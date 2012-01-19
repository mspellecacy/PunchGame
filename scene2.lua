--> Load Storyboard 
local storyboard = require( "storyboard" );
local scene = storyboard.newScene();
local ads = require "ads";
require "ice";
require "sprite";
require "audio";
local math = require("math");
local physics = require("physics");

display.setStatusBar(display.HiddenStatusBar);

--> Variable Setup
----------------------
local DEBUG = false;
local physRunning = true;
--local audioRunning = true;
local cX = display.viewableContentWidth;
local cY = display.viewableContentHeight;
local cCX = cX / 2;
local cCY = cY / 2;
local rand = math.random;
local impactMult = 1000; -- impact multiplier
local gameLen = 60; -- Game length in seconds
local settings = ice:loadBox("settings");
settings:enableAutomaticSaving();
--settings:storeIfNew("audioRunning", true);
local audioRunning = settings:retrieve("audioRunning");
local highScore = ice:loadBox("highscore");
local curHS = highScore:retrieve("highscore");
highScore:storeIfNew("highscore", 0);
highScore:enableAutomaticSaving();

local sndBtn = {};

local numbers = { 
   [string.byte("0")] = "0_white.png",
   [string.byte("1")] = "1_white.png",
   [string.byte("2")] = "2_white.png",
   [string.byte("3")] = "3_white.png",
   [string.byte("4")] = "4_white.png",
   [string.byte("5")] = "5_white.png",
   [string.byte("6")] = "6_white.png",
   [string.byte("7")] = "7_white.png",
   [string.byte("8")] = "8_white.png",
   [string.byte("9")] = "9_white.png",
   [string.byte(" ")] = "space.png",
}


-- Called when the scene's view does not exist:
function scene:createScene( event )
   local group = self.view;

   --> Game Objects setup
   -------------------------

   --> Game play objects
   --local mainJoint = {};
   --local secondJoint = {};
   local plots = {};
   local hitPath = {};
   local hits = {};
   --local dots = {};
   local stars = {};
   local transitions = {};
   local swingDraw = nil;

   --> Game play functions
   local resetHead = {};
   local doImpact = {};
   local calcScore = {};

   --> Create Walls
   local leftWall  = display.newRect (0, 0, 1, display.contentHeight)
   local rightWall = display.newRect (display.contentWidth, 0, 1, display.contentHeight)
   local ceiling   = display.newRect (0, 0, display.contentWidth, 1)
   local floor     = display.newRect (0, display.contentHeight, display.contentWidth, 1)
   group:insert(leftWall);
   group:insert(rightWall);
   group:insert(ceiling);
   group:insert(floor);
   leftWall.isVisible = false;
   rightWall.isVisible = false;
   ceiling.isVisible = false;
   floor.isVisible = false;

   --------------------------------------------------------------------------------
   ------------
   ------------ STATIC IMAGES
   ------------
   --------------------------------------------------------------------------------

   --> Background
   local bg = display.newImageRect("background.png", cX+5, cY);
   group:insert(bg);
   bg:setReferencePoint(display.CenterReferencePoint);
   bg.x = cCX;
   bg.y = cCY;

   --> Obama Body
   local body = display.newImageRect("obama_body.png", 480, 800);
   group:insert(body);
   body:setReferencePoint(display.BottomCenterReferencePoint);
   body.x = cCX+15;
   body.y = cY+5;
   
   --> Back Button
   --local backBtn = display.newImageRect("back.png", 96, 96);
   --group:insert(backBtn);
   --backBtn:setReferencePoint(display.BottomRightReferencePoint);
   --backBtn.alpha = .5;
   --backBtn.x = cX; backBtn.y = cY;
   
   --------------------------------------------------------------------------------
   ------------
   ------------ SPRITES
   ------------
   --------------------------------------------------------------------------------
   --> Setup the bobble sprite sheet
   local bobbleData = require "obama_doll";
   local dataBobble = bobbleData.getSpriteSheetData();
   local bobbleSheet = sprite.newSpriteSheetFromData( "obama_doll.png", dataBobble );
   local bobbleSet = sprite.newSpriteSet(bobbleSheet, 1, 2);
   sprite.add(bobbleSet, "bobble", 1, 6, 1);

   --> Setup the head bottle sprite
   local head = sprite.newSprite(bobbleSet);
   head:prepare("bobble");
   --group:insert(head);

   --> Setup The Glove Sprite
   local gloveData = require "glove";
   local dataGlove = gloveData.getSpriteSheetData();
   local gloveSheet = sprite.newSpriteSheetFromData( "glove.png", dataGlove )
   local gloveSet = sprite.newSpriteSet(gloveSheet, 1, 3)
   sprite.add(gloveSet, "hit", 1, 3, 100, 1);

   --> Setup The Glove
   local glove = sprite.newSprite(gloveSet);
   --local glove = display.newImageRect("rep_glove.png", 480, 800);
   glove.x = -5000;
   glove.y = -5000;
   --group:insert(glove);

   --> Setup display group for score area.
   
   --> Audio Controls
   local sndBtnData = require "sound_toggle";
   local dataSound = sndBtnData.getSpriteSheetData();
   local sndBtnSheet = sprite.newSpriteSheetFromData( "sound_toggle.png", dataSound );
   local sndBtnSet = sprite.newSpriteSet(sndBtnSheet, 1, 2);
   sprite.add(sndBtnSet, "toggle", 1, 2, 1);

   sndBtn = sprite.newSprite(sndBtnSet);
   sndBtn:prepare("toggle");
   if(audioRunning) then
      sndBtn.currentFrame = 2;
   else
      sndBtn.currentFrame = 1;
   end
   sndBtn:setReferencePoint(display.BottomLeftReferencePoint);
   sndBtn.alpha = 0.25;
   sndBtn.x = 0;
   sndBtn.y = cY;
   group:insert(sndBtn);


   --------------------------------------------------------------------------------
   ------------
   ------------ GAME STUFF
   ------------
   --------------------------------------------------------------------------------

   --> Print out some environment info..
   print("\tX: " .. cX);
   print("\tY: " .. cY);

   --> Start Physics
   physics.start(true);
   physics.setScale( 60 );
   if DEBUG then
      --physics.setDrawMode( "debug" )
      physics.setDrawMode( "hybrid" );
   end
   physics.setGravity( 0, 0 );


   --> Setup the play area boundries
   --physics.addBody (leftWall, "static",
   --		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
   --physics.addBody (rightWall, "static",
   --		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
   physics.addBody (ceiling, "static",
		    {density = 1.0, friction = 0, bounce = .02, isSensor = false});
   physics.addBody (floor, "static",
		    {density = 1.0, friction = 0, bounce = .02, isSensor = false});


   --> Construct and place the bobble head.
   head.currentFrame = 1;
   head:setReferencePoint(display.CenterReferencePoint);
   head.x = cCX;
   head.y = cCY+100;

   group:insert(head);
   group:insert(glove); -- Have to insert glove after head so it shows up.

   physics.addBody( head, { density=0.2, friction=0.05, bounce=.95, radius=125 });

   --> Setup the main pivot joint
   mainJoint = physics.newJoint("pivot", head, floor, cCX, head.y+200);
   mainJoint.isLimitEnabled = true;
   mainJoint:setRotationLimits( -45, 45 );

   --> Setup the second 'counter weight' join
   secondJoint = physics.newJoint("distance", ceiling, head,
				  ceiling.x, ceiling.y,
				  head.x, head.y );
   secondJoint.frequency = 10;

   --> Game functions

   local function showTextureMemory()
      print("\t" .. (system.getInfo( "textureMemoryUsed" ) / (1024*1024)) .. "mb");
   end
   
   local function purgeStars()
      for i=1,#stars,1 do
	 stars[i]:removeSelf();
	 stars[i] = nil;
      end
   end
   
   --> Makes the impact all pretty (Shooting Stars!)
   local function doImpact(hitLoc)
      if hitLoc.y > cY then
	 -- This fixes a a bug with letter boxing and stars getting 'stuck' on screen.
	 hitLoc.y = cY-1;
      end
      --> Build some stars
      for i=1,10,1 do 
	 stars[i] = display.newImageRect("star.png", 45, 45);
	 stars[i].height = 45;
	 stars[i].width = 45;
	 stars[i].x = hitLoc.x;
	 stars[i].y = hitLoc.y;
      end
      
      --> Animate some stars
      for i=1,#stars,1 do
	 --> Randomly select what direction (RU,LU,RD,LD) the star will travel.
	 starType = rand(1,4);
	 if(starType == 1) then
	    --> Down and to the Right
	    rT = { x = (hitLoc.x+rand(1,(cX-hitLoc.x))), 
		   y = (hitLoc.y+rand(1,(cY-hitLoc.y)))};
	 elseif(starType == 2) then
	    --> Down and to the Left
	    rT = { x = (hitLoc.x-rand(1,(cX+hitLoc.x))), 
		   y = (hitLoc.y+rand(1,(cY-hitLoc.y)))};
	 elseif(starType == 3) then
	    --> Up and to the Right
	    rT = { x = (hitLoc.x+rand(1,(cX-hitLoc.x))), 
		   y = (hitLoc.y-rand(1,(cY+hitLoc.y)))};
	 elseif(starType == 4) then
	    --> Up and to the Left
	    rT = { x = (hitLoc.x-rand(1,(cX+hitLoc.x))), 
		   y = (hitLoc.y-rand(1,(cY+hitLoc.y)))};
	 end

	 rT.rotation = rand(1,920);
	 rT.time = rand(145,900);
	 rT.alpha = 0;
	 flashRect = display.newRect(0,0,cX+5,cY+5);
	 flashRect.alpha = 0.05;
	 flashRect:setFillColor(255,255,255);
	 transition.to(flashRect,{time=250, alpha=0});
	 transition.to(stars[i], rT);
      end
      --showTextureMemory();
   end

   --> Sets the head back to a state of waiting to be hit (from crying)
   function resetHead( event )
      tScore = score.getScore();
      if (tScore > 250000) then
	 head.currentFrame=6;
      elseif (tScore > 150000) then
	 head.currentFrame=5;
      elseif (tScore > 100000) then
	 head.currentFrame=4;
      elseif(tScore > 25000) then
	 head.currentFrame=3;
      else
	 head.currentFrame=1;
      end
   end

   --> Blast that bitch in the face with fist!
   function blast(velocity, hitLocX)
      head.currentFrame = 2;

      -- Hit on Left or Right?
      xVel = velocity;
      if (hitLocX > cCX) then
	 xVel = (xVel * -1);
      end

      head:applyLinearImpulse(velocity,xVel, head.x, head.y);
      
      if (audioRunning) then
	 --> Cheap and dirty, need to make this more robust.
	 hitSnd = rand(1,2);
	 if (hitSnd == 1) then
	    media.playEventSound( hitSound1 );
	 elseif (hitSnd == 2) then
	    media.playEventSound( hitSound2 );
	 end
      end

      timer.performWithDelay(2000, resetHead);
   end 

   --> Update the score
   function doScore(velocity)
      score.setScore(score.getScore()+(math.round(velocity / 10)));
   end

   -->Stop and start physics for testing purposes.
   function pausePhys(event)
      if physRunning then
	 physics.pause();
	 physRunning = false;
      else
	 physics.start();
	 physRunning = true;
      end
   end

   -->Purge old hits
   function resetPlots()
      plots = nil;
      plots = {};

      --hitPath:removeSelf();
      hitPath = nil;
      hitPath = {};
   end

   --> Basic hit detection
   function hitTestObjects(obj1, obj2)
      local left = ( obj1.contentBounds.xMin <= obj2.contentBounds.xMin and 
		     obj1.contentBounds.xMax >= obj2.contentBounds.xMin );
      local right = ( obj1.contentBounds.xMin >= obj2.contentBounds.xMin and 
		      obj1.contentBounds.xMin <= obj2.contentBounds.xMax );
      local up = ( obj1.contentBounds.yMin <= obj2.contentBounds.yMin and
		   obj1.contentBounds.yMax >= obj2.contentBounds.yMin );
      local down = ( obj1.contentBounds.yMin >= obj2.contentBounds.yMin and
		     obj1.contentBounds.yMin <= obj2.contentBounds.yMax );
      return (left or right) and (up or down)
   end

   --> Basic distance calculator between two plot points
   function distance(px, py, qx, qy) 
      local dx = px - qx;
      local dy = py - qy;
      local dist = math.sqrt(dx*dx + dy*dy);
      return dist;
   end

   --> Draw out the swing, do that fancy stuff like hit detection.
   function drawPlots(startTime, endTime)

      local hitHead = false;
      local velocity = {};
      local hitLoc = {}
      --hitPath = display.newLine( plots[1][1],plots[1][2],
      --			      plots[2][1],plots[2][2] )
      --hitPath:setColor( 255, 102, 102, 255 )
      --hitPath.width = 3

      for i=3,#plots do
	 -- hitPath:append( plots[i][1],plots[i][2] )
	 if (distance(head.x,head.y,plots[i][1],plots[i][2]) < 125) then
	    local hitDelta1 =  plots[i-1][3];
	    local hitDelta2 =  plots[i][3];
	    local timeDelta = hitDelta2 - hitDelta1;
	    if (timeDelta == 0) then timeDelta = 1 end

	    lastHitDist = distance(plots[i-1][1],plots[i-1][2],
				   plots[i][1],plots[i][2])
	    velocity = (lastHitDist / timeDelta);
	    hitHead = true;
	    hitLoc = {x = plots[#plots][1], y = plots[#plots][2]};
	    break;
	 end
      end

      if (hitHead) then
	 doImpact(hitLoc);
	 swingGlove(hitLoc);
	 --> glove:dispose();
	 --> Need an impact velocity multiplier
	 doScore(velocity*impactMult);
	 blast((velocity*impactMult), hitLoc.x);
      end

      --myCircle:setLinearVelocity(50000, 50000);
      --timer.performWithDelay(1000,resetPlots);
   end

   function killGlove(event)
      function finish() 
	 glove.isVisible = false;
	 glove.x = -5000;
	 glove.y = -5000;
      end
      if (event.phase == "end") then
	 timer.performWithDelay(75,finish);
      end
   end

   function swingGlove(hitLoc)
      --> Setup The Glove
      glove.isVisible = false;
      glove:prepare("hit");
      glove.x = hitLoc.x;
      glove.y = hitLoc.y;
      glove.isVisible = true;
      --timer.performWithDelay(1, killGlove);
      glove:addEventListener("sprite",killGlove);
      glove:play();
   end


   --> Primary touch even tracker, everything stems from this.
   function swingEvent(event)
      plot = {};
      startPos = {};
      dots = {};
      if (event.phase == "began") then
	 if(#plots > 1) then
	    resetPlots();
	 end
	 plot = { event.x, event.y, system.getTimer() }
	 plots[#plots+1] = plot;
      elseif (event.phase  == "moved") then
	 plot = { event.x, event.y, system.getTimer() }
	 plots[#plots+1] = plot;
	 if((#plots % 5) == 0) then
	    thisStar = rand(1,2);
	    if(thisStar == 1) then
	       --> Down and to the Right
	       rT = { x = (event.x+rand(1,(cX-event.x))), 
		      y = (event.y+rand(1,(cY-event.y)))};
	    elseif(thisStar == 2) then
	       --> Down and to the Left
	       rT = { x = (event.x-rand(1,(cX+event.x))), 
		      y = (event.y+rand(1,(cY-event.y)))};
	    end

	    rT.rotation = rand(1,920);
	    rT.time = rand(145,900);
	    rT.alpha = 0;

	    dots[#dots+1] = display.newImageRect("rnc.png", 45, 45);
	    dots[#dots].x = event.x;
	    dots[#dots].y = event.y;
	    transition.to(dots[#dots],rT);
	 end
      elseif (event.phase  == "ended") then      
	 plot = { event.x, event.y, system.getTimer() }
	 plots[#plots+1] = plot;
	 dots={};
	 drawPlots();
      end
      return true;
   end


   function toggleAudio(event)
      if audioRunning then
	 sndBtn.currentFrame = 1;
	 audioRunning = false;
	 settings:store("audioRunning", audioRunning);
	 settings:save();
      else
	 sndBtn.currentFrame = 2;
	 audioRunning = true;
	 settings:store("audioRunning", audioRunning);
	 settings:save();
      end
   end

   function updateTime()
      if (countdown.getTime() > 0) then
	 countdown.setTime(countdown.getTime() - 1);
      elseif (countdown.getTime() == 0) then
	 stopGame();
	 resetGame();
      end
   end


   function showHighscore(thisScore)
      -- remove old numerals
      local theBackgroundBorder = 10;
      local numbersGroup = display.newGroup()
      hsGroup:insert( numbersGroup )
      
      -- go through the score, right to left
      local scoreStr = tostring(thisScore)
      
      local scoreLen = string.len( scoreStr )
      local i = 1;
      
      -- starting location is on the right. notice the digits will be centered on the background
      --local x = 45+theBackgroundBorder;
      local x = -145;
      local y = hsGroup.contentHeight / 2
      
      while i <= scoreLen do
	 -- fetch the digit
	 local c = string.byte( scoreStr, i )
	 local digitPath = numbers[c]
	 local characterImage = display.newImageRect( digitPath, 48, 88 )
	 
	 -- put it in the score group
	 hsGroup:insert( characterImage )
	 
	 -- place the digit
	 characterImage.x = x - characterImage.width / 2
	 characterImage.y = y
	 x = x + characterImage.width
	 
	 -- 
	 i = i + 1
      end
   end


   function startGame(event)

      score.setScore(0);

      head.currentFrame = 1;
      -- Remove the tap listener, we dont need it while the game is running
      Runtime:removeEventListener("touch",startGame);

      destroyOverlay();
      -- Add the touch listener for swingEvents (basically starts listening for everything)
      Runtime:addEventListener("touch",swingEvent);

      -- Start up the game timer
      countdownTimer = timer.performWithDelay( 1000, updateTime, -1 )

   end

   function stopGame()
      -- Save score if its higher...
      highScore:storeIfHigher("highscore", score.getScore());
      highScore:save();
      -- Remove swing event listener (stops the game basically)
      timer.cancel(countdownTimer);
      if(audioRunning)then
	 media.playEventSound(finishGroan);
      end
      Runtime:removeEventListener("touch",swingEvent);
      
   end

   function resetGame()
      buildOverlay();
      countdown.setTime(gameLen);
      tapToStart:addEventListener("tap",startGame);
   end
   
   function buildOverlay()
      --> Notify user that they need to tap the screen to start palying...
      tapToStart = display.newImageRect("tap_button.png", 356, 121);
      tapToStart:setReferencePoint(display.CenterReferencePoint);
      tapToStart.x = cCX;
      tapToStart.y = cCY-100;
      
      --> Show a highscore label...
      --.. highScore:retrieve("highscore")
      highscoreLabel = display.newImageRect("highscore.png", 464, 168);
     
      highscoreLabel:setReferencePoint(display.CenterReferencePoint);
      highscoreLabel.x = cCX;
      highscoreLabel.y = cCY+200;

      
      hsGroup = display.newGroup();
      hsGroup.x = cCX; hsGroup.y = cCY+235;

      showHighscore(highScore:retrieve("highscore"));

   end

   function destroyOverlay()
      tapToStart:removeEventListener("touch",startGame);
      tapToStart:removeSelf();
      highscoreLabel:removeSelf();
      hsGroup:removeSelf();
   end

   function goBack(event)
      storyboard.gotoScene( "scene1", "fade", 400 );
      countdownTimer = nil;
      countdownTimer = {}
      destroyOverlay();
   end


   
end  -- scene:createScene(event)


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
   local group = self.view

   --native.setActivityIndicator( false );
   -- remove previous scene's view
   storyboard.purgeScene("scene1");
   
   --> Score
   local score = require("score");
   local scoreInfo = score.getInfo();
   score.init({ x = 15, y = 135 });
   score.setScore(0);
   

   --> Game Countdown
   local countdown = require("countdown");
   local cdinfo = countdown.getInfo();
   countdown.init({ x = (cX - cdinfo.contentWidth) - 15, y = 135 });
   countdown.setTime(gameLen);

   --> Countdown Timer
   local countdownTimer = {};
 
   -- Example for inneractive:
   --ads.init( "inneractive", "IA_GameTest" )  --Debug
   ads.init( "inneractive", "LeftSquare_PunchGame_Android" );  --PunchGame ID
   -- iPhone, iPod touch, iPad, android etc
   ads.show( "banner", { x=0, y=0, interval=30 } );
   --ads.show( "fullscreen", { x=0, y=0, interval=60 } )
   --ads.show( "text", { x=0, y=100, interval=60 } )

   --> Setup the Event Sounds
   hitSound1 = media.newEventSound( "hit_sound1.mp3" );
   hitSound2 = media.newEventSound( "hit_sound2.mp3" );
   finishGroan = media.newEventSound( "finish_groan.mp3" );
   --hitRespo1 = media.newEventSound( "sounds/hit_response1.mp3" );
   --hitRespo2 = media.newEventSound( "sounds/hit_response2.mp3" );
   --hitRespo3 = media.newEventSound( "sounds/hit_response3.mp3" );

   buildOverlay();

   
   --> Wait for Tap Event to start game.
   sndBtn:addEventListener("tap",toggleAudio);
   tapToStart:addEventListener("touch",startGame);
   
   --Runtime:addEventListener("tap", goBack);
   --Runtime:addEventListener("touch",swingEvent);

   -----------------------------------------------------------------------------
   
   --	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
   
   -----------------------------------------------------------------------------
   
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
   local group = self.view
   
   -----------------------------------------------------------------------------
   
   --	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
   
   -----------------------------------------------------------------------------
   
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
   local group = self.view
   
   -----------------------------------------------------------------------------
   
   --	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
   
   -----------------------------------------------------------------------------
   
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene
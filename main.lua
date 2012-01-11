--
-- Project: PunchGame
-- Description: 
--
-- Version: 1.0
--
-- Copyright 2011 Michael Spellecacy & Cody Sowl. All Rights Reserved.
-- Code By: Michael Spellecacy
-- Art By: Cody Sowl

--> Imports
---------------
require "sprite"
require "audio"
local math = require("math");
local physics = require("physics")
local gameui = require("gameui");

--> Variable Setup
----------------------
local DEBUG = false;
local physRunning = true;
local cX = display.contentWidth;
local cY = display.contentHeight;
local cCX = cX / 2;
local cCY = cY / 2;
local rand = math.random;



--> Game Objects setup
-------------------------

--> Game play objects
local mainJoint = {};
local secondJoint = {};
local plots = {};
local hitPath = {};
local hits = {};
local dots = {};
local stars = {};
local transitions = {};
local swingDraw = nil;

--> Game play functions
local resetHead = {};
local doImpact = {};

--> Create Walls
local leftWall  = display.newRect (0, 0, 1, display.contentHeight)
local rightWall = display.newRect (display.contentWidth, 0, 1, display.contentHeight)
local ceiling   = display.newRect (0, 0, display.contentWidth, 1)
local floor     = display.newRect (0, display.contentHeight, display.contentWidth, 1)

--> Background
local bg = display.newImageRect("background.png", cX, cY);
bg:setReferencePoint(display.CenterReferencePoint);
bg.x = cCX;
bg.y = cCY;

-->Setup the bobble sprite
local bobbleData = require "obama_doll"
local data = bobbleData.getSpriteSheetData()
local bobbleSheet = sprite.newSpriteSheetFromData( "obama_doll.png", data )
local bobbleSet = sprite.newSpriteSet(bobbleSheet, 1, 2)
sprite.add(bobbleSet, "bobble", 1, 2, 1);

-->Setup the head sprite
local head = sprite.newSprite(bobbleSet);
head:prepare("bobble");


--> Start Game
------------------
--> Print out some environment info..
if DEBUG then
   print("\tH: " .. cY);
   print("\tW: " .. cX);
end

--> Start Physics
physics.start(true)
physics.setScale( 60 )
if DEBUG then
   --physics.setDrawMode( "debug" )
   physics.setDrawMode( "hybrid" );
end
physics.setGravity( 0, 0 )


--> Setup the play area boundries
--physics.addBody (leftWall, "static",
--		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
--physics.addBody (rightWall, "static",
--		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (ceiling, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (floor, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})


--> Construct and place the bobble head.
head.currentFrame = 1;
head:setReferencePoint(display.CenterReferencePoint);
head.x = cX / 2;
head.y = cY / 2;
physics.addBody( head, { density=0.2, friction=0.05, bounce=.95, radius=125 })

-->Setup the main pivot joint
mainJoint = physics.newJoint("pivot", head, floor, cX/2, cY/2+235)
mainJoint.isLimitEnabled = true;
mainJoint:setRotationLimits( -45, 45 );

-->Setup the second 'counter weight' join
secondJoint = physics.newJoint("distance", ceiling, head,
			       ceiling.x, ceiling.y,
			       head.x, head.y );
secondJoint.frequency = 10;

-->Setup the Sounds
hitSound1 = media.newEventSound( "hit_sound1.mp3" );
--hitSound2 = media.newEventSound( "sounds/hit_sound2.mp3" );
--hitSound3 = media.newEventSound( "sounds/hit_sound3.mp3" );
--hitRespo1 = media.newEventSound( "sounds/hit_response1.mp3" );
--hitRespo2 = media.newEventSound( "sounds/hit_response2.mp3" );
--hitRespo3 = media.newEventSound( "sounds/hit_response3.mp3" );

--> Game functions
local function purgeStars()
      for i=1,#stars,1 do
	 stars[i]:removeSelf();
	 stars[i] = nil;
      end
end

local function doImpact(hitLoc)

   --> Build some stars
   for i=1,15,1 do 
      stars[i] = display.newImageRect("star.png", 45, 45);
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
		y = (hitLoc.y+rand(1,(cY-hitLoc.y)))}
      elseif(starType == 2) then
	 --> Down and to the Left
	 rT = { x = (hitLoc.x-rand(1,(cX+hitLoc.x))), 
		y = (hitLoc.y+rand(1,(cY-hitLoc.y)))}
      elseif(starType == 3) then
	 --> Up and to the Right
	 rT = { x = (hitLoc.x+rand(1,(cX-hitLoc.x))), 
		y = (hitLoc.y-rand(1,(cY+hitLoc.y)))}
      elseif(starType == 4) then
	 --> Up and to the Left
	 rT = { x = (hitLoc.x-rand(1,(cX+hitLoc.x))), 
		y = (hitLoc.y-rand(1,(cY+hitLoc.y)))}
      end

      rT.rotation = rand(1,920);
      rT.time = rand(145,900);
      rT.alpha = 0;
      flashRect = display.newRect(0,0,cX,cY);
      flashRect.alpha = 0.05;
      flashRect:setFillColor(255,255,255);
      transition.to(flashRect,{time=250, alpha=0});
      transition.to(stars[i], rT);
   end
end

function resetHead( event )
   head.currentFrame=1;
end

local function blast(velocity)
   head.currentFrame = 2;
   head:applyLinearImpulse(velocity,velocity, head.x, head.y);
   media.playEventSound( hitSound1 );
   timer.performWithDelay(2000, resetHead);
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
   local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
   local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
   local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
   local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
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
   impactMult = 1000;
   local hitHead = false;
   local velocity = {};
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
	 doImpact({x=plots[i][1],y=plots[i][2]});
	 break;
      end
   end
   if (hitHead) then
      --need an impact velocity multiplier
      blast(velocity*impactMult);
   end
   --myCircle:setLinearVelocity(50000, 50000);
   timer.performWithDelay(1000,resetPlots);
end

function swingEvent(event)
   local plot = {};
   local startPos = {};
   if (event.phase == "began") then
      if(#plots > 1) then
	 resetPlots();
      end
      plot = { event.x, event.y, system.getTimer() }
      plots[#plots+1] = plot;
   elseif (event.phase  == "moved") then
      plot = { event.x, event.y, system.getTimer() }
      plots[#plots+1] = plot;
      if((#plots % 10) == 0) then
	 
	 if(event.x > cCX) then
	    --> Down and to the Right
	    rT = { x = (event.x+rand(1,(cX-event.x))), 
		   y = (event.y+rand(1,(cY-event.y)))}
	 elseif(event.x < cCX) then
	    --> Down and to the Left
	    rT = { x = (event.x-rand(1,(cX+event.x))), 
		   y = (event.y+rand(1,(cY-event.y)))}
	 end

	 rT.rotation = rand(1,920);
	 rT.time = rand(145,900);
	 rT.alpha = 0;

	 dots[#dots+1] = display.newImageRect("star.png", 45, 45);
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




--> Main touch event handler
Runtime:addEventListener("touch",swingEvent);

if DEBUG then
   print("\t" .. (system.getInfo( "textureMemoryUsed" ) / (1024*1024)) .. "mb");
end
--Runtime:addEventListener("tap",pausePhys);

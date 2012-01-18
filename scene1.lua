----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local playBtn;
-- Touch event listener for play button
local cX = display.viewableContentWidth;
local cY = display.viewableContentHeight;
local cCX = cX / 2;
local cCY = cY / 2;


local function killCreditsText(self, event)
   if event.phase == "began" then
      cText:removeSelf();
      return true;
   end
end

local function onCreditsTouch( self, event )
   if (event.phase == "began") then
      cText = display.newImageRect("credits_text.png", cX+5, cY+5);
      cText:setReferencePoint(display.CenterReferencePoint);
      cText.alpha = 0;
      cText.x = cCX; cText.y = cCY;
      cText.touch = killCreditsText;
      cText:addEventListener("touch", cText);
      transition.to(cText, {alpha = 1, time=150});
   end
end


local function killHelpText(self, event)
   if event.phase == "began" then
      hText:removeSelf();
      return true;
   end
end

local function onHelpTouch( self, event )
   if (event.phase == "began") then
      hText = display.newImageRect("help_text.png", cX+5, cY+5);
      hText:setReferencePoint(display.CenterReferencePoint);
      hText.alpha = 0;
      hText.x = cCX; hText.y = cCY;
      hText.touch = killHelpText;
      hText:addEventListener("touch", hText);
      transition.to(hText, {alpha = 1, time=150});
   end
end

local function onPlayTouch( self, event )
   if event.phase == "began" then
      native.setActivityIndicator( true );
      storyboard.gotoScene( "scene2", "fade", 400  );
      return true
   end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view;

	--> Load BG
	titlebg = display.newImageRect("titlebg.png",cX+5,cY+5);
	titlebg:setReferencePoint(display.CenterReferencePoint);
	titlebg.x = cCX; titlebg.y = cCY;
	group:insert(titlebg);

	--> Load BG
	title = display.newImageRect("title.png",545,300);
	title:setReferencePoint(display.CenterReferencePoint);
	title.x = cCX; title.y = cCY-300;
	group:insert(title);

	--> Dem Glove
	demglove = display.newImage("dem_glove.png");
	demglove:setReferencePoint(display.CenterReferencePoint);
	demglove.x = cCX; demglove.y = cCY;
	group:insert(demglove);

	--> Rep Glove
	repglove = display.newImage("rep_glove.png");
	repglove:setReferencePoint(display.CenterReferencePoint);
	repglove.x = cCX; repglove.y = cCY;
	group:insert(repglove);

	--> Play Button
	playBtn = display.newImageRect("play_button.png", 309, 93);
	playBtn:setReferencePoint(display.CenterReferencePoint)
	playBtn.x = cCX; playBtn.y = cCY+125;
	playBtn.touch = onPlayTouch;
	group:insert(playBtn);

	--> Help Button
	helpBtn = display.newImageRect("help_button.png", 222, 66);
	helpBtn:setReferencePoint(display.CenterReferencePoint)
	helpBtn.x = cCX; helpBtn.y = cCY+230;
	helpBtn.touch = onHelpTouch;
	group:insert(helpBtn);

	--> Credits Button
	creditsBtn = display.newImageRect("credits_button.png", 240, 70);
	creditsBtn:setReferencePoint(display.BottomRightReferencePoint)
	creditsBtn.x = cX; creditsBtn.y = cY;
	creditsBtn.touch = onCreditsTouch;
	group:insert(creditsBtn);


	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	playBtn:addEventListener("touch", playBtn );
	helpBtn:addEventListener("touch", helpBtn );
	creditsBtn:addEventListener("touch", creditsBtn );
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
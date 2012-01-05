--
-- Project: PunchGame
-- Description: 
--
-- Version: 1.0
--
-- Copyright 2011 Michael Spellecacy & Cody Sowl. All Rights Reserved.
--

require "sprite"
require "audio"

local physics = require("physics")
physics.start(true)
local physRunning = true;

physics.setScale( 60 )
--physics.setDrawMode( "debug" )
--physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 9.8 )

local _H, _W = display.contentHeight, display.contentWidth;
print("\tH: " .. _H);
print("\tW: " .. _W);

local circle = "";
--> Create Walls
local leftWall  = display.newRect (0, 0, 1, display.contentHeight)
local rightWall = display.newRect (display.contentWidth, 0, 1, display.contentHeight)
local ceiling   = display.newRect (0, 0, display.contentWidth, 1)
local floor     = display.newRect (0, display.contentHeight, display.contentWidth, 1)

physics.addBody (leftWall, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (rightWall, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (ceiling, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (floor, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})


-->Setup the Background
local bg = display.newImageRect("images/background.png", _W, _H);
bg:setReferencePoint(display.CenterReferencePoint);
bg.x, bg.y =  _W/2, _H/2

-->Setup the bobble sprite
local bobbleData = require "images/obama_doll"
local data = bobbleData.getSpriteSheetData()
local bobbleSheet = sprite.newSpriteSheetFromData( "images/obama_doll.png", data )
local bobbleSet = sprite.newSpriteSet(bobbleSheet, 1, 2)
sprite.add(bobbleSet, "bobble", 1, 2, 1);

-->Setup the head sprite
local head = sprite.newSprite(bobbleSet);
head:prepare("bobble");
head.currentFrame = 1;
head:setReferencePoint(display.CenterReferencePoint)
head.x,head.y = _W / 2, _H / 2;

physics.addBody( head, { density=0.2, friction=0.25, bounce=.75, radius=125 })

-->Setup the main pivot joint
local mainJoint = {};
mainJoint = physics.newJoint("pivot", head, floor, _W/2, _H/2+235)
mainJoint.isLimitEnabled = true;
mainJoint:setRotationLimits( -45, 45 );

-->Setup the second 'counter weight' join
secondJoint = physics.newJoint("distance", ceiling, head,
			       ceiling.x, ceiling.y,
			       head.x, head.y )
secondJoint.frequency = 10;

-->Setup the Sounds
hitSound1 = media.newEventSound( "sounds/hit_sound1.mp3" );
--hitSound2 = media.newEventSound( "sounds/hit_sound2.mp3" );
--hitSound3 = media.newEventSound( "sounds/hit_sound3.mp3" );
--hitRespo1 = media.newEventSound( "sounds/hit_response1.mp3" );
--hitRespo2 = media.newEventSound( "sounds/hit_response2.mp3" );
--hitRespo3 = media.newEventSound( "sounds/hit_response3.mp3" );


local resetHead = {}

function resetHead( event )
   head.currentFrame=1;
end

local function blast( event )
   
   head.currentFrame = 2;
   head:applyLinearImpulse(1000,1000, head.x, head.y);
   media.playEventSound( hitSound1 );
   timer.performWithDelay(2000, resetHead);
end 

function pausePhys(event)
   if physRunning then
      physics.pause();
      physRunning = false;
   else
      physics.start();
      physRunning = true;
   end
end


--head:applyLinearImpulse(5000,5000, head.x, head.y)
Runtime:addEventListener("tap",blast);
--Runtime:addEventListener("tap",pausePhys);





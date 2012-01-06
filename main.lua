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
local math = require("math");
local DEBUG = false;

local physics = require("physics")
physics.start(true)
local physRunning = true;
local gameui = require("gameui");


physics.setScale( 60 )
if DEBUG then
   --physics.setDrawMode( "debug" )
   physics.setDrawMode( "hybrid" )
end
physics.setGravity( 0, 0 )

local _H, _W = display.contentHeight, display.contentWidth;
if DEBUG then
   print("\tH: " .. _H);
   print("\tW: " .. _W);
end

local circle = "";
--> Create Walls
local leftWall  = display.newRect (0, 0, 1, display.contentHeight)
local rightWall = display.newRect (display.contentWidth, 0, 1, display.contentHeight)
local ceiling   = display.newRect (0, 0, display.contentWidth, 1)
local floor     = display.newRect (0, display.contentHeight, display.contentWidth, 1)

--physics.addBody (leftWall, "static",
--		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
--physics.addBody (rightWall, "static",
--		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (ceiling, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})
physics.addBody (floor, "static",
		 {density = 1.0, friction = 0, bounce = .02, isSensor = false})


-->Setup the Background
local bg = display.newImageRect("background.png", _W, _H);
bg:setReferencePoint(display.CenterReferencePoint);
bg.x, bg.y =  _W/2, _H/2

-->Setup the bobble sprite
local bobbleData = require "obama_doll"
local data = bobbleData.getSpriteSheetData()
local bobbleSheet = sprite.newSpriteSheetFromData( "obama_doll.png", data )
local bobbleSet = sprite.newSpriteSet(bobbleSheet, 1, 2)
sprite.add(bobbleSet, "bobble", 1, 2, 1);

-->Setup the head sprite
local head = sprite.newSprite(bobbleSet);
head:prepare("bobble");
head.currentFrame = 1;
head:setReferencePoint(display.CenterReferencePoint);

head.x,head.y = _W / 2, _H / 2;

physics.addBody( head, { density=0.2, friction=0.05, bounce=.95, radius=125 })

-->Setup the main pivot joint
local mainJoint = {};
mainJoint = physics.newJoint("pivot", head, floor, _W/2, _H/2+235)
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


local resetHead = {}

function resetHead( event )
   head.currentFrame=1;
end

local function blast(velocity)
   head.currentFrame = 2;
   head:applyLinearImpulse(velocity,velocity, head.x, head.y);
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




local plots = {};
local hitPath = {};

function resetPlots()
   plots = {};
   hitPath:removeSelf();
   assert(hitPath, "\tignore me");
   hitPath = {};
end

function hitTestObjects(obj1, obj2)
        local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
        local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
        local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
        local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
        return (left or right) and (up or down)
end

function distance(px, py, qx, qy) 
   local dx = px - qx;
   local dy = py - qy;
   local dist = math.sqrt(dx*dx + dy*dy);
   return dist;
end

--[[
public double distance(Point p, Point q)
{ double dx   = p.x - q.x;         //horizontal difference 
  double dy   = p.y - q.y;         //vertical difference 
  double dist = Math.sqrt( dx*dx + dy*dy ); //distance using Pythagoras theorem
  return dist;
}
--]]

function drawPlots(startTime, endTime)
   local hitHead = false;
   local velocity = {};
   local hitBox = display.newCircle(head.x,head.y, 125);
   hitBox.isVisible = false;
   hitPath = display.newLine( plots[1][1],plots[1][2],
			      plots[2][1],plots[2][2] )
   hitPath:setColor( 255, 102, 102, 255 )
   hitPath.width = 3 
   --do only every 5 plots 'cause otherwise its just too much
   for i=3,#plots do
      hitPath:append( plots[i][1],plots[i][2] )
      if (hitTestObjects(hitPath, hitBox)) then
	 local hitDelta1, hitDelta2 = plots[i-1][3], plots[i][3];
	 local timeDelta = hitDelta2 - hitDelta1;
	 if (timeDelta == 0) then timeDelta = 1 end

	 lastHitDist = distance(plots[i-1][1],plots[i-1][2],
				plots[i][1],plots[i][2])
	 velocity = (lastHitDist / timeDelta);
	 --print("\tDistance: " .. lastHitDist);
	 --print("\tTime Delta: " .. (hitDelta2 - hitDelta1));
	 --print("\tVelocity: " .. velocity);
	 hitHead = true;
	 --print ("\tBREAK!");
	 break;
      end
   end
   if (hitHead) then
      --need an impact velocity multiplier
      blast(velocity*1000);
   end
   --myCircle:setLinearVelocity(50000, 50000);
   timer.performWithDelay(1000,resetPlots);
end

function swingEvent(event)
   local plot = {};
   local startTime = system.getTimer();
   if (event.phase == "began") then
      if(#plots > 1) then
	 resetPlots();
      end
      plot = { event.x, event.y, system.getTimer() }
      plots[#plots+1] = plot;
   elseif (event.phase  == "moved") then
      plot = { event.x, event.y, system.getTimer() }
      plots[#plots+1] = plot;
   elseif (event.phase  == "ended") then
      plot = { event.x, event.y, system.getTimer() }
      plots[#plots+1] = plot;
      --print("\tPlot Count: " .. #plots);
      drawPlots();      
   end
   return true;
end


--head:applyLinearImpulse(5000,5000, head.x, head.y)

Runtime:addEventListener("touch",swingEvent);
if DEBUG then
   print("\t" .. (system.getInfo( "textureMemoryUsed" ) / (1024*1024)) .. "mb");
end
--Runtime:addEventListener("tap",pausePhys);                                    

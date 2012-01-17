-- A sample score keeping display
-- This updates a display for a numeric score
-- Example usage:
--	Place the score at 50,50
-- 		score.init( { x = 50, y = 50 } )
--	Update the score to current value + 10:
--		score.setScore( score.getScore() + 10 )

module(..., package.seeall)

-- Init images. This creates a map of characters to the names of their corresponding images.
local numbers = { 
   [string.byte("0")] = "0.png",
   [string.byte("1")] = "1.png",
   [string.byte("2")] = "2.png",
   [string.byte("3")] = "3.png",
   [string.byte("4")] = "4.png",
   [string.byte("5")] = "5.png",
   [string.byte("6")] = "6.png",
   [string.byte("7")] = "7.png",
   [string.byte("8")] = "8.png",
   [string.byte("9")] = "9.png",
   [string.byte(" ")] = "space.png",
   [string.byte(":")] = "colon.png",
   [string.byte("s")] = "s.png",
}

-- score components
local theTimeGroup = display.newGroup()
local theBackground = display.newImage( "timerbg.png");
local theBackgroundBorder = 10

theTimeGroup:insert( theBackground )

local numbersGroup = display.newGroup()
theTimeGroup:insert( numbersGroup )

-- the remaining time in seconds
local theTime = 0

-- the location of the score image

-- initialize the score
-- 		params.x <= X location of the score
-- 		params.y <= Y location of the score
function init( params )
   theTimeGroup.x = params.x
   theTimeGroup.y = params.y
   setTime( 0 )
end

-- retrieve score panel info
--		result.x <= current panel x
--		result.y <= current panel y
--		result.xmax <= current panel x max
--		result.ymax <= current panel y max
--		result.contentWidth <= panel width
--		result.contentHeight <= panel height
--		result.score <= current score
function getInfo()
   return {
      x = theTimeGroup.x,
      y = theTimeGroup.y,
      xmax = theTimeGroup.x + theTimeGroup.contentWidth,
      ymax = theTimeGroup.y + theTimeGroup.contentHeight,
      contentWidth = theTimeGroup.contentWidth,
      contentHeight = theTimeGroup.contentHeight,
      time = theTime
	  }
end

-- update display of the current score.
-- this is called by setScore, so normally this should not be called
function update()
   -- remove old numerals
   theTimeGroup:remove(2)

   local numbersGroup = display.newGroup()
   theTimeGroup:insert( numbersGroup )

   -- go through the score, right to left
   local timeStr = tostring( theTime .. "s" )

   local timeLen = string.len( timeStr )
   local i = 1;

   -- starting location is on the right. notice the digits will be centered on the background
   local x = 45+theBackgroundBorder;
   --local x = theScoreGroup.contentWidth;
   local y = theTimeGroup.contentHeight / 2

   while i <= timeLen do
      -- fetch the digit
      local c = string.byte( timeStr, i )
      local digitPath = numbers[c]
      local characterImage = display.newImageRect( digitPath, 48, 88 )

      -- put it in the score group
      numbersGroup:insert( characterImage )
      
      -- place the digit
      characterImage.x = x - characterImage.width / 2
      characterImage.y = y
      x = x + characterImage.width

      -- 
      i = i + 1
   end
end

-- get current score
function getTime()
   return theTime
end

-- set score to value
--	score <= score value
function setTime( time )
   theTime = time
   
   update()
end

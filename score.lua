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
}

-- score components
local theScoreGroup = display.newGroup()
local theBackground = display.newImage( "scorebg.png");
local theBackgroundBorder = 10

theScoreGroup:insert( theBackground )

local numbersGroup = display.newGroup()
theScoreGroup:insert( numbersGroup )

-- the current score
local theScore = 0

-- the location of the score image

-- initialize the score
-- 		params.x <= X location of the score
-- 		params.y <= Y location of the score
function init( params )
   theScoreGroup.x = params.x
   theScoreGroup.y = params.y
   setScore( 0 )
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
      x = theScoreGroup.x,
      y = theScoreGroup.y,
      xmax = theScoreGroup.x + theScoreGroup.contentWidth,
      ymax = theScoreGroup.y + theScoreGroup.contentHeight,
      contentWidth = theScoreGroup.contentWidth,
      contentHeight = theScoreGroup.contentHeight,
      score = theScore
	  }
end

-- update display of the current score.
-- this is called by setScore, so normally this should not be called
function update()
   -- remove old numerals
   theScoreGroup:remove(2)

   local numbersGroup = display.newGroup()
   theScoreGroup:insert( numbersGroup )

   -- go through the score, right to left
   local scoreStr = tostring( theScore )

   local scoreLen = string.len( scoreStr )
   local i = 1;

   -- starting location is on the right. notice the digits will be centered on the background
   local x = 45+theBackgroundBorder;
   --local x = theScoreGroup.contentWidth;
   local y = theScoreGroup.contentHeight / 2

   while i <= scoreLen do
      -- fetch the digit
      local c = string.byte( scoreStr, i )
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
function getScore()
   return theScore
end

-- set score to value
--	score <= score value
function setScore( score )
   theScore = score
   
   update()
end

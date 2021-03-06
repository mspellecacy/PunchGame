-- This file is for use with Corona Game Edition
-- 
-- The function getSpriteSheetData() returns a table suitable for importing using sprite.newSpriteSheetFromData()
-- 
-- This file is automatically generated with TexturePacker (http://texturepacker.com). Do not edit
-- $TexturePacker:SmartUpdate:a5b27a4d494f74d0266c63d196b7d796$
-- 
-- Usage example:
--        local sheetData = require "ThisFile.lua"
--        local data = sheetData.getSpriteSheetData()
--        local spriteSheet = sprite.newSpriteSheetFromData( "Untitled.png", data )
-- 
-- For more details, see http://developer.anscamobile.com/content/game-edition-sprite-sheets

local SpriteSheet = {}
SpriteSheet.getSpriteSheetData = function ()
	return {
		frames = {
			{
				name = "obama_bobble1.png",
				spriteColorRect = { x = 3, y = 49, width = 470, height = 610 },
				textureRect = { x = 474, y = 1226, width = 470, height = 610 },
				spriteSourceSize = { width = 480, height = 800 },
				spriteTrimmed = true,
				textureRotated = false
			},
			{
				name = "obama_bobble2.png",
				spriteColorRect = { x = 3, y = 49, width = 470, height = 610 },
				textureRect = { x = 2, y = 1226, width = 470, height = 610 },
				spriteSourceSize = { width = 480, height = 800 },
				spriteTrimmed = true,
				textureRotated = false
			},
			{
				name = "obama_bobble3.png",
				spriteColorRect = { x = 3, y = 49, width = 470, height = 610 },
				textureRect = { x = 474, y = 614, width = 470, height = 610 },
				spriteSourceSize = { width = 480, height = 800 },
				spriteTrimmed = true,
				textureRotated = false
			},
			{
				name = "obama_bobble4.png",
				spriteColorRect = { x = 3, y = 49, width = 470, height = 610 },
				textureRect = { x = 2, y = 614, width = 470, height = 610 },
				spriteSourceSize = { width = 480, height = 800 },
				spriteTrimmed = true,
				textureRotated = false
			},
			{
				name = "obama_bobble5.png",
				spriteColorRect = { x = 3, y = 49, width = 470, height = 610 },
				textureRect = { x = 474, y = 2, width = 470, height = 610 },
				spriteSourceSize = { width = 480, height = 800 },
				spriteTrimmed = true,
				textureRotated = false
			},
			{
				name = "obama_bobble6.png",
				spriteColorRect = { x = 3, y = 49, width = 470, height = 610 },
				textureRect = { x = 2, y = 2, width = 470, height = 610 },
				spriteSourceSize = { width = 480, height = 800 },
				spriteTrimmed = true,
				textureRotated = false
			},
		}
	}
end
return SpriteSheet


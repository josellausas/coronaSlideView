-------------------------------------------------------
--					main.lua
-- Jose Llausas - jose@zunware.com
-------------------------------------------------------

-- Demo for multi-instance SlideView

-- Based on Corona SDK sample code.


display.setStatusBar(display.HiddenStatusBar)

local slideView = require("Zunware_SlideView")

local topImages = {
	"images/top/top_01.png",
	"images/top/top_02.png",
	"images/top/top_03.png",
	--"top_04.png"
}

local botImages = {
	"images/bot/bot_01.png",
	"images/bot/bot_02.png",
	"images/bot/bot_03.png",
	--"bot_04.png",
}


local b = slideView.new(botImages, nil)
local a = slideView.new(topImages, nil)

-- Change positions for SlideViews
a.y = -99
b.y = 100
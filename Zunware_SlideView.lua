---------------------------------------------------------------
--					Modular Slider by JLZ					 --
--					jose@zunware.com						 --
---------------------------------------------------------------

--[[This Module presents a way to instantiate multiple sliders in
	 a single view. I created this because the samle code from 
	 Corona SDK only lets you create one instance for a certain 
	 view. ]] 


module(..., package.seeall)

---------------------------------------------------------------
-- Move Settings:
local minimumDragTolerance = 60 
---------------------------------------------------------------

-- Constants:
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight
local pad = 20
local top = 0
local bottom = 0

--[[ Creates and returns a new Instance of a slider. The slider IsA diplayGroup,
		so it can listen for the "touch" event.]]
function new(imageSet, slideBackground)
	local slider = display.newGroup()
	slider.images = {}
	slider.imgNum = nil

	-- Create Images with provided imageset
	for i=1, #imageSet do
		local p = display.newImage(imageSet[i])
		local h = viewableScreenH-(top+bottom)

		-- Resize images:
		if p.width > viewableScreenW or p.height > h then
			if p.width/viewableScreenW > p.height/h then 
					p.xScale = viewableScreenW/p.width
					p.yScale = viewableScreenW/p.width
			else
					p.xScale = h/p.height
					p.yScale = h/p.height
			end		 
		end
		-- Add to group:
		slider:insert(p)

		-- Place all images except first offscreen:
		if (i > 1) then
			p.x = screenW*1.5 + pad -- all images offscreen except the first one
		else 
			p.x = screenW*.5
		end
		-- Center height:
		p.y = h*.5
		slider.images[i] = p
	end -- Create Images

	-- Default the starting image to the first:
	slider.imgNum = 1
	-- Default position at center of screen:
	slider.x = 0
	slider.y = top + display.screenOriginY


	function slider:touch(event)
		local phase = event.phase

		if (phase == "began") then
			-- Set foucs so this image registers the touch event until touch has ended.
			display.getCurrentStage():setFocus(self.images[self.imgNum])
			self.images[self.imgNum].isFocus = true
			-- Record the coords of start event
			self.startPos = event.x
			self.prevPos = event.x

		elseif self.images[self.imgNum].isFocus then
			
			if (phase == "moved") then
				if self.tween then transition.cancel(self.tween) end
				-- Calculate the difference in movement since touch started
				local delta = event.x - self.prevPos
				self.prevPos = event.x
				-- Move the image by drag amount
				self.images[self.imgNum].x = self.images[self.imgNum].x + delta

				-- Move Previous Image by delta
				if( self.images[self.imgNum-1]) then
					self.images[self.imgNum-1].x = self.images[self.imgNum-1].x + delta
				end

				-- Move next image by delta:
				if (self.images[self.imgNum+1]) then
					self.images[self.imgNum+1].x = self.images[self.imgNum+1].x + delta
				end

			elseif (phase == "ended" or phase == "cancelled") then
				
				local dragDistance = event.x - self.startPos
				
				-- Determine if enough drag was done, then change Image
				if(dragDistance < -minimumDragTolerance and self.imgNum < #self.images) then
					self:nextImage()
				elseif (dragDistance > minimumDragTolerance and self.imgNum > 1) then
					self:prevImage()
				else
					self:cancelMove()
				end


				if (phase == "cancelled") then
					self:cancelMove()
				end
				-- Restore nil focus.
				display.getCurrentStage():setFocus(nil)
				self.images[self.imgNum].isFocus = false
			end
		end
		return true
	end -- End touch()

	function slider:setSlideNumber()
	print("TODO: setSlideNumber")
	end

	function slider:cancelTween()
		if self.prevTween then
			transition.cancel(self.prevTween)
		end
		self.prevTween = self.tween
	end

	function slider:nextImage()
		-- Move current image
		self.tween  = transition.to( self.images[self.imgNum], {
				time=400,
				x=(screenW * 0.5 + pad) * -1,
				transition=easing.outExpo
			})

		-- Move next image
		self.tween = transition.to( self.images[self.imgNum+1], {
				time = 400,
				x = screenW * 0.5,
				transition=easing.outExpo
			})

		-- Update Slider
		self.imgNum = self.imgNum + 1
		self:initImage(self.imgNum)
	end

	function slider:prevImage()
		-- Move current Image
		self.tween = transition.to(
			self.images[self.imgNum],
			{
				time=400,
				x = screenW * 1.5 + pad,
				transition = easing.outExpo
			}
		)

		-- Move previous Image
		self.tween = transition.to(
			self.images[self.imgNum-1], 
			{
				time=400,
				x = screenW * 0.5,
				transition = easing.outExpo
			}
		)

		-- Update slider
		self.imgNum = self.imgNum -1
		self:initImage(self.imgNum)
	end

	function slider:cancelMove()
		-- Current Image
		tween = transition.to (
			self.images[self.imgNum],
			{
				time = 400,
				x = screenW * 0.5,
				transition = easing.outExpo
			}
		)

		-- Previous Image:
		tween = transition.to(
			self.images[self.imgNum-1], 
			{
				time = 400,
				x = (screenW * 0.5 + pad) * -1,
				transition = easing.outExpo
			}
		)

		-- Next Image:
		tween = transition.to(
			self.images[self.imgNum+1], 
			{
				time = 400,
				x = (screenW * 1.5 + pad),
				transition = easing.outExpo
			}
		)
	end

	function slider:initImage(num)
		if(num < #self.images) then
			self.images[num+1].x = screenW * 1.5 + pad
		end

		if(num > 1) then
			self.images[num-1].x = (screenW * 0.5 + pad) * -1
		end
	end

	function slider:jumpToImage(num)
		local i 
		for i = 1, #self.images do
			if i < num then
				self.images[i].x = -screenW * 0.5;
			elseif i > num then
				self.images[i].x = screenW * 1.5 + pad
			else
				self.images[i].x = screenW * 0.5 - pad
			end
		end
		self.imgNum = num
		self.initImage(self.imgNum)
	end

	function slider:cleanUp()
		self:removeEventListener("touch", self)
	end

	slider:addEventListener("touch", slider)
	return slider

end
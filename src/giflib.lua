

local giflib = {}

export type GifImage = {
	Image: Content,
	Time: number
}

export type Gif = {
	Images: 
	{
		GifImage
	},

	ImageLabel: ImageLabel,
	Frame: number,
	AnimationRunning: boolean,

	StartAnimation: (self: Gif)->any,
	StopAnimation: (self: Gif)->any,
	ResetAnimation: (self: Gif)->any
}

function _StartAnimation(self: Gif)
	task.spawn(function()
		self.AnimationRunning = true
		
		while not self.AnimationRunning do
			self.ImageLabel.ImageContent = self.Images[self.Frame].Image
			self.Frame += 1
			task.wait(self.Images[self.Frame].Time)
		end
	end)
end

function _StopAnimation(self: Gif)
	self.AnimationRunning = false
end

function _ResetAnimation(self: Gif)
	self.Frame = 1
end

function giflib.newGif(imageLabel: ImageLabel, images: {GifImage}): Gif
	
	local self: Gif = {
		ImageLabel = imageLabel,
		Images = images,
		Frame = 1,
		AnimationRunning = false,
		StartAnimation = _StartAnimation,
		StopAnimation = _StopAnimation,
		ResetAnimation = _ResetAnimation
	}

	return self
end


return giflib

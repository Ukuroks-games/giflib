local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local algorithm = require(ReplicatedStorage.Packages.stdlib).algorithm

local giflib = {}

export type GifImage = {
	Image: string,
	Time: number
}

export type Gif = {
	--[[
		Список кадров в гифке
	]]
	Images: 
	{
		GifImage
	},

	ImageLabel: ImageLabel,
	Frame: number,

	--[[
		Анимация сейчас запущенна
	]]
	AnimationRunning: boolean,

	--[[
		Гифка зацикленна
	]]
	LoopAnimation: boolean,

	StartAnimation: (self: Gif)->any,
	StopAnimation: (self: Gif)->any,
	ResetAnimation: (self: Gif)->any,
	Destroy: (self: Gif)->any,

	--[[
		Показывает что анимация завершилась
	]]
	Complited: RBXScriptSignal,
	ComplitedEvent: BindableEvent
}

function _Destroy(self: Gif)
	self.ComplitedEvent:Destroy()
end

function _Preload(self: Gif)
	ContentProvider:PreloadAsync(algorithm.copy_by_prop(self.Images, "Image"))
end

function _StartAnimation(self: Gif)
	task.spawn(function()
		self.AnimationRunning = true
		
		while not self.AnimationRunning do
			self.ImageLabel.Image = self.Images[self.Frame].Image

			if #self.Images == self.Frame then
				break
			else
				self.Frame += 1
			end
			
			task.wait(self.Images[self.Frame].Time)
		end

		self.ComplitedEvent:Fire()
	end)
end

function _StopAnimation(self: Gif)
	self.AnimationRunning = false
end

function _ResetAnimation(self: Gif)
	self.Frame = 1
end

function giflib.newGif(imageLabel: ImageLabel, images: {GifImage}, loopAnimation: boolean?): Gif
	
	local _ComplitedEvent = Instance.new("BindableEvent")

	local self: Gif = {
		ImageLabel = imageLabel,
		Images = images,
		Frame = 1,
		AnimationRunning = false,
		Complited = _ComplitedEvent.Event,
		ComplitedEvent = _ComplitedEvent,
		LoopAnimation = loopAnimation or false,
		Destroy = _Destroy,
		StartAnimation = _StartAnimation,
		StopAnimation = _StopAnimation,
		ResetAnimation = _ResetAnimation,
	}

	self.Complited:Connect(function()
		if self.LoopAnimation then
			self:ResetAnimation()
		else
			self:StopAnimation()
		end
	end)

	return self
end


return giflib

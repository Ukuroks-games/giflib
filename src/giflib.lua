-- Services 

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Libraries

local algorithm = require(ReplicatedStorage.Packages.stdlib).algorithm

local Frame = require(script.Parent.gifFrame)

--[[
	# Library for creating gifs
]]
local giflib = {}

giflib.Frame = Frame


--[[
	Gif struct
]]
export type Gif = {
	--[[
		Список кадров в гифке
	]]
	Frames: 
	{
		Frame.GifFrame
	},

	--[[
		Gif surface
	]]
	ImageLabel: Frame,

	--[[
		Current frame
	]]
	Frame: number,

	--[[
		Анимация сейчас запущенна
	]]
	AnimationRunning: boolean,

	--[[
		Гифка зацикленна.

		if true animation is will be looped.
	]]
	LoopAnimation: boolean,

	--[[
		Images already preloaded
	]]
	IsLoaded: boolean,

	--[[
		Start Gif animation
	]]
	StartAnimation: (self: Gif)->nil,

	--[[
		Stop gif animation
	]]
	StopAnimation: (self: Gif)->nil,

	--[[
		Reset animation.
		if animation runnning now, run gif from first image
	]]
	ResetAnimation: (self: Gif)->nil,

	--[[
		Destroy gif
	]]
	Destroy: (self: Gif)->nil,

	--[[
		Wait all image loading
	]]
	Preload: (self: Gif)->nil,

	--[[
		Add frame to gif
	]]
	AddImage: (self: Gif, image: Frame.GifFrame)->nil,

	--[[
		Set current frame
	]]
	SetFrame: (self: Gif, frame: number)->nil,

	--[[
		Показывает что анимация завершилась
	]]
	Completed: RBXScriptSignal,
	CompletedEvent: BindableEvent,

	--[[
		Fire if gif destroying(Destroy called)
	]]
	Destroying: RBXScriptConnection,
	DestroyingEvent: BindableEvent,

	--[[
		Thread int that gif animation runnging
	]]
	AnimationThread: thread,
}

--[[
	Destroy gif
]]
function giflib.Destroy(self: Gif)
	
	-- Если анимация всё ещё запущенна
	self:StopAnimation()

	self.DestroyingEvent:Fire()

	-- Destroy frames
	for _, v in pairs(self.Frames) do
		if v then
			Frame.Destroy(v)
		end
	end

	self.CompletedEvent:Destroy()
	self.DestroyingEvent:Destroy()

	table.remove(self)
end

--[[
	Wait all image loading
]]
function giflib.Preload(self: Gif)

	ContentProvider:PreloadAsync(algorithm.copy_by_prop(self.Frames, "Image.Image"))

	for _, v in pairs(self.Frames) do
		Frame.WaitLoading(v)
	end

	self.IsLoaded = true
end

function giflib.StartAnimation(self: Gif)

	self.AnimationRunning = true

	if not self.IsLoaded then
		self:Preload()
	end

	self.AnimationThread = task.spawn(function()

		while #self.Frames >= self.Frame do

			giflib.SetFrame(self, self.Frame)

			local t = self.Frames[self.Frame].Time

			if #self.Frames + 1 <= self.Frame then
				break
			else
				self.Frame += 1
			end
			
			task.wait(t)
		end

		self.AnimationRunning = false

		self.CompletedEvent:Fire()
	end)
end

function giflib.StopAnimation(self: Gif)
	if self.AnimationRunning then
		task.cancel(self.AnimationThread)
	end

	self.AnimationRunning = false
end

function giflib.SetFrame(self: Gif, frame: number)
	self.Frame = frame

	Frame.Show(self.Frames[self.Frame], self.ImageLabel)

	if self.Frame > 1 then
		Frame.Hide(self.Frames[self.Frame - 1])
	end
end

--[[
	Reset animation.
	if animation runnning now, run gif from first image
]]
function giflib.ResetAnimation(self: Gif)
	self.Frame = 1
	if not self.AnimationRunning then
		self:StartAnimation()
	end
end

function giflib.AddImage(self: Gif, image: Frame.GifFrame)
	self.IsLoaded = false

	self.Frames[#self.Frames + 1] = image
end

--[[
	Gif constructor

	`Label` - то на чем отображается гифка

	`images` - list of `GifImage`s

	`loopAnimation` - if true animation is will be looped
]]
function giflib.newGif(Label: Frame, images: {Frame.GifFrame}, loopAnimation: boolean?): Gif

	local _ComplitedEvent = Instance.new("BindableEvent")
	local _DestroyingEvent = Instance.new("BindableEvent")

	local self: Gif = {
		ImageLabel = Label,
		Frames = images,
		Frame = 1,
		AnimationRunning = false,
		Completed = _ComplitedEvent.Event,
		CompletedEvent = _ComplitedEvent,
		Destroying = _DestroyingEvent.Event,
		DestroyingEvent = _DestroyingEvent,
		LoopAnimation = loopAnimation or false,
		IsLoaded = false,
		Destroy = giflib.Destroy,
		StartAnimation = giflib.StartAnimation,
		StopAnimation = giflib.StopAnimation,
		ResetAnimation = giflib.ResetAnimation,
		Preload = giflib.Preload,
		AddImage = giflib.AddImage,
		SetFrame = giflib.SetFrame,
		AnimationThread = nil
	}

	for _, v in pairs(self.Frames) do
		v.Image.Parent = Label
	end

	self.Completed:Connect(function()
		if self.LoopAnimation then
			self:ResetAnimation()
		else
			self:StopAnimation()
		end
	end)

	return self
end

return giflib

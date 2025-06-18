-- Services

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Libraries

local algorithm = require(ReplicatedStorage.Packages.stdlib).algorithm

local gifFrame = require(script.Parent.gifFrame)
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
	Frames: { Frame.GifFrame },

	--[[
		Gif surface
	]]
	ImageLabel: Frame,

	--[[
		Current frame num
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
		Images are preloaded
	]]
	IsLoaded: boolean,

	--[[
		Start Gif animation
	]]
	StartAnimation: (self: Gif) -> nil,

	--[[
		Stop gif animation
	]]
	StopAnimation: (self: Gif) -> nil,

	--[[
		Reset animation.
		if animation runnning now, run gif from first image
	]]
	ResetAnimation: (self: Gif) -> nil,

	--[[
		Destroy gif
	]]
	Destroy: (self: Gif) -> nil,

	--[[
		Wait all image loading
	]]
	Preload: (self: Gif) -> nil,

	--[[
		Set current frame, that showing now
	]]
	SetFrame: (self: Gif, frame: number) -> nil,

	--[[
		Next frame
	]]
	Next: (self: Gif) -> nil,

	--[[
	
	]]
	Hide: (self: Gif) -> nil,

	--[[
	
	]]
	SetTransparency: (self: Gif, newTransparency: number) -> nil,

	--[[
	
	]]
	SetBackgroundTransparency: (self: Gif, newTransparency: number) -> nil,

	--[[
	
	]]
	SetBackgroundColor: (self: Gif, newColor: Color3) -> nil,

	--[[
	
	]]
	SetScaleType: (self: Gif, scaleType: Enum.ScaleType) -> nil,

	--[[
		Показывает что анимация завершилась
	]]
	Completed: RBXScriptSignal,

	--[[


	]]
	CompletedEvent: BindableEvent,

	--[[
		Fire if gif destroying(Destroy called)
	]]
	Destroying: RBXScriptConnection,

	--[[
	
	]]
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

	table.clear(self)
end

--[[
	Wait all image loading
]]
function giflib.Preload(self: Gif)
	ContentProvider:PreloadAsync(
		algorithm.copy_by_prop(self.Frames, "Image.Image")
	)

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
		while (#self.Frames > self.Frame) and (#self.Frames ~= 0) do
			self:Next()

			task.wait(self.Frames[self.Frame].Time)
		end

		self.AnimationRunning = false

		self.CompletedEvent:Fire()
	end)
end

function giflib.StopAnimation(self: Gif)
	if self.AnimationRunning and self.AnimationThread then
		task.cancel(self.AnimationThread)
		self.AnimationThread = nil
	end

	self.AnimationRunning = false
end

--[[
	Set current frame, that showing now
]]
function giflib.SetFrame(self: Gif, frame: number)
	Frame.Show(self.Frames[frame], self.ImageLabel)

	if self.Frame ~= 0 then
		Frame.Hide(self.Frames[self.Frame]) -- hide last frame
	end

	self.Frame = frame
end

--[[
	Reset animation.
	if animation runnning now, run gif from first image
]]
function giflib.ResetAnimation(self: Gif)
	self.Frame = 0
	if not self.AnimationRunning then
		self:StartAnimation()
	end
end

--[[
	Next frame
]]
function giflib.Next(self: Gif)
	self:SetFrame(self.Frame + 1)
end

--[[
	Hide gif frames
]]
function giflib.Hide(self: Gif)
	for _, v in pairs(self.Frames) do
		gifFrame.Hide(v)
	end
end

--[[

]]
function giflib.SetBackgroundTransparency(self: Gif, newTransparency: number)
	for _, v in pairs(self.Frames) do
		v.Image.BackgroundTransparency = newTransparency
	end
end

--[[

]]
function giflib.SetBackgroundColor(self: Gif, newColor: Color3)
	for _, v in pairs(self.Frames) do
		v.Image.BackgroundColor3 = newColor
	end
end

--[[

]]
function giflib.SetTransparency(self: Gif, newTransparency: number)
	for _, v in pairs(self.Frames) do
		v.Image.ImageTransparency = newTransparency
	end
end

--[[

]]
function giflib.SetScaleType(self: Gif, scaleType: Enum.ScaleType)
	for _, v in pairs(self.Frames) do
		v.Image.ScaleType = scaleType
	end
end

--[[
	Gif constructor

	`Label` - то на чем отображается гифка

	`images` - list of `GifImage`s

	`loopAnimation` - if true animation is will be looped
]]
function giflib.new(
	Label: Frame,
	images: { Frame.GifFrame },
	loopAnimation: boolean?
): Gif
	local _ComplitedEvent = Instance.new("BindableEvent")
	local _DestroyingEvent = Instance.new("BindableEvent")

	local self: Gif = {
		ImageLabel = Label,
		Frames = images,
		Frame = 0,
		AnimationRunning = false,
		Completed = _ComplitedEvent.Event,
		CompletedEvent = _ComplitedEvent,
		Destroying = _DestroyingEvent.Event,
		DestroyingEvent = _DestroyingEvent,
		LoopAnimation = loopAnimation or false,
		IsLoaded = false,
		AnimationThread = nil,
		Destroy = giflib.Destroy,
		SetTransparency = giflib.SetTransparency,
		SetBackgroundTransparency = giflib.SetBackgroundTransparency,
		SetBackgroundColor = giflib.SetBackgroundColor,
		StartAnimation = giflib.StartAnimation,
		StopAnimation = giflib.StopAnimation,
		ResetAnimation = giflib.ResetAnimation,
		SetScaleType = giflib.SetScaleType,
		Preload = giflib.Preload,
		SetFrame = giflib.SetFrame,
		Next = giflib.Next,
		Hide = giflib.Hide,
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

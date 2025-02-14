local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local algorithm = require(ReplicatedStorage.Packages.stdlib).algorithm

local giflib = {}

export type GifImage = {

	Image: ImageLabel,

	--[[
		delay on this image
	]]
	Time: number
}

--[[
	Gif struct
]]
export type Gif = {
	--[[
		Список кадров в гифке
	]]
	Images: 
	{
		GifImage
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
	StartAnimation: (self: Gif)->any,

	--[[
		Stop gif animation
	]]
	StopAnimation: (self: Gif)->any,

	--[[
		Reset animation.
		if animation runnning now, run gif from first image
	]]
	ResetAnimation: (self: Gif)->any,

	--[[
		Destroy gif
	]]
	Destroy: (self: Gif)->nil,
	--[[
		Preload all images
	]]
	Preload: (self: Gif)->nil,

	--[[
		Add image
	]]
	AddImage: (self: Gif, image: GifImage)->nil,

	--[[
		Показывает что анимация завершилась
	]]
	Completed: RBXScriptSignal,
	CompletedEvent: BindableEvent,

	Destroying: RBXScriptConnection,
	DestroyingEvent: BindableEvent,

	AnimationThread: thread
}

function giflib.Destroy(self: Gif)
	
	-- Если анимация всё ещё запущенна
	if self.AnimationRunning then
		task.cancel(self.AnimationThread)
	end

	self.DestroyingEvent:Fire()

	for _, v in pairs(self.Images) do
		if v then
			v.Image:Destroy()
		end
	end

	table.clear(self)
end

function giflib.Preload(self: Gif)
	ContentProvider:PreloadAsync(algorithm.copy_by_prop(self.Images, "Image"))
	self.IsLoaded = true
end

function giflib.StartAnimation(self: Gif)

	if not self.IsLoaded then
		self:Preload()
	end

	self.AnimationRunning = true

	self.AnimationThread = task.spawn(function()
		while self.AnimationRunning and #self.Images >= self.Frame do
			local GifImage = self.Images[self.Frame]

			GifImage.Image.Visible = true

			if #self.Images + 1 <= self.Frame then
				break
			else
				self.Frame += 1
			end
			
			task.wait(GifImage.Time)
			GifImage.Image.Visible = false
		end

		self.AnimationRunning = false

		self.CompletedEvent:Fire()
	end)
end

function giflib.StopAnimation(self: Gif)
	self.AnimationRunning = false
end

function giflib.ResetAnimation(self: Gif)
	self.Frame = 1
	if not self.AnimationRunning then
		self:StartAnimation()
	end
end

function giflib.AddImage(self: Gif, image: GifImage)
	self.IsLoaded = false

	self.Images[#self.Images + 1] = image
end

--[[
	Gif constructor

	`Label` - то на чем отображается гифка

	`images` - list of `GifImage`s

	`loopAnimation` - if true animation is will be looped
]]
function giflib.newGif(Label: Frame, images: {GifImage}, loopAnimation: boolean?): Gif

	local _ComplitedEvent = Instance.new("BindableEvent")
	local _DestroyingEvent = Instance.new("BindableEvent")

	local self: Gif = {
		ImageLabel = Label,
		Images = images,
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
		AnimationThread = nil,
		__len = function(self: Gif)
			return #self.Images
		end
	}

	for _, v in pairs(self.Images) do
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

--[[
	Gif image constructor

	you can do not use funct fror creating `GifImage`
]]
function giflib.newImage(id: string, t: number): GifImage
	local function AddProtocolIfINeeded(): string
		if not id:find("http://www.roblox.com/asset/?id=") then
			id = "http://www.roblox.com/asset/?id=" .. id
		end

		return id
	end

	local img: GifImage = {
		Image = Instance.new("ImageLabel"),
		Time = t
	}

	img.Image.Image = AddProtocolIfINeeded()
	img.Image.Size = UDim2.fromScale(1, 1)

	return img
end


return giflib

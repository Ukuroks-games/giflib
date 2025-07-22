-- Services

local ContentProvider = game:GetService("ContentProvider")

-- Libraries

local algorithm = require(script.Parent.Parent.stdlib).algorithm

local gifFrame = require(script.Parent.gifFrame)

--[[
	# Library for creating gifs
]]
local gif = {}

gif.Mode = {
	Replace = 0,
	Combine = 1,
}

--[[
	Gif struct
]]
export type GifStruct = {
	--[[
		Список кадров в гифке
	]]
	Frames: { gifFrame.GifFrame },

	--[[
		Gif surface
	]]
	Parent: Frame?,

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
		Показывает что анимация завершилась
	]]
	Completed: RBXScriptSignal,

	--[[
		Fire where gif animation completed
	]]
	CompletedEvent: BindableEvent,

	--[[
		Fire if gif destroying(Destroy called)
	]]
	Destroying: RBXScriptConnection,

	--[[
		Fire where Destroy call
	]]
	DestroyingEvent: BindableEvent,

	--[[
		Thread int that gif animation running
	]]
	AnimationThread: thread,

	--[[
		Gif mode. See gif.Mode
	]]
	Mode: number,
}

--[[
	Gif type
]]
export type Gif = GifStruct & typeof(gif)

--[[
	Destroy gif
]]
function gif.Destroy(self: GifStruct, notDestroyFrames: boolean?)
	self.DestroyingEvent:Fire()

	-- Если анимация всё ещё запущенна
	gif.StopAnimation(self)

	if not notDestroyFrames then
		-- Destroy frames
		for _, v in pairs(self.Frames) do
			if v then
				gifFrame.Destroy(v)
			end
		end
	end

	self.CompletedEvent:Destroy()
	self.DestroyingEvent:Destroy()

	table.clear(self)
end

--[[
	Wait all image loading
]]
function gif.Preload(self: GifStruct, noWaitLoad: boolean?)
	ContentProvider:PreloadAsync(
		algorithm.copy_by_prop(self.Frames, "Image.Image")
	)

	if noWaitLoad ~= true then
		for _, v in pairs(self.Frames) do
			gifFrame.WaitLoading(v)
		end
	end

	self.IsLoaded = true
end

--[[
	Start gif animation
]]
function gif.StartAnimation(self: GifStruct, noWaitLoad: boolean?)
	if self.AnimationRunning ~= true then
		self.AnimationRunning = true

		if not self.IsLoaded then -- preload gif if it not been preloaded before
			gif.Preload(self, noWaitLoad)
		end

		self.AnimationThread = task.spawn(function()
			while
				(#self.Frames > self.Frame)
				and (#self.Frames ~= 0)
				and (self.AnimationRunning == true)
			do
				local time = os.clock()

				gif.Next(self)

				local t = self.Frames[self.Frame].Time - (os.clock() - time)

				if t > 0 then
					task.wait(t)
				end
			end

			self.AnimationRunning = false

			self.CompletedEvent:Fire()
		end)
	else
		warn("Animation already running")
	end
end

--[[
	Stop gif animation
]]
function gif.StopAnimation(self: GifStruct)
	if self.AnimationRunning and self.AnimationThread then
		task.cancel(self.AnimationThread)
		self.AnimationThread = nil
	else
		warn("Animation", self, "not been started yet")
	end

	self.AnimationRunning = false
end

--[[
	Set current frame, that showing now
]]
function gif.SetFrame(self: GifStruct, frame: number)
	if self.Parent then
		gifFrame.Show(self.Frames[frame], self.Parent)

		if self.Frame ~= 0 and self.Mode == gif.Mode.Replace then
			gifFrame.Hide(self.Frames[self.Frame]) -- hide last frame
		end
	end

	self.Frame = frame
end

--[[
	Reset animation.
]]
function gif.ResetAnimation(self: GifStruct)
	self.Frame = 0

	if self.Mode == gif.Mode.Combine then
		gif.Hide(self)
	end
end

--[[
	Restart animation
]]
function gif.RestartAnimation(self: GifStruct)
	gif.ResetAnimation(self)
	gif.StartAnimation(self)
end

--[[
	Next frame
]]
function gif.Next(self: GifStruct)
	gif.SetFrame(self, self.Frame + 1)
end

--[[
	Hide gif frames
]]
function gif.Hide(self: GifStruct)
	for _, v in pairs(self.Frames) do
		gifFrame.Hide(v)
	end
end

--[[
	Set frames background transparency
]]
function gif.SetBackgroundTransparency(self: GifStruct, newTransparency: number)
	if self.Mode == gif.Mode.Combine then
		self.Frames[1].Image.BackgroundTransparency = newTransparency
	else
		for _, v in pairs(self.Frames) do
			v.Image.BackgroundTransparency = newTransparency
		end
	end
end

--[[
	Set frames background color
]]
function gif.SetBackgroundColor(self: GifStruct, newColor: Color3)
	for _, v in pairs(self.Frames) do
		v.Image.BackgroundColor3 = newColor
	end
end

--[[
	Set images transparency

	not working normally with combine mode
]]
function gif.SetTransparency(self: GifStruct, newTransparency: number)
	for _, v in pairs(self.Frames) do
		v.Image.ImageTransparency = newTransparency
	end
end

--[[
	Set scale type
]]
function gif.SetScaleType(self: GifStruct, scaleType: Enum.ScaleType)
	for _, v in pairs(self.Frames) do
		v.Image.ScaleType = scaleType
	end
end

--[[
	Set resample mode
]]
function gif.SetResampleMode(self: GifStruct, resampleMode: Enum.ResamplerMode)
	for _, v in pairs(self.Frames) do
		v.Image.ResampleMode = resampleMode
	end
end

--[[
	Set gif parent
]]
function gif.SetParent(self: GifStruct, newParent: Frame?)
	self.Parent = newParent
	self.Frames[self.Frame].Image.Parent = newParent
end

--[[
	Get total animation time
]]
function gif.GetTotalAnimationTime(self: GifStruct): number
	return algorithm.accumulate_by_prop(self.Frames, "Time")
end

--[[
	Add frame
]]
function gif.AddFrame(self: GifStruct, frame: gifFrame.GifFrame)
	self.IsLoaded = self.IsLoaded and frame.Image.IsLoaded
	table.insert(self.Frames, frame)
end

--[[
	Gif constructor

	`images` - list of `GifFrame`s

	`Label` - то на чем отображается гифка

	`loopAnimation` - if true animation is will be looped

	`ShowFirstFrameBeforeLoading` - Show the first frame before animation start
]]
function gif.new(
	frames: { [number]: gifFrame.GifFrame }?,
	parent: Frame?,
	loopAnimation: boolean?,
	ShowFirstFrameBeforeStart: boolean?,
	mode: number?
): Gif
	local _CompletedEvent = Instance.new("BindableEvent")
	local _DestroyingEvent = Instance.new("BindableEvent")

	local self: GifStruct = {
		Parent = parent,
		Frames = frames or {},
		Frame = 0,
		AnimationRunning = false,
		Completed = _CompletedEvent.Event,
		CompletedEvent = _CompletedEvent,
		Destroying = _DestroyingEvent.Event,
		DestroyingEvent = _DestroyingEvent,
		LoopAnimation = loopAnimation or false,
		IsLoaded = false,
		AnimationThread = nil,
		Mode = mode or gif.Mode.Replace,
	}

	gif.Hide(self)

	if ShowFirstFrameBeforeStart == true then
		if parent ~= nil then
			gif.Next(self)
		else
			warn("gif parent is nil. So how show first frame?")
		end
	end

	if mode == gif.Mode.Combine then
		for i = 2, #self.Frames do
			self.Frames[i].Image.BackgroundTransparency = 1
		end
	end

	self.Completed:Connect(function()
		if self.LoopAnimation then
			gif.RestartAnimation(self)
		else
			gif.StopAnimation(self)
		end
	end)

	setmetatable(self, { __index = gif })

	return self
end

return gif

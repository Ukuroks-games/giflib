--!strict

-- Services

local ContentProvider = game:GetService("ContentProvider")

-- Libraries

local algorithm = require(script.Parent.Parent.stdlib).algorithm

local gifFrame = require(script.Parent.gifFrame)

--[=[
	@class gif

	@client
]=]
local gif = {}

--[=[
	Enum of gif modes

	@prop Mode { Replace: 1, Combine: 2 }

	@within gif
	@tag enum
]=]
gif.Mode = {
	--[[
		Next frame replace last frame
	]]
	Replace = 0,

	--[[
		The next layer is superimposed on the previous one
	]]
	Combine = 1,
}

export type GifStruct = {
	--[[
		List of gif frames
	]]
	Frames: { gifFrame.GifFrame },

	--[[
		Gif surface
	]]
	Parent: GuiObject?,

	--[[
		Current frame num
	]]
	Frame: number,

	--[[
		Анимация сейчас запущенна
	]]
	AnimationRunning: boolean,

	--[[
		Gif is looped

		if `true` animation is will be looped.
	]]
	LoopAnimation: boolean,

	--[[
		Images are preloaded
	]]
	IsLoaded: boolean,

	--[[
		Fire where gif animation completed
	]]
	Completed: RBXScriptSignal<>,

	--[[
		Fire where gif animation completed
	]]
	CompletedEvent: BindableEvent,

	--[[
		Fire if gif destroying(Destroy called)
	]]
	Destroying: RBXScriptSignal<>,

	--[[
		Fire where Destroy call
	]]
	DestroyingEvent: BindableEvent,

	--[[
		Thread int that gif animation running
	]]
	AnimationThread: thread?,

	--[[
		Gif mode. See gif.Mode
	]]
	Mode: number,

	--[[
		animation speed
	]]
	Speed: number,
}

--[=[
	@interface Gif

	@field Frames { gifFrame }
	@field Parent Frame?
	@field Frame number
	@field AnimationRunning boolean
	@field LoopAnimation boolean
	@field IsLoaded boolean
	@field Completed RBXScriptConnection
	@field Destroying RBXScriptConnection
	@field AnimationThread thread
	@field Mode Mode

	@within gif
]=]
export type Gif = typeof(setmetatable({} :: GifStruct, { __index = gif }))


--[=[
	Destroy gif
	
	@param self GifStruct  -- 
	@param notDestroyFrames boolean -- if you need to not destroy frames

	@method Destroy

	@within gif
]=]
function gif.Destroy(self: Gif, notDestroyFrames: boolean?)
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
end

--[=[
	Wait all image loading

	You should always preload gif before start it, otherwise you can notice the passes of personnel and flickering

	@param self gif
	@param skip number?|boolean	-- skip preload. max delay in sec or boolean

	@method Preload

	@within gif

	@yields
]=]
function gif.Preload(self: Gif, skip: number? | boolean?)
	ContentProvider:PreloadAsync(
		algorithm.copy_by_prop(self.Frames :: gifFrame.GifFrameStruct, "Image")
	)

	if
		(typeof(skip) == "boolean" and skip ~= true)
		or (typeof(skip) == "number")
	then
		local delay = (function()
			if typeof(skip) == "number" then
				return skip
			else
				return 5
			end
		end)() / #self.Frames

		for _, v in pairs(self.Frames) do
			gifFrame.WaitLoading(v, delay)
		end
	end

	self.IsLoaded = true
end

--[=[
	Main animation loop

	@param self gif

	@method AnimationLoop
	@within gif
]=]
function gif.AnimationLoop(self: Gif)
	while
		(#self.Frames > self.Frame)
		and (#self.Frames ~= 0)
		and (self.AnimationRunning == true)
	do
		local time = os.clock()

		gif.Next(self)

		local t = (self.Frames[self.Frame].Time / self.Speed)
			- (os.clock() - time)

		if t > 0 then
			task.wait(t)
		end
	end

	self.AnimationRunning = false

	self.CompletedEvent:Fire()
end

--[=[
	Start gif animation. 

	If gif not been preloaded yet thins function will run [`gif:Preload`](#Preload) (you can skip that if you set arg noWaitPreload to true).

	@param self gif
	@param skip number?|boolean	-- skip preload. max delay in sec or boolean

	@method StartAnimation

	@within gif
]=]
function gif.StartAnimation(self: Gif, skip: number? | boolean?)
	if self.AnimationRunning ~= true then
		self.AnimationRunning = true

		if not self.IsLoaded then -- preload gif if it not been preloaded before
			gif.Preload(self, skip)
		end

		self.AnimationThread = task.spawn(gif.AnimationLoop, self)
	else
		warn("Animation already running")
	end
end

--[=[
	Stop gif animation

	@param self gif

	@method StopAnimation

	@within gif
]=]
function gif.StopAnimation(self: Gif)
	if (self.AnimationRunning == true) and self.AnimationThread then

		task.cancel(self.AnimationThread)
		self.AnimationThread = nil
	elseif self.AnimationRunning == true then
		warn("StartAnimation not been done")
	else
		warn("Animation", self, "not been started yet")
	end

	self.AnimationRunning = false
end

--[=[
	Set current frame, that showing now

	@param self gif
	@param frame number -- index of frame

	@method SetFrame

	@within gif
]=]
function gif.SetFrame(self: Gif, frame: number)
	if self.Parent and self.Frames[frame] then
		gifFrame.Show(self.Frames[frame], self.Parent)

		if self.Frame ~= 0 and self.Mode == gif.Mode.Replace then
			gifFrame.Hide(self.Frames[self.Frame]) -- hide last frame
		end
	else
		warn("Parent or self.Frames[" .. frame .. "] not exist")
	end

	self.Frame = frame
end

--[=[
	Reset animation. 
	
	Don't stopping animation

	@param self gif

	@method ResetAnimation

	@within gif
]=]
function gif.ResetAnimation(self: Gif)
	self.Frame = 0

	if self.Mode == gif.Mode.Combine then
		gif.Hide(self)
	end
end

--[=[
	Restart animation

	@param self gif
	@param skip number?|boolean	-- skip preload. max delay in sec or boolean

	@method RestartAnimation

	@within gif


	@since v0.3.2
]=]
function gif.RestartAnimation(self: Gif, skip: number? | boolean?)

	gif.ResetAnimation(self)
	gif.StartAnimation(self, skip)
end

--[=[
	Next frame

	@param self gif

	@method Next

	@within gif
]=]
function gif.Next(self: Gif)
	gif.SetFrame(self, self.Frame + 1)
end

--[=[
	Hide gif frames

	@param self gif

	@method Hide

	@within gif

	@since v0.1.8
]=]
function gif.Hide(self: Gif)

	for _, v in pairs(self.Frames) do
		gifFrame.Hide(v)
	end
end

--[=[
	Set frames background transparency

	@param self gif
	@param newTransparency number

	@method SetBackgroundTransparency
	@within gif


	@since v0.1.8
]=]
function gif.SetBackgroundTransparency(self: Gif, newTransparency: number)

	if self.Mode == gif.Mode.Combine then
		self.Frames[1].Image.BackgroundTransparency = newTransparency
	elseif self.Mode == gif.Mode.Replace then
		for _, v in pairs(self.Frames) do
			v.Image.BackgroundTransparency = newTransparency
		end
	else
		warn("unknown mode" .. tostring(self.Mode))
	end
end

--[=[
	Set frames background color

	@param self gif
	@param newColor Color3

	@method SetBackgroundColor
	@within gif

	@since v0.1.8
]=]
function gif.SetBackgroundColor(self: Gif, newColor: Color3)
	for _, v in pairs(self.Frames) do
		v.Image.BackgroundColor3 = newColor
	end
end

--[=[
	Set images transparency

	not working normally with combine mode

	@param self gif
	@param newTransparency number

	@method SetTransparency
	@within gif

	@since v0.1.8
]=]
function gif.SetTransparency(self: Gif, newTransparency: number)
	for _, v in pairs(self.Frames) do
		v.Image.ImageTransparency = newTransparency
	end
end

--[=[
	Set scale type

	@param self gif
	@param scaleType ScaleType

	@method SetScaleType
	@within gif


	@since v0.1.8
]=]
function gif.SetScaleType(self: Gif, scaleType: Enum.ScaleType)
	for _, v in pairs(self.Frames) do
		v.Image.ScaleType = scaleType
	end
end

--[=[
	Set resample mode

	@param self gif
	@param resampleMode ResamplerMode

	@method SetResampleMode

	@within gif
]=]
function gif.SetResampleMode(self: Gif, resampleMode: Enum.ResamplerMode)

	for _, v in pairs(self.Frames) do
		v.Image.ResampleMode = resampleMode
	end
end

--[=[
	Set gif parent

	@param self gif
	@param newParent Frame?

	@method SetParent
	@within gif
]=]
function gif.SetParent(self: Gif, newParent: Frame?)

	self.Parent = newParent
	self.Frames[self.Frame].Image.Parent = newParent
end

--[=[
	Get total animation time

	@method GetTotalAnimationTime

	@within gif


	@since v0.3.1
]=]
function gif.GetTotalAnimationTime(self: Gif): number
	return algorithm.accumulate_by_prop(
		self.Frames :: gifFrame.GifFrameStruct,
		"Time"
	)
end

--[=[
	Add new frame 

	@param self gif
	@param frame gifFrame

	@method AddFrame
	@within gif

	@since v0.3.1
]=]
function gif.AddFrame(self: Gif, frame: gifFrame.GifFrame)
	self.IsLoaded = self.IsLoaded and frame.Image.IsLoaded
	table.insert(self.Frames, frame)
end

--[=[
	Gif constructor

	@function new
	
	@param frames	{ [number]: GifFrame }?	-- list of frames
	@param parent	{ Frame }?  -- gif surface. Parent for all frames
	@param loopAnimation boolean? -- animation is looped 
	@param ShowFirstFrameBeforeStart boolean?	-- is true first frame will showing before gif.StartAnimation call.
	@param mode number?

	@return Gif

	@within gif
]=]
function gif.new(
	frames: { [number]: gifFrame.GifFrame }?,
	parent: Frame?,
	loopAnimation: boolean?,
	ShowFirstFrameBeforeStart: boolean?,
	mode: number?,
	speed: number?
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
		Speed = speed or 1,
	}

	setmetatable(self, { __index = gif })

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

	return self
end

return gif

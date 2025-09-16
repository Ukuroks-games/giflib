--!strict

-- Services

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")

-- Libraries

local stdlib = require(script.Parent.Parent.stdlib)

--[=[
	Gif frame class

	@class gifFrame

	@client
]=]
local gifFrame = {}

--[[
	Gui for preloading a images
]]
local Gui = stdlib.utility.CreateOrFindInstance(
	"GifPreloadGui",
	"ScreenGui",
	Players.LocalPlayer.PlayerGui
) :: ScreenGui

Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true

--[[
	@type GifFrameStruct 

	@within gifFrame
]]
export type GifFrameStruct = {

	--[=[
		Label with image
	]=]
	Image: ImageLabel,

	--[=[
		delay on this image
	]=]
	Time: number,
}

export type GifFrame = typeof(setmetatable(
	{} :: GifFrameStruct,
	{ __index = gifFrame }
))

--[=[
	Preload frame

	@param self gifFrame

	@method Preload

	@within gifFrame
	@yields
]=]
function gifFrame.Preload(self: GifFrame)
	ContentProvider:PreloadAsync({ self.Image })
end

--[=[
	Wait image loading

	@param skipDelay number?

	@method WaitLoading
	@within gifFrame

	@yields
]=]
function gifFrame.WaitLoading(self: GifFrame, skipDelay: number?)
	local t = os.clock()

	while not self.Image.IsLoaded do
		task.wait()

		if (os.clock() - t) > (skipDelay or 10) then
			warn("Loading may be so long...")
			break
		end
	end
end

--[=[
	Destroy gif frame

	@method Destroy
	@within gifFrame
]=]
function gifFrame.Destroy(self: GifFrame)
	self.Image:Destroy()
end

--[=[
	Show frame.

	@param parent Frame -- is Gif.ImageLabel

	@method Show
	@within gifFrame
]=]
function gifFrame.Show(self: GifFrame, parent: GuiBase)
	self.Image.Visible = true
	self.Image.Size = UDim2.fromScale(1,1)
	self.Image.Parent = parent
end

--[=[
	Hide frame. Keep image in memory

	
	@method Hide
	@within gifFrame
]=]
function gifFrame.Hide(self: GifFrame)
	self.Image.Size = UDim2.new()
	self.Image.Parent = Gui
end

--[=[
	don't keep image in memory

	@method Free
	@within gifFrame

	@since v0.4.0
]=]
function gifFrame.Free(self: GifFrame)
	self.Image.Visible = false
end

--[[
	Set up self struct for it become `GifFrame`
]]
local function SetUpSelf(self: GifFrameStruct): GifFrame
	setmetatable(self, { __index = gifFrame })

	self.Image.Size = UDim2.fromScale(1, 1)
	self.Image.Position = UDim2.new()

	return self
end

--[=[
	Set frame time
]=]
function gifFrame.SetTime(self: GifFrame, t: number)
	self.Image:SetAttribute("Time", self.Time)
	self.Time = t
end

--[=[
	Create frame from exist image.

	@function FromInstance

	@param image ImageLabel -- image label with attribute "Time" and type number
	@return gifFrame

	@within gifFrame

	@since v0.4.0
]=]
function gifFrame.FromInstance(image: ImageLabel): GifFrame
	local self: GifFrameStruct = {
		Image = image,
		Time = (image:GetAttribute("Time") :: number) or 0,
	}

	return SetUpSelf(self)
end

--[=[
	Gif frame constructor

	@function new

	@param id string -- asset id of frame
	@param t number -- frame time

	@return gifFrame

	@within gifFrame
]=]
function gifFrame.new(id: string, t: number): GifFrame
	if
		(not id:find("http://www.roblox.com/asset/?id="))
		or (not id:find("rbxassetid://"))
	then
		id = "rbxassetid://" .. id
	end

	local self: GifFrameStruct = {
		Image = Instance.new("ImageLabel"),
		Time = t,
	}

	self.Image.Image = id

	return SetUpSelf(self)
end

return gifFrame

-- Services

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")

--[[
	Gif frame class
]]
local gifFrame = {}

local function CreateGui(name: string): Instance
	local a = Players.LocalPlayer.PlayerGui:FindFirstChild(name)

	if not a then
		a = Instance.new("ScreenGui")
		a.Parent = Players.LocalPlayer.PlayerGui
		a.Name = name
	end

	return a
end

--[[
	Gui for preloading a images
]]
local Gui = CreateGui("GifPreloadGui")

--[[
	gifFrame struct
]]
export type GifFrameStruct = {

	--[[
		Label with image
	]]
	Image: ImageLabel,

	--[[
		delay on this image
	]]
	Time: number,
}

export type GifFrame = GifFrameStruct & typeof(gifFrame)

--[[
	Preload frame
]]
function gifFrame.Preload(self: GifFrame)
	ContentProvider:PreloadAsync(self.Image.Image)
end

--[[
	Wait image loading
]]
function gifFrame.WaitLoading(self: GifFrame, skipDelay: number?)
	local t = os.clock()
	while not self.Image.IsLoaded do
		task.wait()
		if  (os.clock() - t) > (skipDelay or 10) then
			warn("Loading may be so long...")
			break
		end
	end
end

--[[
	Destroy gif frame
]]
function gifFrame.Destroy(self: GifFrame)
	self.Image:Destroy()
end

--[[
	Show frame.

	`parent` is Gif.ImageLabel
]]
function gifFrame.Show(self: GifFrame, parent: Frame)
	self.Image.Position = UDim2.fromScale(0, 0)
	self.Image.Parent = parent
end

--[[
	Hide frame
]]
function gifFrame.Hide(self: GifFrame)
	self.Image.Position = UDim2.fromScale(1, 1)
	self.Image.Parent = Gui
end

--[[
	Gif frame constructor
]]
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

	setmetatable(self, { __index = gifFrame })

	self.Image.Image = id
	self.Image.Size = UDim2.fromScale(1, 1)
	self.Image.Position = UDim2.fromScale(1, 1)

	return self
end

return gifFrame

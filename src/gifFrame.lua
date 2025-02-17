local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")

--[[
	Gif frame class
]]
local gifFrame = {}

local function CreateGui(name: string)
	local a = Players.LocalPlayer.PlayerGui:FindFirstChild(name)

	if not a then
		a = Instance.new("ScreenGui",  Players.LocalPlayer.PlayerGui)
		a.Name = name
	end

	return a 
end

local Gui = CreateGui("GifPreloadGui")

--[[
	gifFrame struct
]]
export type GifFrame = {

	--[[
		Label with image
	]]
	Image: ImageLabel,

	--[[
		delay on this image
	]]
	Time: number,
}

--[[
	Preload frame
]]
function gifFrame.Preload(self: GifFrame)
	ContentProvider:PreloadAsync(self.Image.Image)
end

--[[
	Wait image loading
]]
function gifFrame.WaitLoading(self: GifFrame)
	while not self.Image.IsLoaded do
		task.wait()
	end
end

--[[
	Destroy gif frame
]]
function gifFrame.Destroy(self: GifFrame)
	self.Image:Destroy()
end

function gifFrame.Show(self: GifFrame, parent: Frame)
	self.Image.Position = UDim2.fromScale(0, 0)
	self.Image.Parent = parent
end

function gifFrame.Hide(self: GifFrame)
	self.Image.Position = UDim2.fromScale(1, 1)
	self.Image.Parent = Gui
end

--[[
	Gif frame constructor
]]
function gifFrame.new(id: string, t: number): GifFrame
	
	if (not id:find("http://www.roblox.com/asset/?id=")) or (not id:find("rbxassetid://")) then
		id = "rbxassetid://" .. id
	end

	local img: GifFrame = {
		Image = Instance.new("ImageLabel"),
		Time = t
	}

	img.Image.Image = id
	img.Image.Size = UDim2.fromScale(1, 1)
	img.Image.Position = UDim2.fromScale(1, 1)

	return img
end

return gifFrame

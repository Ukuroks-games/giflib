local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)

local imageLabel3 = Instance.new("Frame")

imageLabel3.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
imageLabel3.Size = UDim2.fromScale(0.5, 0.5)
imageLabel3.Position = UDim2.fromScale(0.5, 0.5)

local combinedGif = giflib.gif.new({
	giflib.Frame.new("115357019166297", 0.2), -- 1
	giflib.Frame.new("131955103378417", 0.2), -- 2
}, imageLabel3, true, false, giflib.gif.Mode.Replace)

combinedGif:StartAnimation()

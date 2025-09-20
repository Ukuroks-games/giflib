--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)

local imageLabel3 = Instance.new("Frame")

imageLabel3.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
imageLabel3.Size = UDim2.fromScale(0.5, 0.5)
imageLabel3.Position = UDim2.fromScale(0.5, 0.5)

local gif = giflib.gif.new()

gif.LoopAnimation = true
gif:SetResampleMode(Enum.ResamplerMode.Pixelated)

for _, v in pairs({
	giflib.Frame.new("115357019166297", 0.2), -- 1
	giflib.Frame.new("131955103378417", 0.2), -- 2
}) do
	gif:AddFrame(v)
end

gif:SetParent(imageLabel3)



gif:StartAnimation()

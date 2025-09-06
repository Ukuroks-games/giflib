local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)

local imageLabel = Instance.new("Frame")

imageLabel.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
imageLabel.Size = UDim2.fromScale(1, 0.5)

local myGif = giflib.gif.new(
	{
		giflib.Frame.new("85510906103514", 0.08),
		giflib.Frame.new("108084812514916", 0.08),
		giflib.Frame.new("110413056991989", 0.08),
		giflib.Frame.new("138519472508007", 0.08),
		giflib.Frame.new("76126708840626", 0.08),
		giflib.Frame.new("105799496264978", 0.08),
		giflib.Frame.new("126677371037972", 0.08),
		giflib.Frame.new("110695448399045", 0.08),
		giflib.Frame.new("88405074787964", 0.08),
		giflib.Frame.new("82234753210135", 0.08),
		giflib.Frame.new("126380322008457", 0.08),
		giflib.Frame.new("73999504428848", 1),
	},
	imageLabel,
	true, -- animation is looped
	true -- show first frame before animation loaded
)

print("Total myGif animation time", myGif:GetTotalAnimationTime(), "sec")

myGif:SetResampleMode(Enum.ResamplerMode.Pixelated)
myGif:SetScaleType(Enum.ScaleType.Fit)
myGif:SetBackgroundTransparency(1)

print("Start")
myGif:StartAnimation(true) -- without wait loading

wait(10)
print("Stop Animation")
myGif:StopAnimation()

wait(10)
print("Start")
myGif:StartAnimation()

wait(10)
print("Set to Pixelated")
myGif:SetResampleMode(Enum.ResamplerMode.Pixelated)

wait(10)
print("Set fit scale type")
myGif:SetScaleType(Enum.ScaleType.Fit)

wait(10)
print("Speed x4")
myGif.Speed = 4

wait(10)
print("Speed x0.25")
myGif.Speed = 0.25

wait(10)
print("Free")
myGif:Free()

wait(10)
print("Destroy")
myGif:Destroy()

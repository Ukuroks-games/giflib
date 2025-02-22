local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.shared.giflib)

local imageLabel = Instance.new("Frame")

imageLabel.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
imageLabel.Size = UDim2.fromScale(1, 1)

local mygif = giflib.new(
	imageLabel,
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
		giflib.Frame.new("73999504428848", 1)
	},
	true	-- animation is looped
)

mygif:StartAnimation()




wait(10)
print("Stop Animation")
mygif:StopAnimation()

wait(10)
print("Start")
mygif:StartAnimation() -- continue 




wait(10)
print("Destroy")
mygif:Destroy()

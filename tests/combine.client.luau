local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.Packages.giflib)

local imageLabel2 = Instance.new("Frame")

imageLabel2.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
imageLabel2.Size = UDim2.fromScale(0.5, 0.5)
imageLabel2.Position = UDim2.fromScale(0, 0.5)

local combinedGif = giflib.gif.new({
	giflib.Frame.new("131246783435400", 0.08),
	giflib.Frame.new("80753483621287", 0.08),
	giflib.Frame.new("111147313189929", 0.08),
	giflib.Frame.new("113736881417874", 0.08),
	giflib.Frame.new("70452691249678", 0.08),
	giflib.Frame.new("112602630115355", 0.08),
	giflib.Frame.new("83589523571661", 0.08),
	giflib.Frame.new("98042924299709", 0.08),
	giflib.Frame.new("108932971886316", 0.08),
	giflib.Frame.new("103346718798014", 0.08),
	giflib.Frame.new("137078778236103", 0.08),
	giflib.Frame.new("109159162380484", 0.08),
	giflib.Frame.new("112629508782429", 0.08),
	giflib.Frame.new("120789943937396", 0.08),
	giflib.Frame.new("93591224665111", 0.08),
	giflib.Frame.new("81897548584627", 0.08),
	giflib.Frame.new("87896583764508", 0.08),
	giflib.Frame.new("118755832546495", 0.08),
}, imageLabel2, true, false, giflib.gif.Mode.Combine)

combinedGif:StartAnimation()

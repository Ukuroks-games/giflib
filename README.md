# Giflib

library for creating gifs

## Example

```
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.shared.giflib)

local imageLabel = Instance.new("ImageLabel")

imageLabel.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
imageLabel.Size = UDim2.fromScale(1, 1)

local mygif = giflib.newGif(
	imageLabel,
	{
		giflib.newImage("85510906103514", 0.08),
		giflib.newImage("108084812514916", 0.08),
		giflib.newImage("110413056991989", 0.08),
		giflib.newImage("138519472508007", 0.08),
		giflib.newImage("76126708840626", 0.08),
		giflib.newImage("105799496264978", 0.08),
		giflib.newImage("126677371037972", 0.08),
		giflib.newImage("110695448399045", 0.08),
		giflib.newImage("88405074787964", 0.08),
		giflib.newImage("82234753210135", 0.08),
		giflib.newImage("126380322008457", 0.08),
		giflib.newImage("73999504428848", 1)
	},
	true
)

mygif:StartAnimation()
```

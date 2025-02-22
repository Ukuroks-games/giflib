# Giflib

Small library for creating gifs in roblox



## Functions

`new` - gif constructor.

`StartAnimation` - start gif animation

`StopAnimation` - stopping animation

`ResetAnimation` - Reset animation.

`Preload` - Preload images.

`AddImage` - Adding image existing gif

## Events

`Completed` - Fire on animation is ended. If animation is looped fires on every restarting

`Destroying` - Fire on destroying gif

## Example

```
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.shared.giflib)

local imageLabel = Instance.new("ImageLabel")

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
	true
)

mygif:StartAnimation()



wait(10)
mygif:StopAnimation()

wait(10)
mygif:StartAnimation() -- continue 



wait(10)

mygif:Destroy()

```

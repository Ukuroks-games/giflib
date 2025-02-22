# Giflib

Small library for creating gifs in roblox




## Functions

### Gif functions

`new(Label: Frame, images: { Frame.GifFrame }, loopAnimation: boolean?): Gif` - gif constructor.

`StartAnimation(self: Gif)` - start gif animation

`StopAnimation(self: Gif)` - stop animation

`ResetAnimation(self: Gif)` - Reset animation.

`Preload(self: Gif)` - Preload images. Waiting while images not loading

`SetFrame(self: Gif, frame: number)` - set current frame

`Next(self: Gif)` - Next frame

`Destroy(self: Gif)` - Destroy gif. Destroying table, events and frames. Fire Destroying event

### Frame functions

Gif frame struct not contain this methods,but  you can call them as `giflib.Frame.<method>(Frame, ...)`. Why? I think it's waste of memory.

`new(id: string, t: number): GifFrame` - Frame constructor

`Show(self: GifFrame, parent: Frame)` - Show frame. `parent` is Gif.ImageLabel

`WaitLoading(self: GifFrame)` - Wait while frame is loading

`Hide(self: GifFrame)`- Hide gif frame

`Destroy(self: GifFrame)` - Destroy gif frame

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

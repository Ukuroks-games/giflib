local gif = require(script.gif)
local gifFrame = require(script.gifFrame)

export type Gif = gif.Gif
export type GifFrame = gifFrame.GifFrame

--[=[
	@class giflib

	library
]=]
local giflib = {}
	
--[=[
	@prop gif gif
	@within giflib
]=]
giflib.gif = gif

--[=[
	@prop Frame gifFrame
	@within giflib
]=]
giflib.Frame = gifFrame


return giflib


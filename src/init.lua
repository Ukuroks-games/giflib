local gif = require(script.gif)
local gifFrame = require(script.gifFrame)

export type Gif = gif.Gif
export type GifFrame = gifFrame.GifFrame

return {
	gif = gif,
	Frame = gifFrame,
}

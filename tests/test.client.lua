local ReplicatedStorage = game:GetService("ReplicatedStorage")

local giflib = require(ReplicatedStorage.shared.giflib)


local imgLabel = Instance.new("ImageLabel")

local mygif = giflib.newGif(
	imgLabel, 
	{
		{Image = "img1", Time = 0.08},
		{Image = "img2", Time = 0.08},
		{Image = "img3", Time = 0.08}

	}
)

mygif:StartAnimation()

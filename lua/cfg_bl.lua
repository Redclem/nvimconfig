local bufferline = require("bufferline")

bufferline.setup{
	options = {
		mode = "buffers",
		indicator = {
			style = "underline",
		},
		separator_style = "slant",
		themable = true,
		numbers = "none"
	}
}

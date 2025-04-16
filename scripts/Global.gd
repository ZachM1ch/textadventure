extends Node

var deity_choice = null

enum ColorName {
	RED,
	GREEN,
	BLUE,
	YELLOW,
	ORANGE,
	PURPLE,
	PINK,
	WHITE,
	BLACK,
	GRAY,
	CYAN,
	BROWN,
	GOLD
}

const COLOR_VALUES := {
	ColorName.RED: Color("ff4c4c"),
	ColorName.GREEN: Color("4cff4c"),
	ColorName.BLUE: Color("4c4cff"),
	ColorName.YELLOW: Color("fff94c"),
	ColorName.ORANGE: Color("ff994c"),
	ColorName.PURPLE: Color("b44cff"),
	ColorName.PINK: Color("ff4cc7"),
	ColorName.WHITE: Color("ffffff"),
	ColorName.BLACK: Color("000000"),
	ColorName.GRAY: Color("888888"),
	ColorName.CYAN: Color("4cffff"),
	ColorName.BROWN: Color("8b5a2b"),
	ColorName.GOLD: Color("ffd700")
}

const COLOR_NAME_MAP := {
	"red": ColorName.RED,
	"green": ColorName.GREEN,
	"blue": ColorName.BLUE,
	"yellow": ColorName.YELLOW,
	"orange": ColorName.ORANGE,
	"purple": ColorName.PURPLE,
	"pink": ColorName.PINK,
	"white": ColorName.WHITE,
	"black": ColorName.BLACK,
	"gray": ColorName.GRAY,
	"cyan": ColorName.CYAN,
	"brown": ColorName.BROWN,
	"gold": ColorName.GOLD
}

func get_color_enum_from_hex(hex: String) -> int:
	for color_name in COLOR_VALUES.keys():
		if COLOR_VALUES[color_name].to_html() == Color(hex).to_html():
			return color_name
	return ColorName.GRAY  # fallback

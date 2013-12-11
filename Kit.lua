--| Purpose: General toolkit functionality
--| Authors: Atriace
--| Website: massive.atriace.com
----------------------------------------------------------------------------------
local parent, db = ...

function db.color(string, color)
	-- Returns text in the color chosen
	return ("|c00" .. db.hue[color] .. string .. "|r");
end

db.hue = {
	["azure"] = "40acf6",
	["blue"] = "2b74a6",
	["green"] = "7af965",
	["darkGreen"] = "339a22",
	["orange"] = "fd9317",
	["red"] = "ff2717",
	["white"] = "FFFFFF",
	["lightGrey"] = "d9d9d9",
	["grey"] = "808080",
	["darkGrey"] = "333333",
	["black"] = "000000"
}
--| Purpose: General toolkit functionality
--| Authors: Atriace@Gmail.com
--| Website: massive.atriace.com
----------------------------------------------------------------------------------
local parent, db = ...

DEFAULT_CHAT_FRAME:AddMessage("Massive: Kit Loaded", 1, 0, 0)

function db.TableSort(a, b)
	if a < b then
		return true
	end 
end

function db.GetObject(stringPath)
	local path, obj = { strsplit(".", stringPath) }
	for k,v in pairs(path) do
		if not obj then
			obj = _G[v]
		else
			obj = obj[v]
		end
	end
	return obj
end

function db.clone(input, output)
	-- Duplicates the values from input to output

	-- Validate content
	if (not input) then
		db.print("input was null");
		return
	elseif (not output) then
		db.print("output was null");
		return
	end

	-- Iterate over the input object
	for k, v in pairs(input) do
		if (type(v) == "table") then
			output[k] = db.clone(input[v], {})
		else
			output[k] = input[k]
		end
	end
end

function db.merge(input, output)
	-- Copies any values from input into output that share the same key

	-- Validate content
	if (not input) then
		db.print("input was null");
		return
	elseif (not output) then
		db.print("output was null");
		return
	end

	-- Iterate over the input object
	for k, v in pairs(input) do
		-- if the property is shared...
		if (output[k]) then
			-- ... and the value is another table
			if (type(v) == "table" and type(output[k]) == "table") then
				-- use the current object and merge the new values into it
				output[k] = db.merge(v, output[k])
			elseif (type(v) == "table") then
				-- create a new object and clone the values into it
				output[k] = db.clone(v, {})
			else
				-- Otherwise, just copy the value.
				output[k] = input[k]
			end
		end
	end
end

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
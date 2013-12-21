--| Purpose: General toolkit functionality
--| Authors: Atriace@Gmail.com
--| Website: massive.atriace.com
----------------------------------------------------------------------------------
local parent, db = ...

DEFAULT_CHAT_FRAME:AddMessage("Massive: Kit Loaded", 1, 0, 0)

function db.get(stringPath)
	-- Resolves a dot.notation to the nested object it was refering to.
	local path = db.split(stringPath, ".")
	local objName = table.remove(path, 1)
	local obj = _G[objName]
	
	
	if (obj ~= nil) then
		for k,v in pairs(path) do
			local matchFound = false
			if (db.isFrame(obj)) then
				--db.print(objName .. " is a frame.  Searching for " .. v .. " inside it.")
				local child = db.getChildByName(obj, v)
				if (child ~= nil) then
					--db.print("Found " .. v .. " inside " .. objName, 4)
					objName = v
					obj = child
					matchFound = true
				else
					--db.print(v .. " is not a child region of " .. objName, 3)
				end
			end

			if (matchFound == false) then
				--db.print(objName .. " is a " .. type(obj) .. ".  Searching for " .. v .. " inside it.")
				if obj[v] then
					--db.print("Found " .. v .. " inside " .. objName, 4)
					objName = v
					obj = obj[v]
				else
					--db.print(v .. " is not a property of " .. objName, 3)
				end
			end
		end
		return obj
	else
		db.print(objName .. " is not a global property.", 3)
		return nil
	end
end

function db.getChildByName(f, name)
	local list = {f:GetChildren()}
	local obj = nil
	for k,v in pairs(list) do
		if (v:GetName() == name) then
			obj = v
			break
		end
	end
	return obj
end

function db.isFrame(obj)
	if (type(obj) == "table") then
		if obj.GetName then
			db.print(tostring(obj) .. " is a frame called " .. obj:GetName())
			return true
		else
			db.print(tostring(obj) .. " is not a frame")
			return false
		end
	else
		db.print(tostring(obj) .. " is not a table")
		return false
	end
end

-----------------------
--| Table Functions |--
-----------------------

function db.TableSort(a, b)
	if a < b then
		return true
	end 
end

function db.length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
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
			if (output[k] and type(output[k]) == "table") then
				--db.print("Cloning table to existing " .. tostring(k))
				output[k] = db.clone(v, output[k])
			else
				--db.print("Cloning to new table " .. tostring(k))
				output[k] = db.clone(v, {})
			end
		else
			--db.print("Cloning " .. tostring(k) .. " | " .. (tostring(output[k]) or "nil") .. " >> " .. (tostring(input[k]) or "nil"))
			output[k] = input[k]
		end
	end

	return output
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

	return output
end

function db.getKeyOrder(hash)
	-- Returns an array with sorted key values.
	local order = {}
	for k,v in pairs(hash) do
		table.insert(order, tostring(k))
	end

	db.alphanumsort(order)

	return order
end

function db.alphanumsort(o)
  local function padnum(d) return ("%03d%s"):format(#d, d) end
  table.sort(o, function(a,b)
    return tostring(a):gsub("%d+",padnum) < tostring(b):gsub("%d+",padnum) end)
  return o
end

function db.type(item)
	local msg = type(item)
	if (msg == "table") then
		if (item.IsForbidden and type(item.IsForbidden) == "function") then
			--db.print("Checking: " .. type(item) .. type(rawget(item, 0)))
			if (type(rawget(item, 0)) == "nil" or item:IsForbidden() == true ) then
				msg = "forbidden"
			else
				msg = string.lower(item:GetObjectType())
			end
		end
	end
	return msg
end

------------------------
--| String Functions |--
------------------------

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


function db.color(string, color)
	-- Returns text in the color chosen
	return ("|c00" .. db.hue[color] .. string .. "|r")
end

function db.split(s, sep)
	--db.print("Running split on '" .. s .. "' using '" .. sep .. "'")
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(s, pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function db.join(arr, sep)
	--db.print("Joining " .. #arr .. " with '" .. sep .. "'")
	local s = arr[1]
	if #arr > 1 then
		for k, v in pairs(arr) do
			if k > 1 then
				s = s .. sep .. v
			end
		end
	end
	return s
end

function charPad(num, char)
	-- Returns a string of num length of char type
	if (num < 1) then num = 0 end
	if char == nil then char = " " end

	local i = 0
	local txt = ""
	while (i <= num) do
		txt = txt .. char
		i = i + 1
	end
	return txt
end
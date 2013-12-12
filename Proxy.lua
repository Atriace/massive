-- Author: Atriace@Gmail.com
-- Created: 2013.06.19
-- Purpose: A common object which inherits its properties from an original object.  This can be used in-place-of the original for hypothetical calculations.

local parent, db = ...



function Proxy(input:Object)
	local props = {
		["x"] = 0,
		["y"] = 0,
		["width"] = 0,
		["height"] = 0,
		["scaleX"] = 1,
		["scaleY"] = 1,
		["parent"] = Ref._,
		["name"] = "proxe"
	}

	for (local item:String in props) {
		if (input ~= null and input[item]) {
			this[item] = input[item]
		} else {
			this[item] = props[item]
		}
	}
	
	if (input ~= null and input is DisplayObject) { 
		bound.x = input.getBounds(input).x
		bound.y = input.getBounds(input).y
	}
end

function locs()
	return {["x"] = this.x, ["y"] = this.y}
end

function size()
	return {["width"] = this.width, ["height"] = this.height, ["scaleX"] = this.scaleX, ["scaleY"] = this.scaleY}
end

function space()
	return {["x"] = this.x, ["y"] = this.y, ["width"] = this.width, ["height"] = this.height, ["scaleX"] = this.scaleX, ["scaleY"] = this.scaleY}
end

function locScale()
	return {["x"] = this.x, ["y"] = this.y, ["scaleX"] = this.scaleX, ["scaleY"] = this.scaleY}
end

function dimensions()
	return {["x"] = this.x, ["y"] = this.y, ["width"] = this.width, ["height"] = this.height}
end

function bounds(That)
	local answer = roxy()

	--Kit.print(this.name + "[x:" + this.x + ", y:" + this.y + ", width:" + this.width + ", height:" + this.height + "] and " + That.name + "[x:" + That.x + ", y:" + That.y + ", width:" + That.width + ", height:" + That.height + "]")

	-- What is the northwestern point?
	if (That.x < this.x) { -- save That as west
		answer.x = That.x
	} else { -- save this as west
		answer.x = this.x
	end

	if (That.y < this.y) { -- save That as north 
		answer.y = That.y
	} else { -- save this as north
		answer.y = this.y
	end

	-- What is the southeastern point?
	if (That.x + That.width > this.x + this.width) { -- save That as east
		answer.width = (answer.x * -1) + That.x + That.width
	} else { -- save this as east
		answer.width = this.width --(answer.x * -1) + this.x + this.width
	end

	if (That.y + That.height > this.y + this.height) { -- save That as south
		answer.height = (answer.y * -1) + That.y + That.height
	} else { -- save This as south
		answer.height = this.height--(answer.y * -1) + this.y + this.height
	end

	--Kit.print("[x:" + answer.x + ", y:" + answer.y + ", width:" + answer.width + ", height:" + answer.height + "]", ["system")

	return answer
}
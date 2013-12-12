--| Purpose: A library of functions for creating interface objects 
--| Authors: Atriace@Gmail.com
--| Website: massive.atriace.com
----------------------------------------------------------------------------------
local parent, db = ...

function db.CreateWindow(title, sizeX, sizeY, fade, direction, parent)
	-- Deprecated.  To be replaced by db.shape()
	-- Primary output window
	local frame = CreateFrame("ScrollingMessageFrame", title, _G["Massive"])
	frame:StopMovingOrSizing()
	frame:ClearAllPoints()
	if parent then
		frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 13, 0)
	end
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(256)
	frame:SetHeight(256)
	frame:SetPoint("CENTER",0,0)
	-- frame:SetInsertMode(direction)
	frame:SetJustifyH("LEFT")
	frame:SetMaxLines(50000)
	frame:SetFading(false)
	frame:SetFadeDuration(3)
	frame:SetTimeVisible(60)
	frame:SetResizable(true)
	frame:SetMinResize(50, 50) 
	frame:SetClampedToScreen(true)
	frame:SetClampRectInsets(-9, 7, 7, -7)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	frame:SetScript("OnMouseWheel", db.ScrollReport)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	frame:SetScript("OnMouseUp", function(self) db.SnapWindows(self) end)
	frame:SetScript("OnHide", frame:GetScript("OnMouseUp"))
	frame:SetFont(db.dir..db.font..".ttf", 10)
	frame:SetSpacing(3)
	
	db.CreateBorder(title, frame)
	db.CreateGrip(title, frame)
	db.CreateTitle(title, frame)
	
	frame:AddMessage("<< "..title.." Online >>", .5, .5, .5, 0)
end

function db.shape(p)
	-- Creates a shape
	local q = {
		["x"] = 0,
		["y"] = 0,
		["width"] = 100,
		["height"] = 100,
		["color"] = hue.black,
		["alpha"] = 1,
		["edge"] =  {
			["color"] = hue.white,
			["width"] = 0,
			["alpha"] = 0.5
		}
	}

	db.merge(p, q)

	-- Unfinished
end

function db.CreateTitle(title, frame)
	-- Deprecated.  To be replaced by createText
	local bg = _G[frame:GetName().."_BG"]
	local bar = CreateFrame("Frame", title.."Bar", frame)
	bar:ClearAllPoints()
	bar:SetHeight(32)
	bar:SetPoint("TOPLEFT", bg, "TOPLEFT", 0, 0)
	bar:SetPoint("TOPRIGHT", bg, "TOPRIGHT", 0, 0)
	bar:SetFrameStrata("DIALOG")
	
	local texture = bar:CreateTexture(title.."Bar_Texture","BACKGROUND")
	texture:SetTexture(.1,.1,.1,.9)
	texture:SetAllPoints(bar)
	
	local fontstring = bar:CreateFontString(title.."Title","DIALOG") 
	fontstring:SetFont(db.dir..db.font..".ttf", 13)
	fontstring:SetJustifyH("LEFT")
	fontstring:SetPoint("left", bar, "left", 15, -1)
	fontstring:SetShadowColor(0, 0, 0, 1)
	fontstring:SetShadowOffset(0, -1)
	fontstring:SetText(title)
end

function createText(p)
	-- Creates a text object
	local q = {
		["text"] = "Text",
		["width"] = 150,
		["height"] = 20,
		["alpha"] = 1,
		["blendMode"] = "normal",
		["autoSize"] = "left",
		["wordWrap"] = false,
		["multiline"] = true,
		["selectable"] = false,
		["condenseWhite"] = false,
		["format"] = {
			["align"] = "left",
			["color"] = "0x000000",
			["font"] = "VeraMoBd.ttf",
			["size"] = 12,
			["leading"] = 4
		}
	}

	db.merge(p, q)
end

function align(a, b, p)
	-- Places a relative to b
	if (a and b) then
		local q = {
			["h"] = 0.0,			-- 0-1, left to right
			["v"] = 0.0,			-- 0-1, top to bottom
			["pad"] = 0,			-- in pixels
			["padX"] = nil,
			["padY"] = nil,
			["overlap"] = true,		-- inside or outside That's region
			["overlapX"] = nil,
			["overlapY"] = nil,
			["scale"] = 1,			-- Scale isn't implimented yet.
			["scaleX"] = nil,
			["scaleY"] = nil,
			["apply"] = true,		-- Apply the calculations to A or just return the values
			["clamp"] = true		-- Keeps placement clamped to whole pixel values
		}

		merge(p,q)

		-- Simplify operations by only dealing with proxies. We'll apply these later if requested.
		local loc = toGlobal(b)
		local bProxe = new Proxe(b)
		bProxe.x = loc.x + bProxe.bound.x
		bProxe.y = loc.y + bProxe.bound.y

		loc = toGlobal(a)
		local aProxe = new Proxe(a)
		aProxe.x = loc.x + aProxe.bound.x
		aProxe.y = loc.y + aProxe.bound.y

		-- If declared, use the XY specific values, otherwise, the generic value.
		padX = (padX ~= nil) ? padX : pad
		padY = (padY ~= nil) ? padY : pad
		overlapX = (overlapX ~= nil) ? overlapX : overlap
		overlapY = (overlapY ~= nil) ? overlapY : overlap
		scaleX = (scaleX ~= nil) ? scaleX : scale
		scaleY = (scaleY ~= nil) ? scaleY : scale

		-- Apply final scale values.
		aProxe.scaleX = scaleX
		aProxe.scaleY = scaleY
		aProxe.width = aProxe.width * scaleX
		aProxe.height = aProxe.height * scaleY

		-- Place the XY of This at the coordinates defined by the percentages of (H)orizontal and (V)ertical values relative to That plus padding.
		local offset = {}

		local h2:Number = 1 - h
		if (overlapX) {
			h2 = h
			padX = -padX
		}
		offset.x = (bProxe.width + padX * 2) * h - padX - aProxe.width * h2 + bProxe.x

		local v2 = 1 - v
		if (overlapY) {
			v2 = v
			padY = -padY
		}
		offset.y = (bProxe.height + padY * 2) * v -padY - aProxe.height * v2 + bProxe.y
		
		-- Convert the values back to local space (removing offsets).
		offset = toLocal(offset, aProxe.parent).locs()

		-- Undo the boundary compensation
		offset.x -= aProxe.bound.x
		offset.y -= aProxe.bound.y

		if (clamp) {
			offset.y = Math.round(offset.y)
			offset.x = Math.round(offset.x)
		}

		if (apply) {
			a.x = offset.x
			a.y = offset.y
		} else {
			delete(offset.parent)
			db.merge(offset, aProxe)
		}

		-- Undo the scale
		aProxe.width = a.width
		aProxe.height = a.height

		return aProxe
	else
		local aName:String, bName:String
		if (a ~= nil and a.name) then
			aName = a.name
		else
			aName = "nil"
		end

		if (b ~= nil and b.name) then
			bName = b.name
		else
			bName = "nil"
		end

		db.print("Cannot align a nil object. " .. aName .. " to " .. bName, "error")
		db.report(a)
		db.report(b)
		return new Proxe()
	end
end

-- public static function toGlobal(box, offset = nil) {
-- 	/* Finds the absolute stage coordinate of the object passed to it. */
-- 	local proxy = new Proxe(box) 
	
-- 	//db.print("from " + (box.name?box.name:"anonymous object") + " at " + proxy.x + "," + proxy.y, "system")

-- 	if (offset ~= nil) { db.merge(offset, proxy) }

-- 	if (box.hasOwnProperty("parent") and box.parent ~= Ref._) {
-- 		local limit = Ref._.parent
		
-- 		local ref = proxy
-- 		while (ref.parent and ref.parent ~= limit) {
-- 			//db.print("/"+ref.parent)
-- 			ref = ref.parent
-- 			proxy.x += ref.x
-- 			proxy.y += ref.y

-- 			//db.print(proxy.name + ".scale:" + proxy.scaleX + " * " + ref.name + ".scale:" + ref.scaleX + " = " + (proxy.scaleX*ref.scaleX))
-- 			proxy.scaleX = proxy.scaleX*ref.scaleX
-- 			proxy.scaleY = proxy.scaleY*ref.scaleY
-- 		}
-- 	}

-- 	//db.print(box.x + "," + box.y + " = " + proxy.x + "," + proxy.y)

-- 	return proxy
-- }

-- public static function toLocal(source, targetSpace:DisplayObjectContainer, offset = nil) {
-- 	/* Returns coordinates of source in the local space of target. */
-- 	//db.print("to " + targetSpace.name, "system")

-- 	local proxy = new Proxe(source)
-- 	if (offset ~= nil) { db.merge(offset, proxy) }


-- 	if (source.parent ~= targetSpace) {
-- 		//db.print("Traversing link for " + source.name + " to " + targetSpace.name + ".", "warning")
-- 		// Both display objects need to share the same global space, so backtrack first
-- 		proxy = toGlobal(source)
		
-- 		// Next construct the path to the target space
-- 		local path:Array = []
-- 		local ref:DisplayObjectContainer = targetSpace

-- 		while (ref.parent and ref.parent ~= Ref._.parent) {
-- 			path.push(ref)
-- 			ref = ref.parent
-- 		}

-- 		// Now sort the math out
-- 		for (local i:int = path.length-1 path[i] i--) {
-- 			proxy.x -= path[i].x
-- 			proxy.y -= path[i].y
-- 			//db.print(path[i].name + ' modified offset = ' + proxy.x + "," + proxy.y)
-- 		}
-- 	} else {
-- 		//db.print(source.name + " already exists in " + targetSpace.name + ".", "warning")
-- 	}

-- 	return proxy
-- }

function db.CreateEditBox(parent)
	local title = parent.."Edit"
	local frame = CreateFrame("EditBox", title, _G[parent])
	frame:SetFont(db.dir..db.font..".ttf", 11)
	frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -11)
	frame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, -11)
	frame:SetFrameStrata("HIGH")
	frame:SetHeight(26)
	frame:ClearFocus()
	frame:SetAutoFocus(false)
	frame:SetScript("OnEscapePressed", db.OnEscapePressed)
	frame:SetScript("OnEnterPressed", db.OnEnterPressed)
	db.CreateBorder(title, frame)
end

function db.CreateBorder(title, frame)
	local bg = frame:CreateTexture(title.."_BG","BACKGROUND")
	local xOf, yOf, loc, border, i = 5, 5, {
		[1] = { "BOTTOMRIGHT", "TOPLEFT" }, -- tl
		[2] = { "BOTTOMLEFT", "TOPRIGHT" }, -- tr
		[3] = { "TOPRIGHT", "BOTTOMLEFT" }, -- bl
		[4] = { "TOPLEFT", "BOTTOMRIGHT" }, -- br
		[5] = { "BOTTOM", "TOP", "LEFT", "RIGHT", 1, 2 }, -- top
		[6] = { "RIGHT", "LEFT", "TOP", "BOTTOM", 1, 3 }, -- left
		[7] = { "LEFT", "RIGHT", "TOP", "BOTTOM", 2, 4 }, -- right
		[8] = { "TOP", "BOTTOM", "LEFT", "RIGHT", 3, 4 }, -- bottom
	}
	bg:SetTexture(0,0,0,0.75)
	bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -(xOf+2), yOf)
	bg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", xOf, yOf)
	bg:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -(xOf+2), -yOf)
	bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", xOf, -yOf)
	for v=1, 8, 1 do
		border = frame:CreateTexture(title.."_Border_"..v, "BORDER")
		border:SetTexture(1,1,1,.1)
		border:SetHeight(1)
		border:SetWidth(1)
		border:SetPoint(loc[v][1], bg, loc[v][2])
		if v>4 then
			border:SetPoint(loc[v][3], title.."_Border_"..loc[v][5], loc[v][4])
			border:SetPoint(loc[v][4], title.."_Border_"..loc[v][6], loc[v][3])
		end
	end
end

function db.CreateGrip(title, frame)
	local handle = CreateFrame("Button", title.."Handle", frame)
	handle:SetWidth(16)
	handle:SetHeight(16)
	handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	handle:EnableMouse(true)
	handle:RegisterForClicks("LeftButton")
	handle:SetScript("OnMouseDown", function() _G[title]:StartSizing() end)
	handle:SetScript("OnMouseUp", function() _G[title]:StopMovingOrSizing() end)
	local texture = handle:CreateTexture("HandleTexture","HIGH")
	texture:SetTexture(db.dir.."grip")
	texture:SetAllPoints(handle)
end
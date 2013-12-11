--| Purpose: Massive DevTool
--| Authors: Atriace
--| Website: massive.atriace.com																
----------------------------------------------------------------------------------
DEFAULT_CHAT_FRAME:AddMessage("Massive Loaded", 1, 0, 0)
local db, dbVersion = LibStub:NewLibrary("Massive",1);
if not db then return end
db.printLog = {"1","2","3","4","5","6","7","8","9","10"}
db.error = {"frog", "lips", "dame", "man"}
db.search = "exact"
while not db.error[20] do
	table.insert(db.error, 1, "Oodles")
end
local frame = CreateFrame("Frame", "Massive", UIParent)
frame:SetPoint("CENTER")
frame:SetHeight(1)
frame:SetWidth(1)
frame:SetScript("OnEvent", function(...) db.OnEvent(...) end)
frame:RegisterAllEvents()

function db.VarInitialize()
	SlashCmdList["MASSIVE"] = db.SlashCmd
	SLASH_MASSIVE1 = "/mass"
	SLASH_MASSIVE2 = "/massive"
	masspath = LibStub.libs.Massive
	db.trackedVars = {}
	db.events = {}
	db.RegisteredEvents = {
		MACRO_ACTION_FORBIDDEN = "ActionBlocked",
		ADDON_ACTION_FORBIDDEN = "ActionBlocked",
		PLAYER_LOGOUT = "PlayerLogout",
		VARIABLES_LOADED = "VariablesLoaded",
	}
	for k,v in pairs(db.RegisteredEvents) do frame:RegisterEvent(k) end
	
	db.dir = "Interface\\AddOns\\Massive\\media\\"
	db.pre = "Massive"
	db.font = "VeraMoBd"
	db.ScrollInterval = 0
	db.UpdateInterval = 0
	db.SecondInterval = 0
	db.second = 0
	db.physics = {
		as = 0,
		v = 0,
		dx = 0,
	}
	
	db.cmdList = {
		obj = "report",
		object = "report",
		event = "FrameEvents",
		track = "track",
		ilist = "InvList",
		cvar = "cvar",
		find = "FindObject",
		show = "show",
	}
	
	--[[ KeyBindings ]]--
	BINDING_HEADER_MASSIVE = "Massive Development Tool"
	BINDING_NAME_MASSIVE_RELOADUI = "Reload the UI"
	BINDING_NAME_MASSIVE_MOVE_LEFT = "Move Shown window left"
	BINDING_NAME_MASSIVE_MOVE_RIGHT = "Move Shown window right"
	BINDING_NAME_MASSIVE_MOVE_UP = "Move Shown window up"
	BINDING_NAME_MASSIVE_MOVE_DOWN = "Move Shown window down"
		
	MassiveData = db
end

function db.SlashCmd(msg)
	local messages = {strsplit(" ", msg)}
	local msgLength = string.len(messages[1])
	messages[1] = string.lower(messages[1])
	if msgLength==0 then
		db.print("Massive CmdList:", 4, false)
		for k,v in pairs(db.cmdList) do
			if k~="object" then
				db.print(k)
			end
		end
	elseif msgLength>0 then
		for k,v in pairs(db.cmdList) do
			if k==messages[1] then
				if k=="ilist" or k=="find" or messages[2] then
					table.remove(messages, 1)
					db[v](unpack(messages))
				else
					db.print(k.." requires an argument.")
				end
			end
		end
	end
end

function db.show(region)
	local object, swap, path = _G[region], region
	if object then
		db.shownregion = object
		local frame = MassiveRegion or CreateFrame("Frame", db.pre.."Region", Massive)
		frame:ClearAllPoints()
		frame:SetAllPoints(object)
		frame:SetFrameStrata("DIALOG")
		
		local texture = MassiveRegion_Texture or frame:CreateTexture(db.pre.."Region_Texture","BACKGROUND")
		texture:SetTexture(1,1,1,0.25)
		texture:SetAllPoints(frame)
		
		local fontstring = MassiveRegion_FontString or frame:CreateFontString("MassiveRegion_FontString","DIALOG") 
		fontstring:SetFont(db.dir..db.font..".ttf", 9)
		fontstring:SetJustifyH("LEFT")
		fontstring:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, 6)
		fontstring:SetShadowColor(0, 0, 0, 1)
		fontstring:SetShadowOffset(1, -1)
		
		local bg = MassiveRegion_BG or frame:CreateTexture(db.pre.."Region_BG","BACKGROUND")
		bg:SetTexture(0,0,0,0.75)
		bg:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 0,1)
		bg:SetPoint("BOTTOMRIGHT", texture, "TOPRIGHT", 0,1)
		bg:SetPoint("TOPLEFT", texture, "TOPLEFT", 0,70)
		bg:SetPoint("TOPRIGHT", texture, "TOPRIGHT", 0,70)
		
		local seperator = MassiveRegion_Seperator or frame:CreateTexture(db.pre.."Region_Seperator","HIGH")
		seperator:SetTexture(1,1,1,0.5)
		seperator:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 0,0)
		seperator:SetPoint("BOTTOMRIGHT", texture, "TOPRIGHT", 0,0)
		seperator:SetHeight(1)
		
		path = "/"..swap
		while object:GetParent() do
			path = "/"..(object:GetParent()):GetName()..path
			object = object:GetParent()
		end
		
		local point, relativeTo, relativePoint, xOfs, yOfs = _G[swap]:GetPoint()
		relativeTo = relativeTo or UIParent
		fontstring:SetText(path.."\rPoint: "..point.." | relPoint: "..relativePoint.."\rrelTo: "..relativeTo:GetName().."\rX: "..xOfs.."\rY: "..yOfs.."\rDimensions: |c00AAAAFF"..math.floor(_G[swap]:GetWidth()+.5).." x "..math.floor(_G[swap]:GetHeight()+.5).."|r")
	else
		if type(region)=="string" then
			db.print(tostring(region).." was not found.")
		end
	end
end

function Massive_moveShown(direction, toggle)
	if MassiveRegion and toggle==true then
		local object = db.shownregion
		local point, relativeTo, relativePoint, x, y = object:GetPoint()
		relativeTo = relativeTo or UIParent
		x = math.floor(x+.5)
		y = math.floor(y+.5)
		object:ClearAllPoints()
		if direction=="left" then
			object:SetPoint(point, relativeTo, relativePoint, (x-1),y)
		elseif direction=="right" then
			object:SetPoint(point, relativeTo, relativePoint, (x+1),y)
		elseif direction=="up" then
			object:SetPoint(point, relativeTo, relativePoint, x, (y+1))
		elseif direction=="down" then
			object:SetPoint(point, relativeTo, relativePoint, x, (y-1))
		end
		db.show(object)
		MassiveRegion.direction = direction
		MassiveRegion.toggle = toggle
	elseif MassiveRegion and toggle==false then
		MassiveRegion.toggle=nil
		MassiveRegion.direction=nil
		MassiveRegion.interval=nil
	else
		db.print("You are not tracking a region.  Nothing to move.")
	end
end

function db.cvar(var, setting)
	if GetCVar(var) then
		if not setting then
			SetCVar(var, GetCVarDefault(var), true)
			db.print("CVar "..var.." reset.")
		else
			SetCVar(var, setting, true)
			db.print("CVar "..var.." set to "..setting)
		end
	end
end

function db.CreateWindow(title, sizeX, sizeY, fade, direction, parent)	
	-- Primary output window
	local frame = CreateFrame("ScrollingMessageFrame", title, _G[db.pre])
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
	
	db.CreateBorder(title, frame)
	db.CreateGrip(title, frame)
	db.CreateTitle(title, frame)
	
	frame:AddMessage("<< "..title.." Online >>", .5, .5, .5, 0)
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

function db.CreateTitle(title, frame)
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

function db.OnEscapePressed(self)
	self:ClearFocus()
end

function db.OnEnterPressed(self)
	-- Handles commands entered into the debug window.
	local text, hit, arg, key, iend = self:GetText(), false
	local call, arg = strsplit(" ", text)
	if arg then
		key, iend = string.find(text, call)
		arg = string.sub(text, iend+2)
	else
		call = text
		arg = arg or ""
	end

	db[call](arg)
	-- call = string.lower(call)
	-- for k,v in pairs(SlashCmdList) do
	-- 	key = string.lower(k)
	-- 	if key==call then
	-- 		v(arg)
	-- 		hit = true
	-- 		break
	-- 	end
	-- end
	-- if hit==false then
	-- 	db.print("/script "..text)
	-- 	RunScript(text)
	-- end
end

function db.SnapWindows(primary)
	local ploc = {db.GetPoints(primary, "all")}
	local frames = { _G[db.pre]:GetChildren() }
	for _,v in ipairs(frames) do
		if v~=primary then
			local loc, tolerance = {db.GetPoints(v, "all")}, 30
			local xdif = math.abs(loc[1]-ploc[5])
			local ydif = math.abs(loc[2]-ploc[6])
			-- db.print("loc: "..loc[1]..", "..loc[5].." | ploc:"..ploc[1]..", "..ploc[5].."  |  xdif:"..xdif..", ydif:"..ydif)
			if xdif<=tolerance and ydif<=tolerance then
				v:SetPoint("TOPLEFT", primary, "TOPRIGHT", 13, 0)
			end
		end
	end
end

function db.print(msg, id, clear)
	if MassiveReport then
		if clear then
			MassiveReport:Clear()
		end
		if msg and msg~=_ then
			table.insert(db.printLog, 10, msg)
			table.remove(db.printLog, 1)
			MassiveReport:AddMessage(msg, .65, .65, .65, (id or 0))
			MassiveReport:UpdateColorByID(1, 0.35, 0.35, 1.00) -- Blue
			MassiveReport:UpdateColorByID(2, 0.50, 1.00, 0.50) -- Green
			MassiveReport:UpdateColorByID(3, 1.00, 0.35, 0.35) -- Red
			MassiveReport:UpdateColorByID(4, 0.28, 0.65, 1.00) -- Cyan
			MassiveReport:UpdateColorByID(5, 1.00, 0.65, 0.00) -- Orange
			MassiveReport:UpdateColorByID(6, 0.92, 0.92, 0.00) -- Yellow
			MassiveReport:UpdateColorByID(7, 0.50, 0.10, 1.00) -- Purple
			MassiveReport:UpdateColorByID(9, 0.5, 0.5, 0.5) -- Grey
			MassiveReport:UpdateColorByID(10, 1, 1, 1) -- White
		end
	end
end

function db.track(var)
	if var=="erase" or var=="clear" then
		db.trackedVars = {}
	else
		local temp = db.GetObject(var)
		if type(temp)=="table" then
			for k, v in pairs(temp) do
				local vType = type(v)
				local test1, test2 = true, true
				if vType=="table" then
					test1 = false
				end
				if vType=="function" then
					test2 = false
				end
				if test1 and test2 then
					if not db.trackedVars[var.."."..k] then
						db.trackedVars[var.."."..k] = var.."."..k
						table.sort(db.trackedVars, db.TableSort)
					elseif type(v)~="table" then
						db.trackedVars[var.."."..k] = nil
					end
				end
			end
		else
			if not db.trackedVars[var] then
				db.trackedVars[var] = var
				table.sort(db.trackedVars, db.TableSort)
			else
				db.trackedVars[var] = nil
			end
		end
	end
end

function db.GetPoints(frame, anchor)
	if type(frame)~="table" then frame = _G[frame] end
	if not frame then return end
	local t = frame:GetTop()
	local l = frame:GetLeft()
	local r = frame:GetRight()
	local b = frame:GetBottom()
	local locs = {
		TOPLEFT = { l, t },
		TOP = { (l+r)/2, t },
		TOPRIGHT = { r, t },
		LEFT = { (b+t)/2, l },
		RIGHT = { (b+t)/2, r },
		BOTTOMLEFT = { l, b },
		BOTTOM = { (l+r)/2, b },
		BOTTOMRIGHT = { r, b },
		CENTER = { (l+r)/2, (b+t)/2},
	}
	locs.all = { locs.TOPLEFT[1], locs.TOPLEFT[2], locs.TOP[1], locs.TOP[2], locs.TOPRIGHT[1], locs.TOPRIGHT[2], locs.LEFT[1], locs.LEFT[2],  locs.RIGHT[1], locs.RIGHT[2], locs.BOTTOMLEFT[1], locs.BOTTOMLEFT[2], locs.BOTTOM[1], locs.BOTTOM[2], locs.BOTTOMRIGHT[1], locs.BOTTOMRIGHT[2] }
	
	for k,v in pairs(locs) do
		if k==anchor then
			return unpack(v)
		end
	end
end

function db.FrameEvents(frame, eventName)
	local gFrame = db.GetObject(frame)
	if gFrame and gFrame.IsEventRegistered then
		if eventName then
			eventName = string.upper(eventName)
			if gFrame:IsEventRegistered(eventName) then
				db.print(eventName.." is registered to "..frame)
			else
				db.print(eventName.." is not registered to "..frame)
			end
		else
			db.print("<< Currently known events registered to "..frame.." >>\r\r", 9,true)
			for k,v in pairs(db.events) do
				if gFrame:IsEventRegistered(k) then
					db.print(k, 5)
				end
			end
			db.print("\r\r<< End of report >>", 9)
		end
	else
		db.print("\r\r<< "..frame.." is not a frame >>", 3)
	end
end

local i, hits, valid, start, finish, swap

function db.FindObject(object, scope, depthLimit, path, indent)
	if not object then
		db.print("USAGE: find (object, scope, depthlimit)", 5)
		return
	end
	indent = indent or ""
	i = i or 1
	--[[ If no depthlimit is given, but scope is a number,
		set the depthlimit to scope value ]]--
	if scope and type(tonumber(scope))=="number" then
		depthLimit = (tonumber(scope))
		scope = nil
	else
		depthLimit = depthLimit or 4
	end
	
	--[[ Convert the given string scope to our search path,
		otherwise our scope is assumed to be a table or _G ]]--
	if scope and type(scope)=="string" then
		valid = scope.."(string)"
		scope = scope
	else
		if (not scope) or type(scope)=="number" then
			valid = "_G"
			scope = _G
		elseif type(scope)=="table" then
			valid = "passed table"
			scope = scope
		end
	end
	
	--[[ Fetch filepath for printout ]]--
	swap = scope
	if swap and string.find(tostring(object.GetName or ""), "function", 1, true) and object.GetRegions then
		while swap:GetParent() do
			path = "/"..(swap:GetParent()):GetName()..(path or "")
			swap = swap:GetParent()
		end
	else
		path = path or "_G"
	end
	
	--[[ Opening checkpoints ]]--
	if not db.FindObject_TimeStamp then
		db.FindObject_TimeStamp = GetTime()
		db.FindObject_nestDepth = 1
		i, hits = 1, 0
		db.print("\r\r<< Search for "..object.." started with a level "..depthLimit.." depth limit >>")
		-- db.print("Object: "..object..".  Scope: "..valid.."("..type(scope)..").  Path:"..path..".  DepthLimit: "..depthLimit, 4)
	end
	local key, value, khit
	if type(scope)=="table" then
		for k,v in pairs(scope) do
			i = i + 1
			key = tostring(k)
			if (GetTime()-db.FindObject_TimeStamp)<=10 then
				if db.search=="full" then
					-- If we start a caseless, wildcard search
					object = string.lower(object)
					key = db.sanitize(k)
					value = db.sanitize(v)
					if string.find(key, object) then
						khit = true
					else
						khit = false
					end
					if string.find(value, object) then
						vhit = true
					else
						vhit = false
					end
				end
				if key==object or khit==true then
					db.print(path.."[|c0000AAFF"..k.."|r]", 10)
					hits = hits + 1
				elseif tostring(v)==object or vhit==true then
					db.print(path.."["..key.."] = |c0000AAFF"..v.."|r", 10)
					path = path.."["..key.."]"
					hits = hits + 1
				end
				if type(v)=="table" then
					--[[ See if we're repeating hierarchy.  If found, verify and exit.  ]]
					if string.match(path, key) then
						path = string.reverse(path)
						start, finish = string.find(path, "[", 1, true)
						if finish then
							swap = string.sub(path, 2, finish-1)
							swap = string.reverse(swap)
							path = string.reverse(path)
							if string.match(path, swap) then
								db.FindObject_nestDepth = db.FindObject_nestDepth - 1
								return
							end
						end
					else
						-- db.print(db.FindObject_nestDepth..": "..path..indent..tostring(k),5)
						db.FindObject_nestDepth = db.FindObject_nestDepth + 1
						db.FindObject(object, scope[k], depthLimit, path.."["..key.."]", (indent.."  "))
					end
				end
			end
		end
	end
	db.FindObject_nestDepth = db.FindObject_nestDepth - 1
	if db.FindObject_nestDepth==0 or db.FindObject_nestDepth<0 then
		db.print("<< "..i.." indexes searched.  "..hits.." hits found. >>", 9, false)
		db.FindObject_TimeStamp = nil
		db.FindObject_nestDepth = 1
	end
end

function db.sanitize(arg)
	-- Reduces the string to an easily comparable value, including removing POSIX refs
	local value = string.gsub(string.lower(tostring(arg)), "%%%d%$s", "[string]")
	return value
end

function db.report(target, depthLimit, indent)	
	depthLimit = (tonumber(depthLimit)) or 4
	indent = indent or ""
	local object, region, regions, vType, key  = target
	if type(target)=="string" then
		object = _G[target]
		if not object then
			object = db.GetObject(target)
		end
	end
	local region = string.find(tostring(object.GetName or ""), "function", 1, true)
	if region and type(object)=="table" then
		if object.GetRegions then regions = { object:GetRegions() } end
		if object.GetChildren then object = { object:GetChildren() } end
	end
	if not db.ReportObject_TimeStamp then
		db.ReportObject_TimeStamp = GetTime()
		db.ReportObject_nestDepth = 1

		db.print(indent.."<< Report for "..type(target).." started >>\r\r", 9, true)
	end
	
	if object then
		for k,v in pairs(object) do
			if (GetTime()-db.ReportObject_TimeStamp) > 15 and not db.ReportObject_warned then
				db.ReportObject_warned = true
				db.print("\r\r"..indent.."--<< ReportObject failsafe activated >>--", 3)
				db.print(indent.."-- Try limiting your search depth:", 9)
				db.print(indent.."   /mass obj OBJECT |c000088FFdepthLimit|r\r\r", 10)
				break
			else
				if type(v)=="table" then
					if region and v.GetObjectType then
						db.print(indent..(v:GetObjectType() or tostring(v))..": "..(v:GetName() or ""), 5)
						-- (v:GetFrameType() or type(v) or "no type")..": "..(v:GetName() or k or "no name"), 5)
					else
						db.print(indent..tostring(k).." = {", 5)
					end
					if db.ReportObject_nestDepth<=depthLimit and k~="parent" then
						db.ReportObject_nestDepth = db.ReportObject_nestDepth + 1
						db.report(object[k], depthLimit, indent.."  ")
					end
					if not v.GetObjectType then
						db.print(indent.."},", 5)
					end
				elseif db.ReportObject_warned~=true then
					key = tostring(k)
					if type(k)=="number" then
						key = "["..k.."]"
					end
					if type(v)=="string" then
						db.print(indent..key.." = ".."\""..v.."\"", 10)
					elseif type(v)=="number" then
						db.print(indent..key.." = "..v, 4)
					elseif type(v)=="boolean" then
						db.print(indent.."|c00BBBBBB"..key.."|r = "..tostring(v), 1)
					elseif type(v)=="function" then
						db.print(indent..key.."()", 9)
					elseif type(v)~="userdata" then
						db.print(indent.."Unhandled type: "..type(v).." | "..k, 9)
					end
				end
			end
		end
		if regions then
			for k,v in pairs(regions) do
				if (GetTime()-db.ReportObject_TimeStamp) > 15 and not db.ReportObject_warned then
					db.ReportObject_warned = true
					db.print("\r\r"..indent.."--<< ReportObject failsafe activated >>--", 3)
					db.print(indent.."-- Try limiting your search depth:", 9)
					db.print(indent.."   /mass obj OBJECT |c000088FFdepthLimit|r\r\r", 10)
					break
				elseif k and v then
					vType = v:GetObjectType()
					if vType=="FontString" then
						db.print(indent..vType..": "..(v:GetName() or ("|c00AAAAAA"..target:GetName().."["..k.."]|r") or "no name"), 10)
					elseif vType=="Texture" then
						db.print(indent..vType..": "..(v:GetName() or ("|c00AAAAAA"..(target:GetName() or (tostring(target).."no name")).."["..k.."]|r") or "no name"), 4)
					else
						db.print(indent.."Unhandled type: "..v:GetName().."("..v:GetObjectType()..")", 9)
					end
				end
			end
		end
	else
		db.print((target or "No object entered.  This").." is not a frame or table.", 3)
	end
	db.ReportObject_nestDepth = db.ReportObject_nestDepth -1
	if db.ReportObject_nestDepth==0 or db.ReportObject_nestDepth<0 then
		db.ReportObject_TimeStamp, db.ReportObject_warned = nil, nil
		db.print("\r\r"..indent.."<< Report Complete >>", 9, false)
	end
end

function db.InvList()
	db.print("Player Inventory Index", 5, true)
	slot = {"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand", "Ranged", "Tabard", "Bag0", "Bag1", "Bag2", "Bag3"}
	local index, slotId, texture, checkRelic, itemLink, itemId = 1
	while slot[index] do
		slotId, texture, checkRelic = GetInventorySlotInfo(slot[index].."Slot")
		itemLink = GetInventoryItemLink("player", slotId)
		itemId = GetInventoryItemID("player", slotId)
		-- link:gsub("|", "||")
		if itemLink then
			db.print(slotId..": "..(itemLink or "nil").." ItemID="..(itemId or "nil"), 10)
		else
			db.print(slotId..": empty", 9)
		end
		index = index + 1
	end
end

function db.TableSort(a, b)
	if a<b then
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

function db.ScrollReport(self, state)
	db.physics.as = state
end

function db.OnEvent(self, event, ...)
	if not db.events[event] then
		db.events[event] = true
		table.sort(db.events, db.TableSort)
	end
	for k,v in pairs(db.RegisteredEvents) do
		if event==k then
			db[v](...)
			return
		end
	end
end

function db.ActionBlocked(...)
	local addon, offendingFunction = ... 
	db.print("Action Forbidden: "..addon.." called "..(offendingFunction or "."), 3)
end

function db.PlayerLogout()
	MassiveData.trackedVars = db.trackedVars
	MassiveData.events = db.events
end

function db.VariablesLoaded()
	MassiveData = MassiveData or {}
	if MassiveData.trackedVars then
		db.trackedVars = MassiveData.trackedVars
	end
	if MassiveData.events then
		for k, v in pairs(MassiveData.events) do
			if not db.events.k then
				db.events.k = true
			end
		end
		
	end
end

function db.OnUpdate(self, elapsed)
	--[[ KeyBinding Accelerator ]]--
	if MassiveRegion and MassiveRegion.toggle==true then
		MassiveRegion.interval = MassiveRegion.interval or 20
		MassiveRegion.pass = (MassiveRegion.pass or 5) + 1
		if MassiveRegion.pass >= MassiveRegion.interval then
			MassiveRegion.pass = 0
			if MassiveRegion.interval>=1 then
				MassiveRegion.interval = MassiveRegion.interval -1
			end
			Massive_moveShown(MassiveRegion.direction, MassiveRegion.toggle)
		end
	end


	db.ScrollInterval = db.ScrollInterval + elapsed
	if db.ScrollInterval >= 0.01 then
	
		--[[ Report Scolling ]]--
		local anmag, an = 0.2
		local dt = 25*db.ScrollInterval
		
		if math.abs(db.physics.v) < anmag*dt/2 then
			db.physics.v = 0
			an = 0
		else
			an = -(db.physics.v/math.abs(db.physics.v))*anmag
		end
		
		local a = db.physics.as + an
		db.physics.v = a * dt + db.physics.v
		
		if db.physics.v > 0 then
			for v=1, db.physics.v, 1 do
				MassiveReport:ScrollUp()
			end
		elseif db.physics.v < 0 then
			for v=1, math.abs(db.physics.v), 1 do
				MassiveReport:ScrollDown()
			end
		end
		db.physics.as = 0
		
		db.ScrollInterval = 0
	end
	
	db.UpdateInterval = db.UpdateInterval + elapsed
	if (db.UpdateInterval >= 0.1) then
		if db.trackedVars then
			MassiveTracker:Clear()
			for k,v in pairs(db.trackedVars) do
				local obj = db.GetObject(v)
				if not obj and GetCVar(v) then
					local absMax, absMin, Max, Min = GetCVarAbsoluteMax(v), GetCVarAbsoluteMin(v), GetCVarMax(v), GetCVarMin(v)
					obj = GetCVar(v).."\r(default: "..(GetCVarDefault(v) or "none").." | absMax:"..(absMax or "none").." | Max:"..(Max or "none").." | absMin:"..(absMin or "none").." | Min:"..(Min or "none")..")"
				end
				if type(obj)=="table" then
					MassiveTracker:AddMessage(v.." is a table and not a variable.", .65, .65, .65, 3)
				else
					if obj then
						MassiveTracker:AddMessage(k..": "..tostring(obj), .65, .65, .65, (id or 0))
					else
						MassiveTracker:AddMessage(k..": not a variable", .65, .65, .65, (id or 0))
					end
				end
			end
			if db.time then
				MassiveTracker:AddMessage(db.time)
			end
		end
		db.UpdateInterval = 0
	end
	
	db.SecondInterval = db.SecondInterval + elapsed
	if db.SecondInterval >= 1 then
		if db.second then
			local oldMinute = db.minute
			db.hour, db.minute = GetGameTime()
			db.second = db.second + math.floor(db.SecondInterval)
			if oldMinute~=db.minute and db.second~=0 then
				db.second = 0
			end
			if db.second > 60 then
				db.second = 1
			end
			db.time = "Time: "..db.hour..":"..db.minute..":"..db.second
		end
		db.SecondInterval = 0
	end
end

function db.listLayers()
	local frameStruct = {
		BACKGROUND = {"a", "b", "c"},
		LOW = {},
		MEDIUM = {},
		HIGH = {},
		DIALOG = {},
		FULLSCREEN = {},
		FULLSCREEN_DIALOG = {},
		TOOLTIP = {},	
		PARENT = {},
		WORLD = {}
	}

	local count = 0
	local frame = EnumerateFrames()
	while frame do
		count = count + 1
		if (go) then
			table.insert(dataTypes, frame:GetObjectType())
			table.insert(frameStruct[frame:GetFrameStrata()], (frame:GetFrameLevel() or "nil")..": "..(frame:GetName() or frame:GetID()) .. ":" .. frame:GetObjectType())
		end
		
		frame = EnumerateFrames(frame)
	end
	db.print("Completed "..count.." entries for ".. db.length(frameStruct))

	count = 0
	for i, t in pairs(frameStruct) do
		count = count + 1
		db.print(tostring(i).. " ¬")
		for k,v in pairs(t) do 
			db.print("    "..v)
		end
	end

	db.print("Completed "..count.." queries.")
end

function db.getParent()
	db.print(EnumerateFrames():GetParent())
end

function db.listRegions()
	local frameTypes = {
		Frame = true,
		Button = true,
		GameTooltip = true,
		StatusBar = true,
		DressUpModel = true,
		MessageFrame = true,
		EditBox = true,
		ScrollFrame = true,
		Slider = true,
		CheckButton = true,
		Cooldown = true,
		PlayerModel = true,
		Minimap = true,
		ScrollingMessageFrame = true,
		SimpleHTML = true,
		QuestPOIFrame = true,
		ArcheologyDigSiteFrame = true,
		ScenarioPOIFrame = true,
		TabardModel = true,
		Browser = true,
		ColorSelect = true,
		MovieFrame = true
	}

	local ignore = {
		["function"] = true,
		["string"] = true,
		["number"] = true,
		["boolean"] = true
	}

	--if not father then father = _G end

	local uncategorized = {}

	local i = 0
	for k, v in pairs(_G) do
		if ignore[type(v)] ~= true then
			-- if uncategorized[type(v)] ~= true then
			-- 	uncategorized[type(v)] = true
			-- end
			db.print(v:GetObjectType())
			-- if frameTypes[v:GetObjectType()] then
			-- 	db.print(i..(v:GetName() or v:GetID()))
			-- 	i = i + 1
			-- end
		end
	end

	db.print("Found the following additions:")
	for k, v in pairs(uncategorized) do
		db.print(k)
	end
end

function db.listing()
	-- local children = Minimap:GetChildren()
	-- for k, v in pairs(children) do 
	-- 	db.print(k .. ":" .. tostring(v) .. " (" .. type(v) .. ")")
	-- end

	local kids = { UIParent:GetChildren() };
	for k, v in ipairs(kids) do
		db.print(k .. ":" .. (v:GetName() or tostring(v)) .. ":" .. type(v))
	end
	-- local i = 1
	-- while i < length do
	-- 	local child = children[i]
	-- 	db.print(child:GetName())
	-- 	i = i + 1
	-- end

	-- local region = string.find(tostring(father.GetName or ""), "function", 1, true)
	-- if region and type(father)=="table" then
	-- 	if father.GetChildren then object = { father:GetChildren() } end
	-- end
end


function db.length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

db.VarInitialize()
db.CreateWindow("MassiveReport", 512, 256, true,"BOTTOM")
db.CreateEditBox("MassiveReport")
db.CreateWindow("MassiveTracker", 100, 50, false, "TOP", MassiveReport)
frame:SetScript("OnUpdate", db.OnUpdate)
frame:SetScript("OnEvent", db.OnEvent)

-- db.ReportObject(_G, 1)
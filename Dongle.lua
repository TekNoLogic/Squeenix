--[[-------------------------------------------------------------------------
  Copyright (c) 2006, Dongle Development Team
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of the Dongle Development Team nor the names of
        its contributors may be used to endorse or promote products derived
        from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]
local major = "DongleStub-Beta0"
local minor = tonumber(string.match("$Revision: 221 $", "(%d+)") or 1)

local g = getfenv(0)

if not g.DongleStub or g.DongleStub:IsNewerVersion(major, minor) then
	local lib = setmetatable({}, {
		__call = function(t,k) 
			if type(t.versions) == "table" and t.versions[k] then 
				return t.versions[k].instance
			else
				error("Cannot find a library with name '"..tostring(k).."'", 2)
			end
		end
	})

	function lib:IsNewerVersion(major, minor)
		local versionData = self.versions and self.versions[major]
		
		if not versionData then return true end
		local oldmajor,oldminor = versionData.instance:GetVersion()
		
		return minor > oldminor
	end
	
	local function NilCopyTable(src, dest)
		for k,v in pairs(dest) do dest[k] = nil end
		for k,v in pairs(src) do dest[k] = v end
	end

	function lib:Register(newInstance, activate, deactivate)
		local major,minor = newInstance:GetVersion()
		if not self:IsNewerVersion(major, minor) then return false end
		if not self.versions then self.versions = {} end

		local versionData = self.versions[major]
		if not versionData then
			-- New major version
			versionData = {
				["instance"] = newInstance,
				["deactivate"] = deactivate,
			}
			
			self.versions[major] = versionData
			if type(activate) == "function" then
				activate(newInstance)
			end
			return newInstance
		end
		
		local oldDeactivate = versionData.deactivate
		local oldInstance = versionData.instance
		
		versionData.deactivate = deactivate
		
		local skipCopy
		if type(activate) == "function" then
			 skipCopy = activate(newInstance, oldInstance)
		end

		-- Deactivate the old libary if necessary
		if type(oldDeactivate) == "function" then
			oldDeactivate(oldInstance, newInstance)
		end

		-- Re-use the old table, and discard the new one
		if not skipCopy then
			NilCopyTable(newInstance, oldInstance)
		end
		return oldInstance
	end

	function lib:GetVersion() return major,minor end

	local function Activate(new, old)
		if old then
			new.versions = old.versions
		end
		g.DongleStub = new
	end
	
	-- Actually trigger libary activation here
	local stub = g.DongleStub or lib
	stub:Register(lib, Activate)
end

--[[-------------------------------------------------------------------------
  Begin Library Implementation
---------------------------------------------------------------------------]]

local major = "Dongle-Beta0"
local minor = tonumber(string.match("$Revision: 235 $", "(%d+)") or 1)

assert(DongleStub, string.format("Dongle requires DongleStub.", major))
assert(DongleStub and DongleStub:GetVersion() == "DongleStub-Beta0", 
	string.format("Dongle requires DongleStub-Beta0.  You are using an older version.", major))

if not DongleStub:IsNewerVersion(major, minor) then return end

local Dongle = {}
local methods = {
	"RegisterEvent", "UnregisterEvent", "UnregisterAllEvents",
	"RegisterMessage", "UnregisterMessage", "UnregisterAllMessages", "TriggerMessage",
	"EnableDebug", "Print", "PrintF", "Debug", "DebugF",
	"InitializeDB",
	"InitializeSlashCommand",
	"NewModule", "HasModule", "IterateModules",
}

local registry = {}
local lookup = {}
local loadqueue = {}
local loadorder = {}
local events = {}
local databases = {}
local commands = {}
local messages = {}

local frame

local function assert(level,condition,message)
	if not condition then
		error(message,level)
	end
end

local function argcheck(value, num, ...)
	assert(1, type(num) == "number",
		"Bad argument #2 to 'argcheck' (number expected, got " .. type(level) .. ")")

	for i=1,select("#", ...) do
		if type(value) == select(i, ...) then return end
	end

	local types = strjoin(", ", ...)
	local name = string.match(debugstack(), "`argcheck'.-[`<](.-)['>]") or "Unknown"
	error(string.format("bad argument #%d to '%s' (%s expected, got %s)",
		num, name, types, type(value)), 3)
end

local function safecall(func,...)
	local success,err = pcall(func,...)
	if not success then
		geterrorhandler()(err)
	end
end

function Dongle:New(name, obj)
	argcheck(name, 2, "string")
	argcheck(obj, 3, "table", "nil")

	if not obj then
		obj = {}
	end

	if registry[name] then
		error("A Dongle with the name '"..name.."' is already registered.")
	end

	local reg = {["obj"] = obj, ["name"] = name}

	registry[name] = reg
	lookup[obj] = reg
	lookup[name] = reg

	for k,v in pairs(methods) do
		obj[v] = self[v]
	end

	-- Add this Dongle to the end of the queue
	table.insert(loadqueue, obj)
	return obj,name
end

function Dongle:NewModule(name, obj)
	local reg = lookup[self]
	assert(3, reg, "You must call 'NewModule' from a registered Dongle.")
	argcheck(name, 2, "string")
	argcheck(obj, 3, "table", "nil")

	obj,name = Dongle:New(name, obj)

	if not reg.modules then reg.modules = {} end
	reg.modules[obj] = obj
	reg.modules[name] = obj

	return obj,name
end

function Dongle:HasModule(module)
	local reg = lookup[self]
	assert(3, reg, "You must call 'HasModule' from a registered Dongle.")
	argcheck(module, 2, "string", "table")

	return reg.modules[module]
end

local function ModuleIterator(t, name)
	if not t then return end
	local obj
	repeat
		name,obj = next(t, name)
	until type(name) == "string" or not name
	
	return name,obj
end

function Dongle:IterateModules()
	local reg = lookup[self]
	assert(3, reg, "You must call 'IterateModules' from a registered Dongle.")

	return ModuleIterator, reg.modules
end

local function ADDON_LOADED(event, ...)
	for i=1, #loadqueue do
		local obj = loadqueue[i]
		table.insert(loadorder, obj)

		if type(obj.Initialize) == "function" then
			safecall(obj.Initialize, obj)
		end

		if Dongle.initialized and type(obj.Enable) == "function" then
			safecall(obj.Enable, obj)
		end
		loadqueue[i] = nil
	end
end

local function PLAYER_LOGOUT(event)
	self:ClearDBDefaults()
	for k,v in pairs(registry) do
		local obj = v.obj
		if type(obj["Disable"]) == "function" then 
			safecall(obj["Disable"], obj) 
		end
	end
end

local function PLAYER_LOGIN()
	Dongle.initialized = true
	for i,obj in ipairs(loadorder) do
		if type(obj.Enable) == "function" then
			safecall(obj.Enable, obj)
		end
	end
end

local function OnEvent(frame, event, ...)
	local eventTbl = events[event]
	if eventTbl then
		for obj,func in pairs(eventTbl) do
			if type(func) == "string" then
				if type(obj[func]) == "function" then
					safecall(obj[func], obj, event, ...)
				end
			else
				safecall(func, event, ...)
			end
		end
	end
end

function Dongle:RegisterEvent(event, func)
	local reg = lookup[self]
	assert(3, reg, "You must call 'RegisterEvent' from a registered Dongle.")
	argcheck(event, 2, "string")
	argcheck(func, 3, "string", "function", "nil")

	-- Name the method the same as the event if necessary
	if not func then func = event end

	if not events[event] then
		events[event] = {}
		frame:RegisterEvent(event)
	end
	events[event][self] = func
end

function Dongle:UnregisterEvent(event)
	local reg = lookup[self]
	assert(3, reg, "You must call 'UnregisterEvent' from a registered Dongle.")
	argcheck(event, 2, "string")

	if events[event] then
		events[event][self] = nil
		if not next(events[event]) then
			events[event] = nil
			frame:UnregisterEvent(event)
		end
	end
end

function Dongle:UnregisterAllEvents()
	assert(3, lookup[self], "You must call 'UnregisterAllEvents' from a registered Dongle.")

	for event,tbl in pairs(events) do
		tbl[self] = nil
		if not next(tbl) then
			events[event] = nil
			frame:UnregisterEvent(event)
		end
	end
end

function Dongle:RegisterMessage(msg, func)
	local reg = lookup[self]
	assert(3, reg, "You must call 'RegisterMessage' from a registered Dongle.")
	argcheck(msg, 2, "string")
	argcheck(func, 3, "string", "function", "nil")

	-- Name the method the same as the event if necessary
	if not func then func = msg end

	if not messages[msg] then
		messages[msg] = {}
	end
	messages[msg][self] = func
end

function Dongle:UnregisterMessage(msg)
	local reg = lookup[self]
	assert(3, reg, "You must call 'UnregisterMessage' from a registered Dongle.")
	argcheck(msg, 2, "string")

	local tbl = messages[msg]
	if tbl then
		tbl[self] = nil
		if not next(tbl) then
			messages[msg] = nil
		end
	end
end

function Dongle:UnregisterAllMessages()
	assert(3, lookup[self], "You must call 'UnregisterAllMessages' from a registered Dongle.")

	for msg,tbl in pairs(messages) do
		tbl[self] = nil
		if not next(tbl) then
			messages[msg] = nil
		end
	end
end

function Dongle:TriggerMessage(msg, ...)
	argcheck(msg, 2, "string")
	local msgTbl = messages[msg]
	if not msgTbl then return end

	for obj,func in pairs(msgTbl) do
		if type(func) == "string" then
			if type(obj[func]) == "function" then
				safecall(obj[func], obj, msg, ...) 
			end
		else
			safecall(func, msg, ...)
		end
	end
end

function Dongle:EnableDebug(level)
	local reg = lookup[self]
	assert(3, reg, "You must call 'EnableDebug' from a registered Dongle.")
	argcheck(level, 2, "number", "nil")

	reg.debugLevel = level
end

do
	local function argsToStrings(a1, ...)
		if select("#", ...) > 0 then
			return tostring(a1), argsToStrings(...)
		else
			return tostring(a1)
		end
	end

	local function printHelp(obj, method, msg, ...)
		local reg = lookup[obj]
		assert(4, reg, "You must call '"..method.."' from a registered Dongle.")

		local name = reg.name
		msg = "|cFF33FF99"..name.."|r: "..tostring(msg)
		if select("#", ...) > 0 then
			msg = string.join(", ", msg, argsToStrings(...))
		end

		ChatFrame1:AddMessage(msg)
	end

	local function printFHelp(obj, method, msg, ...)
		local reg = lookup[obj]
		assert(4, reg, "You must call '"..method.."' from a registered Dongle.")

		local name = reg.name
		local success,txt = pcall(string.format, "|cFF33FF99%s|r: "..msg, name, ...)
		if success then
			ChatFrame1:AddMessage(txt)
		else
			error(string.gsub(txt, "'%?'", string.format("'%s'", method)), 3)
		end
	end

	function Dongle:Print(...)
		return printHelp(self, "Print", ...)
	end

	function Dongle:PrintF(...)
		return printFHelp(self, "PrintF", ...)
	end

	function Dongle:Debug(level, ...)
		local reg = lookup[self]
		assert(3, reg, "You must call 'Debug' from a registered Dongle.")
		argcheck(level, 2, "number")

		if reg.debugLevel and level <= reg.debugLevel then
			printHelp(self, "Debug", ...)
		end
	end

	function Dongle:DebugF(level, ...)
		local reg = lookup[self]
		assert(3, reg, "You must call 'DebugF' from a registered Dongle.")
		argcheck(level, 2, "number")

		if reg.debugLevel and level <= reg.debugLevel then
			printFHelp(self, "DebugF", ...)
		end
	end
end

local dbMethods = {
	"RegisterDefaults", "SetProfile", "GetProfiles", "DeleteProfile", "CopyProfile",
	"ResetProfile", "ResetDB",
}

local function initdb(parent, name, defaults, defaultProfile, olddb)
	local sv = getglobal(name)

	if not sv then
		sv = {}
		setglobal(name, sv)

		-- Lets do the initial setup
        
		sv.char = {}
		sv.faction = {}
		sv.realm = {}
		sv.class = {}
		sv.global = {}
		sv.profiles = {}
	end

	-- Initialize the specific databases
	local char = string.format("%s of %s", UnitName("player"), GetRealmName())
	local realm = string.format("%s", GetRealmName())
	local class = UnitClass("player")
	local race = select(2, UnitRace("player"))
	local faction = UnitFactionGroup("player")

	-- Initialize the containers
	if not sv.char then sv.char = {} end
	if not sv.realm then sv.realm = {} end
	if not sv.class then sv.class = {} end
	if not sv.faction then sv.faction = {} end
	if not sv.global then sv.global = {} end
	if not sv.profiles then sv.profiles = {} end
	if not sv.profileKeys then sv.profileKeys = {} end

	-- Initialize this characters profiles
	if not sv.char[char] then sv.char[char] = {} end
	if not sv.realm[realm] then sv.realm[realm] = {} end
	if not sv.class[class] then sv.class[class] = {} end
	if not sv.faction[faction] then sv.faction[faction] = {} end

	-- Try to get the profile selected from the char db
	local profileKey = sv.profileKeys[char] or defaultProfile or char
	sv.profileKeys[char] = profileKey

	local profileCreated
    if not sv.profiles[profileKey] then sv.profiles[profileKey] = {} profileCreated = true end

	if olddb then
		for k,v in pairs(olddb) do olddb[k] = nil end
	end

	local db = olddb or {}
	db.char = sv.char[char]
	db.realm = sv.realm[realm]
	db.class = sv.class[class]
	db.faction = sv.faction[faction]
	db.profile = sv.profiles[profileKey]
	db.global = sv.global
	db.profiles = sv.profiles

	-- Copy methods locally
	for idx,method in pairs(dbMethods) do
		db[method] = Dongle[method]
	end

	-- Set some properties in the object we're returning
	db.sv = sv
	db.sv_name = name
	db.profileKey = profileKey
	db.parent = parent
	db.charKey = char
	db.realmKey = realm
	db.classKey = class
	db.factionKey = faction

	databases[db] = true

	if defaults then
		db:RegisterDefaults(defaults)
	end

	return db,profileCreated
end

function Dongle:InitializeDB(name, defaults, defaultProfile)
	local reg = lookup[self]
	assert(3, reg, "You must call 'InitializeDB' from a registered Dongle.")
	argcheck(name, 2, "string")
	argcheck(defaults, 3, "table", "nil")
	argcheck(defaultProfile, 4, "string", "nil")

	local db,profileCreated = initdb(self, name, defaults, defaultProfile)

	if profileCreated then
		Dongle:TriggerMessage("DONGLE_PROFILE_CREATED", db, self, db.sv_name, db.profileKey)	
	end
	return db
end

local function copyDefaults(dest, src, force)
	for k,v in pairs(src) do
		if type(v) == "table" then
			if not dest[k] then dest[k] = {} end
			copyDefaults(dest[k], v, force)
		else
			if (dest[k] == nil) or force then
				dest[k] = v
			end
		end
	end
end

-- This function operates on a Dongle DB object
function Dongle.RegisterDefaults(db, defaults)
	assert(3, databases[db], "You must call 'RegisterDefaults' from a Dongle database object.")
	argcheck(defaults, 2, "table")

	if defaults.char then copyDefaults(db.char, defaults.char) end
	if defaults.realm then copyDefaults(db.realm, defaults.realm) end
	if defaults.class then copyDefaults(db.class, defaults.class) end
	if defaults.faction then copyDefaults(db.faction, defaults.faction) end
	if defaults.global then copyDefaults(db.global, defaults.global) end
	if defaults.profile then copyDefaults(db.profile, defaults.profile) end

	db.defaults = defaults
end

local function removeDefaults(db, defaults)
	if not db then return end
	for k,v in pairs(defaults) do
		if type(v) == "table" and db[k] then
			removeDefaults(db[k], v)
			if not next(db[k]) then
				db[k] = nil
			end
		else
			if db[k] == defaults[k] then
				db[k] = nil
			end
		end
	end
end

function Dongle:ClearDBDefaults()
	for db in pairs(databases) do
		local defaults = db.defaults
		local sv = db.sv

		if db and defaults then
			if defaults.char then removeDefaults(db.char, defaults.char) end
			if defaults.realm then removeDefaults(db.realm, defaults.realm) end
			if defaults.class then removeDefaults(db.class, defaults.class) end
			if defaults.faction then removeDefaults(db.faction, defaults.faction) end
			if defaults.global then removeDefaults(db.global, defaults.global) end
			if defaults.profile then
				for k,v in pairs(sv.profiles) do
					removeDefaults(sv.profiles[k], defaults.profile)
				end
			end

			-- Remove any blank "profiles"
			if not next(db.char) then sv.char[db.charKey] = nil end
			if not next(db.realm) then sv.realm[db.realmKey] = nil end
			if not next(db.class) then sv.class[db.classKey] = nil end
			if not next(db.faction) then sv.faction[db.factionKey] = nil end
			if not next(db.global) then sv.global = nil end
		end
	end
end

function Dongle.SetProfile(db, name)
	assert(3, databases[db], "You must call 'SetProfile' from a Dongle database object.")
	argcheck(name, 2, "string")

	local sv = db.sv
	local old = sv.profiles[db.profileKey]
	local new = sv.profiles[name]
	local profileCreated
	
	if not new then
		sv.profiles[name] = {}
		new = sv.profiles[name]
		profileCreated = true
	end

	if db.defaults and db.defaults.profile then
		-- Remove the defaults from the old profile
		removeDefaults(old, db.defaults.profile)

		-- Inject the defaults into the new profile
		copyDefaults(new, db.defaults.profile)
	end

	db.profile = new

	-- Save this new profile name
	sv.profileKeys[db.charKey] = name
    db.profileKey = name

	if profileCreated then
		Dongle:TriggerMessage("DONGLE_PROFILE_CREATED", db, db.parent, db.sv_name, db.profileKey)	
	end
	
	Dongle:TriggerMessage("DONGLE_PROFILE_CHANGED", db, db.parent, db.sv_name, db.profileKey)
end

function Dongle.GetProfiles(db, t)
	assert(3, databases[db], "You must call 'GetProfiles' from a Dongle database object.")
	argcheck(t, 2, "table", "nil")

	t = t or {}
	local i = 1
	for profileKey in pairs(db.profiles) do
		t[i] = profileKey
		i = i + 1
	end
	return t, i - 1
end

function Dongle.DeleteProfile(db, name)
	assert(3, databases[db], "You must call 'DeleteProfile' from a Dongle database object.")
	argcheck(name, 2, "string")

	if db.profileKey == name then
		error("You cannot delete your active profile.  Change profiles, then attempt to delete.", 2)
	end

	db.sv.profiles[name] = nil
	Dongle:TriggerMessage("DONGLE_PROFILE_DELETED", db, db.parent, db.sv_name, name)
end

function Dongle.CopyProfile(db, name)
	assert(3, databases[db], "You must call 'CopyProfile' from a Dongle database object.")
	argcheck(name, 2, "string")

	assert(3, db.profileKey ~= name, "Source/Destination profile cannot be the same profile")
	assert(3, type(db.sv.profiles[name]) == "table", "Profile \""..name.."\" doesn't exist.")

	local profile = db.profile
	local source = db.sv.profiles[name]

	copyDefaults(profile, source, true)
	Dongle:TriggerMessage("DONGLE_PROFILE_COPIED", db, db.parent, db.sv_name, name, db.profileKey)
end

function Dongle.ResetProfile(db)
	assert(3, databases[db], "You must call 'ResetProfile' from a Dongle database object.")

	local profile = db.profile

	for k,v in pairs(profile) do
		profile[k] = nil
	end
	if db.defaults and db.defaults.profile then
		copyDefaults(profile, db.defaults.profile)
	end
	Dongle:TriggerMessage("DONGLE_PROFILE_RESET", db, db.parent, db.sv_name, db.profileKey)
end


function Dongle.ResetDB(db, defaultProfile)
	assert(3, databases[db], "You must call 'ResetDB' from a Dongle database object.")
    argcheck(defaultProfile, 2, "nil", "string")

	local sv = db.sv
	for k,v in pairs(sv) do
		sv[k] = nil
	end
	
	local parent = db.parent

	initdb(parent, db.sv_name, db.defaults, defaultProfile, db)
	Dongle:TriggerMessage("DONGLE_DATABASE_RESET", db, parent, db.sv_name, db.profileKey)
	Dongle:TriggerMessage("DONGLE_PROFILE_CREATED", db, db.parent, db.sv_name, db.profileKey)
	Dongle:TriggerMessage("DONGLE_PROFILE_CHANGED", db, db.parent, db.sv_name, db.profileKey)
	return db
end

local slashCmdMethods = {
	"RegisterSlashHandler",
	"PrintUsage",
}

local function OnSlashCommand(cmd, cmd_line)
	if cmd.patterns then
		for pattern, tbl in pairs(cmd.patterns) do
			if string.match(cmd_line, pattern) then
				if type(tbl.handler) == "string" then
					cmd.parent[tbl.handler](cmd.parent, string.match(cmd_line, pattern))
				else
					tbl.handler(string.match(cmd_line, pattern))
				end
				return
			end
		end
	end
	cmd:PrintUsage()
end

function Dongle:InitializeSlashCommand(desc, name, ...)
	local reg = lookup[self]
	assert(3, reg, "You must call 'InitializeSlashCommand' from a registered Dongle.")
	argcheck(desc, 2, "string")
	argcheck(name, 3, "string")
	argcheck(select(1, ...), 4, "string")
	for i = 2,select("#", ...) do
		argcheck(select(i, ...), i+2, "string")
	end
	
	local cmd = {}
	cmd.desc = desc
	cmd.name = name
	cmd.parent = self
	cmd.slashes = { ... }
	for idx,method in pairs(slashCmdMethods) do
		cmd[method] = Dongle[method]
	end
	
	local genv = getfenv(0)

	for i = 1,select("#", ...) do
		genv["SLASH_"..name..tostring(i)] = "/"..select(i, ...)
	end

	genv.SlashCmdList[name] = function(...) OnSlashCommand(cmd, ...) end

	commands[cmd] = true

	return cmd
end

function Dongle.RegisterSlashHandler(cmd, desc, pattern, handler)
	assert(3, commands[cmd], "You must call 'RegisterSlashHandler' from a Dongle slash command object.")

	argcheck(desc, 2, "string")
	argcheck(pattern, 3, "string")
	argcheck(handler, 4, "function", "string")

	if not cmd.patterns then
		cmd.patterns = {}
	end
	cmd.patterns[pattern] = {
		["desc"] = desc,
		["handler"] = handler,
	}
end

function Dongle.PrintUsage(cmd)
	assert(3, commands[cmd], "You must call 'PrintUsage' from a Dongle slash command object.")

	local usage = cmd.desc.."\n".."/"..table.concat(cmd.slashes, ", /")..":\n"
	if cmd.patterns then
		local descs = {}
		for pattern,tbl in pairs(cmd.patterns) do
			table.insert(descs, tbl.desc)
		end
		table.sort(descs)
		for _,desc in pairs(descs) do
			usage = usage.." - "..desc.."\n"
		end
	end
	cmd.parent:Print(usage)
end

--[[-------------------------------------------------------------------------
  Begin DongleStub required functions and registration
---------------------------------------------------------------------------]]

function Dongle:GetVersion() return major,minor end

local function Activate(self, old)
	if old then
		self.registry = old.registry or registry
		self.lookup = old.lookup or lookup
		self.loadqueue = old.loadqueue or loadqueue
		self.loadorder = old.loadorder or loadorder
		self.events = old.events or events
		self.databases = old.databases or databases
		self.commands = old.commands or commands
		self.messages = old.messages or messages

		registry = self.registry
		lookup = self.lookup
		loadqueue = self.loadqueue
		loadorder = self.loadorder
		events = self.events
		databases = self.databases
		commands = self.commands
		messages = self.messages

		frame = old.frame

		local reg = self.registry[major]
		reg.obj = self
		lookup[self] = reg
		lookup[major] = reg
	else
		self.registry = registry
		self.lookup = lookup
		self.loadqueue = loadqueue
		self.loadorder = loadorder
		self.events = events
		self.databases = databases
		self.commands = commands
		self.messages = messages

		local reg = {obj = self, name = "Dongle"}
		registry[major] = reg
		lookup[self] = reg
		lookup[major] = reg
	end

	if not frame then
		frame = CreateFrame("Frame")
	end

	self.frame = frame
	frame:SetScript("OnEvent", OnEvent)

	-- Register for events using Dongle itself
	self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	self:RegisterEvent("PLAYER_LOGIN", PLAYER_LOGIN)
	self:RegisterEvent("PLAYER_LOGOUT", PLAYER_LOGOUT)

	-- Convert all the modules handles
	for name,obj in pairs(registry) do
		for k,v in ipairs(methods) do
			obj[k] = self[v]
		end
	end

	-- Convert all database methods
	for db in pairs(databases) do
		for idx,method in ipairs(dbMethods) do
			db[method] = self[method]
		end
	end
	
	-- Convert all slash command methods
	for cmd in pairs(commands) do
		for idx,method in ipairs(slashCmdMethods) do
			cmd[method] = self[method]
		end
	end
end

local function Deactivate(self, new)
	self:UnregisterAllEvents()
	lookup[self] = nil
end

DongleStub:Register(Dongle, Activate, Deactivate)

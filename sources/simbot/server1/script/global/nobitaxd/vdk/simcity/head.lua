IncludeLib("FILESYS")
IncludeLib("TITLE")
IncludeLib("ITEM")
IncludeLib("NPCINFO")
IncludeLib("TIMER")
IncludeLib("SETTING")
IncludeLib("TASKSYS")
IncludeLib("PARTNER")
IncludeLib("BATTLE")
IncludeLib("RELAYLADDER")
IncludeLib("TONG")
IncludeLib("LEAGUE")

Include("\\script\\lib\\remoteexc.lua")
Include("\\script\\lib\\common.lua")
Include("\\script\\lib\\string.lua")
Include("\\script\\lib\\log.lua")
Include("\\script\\lib\\awardtemplet.lua")
--Include("\\script\\lib\\droptemplet.lua")

Include("\\script\\activitysys\\playerfunlib.lua")
Include("\\script\\misc\\eventsys\\type\\npc.lua")
Include("\\script\\dailogsys\\dailogsay.lua")
Include("\\script\\activitysys\\functionlib.lua")
Include("\\script\\activitysys\\npcdailog.lua")
Include("\\script\\global\\titlefuncs.lua")
Include("\\script\\lib\\string.lua")


-- Common Helpers
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\config.lua")

-- Nap he so gia shop BOT vao vdk.so.
-- Ma lenh 1000+N duoc vdk.so V4 xu ly rieng, khong sua tier/item cua BOT.
if SetBotStallTier and BOT_STALL_PRICE_MULTIPLIER then
    SetBotStallTier(0, 1000 + BOT_STALL_PRICE_MULTIPLIER, 1)
end
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\libs\\index.lua")

-- Plugins first
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\plugins\\index.lua")

-- Data load
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\libs\\data.lua")

-- Now main class
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\class\\sim_theosau.lua")
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\class\\sim_citizen.lua")

-- Kick start all plugins if needed
SimCityNgoaiTrang:init()
SimCityNPCInfo:init()

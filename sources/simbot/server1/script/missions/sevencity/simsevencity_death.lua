-- ================================================================
-- Death script cho SimCity bot cua That Thanh Dai Chien
-- ================================================================

Include("\\script\\missions\\sevencity\\war.lua")
Include("\\script\\missions\\sevencity\\simsevencity.lua")
--Include("\\script\\msgkiller\\msgkiller.lua")

-- Helper: extract bang name only tu full NPC name.
-- Input  : "Bang AnhEm-[De Tu]" / "Bang AnhEm-[Truong Lao]" / "Bang AnhEm"
-- Output : "AnhEm"
-- Lua 4.x: khong co string.match/gsub, chi dung string.find + string.sub.
function extractBangNameOnly(npcName)
	if (not npcName or npcName == "") then return "NPC" end
	local result = npcName
	
	-- Step 1: bo prefix "Bang " neu co (5 ky tu)
	if (strsub(result, 1, 5) == "Bang ") then
		result = strsub(result, 6)   -- "Bang AnhEm-[De Tu]" -> "AnhEm-[De Tu]"
	end
	
	-- Step 2: cat truoc dau "-[" neu co (rank suffix)
	local pos = strfind(result, "-[", 1, 1)   -- 1=plain text search (khong regex)
	if (pos and pos > 1) then
		result = strsub(result, 1, pos - 1)   -- "AnhEm-[De Tu]" -> "AnhEm"
	end
	
	return result
end

function OnDeath(nDeadNpcIdx)
	-- 1. Thong bao cho SimThatThanh de schedule respawn
	if (SimThatThanh and SimThatThanh.OnBotDeath) then
		SimThatThanh:OnBotDeath(nDeadNpcIdx)
	else
		print(format("[SIMSC]Death: npc(%d) but SimThatThanh/OnBotDeath missing!", nDeadNpcIdx))
	end
	
	-- 2. Hien msgkiller giua man khi bot bi player giet
	--if (PlayerIndex and PlayerIndex > 0 and add_msgkiller_pk) then
	--	local player = Player:New(PlayerIndex)
	--	local mapid = player:GetWorldPos()
	--	local field = BattleWorld:FindField(mapid)
	--	if (field ~= nil) then
			-- Lay full name roi extract chi tang ten bang (vd "AnhEm")
		--	local fullName = GetNpcName(nDeadNpcIdx) or "NPC"
		--	local victimName = extractBangNameOnly(fullName)
		--	local killerName = player:GetName() or "?"
			--local msg = "  <pic=123><color=cyan>B¹n ®· ®¸nh b¹i ®­îc ng­êi cña <color=yellow>Bang "..victimName.."<color><pic=123>"
			--add_msgkiller_pk(PlayerIndex, msg)
		--end
	--end
end
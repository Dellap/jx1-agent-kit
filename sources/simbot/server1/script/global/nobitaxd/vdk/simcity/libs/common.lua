IncludeLib("NPCINFO")
if not GetNpcAroundNpcList then
    function GetNpcAroundNpcList(nNpcIndex, nRadius)
        return {}, 0
    end
end

-- Helpers
function GetTabFileData(path, tab_name, start_row, max_col) -- Doc file txt
    if TabFile_Load(path, tab_name) ~= 1 then
        return {}, 0
    end
    if not start_row or start_row < 1 then start_row = 1 end
    if not max_col or max_col < 1 then max_col = 1 end
    local nCount = TabFile_GetRowCount(tab_name)
    local tbData = {}
    for y = start_row, nCount do
        local tbTemp = {}
        for x = 1, max_col do tinsert(tbTemp, TabFile_GetCell(tab_name, y, x)) end
        tinsert(tbData, tbTemp)
    end
    return tbData, nCount - start_row + 1
end

isChinese = { "<", ">", "ª¹", "³", "newboss", "²", "´", "åâ", "£¨", "¼ý", "ýË", "¼þ", "¼þ", "£", "º", "±", "¡", "»", "ÙÁ",
    "±", "··", "ÈË" }
function fixName(inp)
    local found = false
    for i = 1, getn(isChinese) do
        if strfind(inp, isChinese[i]) ~= nil then
            return "Qu¸i kh¸ch"
        end
    end
    return inp
end

function GetDistanceRadius(nX, nY, oX, oY)
    return sqrt((nX - oX) * (nX - oX) + (nY - oY) * (nY - oY))
end

function arrFlip(arr)
    local newFlipArr = {}
    local N = getn(arr)
    for i = 1, N do
        tinsert(newFlipArr, arr[N - i + 1])
    end
    return newFlipArr
end

function arrCopy(arr)
    local newFlipArr = {}
    local N = getn(arr)
    for i = 1, N do
        if type(arr[i]) == 'table' then
            tinsert(newFlipArr, arrCopy(arr[i]))
        else
            tinsert(newFlipArr, arr[i])
        end
    end
    return newFlipArr
end

function arrJoin(arr)
    local output = {}
    for i = 1, getn(arr) do
        for j = 1, getn(arr[i]) do
            tinsert(output, arr[i][j])
        end
    end
    return output
end

function objCopy(obj)
    local output = {}
    if obj then
        for k, v in obj do
            output[k] = v
        end
    end
    return output
end

function spawnN(arr, linh, N, config)
    N = N or 16
    for i = 1, N do
        local child = objCopy(config)
        child.nNpcId = linh
        tinsert(arr, child)
    end
    return arr
end

function DelNpcSafe(nNpcIndex)
    if (not nNpcIndex) or (nNpcIndex <= 0) then
        return
    end

    PIdx = NpcIdx2PIdx(nNpcIndex)
    if (PIdx > 0) then
        return
    end
    DelNpc(nNpcIndex)
end

function IsAttackableCamp(camp1, camp2)
    if (camp1 ~= camp2) then
        if camp1 == 0 and camp2 == 5 then
            return 1
        end

        if camp2 == 0 and camp1 == 5 then
            return 1
        end
        if camp1 ~= 0 and camp2 ~= 0 then
            return 1
        end
    end
    return 0
end

function KhoaTHP(nOwnerIndex, flag)
    if nOwnerIndex > 0 then
        CallPlayerFunction(nOwnerIndex, DisabledUseTownP, flag)
        CallPlayerFunction(nOwnerIndex, DisabledUseHeart, flag)
    end
end

function IsNearStation(pId)
    local fighterList = CallPlayerFunction(pId, GetAroundNpcList, 30)
    local nNpcIdx
    for i = 1, getn(fighterList) do
        nNpcIdx = fighterList[i]
        local kind = GetNpcKind(nNpcIdx)
        local nSettingIdx = GetNpcSettingIdx(nNpcIdx)
        if kind == 3 and (nSettingIdx == 239 or nSettingIdx == 236 or nSettingIdx == 237 or nSettingIdx == 238) then
            return 1
        end
    end

    return 0
end

function arrRandomExtracItems(arr, n)
    if getn(arr) < n then
        return arr
    end

    local startIndex = random(1, getn(arr) - n + 1)
    local result = {}

    for i = startIndex, startIndex + n - 1 do
        tinsert(result, arr[i])
    end

    return result
end


function SimCityTableFromFile(strFilePatch, tbPattern)	
	if (TabFile_Load(strFilePatch, strFilePatch) == 0) then
		print("Load TabFile Error!"..strFilePatch)
		return nil
	else
		local tbResult = {}
		local nRowCount = TabFile_GetRowCount(strFilePatch)
        
		for i = 2, nRowCount do
			tbResult[i-1] = {}
			for j = 1, getn(tbPattern) do
				local tmp = nil
				if tbPattern[j] == "*n" then
                    local cell = TabFile_GetCell(strFilePatch, i, j)
                    if cell == nil or cell == "" then
                        tmp = 0
                    else
                        tmp = tonumber(cell)
                    end
				elseif tbPattern[j] == "*w" then
                    local cell = TabFile_GetCell(strFilePatch, i, j)
                    if cell == nil or cell == "" then
                        tmp = ""
                    else
                        tmp = tostring(cell)
                    end
				end
				tinsert(tbResult[i-1], tmp)
			end
		end
		return tbResult
	end
end

function getObjectKeys(tbl)
    local result = {}
    for k,v in tbl do
        tinsert(result, k)
    end
    return result
end

function _sortByScore(tb1, tb2)
	return tb1[2] > tb2[2]
end


function getClosestNode(nodes, nX, nY)
    local minDist1 = 200
    local closestNode1 = nil

    for nodeName, coords in nodes do
        local dist = GetDistanceRadius(nX, nY, coords[1], coords[2])
        if dist < minDist1 then
            minDist1 = dist
            closestNode1 = nodeName
        end
    end
    return closestNode1
end


function nodeNameToCoords(nodeName)
    local point = split(nodeName, "_")
    local x = tonumber(point[1])
    local y = tonumber(point[2])
    return x, y
end

function getNodeInfoByNodeName(tbNpc, nodeName)
    if nodeName == nil then   
        local fn = tbNpc.worldInfo and tbNpc.worldInfo.firstNode
        if fn then return { x = fn[1], y = fn[2], isNearAtraction = 0, linkedNodes = {} } end
        return { x = 0, y = 0, isNearAtraction = 0, linkedNodes = {} }
    end
    if tbNpc.worldInfo.nodes[nodeName] then        
        return tbNpc.worldInfo.nodes[nodeName]
    end
    local x, y = nodeNameToCoords(nodeName)
    return {
        x = x,
        y = y,
        isNearAtraction = 0,
        linkedNodes = {},
        isNearAtraction = 0,
        
    }
end


function faction2DisplayName(faction)
    local tbSay = {}
    if faction == 1 then
        return "Thiªn V­¬ng Bang"
    elseif faction == 2 then
        return "ThiÕu L©m"
    elseif faction == 3 then
        return "Vâ §ang"
    elseif faction == 4 then
        return "C«n L«n"
    elseif faction == 5 then
        return "§­êng M«n"
    elseif faction == 6 then
        return "Ngò §éc"
    elseif faction == 7 then
        return "Nga Mi"
    elseif faction == 8 then
        return "Thóy Yªn"
    elseif faction == 9 then
        return "C¸i Bang"
    elseif faction == 10 then
        return "Thiªn NhÉn"
    end
end


function faction2Key(phai)
	local tenPhai = "thienvuong"
    if phai == 2 then
		tenPhai = "thieulam"
	elseif phai == 3 then
		tenPhai = "vodang"
	elseif phai == 4 then
		tenPhai = "conlon"
	elseif phai == 5 then
		tenPhai = "duongmon"
	elseif phai == 6 then
		tenPhai = "ngudoc"
	elseif phai == 7 then
		tenPhai = "ngami"
	elseif phai == 8 then
		tenPhai = "thuyyen"
	elseif phai == 9 then
		tenPhai = "caibang"
	elseif phai == 10 then
		tenPhai = "thiennhan"				
	end
	return tenPhai
end

function factionKey2Idx(key)
    if key == "thienvuong" then
        return 1
    elseif key == "thieulam" then
        return 2
    elseif key == "vodang" then
        return 3
    elseif key == "conlon" then
        return 4
    elseif key == "duongmon" then
        return 5
    elseif key == "ngudoc" then
        return 6
    elseif key == "ngami" then
        return 7
    elseif key == "thuyyen" then
        return 8
    elseif key == "caibang" then
        return 9
    elseif key == "thiennhan" then
        return 10
    end
end

SIMCITY_CITY_RADIUS = 70   

function SimCityIsInCity(worldInfo, cellX, cellY)
    if not worldInfo.attractions then return 1 end   
    local atts = worldInfo.attractions
    local n = getn(atts)
    if n == 0 then return 1 end
    local r = worldInfo.cityRect   
    if r then
        if cellX >= r[1] and cellY >= r[2] and cellX <= r[3] and cellY <= r[4] then return 1 end
        return 0
    end
    for i = 1, n do
        local a = atts[i]
        if GetDistanceRadius(cellX, cellY, a[1], a[2]) < SIMCITY_CITY_RADIUS then return 1 end
    end
    return 0
end

SIMBOT_NOFIGHT_MAPS = SIMBOT_NOFIGHT_MAPS or { [323]=1, [324]=1, [325]=1 }

function SimCityCanFight(tbNpc)
    local wi = tbNpc.worldInfo
    if not wi then return 0 end   
    if SIMBOT_NOFIGHT_MAPS and tbNpc.nMapId and SIMBOT_NOFIGHT_MAPS[tbNpc.nMapId] then return 0 end  
    if wi.cityPeace == 1 and tbNpc.finalIndex and tbNpc.finalIndex > 0 then
        local nX32, nY32, nMap = GetNpcPos(tbNpc.finalIndex)
        if SimCityIsInCity(wi, nX32 / 32, nY32 / 32) == 1 then return 0 end  
    end
    local _pe = tbNpc.isPlayerEnemyAround
    local _peCD = _pe and _pe > 0 and (not GetPlayerPkMode or not PIdx2NpcIdx or GetPlayerPkMode(PIdx2NpcIdx(_pe)) ~= 0)
    if tbNpc.mode ~= "train" and not (tbNpc.tongkim == 1 and tbNpc.worldInfo and tbNpc.worldInfo.tkWarStarted == 1) and not _peCD and not tbNpc.duelPlayerId then return 0 end  
    if tbNpc.selfDefTick and tbNpc.tick_breath and tbNpc.selfDefTick > tbNpc.tick_breath then return 1 end
    if tbNpc.tongkim == 1 and tbNpc.worldInfo and tbNpc.worldInfo.tkWarStarted ~= 1 then return 0 end  
    if wi.cityPeace == 1 then return 1 end                                   
    if wi.allowFighting == 1 then return 1 end  
    return 0
end

function SimCityIsPeaceZone(tbNpc)
    local wi = tbNpc.worldInfo
    if not wi then return 0 end
    if SIMBOT_NOFIGHT_MAPS and tbNpc.nMapId and SIMBOT_NOFIGHT_MAPS[tbNpc.nMapId] then return 1 end   
    if wi.cityPeace == 1 and tbNpc.finalIndex and tbNpc.finalIndex > 0 then
        local nX32, nY32 = GetNpcPos(tbNpc.finalIndex)
        if SimCityIsInCity(wi, nX32 / 32, nY32 / 32) == 1 then return 1 end   
    end
    return 0   
end

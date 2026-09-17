SimCityNgoaiTrang = {}

SimCityNgoaiTrang.ALLTRANGBI_DATA = {
	ao = {
		nam = {},
		nam_count = 0,
		nu = {},
		nu_count = 0,
	},
	non = {
		nam = {},
		nam_count = 0,
		nu = {},
		nu_count = 0,
	},
	vukhi = {
		nam = {},
		nam_count = 0,
		nu = {},
		nu_count = 0,
	},
	ngua = {
		nam = {},
		nam_count = 0,
		nu = {},
		nu_count = 0,
	}
}

SimCityNgoaiTrang.found = 0

function SimCityNgoaiTrang:init()
	if TabFile_Load and GetTabFileData and self.found == 0 then
		local toLoadData = {
			{
				"\\settings\\npcres_simple\\����������.txt",
				self.ALLTRANGBI_DATA.ao.nam,
				self.ALLTRANGBI_DATA.ao.nam_count
			},
			{
				"\\settings\\npcres_simple\\Ů��������.txt",
				self.ALLTRANGBI_DATA.ao.nu,
				self.ALLTRANGBI_DATA.ao.nu_count
			},
			{
				"\\settings\\npcres_simple\\������ͷ��.txt",
				self.ALLTRANGBI_DATA.non.nam,
				self.ALLTRANGBI_DATA.non.nam_count
			},
			{
				"\\settings\\npcres_simple\\Ů����ͷ��.txt",
				self.ALLTRANGBI_DATA.non.nu,
				self.ALLTRANGBI_DATA.non.nu_count
			},
			{
				"\\settings\\npcres_simple\\������δ����������.txt",
				self.ALLTRANGBI_DATA.vukhi.nam,
				self.ALLTRANGBI_DATA.vukhi.nam_count
			},
			{
				"\\settings\\npcres_simple\\Ů����δ����������.txt",
				self.ALLTRANGBI_DATA.vukhi.nu,
				self.ALLTRANGBI_DATA.vukhi.nu_count
			},
			{
				"\\settings\\npcres_simple\\����������.txt",
				self.ALLTRANGBI_DATA.ngua.nam,
				self.ALLTRANGBI_DATA.ngua.nam_count,
				1
			},
			{
				"\\settings\\npcres_simple\\Ů��������.txt",
				self.ALLTRANGBI_DATA.ngua.nu,
				self.ALLTRANGBI_DATA.ngua.nu_count,
				1
			}
		}

		for j = 1, getn(toLoadData) do
			local info = toLoadData[j]

			local tbData, nCount = GetTabFileData(info[1], "temp" .. j, 2, 4)
			for i = 1, nCount do
				local name = tbData[i][2]
				if info[4] or (name and name ~= "") then
					tinsert(info[2], i)
				end
			end

			info[3] = getn(info[2])
		end

		self.found = 1
	end
end

SimCityNgoaiTrang.used = {}

-- BLACKLIST index ngoai trang THIEU res (mat dau/than/vk/ngua). makeup se TRANH cac index nay.
-- Key: <objectName>_<gioitinh>. nam = charType -1, nu = -2.
-- VD: non_nam = {5, 12} = index DAU (head) nam bi loi -> bot se ko lay nua.
SimCityNgoaiTrang.BLACKLIST = {
	non_nam = {22,23,28}, non_nu = {22,23,28},     -- dau (head / helm)
	ao_nam = {18,38}, ao_nu = {18,38,54},       -- than (body / armor). 18=ao mac dinh (bo), 38=ban phi phong cua 18
	vukhi_nam = {}, vukhi_nu = {}, -- vu khi (weapon)
	ngua_nam = {}, ngua_nu = {},   -- ngua (horse)
}

-- chi dung cac id ngua nay (user loc qua test_res_item.lua)
SimCityNgoaiTrang.HORSE_WL = {0,1,2,5,9,10,11,12}

-- bot chi mac 13 trang phuc (6 nu + 7 nam), random ban thuong/cape (res cao = co phi phong).
SimCityNgoaiTrang.ARMOR_WL_NU  = {8,14,19,20,29,35,40,41}
SimCityNgoaiTrang.ARMOR_WL_NAM = {2,8,11,14,20,23,29,32,35,41}
SimCityNgoaiTrang.HELM_WL = {2,5,8,11,14,17,20}
function SimCityNgoaiTrang:pickHelm()
	return self.HELM_WL[random(1, getn(self.HELM_WL))]
end
SimCityNgoaiTrang.WEAPON_WL = {20,23,24,26,28,30}
function SimCityNgoaiTrang:pickWeapon()
	return self.WEAPON_WL[random(1, getn(self.WEAPON_WL))]
end
function SimCityNgoaiTrang:pickArmor(charType, faction)
	if faction == "caibang" then local _f = {17,38}; return _f[random(1, 2)] end
	if faction == "vodang" or faction == "conlon" then local _f = {5,26}; return _f[random(1, 2)] end
	local _wl = (charType == -2) and self.ARMOR_WL_NU or self.ARMOR_WL_NAM
	return _wl[random(1, getn(_wl))]
end

function SimCityNgoaiTrang:makeup(config, nNpcIndex)
	if config.series == 0 then config.nSettingsIdx = -1 elseif config.series == 2 then config.nSettingsIdx = -2 end  
	config.nSettingsIdx = config.nSettingsIdx or random(-2, -1)
	config.nNewHelmType = config.nNewHelmType or self:pickHelm()
	config.nNewArmorType = config.nNewArmorType or self:pickArmor(config.nSettingsIdx, config.faction)
	config.nNewWeaponType = config.nNewWeaponType or self:pickWeapon()
	config.nNewHorseType = config.nNewHorseType or self.HORSE_WL[random(1, getn(self.HORSE_WL))]

	ChangeNpcFeature(nNpcIndex, 0, 0, config.nSettingsIdx, config.nNewHelmType, config.nNewArmorType,
		config.nNewWeaponType,
		config.nNewHorseType)

	if SetNpcRideHorse then SetNpcRideHorse(nNpcIndex, 1) end
end

function SimCityNgoaiTrang:getData(charType, objectName)
	local target = {}
	if objectName == "non" then
		target = self.ALLTRANGBI_DATA.non
	end
	if objectName == "ao" then
		target = self.ALLTRANGBI_DATA.ao
	end
	if objectName == "vukhi" then
		target = self.ALLTRANGBI_DATA.vukhi
	end
	if objectName == "ngua" then
		target = self.ALLTRANGBI_DATA.ngua
	end


	local collection = {}
	if charType == -1 then
		collection = target.nam
	elseif charType == -2 then
		collection = target.nu
	else
		return nil
	end

	local N = getn(collection)
	if N > 0 then
		local gkey = objectName .. ((charType == -1) and "_nam" or "_nu")
		local bl = self.BLACKLIST[gkey] or {}
		local bln = getn(bl)
		for try = 1, 30 do
			local idx = collection[random(1, N)]
			idx = tonumber(idx) or 0
			local bad = nil
			if objectName == "ao" then if idx >= 42 then bad = 1 end end
			if objectName == "ngua" then if idx > 11 then bad = 1 end end
			if objectName == "vukhi" then if idx > 32 then bad = 1 end end
			for k = 1, bln do
				if tonumber(bl[k]) == idx then bad = 1 end
			end
			if not bad then return idx end
		end
		return tonumber(collection[random(1, N)]) or 1
	end
	return nil
end


function SimCityNgoaiTrang:doRandom(forceGender)
	local sIdx = forceGender or random(-2, -1)  
	return {
		nSettingsIdx   = sIdx,
		nNewHelmType   = self:pickHelm(),
		nNewArmorType  = self:pickArmor(sIdx),
		nNewWeaponType = self:pickWeapon(),
		nNewHorseType  = self.HORSE_WL[random(1, getn(self.HORSE_WL))],
	}
end

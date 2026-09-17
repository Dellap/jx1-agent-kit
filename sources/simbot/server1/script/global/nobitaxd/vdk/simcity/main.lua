Include("\\script\\global\\nobitaxd\\vdk\\simcity\\head.lua")
--Include("\\script\\global\\nobitaxd\\vdk\\simcity\\controllers\\thanhthi.lua")
function main()
	SimCityThanhThi:mainMenu()
	return 1
end

-- Main loop
function mainLoop()
    SimCitizen:ATick()
	SimTheoSau:ATick()
	--SimCityKeoXe:ATick()
    AddTimer(REFRESH_RATE, "mainLoop", SimCitizen)
    -- SimCitizen:FastCastTick()   -- [2026-06-27 TAT: fast-cast + SetNpcFightTarget ghi de target engine-AI moi 0.7s -> pha bot-vs-bot da chay hom qua. Tra ve engine-AI tu nhien.
end 

function worldLoop()
	SimCityWorld:ATick(20)
    AddTimer(REFRESH_RATE*3, "worldLoop", SimCityWorld)
end 

AddTimer(REFRESH_RATE, "mainLoop", SimCitizen)
AddTimer(REFRESH_RATE*3, "worldLoop", SimCityWorld)

-- [2026-06-27] fast-cast goi tu mainLoop (xem ham mainLoop) -> bo timer rieng (ko on dinh)
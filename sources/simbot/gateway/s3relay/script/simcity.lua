Include("\\script\\mission\\sevencity\\war.lua")

--------------------------------------------------------------------

function Mo_TongKim(level)
	
	if level == 1 then
		zMsg2SubWorld  = "<color=0xa9ffe0>Chi’n tr≠Íng TËng - Kim <color=yellow>S¨ c p<color>  Æ∑ Æ’n giÍ b∏o danh, thÍi gian b∏o danh lµ 5 phÛt.."
		Battle_StartNewRound(1, level );
	elseif level == 2 then
		zMsg2SubWorld  = "<color=0xa9ffe0>Chi’n tr≠Íng TËng - Kim <color=yellow>Trung c p c p<color>  Æ∑ Æ’n giÍ b∏o danh, thÍi gian b∏o danh lµ 5 phÛt."
		Battle_StartNewRound(1, level );
	elseif level == 3 then
		zMsg2SubWorld  = "<color=0xa9ffe0>Chi’n tr≠Íng TËng - Kim <color=yellow>Cao c p<color>  Æ∑ Æ’n giÍ b∏o danh, thÍi gian b∏o danh lµ 5 phÛt."
		Battle_StartNewRound(1, level );
	end
	if level >=1 and level <=3 then
		GlobalExecute(format("dw Msg2SubWorld([[%s]])",zMsg2SubWorld))
	--GlobalExecute(format("dw AddLocalCountNews([[%s]], 1)",zMsg2SubWorld))
	end
end

function Mo_PhongHoaLienThanh(loai, phe)
	if (phe == 2) then
		OutputMsg("'V÷ quËc li™n thµnh'   phe Kim Æ∑ bæt Æ«u b∏o danh.");

		if loai == 1 then 
			GlobalExecute("dw CityDefence_OpenMain(2)");
		else
			GlobalExecute("dw NewCityDefence_OpenMain(2)");
		end
	else
		OutputMsg("'V÷ quËc li™n thµnh'   TËng Æ∑ bæt Æ«u b∏o danh.");
		if loai == 1 then 
			GlobalExecute("dw CityDefence_OpenMain(1)");
		else
			GlobalExecute("dw NewCityDefence_OpenMain(1)");
		end
	end
end
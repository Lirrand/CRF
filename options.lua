local _G = getfenv(0)

SLASH_CRF1 = '/crf'
SlashCmdList['CRF'] = function(msg)
	local chat = nil

	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = GetChatWindowInfo(i)
		if name == 'CRF' then
			chat = _G['ChatFrame' .. i]
			FCF_SelectDockFrame(chat)
			break
		end
	end

	if not chat then
		FCF_OpenNewWindow('CRF')
		chat = _G['ChatFrame' .. FCF_GetNumActiveChatFrames()]
		ChatFrame_RemoveAllMessageGroups(chat)
	end

	local args = {}
	local i = 1
	for arg in string.gfind(string.lower(msg), "%S+") do
		args[i] = arg
		i = i + 1
	end

	if args[1] == 'border' then
		CRF_Settings['frame_border'] = not CRF_Settings['frame_border']

		chat:AddMessage("Group frame border set to " .. (CRF_Settings['frame_border'] and "visible" or "hidden") .. ".")
	elseif args[1] == 'power' then
		CRF_Settings['unit_power'] = not CRF_Settings['unit_power']

		chat:AddMessage("Unit powerbar set to " .. (CRF_Settings['unit_power'] and "visible" or "hidden") .. ".")
	elseif args[1] == 'class' then
		CRF_Settings['unit_colors'] = not CRF_Settings['unit_colors']

		chat:AddMessage("Unit healthbar class colors set to " .. (CRF_Settings['unit_colors'] and "enabled" or "disabled") .. ".")
   elseif args[1] == 'aura'then
		if args[2] == 'size' then
			if args[3] and type(tonumber(args[3])) == 'number' then
				local size = tonumber(args[3])
				if size < (CRF_Settings['unit_height'] - 4) then
					CRF_Settings['aura_size'] = size

					chat:AddMessage("Unitframe aura size set to " .. size .. ".")
				else
					chat:AddMessage("Unitframe aura size exceeds unitframe height.")
				end
			end
		end
	elseif args[1] == 'size' then
      if (args[2] and type(tonumber(args[2])) == 'number') and (args[3] and type(tonumber(args[3])) == 'number') then
         local width = tonumber(args[2])
         local height = tonumber(args[3])
         if (width >= 64 and width <= 128) and (height >= 42 and height <= 64) then
            CRF_Settings['unit_width'] = tonumber(width)
            CRF_Settings['unit_height'] = tonumber(height)

            chat:AddMessage("Unitframe width and height set to " .. width .. " and " .. height .. ".")
         end
      end
	else
		chat:Clear()
		chat:AddMessage("/crf border - toggle group frame border visibility")
		chat:AddMessage("/crf power - toggle unit powerbar visibility")
		chat:AddMessage("/crf class - toggle class-colored healthbars")
		chat:AddMessage("/crf aura size [number] - set unitframe auras size")
		chat:AddMessage("/crf size [width] [height] - set unitframe width and height")
	end

	CRF_UpdateLookAndFeel()
end
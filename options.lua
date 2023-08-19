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

		chat:AddMessage("|cffcececeGroup frame border set to " .. (CRF_Settings['frame_border'] and "|cffffffffvisible" or "|cffffffffhidden") .. "|cffcecece.")
	elseif args[1] == 'power' then
		CRF_Settings['unit_power'] = not CRF_Settings['unit_power']

		chat:AddMessage("|cffcececeUnitframe powerbars set to " .. (CRF_Settings['unit_power'] and "|cffffffffvisible" or "|cffffffffhidden") .. "|cffcecece.")
	elseif args[1] == 'class' then
		CRF_Settings['unit_colors'] = not CRF_Settings['unit_colors']

		chat:AddMessage("|cffcececeUnitframe class-colored healthbars " .. (CRF_Settings['unit_colors'] and "|cffffffffenabled" or "|cffffffffdisabled") .. "|cffcecece.")
   elseif args[1] == 'aura'then
		if args[2] == 'size' then
			if args[3] and type(tonumber(args[3])) == 'number' then
				local size = tonumber(args[3])
				if size < (CRF_Settings['unit_height'] - 4) then
					CRF_Settings['aura_size'] = size

					chat:AddMessage("|cffcececeUnitframe aura size set to |cffffffff" .. size .. "|cffcecece.")
				else
					chat:AddMessage("|cffcececeSpecified aura size exceeds unitframe height.")
				end
			end
		end
	elseif args[1] == 'size' then
      if (args[2] and type(tonumber(args[2])) == 'number') and (args[3] and type(tonumber(args[3])) == 'number') then
         local width = tonumber(args[2])
         local height = tonumber(args[3])
         if width >= 64 and width <= 128 then
				if height >= 36 and height <= 64 then
					CRF_Settings['unit_width'] = tonumber(width)
					CRF_Settings['unit_height'] = tonumber(height)

					chat:AddMessage("|cffcececeUnitframe width and height set to |cffffffff" .. width .. " |cffcececeand |cffffffff" .. height .. "|cffcecece.")
				else
					chat:AddMessage("|cffcececeSpecified height is too small (min. 36px) or too large (max. 64px).")
				end
			else
				chat:AddMessage("|cffcececeSpecified width is too small (min. 64px) or too large (max. 128px).")
			end
      end
	elseif args[1] == 'reset' then
		CRF_Settings = {
			['frame_border'] = true,
			['unit_power'] = true,
			['unit_colors'] = true,
			['unit_width'] = 64,
			['unit_height'] = 42,
			['aura_size'] = 16
	  }
	else
		chat:Clear()

		chat:AddMessage("Compact Raid Frames")
		chat:AddMessage("")
		chat:AddMessage("|cff808080/crf |cffffffffborder |cffcecece- toggle group frame border visibility")
		chat:AddMessage("|cff808080/crf |cffffffffpower |cffcecece- toggle unit powerbar visibility")
		chat:AddMessage("|cff808080/crf |cffffffffclass |cffcecece- toggle class-colored healthbars")
		chat:AddMessage("|cff808080/crf |cffffffffaura size [number] |cffcecece- set unitframe auras size")
		chat:AddMessage("|cff808080/crf |cffffffffsize [width] [height] |cffcecece- set unitframe width and height")
		chat:AddMessage("|cff808080/crf |cffffffffsize reset |cffcecece- reset addon settings")
		chat:AddMessage("")
	end

	CRF_UpdateLookAndFeel()
end
local _G = getfenv(0)

function CRF_Init()
	local group = _G['CompactGroupFrame']
	
	if group then
		local SHOW_PLAYER = CRF_Settings['show_player'] and 1 or 0
		
		group:SetScale(CRF_Settings['frame_scale'])

		if not CRF_Settings['frame_border'] then
			local textures = {
				'TopLeftTexture',
				'TopRightTexture',
				'TopMiddleTexture',
				'BottomLeftTexture',
				'BottomRightTexture',
				'BottomMiddleTexture',
				'LeftTexture',
				'RightTexture'
			}

			for _, v in pairs(textures) do
				local texture = _G['CompactGroupFrame' .. v]
				if texture then
					texture:Hide()
				end
			end
		end
		
		for i = 1, MAX_PARTY_MEMBERS do
			local unit = _G['PartyMemberFrame' .. i]
			unit:Hide()
			unit:UnregisterAllEvents()
			unit.Show = function() return end
		end
		
		for i = 1, MAX_PARTY_MEMBERS + SHOW_PLAYER do
			local unit = CreateFrame('Frame', "CompactUnitFrame" .. i, group, "CompactUnitFrameTemplate")
			unit:Hide()
			unit:SetID(i - SHOW_PLAYER)
			unit:SetPoint('TOP', group, 0, -((i - 1) * unit:GetHeight() + 6))
			
			if CRF_Settings['unit_health'] then
				local health = _G[unit:GetName() .. 'HealthBarText']
				health:Show()
			end
			
			if CRF_Settings['unit_power'] then
				local healthbar = _G[unit:GetName() .. 'HealthBar']
				healthbar:ClearAllPoints()
				healthbar:SetPoint('TOPLEFT', unit)
				healthbar:SetPoint('BOTTOMRIGHT', unit, 0, 10)
				
				local indicator = _G[unit:GetName() .. 'DebuffIndicator']
				indicator:SetPoint('BOTTOMRIGHT', unit, -6, 10)
			end
		end
	end
end

function CRF_UpdateFrames()
	local group = _G['CompactGroupFrame']
	
	if group then		
		local SHOW_PLAYER = CRF_Settings['show_player'] and 1 or 0
		
		if GetNumPartyMembers() + SHOW_PLAYER > 0 then
			group:Show()
			group:SetHeight((GetNumPartyMembers() + SHOW_PLAYER) * 50 + 14)
		else
			group:Hide()
			return
		end
		
		for i = 1, MAX_PARTY_MEMBERS + SHOW_PLAYER do
			local unit = _G['CompactUnitFrame' .. i]
			unit:SetWidth(group:GetWidth() - 14)
			
			local member = nil
			
			if SHOW_PLAYER == i then
				member = 'player'
			else
				if GetPartyMember(i - SHOW_PLAYER) then
					member = 'party' .. i - SHOW_PLAYER
				else
					unit:Hide()
				end
			end
			
			if member then
				unit:Show()
				unit.unit = member

				CRF_UpdateMemberFrame(unit)
			end
		end
	end
end

function CRF_UpdateMemberFrame(frame)
	if frame and frame.unit then
		local member = frame.unit
		local name = _G[frame:GetName() .. 'NameText']
		local healthbar = _G[frame:GetName() .. 'HealthBar']
		local health = _G[frame:GetName() .. 'HealthBarText']
		local powerbar = _G[frame:GetName() .. 'PowerBar']
		
		name:SetText(UnitName(member))
				
		if not UnitIsConnected(member) then
			healthbar:SetMinMaxValues(0, 1)
			healthbar:SetValue(1)
			healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			
			if CRF_Settings['unit_health'] and health:IsVisible() then
				health:SetText("Offline")
				health:Show()
			end

			if CRF_Settings['unit_power'] then
				powerbar:SetStatusBarColor(0.6, 0.6, 0.6)
				powerbar:SetMinMaxValues(0, 1)
				powerbar:SetValue(1)
				powerbar:Show()
			end
		else
			healthbar:SetMinMaxValues(0, UnitHealthMax(member))
			healthbar:SetValue(UnitHealth(member))
			
			if CRF_Settings['unit_colors'] then
				local _, class = UnitClass(member)
				local color = RAID_CLASS_COLORS[class]
				healthbar:SetStatusBarColor(color.r, color.g, color.b)
			end
			
			if CRF_Settings['unit_health'] and health:IsVisible() then
				health:SetText(format('%.0f%%', (UnitHealth(member) / UnitHealthMax(member)) * 100))
				health:Show()
			end
			
			if CRF_Settings['unit_power'] then
				local color = ManaBarColor[UnitPowerType(member)]
				powerbar:SetStatusBarColor(color.r, color.g, color.b)
				powerbar:SetBackdropColor(color.r - 0.6, color.g - 0.6, color.b - 0.6, 0.8)
				powerbar:SetMinMaxValues(0, UnitManaMax(member))
				powerbar:SetValue(UnitMana(member))
				powerbar:Show()
			end
		end
	end
end

function CRF_UpdateMemberFrameIndicator(frame)
	if frame and frame.unit then
		local indicator = _G[frame:GetName() .. 'DebuffIndicator']
		if indicator:GetTexture() then
			indicator:Hide()
		end
		
		for i = 1, 40 do
			local _, _, type = UnitDebuff(frame.unit, i)
			if type then
				indicator:Show()
				indicator:SetTexture('Interface\\AddOns\\CRF\\assets\\UnitFrame-Debuff' .. type)
			end
		end
	end
end

SLASH_CRF1 = '/crf'
SlashCmdList['CRF'] = function(msg)
	local args = {}
	local i = 1
	for arg in string.gfind(string.lower(msg), "%S+") do
		args[i] = arg
		i = i + 1
	end
	
	if not args[1] then
		DEFAULT_CHAT_FRAME:AddMessage("/crf scale [number] - set group frame scale")
		DEFAULT_CHAT_FRAME:AddMessage("/crf border - toggle group border visibility")
		DEFAULT_CHAT_FRAME:AddMessage("/crf player - toggle player visibility in group frame")
		DEFAULT_CHAT_FRAME:AddMessage("/crf class - toggle healthbar color based on class")
		DEFAULT_CHAT_FRAME:AddMessage("/crf health - toggle health percentage text visibility")
		DEFAULT_CHAT_FRAME:AddMessage("/crf power - toggle unit powerbar visibility")
		DEFAULT_CHAT_FRAME:AddMessage("")
		DEFAULT_CHAT_FRAME:AddMessage("Any changes will be applied after you reload your interface.")
		
	elseif args[1] == 'scale' then
		if args[2] and type(tonumber(args[2])) == 'number' then
			CRF_Settings['frame_scale'] = tonumber(args[2])
			
			DEFAULT_CHAT_FRAME:AddMessage("Group frame scale set to " .. args[2] .. ".")
		end

	elseif args[1] == 'border' then
		CRF_Settings['frame_border'] = not CRF_Settings['frame_border']
		
		DEFAULT_CHAT_FRAME:AddMessage("Group frame border set to " .. (CRF_Settings['frame_border'] and "visible" or "hidden") .. ".")
		
	elseif args[1] == 'player' then
		CRF_Settings['show_player'] = not CRF_Settings['show_player']
		
		DEFAULT_CHAT_FRAME:AddMessage("Player visibility in group set to " ..
		(CRF_Settings['show_player'] and "visible" or "hidden") .. ".")
		
	elseif args[1] == 'class' then
		CRF_Settings['unit_colors'] = not CRF_Settings['unit_colors']
		
		DEFAULT_CHAT_FRAME:AddMessage("Unit healthbar class colors set to " ..
		(CRF_Settings['unit_colors'] and "enabled" or "disabled") .. ".")
		
	elseif args[1] == 'health' then
		CRF_Settings['unit_health'] = not CRF_Settings['unit_health']
		
		DEFAULT_CHAT_FRAME:AddMessage("Unit health percentage text set to " ..
		(CRF_Settings['unit_health'] and "enabled" or "disabled") .. ".")
		
	elseif args[1] == 'power' then
		CRF_Settings['unit_power'] = not CRF_Settings['unit_power']
		
		DEFAULT_CHAT_FRAME:AddMessage(
		"Unit powerbar set to " .. (CRF_Settings['unit_power'] and "visible" or "hidden") .. ".")
	end
end
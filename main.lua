local _G = getfenv(0)

function CRF_Init()
	local group = _G['CompactGroupFrame']

	if group then
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
			local frame = _G['PartyMemberFrame' .. i]
			frame:Hide()
			frame:UnregisterAllEvents()
			frame.Show = function() return end
		end
		
		for i = 1, MAX_PARTY_MEMBERS + 1 do
			local frame = _G['CompactUnitFrame' .. i]
			frame:Hide()
			frame:SetID(i - 1)
			frame:SetPoint('TOP', group, 0, -((i - 1) * frame:GetHeight() + 6))
			
			if CRF_Settings['unit_health'] then
				local health = _G[frame:GetName() .. 'HealthBarText']
				frame:Show()
			end
			
			if CRF_Settings['unit_power'] then
				local healthbar = _G[frame:GetName() .. 'HealthBar']
				healthbar:SetPoint('TOPLEFT', frame)
				healthbar:SetPoint('BOTTOMRIGHT', frame, 0, 10)
				
				local indicator = _G[frame:GetName() .. 'DebuffIndicator']
				indicator:SetPoint('BOTTOMRIGHT', frame, -6, 10)
			end
		end

		group.ready = true
	end
end

function CRF_UpdateFrames()
	local group = _G['CompactGroupFrame']
	
	if group then		
		if GetNumPartyMembers() > 0 then
			group:Show()
			group:SetHeight((GetNumPartyMembers() + 1) * 50 + 14)
		else
			group:Hide()
			return
		end
		
		for i = 1, MAX_PARTY_MEMBERS + 1 do
			local frame = _G['CompactUnitFrame' .. i]
			frame:SetWidth(group:GetWidth() - 14)
			
			local member = nil
			
			if i == 1 then
				member = 'player'
			else
				if GetPartyMember(i - 1) then
					member = 'party' .. i - 1
				else
					frame:Hide()
				end
			end
			
			if member then
				frame:Show()
				frame.unit = member

				CRF_UpdateMemberFrame(frame)
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
				local color = RAID_CLASS_COLORS[class] or { r = 0.0, g = 1.0, b = 0.0 }
				healthbar:SetStatusBarColor(color.r, color.g, color.b)
			end
			
			if CRF_Settings['unit_health'] and health:IsVisible() then
				health:SetText(format('%.0f%%', (UnitHealth(member) / UnitHealthMax(member)) * 100))
				health:Show()
			end
			
			if CRF_Settings['unit_power'] then
				local color = ManaBarColor[UnitPowerType(member)] or { r = 0.0, g = 0.0, b = 1.0 }
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
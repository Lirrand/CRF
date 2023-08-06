local _G = getfenv(0)

local classBuffs = {
	druid = {
		'Interface\\Icons\\Spell_Nature_Regeneration', 								-- Mark/Gift of the Wild
		'Interface\\Icons\\Spell_Nature_Thorns',										-- Thorns
		'Interface\\Icons\\Spell_Nature_Moonglow',									-- Moonkin Aura
		'Interface\\Icons\\Spell_Mature_UnyeildingStamina',						-- Leader of the Pack
	},
	hunter = {
		'Interface\\Icons\\Spell_Nature_ProtectionformNature',					-- Aspect of the Wild
		'Interface\\Icons\\Ability_Trueshot',											-- Trueshot Aura
		'Interface\\Icons\\Ability_Hunter_Pet_Wolf',									-- Furious Howl (Wolf pet)
	},
	mage = {
		'Interface\\Icons\\Spell_Holy_MagicalSentry',								-- Arcane Intellect
		'Interface\\Icons\\Spell_Holy_ArcaneIntellect',								-- Arcane Brilliance
		'Interface\\Icons\\Spell_Nature_AbolishMagic',								-- Dampen Magic
		'Interface\\Icons\\Spell_Holy_FlashHeal',										-- Amplify Magic
	},
	paladin = {
		'Interface\\Icons\\Spell_Holy_FistOfJustice',								-- Blessing of Might
		'Interface\\Icons\\Spell_Holy_SealOfWisdom',									-- Blessing of Wisdom
		'Interface\\Icons\\Spell_Holy_SealOfSalvation',								-- Blessing of Salvation
		'Interface\\Icons\\Spell_Holy_PrayerOfHealing02',							-- Blessing of Light
		'Interface\\Icons\\Spell_Holy_SealOfValor',									-- Blessing of Freedom
		'Interface\\Icons\\Spell_Holy_SealOfProtection',							-- Blessing of Protection
		'Interface\\Icons\\Spell_Nature_LightningShield',							-- Blessing of Sanctuary
		'Interface\\Icons\\Spell_Magic_MageArmor',									-- Blessing of Kings
		'Interface\\Icons\\Spell_Holy_GreaterBlessingofKings',					-- Greater Blessing of Might
		'Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom',					-- Greater Blessing of Wisdom
		'Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation',				-- Greater Blessing of Salvation
		'Interface\\Icons\\Spell_Holy_GreaterBlessingofLight',					-- Greater Blessing of Light
		'Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary',				-- Greater Blessing of Sanctuary
		'Interface\\Icons\\Spell_Magic_GreaterBlessingofKings',					-- Greater Blessing of Kings
		'Interface\\Icons\\Spell_Holy_DevotionAura',									-- Devotion Aura
		'Interface\\Icons\\Spell_Holy_AuraOfLight',									-- Retribution Aura
		'Interface\\Icons\\Spell_Holy_MindSooth',										-- Concentration Aura
		'Interface\\Icons\\Spell_Shadow_SealOfKings',								-- Shadow Resistance Aura
		'Interface\\Icons\\Spell_Holy_MindVision',									-- Sanctity Aura
		'Interface\\Icons\\Spell_Frost_WizardMark',									-- Frost Resistance Aura
		'Interface\\Icons\\Spell_Fire_SealOfFire',									-- Fire Resistance Aura
	},
	priest = {
		'Interface\\Icons\\Spell_Holy_WordFortitude',								-- Power Word: Fortitude
		'Interface\\Icons\\Spell_Holy_DivineSpirit',									-- Divine Spirit
		'Interface\\Icons\\Spell_Shadow_AntiShadow',									-- Shadow Protection
		'Interface\\Icons\\Spell_Holy_Excorcism',										-- Fear Ward
		'Interface\\Icons\\Spell_Holy_PrayerOfFortitude',							-- Prayer of Fortitude
		'Interface\\Icons\\Spell_Holy_PrayerofSpirit',								-- Prayer of Spirit
		'Interface\\Icons\\Spell_Holy_PrayerofShadowProtection',					-- Prayer of Shadow Protection
	},
	warlock = {
		'Interface\\Icons\\Spell_Shadow_BloodBoil',									-- Blood Pact
	},
	warrior = {
		'Interface\\Icons\\Ability_Warrior_BattleShout',							-- Battle Shout
	}
}

function CRF_Init()
	local group = _G['CompactGroupFrame']

	if group then
		if not CRF_Settings['frame_border'] then
			group:SetBackdrop(nil)
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
			frame:SetPoint('TOP', group, 0, -((i - 1) * frame:GetHeight() + 4))

			if CRF_Settings['unit_health'] then
				local health = _G[frame:GetName() .. 'HealthBarText']
				frame:Show()
			end

			if CRF_Settings['unit_power'] then
				local healthbar = _G[frame:GetName() .. 'HealthBar']
				healthbar:SetHeight(38)
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
			group:SetHeight((GetNumPartyMembers() + 1) * 42 + 8)
		else
			group:Hide()
			return
		end

		for i = 1, MAX_PARTY_MEMBERS + 1 do
			local frame = _G['CompactUnitFrame' .. i]
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
				CRF_UpdateMemberFrameAuras(frame)
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

			CRF_OnHeal(member, nil)
		end
	end
end

function CRF_UpdateMemberFrameAuras(frame)
	if frame and frame.unit then
		for i = 1, 4 do
			local button = _G[frame:GetName() .. 'AuraButton' .. i]
			button:Hide()
			button.type = nil
			button.index = nil

			local texture = _G[button:GetName() .. 'Texture']
			texture:SetTexture(nil)
		end

		local index = 1
		while UnitDebuff(frame.unit, index) do
			local debuff, _, type = UnitDebuff(frame.unit, index)
			if type then
				local button = CRF_GetFreeAuraButton(frame, true)
				if not button then return end

				local texture = _G[button:GetName() .. 'Texture']
				debuff = string.gsub(debuff, '/', '\\')

				button:Show()
				if type == 'Curse' then
					button:SetBackdropColor(0.6, 0.0, 1.0, 1.0)
				elseif type == 'Disease' then
					button:SetBackdropColor(0.6, 0.4, 0.0, 1.0)
				elseif type == 'Magic' then
					button:SetBackdropColor(0.2, 0.6, 1.0, 1.0)
				elseif type == 'Poison' then
					button:SetBackdropColor(0.0, 0.6, 0.0, 1.0)
				else
					button:SetBackdropColor(0.8, 0.0, 0.0, 1.0)
				end
				button.type = 'debuff'
				button.index = index

				texture:SetTexture(debuff)
			end

			index = index + 1
		end

		index = 1
		while UnitBuff(frame.unit, index) do
			local button = CRF_GetFreeAuraButton(frame, false)
			if not button then return end

			local buff = string.gsub(UnitBuff(frame.unit, index), '/', '\\')
			local _, class = UnitClass('player')

			for _, classBuff in ipairs(classBuffs[string.lower(class)]) do
				if buff == classBuff then
					local texture = _G[button:GetName() .. 'Texture']

					button:Show()
					button:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
					button.type = 'buff'
					button.index = index

					texture:SetTexture(buff)
				end
			end

			index = index + 1
		end
	end
end

function CRF_GetFreeAuraButton(frame, reverse)
	if reverse then
		for i = 4, 1, -1 do
			local button = _G[frame:GetName() .. 'AuraButton' .. i]
			local texture = _G[button:GetName() .. 'Texture']
			if not texture:GetTexture() or (texture:GetTexture() and button.type == 'buff') then
				return button
			end
		end
	else
		for i = 1, 4 do
			local button = _G[frame:GetName() .. 'AuraButton' .. i]
			local texture = _G[button:GetName() .. 'Texture']
			if not texture:GetTexture() then
				return button
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
		DEFAULT_CHAT_FRAME:AddMessage("/crf border - toggle group border visibility")
		DEFAULT_CHAT_FRAME:AddMessage("/crf class - toggle healthbar color based on class")
		DEFAULT_CHAT_FRAME:AddMessage("/crf health - toggle health percentage text visibility")
		DEFAULT_CHAT_FRAME:AddMessage("/crf power - toggle unit powerbar visibility")
		DEFAULT_CHAT_FRAME:AddMessage("")
		DEFAULT_CHAT_FRAME:AddMessage("Any changes will be applied after you reload your interface.")

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
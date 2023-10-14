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

function CRF_UpdateFrames()
	local group = _G['CompactGroupFrame']
	local party = _G['CompactPartyFrame']
	local isInRaid = UnitInRaid("player")
	local height, width = CRF_Settings['unit_height'], CRF_Settings['unit_width']
	CRF_UpdateLookAndFeel()

	if group then
		if isInRaid then
			party:Hide()
			group:Show()

			local highestSubGroupNumber = 0
			local highestSubGroupSize = 0

			for i = 1, 8 do
				local raidGroup = _G['CompactRaidFrame'..i]
		
				if RAID_SUBGROUP_LISTS and RAID_SUBGROUP_LISTS[i] then
					local highestFrameNumber = 0
					for frameNumber, raidNumber in pairs(RAID_SUBGROUP_LISTS[i]) do
						local frame = _G[raidGroup:GetName() .. 'UnitFrame' .. frameNumber]
						frame:SetID(raidNumber)
						frame.unit = 'raid'..raidNumber
						frame:Show()

						CRF_SetUnitFrameAppearance(frame, frameNumber, raidGroup)
						CRF_UpdateMemberFrameAuras(frame)

						if highestFrameNumber < frameNumber then
							highestFrameNumber = frameNumber
						end
					end
					if highestFrameNumber > 0 then
						raidGroup:SetPoint('TOPLEFT', group, (width + 8) * (i - 1), 0)
						raidGroup:Show()
						highestSubGroupNumber = i
					else
						raidGroup:Hide()
					end
					for j = highestFrameNumber + 1, MAX_PARTY_MEMBERS + 1 do
						local frame = _G[raidGroup:GetName() .. 'UnitFrame' .. j]
						frame:Hide()
					end
					if highestSubGroupSize < highestFrameNumber then
						highestSubGroupSize = highestFrameNumber
					end
				else
					raidGroup:Hide()
				end
			end
			group:SetHeight(highestSubGroupSize * height + 8)
			group:SetWidth((width + 8) * highestSubGroupNumber)
		else
			party:Show()
			for i = 1, 8 do
				local raidGroup = _G['CompactRaidFrame'..i]
				raidGroup:Hide()
			end
			if GetNumPartyMembers() > 0 then
				group:Show()
				group:SetHeight((GetNumPartyMembers() + 1) * CRF_Settings['unit_height'] + 8)
				group:SetWidth(CRF_Settings['unit_width'] + 8)
			else
				group:Hide()
				return
			end
	
			for i = 1, MAX_PARTY_MEMBERS + 1 do
				local frame = _G['CompactPartyFrameUnitFrame' .. i]
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
					frame:SetID(i - 1)
					frame.unit = member
	
					CRF_UpdateMemberFrame(frame)
					CRF_UpdateMemberFrameAuras(frame)
				end
			end
		end
	end
end

function CRF_UpdateMemberFrame(frame)
	if frame and frame.unit then
		local member = frame.unit
		local name = _G[frame:GetName() .. 'NameText']
		local healthbar = _G[frame:GetName() .. 'HealthBar']
		local powerbar = _G[frame:GetName() .. 'PowerBar']

		name:SetText(UnitName(member))

		if UnitIsConnected(member) then
			healthbar:SetMinMaxValues(0, UnitHealthMax(member))
			healthbar:SetValue(UnitHealth(member))

			if CRF_Settings['unit_colors'] then
				local _, class = UnitClass(member)
				local color = RAID_CLASS_COLORS[class] or { r = 0.0, g = 1.0, b = 0.0 }
				healthbar:SetStatusBarColor(color.r, color.g, color.b)
			end

			if CRF_Settings['unit_power'] then
				local color = ManaBarColor[UnitPowerType(member)] or { r = 0.0, g = 0.0, b = 1.0 }
				powerbar:SetStatusBarColor(color.r, color.g, color.b)
				powerbar:SetBackdropColor(color.r - 0.6, color.g - 0.6, color.b - 0.6, 0.8)
				powerbar:SetMinMaxValues(0, UnitManaMax(member))
				powerbar:SetValue(UnitMana(member))
			end

			CRF_OnHeal(member, frame)
		else
			healthbar:SetMinMaxValues(0, 1)
			healthbar:SetValue(1)
			healthbar:SetStatusBarColor(0.5, 0.5, 0.5)

			if CRF_Settings['unit_power'] then
				powerbar:SetStatusBarColor(0.6, 0.6, 0.6)
				powerbar:SetMinMaxValues(0, 1)
				powerbar:SetValue(1)
			end
		end
	end
end

function CRF_UpdateMemberFrameAuras(frame)
	if frame and frame.unit then
		for i = 1, 8 do
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
	local max = floor(CRF_Settings['unit_width'] / CRF_Settings['aura_size'])

	if reverse then
		for i = max, 1, -1 do
			local button = _G[frame:GetName() .. 'AuraButton' .. i]
			local texture = _G[button:GetName() .. 'Texture']
			if not texture:GetTexture() or (texture:GetTexture() and button.type == 'buff') then
				return button
			end
		end
	else
		for i = 1, max do
			local button = _G[frame:GetName() .. 'AuraButton' .. i]
			local texture = _G[button:GetName() .. 'Texture']
			if not texture:GetTexture() then
				return button
			end
		end
	end
end

function CRF_SetUnitFrameAppearance(frame, frameNumber, parentFrame)
	local healthbar = _G[frame:GetName() .. 'HealthBar']
	local powerbar = _G[frame:GetName() .. 'PowerBar']

	local height, width = CRF_Settings['unit_height'], CRF_Settings['unit_width']

	frame:SetPoint('TOP', parentFrame, 0, -((frameNumber - 1) * height + 4))
	frame:SetHeight(height)
	frame:SetWidth(width)

	healthbar:SetWidth(width)

	if CRF_Settings['unit_power'] then
		healthbar:SetHeight(height - 4)

		powerbar:Show()
		powerbar:SetWidth(width)
	else
		healthbar:SetHeight(height)

		powerbar:Hide()
	end

	if CRF_Settings['unit_colors'] then
		CRF_UpdateMemberFrame(frame)
	else
		healthbar:SetStatusBarColor(0.0, 1.0, 0.0)
	end

	local size = CRF_Settings['aura_size']
	for i = 1, 8 do
		local button = _G[frame:GetName() .. 'AuraButton' .. i]
		button:SetHeight(size)
		button:SetWidth(size)

		if i ~= 1 then
			button:SetPoint('LEFT', _G[frame:GetName() .. 'AuraButton' .. i - 1], size, 0)
		end
	end

	CRF_UpdateMemberFrameAuras(frame)
end

function CRF_UpdateLookAndFeel()
	local group = _G['CompactGroupFrame']
	local isInRaid = UnitInRaid("player")
	local height, width = CRF_Settings['unit_height'], CRF_Settings['unit_width']

	if CRF_Settings['frame_border'] then
		group:SetBackdrop({
			edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
			edgeSize = 16
		})
		group:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0)
	else
		group:SetBackdrop(nil)
	end

	if isInRaid then
		local highestSubGroupNumber = 0
		local highestSubGroupSize = 0
		for i = 1, 8 do
			local raidGroup = _G['CompactRaidFrame'..i]
	
			if RAID_SUBGROUP_LISTS and RAID_SUBGROUP_LISTS[i] then
				local highestFrameNumber = 0
				for frameNumber, raidNumber in pairs(RAID_SUBGROUP_LISTS[i]) do
					local frame = _G[raidGroup:GetName() .. 'UnitFrame' .. frameNumber]

					CRF_SetUnitFrameAppearance(frame, frameNumber, raidGroup)

					if highestFrameNumber < frameNumber then
						highestFrameNumber = frameNumber
					end
				end
				if highestFrameNumber > 0 then
					highestSubGroupNumber = i
				end
				if highestSubGroupSize < highestFrameNumber then
					highestSubGroupSize = highestFrameNumber
				end
			end

			raidGroup:SetPoint('TOPLEFT', group, (width + 8) * (i - 1), 0)
			raidGroup:SetHeight(5 * height + 8)
			raidGroup:SetWidth(width + 8)
		end

		group:SetHeight(highestSubGroupSize * height + 8)
		group:SetWidth((width + 8) * highestSubGroupNumber)
	else
		for i = 1, MAX_PARTY_MEMBERS + 1 do
			local frame = _G['CompactPartyFrameUnitFrame' .. i]

			group:SetHeight((GetNumPartyMembers() + 1) * height + 8)
			group:SetWidth(width + 8)

			CRF_SetUnitFrameAppearance(frame, i, group)
		end
	end
end
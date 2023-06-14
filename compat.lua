local _G = getfenv(0)

local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Roster = AceLibrary("RosterLib-2.0")

local frames = {
	["player"] = _G['CompactUnitFrame1HealthBar'],
	["party1"] = _G['CompactUnitFrame2HealthBar'],
	["party2"] = _G['CompactUnitFrame3HealthBar'],
	["party3"] = _G['CompactUnitFrame4HealthBar'],
	["party4"] = _G['CompactUnitFrame5HealthBar'],
}

local function OnHeal(unit, frame)
	if not frame then
		frame = frames[unit]
	end

	local prediction = _G[frame:GetName() .. 'Prediction']
	local healed = HealComm:getHeal(UnitName(unit))
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if healed > 0 and health < maxHealth and frame:IsVisible() then
		prediction:Show()
		local healthWidth = frame:GetWidth() * (health / maxHealth)
		local incWidth = frame:GetWidth() * (healed / maxHealth)
		if healthWidth + incWidth > (frame:GetWidth()) then
			incWidth = frame:GetWidth() - healthWidth
		end

		prediction:SetWidth(incWidth - 2)
		prediction:SetHeight(frame:GetHeight())
		prediction:ClearAllPoints()
		prediction:SetPoint('TOPLEFT', frame, 'TOPLEFT', healthWidth, 0)
	else
		prediction:Hide()
	end
end	

local function OnEvent(unitname)
	local unitobj = Roster:GetUnitObjectFromName(unitname)
	if not unitobj or not unitobj.unitid then
		return
	end

	if UnitIsUnit('player', unitobj.unitid) then
		OnHeal('player')
	else
		for i = 1, 4 do
			if UnitIsUnit('party' .. i, unitobj.unitid) then
				OnHeal('party' .. i)
			end
		end
	end
end

AceEvent:RegisterEvent("HealComm_Healupdate", OnEvent)

for _, frame in frames do
	local name = frame:GetName()
	local heal = CreateFrame('StatusBar', name .. 'Prediction', frame)
	heal:SetStatusBarTexture('Interface\\AddOns\\CRF\\assets\\UnitFrame-HealthFill')
	heal:SetMinMaxValues(0, 1)
	heal:SetValue(1)
	heal:SetStatusBarColor(0, 1, 0, 0.5)
end
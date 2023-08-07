local _G = getfenv(0)

local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Roster = AceLibrary("RosterLib-2.0")

local frames = {
	["player"] = _G['CompactUnitFrame1'],
	["party1"] = _G['CompactUnitFrame2'],
	["party2"] = _G['CompactUnitFrame3'],
	["party3"] = _G['CompactUnitFrame4'],
	["party4"] = _G['CompactUnitFrame5'],
}

local function OnEvent(unitname)
	local unitobj = Roster:GetUnitObjectFromName(unitname)
	if not unitobj or not unitobj.unitid then
		return
	end

	if UnitIsUnit('player', unitobj.unitid) then
		CRF_OnHeal('player')
	else
		for i = 1, 4 do
			if UnitIsUnit('party' .. i, unitobj.unitid) then
				CRF_OnHeal('party' .. i)
			end
		end
	end
end

AceEvent:RegisterEvent("HealComm_Healupdate", OnEvent)

function CRF_OnHeal(unit, frame)
	if not frame then
		frame = frames[unit]
	end

	local bar = _G[frame:GetName() .. 'HealthBarIncomingHealBar']
	local healed = HealComm:getHeal(UnitName(unit))
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if healed > 0 and health < maxHealth and frame:IsVisible() then
		local healthWidth = frame:GetWidth() * (health / maxHealth)
		local incWidth = frame:GetWidth() * (healed / maxHealth)
		if healthWidth + incWidth > (frame:GetWidth()) then
			incWidth = frame:GetWidth() - healthWidth
		end

		bar:Show()
		bar:SetWidth(incWidth)
		bar:SetHeight(bar:GetParent():GetHeight())
		bar:ClearAllPoints()
		bar:SetPoint('TOPLEFT', frame, 'TOPLEFT', healthWidth, 0)
	else
		bar:Hide()
	end
end
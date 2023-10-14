local _G = getfenv(0)

local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Roster = AceLibrary("RosterLib-2.0")

local frames = {
	["player"] = _G['CompactPartyFrameUnitFrame1'],
	["party1"] = _G['CompactPartyFrameUnitFrame2'],
	["party2"] = _G['CompactPartyFrameUnitFrame3'],
	["party3"] = _G['CompactPartyFrameUnitFrame4'],
	["party4"] = _G['CompactPartyFrameUnitFrame5'],
}

local function OnEvent(unitname)
	local unitobj = Roster:GetUnitObjectFromName(unitname)
	if not unitobj or not unitobj.unitid then
		return
	end

	if UnitInRaid("player") then
		for i = 1, 40 do
			if UnitIsUnit('raid' .. i, unitobj.unitid) then
				CRF_OnHeal('raid' .. i)
			end
		end
	else
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
end

AceEvent:RegisterEvent("HealComm_Healupdate", OnEvent)

function CRF_OnHeal(unit, frame)
	if not frame then
		frame = frames[unit]
		if not frame then
			local raidIndex = 1
			local groupIndex = 1
			for raidIndex = 1, 8 do
				for groupIndex = 1, 5 do
					local frameToTest = _G['CompactRaidFrame'..raidIndex..'UnitFrame'..groupIndex]
					if frameToTest.unit == unit then
						frame = frameToTest
						return
					end
				end
				if frame then
					return
				end
			end
		end
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
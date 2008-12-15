--######################
-- Interface: 30000
-- Title: QIDTest
-- Notes: Displays an items basic info in the color of the item's quality, in the tooltip.
-- License: GNUv2GPL
-- Author: Anaral
-- Version: 3.05
--#######################

QualityID = {}
QIDDB = {
enabled = true;
showStackCount = true;
showIcon = true;
showType = true;
}

QIDDB.enabled	= true
QIDDB.showStackCount = true
QIDDB.showIcon = true
QIDDB.showType = true
QIDDB.QualityIDVersion = "3.05"

--For testing if version is doubling info, if it shows twice, then we are sad pandas.
--DEFAULT_CHAT_FRAME:AddMessage("|cff00dd88" .. "QualityID: v"..QIDDB.QualityIDVersion.." enabled!")

function QualityID:CheckSavedVars()
	if (not (QIDDB)) then DEFAULT_CHAT_FRAME:AddMessage("Setting up QIDDB.") end
	if (not (QIDDB)) then QIDDB = {} end
	if (not (QIDDB.enabled))	then QIDDB.enabled = self.enabled	end
	if (not (QIDDB.showStackCount)) then QIDDB.showStackCount = self.showStackCount end
	if (not (QIDDB.showIcon)) then QIDDB.showIcon = self.showIcon end
	if (not (QIDDB.showType)) then QIDDB.showType = self.showType end
end

function QualityID:VARIABLES_LOADED()
	QualityID:CheckSavedVars()
end

function chat(text)
	if(type(text) == "boolean") then
        if(text) then
            text = "True";
        else
            text = "False";
        end
    end
	if(text ~= nil) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff00dd88" .. text .. "|r");
	end
end

SLASH_QUALITYID1 = "/qualityid"
SLASH_QUALITYID2 = "/qid"
--	SlashCmdList["SLASHCMD"] = function (msg, editBox) end;  <--- blizz function for 3.0
SlashCmdList["QUALITYID"] = function(msg)
	QualityID_SlashCommandHandler(msg);
end
--slashcommand functions
function QualityID_SlashCommandHandler(msg)
    if(msg ~= "") then
        chat("QualityID: " .. msg .. " toggled.");
    end
    if(msg:lower() == "toggle") then
        QIDDB.enabled = not QIDDB.enabled;
    elseif(msg:lower() == "on") then
        QIDDB.enabled = true;
    elseif(msg:lower() == "off") then
        QIDDB.enabled = false;
	elseif(msg:lower() == "stack") then
		QIDDB.showStackCount = not QIDDB.showStackCount;
	elseif(msg:lower() == "itemtype") then
		QIDDB.showitemType = not QIDDB.showitemType;
	elseif(msg:lower() == "icon") then
		QIDDB.showIcon = not QIDDB.showIcon;
	elseif(msg == "") then
        chat("QIDTest options:  /qid {toggle | on | off}");
		chat("/qid stack {toggle}");
		chat("/qid itype {toggle}");
		chat("/qid icon {toggle}");
    end
end

local origs = {}
--adds id, lvl, stkct, and type
local function OnTooltipSetItem(frame, ...)
	local name, link = frame:GetItem()
	if QIDDB.enabled and link then
		local _, _, id, id2 = strfind(link, "item:(%d+).+:(.+:.+)%[")
		--While not all returns will be called, all are listed for personal reference.
		local name,link,quality,ilvl,reqLevel,type,subType,stackCount = GetItemInfo(id)
		--text that you see in the tooltip
		frame:AddLine(" ")
		if stackCount and QIDDB.showStackCount and stackCount > 2 then
		frame:AddLine( "Stacks in lots of "..ITEM_QUALITY_COLORS[quality].hex..stackCount)
		end
		if quality then
		frame:AddLine( "Item ID:  "..ITEM_QUALITY_COLORS[quality].hex..id)
		frame:AddLine( "Item Lvl:  "..ITEM_QUALITY_COLORS[quality].hex..ilvl)
		end
		if QIDDB.showitemType then
		frame:AddLine( ""..type..": "..subType, 0,1,0)
		end
		frame:AddLine(" ")
	end
	if origs[frame] then
		return origs[frame](frame, ...)
	end
end

--Add item icon to the tooltip.
local function hookItem(frame, ...)
	local _G = getfenv(0)
	local set = frame:GetScript('OnTooltipSetItem')

	frame:SetScript('OnTooltipSetItem', function(self, ...)
		local link = select(2, self:GetItem())
		if  link and GetItemInfo(link) then
			local text = _G[self:GetName() .. 'TextLeft1']
			--make sure the icon does not display twice on recipies, which fire OnTooltipSetItem twice
			if QIDDB.showIcon and text and text:GetText():sub(1, 2) ~= '|T' then 
				text:SetFormattedText('|T%s:%d|t%s', GetItemIcon(link), 36, text:GetText())
			end
		end

		if set then
			return set(self, ...)
		end
	end)
end
hookItem(GameTooltip)
hookItem(ItemRefTooltip)
hookItem(ShoppingTooltip1)
hookItem(ShoppingTooltip2)

for _,frame in pairs{GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2} do
	origs[frame] = frame:GetScript("OnTooltipSetItem")
	frame:SetScript("OnTooltipSetItem", OnTooltipSetItem)
end


--Run once when first loaded.
do
	QID = CreateFrame("Frame", "QID")
	QID:RegisterEvent("VARIABLES_LOADED")
	QID:SetScript("OnEvent", function(self, event, ...) QualityID[event](QualityID, event, ...) end)
	
	DEFAULT_CHAT_FRAME:AddMessage("|cff00dd88" .. "QualityID: v"..QIDDB.QualityIDVersion.." enabled!");
end
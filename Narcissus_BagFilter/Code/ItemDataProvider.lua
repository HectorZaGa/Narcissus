local _, addon = ...

local DataProvider = {};
addon.BagItemSearchDataProvider = DataProvider;

local ItemDatabase = addon.BagItemSearchDatabase;  --table

local ipairs = ipairs;
local gsub = string.gsub;
local match = string.match;
local find = string.find;

local GetContainerItemID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID;
local GetItemSpell = GetItemSpell;

local IsCosmeticItem = IsCosmeticItem;
if not IsCosmeticItem then
    IsCosmeticItem = function(itemID) return false end
end

--local PATTERN_CONJURED_ITEM = ITEM_CONJURED or "Conjured Item";


local NUM_TYPES = 0;

local ItemIDXTypeID = {};       --[itemID] = typeID,        --ID x ItemNameDescription
local ItemSubText = {};         --[typeID] = {text, color, count},
local SubTextXTypeID = {};      --[Subtext] = typeID,
local SubTextNameList = {};     --For sorting. {name, typeID};
local BagCache = {};    --[bag] = { {id, [cosmic = state], [tele = state]}, }   --This significantly increases RAM usage

---- Markers ----
local ANY_COSMETIC = false;
local ANY_TELE = false;


local GetBagItemSubText;

do
    if C_TooltipInfo then
        GetBagItemSubText = NarciAPI.GetBagItemSubText;

    else
        local tooltipName = "NarciItemSubTextUtilityTooltip";
        local TP = _G[tooltipName];
        TP:SetOwner(UIParent, "ANCHOR_NONE");
        local KeyLine = _G[tooltipName.."TextLeft2"];

        local function GetSubText(bag, slot)
            TP:SetBagItem(bag, slot);
            return KeyLine:GetText();
        end

        GetBagItemSubText = GetSubText;
    end
end


local function GetColorString(text)
    return match(text, "|[cC][fF][fF](%w%w%w%w%w%w)");
end

local function RemoveColorString(text)
    return gsub(text, "|[cC][fF][fF]%w%w%w%w%w%w(.*)|[rR]", "%1")
end

---- Derivative of ColorUtil.lua ----
local function ExtractColorValueFromHex(str, index)
	return math.floor(1000*tonumber(str:sub(index, index + 1), 16) / 255 + 0.5)/1000;
end

local function GetRGBColorFromHex(hexColor)
	local r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5);
    return r, g, b
end

local IGNORED_ITEMS = {
    [127829] = true,
}

local KNOWN_TYPES = {
    --These item names don't contain color code, so it can't be detected by our algo 
};

do
    local itemCosmetic = ITEM_COSMETIC or "Cosmetic";
    if itemCosmetic then
        KNOWN_TYPES[itemCosmetic] = {text = itemCosmetic, r = 1, g = 0.502, b = 1, count = 0, filter = "ShowCosmetic"};    --color
    end
end

function DataProvider:CacheBagItem(bag, slot)
    local itemID = GetContainerItemID(bag, slot);

    if not BagCache[bag] then
        BagCache[bag] = {};
    end
    if not BagCache[bag][slot] then
        BagCache[bag][slot] = {};
    end

    local cache =  BagCache[bag][slot];
    if itemID then
        if itemID ~= cache.id then
            cache.id = itemID;

            if IsCosmeticItem(itemID) then
                cache.cosmic = true;
            else
                cache.cosmic = nil;
            end

            if self:IsTransportationItem(itemID) then
                cache.tele = true;
            else
                cache.tele = nil;
            end
        end

        if not ItemIDXTypeID[itemID] then
            local text = GetBagItemSubText(bag, slot);
            if text then
                if text == "" then
                    --print("Not Cached", bag, slot)
                    return false
                else
                    local typeID;
                    if not IGNORED_ITEMS[itemID] then
                        if KNOWN_TYPES[text] then
                            if not SubTextXTypeID[text] then
                                NUM_TYPES = NUM_TYPES + 1;
                                typeID = NUM_TYPES;
                                SubTextXTypeID[text] = typeID;
                                table.insert(SubTextNameList, {text, typeID});
                                ItemSubText[typeID] = KNOWN_TYPES[text];
                                --print("Knwon Type: #"..typeID.." "..text);
                            end
                            typeID = SubTextXTypeID[text];
                            ItemIDXTypeID[itemID] = typeID;
                        else
                            local colorHex = GetColorString(text);
                            if colorHex and (not find(text, "<")) then  --<Made by XXX
                                text = RemoveColorString(text);
                                if not SubTextXTypeID[text] then
                                    NUM_TYPES = NUM_TYPES + 1;
                                    typeID = NUM_TYPES;
                                    SubTextXTypeID[text] = typeID;
                                    table.insert(SubTextNameList, {text, typeID});
                                    ItemSubText[typeID] = {};
                                    local tbl = ItemSubText[typeID];
                                    tbl.text = text;
                                    tbl.r, tbl.g, tbl.b = GetRGBColorFromHex(colorHex);
                                    tbl.count = 0;
                                    --print("New Type: #"..typeID.." "..text);
                                end
                                typeID = SubTextXTypeID[text];
                                ItemIDXTypeID[itemID] = typeID;
                            else
                                ItemIDXTypeID[itemID] = 0;
                            end
                        end
                    else
                        ItemIDXTypeID[itemID] = 0;
                    end
                end
            end
        end
    else
        if cache.id then
            cache.id = nil;
            cache.cosmic = nil;
            cache.tele = nil;
        end
    end

    return true
end

function DataProvider:GetAllItemTypes()
    return ItemSubText, SubTextNameList
end

function DataProvider:IsTransportationItem(itemID)
    return ItemDatabase.TeleportationItems[itemID] or false
end

function DataProvider:IsConjuredItem(itemID)
    --Use this less adaptive method for slightly better performance?
    return ItemDatabase.ConjuredItems[itemID] or false

    --TP:SetBagItem(bag, slot);
    --local text = KeyLine:GetText();
    --return text and text == PATTERN_CONJURED_ITEM
end




function DataProvider:ResetMarkers()
    ANY_COSMETIC = false;
    ANY_TELE = false;

    for typeID, typeInfo in ipairs(ItemSubText) do
        typeInfo.count = 0;
    end
end

function DataProvider:UpdateMarkers()
    local itemID, typeID, bagData;

    for bag = 0, 4 do
        bagData = BagCache[bag];
        if bagData then
            for slot, slotData in ipairs(bagData) do
                itemID = slotData.id;

                if itemID then
                    if not ANY_TELE then
                        if slotData.tele then
                            ANY_TELE = true;
                        end
                    end

                    typeID = ItemIDXTypeID[itemID];
                    if ItemSubText[typeID] then
                        ItemSubText[typeID].count = ItemSubText[typeID].count + 1;
                    end
                end
            end
        end
    end
end

function DataProvider:HasAnyTeleportationItem()
    return ANY_TELE
end
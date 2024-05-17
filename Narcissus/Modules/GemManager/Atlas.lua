local _, addon = ...
local Gemma = addon.Gemma;

local PATH = "Interface/AddOns/Narcissus/Art/Modules/GemManager/";

local Atlas = {};
local AtlasUtil = {};
Gemma.AtlasUtil = AtlasUtil;

function AtlasUtil:SetAtlas(texture, name)
    local a = name and Atlas[name];

    if a then
        texture:SetTexture(a[1]);
        texture:SetSize(a[2], a[3]);
        texture:SetTexCoord(a[4], a[5], a[6], a[7]);
    else
        texture:SetTexture(nil);
    end
end

function AtlasUtil:GetTexCoord(name)
    local a = name and Atlas[name];

    if a then
        return a[4], a[5], a[6], a[7]
    end
end

local HS = 40;    --48;

local AtlasInfo = {
    --file, textureWidth, textureHeight, {[atlasName] = {width, height, 4pixelCoords}, ...}

    {PATH.."TimerunningPandaria.png", 1024, 1024, {
        ["remix-ui-bg"] = {338, 424, 616, 1024, 0, 512},
        ["remix-ui-divider"] = {338, 16, 0, 408, 256, 280},
        ["remix-ui-tinker-bg"] = {312, 312, 0, 144, 96, 240},
        ["remix-ui-tooltip-bg"] = {204, 86, 0, 204, 282, 368},
        ["remix-ui-loadingicon"] = {24, 24, 162, 194, 164, 196},

        ["remix-listbutton-highlight"] = {256, 64, 292, 548, 282, 346},

        ["remix-hexagon-yellow"] = {HS, HS, 0, 96, 0, 96},
        ["remix-hexagon-green"] = {HS, HS, 96, 192, 0, 96},
        ["remix-hexagon-darkyellow"] = {HS, HS, 192, 288, 0, 96},
        ["remix-hexagon-grey"] = {HS, HS, 288, 384, 0, 96},
        ["remix-hexagon-highlight"] = {HS, HS, 384, 480, 0, 96},
        ["remix-hexagon-dashedhighlight"] = {HS, HS, 480, 576, 0, 96},

        ["remix-bigsquare-yellow"] = {72, 72, 0, 144, 368, 512},
        ["remix-bigsquare-green"] = {72, 72, 144, 288, 368, 512},
        ["remix-bigsquare-grey"] = {72, 72, 288, 432, 368, 512},
        ["remix-bigsquare-highlight"] = {72, 72, 432, 576, 368, 512},
        ["remix-bigsquare-dashedhighlight"] = {72, 72, 0, 144, 770, 914},
        ["remix-bigsquare-shadow"] = {144, 144, 0, 144, 512, 656},

        ["remix-square-yellow"] = {48, 48, 194, 290, 674, 770},

        ["gemlist-return"] = {20, 20, 328, 360, 100, 132},
        ["gemlist-prev"] = {14, 14, 292, 324, 100, 132},
        ["gemlist-next"] = {14, 14, 324, 292, 100, 132},

        ["gemma-progressbar-border"] = {200, 24, 146, 546, 514, 562},
        ["gemma-progressbar-fill"] = {188, 12, 158, 534, 564, 588},
        ["gemma-progressbar-bg"] = {200, 12, 146, 546, 588, 612},
        ["gemma-progressbar-fillred"] = {188, 12, 158, 534, 612, 636},

        ["gemma-spinner-circle"] = {80, 80, 578, 738, 514, 674},
        ["gemma-spinner-dial"] = {128, 128, 768, 1024, 514, 770},

        ["gemma-stats-bg"] = {306, 24, 158, 464, 136, 160},
        ["gemma-stats-minus"] = {14, 14, 364, 396, 100, 132},
        ["gemma-stats-plus"] = {14, 14, 400, 432, 100, 132},
        ["gemma-stats-mouseover-bg"] = {314, 32, 158, 472, 196, 228},
        ["gemma-stats-mouseover-minus"] = {18, 18, 472, 512, 100, 140},
        ["gemma-stats-mouseover-plus"] = {18, 18, 516, 556, 100, 140},
        ["gemma-stats-mouseover-buttonhighlight"] = {24, 24, 560, 600, 100, 140},

        ["gemtypeicon-movement"] = {24, 24, 0, 48, 674, 722},
        ["gemtypeicon-offensive"] = {24, 24, 48, 96, 674, 722},
    }},

    {PATH.."HourglassWidget.png", 256, 256, {
        ["hourglass-background"] = {48, 48, 0, 64, 0, 64},
        ["hourglass-drip"] = {5, 24, 66, 74, 0, 32},
        ["hourglass-shine"] = {18, 48, 140, 164, 0, 64},
    }},
};

do
    local file, width, height;
    local w, h;

    for _, v in pairs(AtlasInfo) do
        file = v[1];
        width, height = v[2], v[3];
        for name, data in pairs(v[4]) do
            w, h = data[1], data[2];
            Atlas[name] = {file, w, h, data[3]/width, data[4]/width, data[5]/height, data[6]/height};
        end
    end

    AtlasInfo = {};
end
-- Author: TheNewTimeGamer

-- Vigor bar should have speed with a marker for trill of the skies
-- Vigot bar should have a timer (bar) for when the next vigor (partial) point recharges

-- Reference: https://wowpedia.fandom.com/wiki/UNIT_AURA

local containerFrame = CreateFrame("Frame", "TNTG-Container-Vigor");
containerFrame:SetFrameStrata("BACKGROUND");
containerFrame:SetSize(200, 25);
containerFrame:SetPoint("CENTER", EncounterBar, "CENTER", 0, 0);

containerFrame:EnableMouse(true)
containerFrame:SetMovable(true)
containerFrame:SetClampedToScreen(true)

containerFrame.texture = containerFrame:CreateTexture(nil, "BACKGROUND");
containerFrame.texture:SetTexture("Interface\\AddOns\\TNTG-Flight-Utils\\backdrop.png");
containerFrame.texture:SetAllPoints(true);

local overlayFrame = CreateFrame("Frame", "TNTG-Overlay-Vigor", containerFrame);
overlayFrame:SetFrameStrata("HIGH");
overlayFrame:SetSize(200, 25);
overlayFrame:SetPoint("CENTER", containerFrame, "CENTER", 0, 0);

overlayFrame.texture = overlayFrame:CreateTexture(nil, "BACKGROUND");
overlayFrame.texture:SetTexture("Interface\\AddOns\\TNTG-Flight-Utils\\overlay.png");
overlayFrame.texture:SetAllPoints(true);

local speedFrame = CreateFrame("Frame", "TNTG-Element-Speed", containerFrame);
speedFrame:SetFrameStrata("LOW");
speedFrame:SetSize(195, 7);
speedFrame:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 3, -3);

speedFrame.texture = speedFrame:CreateTexture(nil, "BACKGROUND");
speedFrame.texture:SetPoint("TOP", speedFrame, "TOP", 0, 0);
speedFrame.texture:SetPoint("BOTTOM", speedFrame, "BOTTOM", 0, 0);
speedFrame.texture:SetPoint("LEFT", speedFrame, "LEFT", 0, 0);
speedFrame.texture:SetColorTexture(1, 0, 0, 1);

local vigorFrame = CreateFrame("Frame", "TNTG-Element-Vigor", containerFrame);
vigorFrame:SetFrameStrata("LOW");
vigorFrame:SetSize(195, 11);
vigorFrame:SetPoint("TOPLEFT", speedFrame, "BOTTOMLEFT", 0, -2);

vigorFrame.texture = vigorFrame:CreateTexture(nil, "BACKGROUND");
vigorFrame.texture:SetPoint("TOP", vigorFrame, "TOP", 0, 0);
vigorFrame.texture:SetPoint("BOTTOM", vigorFrame, "BOTTOM", 0, 0);
vigorFrame.texture:SetPoint("LEFT", vigorFrame, "LEFT", 0, 0);
vigorFrame.texture:SetColorTexture(0.2196, 0.5686, 0.6706, 1);

local chargesFrame = CreateFrame("Frame", "TNTG-Element-Vigor", containerFrame);
chargesFrame:SetFrameStrata("MEDIUM");
chargesFrame:SetSize(195, 11);
chargesFrame:SetPoint("TOPLEFT", speedFrame, "BOTTOMLEFT", 0, -2);

chargesFrame.texture = chargesFrame:CreateTexture(nil, "BACKGROUND");
chargesFrame.texture:SetPoint("TOP", chargesFrame, "TOP", 0, 0);
chargesFrame.texture:SetPoint("BOTTOM", chargesFrame, "BOTTOM", 0, 0);
chargesFrame.texture:SetPoint("LEFT", chargesFrame, "LEFT", 0, 0);
chargesFrame.texture:SetColorTexture(0.5255, 0.7882, 0.8667, 1);

local function updateSpeed(self, elapsed)
    local _, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo();
    self.texture:SetWidth(200 * (forwardSpeed / 100));
end

speedFrame:SetScript("OnUpdate", updateSpeed);

-- Sets the containerFrame to the given visibility boolean.
-- Do the opposite for the EncounterBar to ensure that it is visible when we're actually in an encounter.
-- We don't want a raid fight's encounter bar to be hidden because someone uses this addon.
local function setVisible(visible)
    containerFrame:SetShown(visible);

    -- Make the EncounterBar fully transparent as hidding it with SetShown makes it not update correctly.
    if EncounterBar then
        if visible then
            EncounterBar:SetAlpha(0);
        else
            EncounterBar:SetAlpha(1);
        end
    end
end

local function updateVigor(self, event, info)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, canGlide = C_PlayerInfo.GetGlidingInfo();

        -- If we're not able to use dynamic flight, we hide.
        if not canGlide then
            setVisible(false);
        else
            setVisible(true);
        end
    elseif event == "UPDATE_UI_WIDGET" then
        if info.widgetSetID == C_UIWidgetManager.GetPowerBarWidgetSetID() then
            local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(info.widgetID)

            -- If we fail to get the vigor bar widget, we hide.
            if widgetInfo == nil then
                setVisible(false);
                return;
            end

            local fillProgress = widgetInfo.fillValue / 100;
            local vigor = widgetInfo.numFullFrames;
            local maxVigor = widgetInfo.numTotalFrames;

            -- If the blizzard bar tells us we don't have any max vigor, we hide.
            if maxVigor <= 0 then
                setVisible(false);
                return;
            end

            setVisible(true);

            self.texture:SetWidth(self:GetWidth() * (vigor / maxVigor) +
                fillProgress * (self:GetWidth() / widgetInfo.numTotalFrames));
            chargesFrame.texture:SetWidth(self:GetWidth() * (vigor / maxVigor));
        end
    end
end

vigorFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
vigorFrame:RegisterEvent("UPDATE_UI_WIDGET");
vigorFrame:SetScript("OnEvent", updateVigor);

import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "TravelWindowII.src.extensions";
import "TravelWindowII.src.TravelGridTab"
import "TravelWindowII.src.SettingsMenu";
import "TravelWindowII.src.utils.BitOps";

--[[ This is the window for the text list tab of the 	]] --
--[[ Travel UI.  It handles creating all UI controls on ]] --
--[[ the tab, and updating the UI when the settings are	]] --
--[[ changed.											]] --
--[[ This class is actually an extension  	]] --
--[[ of the TravelGridTab	]] --

TravelListTab = class(TravelGridTab);

function TravelListTab:Constructor(toplevel)
    TravelGridTab.Constructor(self);

    -- need top level window in order to close it
    self.parent = toplevel;
end

function TravelListTab:SetItems()
    self.labels = {};
    TravelGridTab.SetItems(self);
end

function TravelListTab:AddItem(shortcut, i)
    -- set the column width to 1
    self.numOfCols = 1;

    -- determine the width and height of the shortcuts and labels to be added
    itemWidth = self:GetWidth() - 30;
    itemHeight = 22;

    -- set the index value based on the row and column
    local index = (self.row - 1) * self.numOfCols + self.col;

    -- create new quickslots setting the position
    -- based on the row and column locations
    self.quickslots[index] = Turbine.UI.Lotro.Quickslot();
    self.quickslots[index]:SetSize(itemWidth, itemHeight);
    self.quickslots[index]:SetPosition(10 + ((self.col - 1) * (itemWidth + 2)), ((self.row - 1) * (itemHeight)));
    self.quickslots[index]:SetZOrder(90);
    self.quickslots[index]:SetOpacity(1);
    self.quickslots[index]:SetUseOnRightClick(false);
    self.quickslots[index]:SetParent(self.SubWindow);

    pcall(function()
        self.quickslots[index]:SetShortcut(shortcut);
    end)

    -- create the label that will cover the shortcut
    self.labels[index] = Turbine.UI.Label();
    self.labels[index]:SetSize(itemWidth, itemHeight);
    self.labels[index]:SetPosition(10 + ((self.col - 1) * (itemWidth + 2)), ((self.row - 1) * (itemHeight)));
    self.labels[index]:SetZOrder(100);
    self.labels[index]:SetMouseVisible(false);
    self.labels[index]:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
    self.labels[index]:SetBackColor(Turbine.UI.Color(0.87, 0, 0, 0));
    self.labels[index]:SetText(shortcut:GetSkillLabel());
    self.labels[index]:SetParent(self.SubWindow);

    -- set all quickslots to be visible and
    -- disable dropping new shortcuts onto them
    self.quickslots[index]:SetAllowDrop(false);
    self.quickslots[index]:SetVisible(true);

    -- show the menu when right clicked
    self.quickslots[index].MouseClick = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Right) then
            Menu:ShowMenu();
        else
            if (Settings.hideOnTravel == 1) then
                self.parent:SetVisible(false);
            end
        end
    end

    -- handle the mouse wheel scroll
    self.quickslots[index].MouseWheel = function(sender, args)
        self:DoScroll(sender, args);
    end

    -- change the background colour of the label with the mouse enters
    self.quickslots[index].MouseEnter = function(sender, args)
        self.labels[index]:SetBackColor(Turbine.UI.Color(0.87, 0.17, 0.17, 0.17));
    end

    -- return the background colour when the mouse leaves the label
    self.quickslots[index].MouseLeave = function(sender, args)
        self.labels[index]:SetBackColor(Turbine.UI.Color(0.87, 0, 0, 0));
    end

    -- increase the row number when the column
    -- number is greater than the number of columns
    -- for the size of the window
    self.col = self.col + 1;
    if (self.col > self.numOfCols) then
        self.col = 1;
        self.row = self.row + 1;
    end
end

function TravelListTab:SetScrollBar()

    -- set up the scrollbar for the list
    self.myScrollBar = Turbine.UI.Lotro.ScrollBar();
    self.myScrollBar:SetBackColor(Turbine.UI.Color(0.87, 0, 0, 0));
    self.myScrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
    self.myScrollBar:SetSize(10, self:GetHeight() - 35);
    self.myScrollBar:SetPosition(self:GetWidth() - 15, 0);
    self.myScrollBar:SetMinimum(0);

    -- set the maximum value of the scrollbar
    -- based on the number of rows in the subwindow
    NumberOfSlots = #self.quickslots;
    NumberOfRows = math.ceil(NumberOfSlots / self.numOfCols);

    self.max = NumberOfRows * 22 - self:GetHeight() + 35;
    if (self.max < 0) then
        -- the max cannot be less than one
        self.max = 0;
        self.myScrollBar:SetMaximum(self.max);
        self.myScrollBar:SetParent(self.SubWindow);
        self.myScrollBar:SetVisible(false);
    else
        self.myScrollBar:SetMaximum(self.max);
        self.myScrollBar:SetParent(self.SubWindow);
        self.myScrollBar:SetVisible(true);
    end

    -- show the menu when right clicked
    self.myScrollBar.MouseClick = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Right) then
            Menu:ShowMenu();
        end
    end

    -- call the routine to update the
    -- sub window when the value of the
    -- scrollbar is changed.
    self.myScrollBar.ValueChanged = function(sender, args)
        self:UpdateSubWindow();
    end
end

function TravelListTab:UpdateSubWindow()
    -- loop through all the quickslots
    for i = 1, #self.quickslots, 1 do
        -- get the number of rows
        self.row = math.ceil(i / self.numOfCols);

        -- set the top position of the quickslots based on row
        -- number and the value of the scrollbar
        self.quickslots[i]:SetTop((self.row - 1) * 22 - self.myScrollBar:GetValue());
        self.labels[i]:SetTop((self.row - 1) * 22 - self.myScrollBar:GetValue());
    end
end

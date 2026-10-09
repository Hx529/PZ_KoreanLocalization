local StockName = {
  "IGUI_RISKY_Spiffos",
  "IGUI_RISKY_Gas2Go",
  "IGUI_RISKY_Fossil",
  "IGUI_RISKY_Gigamart",
  "IGUI_RISKY_PileOCrepe",
  "IGUI_RISKY_McCoyLogginCo",
  "IGUI_RISKY_ValuTech",
  "IGUI_RISKY_PizzaWhirled",
  "IGUI_RISKY_TacoDelPancho",
}
local StockTexture = {"risky_investment_spiffo", "risky_investment_gas2go", "risky_investment_fossil", "risky_investment_gigamart", "risky_investment_poc", "risky_investment_mccoy",
                      "risky_investment_valutech", "risky_investment_pizzawhirled", "risky_investment_tacodelpancho"}
local investmentWindow = {}

local function OnGameStart()
    if (getSpecificPlayer(0):getModData().stock == nil or getSpecificPlayer(0):getModData().fund == nil) then
        getSpecificPlayer(0):getModData().stock = {}
        getSpecificPlayer(0):getModData().fund = ZombRand(1, 1000)
    end
end

Events.OnGameStart.Add(OnGameStart)

local function OnCreatePlayer(playerNum, player)
    if (player:getModData().stock == nil or player:getModData().fund == nil) then
        player:getModData().stock = {}
        player:getModData().fund = ZombRand(1, 1000)
    end
end

Events.OnCreatePlayer.Add(OnCreatePlayer)

local function OnCharacterDeath(character)
    if (character:getID() == getSpecificPlayer(0):getID()) then
        if (investmentWindow[0] ~= nil or investmentWindow[0]:getIsVisible()) then
            investmentWindow[0]:close()
        end
    end
end

Events.OnCharacterDeath.Add(OnCharacterDeath)

local function OnZombieDead(zombie)
    if (ZombRand(0, 10) < 1) then
        zombie:getInventory():AddItem("RiskyInvestment.PDA")
    end
end

Events.OnZombieDead.Add(OnZombieDead)


riskyInvestmentUI = ISCollapsableWindowJoypad:derive("riskyInvestmentUI")

function riskyInvestmentUI:new(x, y, width, height, character)
    local o = {}
	o = ISCollapsableWindowJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.buttons = {}

	return o
end

function riskyInvestmentUI:update()
    ISCollapsableWindowJoypad.update(self)

    if self and self:getIsVisible() then
        if (self.character:getPrimaryHandType() ~= "PDA" and self.character:getSecondaryHandType() ~= "PDA") then
            self:close()
            return
        end
    end

    local modData = ModData.getOrCreate("riskyInvestment")
    for i = 1, #self.buttons, 1 do
        -- Time Check
        if (getGameTime():getHour() >= 9 and getGameTime():getHour() < 16) then
            -- Buy Check
            if (self.character:getModData().fund >= modData.stock[i]) then
                self.buttons[i][1]:setEnable(true)
            else
                self.buttons[i][1]:setEnable(false)
            end

            -- Sell Check
            if (self.character:getModData().stock[i] ~= nil and self.character:getModData().stock[i] ~= 0) then
                self.buttons[i][2]:setEnable(true)
            else
                self.buttons[i][2]:setEnable(false)
            end
        else
            self.buttons[i][1]:setEnable(false)
            self.buttons[i][2]:setEnable(false)
        end
    end
end

function riskyInvestmentUI:onDeposit(button, x, y)
    local modData = ModData.getOrCreate("riskyInvestment")
    local moneyItems = self.character:getInventory():getItemsFromType("Money")
    self.character:getModData().fund = self.character:getModData().fund + moneyItems:size()

    for i = 0, moneyItems:size() - 1, 1 do
        self.character:getInventory():DoRemoveItem(moneyItems:get(i))
    end
end

function riskyInvestmentUI:onWithdraw(button, x, y)
    local modData = ModData.getOrCreate("riskyInvestment")
    self.character:getInventory():AddItems("Base.Money", self.character:getModData().fund)
    self.character:getModData().fund = 0
end

function riskyInvestmentUI:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    self:drawTexture(getTexture("Item_Money"), 15, 35, 1, 1, 1, 1)
    self:drawText(getText('IGUI_RISKY_INVEST_BALANCE') .. ": $" .. self.character:getModData().fund, 55, 35, 1, 1, 1, 1, UIFont.Medium)

    if (getGameTime():getHour() >= 9 and getGameTime():getHour() < 16) then
        self:drawText(getText('IGUI_RISKY_INVEST_OPEN'), 55, 90, 0, 1, 0, 1, UIFont.Small)
    else
        self:drawText(getText('IGUI_RISKY_INVEST_CLOSE'), 55, 90, 1, 0, 0, 1, UIFont.Small)
    end

    local entryHeight = 110
    local modData = ModData.getOrCreate("riskyInvestment")
    for i = 1, #modData.stock, 1 do
        local column = (i - 1) % 3 * 200
        local yestrdVal = modData.stockPrev[i]
        local currentVal = modData.stock[i]
        self:drawTextureScaled(getTexture("media/textures/" .. StockTexture[i] .. ".png"), 15 + column, entryHeight + 3, 38, 38, 1, 1, 1, 1)
        self:drawText(getText(StockName[i]), 60 + column, entryHeight, 1, 1, 1, 1, UIFont.Medium)

        self:drawText(getText('IGUI_RISKY_INVEST_PRICE') .. ": $" .. tostring(currentVal), 60 + column, entryHeight + 25, 1, 1, 1, 1, UIFont.Small)

        local changes = ((currentVal - yestrdVal) / yestrdVal) * 100
        if (changes < 0) then
            self:drawText(string.format("%.1f", changes) .. "%", 75 + column, entryHeight + 40, 1, 0, 0, 1, UIFont.Small)
            self:drawTextureScaled(getTexture("media/textures/risky_investment_decrease.png"), 60 + column, entryHeight + 45, 10, 10, 1, 1, 1, 1)
        else
            self:drawText(string.format("%.1f", changes) .. "%", 75 + column, entryHeight + 40, 0, 1, 0, 1, UIFont.Small)
            self:drawTextureScaled(getTexture("media/textures/risky_investment_increase.png"), 60 + column, entryHeight + 45, 10, 10, 1, 1, 1, 1)
        end

        local owned = self.character:getModData().stock[i]
        if (owned == nil) then
            owned = 0
        end

        self:drawText(getText('IGUI_RISKY_INVEST_OWNED') .. ": " .. tostring(owned), 60 + column, entryHeight + 55, 1, 1, 1, 1, UIFont.Small)

        if (i % 3 == 0) then
            entryHeight = entryHeight + 107
        end
    end
end

function riskyInvestmentUI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local depositButton = ISButton:new(55, 60, 50, 25, getText('IGUI_RISKY_INVEST_DEPOSIT'), self, self.onDeposit)
    depositButton.borderColor.r = 0.0
    depositButton.borderColor.g = 255.0
    depositButton.borderColor.b = 0.0
    depositButton:initialise()
    depositButton:instantiate()
    self:addChild(depositButton)

    local withdrawButton = ISButton:new(115, 60, 50, 25, getText('IGUI_RISKY_INVEST_WITHDRAW'), self, self.onWithdraw)
    withdrawButton.borderColor.r = 255.0
    withdrawButton.borderColor.g = 0.0
    withdrawButton.borderColor.b = 0.0
    withdrawButton:initialise()
    withdrawButton:instantiate()
    self:addChild(withdrawButton)

    local entryHeight = 110
    local modData = ModData.getOrCreate("riskyInvestment")
    for i = 1, #modData.stock, 1 do
        local column = (i - 1) % 3 * 200
        local buyButton = ISButton:new(60 + column, entryHeight + 78, 50, 25, getText('IGUI_RISKY_INVEST_BUY'), self, function()
            if (self.character:getModData().fund >= modData.stock[i]) then
                if (self.character:getModData().stock[i] == nil) then
                    self.character:getModData().stock[i] = 0
                end

                self.character:getModData().stock[i] = self.character:getModData().stock[i] + 1
                self.character:getModData().fund = self.character:getModData().fund - modData.stock[i]
            end
        end)
        buyButton.borderColor.r = 0.0
        buyButton.borderColor.g = 255.0
        buyButton.borderColor.b = 0.0
        buyButton:initialise()
        buyButton:instantiate()
        self:addChild(buyButton)

        local sellButton = ISButton:new(120 + column, entryHeight + 78, 50, 25, getText('IGUI_RISKY_INVEST_SELL'), self, function()
            if (self.character:getModData().stock[i] ~= nil and self.character:getModData().stock[i] ~= 0) then
                self.character:getModData().stock[i] = self.character:getModData().stock[i] - 1
                self.character:getModData().fund = self.character:getModData().fund + modData.stock[i]
            end
        end)
        sellButton.borderColor.r = 255.0
        sellButton.borderColor.g = 0.0
        sellButton.borderColor.b = 0.0
        sellButton:initialise()
        sellButton:instantiate()
        self:addChild(sellButton)

        table.insert(self.buttons, {buyButton, sellButton})

        if (i % 3 == 0) then
            entryHeight = entryHeight + 107
        end
    end
end

function riskyInvestmentUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    investmentWindow[0] = nil
end

local function OnEquipSecondary(character, item)
    if item and item:getType() == "PDA" and item:isEquipped() then
        if (investmentWindow[0] == nil or not investmentWindow[0]:getIsVisible()) then
            investmentWindow[0] = riskyInvestmentUI:new(100, 100, 700, 445, getSpecificPlayer(0))
            investmentWindow[0]:setTitle(getText('IGUI_RISKY_INVEST_STOCKX'))
            investmentWindow[0]:addToUIManager()
            investmentWindow[0].resizable = false
            investmentWindow[0].collapsable = false
        else
            investmentWindow[0].itemBase = item
        end
    end
end

Events.OnEquipSecondary.Add(OnEquipSecondary)

local function OnEquipPrimary(character, item)
    if item and item:getType() == "PDA" and item:isEquipped() then
        if (investmentWindow[0] == nil or not investmentWindow[0]:getIsVisible()) then
            investmentWindow[0] = riskyInvestmentUI:new(100, 100, 700, 500, getSpecificPlayer(0))
            investmentWindow[0]:setTitle(getText('IGUI_RISKY_INVEST_STOCKX'))
            investmentWindow[0]:addToUIManager()
            investmentWindow[0].resizable = false
            investmentWindow[0].collapsable = false
        else
            investmentWindow[0].itemBase = item
        end
    end
end

Events.OnEquipPrimary.Add(OnEquipPrimary)

local function createInventoryMenuEntry(_player, _context, _items)
    local resItems = {}
    local container = nil
    for i,v in ipairs(_items) do
        if not instanceof(v, "InventoryItem") then
            for _, it in ipairs(v.items) do
                resItems[it] = true
            end
            container = v.items[1]:getContainer()
        else
            resItems[v] = true
            container = v:getContainer()
        end
    end

    for v, _ in pairs(resItems) do
        if v:getType() == "PDA" and v:isEquipped() then
            _context:addOptionOnTop(getText('IGUI_RISKY_INVEST_BROWSE'), 0, function()
                if investmentWindow[0] == nil or not investmentWindow[0]:getIsVisible() then
                    investmentWindow[0] = riskyInvestmentUI:new(100, 100, 700, 500, getSpecificPlayer(0))
                    investmentWindow[0]:setTitle(getText('IGUI_RISKY_INVEST_STOCKX'))
                    investmentWindow[0]:addToUIManager()
                    investmentWindow[0].resizable = false
                    investmentWindow[0].collapsable = false
                end
            end)
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(createInventoryMenuEntry)

---------------------------------
---     Coded by Sioyth       ---
--- https://github.com/Sioyth ---
---------------------------------

NestedContainers = {}
NotDisplayedContainersIDS = {}
NotDisplayedContainersType = {}

function NestedContainers:CreateContainer(obj, container, containerButton)

    if NestedContainers:IsContainerDisplayed(container) == false then
        return
    end

     --found a container, so create a button for it...
    containerButton = obj:addContainerButton(container:getInventory(), container:getTex(), container:getName(), container:getName())
    if(container:getVisual() and container:getClothingItem()) then
        local tint = container:getVisual():getTint(container:getClothingItem());
        containerButton:setTextureRGBA(tint:getRedFloat(), tint:getGreenFloat(), tint:getBlueFloat(), 1.0);
    end

    -- Do it again to check more containers inside the inventory or bags
    local it = container:getInventory():getItems()
    for i = 0, it:size()-1 do
        local item = it:get(i)
        if item:getCategory() == "Container" then
            NestedContainers:CreateContainer(obj, item, containerButton)
        end
    end
end

function NestedContainers:CanPutIn(container, player, items, minWeight)

    local parentContainer = nil
    local currentContainer = container

    -- get InventoryContainer from ItemContainer
    local inventoryContainer = container:getContainingItem()

    -- Get the container this item is inside of aka parent container as an InventoryContainer
    if inventoryContainer ~= nil then
        parentContainer = inventoryContainer:getContainer()
    end

    --If a container other than the player inventory exists, the program checks the weight of the topmost container,
    -- which is the one that other containers were placed into first, and then proceeds to check the lower containers
    -- in a cascading manner until all the nested containers have been accounted for.
    if parentContainer ~= nil and parentContainer ~= player:getInventory() and not container:getType() == "floor" then
        currentContainer = parentContainer
        if not NestedContainers:CanPutIn(parentContainer, player, items, minWeight) then
            return false
        end
    end

    if #items == 1 then
        return container:hasRoomFor(player, items[1])
    elseif #items > 0 then
        return container:hasRoomFor(player, minWeight)
    end

    return false
end

-- Different name to the other one because I was having some errors when they had the same name.
-- Used in DraggedItems.lua
function NestedContainers:CanTransferItem(container, player, item)

    --local canPutIn = false
    local parentContainer = nil
    local currentContainer = container

    -- get InventoryContainer from ItemContainer
    local inventoryContainer = container:getContainingItem()

    -- Get the container this item is inside of aka parent container as an InventoryContainer
    if inventoryContainer ~= nil then
        parentContainer = inventoryContainer:getContainer()
    end

    --If a container other than the player inventory exists, the program checks the weight of the topmost container,
    -- which is the one that other containers were placed into first, and then proceeds to check the lower containers
    -- in a cascading manner until all the nested containers have been accounted for.
    if parentContainer ~= nil and parentContainer ~= player:getInventory() then
        currentContainer = parentContainer
        if not NestedContainers:CanTransferItem(parentContainer, player, item) then
            return false
        end
    end
    if container:getType()=="floor" then
        return true
    else
        return container:hasRoomFor(player, item)
    end
end

-- Different name to the other one because I was having some errors when they had the same name.
-- Used in DraggedItems.lua
function NestedContainers:CanTransferItemWeight(container, player, item, weight)

    --local canPutIn = false
    local parentContainer = nil
    local currentContainer = container

    -- get InventoryContainer from ItemContainer
    local inventoryContainer = container:getContainingItem()

    -- Get the container this item is inside of aka parent container as an InventoryContainer
    if inventoryContainer ~= nil then
        parentContainer = inventoryContainer:getContainer()
    end

    --If a container other than the player inventory exists, the program checks the weight of the topmost container,
    -- which is the one that other containers were placed into first, and then proceeds to check the lower containers
    -- in a cascading manner until all the nested containers have been accounted for.
    if parentContainer ~= nil and parentContainer ~= player:getInventory() then
        currentContainer = parentContainer
        if not NestedContainers:CanTransferItemWeight(parentContainer, player, item, weight) then
            return false
        end
    end

    if container:getType()=="floor" then
        return true
    else
        return container:hasRoomFor(player, weight)
    end
end

function NestedContainers:IsContainerDisplayed(container)
    if ContainValue(NotDisplayedContainersIDS, container:getID()) then
        return false
    elseif ContainValue(NotDisplayedContainersType, container:getType()) then
        return false
    else
        return true
    end
end

function NestedContainers:IsSpecificContainerDisplayed(container)
    return not ContainValue(NotDisplayedContainersIDS, container:getID())
end

function NestedContainers:IsContainerTypeDisplayed(container)
    return not ContainValue(NotDisplayedContainersType, container:getType())
end

--- Specific Container Display
NestedContainers.ToggleDisplay = function(container)
    local containerID = container:getID()
    if NestedContainers:IsContainerDisplayed(container) then
        table.insert(NotDisplayedContainersIDS, containerID)
    else
        table.remove(NotDisplayedContainersIDS, IndexOfValue(NotDisplayedContainersType, containerID))
    end

    ISInventoryPage.renderDirty = true;
end
---

--- Container Type Display
NestedContainers.ToggleDisplayType = function(container)
    local containerType =  container:getType()
    if NestedContainers:IsContainerDisplayed(container) then
        table.insert(NotDisplayedContainersType, containerType)
    else
        table.remove(NotDisplayedContainersType, IndexOfValue(NotDisplayedContainersType, containerType))
    end

    ISInventoryPage.renderDirty = true;
end
---

function ISInventoryTransferAction:isValid()
    if not self.item then
        return false;
    end
    self.dontAdd = false;
    if not self.destContainer or not self.srcContainer then return false; end
    if self.allowMissingItems and not self.srcContainer:contains(self.item) then -- if the item is destroyed before, for example when crafting something, we want to transfer the items left back to their original position, but some might be destroyed by the recipe (like molotov, the gas can will be returned, but the ripped sheet is destroyed)
        --		self:stop();
        self.dontAdd = true;
        return true;
    end
    if (not self.destContainer:isExistYet()) or (not self.srcContainer:isExistYet()) then
        return false
    end

    local parent = self.srcContainer:getParent()
    -- Duplication exploit: drag items from a corpse to another container while pickup up the corpse.
    -- ItemContainer:isExistYet() would detect this if SystemDisabler.doWorldSyncEnable was true.
    if instanceof(parent, "IsoDeadBody") and parent:getStaticMovingObjectIndex() == -1 then
        return false
    end

    -- Don't fail if the item was transferred by a previous action.
    if self:isAlreadyTransferred(self.item) then
        return true
    end

    -- Limit items per container in MP
    if isClient() then
        if not isItemTransactionConsistent(self.item, self.srcContainer, self.destContainer) then
            return false
        end
        local limit = getServerOptions():getInteger("ItemNumbersLimitPerContainer");
        if limit > 0 and (not instanceof(self.destContainer:getParent(), "IsoGameCharacter")) then
            --allow dropping full bags on an empty square or put full container in an empty container
            if not self.destContainer:getItems():isEmpty() then
                local destRoot = self:findRootInventory(self.destContainer);
                local srcRoot = self:findRootInventory(self.srcContainer);
                --total count remains the same if the same root container
                if srcRoot ~= destRoot then
                    local tranferItemsNum = 1;
                    if self.item:getCategory() == "Container" then
                        tranferItemsNum = self:countItemsRecursive({self.item:getInventory()}, 1);
                    end;
                    --count items from the root container
                    local destContainerItemsNum = self:countItemsRecursive({destRoot}, 0);
                    --if destination is an item then add 1
                    if destRoot:getContainingItem() then destContainerItemsNum = destContainerItemsNum + 1; end;
                    --total items must not exceed the server limit
                    if destContainerItemsNum + tranferItemsNum > limit then
                        return false;
                    end;
                end;
            end;
        end;
    end;

    if ISTradingUI.instance and ISTradingUI.instance:isVisible() then
        return false;
    end
    if not self.srcContainer:contains(self.item) then
        return false;
    end
    if self.srcContainer == self.destContainer then return false; end

    if self.destContainer:getType()=="floor" then
        if instanceof(self.item, "Moveable") and self.item:getSpriteGrid()==nil then
            if not self.item:CanBeDroppedOnFloor() then
                return false;
            end
        end
        if self:getNotFullFloorSquare(self.item) == nil then
            return false;
        end
    --elseif not self.destContainer:hasRoomFor(self.character, self.item) then
    --    return false;
    elseif not NestedContainers:CanTransferItem(self.destContainer, self.character, self.item) then
        return false;
    end

    if not self.srcContainer:isRemoveItemAllowed(self.item) then
        return false;
    end
    if not self.destContainer:isItemAllowed(self.item) then
        return false;
    end
    if self.item:getContainer() == self.srcContainer and not self.destContainer:isInside(self.item) then
        return true;
    end
    if isClient() and self.srcContainer:getSourceGrid() and SafeHouse.isSafeHouse(self.srcContainer:getSourceGrid(), self.character:getUsername(), true) then
        return false;
    end
    return false;
end

local sqsContainers = {}
local sqsVehicles = {}
function ISInventoryPage:refreshBackpacks()
    self.buttonPool = self.buttonPool or {}
    for i,v in ipairs(self.backpacks) do
        self:removeChild(v)
        table.insert(self.buttonPool, i, v)
    end

    local floorContainer = ISInventoryPage.GetFloorContainer(self.player)

    self.inventoryPane.lastinventory = self.inventoryPane.inventory

    self.inventoryPane:hideButtons()

    local oldNumBackpacks = #self.backpacks
    table.wipe(self.backpacks)

    local containerButton = nil

    local playerObj = getSpecificPlayer(self.player)

    triggerEvent("OnRefreshInventoryWindowContainers", self, "begin")

    if self.onCharacter then
        local name = getText("IGUI_InventoryName", playerObj:getDescriptor():getForename(), playerObj:getDescriptor():getSurname())
        containerButton = self:addContainerButton(playerObj:getInventory(), self.invbasic, name, nil)
        containerButton.capacity = self.inventory:getMaxWeight()
        if not self.capacity then
            self.capacity = containerButton.capacity
        end
        local it = playerObj:getInventory():getItems()
        for i = 0, it:size()-1 do
            local item = it:get(i)
                -- found a container, so create a button for it...
            if item:getCategory() == "Container" or item:getType() == "KeyRing" then
                NestedContainers:CreateContainer(self, item, containerButton)
            end
        end
    elseif playerObj:getVehicle() then
        local vehicle = playerObj:getVehicle()
        for partIndex=1,vehicle:getPartCount() do
            local vehiclePart = vehicle:getPartByIndex(partIndex-1)
            if vehiclePart:getItemContainer() and vehicle:canAccessContainer(partIndex-1, playerObj) then
                local tooltip = getText("IGUI_VehiclePart" .. vehiclePart:getItemContainer():getType())
                containerButton = self:addContainerButton(vehiclePart:getItemContainer(), nil, tooltip, nil)
                self:checkExplored(containerButton.inventory, playerObj)
            end
        end
    else
        local cx = playerObj:getX()
        local cy = playerObj:getY()
        local cz = playerObj:getZ()

        -- Do floor
        local container = floorContainer
        container:removeItemsFromProcessItems()
        container:clear()

        local sqs = sqsContainers
        table.wipe(sqs)

        local dir = playerObj:getDir()
        local lookSquare = nil
        if self.lookDir ~= dir then
            self.lookDir = dir
            local dx,dy = 0,0
            if dir == IsoDirections.NW or dir == IsoDirections.W or dir == IsoDirections.SW then
                dx = -1
            end
            if dir == IsoDirections.NE or dir == IsoDirections.E or dir == IsoDirections.SE then
                dx = 1
            end
            if dir == IsoDirections.NW or dir == IsoDirections.N or dir == IsoDirections.NE then
                dy = -1
            end
            if dir == IsoDirections.SW or dir == IsoDirections.S or dir == IsoDirections.SE then
                dy = 1
            end
            lookSquare = getCell():getGridSquare(cx + dx, cy + dy, cz)
        end

        local vehicleContainers = sqsVehicles
        table.wipe(vehicleContainers)

        for dy=-1,1 do
            for dx=-1,1 do
                local square = getCell():getGridSquare(cx + dx, cy + dy, cz)
                if square then
                    table.insert(sqs, square)
                end
            end
        end

        for _,gs in ipairs(sqs) do
            -- stop grabbing thru walls...
            local currentSq = playerObj:getCurrentSquare()
            if gs ~= currentSq and currentSq and currentSq:isBlockedTo(gs) then
                gs = nil
            end

            -- don't show containers in safehouse if you're not allowed
            if gs and isClient() and SafeHouse.isSafeHouse(gs, playerObj:getUsername(), true) and not getServerOptions():getBoolean("SafehouseAllowLoot") then
                gs = nil
            end

            if gs ~= nil then
                local numButtons = #self.backpacks

                local wobs = gs:getWorldObjects()
                for i = 0, wobs:size()-1 do
                    local o = wobs:get(i)
                    -- FIXME: An item can be in only one container in coop the item won't be displayed for every player.
                    floorContainer:AddItem(o:getItem())
                    if o:getItem() and o:getItem():getCategory() == "Container" then
                        local item = o:getItem()
                        NestedContainers:CreateContainer(self, item, containerButton)
                    end
                end

                local sobs = gs:getStaticMovingObjects()
                for i = 0, sobs:size()-1 do
                    local so = sobs:get(i)
                    if so:getContainer() ~= nil then
                        local title = getTextOrNull("IGUI_ContainerTitle_" .. so:getContainer():getType()) or ""
                        containerButton = self:addContainerButton(so:getContainer(), nil, title, nil)
                        self:checkExplored(containerButton.inventory, playerObj)
                    end
                end

                local obs = gs:getObjects()
                for i = 0, obs:size()-1 do
                    local o = obs:get(i)
                    for containerIndex = 1,o:getContainerCount() do
                        local container = o:getContainerByIndex(containerIndex-1)
                        local title = getTextOrNull("IGUI_ContainerTitle_" .. container:getType()) or ""
                        containerButton = self:addContainerButton(container, nil, title, nil)

                        local it = container:getItems()
                        for i = 0, it:size()-1 do
                            local item = it:get(i)
                            if item:getCategory() == "Container" then
                                NestedContainers:CreateContainer(self, item, containerButton)
                            end
                        end

                        if instanceof(o, "IsoThumpable") and o:isLockedToCharacter(playerObj) then
                            containerButton.onclick = nil
                            containerButton.onmousedown = nil
                            containerButton:setOnMouseOverFunction(nil)
                            containerButton:setOnMouseOutFunction(nil)
                            containerButton.textureOverride = getTexture("media/ui/lock.png")
                        end

                        if instanceof(o, "IsoThumpable") and o:isLockedByPadlock() and playerObj:getInventory():haveThisKeyId(o:getKeyId()) then
                            containerButton.textureOverride = getTexture("media/ui/lockOpen.png")
                        end

                        self:checkExplored(containerButton.inventory, playerObj)
                    end
                end

                local vehicle = gs:getVehicleContainer()
                if vehicle and not vehicleContainers[vehicle] then
                    vehicleContainers[vehicle] = true
                    for partIndex=1,vehicle:getPartCount() do
                        local vehiclePart = vehicle:getPartByIndex(partIndex-1)
                        if vehiclePart:getItemContainer() and vehicle:canAccessContainer(partIndex-1, playerObj) then
                            local tooltip = getText("IGUI_VehiclePart" .. vehiclePart:getItemContainer():getType())
                            containerButton = self:addContainerButton(vehiclePart:getItemContainer(), nil, tooltip, nil)
                            self:checkExplored(containerButton.inventory, playerObj)

                            local it = vehiclePart:getItemContainer():getItems()
                            for i = 0, it:size()-1 do
                                local item = it:get(i)
                                if item:getCategory() == "Container" then
                                    NestedContainers:CreateContainer(self, item, containerButton)
                                end
                            end
                        end
                    end
                end

                if (numButtons < #self.backpacks) and (gs == lookSquare) then
                    self.inventoryPane.inventory = self.backpacks[numButtons + 1].inventory
                end
            end
        end

        triggerEvent("OnRefreshInventoryWindowContainers", self, "beforeFloor")

        local title = getTextOrNull("IGUI_ContainerTitle_floor") or ""
        containerButton = self:addContainerButton(floorContainer, ContainerButtonIcons.floor, title, nil)
        containerButton.capacity = floorContainer:getMaxWeight()
    end

    triggerEvent("OnRefreshInventoryWindowContainers", self, "buttonsAdded")

    local found = false
    local foundIndex = -1
    for index,containerButton in ipairs(self.backpacks) do
        if containerButton.inventory == self.inventoryPane.inventory then
            foundIndex = index
            found = true
            break
        end
    end

    self.inventoryPane.inventory = self.inventoryPane.lastinventory
    self.inventory = self.inventoryPane.inventory
    if self.backpackChoice ~= nil and playerObj:getJoypadBind() ~= -1 then
        if not self.onCharacter and oldNumBackpacks == 1 and #self.backpacks > 1 then
            self.backpackChoice = 1
        end
        if self.backpackChoice > #self.backpacks then
            self.backpackChoice = 1
        end
        if self.backpacks[self.backpackChoice] ~= nil then
            self.inventoryPane.inventory = self.backpacks[self.backpackChoice].inventory
            self.capacity = self.backpacks[self.backpackChoice].capacity
        end
    else
        if not self.onCharacter and oldNumBackpacks == 1 and #self.backpacks > 1 then
            self.inventoryPane.inventory = self.backpacks[1].inventory
            self.capacity = self.backpacks[1].capacity
        elseif found then
            self.inventoryPane.inventory = self.backpacks[foundIndex].inventory
            self.capacity = self.backpacks[foundIndex].capacity
        elseif not found and #self.backpacks > 0 then
            if self.backpacks[1] and self.backpacks[1].inventory then
                self.inventoryPane.inventory = self.backpacks[1].inventory
                self.capacity = self.backpacks[1].capacity
            end
        elseif self.inventoryPane.lastinventory ~= nil then
            self.inventoryPane.inventory = self.inventoryPane.lastinventory
        end
    end

    -- ISInventoryTransferAction sometimes turns the player to face a container.
    -- Which container is selected changes as the player changes direction.
    -- Although ISInventoryTransferAction forces a container to be selected,
    -- sometimes the action completes before the player finishes turning.
    if self.forceSelectedContainer then
        if self.forceSelectedContainerTime > getTimestampMs() then
            for _,containerButton in ipairs(self.backpacks) do
                if containerButton.inventory == self.forceSelectedContainer then
                    self.inventoryPane.inventory = containerButton.inventory
                    self.capacity = containerButton.capacity
                    break
                end
            end
        else
            self.forceSelectedContainer = nil
        end
    end

    if isClient() and (not self.isCollapsed) and (self.inventoryPane.inventory ~= self.inventoryPane.lastinventory) then
        self.inventoryPane.inventory:requestSync()
    end

    self.inventoryPane:bringToTop()
    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()

    self.inventory = self.inventoryPane.inventory

    self.title = nil
    for k,containerButton in ipairs(self.backpacks) do
        if containerButton.inventory == self.inventory then
            self.selectedButton = containerButton;
            containerButton:setBackgroundRGBA(0.7, 0.7, 0.7, 1.0)
            self.title = containerButton.name
        else
            containerButton:setBackgroundRGBA(0.0, 0.0, 0.0, 0.0)
        end
    end

    if self.inventoryPane ~= nil then
        self.inventoryPane:refreshContainer()
    end

    self:refreshWeight()

    self:syncToggleStove()

    triggerEvent("OnRefreshInventoryWindowContainers", self, "end")
end

function ISInventoryPage:canPutIn()
    local playerObj = getSpecificPlayer(self.player)
    local container = self.mouseOverButton and self.mouseOverButton.inventory or nil
    if not container then
        return false
    end
    local items = {}
    local minWeight = 100000
    local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
    for i,item in ipairs(dragging) do
        local itemOK = true
        if item:isFavorite() and not container:isInCharacterInventory(playerObj) then
            itemOK = false
        end
        if container:isInside(item) then
            itemOK = false
        end
        if container:getType() == "floor" and item:getWorldItem() then
            itemOK = false
        end
        if item:getContainer() == container then
            itemOK = false
        end
        if not container:isItemAllowed(item) then
            itemOK = false
        end
        if itemOK then
            table.insert(items, item)
        end
        if item:getUnequippedWeight() < minWeight then
            minWeight = item:getUnequippedWeight()
        end
    end

    return NestedContainers:CanPutIn(container, playerObj, items, minWeight)
end

function ISInventoryPane:canPutIn()
    local playerObj = getSpecificPlayer(self.player)

    if self.inventory == nil then
        return false;
    end
    if self.inventory:getType() == "floor" then
        return true;
    end

    if self.inventory:getParent() == playerObj then
        return true;
    end

    local items = {}
    -- If the lightest item fits, allow the transfer.
    local minWeight = 100000
    local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
    for i,v in ipairs(dragging) do
        local itemOK = true
        if v:isFavorite() and not self.inventory:isInCharacterInventory(playerObj) then
            itemOK = false
        end
        -- you can't draw the container in himself
        if (self.inventory:isInside(v)) then
            itemOK = false;
        end
        if self.inventory:getType() == "floor" and v:getWorldItem() then
            itemOK = false
        end
        if v:getContainer() == self.inventory then
            itemOK = false
        end
        local inv = self.inventory;
        --        if self.mouseOverButton and self.mouseOverButton.inventory then
        --            inv = self.mouseOverButton.inventory;
        --        end
        if not inv:isItemAllowed(v) then
            itemOK = false;
        end
        if itemOK then
            table.insert(items, v)
        end
        if v:getUnequippedWeight() < minWeight then
            minWeight = v:getUnequippedWeight()
        end
    end

    return NestedContainers:CanPutIn(self.inventory, playerObj, items, minWeight)
end

function ISInventoryPane:new (x, y, width, height, inventory, zoom)
    local o = {}
    --o.data = {}
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x;
    o.y = y;
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.width = width;
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = false;
    o.anchorTop = true;
    o.anchorBottom = false;
    o.inventory = inventory;
    o.zoom = zoom;
    o.mode = "details";
    o.column2 = 30;
    o.column3 = 140;
    o.column4 = o.width;
    o.items = {}
    o.selected = {}
    o.previousMouseUp = nil;
    local font = getCore():getOptionInventoryFont()
    if font == "Large" then
        o.font = UIFont.Large
    elseif font == "Small" then
        o.font = UIFont.Small
    else
        o.font = UIFont.Medium
    end
    if zoom > 1.5 then
        o.font = UIFont.Large;
    end
    o.fontHgt = getTextManager():getFontFromEnum(o.font):getLineHeight()
    o.itemHgt = math.ceil(math.max(18, o.fontHgt) * o.zoom)
    o.texScale = math.min(32, (o.itemHgt - 2)) / 32
    o.draggedItems = DraggedItems:new(o)

    o.treeexpicon = getTexture("media/ui/TreeExpanded.png");
    o.treecolicon = getTexture("media/ui/TreeCollapsed.png");
    o.expandicon = getTexture("media/ui/TreeExpandAll.png");
    o.filtericon = getTexture("media/ui/TreeFilter.png");
    o.collapseicon = getTexture("media/ui/TreeCollapseAll.png");
    o.equippedItemIcon = getTexture("media/ui/icon.png");
    o.equippedInHotbar = getTexture("media/ui/iconInHotbar.png");
    o.brokenItemIcon = getTexture("media/ui/icon_broken.png");
    o.frozenItemIcon = getTexture("media/ui/icon_frozen.png");
    o.poisonIcon = getTexture("media/ui/SkullPoison.png");
    o.itemSortFunc = ISInventoryPane.itemSortByNameInc; -- how to sort the items...
    o.favoriteStar = getTexture("media/ui/FavoriteStar.png");
    return o
end

local function predicateNotBroken(item)
    return not item:isBroken()
end

-- MAIN METHOD FOR CREATING RIGHT CLICK CONTEXT MENU FOR INVENTORY ITEMS
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    if getCore():getGameMode() == "Tutorial" then
        Tutorial1.createInventoryContextMenu(player, isInPlayerInventory, items ,x ,y);
        return;
    end
    if ISInventoryPaneContextMenu.dontCreateMenu then return; end

    -- if the game is paused, we don't show the item context menu
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        return;
    end

    -- items is a list that could container either InventoryItem objects, OR a table with a list of InventoryItem objects in .items
    -- Also there is a duplicate entry first in the list, so ignore that.

    --print("Context menu for player "..player);
    --print("Creating context menu for inventory items");
    local context = ISContextMenu.get(player, x, y);
    -- avoid doing action while trading (you could eat half an apple and still trade it...)
    --    if ISTradingUI.instance and ISTradingUI.instance:isVisible() then
    --        context:addOption(getText("IGUI_TradingUI_CantRightClick"), nil, nil);
    --        return;
    --    end

    context.origin = origin;
    local itemsCraft = {};
    local c = 0;
    local isAllFood = true;
    local isWeapon = nil;
    local isHandWeapon = nil;
    local isAllPills = true;
    local clothing;
    local recipe = nil;
    local evorecipe = nil;
    local baseItem = nil;
    local isAllLiterature = true;
    local canBeActivated = nil;
    local isAllBandage = true;
    local unequip = nil;
    local isReloadable = false;
    local waterContainer = nil;
    local canBeDry = nil;
    local canBeEquippedBack = nil;
    local twoHandsItem = nil;
    local brokenObject = nil;
    local canBeRenamed = nil;
    local canBeRenamedFood = nil;
    local pourOnGround = nil
    local canBeWrite = nil;
    local force2Hands = nil;
    local remoteController = nil;
    local remoteControllable = nil;
    local generator = nil;
    local corpse = nil;
    local alarmClock = nil;
    local inPlayerInv = nil;
    local drainable = nil;
    local map = nil;
    local carBattery = nil;
    local carBatteryCharger = nil;
    local clothingRecipe = nil;
    local clothingItemExtra = nil;
    local magazine = nil;
    local bullet = nil;
    local hairDye = nil;
    local makeup = nil;

    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

    ISInventoryPaneContextMenu.removeToolTip();

    getCell():setDrag(nil, player);

    for _,tooltip in ipairs(ISInventoryPaneContextMenu.tooltipsUsed) do
        table.insert(ISInventoryPaneContextMenu.tooltipPool, tooltip);
    end
    --    print('reused ',#ISInventoryPaneContextMenu.tooltipsUsed,' inventory tooltips')
    table.wipe(ISInventoryPaneContextMenu.tooltipsUsed);

    local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
    local testItem = nil;
    local editItem = nil;
    for i,v in ipairs(items) do
        testItem = v;
        if not instanceof(v, "InventoryItem") then
            --print(#v.items);
            if #v.items == 2 then
                editItem = v.items[1];
            end
            testItem = v.items[1];
        else
            editItem = v
        end
        if instanceof(testItem, "Key") or testItem:getType() == "KeyRing" then
            canBeRenamed = testItem;
        end
        if testItem:getClothingItemExtraOption() then
            clothingItemExtra = testItem;
        end
        if not testItem:isCanBandage() then
            isAllBandage = false;
        end
        if testItem:getCategory() ~= "Food" or testItem:getScriptItem():isCantEat() then
            isAllFood = false;
        end
        if testItem:getCategory() == "Clothing" then
            clothing = testItem;
        end
        if (testItem:getType() == "DishCloth" or testItem:getType() == "BathTowel") and playerObj:getBodyDamage():getWetness() > 0 then
            canBeDry = true;
        end
        if testItem:isHairDye() then
            hairDye = testItem;
        end
        if testItem:getMakeUpType() then
            makeup = testItem;
        end
        if testItem:isBroken() or testItem:getCondition() < testItem:getConditionMax() then
            brokenObject = testItem;
        end
        if instanceof(testItem, "DrainableComboItem") then
            drainable = testItem;
        end
        if testItem:getContainer() and testItem:getContainer():isInCharacterInventory(playerObj) then
            inPlayerInv = testItem;
        end
        if testItem:getMaxAmmo() > 0 and not instanceof(testItem, "HandWeapon") then
            magazine = testItem;
        end
        if testItem:getDisplayCategory() == "Ammo" then
            bullet = testItem;
        end
        if playerObj:isEquipped(testItem) then
            unequip = testItem;
        end
        if ISInventoryPaneContextMenu.startWith(testItem:getType(), "CarBattery") and testItem:getType() ~= "CarBatteryCharger" then
            carBattery = testItem;
        end
        if testItem:getType() == "CarBatteryCharger" then
            carBatteryCharger = testItem;
        end
        if testItem:IsMap() then
            map = testItem;
        end
        if testItem:getCategory() ~= "Literature" or testItem:canBeWrite() then
            isAllLiterature = false;
        end
        if testItem:getCategory() == "Literature" and testItem:canBeWrite() then
            canBeWrite = testItem;
        end
        if testItem:canBeActivated() and (playerObj:isHandItem(testItem) or playerObj:isAttachedItem(testItem)) then
            canBeActivated = testItem;
        end
        -- all items can be equiped
        if (instanceof(testItem, "HandWeapon") and testItem:getCondition() > 0) or (instanceof(testItem, "InventoryItem") and not instanceof(testItem, "HandWeapon")) then
            isWeapon = testItem;
        end
        if instanceof(testItem, "HandWeapon") then
            isHandWeapon = testItem
        end
        -- remote controller
        if testItem:isRemoteController() then
            remoteController = testItem;
        end
        if isHandWeapon and isHandWeapon:canBeRemote() then
            remoteControllable = isHandWeapon;
        end
        if instanceof(testItem, "InventoryContainer") and testItem:canBeEquipped() == "Back" and not playerObj:isEquippedClothing(testItem) then
            canBeEquippedBack = testItem;
        end
        if instanceof(testItem, "InventoryContainer") then
            canBeRenamed = testItem;
        end
        if testItem:getType() == "Generator" then
            generator = testItem;
        end
        if testItem:getType() == "CorpseMale" or testItem:getType() == "CorpseFemale" then
            corpse = testItem;
        end
        if instanceof(testItem, "AlarmClock") or instanceof(testItem, "AlarmClockClothing") then
            alarmClock = testItem;
        end
        if instanceof(testItem, "Food")  then -- Check if it's a recipe from the evolved recipe and have at least 3 ingredient, so we can name them
            for i=0,getEvolvedRecipes():size()-1 do
                local evoRecipeTest = getEvolvedRecipes():get(i);
                if evoRecipeTest:isResultItem(testItem) and testItem:haveExtraItems() and testItem:getExtraItems():size() >= 3 then
                    canBeRenamedFood = testItem;
                end
            end
        end
        if testItem:isTwoHandWeapon() and testItem:getCondition() > 0 then
            twoHandsItem = testItem;
        end
        if testItem:isRequiresEquippedBothHands() and testItem:getCondition() > 0 then
            force2Hands = testItem;
        end
        --> Stormy
        if(not getCore():isNewReloading() and ReloadUtil:isReloadable(testItem, playerObj)) then
            isReloadable = true;
        end
        -->> Stormy
        if not ISInventoryPaneContextMenu.startWith(testItem:getType(), "Pills") then
            isAllPills = false;
        end
        if testItem:isWaterSource() then
            waterContainer = testItem;
        end
        if not instanceof(testItem, "Literature") and ISInventoryPaneContextMenu.canReplaceStoreWater(testItem) then
            pourOnGround = testItem
        end
        -- if item is not a clothing, use ClothingRecipesDefinitions
        if not playerObj:isEquippedClothing(testItem) and (ClothingRecipesDefinitions[testItem:getType()] or (testItem:getFabricType() and instanceof(testItem, "Clothing"))) then
            clothingRecipe = testItem;
        end
        evorecipe = RecipeManager.getEvolvedRecipe(testItem, playerObj, containerList, true);
        if evorecipe then
            baseItem = testItem;
        end
        itemsCraft[c + 1] = testItem;

        c = c + 1;
        -- you can equip only 1 weapon
        if c > 1 then
            --~ 			isWeapon = false;
            isHandWeapon = nil
            isAllLiterature = false;
            canBeActivated = nil;
            isReloadable = false;
            unequip = nil;
            canBeEquippedBack = nil;
            brokenObject = nil;
        end
    end

    triggerEvent("OnPreFillInventoryObjectContextMenu", player, context, items);

    context.blinkOption = ISInventoryPaneContextMenu.blinkOption;

    if editItem and c == 1 and ((isClient() and playerObj:getAccessLevel() ~= "None" and playerObj:getAccessLevel() ~= "Observer") and playerObj:getInventory():contains(editItem, true) or isDebugEnabled()) then
        local option = context:addDebugOption(getText("ContextMenu_EditItem"), items, ISInventoryPaneContextMenu.onEditItem, playerObj, testItem);
    end

    -- check the recipe
    if #itemsCraft > 0 then
        local sameType = true
        for i=2,#itemsCraft do
            if itemsCraft[i]:getFullType() ~= itemsCraft[1]:getFullType() then
                sameType = false
                break
            end
        end
        if sameType then
            recipe = RecipeManager.getUniqueRecipeItems(itemsCraft[1], playerObj, containerList);
        end
    end


    if c == 0 then
        context:setVisible(false);
        return;
    end

    local loot = getPlayerLoot(player);
    --~ 	context:addOption("Information", items, ISInventoryPaneContextMenu.onInformationItems);
    if not isInPlayerInventory then
        ISInventoryPaneContextMenu.doGrabMenu(context, items, player);
    end
    if evorecipe then
        ISInventoryPaneContextMenu.doEvorecipeMenu(context, items, player, evorecipe, baseItem, containerList);
    end

    if(isInPlayerInventory and loot.inventory ~= nil and loot.inventory:getType() ~= "floor" ) and playerObj:getJoypadBind() == -1 then
        if ISInventoryPaneContextMenu.isAnyAllowed(loot.inventory, items) and not ISInventoryPaneContextMenu.isAllFav(items) then
            local label = loot.title and getText("ContextMenu_PutInContainer", loot.title) or getText("ContextMenu_Put_in_Container")
            context:addOption(label, items, ISInventoryPaneContextMenu.onPutItems, player);
        end
    end

    -- Move To
    local moveItems = ISInventoryPane.getActualItems(items)
    if #moveItems > 0 and playerObj:getJoypadBind() ~= -1 then
        local subMenu = nil
        local moveTo0 = ISInventoryPaneContextMenu.canUnpack(moveItems, player)
        local moveToWorn = {}
        local wornItems = playerObj:getWornItems()
        for i=1,wornItems:size() do
            local item = wornItems:get(i-1):getItem()
            local moveTo1 = ISInventoryPaneContextMenu.canMoveTo(moveItems, item, player)
            if moveTo1 then
                table.insert(moveToWorn, moveTo1)
            end
        end
        local moveTo2 = ISInventoryPaneContextMenu.canMoveTo(moveItems, playerObj:getPrimaryHandItem(), player)
        local moveTo3 = ISInventoryPaneContextMenu.canMoveTo(moveItems, playerObj:getSecondaryHandItem(), player)
        local moveTo4 = ISInventoryPaneContextMenu.canMoveTo(moveItems, ISInventoryPage.floorContainer[player+1], player)
        local keyRings = {}
        local inventoryItems = playerObj:getInventory():getItems()
        for i=1,inventoryItems:size() do
            local item = inventoryItems:get(i-1)
            if item:getType() == "KeyRing" and ISInventoryPaneContextMenu.canMoveTo(moveItems, item, player) then
                table.insert(keyRings, item)
            end
        end
        local putIn = isInPlayerInventory and
                loot.inventory and loot.inventory:getType() ~= "floor" and
                ISInventoryPaneContextMenu.isAnyAllowed(loot.inventory, items) and
                not ISInventoryPaneContextMenu.isAllFav(moveItems)
        if moveTo0 or (#moveToWorn > 0) or moveTo2 or moveTo3 or moveTo4 or (#keyRings > 0) or putIn then
            local option = context:addOption(getText("ContextMenu_Move_To"))
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)
            local subOption
            if moveTo0 then
                subOption = subMenu:addOption(getText("ContextMenu_MoveToInventory"), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, playerInv, player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, playerInv, moveItems) then
                    subOption.notAvailable = true
                end
            end
            for _,moveTo in ipairs(moveToWorn) do
                subOption = subMenu:addOption(moveTo:getName(), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, moveTo:getInventory(), player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, moveTo, moveItems) then
                    subOption.notAvailable = true
                end
            end
            if moveTo2 then
                subOption = subMenu:addOption(moveTo2:getName(), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, moveTo2:getInventory(), player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, moveTo2, moveItems) then
                    subOption.notAvailable = true
                end
            end
            if moveTo3 then
                subOption = subMenu:addOption(moveTo3:getName(), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, moveTo3:getInventory(), player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, moveTo3, moveItems) then
                    subOption.notAvailable = true
                end
            end
            for _,moveTo in ipairs(keyRings) do
                subOption = subMenu:addOption(moveTo:getName(), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, moveTo:getInventory(), player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, moveTo, moveItems) then
                    subOption.notAvailable = true
                end
            end
            if putIn then
                subOption = subMenu:addOption(loot.title and loot.title or getText("ContextMenu_MoveToContainer"), moveItems, ISInventoryPaneContextMenu.onPutItems, player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, loot.inventory, moveItems) then
                    subOption.notAvailable = true
                end
            end
            if moveTo4 then
                subOption = subMenu:addOption(getText("ContextMenu_Floor"), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, moveTo4, player)
                if not ISInventoryPaneContextMenu.hasRoomForAny(playerObj, moveTo4, moveItems) then
                    subOption.notAvailable = true
                end
            end
        end

        if isInPlayerInventory then
            context:addOption(getText("IGUI_invpage_Transfer_all"), getPlayerInventory(player), ISInventoryPage.transferAll)
        else
            context:addOption(getText("IGUI_invpage_Loot_all"), loot, ISInventoryPage.lootAll)
        end
    end

    if #moveItems and playerObj:getJoypadBind() == -1 then
        if ISInventoryPaneContextMenu.canUnpack(moveItems, player) then
            context:addOption(getText("ContextMenu_Unpack"), moveItems, ISInventoryPaneContextMenu.onMoveItemsTo, playerObj:getInventory(), player)
        end
    end

    if inPlayerInv then
        if inPlayerInv:isFavorite() then
            context:addOption(getText("ContextMenu_Unfavorite"), moveItems, ISInventoryPaneContextMenu.onFavorite, inPlayerInv, false)
        else
            context:addOption(getText("IGUI_CraftUI_Favorite"), moveItems, ISInventoryPaneContextMenu.onFavorite, inPlayerInv, true)
        end
    end

    if not inPlayerInv and playerObj:getJoypadBind() ~= -1 then
        ISInventoryPaneContextMenu.doStoveMenu(context, player)
        ISInventoryPaneContextMenu.doTrashCanMenu(context, player)
    end

    if canBeEquippedBack then
        local option = context:addOption(getText("ContextMenu_Equip_on_your_Back"), items, ISInventoryPaneContextMenu.onWearItems, player);
        if playerObj:getClothingItem_Back() then
            local tooltip = ISInventoryPaneContextMenu.addToolTip()
            tooltip.description = getText("Tooltip_ReplaceWornItems") .. " <LINE> <INDENT:20> "
            tooltip.description = tooltip.description .. playerObj:getClothingItem_Back():getDisplayName()
            option.toolTip = tooltip
        end
    end

    if isAllFood then
        -- Some items have a custom menu option, such as "Smoke" or "Drink" instead of "Eat".
        -- If the selected items have different menu options, don't add any eat option.
        -- If a food item has no hunger reduction (like Cigarettes) it is impossible to eat
        -- some percentage, so we shouldn't show the submenu in such cases.
        local foodItems = ISInventoryPane.getActualItems(items)
        local foodByCmd = {}
        local cmd = nil
        local hungerNotZero = 0
        for i,k in ipairs(foodItems) do
            cmd = k:getCustomMenuOption() or getText("ContextMenu_Eat")
            foodByCmd[cmd] = true
            if k:getHungChange() < 0 then
                hungerNotZero = hungerNotZero + 1
            end
        end
        local cmdCount = 0
        for k,v in pairs(foodByCmd) do
            cmdCount = cmdCount + 1
        end
        if cmdCount == 1 then
            if hungerNotZero > 0 then
                local eatOption = context:addOption(cmd, items, nil)
                if playerObj:getMoodles():getMoodleLevel(MoodleType.FoodEaten) >= 3 and playerObj:getNutrition():getCalories() >= 1000 then
                    local tooltip = ISInventoryPaneContextMenu.addToolTip();
                    eatOption.notAvailable = true;
                    tooltip.description = getText("Tooltip_CantEatMore");
                    eatOption.toolTip = tooltip;
                else
                    local subMenuEat = context:getNew(context)
                    context:addSubMenu(eatOption, subMenuEat)
                    local option = subMenuEat:addOption(getText("ContextMenu_Eat_All"), items, ISInventoryPaneContextMenu.onEatItems, 1, player)
                    -- ISInventoryPaneContextMenu.addEatTooltip(option, foodItems, 1.0) -- commented out as the information provided can be confusing
                    -- this it to prevent eating smaller portions of food then their hunger value allows
                    local baseHunger = (math.abs(( foodItems[1]:getBaseHunger() * 100 ) )) +.001
                    local hungerChange = (math.abs(( foodItems[1]:getHungerChange() * 100 ) )) +.001
                    --print("Base Hunger" .. tostring(baseHunger))
                    --print("Hunger Change" .. tostring(hungerChange))
                    if (hungerChange >= 2 ) and ( hungerChange >= baseHunger/2 ) then
                        --print(tostring(baseHunger >= 2))
                        --print(tostring(hungerChange >= baseHunger/2))
                        option = subMenuEat:addOption(getText("ContextMenu_Eat_Half"), items, ISInventoryPaneContextMenu.onEatItems, 0.5, player)
                        -- ISInventoryPaneContextMenu.addEatTooltip(option, foodItems, 0.5) -- commented out as the information provided can be confusing
                    end
                    -- if baseHunger >= 4 and ( hungerChange >= baseHunger/4 ) then
                    if (hungerChange >= 4) and (hungerChange >= baseHunger/4) then
                        --print(tostring(baseHunger >= 4))
                        --print(tostring(hungerChange >= baseHunger/4))
                        option = subMenuEat:addOption(getText("ContextMenu_Eat_Quarter"), items, ISInventoryPaneContextMenu.onEatItems, 0.25, player)
                        -- ISInventoryPaneContextMenu.addEatTooltip(option, foodItems, 0.25) -- commented out as the information provided can be confusing
                    end
                end
            elseif cmd ~= getText("ContextMenu_Eat") then
                ISInventoryPaneContextMenu.doEatOption(context, cmd, items, player, playerObj, foodItems);
            end
        end
    end
    if generator then
        if not playerObj:isHandItem(generator) then
            context:addOption(getText("ContextMenu_GeneratorTake"), playerObj, ISInventoryPaneContextMenu.equipHeavyItem, generator);
        end
    elseif corpse then
        if not playerObj:isHandItem(corpse) then
            context:addOption(getText("ContextMenu_Grab_Corpse"), playerObj, ISInventoryPaneContextMenu.equipHeavyItem, corpse);
        end
    elseif twoHandsItem and not playerObj:isItemInBothHands(twoHandsItem) then
        context:addOption(getText("ContextMenu_Equip_Two_Hands"), items, ISInventoryPaneContextMenu.OnTwoHandsEquip, player);
    elseif force2Hands and not playerObj:isItemInBothHands(force2Hands) then
        context:addOption(getText("ContextMenu_Equip_Two_Hands"), items, ISInventoryPaneContextMenu.OnTwoHandsEquip, player);
    end
    if isWeapon and not isAllFood and not force2Hands and not clothing then
        ISInventoryPaneContextMenu.doEquipOption(context, playerObj, isWeapon, items, player);
    end
    -- weapon upgrades
    isWeapon = isHandWeapon -- to allow upgrading broken weapons
    local hasScrewdriver = playerInv:containsTagEvalRecurse("Screwdriver", predicateNotBroken)
    if isWeapon and instanceof(isWeapon, "HandWeapon") and hasScrewdriver then
        -- add parts
        local weaponParts = getSpecificPlayer(player):getInventory():getItemsFromCategory("WeaponPart");
        if weaponParts and not weaponParts:isEmpty() then
            local subMenuUp = context:getNew(context);
            local doIt = false;
            local addOption = false;
            local alreadyDoneList = {};
            for i=0, weaponParts:size() - 1 do
                local part = weaponParts:get(i);
                if part:getMountOn():contains(isWeapon:getFullType()) and not alreadyDoneList[part:getName()] then
                    if (part:getPartType() == "Scope") and not isWeapon:getScope() then
                        addOption = true;
                    elseif (part:getPartType() == "Clip") and not isWeapon:getClip() then
                        addOption = true;
                    elseif (part:getPartType() == "Sling") and not isWeapon:getSling() then
                        addOption = true;
                    elseif (part:getPartType() == "Stock") and not isWeapon:getStock() then
                        addOption = true;
                    elseif (part:getPartType() == "Canon") and not isWeapon:getCanon() then
                        addOption = true;
                    elseif (part:getPartType() == "RecoilPad") and not isWeapon:getRecoilpad() then
                        addOption = true;
                    end
                end
                if addOption then
                    doIt = true;
                    subMenuUp:addOption(weaponParts:get(i):getName(), isWeapon, ISInventoryPaneContextMenu.onUpgradeWeapon, part, getSpecificPlayer(player));
                    addOption = false;
                    alreadyDoneList[part:getName()] = true;
                end
            end
            if doIt then
                local upgradeOption = context:addOption(getText("ContextMenu_Add_Weapon_Upgrade"), items, nil);
                context:addSubMenu(upgradeOption, subMenuUp);
            end
        end
        -- remove parts
        if hasScrewdriver and (isWeapon:getScope() or isWeapon:getClip() or isWeapon:getSling() or isWeapon:getStock() or isWeapon:getCanon() or isWeapon:getRecoilpad()) then
            local removeUpgradeOption = context:addOption(getText("ContextMenu_Remove_Weapon_Upgrade"), items, nil);
            local subMenuRemove = context:getNew(context);
            context:addSubMenu(removeUpgradeOption, subMenuRemove);
            if isWeapon:getScope() then
                subMenuRemove:addOption(isWeapon:getScope():getName(), isWeapon, ISInventoryPaneContextMenu.onRemoveUpgradeWeapon, isWeapon:getScope(), getSpecificPlayer(player));
            end
            if isWeapon:getClip() then
                subMenuRemove:addOption(isWeapon:getClip():getName(), isWeapon, ISInventoryPaneContextMenu.onRemoveUpgradeWeapon, isWeapon:getClip(), getSpecificPlayer(player));
            end
            if isWeapon:getSling() then
                subMenuRemove:addOption(isWeapon:getSling():getName(), isWeapon, ISInventoryPaneContextMenu.onRemoveUpgradeWeapon, isWeapon:getSling(), getSpecificPlayer(player));
            end
            if isWeapon:getStock() then
                subMenuRemove:addOption(isWeapon:getStock():getName(), isWeapon, ISInventoryPaneContextMenu.onRemoveUpgradeWeapon, isWeapon:getStock(), getSpecificPlayer(player));
            end
            if isWeapon:getCanon() then
                subMenuRemove:addOption(isWeapon:getCanon():getName(), isWeapon, ISInventoryPaneContextMenu.onRemoveUpgradeWeapon, isWeapon:getCanon(), getSpecificPlayer(player));
            end
            if isWeapon:getRecoilpad() then
                subMenuRemove:addOption(isWeapon:getRecoilpad():getName(), isWeapon, ISInventoryPaneContextMenu.onRemoveUpgradeWeapon, isWeapon:getRecoilpad(), getSpecificPlayer(player));
            end
        end
    end

    if isHandWeapon and isHandWeapon:getExplosionTimer() > 0 then
        if isHandWeapon:getSensorRange() == 0 then
            context:addOption(getText("ContextMenu_TrapSetTimerExplosion"), isHandWeapon, ISInventoryPaneContextMenu.onSetBombTimer, player);
        else
            context:addOption(getText("ContextMenu_TrapSetTimerActivation"), isHandWeapon, ISInventoryPaneContextMenu.onSetBombTimer, player);
        end
    end
    -- place trap/bomb
    if isHandWeapon and isHandWeapon:canBePlaced() then
        context:addOption(getText("ContextMenu_TrapPlace", isHandWeapon:getName()), isHandWeapon, ISInventoryPaneContextMenu.onPlaceTrap, getSpecificPlayer(player));
    end
    -- link remote controller
    if remoteControllable then
        for i = 0, playerObj:getInventory():getItems():size() -1 do
            local item = playerObj:getInventory():getItems():get(i);
            if item:isRemoteController() and (item:getRemoteControlID() == -1 or item:getRemoteControlID() ~= remoteControllable:getRemoteControlID()) then
                context:addOption(getText("ContextMenu_TrapControllerLinkTo", item:getName()), remoteControllable, ISInventoryPaneContextMenu.OnLinkRemoteController, item, player);
            end
        end
        if remoteControllable:getRemoteControlID() ~= -1 then
            context:addOption(getText("ContextMenu_TrapControllerReset"), remoteControllable, ISInventoryPaneContextMenu.OnResetRemoteControlID, player);
        end
    end
    -- remote controller
    if remoteController then
        for i = 0, playerObj:getInventory():getItems():size() -1 do
            local item = playerObj:getInventory():getItems():get(i);
            if instanceof(item, "HandWeapon") and item:canBeRemote() and (item:getRemoteControlID() == -1 or item:getRemoteControlID() ~= remoteController:getRemoteControlID()) then
                context:addOption(getText("ContextMenu_TrapControllerLinkTo", item:getName()), item, ISInventoryPaneContextMenu.OnLinkRemoteController, remoteController, player);
            end
        end
        if remoteController:getRemoteControlID() ~= -1 then
            context:addOption(getText("ContextMenu_TrapControllerTrigger"), remoteController, ISInventoryPaneContextMenu.OnTriggerRemoteController, player);
            context:addOption(getText("ContextMenu_TrapControllerReset"), remoteController, ISInventoryPaneContextMenu.OnResetRemoteControlID, player);
        end
    end

    if isHandWeapon and instanceof(isHandWeapon, "HandWeapon") and isHandWeapon:getFireModePossibilities() and isHandWeapon:getFireModePossibilities():size() > 1 then
        ISInventoryPaneContextMenu.doChangeFireModeMenu(playerObj, isHandWeapon, context);
    end

    if isHandWeapon and instanceof(isHandWeapon, "HandWeapon") and getCore():isNewReloading() then
        ISInventoryPaneContextMenu.doReloadMenuForWeapon(playerObj, isHandWeapon, context);
        magazine = nil
        bullet = nil
    end

    if magazine and isInPlayerInventory then
        ISInventoryPaneContextMenu.doReloadMenuForMagazine(playerObj, magazine, context);
        ISInventoryPaneContextMenu.doMagazineMenu(playerObj, magazine, context);
        bullet = nil
    end
    if bullet and isInPlayerInventory then
        ISInventoryPaneContextMenu.doReloadMenuForBullets(playerObj, bullet, context);
    end

    --> Stormy
    if isInPlayerInventory and isReloadable then
        local item = items[1];
        -- if it's a header, we get our first item (the selected one)
        if not instanceof(items[1], "InventoryItem") then
            item = items[1].items[1];
        end
        context:addOption(ReloadUtil:getReloadText(item, playerObj), items, ISInventoryPaneContextMenu.OnReload, player);
    end
    -->> Stormy

    if waterContainer and (playerObj:getStats():getThirst() > 0.1) then
        -- print("THIRST")
        ISInventoryPaneContextMenu.doDrinkForThirstMenu(context, playerObj, waterContainer)
    end
    if waterContainer and getCore():getOptionAutoDrink() and getSpecificPlayer(player):getInventory():contains(waterContainer) then
        context:addOption(getText("ContextMenu_DisableAutodrink") , waterContainer, ISInventoryPaneContextMenu.AutoDrinkOff );
    elseif waterContainer  and getSpecificPlayer(player):getInventory():contains(waterContainer) then
        context:addOption(getText("ContextMenu_EnableAutodrink") , waterContainer, ISInventoryPaneContextMenu.AutoDrinkOn );
    end

    -- Crowley
    local pourInto = {}
    if c == 1 and waterContainer ~= nil then
        for i = 0, getSpecificPlayer(player):getInventory():getItems():size() -1 do
            local item = getSpecificPlayer(player):getInventory():getItems():get(i);
            if item ~= waterContainer and item:canStoreWater() and not item:isWaterSource() then
                table.insert(pourInto, item)
            elseif item ~= waterContainer and item:canStoreWater() and item:isWaterSource() and instanceof(item, "DrainableComboItem") and (1 - item:getCurrentUsesFloat()) >= item:getUseDelta() then
                table.insert(pourInto, item)
            end
        end
        if #pourInto > 0 then
            local subMenuOption = context:addOption(getText("ContextMenu_Pour_into"), items, nil);
            local subMenu = context:getNew(context)
            context:addSubMenu(subMenuOption, subMenu)
            for _,item in ipairs(pourInto) do
                if instanceof(item, "DrainableComboItem") then
                    local subOption = subMenu:addOption(item:getName(), items, ISInventoryPaneContextMenu.onTransferWater, waterContainer, item, player);
                    local tooltip = ISInventoryPaneContextMenu.addToolTip()
                    local tx = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_WaterName") .. ":") + 20
                    tooltip.description = string.format("%s: <SETX:%d> %d / %d",
                            getText("ContextMenu_WaterName"), tx, item:getCurrentUses(), 1.0 / item:getUseDelta() + 0.0001)
                    if item:isTaintedWater() and getSandboxOptions():getOptionByName("EnableTaintedWaterText"):getValue() then
                        tooltip.description = tooltip.description .. " <BR> <RGB:1,0.5,0.5> " .. getText("Tooltip_item_TaintedWater")
                    end
                    subOption.toolTip = tooltip
                else
                    subMenu:addOption(item:getName(), items, ISInventoryPaneContextMenu.onTransferWater, waterContainer, item, player);
                end
            end
        end

        context:addOption(getText("ContextMenu_Pour_on_Ground"), items, ISInventoryPaneContextMenu.onEmptyWaterContainer, waterContainer, player);
    end
    -- /Crowley

    if c == 1 then
        ISInventoryPaneContextMenu.checkConsolidate(drainable, player, context, pourInto);
    end

    if c == 1 and pourOnGround and not waterContainer then
        context:addOption(getText("ContextMenu_Pour_on_Ground"), items, ISInventoryPaneContextMenu.onDumpContents, pourOnGround, 100.0, player);
    end

    if isAllPills then
        context:addOption(getText("ContextMenu_Take_pills"), items, ISInventoryPaneContextMenu.onPillsItems, player);
    end
    -- if isAllLiterature and not getSpecificPlayer(player):getTraits():isIlliterate() then
    if isAllLiterature then
        ISInventoryPaneContextMenu.doLiteratureMenu(context, items, player)
    end
    if clothing and clothing:getCoveredParts():size() > 0 then
        context:addOption(getText("IGUI_invpanel_Inspect"), playerObj, ISInventoryPaneContextMenu.onInspectClothing, clothing);
        --        ISInventoryPaneContextMenu.doClothingPatchMenu(player, clothing, context);
    end
    if clothing and not unequip then
        ISInventoryPaneContextMenu.doWearClothingMenu(player, clothing, items, context);
    end

    local addDropOption = true
    if unequip and isForceDropHeavyItem(unequip) then
        context:addOption(getText("ContextMenu_Drop"), items, ISInventoryPaneContextMenu.onUnEquip, player);
        addDropOption = false
    elseif unequip then
        context:addOption(getText("ContextMenu_Unequip"), items, ISInventoryPaneContextMenu.onUnEquip, player);
    end

    -- recipe dynamic context menu
    if recipe ~= nil then
        ISInventoryPaneContextMenu.addDynamicalContextMenu(itemsCraft[1], context, recipe, player, containerList);
    end
    if canBeActivated ~= nil and (not instanceof(canBeActivated, "Drainable") or canBeActivated:getCurrentUsesFloat() > 0) then
        if (canBeActivated:getType() ~= "CandleLit") then
            local txt = getText("ContextMenu_Turn_On");
            if canBeActivated:isActivated() then
                txt = getText("ContextMenu_Turn_Off");
            end
            context:addOption(txt, canBeActivated, ISInventoryPaneContextMenu.onActivateItem, player);
        end
    end
    if isAllBandage then
        ISInventoryPaneContextMenu.doBandageMenu(context, items, player);
    end
    -- dry yourself with a towel
    if canBeDry then
        context:addOption(getText("ContextMenu_Dry_myself"), items, ISInventoryPaneContextMenu.onDryMyself, player);
    end
    if hairDye and playerObj:getHumanVisual():getHairModel() and playerObj:getHumanVisual():getHairModel() ~= "Bald" then
        context:addOption(getText("ContextMenu_DyeHair"), hairDye, ISInventoryPaneContextMenu.onDyeHair, playerObj, false);
    end
    if hairDye and playerObj:getHumanVisual():getBeardModel() and playerObj:getHumanVisual():getBeardModel() ~= "" then
        context:addOption(getText("ContextMenu_DyeBeard"), hairDye, ISInventoryPaneContextMenu.onDyeHair, playerObj, true);
    end
    if makeup then
        ISInventoryPaneContextMenu.doMakeUpMenu(context, makeup, playerObj)
    end
    if isInPlayerInventory and addDropOption and playerObj:getJoypadBind() == -1 and
            not ISInventoryPaneContextMenu.isAllFav(items) and
            not ISInventoryPaneContextMenu.isAllNoDropMoveable(items) then
        context:addOption(getText("ContextMenu_Drop"), items, ISInventoryPaneContextMenu.onDropItems, player);
    end

    ISInventoryPaneContextMenu.doPlace3DItemOption(items, playerObj, context)

    if brokenObject then
        local fixingList = FixingManager.getFixes(brokenObject);
        if not fixingList:isEmpty() then
            local fixOption = context:addOption(getText("ContextMenu_Repair") .. getItemNameFromFullType(brokenObject:getFullType()), items, nil);
            local subMenuFix = ISContextMenu:getNew(context);
            context:addSubMenu(fixOption, subMenuFix);
            for i=0,fixingList:size()-1 do
                ISInventoryPaneContextMenu.buildFixingMenu(brokenObject, player, fixingList:get(i), fixOption, subMenuFix)
            end
        end
    end
    if alarmClock and alarmClock:isDigital() then
        if alarmClock:isRinging() then
            context:addOption(getText("ContextMenu_StopAlarm"), alarmClock, ISInventoryPaneContextMenu.onStopAlarm, player);
        end
        context:addOption(getText("ContextMenu_SetAlarm"), alarmClock, ISInventoryPaneContextMenu.onSetAlarm, player);
    end
    if clothingItemExtra then
        ISInventoryPaneContextMenu.doClothingItemExtraMenu(context, clothingItemExtra, playerObj);
    end
    if canBeRenamed then
        context:addOption(getText("ContextMenu_RenameBag"), canBeRenamed, ISInventoryPaneContextMenu.onRenameBag, player);

        local onOff
        local onOffType

        if(NestedContainers:IsContainerTypeDisplayed(canBeRenamed)) then
            onOffType = "OFF"
        else
            onOffType = "ON"
        end

        if(NestedContainers:IsSpecificContainerDisplayed(canBeRenamed)) then
            onOff = "OFF"
        else
            onOff = "ON"
        end

        context:addOption(getText("ContextMenu_Toggle_Container_display_" .. onOff), canBeRenamed, NestedContainers.ToggleDisplay);
        context:addOption(getText("ContextMenu_Toggle_Container_display_Type_" .. onOffType), canBeRenamed, NestedContainers.ToggleDisplayType);
    end
    if canBeRenamedFood then
        context:addOption(getText("ContextMenu_RenameFood") .. canBeRenamedFood:getName(), canBeRenamedFood, ISInventoryPaneContextMenu.onRenameFood, player);
    end
    if canBeWrite then
        local editable = playerInv:containsTagRecurse("Write") or playerInv:containsTagRecurse("BluePen") or playerInv:containsTagRecurse("Pen") or playerInv:containsTagRecurse("Pencil") or playerInv:containsTagRecurse("RedPen")
        if canBeWrite:getLockedBy() and canBeWrite:getLockedBy() ~= playerObj:getUsername() then
            editable = false
        end
        if not editable then
            context:addOption(getText("ContextMenu_Read_Note", canBeWrite:getName()), canBeWrite, ISInventoryPaneContextMenu.onWriteSomething, false, player);
        else
            context:addOption(getText("ContextMenu_Write_Note", canBeWrite:getName()), canBeWrite, ISInventoryPaneContextMenu.onWriteSomething, true, player);
        end
    end
    if map then
        context:addOption(getText("ContextMenu_CheckMap"), map, ISInventoryPaneContextMenu.onCheckMap, player);
        context:addOption(getText("ContextMenu_RenameMap"), map, ISInventoryPaneContextMenu.onRenameMap, player);
    end

    --	local carBatteryCharger = playerObj:getInventory():getItemFromType("CarBatteryCharger")
    if carBatteryCharger then
        context:addOption(getText("ContextMenu_CarBatteryCharger_Place"), playerObj, ISInventoryPaneContextMenu.onPlaceCarBatteryCharger, carBatteryCharger)
    end
    if clothingRecipe then
        ISInventoryPaneContextMenu.doClothingRecipeMenu(playerObj, clothingRecipe, items, context);
    end

    ISHotbar.doMenuFromInventory(player, testItem, context);

    -- use the event (as you would 'OnTick' etc) to add items to context menu without mod conflicts.
    triggerEvent("OnFillInventoryObjectContextMenu", player, context, items);

    return context;
end

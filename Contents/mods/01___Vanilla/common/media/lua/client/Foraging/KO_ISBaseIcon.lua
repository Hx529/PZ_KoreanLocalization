-- 채집

function ISBaseIcon:doContextMenu(_context)
	if self.isTrack then return; end
	if self:getIsSeen() and self:getAlpha() > 0 then
		self:getGridSquare();
		if (not self.square) then return; end;

		local contextMenu = _context;
		if not contextMenu then
			contextMenu = ISContextMenu.get(self.player, getMouseX(), getMouseY());
		end;
		if not contextMenu then return; end;

		local plInventory = self.character:getInventory();
		local plInventoryHasSpace = plInventory:getCapacityWeight() <= plInventory:getEffectiveCapacity(self.character);
		local contextName = getText("UI_foraging_UnknownItem") .. " " .. getText("IGUI_Pickup");

		if self.identified then
			local displayName = self.itemObj:getDisplayName();
			if self.itemList and not self.itemList:isEmpty() then
				if self.itemList:get(0) ~= nil then
					displayName = self.itemList:get(0):getDisplayName();
				end;
			end;
			if not displayName then
				displayName = getText("UI_foraging_UnknownItem");
			end;
			contextName = "'".. displayName .. "' " .. getText("IGUI_Pickup");
		end;

		local contextOption = contextMenu:addOption(contextName, self, nil, contextMenu, plInventory);
    contextOption.iconTexture = getTexture("media/textures/" .. tostring(self.itemObj:getTexture():getName()) .. ".png")
		local subMenu = ISContextMenu:getNew(contextMenu);
		local bpList = getPlayerInventory(self.player).backpacks;

		local plInvOption = subMenu:addOption(getText("ContextMenu_PutInContainer", getText("ContextMenu_MoveToInventory")), self, self.onClickContext, 0, 0, contextMenu, plInventory, {self.itemObj});
		plInvOption.iconTexture = getTexture("media/ui/Icon_InventoryBasic.png")
		if plInventory:hasRoomFor(self.character, self.itemObj) and plInventoryHasSpace then
			self:doGrabSubMenu(contextMenu, plInvOption, plInventory);
		else
			plInvOption.onSelect = nil;
			plInvOption.notAvailable = true;
		end;
		for _, backpack in ipairs(bpList) do
			local bpItem = backpack and backpack.inventory and backpack.inventory:getContainingItem();
			if bpItem then
				if backpack.inventory:isItemAllowed(self.itemObj) then
					local backPackOption = subMenu:addOption(getText("ContextMenu_PutInContainer", bpItem:getDisplayName()), self, self.onClickContext, 0, 0, contextMenu, backpack.inventory, {self.itemObj});
					backPackOption.itemForTexture = bpItem
					if (not backpack.inventory:hasRoomFor(self.character, self.itemObj)) or (not plInventoryHasSpace) then
						backPackOption.onSelect = nil;
						backPackOption.notAvailable = true;
					else
						self:doGrabSubMenu(contextMenu, backPackOption, backpack.inventory);
					end;
				end;
			end;
		end;
		contextMenu:addSubMenu(contextOption, subMenu);
		if self.onClickDiscard then
			if self.identified then
				contextName = "'" .. self.itemObj:getDisplayName() .. "' " .. getText("UI_foraging_DiscardItem");
			else
				contextName = getText("UI_foraging_UnknownItem") .. " " .. getText("UI_foraging_DiscardItem");
			end;
			contextOption = contextMenu:addOption(contextName, self, self.onClickDiscard, contextMenu);
			contextOption.iconTexture = getTexture("media/ui/LootableMaps/map_garbage.png")
		end;

		triggerEvent("onFillSearchIconContextMenu", contextMenu, self);
		return false;
	end;
	return false;
end

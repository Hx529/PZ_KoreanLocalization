-- 브러쉬 도구 매니저 번역

local function setTileCursor(tilename, playerObj)
  local cursor = ISBrushToolTileCursor:new(tilename, tilename, playerObj)
  getCell():setDrag(cursor, playerObj:getPlayerNum())
  end

  local function destroyTile(obj)
  if isClient() then
  sledgeDestroy(obj)
  else
  obj:getSquare():transmitRemoveItemFromSquare(obj)
  end
end

ISWorldObjectContextMenu.doBrushToolOptions = function(context, worldobjects, player)

	local addTooltip = function(option, spriteName)
		local tooltip = ISToolTip:new();
		tooltip:initialise();
		tooltip:setName("");
		tooltip:setTexture(spriteName);
		option.toolTip = tooltip
	end

	local playerObj = getSpecificPlayer(player)

	local brushToolManager = context:addOption(getText("IGUI_DebugContext_BrushToolManager"), playerObj, BrushToolManager.openPanel)
  brushToolManager.iconTexture = getTexture("media/textures/Item_Insect_Aphid.png");

	local copyOption = context:addOption(getText("IGUI_DebugContext_BrushToolManager_Copy_tile"), worldobjects)
  copyOption.iconTexture = getTexture("media/textures/Item_Insect_Aphid.png");
	local copySubMenu = context:getNew(context)
	context:addSubMenu(copyOption, copySubMenu)

	local destoyOption = context:addOption(getText("IGUI_DebugContext_BrushToolManager_Destroy_tile"), worldobjects)
  destoyOption.iconTexture = getTexture("media/textures/Item_Insect_Aphid.png");
	local destoySubMenu = context:getNew(context)
	context:addSubMenu(destoyOption, destoySubMenu)

	local opt = nil
	for _, obj in ipairs(worldobjects) do
		if obj:getSprite() ~= nil and obj:getSprite():getName() ~= nil then
			opt = copySubMenu:addOption("[MAIN] " .. obj:getSprite():getName(), obj:getSprite():getName(), setTileCursor, playerObj)
			addTooltip(opt, obj:getSprite():getName())
			opt = destoySubMenu:addOption(obj:getSprite():getName(), obj, destroyTile)
			addTooltip(opt, obj:getSprite():getName())
		end

		if obj:getOverlaySprite() ~= nil and obj:getOverlaySprite():getName() ~= nil then
			opt = copySubMenu:addOption("[OVERLAY] " .. obj:getOverlaySprite():getName(), obj:getOverlaySprite():getName(), nil, playerObj, setTileCursor, playerObj)
			addTooltip(opt, obj:getOverlaySprite():getName())
		end

		local attachedSprites = obj:getAttachedAnimSprite()
		if attachedSprites ~= nil then
			for i = 0, attachedSprites:size()-1 do
				local sprite = attachedSprites:get(i):getParentSprite()
				if sprite and sprite:getName() ~= nil then
					opt = copySubMenu:addOption("[ATTACHED] " .. sprite:getName(), sprite:getName(), setTileCursor, playerObj)
					addTooltip(opt, sprite:getName())
				end
			end
		end
	end
end

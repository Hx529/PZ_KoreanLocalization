-- 디버그 - 채집 번역
function ISSearchManager.createDebugContextMenu(_player, _context, _manager, _square)
	local contextMenu = ISContextMenu:getNew(_context);
	if not contextMenu then return; end;

	local forageDebugOption = _context:addDebugOption(getText("IGUI_perks_Foraging"));
	contextMenu:addSubMenu(forageDebugOption, contextMenu);

	--add test icons
	contextMenu:addDebugOption(getText("IGUI_DebugContext_Foraging_AddForageIconHere1"), _manager, onClickCreateIcon, _square, 1);
	contextMenu:addDebugOption(getText("IGUI_DebugContext_Foraging_AddForageIconHere10"), _manager, onClickCreateIcon, _square, 10);
	contextMenu:addDebugOption(getText("IGUI_DebugContext_Foraging_AddForageIconHere50"), _manager, onClickCreateIcon, _square, 50);
	ISSearchManager.createDebugSpawnAllContextMenu(_player, contextMenu, _manager, _square)
	contextMenu:addDebugOption("----------");
	contextMenu:addDebugOption(getText("IGUI_DebugContext_Foraging_ClearAndRefreshAllIconsInThisZone"), _manager, _manager.refreshZoneIcons, _square);
	contextMenu:addDebugOption(getText("IGUI_DebugContext_Foraging_MoveAllForageIconsInZoneToThisSquare"), _manager, _manager.moveAllZoneIconsToSquare, _square);
end

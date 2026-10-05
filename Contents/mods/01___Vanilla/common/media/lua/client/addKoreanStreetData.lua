-- feat: Skyblue
-- 이 코드의 작성 및 구현에 Skyblue님의 도움이 있었습니다.

local MapUtils_initDirectoryStreetData = MapUtils.initDirectoryStreetData
function MapUtils.initDirectoryStreetData(mapUI, directory)
	if directory == "media/maps/Muldraugh, KY" and fileExists('media/maps/streets.xml') then
		mapUI.javaObject:getAPIv3():getStreetsAPI():addStreetData('media/maps/streets.xml')
		return
	else
		MapUtils_initDirectoryStreetData(mapUI, directory)
	end
end

function addKoreanStreetData()
    -- 전단지 한글 사이즈 수정
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.title:setScaleX(1.2)
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.title:setScaleY(1.2)
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.text:setScaleX(1)
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.text:setScaleY(1)
	PZAPI.UI.PrintMedia.children.bar.children.name.scaleX = 1
	PZAPI.UI.PrintMedia.children.bar.children.name.scaleY = 1

    if not ISWorldMap_instance then
        ISWorldMap.ShowWorldMap(0)
        ISWorldMap_instance:close()
    end

    local mapAPI = ISWorldMap_instance.javaObject:getAPIv3()
	local symAPI = mapAPI:getSymbolsAPIv2()

	for i=0, symAPI:getSymbolCount() - 1 do
		local sym = symAPI:getSymbolByIndex(i)
		if sym and sym:isText() then
			local text = sym:getUntranslatedText() or sym:getTranslatedText()
			local annotations = KoreanWorldmapAnnotationsList[text]
			if annotations then
				sym:setTranslatedText(annotations)
			end
		end
	end

end

Events.OnGameStart.Add(addKoreanStreetData)

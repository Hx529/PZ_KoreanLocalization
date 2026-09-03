-- feat: Skyblue
-- 이 코드의 작성 및 구현에 Skyblue님의 도움이 있었습니다.

function addKoreanStreetData()
    if not ISWorldMap_instance then
        ISWorldMap.ShowWorldMap(0)
        ISWorldMap_instance:close()
    end

    -- 도로명 한글화
    local mapAPI = ISWorldMap_instance.javaObject:getAPIv3()
    local streetsAPI = mapAPI:getStreetsAPI()
    local editorAPI = streetsAPI:getEditorAPI()
    local file = 'media/maps/streets.xml'
    if fileExists(file) then
        streetsAPI:clearStreetData()
        streetsAPI:addStreetData(file)
        editorAPI:setStreetData(file)
    end

    -- 전단지 한글 사이즈 수정
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.title:setScaleX(1.2)
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.title:setScaleY(1.2)
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.text:setScaleX(1)
    PZAPI.UI.PrintMedia.children.body.children.textNode.children.container.children.text:setScaleY(1)
	PZAPI.UI.PrintMedia.children.bar.children.name.scaleX = 1
	PZAPI.UI.PrintMedia.children.bar.children.name.scaleY = 1

	-- 지도 기본 심볼 한글화
	local symAPI = mapAPI:getSymbolsAPIv2()
	local Save_temp = {}
	local cnt = symAPI:getSymbolCount()
	local setFont
	if getTextManager():getFontHeight(UIFont.small) == 16 then
		setFont = UIFont.Large
	else
		setFont = UIFont.Small
	end
	local setFont_h = getTextManager():getFontHeight(setFont)

	-- 좀보이드 심볼 삭제 기능이 진짜 개씹병신이라 하나하나 지우는거보다 심볼 새겨져 있는걸 저장했다가 전체 clear하고 다시 새기는게 훨씬 빠름
	for i = 0, cnt - 1 do
		local sym = symAPI:getSymbolByIndex(i)
		if sym:isUserDefined() and sym:isPrivate() and (math.floor(sym:getAlpha()* 10^2 + 0.5 ) / 10^2 ~= 0.95) then
			local s = {}
			s.x = sym:getWorldX()
			s.y = sym:getWorldY()
			s.r = sym:getRed()
			s.g = sym:getGreen()
			s.b = sym:getBlue()
			s.a = sym:getAlpha()
			s.rotation = sym:getRotation()
			s.matchPerspective = sym:isMatchPerspective()
			s.applyZoom = sym:isApplyZoom()
			s.minZoom = sym:getMinZoom()
			s.maxZoom = sym:getMaxZoom()
			s.UserDefined = sym:isUserDefined()
			s.texture = ""
			s.text = ""
			if sym:isTexture() then
				s.type = "texture"
				s.texture = sym:getSymbolID()
				local h = MapSymbolDefinitions:getInstance():getSymbolById(sym:getSymbolID()):getHeight()
				s.scale = sym:getDisplayHeight() / (mapAPI:getWorldScale() * h)
			elseif sym:isText() then
				s.type = "text"
				s.layerID = sym:getLayerID()
				s.text = sym:getTranslatedText() or sym:getUntranslatedText()
				s.scale = sym:getScale()
			end
			s.AnchorX = sym:getAnchorX()
			s.AnchorY = sym:getAnchorY()

			table.insert(Save_temp, s)
		end
	end

	symAPI:clear()

	for k, v in pairs(Save_temp) do
		local sym
		if v.type == "texture" then
			sym = symAPI:addTexture(v.texture, v.x, v.y)
		elseif v.type == "text" then
			sym = symAPI:addTranslatedText(v.text, setFont, v.x, v.y)
		end
		sym:setAnchor(v.AnchorX, v.AnchorY)
		sym:setRGBA(v.r, v.g, v.b, v.a)
		sym:setRotation(v.rotation)
		sym:setMatchPerspective(v.matchPerspective)
		sym:setApplyZoom(v.applyZoom)
		sym:setMinZoom(v.minZoom)
		sym:setMaxZoom(v.maxZoom)
		sym:setUserDefined(v.UserDefined)
		sym:setScale(v.scale)
	end

	KoreanWorldmapAnnotations(ISWorldMap_instance)

end

Events.OnGameStart.Add(addKoreanStreetData)

-- feat: Skyblue
-- 이 코드의 작성 및 구현에 Skyblue님의 도움이 있었습니다.

KoreanWorldmapAnnotationsList = KoreanWorldmapAnnotationsList or {}
KoreanWorldmapAnnotationsList["DARK WALLOW LAKE"] = getText("MapLabel_DARK_WALLOW_LAKE")
KoreanWorldmapAnnotationsList["HOG WALLOW FOREST"] = getText("MapLabel_HOG_WALLOW_FOREST")
KoreanWorldmapAnnotationsList["Kentucky State<br>Prison"] = getText("MapLabel_Kentucky_State_Prison")
KoreanWorldmapAnnotationsList["DOE VALLEY FOREST"] = getText("MapLabel_DOE_VALLEY_FOREST")
KoreanWorldmapAnnotationsList["DOE VALLEY LAKE"] = getText("MapLabel_DOE_VALLEY_LAKE")
KoreanWorldmapAnnotationsList["JEFFERSON<br>FOREST"] = getText("JEFFERSON<br>FOREST")
KoreanWorldmapAnnotationsList["Louisville International<br>Airport"] = getText("MapLabel_Louisville_International_Airport")
KoreanWorldmapAnnotationsList["Louisville<br>Expo Center"] = getText("Louisville<br>Expo Center")
KoreanWorldmapAnnotationsList["Louisville<br>State<br>University"] = getText("MapLabel_Louisville_State_University")
KoreanWorldmapAnnotationsList["Grand<br>Ohio<br>Mall"] = getText("MapLabel_Grand_Ohio_Mall")
KoreanWorldmapAnnotationsList["Iroquois Park"] = getText("MapLabel_Iroquois_Park")
KoreanWorldmapAnnotationsList["Crossroads<br>Mall"] = getText("MapLabel_Crossroads_Mall")
KoreanWorldmapAnnotationsList["Fossoil<br>Field"] = getText("MapLabel_Fossoil_Field")
KoreanWorldmapAnnotationsList["Havisham<br>Hotel"] = getText("MapLabel_Havisham_Hotel")
KoreanWorldmapAnnotationsList["Chapelmount<br>Downs"] = getText("MapLabel_Chapelmount_Downs")
KoreanWorldmapAnnotationsList["St. Michael's<br>Cathedral"] = getText("MapLabel_St_Michaels_Cathedral")
KoreanWorldmapAnnotationsList["Cardinal<br>Plaza"] = getText("MapLabel_Cardinal_Plaza")
KoreanWorldmapAnnotationsList["Louisville<br>General<br>Hospital"] = getText("MapLabel_Louisville_General_Hospital")
KoreanWorldmapAnnotationsList["St. Peregrin<br>Hospital"] = getText("MapLabel_St_Peregrin_Hospital")
KoreanWorldmapAnnotationsList["Louisville Bruiser<br>Factory"] = getText("MapLabel_Louisville_Bruiser_Factory")
KoreanWorldmapAnnotationsList["Irvington Speedway"] = getText("MapLabel_Irvington_Speedway")
KoreanWorldmapAnnotationsList["Bright Valley<br>Trailer Park"] = getText("MapLabel_Bright_Valley_Trailer_Park")
KoreanWorldmapAnnotationsList["PS Delilah"] = getText("MapLabel_PS_Delilah")
KoreanWorldmapAnnotationsList["Knox Boundary Camp"] = getText("MapLabel_Knox_Boundary_Camp")
KoreanWorldmapAnnotationsList["Coalfield"] = getText("MapLabel_Coalfield")
KoreanWorldmapAnnotationsList["WADSWORTH LAKE"] = getText("MapLabel_WADSWORTH_LAKE")
KoreanWorldmapAnnotationsList["Sunderland Hills<br>Sanatorium"] = getText("MapLabel_Sunderland_Hills_Sanatorium")
KoreanWorldmapAnnotationsList["West Maple<br>Country Club"] = getText("MapLabel_West_Maple_Country_Club")
KoreanWorldmapAnnotationsList["Dixie Trailer Park"] = getText("MapLabel_Dixie_Trailer_Park")
KoreanWorldmapAnnotationsList["Trainyard"] = getText("MapLabel_Trainyard")
KoreanWorldmapAnnotationsList["McCoy's Logging"] = getText("MapLabel_McCoys_Logging")
KoreanWorldmapAnnotationsList["Pondview<br>Shopping<br>Center"] = getText("MapLabel_Pondview_Shopping_Center")
KoreanWorldmapAnnotationsList["Scenic Grove<br>Trailer Park"] = getText("MapLabel_Scenic_Grove_Trailer_Park")
KoreanWorldmapAnnotationsList["DEERHEAD LAKE"] = getText("MapLabel_DEERHEAD_LAKE")
KoreanWorldmapAnnotationsList["Pony Roam-O"] = getText("MapLabel_Pony_Roam-O")
KoreanWorldmapAnnotationsList["Meadshire<BR>Estate"] = getText("MapLabel_Meadshire_Estate")
KoreanWorldmapAnnotationsList["Louisville<BR>Train Station"] = getText("MapLabel_Louisville_Train_Station")
KoreanWorldmapAnnotationsList["Brandenburg<br>Detention<br>Center"] = getText("MapLabel_Brandenburg_Detention_Center")
KoreanWorldmapAnnotationsList["Camp Fitzgerald"] = getText("MapLabel_Camp_Fitzgerald")
KoreanWorldmapAnnotationsList["Camp Arthur"] = getText("MapLabel_Camp_Arthur")
KoreanWorldmapAnnotationsList["Camp Camus"] = getText("MapLabel_Camp_Camus")


function KoreanWorldmapAnnotations(mapUI)
	local mapAPI = mapUI.javaObject:getAPIv3()
	local symbolsAPI = mapAPI:getSymbolsAPIv2()

	-- 모드 맵 라벨 추가
	local townLabels = {
		{ mod = "\\RavenCreekB42", id = "MapLabel_RAVEN_CREEK", text = "text-town", x = 5530, y = 16370, scale = 5.5, rotation = 45.0 },
		{ mod = "\\WestPointExpansionB42", id = "MapLabel_WestPoint_Expansion", text = "text-town", x = 12472, y = 6977, scale = 3.5, rotation = 45.0 },
		{ mod = "\\CoryerdonB42", id = "MapLabel_CORYERDON", text = "text-town", x = 8771, y = 5969, scale = 5.5, rotation = 45.0 },
		{ mod = "\\KingsmouthB42", id = "MapLabel_KINGSMOUTH", text = "text-town", x = 7160, y = 16447, scale = 4.5, rotation = 45.0 },
		{ mod = "\\KingsmouthNorthB42", id = "MapLabel_KINGSMOUTH_NORTH", text = "text-town", x = 547, y = 4415, scale = 4.5, rotation = 45.0 },
		{ mod = "\\FortBenningB42", id = "MapLabel_FORT_BENNING", text = "text-town", x = 6106, y = 7033, scale = 3.5, rotation = 0.0 },
		{ mod = "\\LittleTownshipB42", id = "MapLabel_Little_Township", text = "text-town", x = 8251, y = 8544, scale = 3.5, rotation = 45.0 },
		{ mod = "\\CamdenCountyB42", id = "MapLabel_CAMDEN_COUNTY", text = "text-town", x = 16200, y = 11456, scale = 8.5, rotation = 0.0 },
		{ mod = "\\Fort Waterfront B42", id = "MapLabel_FORT_WATERFRONT", text = "text-town", x = 10251, y = 10993, scale = 3.5, rotation = 45.0 },
		{ mod = "\\Ashenwood B42", id = "MapLabel_Ashenwood", text = "text-town", x = 11520, y = 11520, scale = 3.5, rotation = 45.0 },
		{ mod = "\\Willowbrook Bastion!", id = "MapLabel_Willowbrook_Bastion", text = "text-town", x = 9065, y = 9880, scale = 4.5, rotation = 45.0 },
		{ mod = "\\RaccoonCityB42", id = "MapLabel_RaccoonCity", text = "text-town", x = 10240, y = 10240, scale = 3.5, rotation = 45.0 },
		{ mod = "\\Nettle Township B42 version", id = "MapLabel_Nettle_Township", text = "text-town", x = 6910, y = 9300, scale = 3.5, rotation = 45.0 },
	}

	for _, town in ipairs(townLabels) do
		if getActivatedMods():contains(town.mod) then
			local symbol = symbolsAPI:addUntranslatedText(town.id, town.text, town.x, town.y)
			symbol:setRGBA(0.000, 0.000, 0.000, 0.000)
			symbol:setScale(town.scale)
			symbol:setAnchor(0.50, 0.50)
			symbol:setRotation(town.rotation)
			symbol:setMatchPerspective(true)
			symbol:setApplyZoom(true)
			symbol:setMinZoom(0.00)
			symbol:setMaxZoom(13.00)
			symbol:setUserDefined(false)
		end
	end
end

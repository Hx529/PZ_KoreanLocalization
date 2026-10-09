if isServer() then return end
-- if not IPPJModCheck then return end


local config = {
    keyBind   = nil,
    checkBox  = nil,
    textEntry = nil,
    multiBox  = nil,
    comboBox  = nil,
    colorPick = nil,
    slider    = nil,
    button    = nil
}

local function IPPJSettingsCF()
	local IPPJSettings = PZAPI.ModOptions:create("IPPJSettings", "Improved Projectile B42")

	config.checkBox = IPPJSettings:addTickBox("SimplifiedProj", getText("UI_IB_Simplified_Projectile"), false, getText("UI_IB_Default_false"))
	config.checkBox = IPPJSettings:addTickBox("CustomBloodEffect", getText("UI_IB_Custom_Blood_Effect_Player"), false, getText("UI_IB_Currently_Not_Available"))
	config.checkBox = IPPJSettings:addTickBox("CustomBloodEffectOthers", getText("UI_IB_Custom_Blood_Effect_Other"), false, getText("UI_IB_Currently_Not_Available"))
	config.checkBox = IPPJSettings:addTickBox("ExplosionEffect", getText("UI_IB_Explosion_Effect"), true, getText("UI_IB_Default_true"))
	config.comboBox = IPPJSettings:addComboBox("CrosshairType", getText("UI_IB_Crosshair_Type"), getText("UI_IB_Change_crosshair_graphic_Default_Type_1"))
		config.comboBox:addItem(getText("UI_IB_Type_1"), true)
		config.comboBox:addItem(getText("UI_IB_Type_2"), false)
		config.comboBox:addItem(getText("UI_IB_Type_3"), false)
		config.comboBox:addItem(getText("UI_IB_Type_4"), false)
		config.comboBox:addItem(getText("UI_IB_OFF"), false)
	config.textEntry = IPPJSettings:addTextEntry("CrosshairHeight", getText("UI_IB_Crosshair_Height"), "0", getText("UI_IB_Numbers_only_otherwise_something_will_go_wrong_Defalut_0"))
	config.checkBox = IPPJSettings:addTickBox("CrosshairDot", getText("UI_IB_Crosshair_Centor_Dot"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("CrosshairOutline", getText("UI_IB_Crosshair_Outline"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("RemoveIsoCursor", getText("UI_IB_Remove_Iso_Cursor"), true, getText("UI_IB_Default_true"))
	config.comboBox = IPPJSettings:addComboBox("SniperScope", getText("UI_IB_Sniper_Scope"), getText("UI_IB_Change_crosshair_graphic_Default_Type_1_Currently_Not_Available"))
	config.comboBox:addItem(getText("UI_IB_Type_1"), true)
	config.comboBox:addItem(getText("UI_IB_Type_2"), false)
	config.comboBox:addItem(getText("UI_IB_Type_3"), false)
	config.comboBox:addItem(getText("UI_IB_OFF"), false)
	config.textEntry = IPPJSettings:addTextEntry("SniperScopeRangeV", getText("UI_IB_Minimum_Range_for_Sniper_Scope"), "14", getText("UI_IB_Numbers_only_otherwise_something_will_go_wrong_Defalut_14__Currently_Not_Available"))
	config.checkBox = IPPJSettings:addTickBox("ShowAmmoCount", getText("UI_IB_Show_Ammo_Count"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("ShowOutOfRange", getText("UI_IB_Show_OutOfRange_Warning"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("ShowPlayerLevel", getText("UI_IB_Show_Players_ZLevel"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("ResetLevel", getText("UI_IB_Always_Reset_ZLevel_when_ADS"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("AdjustLevelFloor", getText("UI_IB_Adjust_Level_Floor"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("AimAssistLZombie", getText("UI_IB_Aim_Assist_Zombie"), true, getText("UI_IB_Default_true"))
	config.checkBox = IPPJSettings:addTickBox("VisualRecoil", getText("UI_IB_Visual_Recoil"), true, getText("UI_IB_Default_true"))
	config.textEntry = IPPJSettings:addTextEntry("VisualRecoilMult", getText("UI_IB_Visual_Recoil_Factor"), "1", getText("UI_IB_Numbers_only_otherwise_something_will_go_wrong_Defalut_1"))
	config.multiBox = IPPJSettings:addMultipleTickBox("MoodleEffect", getText("UI_IB_Moodle_Effect"), getText("UI_IB_Default_true"))
		config.multiBox:addTickBox(getText("UI_IB_Panic"), true)
		config.multiBox:addTickBox(getText("UI_IB_Tired"), true)
		config.multiBox:addTickBox(getText("UI_IB_Cold"), true)
	config.comboBox = IPPJSettings:addComboBox("HitMarkType", getText("UI_IB_Hit_Marker_Type"), getText("UI_IB_Change_hit_marker_graphic_Default_Type_1"))
		config.comboBox:addItem(getText("UI_IB_Type_1"), true)
		config.comboBox:addItem(getText("UI_IB_Type_2"), false)
		config.comboBox:addItem(getText("UI_IB_OFF"), false)
	config.checkBox = IPPJSettings:addTickBox("HitInfoText", getText("UI_IB_Hit_Info"), false, getText("UI_IB_Default_false"))
end

IPPJSettingsCF()

local CrosshairTypeList		= {"Type 1", "Type 2", "Type 3", "Type 4", "OFF"}
local HitMarkTypeList		= {"Type 1", "Type 2", "OFF"}
local SniperScopeTypeList	= {"OFF", "Type 1", "Type 2", "Type 3"}
local settingNum = 0

IPPJModOptions = PZAPI.ModOptions:getOptions("IPPJSettings")
--[[
IPPJSettings = {
	GameVersion				= getCore():getVersionNumber(),
	SimplifiedProj			= IPPJModOptions:getOption("SimplifiedProj"):getValue() 	or false,
	--	CustomBloodEffect		= IPPJModOptions:getOption("CustomBloodEffect"):getValue() or false,
	--	CustomBloodEffectOthers = IPPJModOptions:getOption("CustomBloodEffectOthers"):getValue() or false,
	CustomBloodEffect		= false,
	CustomBloodEffectOthers = false,
	-- 	ExplosionEffect			= IPPJModOptions:getOption("ExplosionEffect"):getValue() 	or false,
	ExplosionEffect			= false,
	CrosshairType			= "Type 1",
	CrosshairTypeIdx		= IPPJModOptions:getOption("CrosshairType"):getValue() 		or 1,
	CrosshairDot			= IPPJModOptions:getOption("CrosshairDot"):getValue() 		or true,
	CrosshairOutline		= IPPJModOptions:getOption("CrosshairOutline"):getValue() 	or true,
	RemoveIsoCursor			= IPPJModOptions:getOption("RemoveIsoCursor"):getValue() 	or false,
	SniperScope				= "OFF",
	SniperScopeIdx			= IPPJModOptions:getOption("SniperScope"):getValue() 		or 1,
	SniperScopeRangeV		= IPPJModOptions:getOption("SniperScopeRangeV"):getValue() 	or 14,
	CrosshairHeight			= IPPJModOptions:getOption("CrosshairHeight"):getValue() 	or 0,
	ShowAmmoCount			= IPPJModOptions:getOption("ShowAmmoCount"):getValue() 		or true,
	ShowOutOfRange			= IPPJModOptions:getOption("ShowOutOfRange"):getValue() 	or true,
	ShowPlayerLevel			= IPPJModOptions:getOption("ShowPlayerLevel"):getValue() 	or true,
	ResetLevel				= IPPJModOptions:getOption("ResetLevel"):getValue() 		or true,
	AdjustLevelFloor		= IPPJModOptions:getOption("AdjustLevelFloor"):getValue() 	or false,
	AimAssistLZombie		= IPPJModOptions:getOption("AimAssistLZombie"):getValue() 	or false,
	VisualRecoil			= IPPJModOptions:getOption("VisualRecoil"):getValue() 		or true,
	VisualRecoilMult		= IPPJModOptions:getOption("VisualRecoilMult"):getValue() 	or 1,
	MoodleEffectPanic		= IPPJModOptions:getOption("MoodleEffect"):getValue(1) 		or true,
	MoodleEffectTired		= IPPJModOptions:getOption("MoodleEffect"):getValue(2) 		or false,
	MoodleEffectCold		= IPPJModOptions:getOption("MoodleEffect"):getValue(3) 		or true,
	HitMarkType				= "Type 1",
	HitMarkTypeIdx			= IPPJModOptions:getOption("HitMarkType"):getValue() 		or 1,
	HitInfoText				= IPPJModOptions:getOption("HitInfoText"):getValue() 		or false,
	CrosshairColorMIN		= {
		r = 0.4, g = 1.0, b = 0.4, a = 0.7
	},
	CrosshairColorMAX		= {
		r = 1.0, g = 0.3, b = 0.3, a = 0.7
	}
}

IPPJSettingsDefault = {
	GameVersion				= getCore():getVersionNumber(),
	SimplifiedProj			= false,
	CustomBloodEffect		= false,
	CustomBloodEffectOthers = false,
	ExplosionEffect			= false,
	CrosshairType			= "Type 1",
	CrosshairTypeIdx		= 1,
	CrosshairDot			= true,
	CrosshairOutline		= true,
	RemoveIsoCursor			= false,
	SniperScope				= "OFF",
	SniperScopeIdx			= 1,
	SniperScopeRangeV		= 14,
	CrosshairHeight			= 0,
	ShowAmmoCount			= true,
	ShowOutOfRange			= true,
	ShowPlayerLevel			= true,
	ResetLevel				= true,
	AdjustLevelFloor		= false,
	AimAssistLZombie		= false,
	VisualRecoil			= true,
	VisualRecoilMult		= 1,
	MoodleEffectPanic		= true,
	MoodleEffectTired		= false,
	MoodleEffectCold		= true,
	HitMarkType				= "Type 1",
	HitMarkTypeIdx			= 1,
	HitInfoText				= false,
	CrosshairColorMIN		= {
		r = 0.4, g = 1.0, b = 0.4, a = 0.7
	},
	CrosshairColorMAX		= {
		r = 1.0, g = 0.3, b = 0.3, a = 0.7
	}
}
]]
IPPJSettingsCache = {}
UserIsoCursorVis = getCore():getIsoCursorVisibility()
UserUIFBO = getCore():getOptionUIFBO()
UserUIRenderFPS = getCore():getOptionUIRenderFPS()
--[[
local function fromCfgData(curr, loc)
	if loc == nil then return end

	for i, v in pairs(loc) do
		if i == "MoodleEffect" then
			curr["MoodleEffectPanic"] = v
		else
			curr[i] = v
		end
	end

	-- Checking
	for i, v in pairs(IPPJSettingsDefault) do
		if IPPJSettings[i] == nil then
			if i == "CrosshairColorMIN" or i == "CrosshairColorMAX" then
				for j, w in pairs(IPPJSettingsDefault[i]) do
					IPPJSettings[i][j] = w
				end
			else
				IPPJSettings[i] = v
			end
		end
	end

	return curr
end

local function saveSettings()
	settingNum = 0
	for i, v in pairs(IPPJSettings) do
		settingNum = settingNum + 1
	end

	local writer = getFileWriter("IPPJOptions.lua.cfg", true, false)

	writer:write("IPPJSettingsSave={\n")
	local idx = 1
	for i, v in pairs(IPPJSettings) do
		writer:write("\t" .. i .. "=")
		if type(v) == "string" then
			writer:write("\"" .. v .. "\"")
		elseif type(v) == "table" then
			writer:write("{\n")
			local cidx = 1
			for j, k in pairs(v) do
				writer:write("\t" .. j .. "=" .. tostring(k))
				if cidx ~= 4 then
					writer:write(",")
				end
				writer:write("\n")
				if cidx == 4 then
					writer:write("\t}")
				end
				cidx = cidx + 1
			end
		else
			writer:write(tostring(v))
		end
		if idx ~= settingNum then
			writer:write(",")
		end
		writer:write("\n")
		idx = idx + 1
	end
	writer:write("}\n")
	writer:write("return IPPJSettingsSave\n")
	writer:close()
end

local function loadSettings()
	local reader = getFileReader("IPPJOptions.lua.cfg", false)
	if reader == nil then
		print("[IPPJ] No option file")
		saveSettings()
		reader = getFileReader("IPPJOptions.lua.cfg", false)
		if reader == nil then
			print("[IPPJ] Error : Cannot create option file")
			return
		end
	end

	local cfgData = ""
	local eof = false
	repeat
		line = reader:readLine()
		if line == nil then eof = true
		else cfgData = cfgData .. line .. "\r\n" end
	until eof ~= false
	reader:close()

	local cfgLua = loadstring(cfgData)
	if cfgLua == nil then return end
	local localCfgData = cfgLua()

	IPPJSettings = fromCfgData(IPPJSettings, localCfgData)
	print("[IPPJ] Option file loaded")
end

Events.OnResetLua.Add(loadSettings)
Events.OnGameStart.Add(loadSettings)
Events.OnMainMenuEnter.Add(loadSettings)

--*************************************************************************************--
--** Main Options **
--*************************************************************************************--
local PageName = "Improved Projectile"

local function getTypeIndex(options, selected)
	for i, v in ipairs(options) do
		if v == selected then
			return i
		end
	end
end

local IPPJGameOption = ISBaseObject:derive("GameOption")

function IPPJGameOption:new(name, control, arg1, arg2)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.name = name
	o.control = control
	o.arg1 = arg1
	o.arg2 = arg2
	if control.isCombobox then
		control.onChange = self.onChangeComboBox
		control.target = o
	end
	if control.isTickBox then
		control.changeOptionMethod = self.onChangeTickBox
		control.changeOptionTarget = o
	end
	if control.isSlider then
		control.targetFunc = self.onChangeVolumeControl
		control.target = o
	end
	return o
end

function IPPJGameOption:toUI()
	print("ERROR: option '" ..self.name.. "' missing toUI()")
end

function IPPJGameOption:apply()
	print("ERROR: option '" ..self.name.. "' missing apply()")
end

function IPPJGameOption:onChangeComboBox(box)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(box)
	end
end

function IPPJGameOption:onChangeTickBox(index, selected)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(index, selected)
	end
end

function IPPJGameOption:onChangeVolumeControl(control, volume)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(control, volume)
	end
end

function setChanged(target)
	target.gameOptions.changed = true
end

function onSliderChange(target, val, _self)
	_self.label:setName(tostring(val))
	setChanged(target)
end

function pickRGBColor(target, color, mouseUp)
	target.backgroundColor = {r = color.r, g = color.g, b = color.b, a = 1}
	local gameOptions = MainOptions.instance.gameOptions
	gameOptions:onChange()
end

function rgbPickerBtnClick(target, _self)
	_self.colorPicker2:setX(100)
	_self.colorPicker2:setY(100)

	local colorInfo = ColorInfo.new(_self.backgroundColor.r, _self.backgroundColor.g, _self.backgroundColor.b, 1)
	_self.colorPicker2:setInitialColor(colorInfo)
	target:addChild(_self.colorPicker2)
	_self.colorPicker2:setVisible(true)
	_self.colorPicker2:bringToTop()
end

function onResetAllClick(target)
	for i, v in pairs(IPPJSettings) do
		IPPJSettingsCache[i] = v
	end
	for i, v in pairs(IPPJSettingsDefault) do
		IPPJSettings[i] = v
	end
	target.gameOptions.changed = true
	for _, option in ipairs(target.gameOptions.options) do
		option:toUI()
	end
	for i, v in pairs(IPPJSettingsCache) do
		IPPJSettings[i] = v
	end
	IPPJSettingsCache = {}
end

function onResetColorClick(target)
	IPPJSettingsCache.CrosshairColorMIN = {}
	IPPJSettingsCache.CrosshairColorMAX = {}
	for i, v in pairs(IPPJModOptions:getOption("CrosshairColorMIN) do
		IPPJSettingsCache.CrosshairColorMIN[i] = v
	end
	for i, v in pairs(IPPJModOptions:getOption("CrosshairColorMAX) do
		IPPJSettingsCache.CrosshairColorMAX[i] = v
	end
	for i, v in pairs(IPPJSettingsDefault.CrosshairColorMIN) do
		IPPJModOptions:getOption("CrosshairColorMIN[i] = v
	end
	for i, v in pairs(IPPJSettingsDefault.CrosshairColorMAX) do
		IPPJModOptions:getOption("CrosshairColorMAX[i] = v
	end
	target.gameOptions.changed = true
	for _, option in ipairs(target.gameOptions.options) do
		if option.isRGBPicker then
			option:toUI()
		end
	end
	for i, v in pairs(IPPJSettingsCache.CrosshairColorMIN) do
		IPPJModOptions:getOption("CrosshairColorMIN[i] = v
	end
	for i, v in pairs(IPPJSettingsCache.CrosshairColorMAX) do
		IPPJModOptions:getOption("CrosshairColorMAX[i] = v
	end
	IPPJSettingsCache = {}
end

function MainOptions:IPPJDropdown(x, y, w, h, name, options, tooltip)
	local combo = self:addCombo(x, y, w, h, getText("UI_IPPJ" .. name), options, getTypeIndex(options, IPPJSettings[name]), self, setChanged)

	if tooltip then
		local map = {}
		map["defaultTooltip"] = getText("UI_IPPJ" .. name .. "_tooltip")
		combo:setToolTipMap(map)
	end

	local gameOp = IPPJGameOption:new(name, combo)

	function gameOp.toUI(self)
		self.control.selected = getTypeIndex(self.control.options, IPPJSettings[name])
	end
	function gameOp.apply(self)
		IPPJSettings[name] = self.control.options[self.control.selected]
		IPPJSettings[name .. "Idx"] = self.control.selected
	end
	self.gameOptions:add(gameOp)
end

function MainOptions:IPPJCheckBox(x, y, w, h, name, tooltip)
	if luautils.stringStarts(IPPJModOptions:getOption("GameVersion, "40") then
		local cb = self:addCombo(x, y, w, h, getText("UI_IPPJ" .. name), {getText("UI_Yes"), getText("UI_No")}, IPPJSettings[name], self, setChanged)

		local cbGameOp = IPPJGameOption:new(name, cb)

		function cbGameOp.toUI(self)
			if IPPJSettings[name] then
				self.control.selected = 1
			else
				self.control.selected = 2
			end
		end
		function cbGameOp.apply(self)
			IPPJSettings[name] = self.control.selected == 1
		end
		self.gameOptions:add(cbGameOp)

	else
		local yesNo = self:addYesNo(x, y, w, h, getText("UI_IPPJ" .. name))
		yesNo.changeOptionMethod = setChanged
		yesNo.changeOptionTarget = self

		if tooltip then
			yesNo.tooltip = getText("UI_IPPJ" .. name .. "_tooltip")
		end

		local gameOp = IPPJGameOption:new(name, yesNo)

		function gameOp.toUI(self)
			self.control:setSelected(1, IPPJSettings[name])
		end
		function gameOp.apply(self)
			IPPJSettings[name] = self.control:isSelected(1)
		end
		self.gameOptions:add(gameOp)
	end
end

function MainOptions:IPPJSlider(x, y, w, h, name, min, max, step)
	local fontHeight = getTextManager():getFontHeight(UIFont.Small)
	local value = IPPJSettings[name]

	local label = ISLabel:new(x, y + self.addY, fontHeight, getText("UI_IPPJ" .. name), 1, 1, 1, 1, UIFont.Small)
	label:initialise()
	self.mainPanel:addChild(label)

	local currVal = ISLabel:new(x + 20 + w + 10, y + self.addY, fontHeight, tostring(value), 1, 1, 1, 1, UIFont.Small, true)
	currVal:initialise()
	self.mainPanel:addChild(currVal)

	local slider = ISSliderPanel:new(x + 20, y + self.addY + (math.max(fontHeight, h) - h) / 2, w, h, self, onSliderChange)
	slider:initialise()
	slider.label = currVal
	slider.ct_onChange = onchange

	slider:setValues(min, max, step, step)
	slider:setCurrentValue(value)
	slider.selected = selected
	slider.default = selected

	self.mainPanel:addChild(slider)

	self.mainPanel:insertNewLineOfButtons(slider)
	self.addY = self.addY + math.max(fontHeight, h) + 6

	local gameOp = IPPJGameOption:new(name, slider)

	function gameOp.toUI(self)
		self.control:setCurrentValue(IPPJSettings[name])
	end
	function gameOp.apply(self)
		IPPJSettings[name] = self.control:getCurrentValue()
	end
	self.gameOptions:add(gameOp)
end

function MainOptions:IPPJRGBPicker(x, y, w, h, name)
	local fontHeight = getTextManager():getFontHeight(UIFont.Small)
	local rgba = IPPJSettings[name]
	local nx = x + 20
	local ox = 0

	local height = math.max(fontHeight, 20 + 4)
	local aimColor = ISButton:new(nx + ox, y + self.addY + (height - 20) / 2, 40, 20, "", self, rgbPickerBtnClick)
	aimColor:initialise()
	aimColor.backgroundColor = {r = rgba.r, g = rgba.g, b = rgba.b, a = 1}

	ox = ox + aimColor.width + 10
	local label = ISLabel:new(x, y + self.addY, fontHeight, getText("UI_IPPJ" .. name), 1, 1, 1, 1, UIFont.Small)
	label:initialise()

	aimColor.colorPicker2 = ISColorPicker:new(0, 0)
	aimColor.colorPicker2:initialise()
	aimColor.colorPicker2.pickedTarget = aimColor
	aimColor.colorPicker2.pickedFunc = pickRGBColor
	aimColor.colorPicker2.resetFocusTo = self
	aimColor.colorPicker2:setInitialColor(ColorInfo.new(rgba.r, rgba.g, rgba.b, 1))

	local currVal = ISLabel:new(x + w + 30, y + self.addY, fontHeight, tostring(rgba.a), 1, 1, 1, 1, UIFont.Small, true)
	currVal:initialise()

	self.mainPanel:addChild(aimColor)
	self.mainPanel:addChild(label)
	self.mainPanel:addChild(currVal)

	local aLabel = ISLabel:new(nx + ox, y + self.addY, fontHeight, "A:", 1, 1, 1, 1, UIFont.Small, true)
	aLabel:initialise()
	self.mainPanel:addChild(aLabel)
	ox = ox + aLabel.width + 5

	local slider = ISSliderPanel:new(nx + ox, y + self.addY + (math.max(fontHeight, h) - h) / 2, w-ox, h, self, onSliderChange)
	slider:initialise()
	slider.label = currVal
	slider.ct_onChange = onchange

	slider:setValues(0, 1, 0.01, 0.01)
	slider:setCurrentValue(rgba.a)
	slider.selected = selected
	slider.default = selected

	self.mainPanel:addChild(slider)
	self.mainPanel:insertNewLineOfButtons(slider)
	self.addY = self.addY + math.max(fontHeight, h) + 6

	gameOption = IPPJGameOption:new(name, aimColor)
	gameOption.alpha = slider
	gameOption.isRGBPicker = true
	function gameOption.toUI(self)
		local color = IPPJSettings[name]
		self.control.backgroundColor = {r = color.r, g = color.g, b = color.b, a = 1}
		self.alpha:setCurrentValue(color.a)
	end
	function gameOption.apply(self)
		local current = self.control.backgroundColor
		IPPJSettings[name] = {r = current.r, g = current.g, b = current.b, a = self.alpha:getCurrentValue()}
		self.gameOptions.changed = true
	end
	self.gameOptions:add(gameOption)
end

function MainOptions:IPPresetButton(x, y, action)
	local fontHeight = getTextManager():getFontHeight(UIFont.Medium)
	local reset = ISButton:new(x, y, 150, fontHeight, "RESET " .. action, self)
	if action == "ALL" then
		reset.onclick = onResetAllClick
	else
		reset.onclick = onResetColorClick
	end
	reset:initialise()

	self.mainPanel:addChild(reset)
end

local function IPPJOptionsInit(mainOption)
	if not mainOption.tabs:getView(PageName) then
		mainOption:addPage(PageName)
		mainOption.addY = 50
		local leftPos = mainOption:getWidth() / 3
		local optionWidth = 300

		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "SimplifiedProj", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "CustomBloodEffect", false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "CustomBloodEffectOthers", false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "ExplosionEffect", false)
		mainOption.addY = mainOption.addY + 15
		mainOption:IPPJDropdown(leftPos, 0, optionWidth, 20, "CrosshairType", CrosshairTypeList, false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "CrosshairDot", false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "CrosshairOutline", false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "RemoveIsoCursor", false)
		mainOption:IPPJDropdown(leftPos, 0, optionWidth, 20, "SniperScope", SniperScopeTypeList, true)
		mainOption:IPPJSlider(leftPos, 0, optionWidth, 20, "SniperScopeRangeV", 0, 30, 0.1)
		mainOption:IPPJSlider(leftPos, 0, optionWidth, 20, "CrosshairHeight", -40, 40, 0.5)
		mainOption.addY = mainOption.addY + 15
		--mainOption:IPPJSlider(leftPos, 0, optionWidth, 20, "AimCalcDelay", 0, 20, 1)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "ShowAmmoCount", false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "ShowOutOfRange", false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "ShowPlayerLevel", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "ResetLevel", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "AdjustLevelFloor", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "AimAssistLZombie", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "VisualRecoil", true)
		mainOption:IPPJSlider(leftPos, 0, optionWidth, 20, "VisualRecoilMult", 0.1, 5, 0.05)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "MoodleEffectPanic", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "MoodleEffectTired", true)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "MoodleEffectCold", true)
		mainOption.addY = mainOption.addY + 15
		mainOption:IPPJDropdown(leftPos, 0, optionWidth, 20, "HitMarkType", HitMarkTypeList, false)
		mainOption:IPPJCheckBox(leftPos, 0, optionWidth, 20, "HitInfoText", false)
		mainOption.addY = mainOption.addY + 15
		mainOption:IPPJRGBPicker(leftPos, 0, optionWidth, 20, "CrosshairColorMIN")
		mainOption:IPPJRGBPicker(leftPos, 0, optionWidth, 20, "CrosshairColorMAX")
		mainOption:IPPresetButton(leftPos + 40, mainOption.addY + 50, "COLOR")
		mainOption:IPPresetButton(leftPos + 200, mainOption.addY + 50, "ALL")

		mainOption.mainPanel:setScrollHeight(mainOption.addY + 50)
	end
end

local function DoSave()
	saveSettings()
end

local old_MainOptionCreate = MainOptions.create
function MainOptions:create()
	old_MainOptionCreate(self)
	local status, err = pcall(IPPJOptionsInit, self)
	if not status then
		print("MainOptions:create Error")
	end
end

local old_MainOptionApply = MainOptions.apply
function MainOptions:apply(closeAfter)
	old_MainOptionApply(self, closeAfter)
	local status, err = pcall(DoSave)
	if not status then
		print("MainOptions:apply Error")
	end
	UserIsoCursorVis = getCore():getIsoCursorVisibility()
	UserUIFBO = getCore():getOptionUIFBO()
	UserUIRenderFPS = getCore():getOptionUIRenderFPS()
end
]]

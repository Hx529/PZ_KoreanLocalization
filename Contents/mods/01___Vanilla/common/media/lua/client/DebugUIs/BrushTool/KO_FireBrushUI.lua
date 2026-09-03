-- 브러시 도구 매니저 - 화재 설정 번역

function FireBrushUI:initialise()
    ISPanelJoypad.initialise(self);

    local buttonWid = 150
    local buttonHgt = 25

    self.brushType = ISRadioButtons:new(self:getWidth()/2 - 50, 26, 150, 20, self)
    self.brushType.choicesColor = {r=1, g=1, b=1, a=1}
    self.brushType:initialise()
    self.brushType.autoWidth = true;
    self:addChild(self.brushType)
    self.brushType:addOption(getText("IGUI_DebugContext_BrushToolManager_Fire"));
    self.brushType:addOption(getText("IGUI_DebugContext_BrushToolManager_Smoke"))
    self.brushType:addOption(getText("IGUI_DebugContext_BrushToolManager_Explosion"))
    self.brushType:setSelected(1)

    self.addByClick = ISButton:new(self:getWidth() / 2 - buttonWid/2, self.brushType:getBottom() + 10, buttonWid, buttonHgt, getText("IGUI_DebugContext_BrushToolManager_Add_by_click"), self, FireBrushUI.onClick);
    self.addByClick.internal = "ADDBYCLICK";
    self.addByClick:initialise();
    self.addByClick:instantiate();
    self:addChild(self.addByClick);

    self.removeByClick = ISButton:new(self:getWidth() / 2 - buttonWid/2, self.addByClick:getBottom() + 10, buttonWid, buttonHgt, getText("IGUI_DebugContext_BrushToolManager_Remove_by_click"), self, FireBrushUI.onClick);
    self.removeByClick.internal = "REMOVEBYCLICK";
    self.removeByClick:initialise();
    self.removeByClick:instantiate();
    self:addChild(self.removeByClick);

    self.addByArea = ISButton:new(self:getWidth() / 2 - buttonWid/2, self.removeByClick:getBottom() + 10, buttonWid, buttonHgt, getText("IGUI_DebugContext_BrushToolManager_Add_by_area"), self, FireBrushUI.onClick);
    self.addByArea.internal = "ADDBYAREA";
    self.addByArea:initialise();
    self.addByArea:instantiate();
    self:addChild(self.addByArea);

    self.removeByArea = ISButton:new(self:getWidth() / 2 - buttonWid/2, self.addByArea:getBottom() + 10, buttonWid, buttonHgt, getText("IGUI_DebugContext_BrushToolManager_Remove_by_area"), self, FireBrushUI.onClick);
    self.removeByArea.internal = "REMOVEBYAREA";
    self.removeByArea:initialise();
    self.removeByArea:instantiate();
    self:addChild(self.removeByArea);

    self.close = ISButton:new(self:getWidth() / 2 - buttonWid/2, self.removeByArea:getBottom() + 10, buttonWid, buttonHgt, getText("IGUI_DebugContext_BrushToolManager_Close"), self, FireBrushUI.onClick);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self:addChild(self.close);
end

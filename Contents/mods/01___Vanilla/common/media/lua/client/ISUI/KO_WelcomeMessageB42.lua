-- local originalCreate = WelcomeMessageUI.create

-- WelcomeMessageUI.create = function(self)
--     originalCreate(self)

--     if self.titleLabel then
--         self.titleLabel:setName(getText("UI_B42_Welcome_1"))
--     end
--     if self.changeLabel then
--         self.changeLabel:setName(getText("UI_B42_Welcome_2"))
--     end
-- end

-- local originalRender = WelcomeMessageUI.render

-- WelcomeMessageUI.render = function(self)
--     originalRender(self)

--     self.rich.text = getText("UI_B42_Welcome_3")
--     self.rich:paginate()
-- end

require('NPCs/MainCreationMethods');

local function initKnoxEventTraits()
    TraitFactory.addTrait("Married", getText("UI_KnoxEvent_Married"), 1, getText("UI_KnoxEvent_Married_tooltip"), false);
end

Events.OnGameBoot.Add(initKnoxEventTraits);

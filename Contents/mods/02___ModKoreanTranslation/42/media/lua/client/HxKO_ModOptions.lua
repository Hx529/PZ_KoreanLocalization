-- Hx KO: 다른 모드가 PZAPI.ModOptions에 영어로 하드코딩한 옵션 문구를 한국어로 바꾼다.
-- * 옵션 화면을 그리기 직전(MainOptions:addModOptionsPanel)에 적용하므로 모드 로드 순서와 무관하다.
-- * PZAPI.ModOptions.Data에 등록된(= 활성화된) 모드만 처리한다.
-- * 영어 원문이 HxKO_ModOptions_Data.lua에 기록된 문장과 정확히 같을 때만 바꾼다.
--   모드 업데이트로 원문이 바뀌면 그 항목은 영어로 남는다.
-- * 번역문은 KO UI.json의 UI_HxMO_* 키에 있으므로 한국어가 아닌 언어에서는 아무것도 바뀌지 않는다.
require "PZAPI/ModOptions"
require "OptionScreens/MainOptions"
require "HxKO_ModOptions_Data"

HxKO_MO = HxKO_MO or {}
local map = HxKO_MO.map or {}

-- 모드 ID를 알 수 없는 경우를 위한 전체 색인 (먼저 등록된 키 우선)
local any = {}
for _, t in pairs(map) do
    for en, key in pairs(t) do
        if any[en] == nil then any[en] = key end
    end
end

local count = 0

local function lookup(scope, en)
    if type(en) ~= "string" or en == "" then return nil end
    local t = map[scope]
    local key = (t and t[en]) or any[en]
    if key and getTextOrNull(key) then
        count = count + 1
        return key
    end
    return nil
end

-- 다중 체크박스는 화면 라벨(getText(name))로 비활성 상태를 찾으므로,
-- 모드가 영어 이름으로 setEnabled를 불러도 번역된 라벨에 적용되도록 바꾼다.
local function multiSetEnabled(self, optionName, value)
    local idx = self.nameToIndex[optionName]
    if idx == nil or self.values[idx] == nil then return end
    self.values[idx].isEnabled = value
    if self.element ~= nil then
        self.element:disableOption(self.values[idx].name, not value)
    end
end

local function translate(options)
    local scope = options.modOptionsID
    local k = lookup(scope, options.name)
    if k then options.name = k end
    for _, opt in ipairs(options.data) do
        if opt.type == "description" then
            k = lookup(scope, opt.text)
            if k then opt.text = getText(k) end
        elseif opt.type ~= "separator" then
            k = lookup(scope, opt.name)
            if k then opt.name = k end
            k = lookup(scope, opt.tooltip)
            if k then opt.tooltip = k end
        end
        if opt.type == "combobox" then
            for i, v in ipairs(opt.values) do
                k = lookup(scope, v)
                if k then opt.values[i] = getText(k) end
            end
        elseif opt.type == "multipletickbox" then
            local changed = false
            for _, v in ipairs(opt.values) do
                k = lookup(scope, v.name)
                if k then
                    v.name = getText(k)
                    changed = true
                end
            end
            if changed then opt.setEnabled = multiSetEnabled end
        end
    end
end

function HxKO_MO.apply()
    count = 0
    for _, options in ipairs(PZAPI.ModOptions.Data) do
        local ok, err = pcall(translate, options)
        if not ok then
            print("[HxKO] ModOptions translate failed: " .. tostring(options.modOptionsID) .. " " .. tostring(err))
        end
    end
    if count > 0 then
        print("[HxKO] ModOptions: translated " .. count .. " strings")
    end
end

-- 옵션 화면을 여는 함수 앞에 번역을 끼워 넣는다. [B42] Mod Manager처럼 이 파일보다 늦게 로드되어
-- 함수를 덮어쓰는 모드가 있으므로, 모든 Lua가 로드된 뒤(OnGameBoot)에 그 시점의 함수를 감싼다.
local function wrap(tbl, name)
    if type(tbl) ~= "table" or type(tbl[name]) ~= "function" then return end
    local orig = tbl[name]
    if HxKO_MO.wrapped[orig] then return end
    local f = function(...)
        HxKO_MO.apply()
        return orig(...)
    end
    HxKO_MO.wrapped[f] = true
    tbl[name] = f
end

local function hook()
    HxKO_MO.wrapped = HxKO_MO.wrapped or {}
    wrap(MainOptions, "addModOptionsPanel")   -- 바닐라 옵션 > 모드 탭
    wrap(ModOptionsScreen, "new")             -- [B42] Mod Manager 모드 옵션 화면
    HxKO_MO.apply()
end

hook()
Events.OnGameBoot.Add(hook)
Events.OnMainMenuEnter.Add(hook)
Events.OnGameStart.Add(hook)

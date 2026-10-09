-- Hx KO: 모드가 Lua 테이블에 영어로 하드코딩한 표시 문구를 번역 키로 바꿔 적용한다.
-- * TARGETS에 적은 모드가 켜져 있을 때만, 그 모드 모듈이 돌려준 테이블을 찾아 문자열을 제자리에서 바꾼다.
--   모드는 같은 테이블을 참조하므로 원본 파일을 고치지 않고도 번역문이 표시된다.
-- * 영어 원문 -> 번역 키 대응은 HxKO_Hardcoded_Data.lua(자동 생성), 번역문은 KO Tooltip.json의 Tooltip_HxHC_* 키에 있다.
-- * 원문이 바뀐 줄이나 번역 키가 없는 줄(한국어가 아닌 언어 포함)은 그대로 둔다.
require "HxKO_Hardcoded_Data"

HxKO_HC = HxKO_HC or {}
local map = HxKO_HC.map or {}

-- mods: 모드 ID 중 하나라도 켜져 있으면 적용 / module: require 경로 / path: 모듈 테이블 안의 필드 경로
local TARGETS = {
    { scope = "GoM", mods = { "GunsOfMarz", "MarzGuns" },
      module = "MarzWeapons/ItemTooltipsTable", path = { "tooltipsPergun" } },
}

local function isActive(ids)
    local active = getActivatedMods()
    if not active then return false end
    for _, id in ipairs(ids) do
        if active:contains(id) or active:contains("\\" .. id) then return true end
    end
    return false
end

local function tr(scope, s)
    local t = map[scope]
    local key = t and t[s]
    if key then
        local text = getTextOrNull(key)
        if text then return text end
    end
    return nil
end

-- table of strings, or table of (string | table of strings); replaces in place
local function translateValues(scope, tbl)
    local n = 0
    for k, v in pairs(tbl) do
        if type(v) == "string" then
            local text = tr(scope, v)
            if text then tbl[k] = text; n = n + 1 end
        elseif type(v) == "table" then
            for i, line in pairs(v) do
                if type(line) == "string" then
                    local text = tr(scope, line)
                    if text then v[i] = text; n = n + 1 end
                end
            end
        end
    end
    return n
end

local done = {}

function HxKO_HC.apply()
    local ok, lang = pcall(function() return Translator.getLanguage():name() end)
    if not ok or lang ~= "KO" then return end
    for _, target in ipairs(TARGETS) do
        if not done[target.scope] and isActive(target.mods) then
            local okReq, mod = pcall(require, target.module)
            local tbl = okReq and mod or nil
            for _, field in ipairs(target.path) do
                if type(tbl) ~= "table" then break end
                tbl = tbl[field]
            end
            if type(tbl) == "table" then
                local okRun, n = pcall(translateValues, target.scope, tbl)
                if okRun then
                    done[target.scope] = true
                    print("[HxKO] Hardcoded " .. target.scope .. ": translated " .. tostring(n) .. " strings")
                else
                    print("[HxKO] Hardcoded " .. target.scope .. " failed: " .. tostring(n))
                end
            end
        end
    end
end

Events.OnGameBoot.Add(HxKO_HC.apply)
Events.OnMainMenuEnter.Add(HxKO_HC.apply)
Events.OnGameStart.Add(HxKO_HC.apply)

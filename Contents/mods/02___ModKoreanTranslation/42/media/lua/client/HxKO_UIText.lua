-- Hx KO: 모드가 표시 함수에 영어 문자열을 직접 넘기는 경우(컨텍스트 메뉴, 버튼, 라벨, 툴팁, 말풍선, 헤일로 등)를 번역한다.
-- * 원문 -> 번역 키 대응은 HxKO_UIText_Data.lua(자동 생성), 번역문은 KO Tooltip.json의 Tooltip_HxUI_* 키에 있다.
-- * 원문을 쓴 모드가 하나라도 켜져 있는 항목만 사용하며, 게임 언어가 한국어가 아니면 아무것도 바꾸지 않는다.
-- * 모드 코드는 고치지 않는다. 화면에 그리거나 저장하는 순간의 문자열만 바꾸므로,
--   컨텍스트 메뉴 option.name 등 모드가 비교에 쓰는 값은 영어 그대로 남는다.
-- 일치 순서: 전체 문장(앞뒤 공백 무시) -> 자리표시자 템플릿 -> 줄 단위 -> 문장 조각(단어 경계).
require "HxKO_UIText_Data"

HxKO_UI = HxKO_UI or {}
local D = HxKO_UI

local enabled = false
local FULL, FRAGW, TPL, CAP = {}, {}, {}, {}
local cache, cacheN = {}, 0
local WRAPPED = {}

local function lookupFull(s)
    local t = FULL[s]
    if t then return t end
    if s:find("^%s") or s:find("%s$") then
        local lead, core, trail = s:match("^(%s*)(.-)(%s*)$")
        t = core and FULL[core]
        if t then return lead .. t .. trail end
    end
    return nil
end

local function replaceAt(s, tok, val)
    local a, b = s:find(tok, 1, true)
    if not a then return s end
    return s:sub(1, a - 1) .. val .. s:sub(b + 1)
end

local function tryTpl(s)
    for _, t in ipairs(TPL) do
        local caps = { s:match(t.pat) }
        if caps[1] ~= nil then
            local out, ok = t.ko, true
            for i, tok in ipairs(t.toks) do
                local v = caps[i]
                local kind = t.kinds:sub(i, i)
                local tv = CAP[v]
                if not tv and kind ~= "e" then tv = lookupFull(v) or v end
                if not tv then ok = false; break end
                out = replaceAt(out, tok, tv)
            end
            if ok then return out end
        end
    end
    return nil
end

local function replaceFrags(s)
    local cands, seen = nil, {}
    for w in s:gmatch("[A-Za-z]+") do
        if not seen[w] then
            seen[w] = true
            local list = FRAGW[w]
            if list then
                cands = cands or {}
                for _, f in ipairs(list) do cands[#cands + 1] = f end
            end
        end
    end
    if not cands then return nil end
    table.sort(cands, function(a, b) return #a.en > #b.en end)
    local out, changed = s, false
    for _, f in ipairs(cands) do
        local init = 1
        while true do
            local i, j = out:find(f.en, init, true)
            if not i then break end
            local okB = not (f.wordStart and i > 1 and out:sub(i - 1, i - 1):find("[A-Za-z0-9]"))
            local okA = not (f.wordEnd and out:sub(j + 1, j + 1):find("[A-Za-z0-9]"))
            -- 한 단어짜리 조각("Drop " .. 아이템 이름 등)은 맨 앞에 오고, 뒤가 영어 문장(소문자 단어)이 아닐 때만 바꾼다.
            if f.startOnly and ((i > 1 and not out:sub(1, i - 1):find("^[%s%p]*$"))
                    or (" " .. out:sub(j + 1)):find("[^A-Za-z'][a-z]")) then
                okB = false
            end
            if okB and okA then
                out = out:sub(1, i - 1) .. f.ko .. out:sub(j + 1)
                init = i + #f.ko
                changed = true
            else
                init = i + 1
            end
        end
    end
    return changed and out or nil
end

local function perLine(s)
    local parts, changed = {}, false
    for line in (s .. "\n"):gmatch("(.-)\n") do
        local t = lookupFull(line)
        if t then changed = true; parts[#parts + 1] = t else parts[#parts + 1] = line end
    end
    return changed and table.concat(parts, "\n") or nil
end

local function translate(s)
    if not enabled or type(s) ~= "string" then return s end
    local c = cache[s]
    if c then return c end
    local out = s
    if s:find("[A-Za-z][A-Za-z]") then
        out = lookupFull(s) or tryTpl(s)
        if not out then
            out = s
            if s:find("\n", 1, true) then out = perLine(out) or out end
            out = replaceFrags(out) or out
        end
    end
    if cacheN >= 4000 then cache, cacheN = {}, 0 end
    cache[s] = out
    cacheN = cacheN + 1
    return out
end
HxKO_UI.translate = translate

-- 켜진 모드 기준으로 번역표를 다시 만든다.
function HxKO_UI.build()
    FULL, FRAGW, TPL, CAP = {}, {}, {}, {}
    cache, cacheN = {}, 0
    enabled = false
    local okLang, lang = pcall(function() return Translator.getLanguage():name() end)
    if not okLang or lang ~= "KO" then return end
    local active = {}
    local list = getActivatedMods()
    if list then
        for i = 0, list:size() - 1 do
            local id = tostring(list:get(i))
            active[id] = true
            active[(id:gsub("^\\", ""))] = true
        end
    end
    local function on(e, from)
        for i = from, #e do
            if active[D.mods[e[i]]] then return true end
        end
        return false
    end
    local function ko(id) return getTextOrNull("Tooltip_HxUI_" .. id) end
    local n = 0
    for _, e in ipairs(D.full or {}) do
        if on(e, 3) then
            local t = ko(e[2])
            if t then FULL[e[1]] = t; n = n + 1 end
        end
    end
    for _, e in ipairs(D.frag or {}) do
        if on(e, 3) then
            local t = ko(e[2])
            local w = e[1]:match("[A-Za-z]+")
            if t and w then
                FRAGW[w] = FRAGW[w] or {}
                table.insert(FRAGW[w], { en = e[1], ko = t, startOnly = e[1]:find("^[A-Za-z]+$") ~= nil,
                    wordStart = e[1]:find("^[A-Za-z0-9]") ~= nil, wordEnd = e[1]:find("[A-Za-z0-9]$") ~= nil })
                n = n + 1
            end
        end
    end
    for _, e in ipairs(D.cap or {}) do
        if on(e, 3) then
            local t = ko(e[2])
            if t then CAP[e[1]] = t; n = n + 1 end
        end
    end
    for _, e in ipairs(D.tpl or {}) do
        if on(e, 5) then
            local t = ko(e[2])
            if t then table.insert(TPL, { pat = e[1], ko = t, toks = e[3], kinds = e[4] }); n = n + 1 end
        end
    end
    enabled = n > 0
    print("[HxKO] UIText: " .. tostring(n) .. " strings for active mods")
end

-- 함수 감싸기: 이미 감싼 함수는 다시 감싸지 않는다(다른 모드가 덮어쓴 경우에만 새로 감쌈).
local function wrap(tbl, name, make)
    if tbl == nil then return end
    local ok, orig = pcall(function() return tbl[name] end)
    if not ok or orig == nil or WRAPPED[orig] then return end
    local f = make(orig)
    local okSet = pcall(function() tbl[name] = f end)
    if okSet then WRAPPED[f] = true end
end

local function arg2(orig) return function(a, b, ...) return orig(a, translate(b), ...) end end
local function arg5(orig) return function(a1, a2, a3, a4, a5, ...) return orig(a1, a2, a3, a4, translate(a5), ...) end end
local function arg6(orig) return function(a1, a2, a3, a4, a5, a6, ...) return orig(a1, a2, a3, a4, a5, translate(a6), ...) end end

-- 리치 텍스트(채팅 포함)는 paginate 단계에서 처리하므로 줄 단위 drawText는 건너뛴다.
local function draw(orig)
    return function(self, str, ...)
        if enabled and type(self) == "table" and self.lineX == nil then str = translate(str) end
        return orig(self, str, ...)
    end
end

local function tooltipRender(orig)
    return function(self, ...)
        if enabled then
            if type(self.name) == "string" then self.name = translate(self.name) end
            if type(self.description) == "string" then self.description = translate(self.description) end
            if type(self.footNote) == "string" then self.footNote = translate(self.footNote) end
        end
        return orig(self, ...)
    end
end

local function paginate(orig)
    return function(self, ...)
        if enabled and type(self.text) == "string" and self.log == nil then self.text = translate(self.text) end
        return orig(self, ...)
    end
end

-- 메뉴 폭은 번역문 기준으로 재되, option.name은 원래 값으로 되돌린다.
local function calcWidth(orig)
    return function(self, ...)
        if not enabled or type(self.options) ~= "table" then return orig(self, ...) end
        local saved = {}
        for i, o in ipairs(self.options) do saved[i] = o.name; o.name = translate(o.name) end
        local ok, r = pcall(orig, self, ...)
        for i, o in ipairs(self.options) do o.name = saved[i] end
        if not ok then error(r) end
        return r
    end
end

local JAVA_CLASSES = { "IsoGameCharacter", "IsoLivingCharacter", "IsoPlayer", "IsoZombie", "IsoSurvivor", "IsoAnimal" }
local JAVA_METHODS = { "Say", "SayShout", "SayWhisper", "setHaloNote", "addLineChatElement" }

local function installJava()
    if type(__classmetatables) ~= "table" then return end
    for _, cname in ipairs(JAVA_CLASSES) do
        local ok, base = pcall(function()
            local cls = _G[cname]
            local mt = cls and __classmetatables[cls.class]
            return mt and mt.__index
        end)
        if ok and type(base) == "table" then
            for _, m in ipairs(JAVA_METHODS) do
                if rawget(base, m) ~= nil then wrap(base, m, arg2) end
            end
        end
    end
    local H = _G.HaloTextHelper
    if H ~= nil then
        for _, m in ipairs({ "addText", "addTextWithArrow", "addGoodText", "addBadText" }) do wrap(H, m, arg2) end
    end
end

function HxKO_UI.install()
    if ISUIElement then
        for _, m in ipairs({ "drawText", "drawTextCentre", "drawTextRight", "drawTextZoomed", "drawTextUntrimmed",
                             "drawTextStatic", "drawTextCentreStatic", "drawTextRightStatic" }) do
            wrap(ISUIElement, m, draw)
        end
    end
    if ISButton then wrap(ISButton, "new", arg6); wrap(ISButton, "setTitle", arg2) end
    if ISLabel then wrap(ISLabel, "new", arg5); wrap(ISLabel, "setName", arg2); wrap(ISLabel, "setNameWithoutMoving", arg2) end
    if ISModalDialog then wrap(ISModalDialog, "new", arg6) end
    if ISTextBox then wrap(ISTextBox, "new", arg6) end
    if ISRadialMenu then wrap(ISRadialMenu, "addSlice", arg2) end
    if ISToolTip then wrap(ISToolTip, "render", tooltipRender) end
    if ISRichTextPanel then wrap(ISRichTextPanel, "paginate", paginate) end
    if ISContextMenu then wrap(ISContextMenu, "calcWidth", calcWidth) end
    installJava()
end

local function boot()
    HxKO_UI.build()
    HxKO_UI.install()
end

Events.OnGameBoot.Add(boot)
Events.OnMainMenuEnter.Add(boot)
Events.OnGameStart.Add(boot)

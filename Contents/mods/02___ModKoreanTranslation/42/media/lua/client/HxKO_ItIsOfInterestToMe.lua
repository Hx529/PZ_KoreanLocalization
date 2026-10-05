-- Hx KO: "It Is Of Interest To Me" 모드의 편지/쪽지 본문을 한국어로 바꾼다.
-- 이 모드는 본문을 자기 폴더(Content/<Pool>/<언어>/<id>.txt)에서만 읽으므로(getModFileReader),
-- 번역팩에 같은 id의 파일을 두고, 모드가 만든 텍스트 풀(NoteContentPool, LetterContentPools)의
-- 항목 text를 id 기준으로 덮어쓴다. 모드는 아이템을 열 때마다 풀에서 id로 본문을 다시 찾으므로
-- 이미 읽은 편지에도 적용된다.
-- * 모드가 꺼져 있으면 풀 전역 변수가 없으므로 아무것도 하지 않는다.
-- * 게임 언어가 KO일 때만 적용한다. 번역 파일이 없는 id는 원문(EN) 그대로 둔다.
local MY_MOD_ID = "Hx_KR_Mod"
local BASE = "media/lua/shared/HxKO_Content/ItIsOfInterestToMe/"

local function readAll(path)
    local reader = getModFileReader(MY_MOD_ID, path, false)
    if not reader then return nil end
    local lines = {}
    while true do
        local line = reader:readLine()
        if line == nil then break end
        table.insert(lines, line)
    end
    reader:close()
    local text = table.concat(lines, "\n")
    if text == "" then return nil end
    return text
end

local function overlay(pool, poolName)
    if type(pool) ~= "table" then return 0 end
    local n = 0
    for _, entry in ipairs(pool) do
        if type(entry) == "table" and entry.id and not entry.hxko then
            local text = readAll(BASE .. poolName .. "/" .. entry.id)
            if text then
                entry.text = text
                entry.hxko = true
                n = n + 1
            end
        end
    end
    return n
end

local function apply()
    local ok, lang = pcall(function() return Translator.getLanguage():name() end)
    if not ok or lang ~= "KO" then return end
    local n = 0
    if NoteContentPool then
        n = n + overlay(NoteContentPool, "Note")
    end
    if LetterContentPools then
        for category, pool in pairs(LetterContentPools) do
            n = n + overlay(pool, "Letters/" .. category)
        end
    end
    if n > 0 then
        print("[HxKO] ItIsOfInterestToMe: translated " .. n .. " texts")
    end
end

Events.OnGameBoot.Add(apply)
Events.OnMainMenuEnter.Add(apply)
Events.OnGameStart.Add(apply)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""번역 json 정리 도구.

KO 번역 json의 키를 사람이 읽기 좋은 순서로 다시 배열하고, 구역마다 머리글 키를 넣는다.
값은 한 글자도 바꾸지 않는다(원문 JSON 문자열을 그대로 옮김). 몇 번을 실행해도 결과가 같다.

  02___ModKoreanTranslation (통합 번역)
      창작마당 모드별로 묶는다. 모드 제목 순으로 정렬하고, 모드 안에서는 그 모드 번역 파일의 키 순서를 따른다.
          "========== Radio Traders [3807707103] ==========": "",
      설치된 모드 어디에도 없는 키는 맨 끝 "출처 미확인" 구역에 원래 순서대로 남긴다.
  01___Vanilla (바닐라 번역)
      파일마다 알맞은 분류로 묶는다(아이템 분류, 제작 분류, 샌드박스 옵션 페이지, 라디오 채널 등).
          "========== 음식 (Food) ==========": "",
      키가 적은 파일은 그대로 둔다. 예전 버전 표시 키("/** 42.19 **/", "//comment_1")는 머리글로 대체되어 사라진다.
      "--키" 형태(번역자가 꺼 둔 예전 번역)는 원래 키와 같은 구역에 남는다.

머리글 키는 값이 빈 문자열이라 게임에 아무 영향이 없다.

사용법 (저장소 루트에서):
    python tools/organize_ko_json.py              # 바뀔 내용만 보고
    python tools/organize_ko_json.py --write      # 파일에 반영
    python tools/organize_ko_json.py --write --only vanilla   # pack | vanilla 중 하나만
게임/창작마당 경로가 기본값과 다르면 --game, --workshop 으로 지정한다.
"""
import argparse
import collections
import glob
import json
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODS = os.path.join(REPO, "Contents", "mods")
PACK_KO = os.path.join(MODS, "02___ModKoreanTranslation", "42", "media", "lua", "shared", "Translate", "KO")
PACK_CLIENT = os.path.join(MODS, "02___ModKoreanTranslation", "42", "media", "lua", "client")
VAN_KO = os.path.join(MODS, "01___Vanilla", "42", "media", "lua", "shared", "Translate", "KO")
DEF_GAME = r"C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid"
DEF_WS = r"C:\Program Files (x86)\Steam\steamapps\workshop\content\108600"

HEADER_RE = re.compile(r"^=+ (.+?) =+$")
NOTE_RE = re.compile(r"^(/\*|//)")          # 예전 버전 표시/메모 키: 바닐라에서 머리글로 대체
LINE_RE = re.compile(r'^\s*("(?:[^"\\]|\\.)*")\s*:\s*("(?:[^"\\]|\\.)*")\s*,?\s*$')
WID_RE = re.compile(r"\[(\d{6,})\]$")
UNKNOWN = "출처 미확인 (현재 설치되지 않은 모드)"
OTHER = "기타"
SMALL_FILE = 60                               # 이보다 키가 적은 바닐라 파일은 묶지 않는다

CANON = ["Tooltip", "IG_UI", "Recipes", "RecipeGroups", "Farming", "ContextMenu", "SurvivalGuide", "Items", "ItemName",
         "Moodles", "Sandbox", "Challenge", "Stash", "Moveables", "MakeUp", "GameSound", "DynamicRadio",
         "EvolvedRecipeName", "Recorded_Media", "SurvivorNames", "Attributes", "Fluids", "Print_Media", "Print_Text",
         "Entity", "RadioData", "BodyParts", "MapLabel", "Credits", "UI", "MultiStageBuild", "Traits"]
CMAP = {c.lower() + ".json": c + ".json" for c in CANON}
PREFIX = {"ItemName.json": "ItemName_", "Recipes.json": "Recipe_", "EvolvedRecipeName.json": "EvolvedRecipeName_",
          "MultiStageBuild.json": "MultiStageBuild_", "RecipeGroups.json": "RecipeGroup_"}


def norm_key(fn, k):
    p = PREFIX.get(fn)
    return k[len(p):] if p and k.startswith(p) else k


def header(label):
    return "========== %s ==========" % label


# ------------------------------------------------------------------ 파일 읽기/쓰기
def read_file(path):
    """-> (entries, data). entry = dict(key, rk, rv, header, block). 머리글 키는 entries에서 빠진다."""
    text = open(path, encoding="utf-8-sig").read()
    data = json.loads(text)
    entries, head, block, seen = [], None, 0, set()
    for line in text.splitlines():
        s = line.strip()
        if s in ("{", "}"):
            continue
        if not s:
            block += 1
            continue
        m = LINE_RE.match(line)
        if not m:
            raise SystemExit("%s: 한 줄에 키 하나 형식이 아님: %s" % (path, s[:80]))
        k, v = json.loads(m.group(1)), json.loads(m.group(2))
        if k in seen or data.get(k) != v:
            raise SystemExit("%s: 중복 키이거나 값이 다름: %s" % (path, k))
        seen.add(k)
        hm = HEADER_RE.match(k)
        if hm and v == "":
            head = hm.group(1)
            block += 1
            continue
        entries.append(dict(key=k, rk=m.group(1), rv=m.group(2), header=head, block=block, pos=len(entries)))
    if len(seen) != len(data):
        raise SystemExit("%s: 줄 단위로 읽은 키 수(%d)와 json 키 수(%d)가 다름" % (path, len(seen), len(data)))
    return entries, data


def render(groups):
    """groups: [(label or None, [entry...])] -> json text"""
    out = ["{"]
    for gi, (label, items) in enumerate(groups):
        if gi:
            out.append("")
        if label is not None:
            out.append("    %s: \"\"," % json.dumps(header(label), ensure_ascii=False))
        for e in items:
            out.append("    %s: %s," % (e["rk"], e["rv"]))
    last = max(i for i, l in enumerate(out) if l.strip())
    out[last] = out[last].rstrip(",")
    out.append("}")
    return "\n".join(out) + "\n"


def apply(path, groups, data, dropped, write, report):
    new = render(groups)
    after = json.loads(new)
    body = {k: v for k, v in after.items() if not (HEADER_RE.match(k) and v == "")}
    want = {k: v for k, v in data.items() if not (HEADER_RE.match(k) and v == "") and k not in dropped}
    if body != want:
        raise SystemExit("%s: 정리 후 키/값이 원본과 다름 - 쓰지 않음" % path)
    old = open(path, encoding="utf-8-sig").read().replace("\r\n", "\n")
    changed = old != new
    report.append("%s %-24s 키 %6d  구역 %4d%s" % ("*" if changed else " ", os.path.basename(path), len(body),
                                                  sum(1 for g in groups if g[0] is not None),
                                                  ("  (메모 키 %d개 제거)" % len(dropped)) if dropped else ""))
    if write and changed:
        open(path, "w", encoding="utf-8", newline="\n").write(new)
    return changed


# ------------------------------------------------------------------ 02 통합 번역: 모드별
def load_json_loose(path):
    try:
        raw = open(path, encoding="utf-8-sig", errors="replace").read()
    except OSError:
        return {}
    try:
        d = json.loads(raw, strict=False)
        return d if isinstance(d, dict) else {}
    except ValueError:
        return {k: "" for k in re.findall(r'"((?:[^"\\]|\\.)+)"\s*:', raw)}


def scan_workshop(ws):
    """창작마당 모드의 번역 파일 전체 -> (file, key) -> [wid], key -> [wid], (wid, file, key) -> 순서, modinfo"""
    byfk, byk, order, seq = collections.defaultdict(list), collections.defaultdict(list), {}, collections.Counter()
    modid2wid, modname, langs = {}, {}, collections.defaultdict(set)
    if not os.path.isdir(ws):
        print("창작마당 폴더 없음: %s (현재 머리글 기준으로만 정리)" % ws)
        return byfk, byk, order, modid2wid, modname, set()
    for wid in sorted(os.listdir(ws)):
        root = os.path.join(ws, wid, "mods")
        if not os.path.isdir(root):
            continue
        files = []
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames.sort()
            if "mod.info" in filenames:
                txt = open(os.path.join(dirpath, "mod.info"), encoding="utf-8", errors="ignore").read()
                mid = re.search(r"(?mi)^id=\s*\\?(.+?)\s*$", txt)
                nm = re.search(r"(?mi)^name=\s*(.+?)\s*$", txt)
                if mid:
                    modid2wid.setdefault(mid.group(1), wid)
                if nm:
                    modname.setdefault(wid, nm.group(1))
            parts = dirpath.replace("\\", "/").split("/")
            if len(parts) >= 2 and parts[-2] == "Translate":
                lang = parts[-1]
                for f in sorted(filenames):
                    if f.lower().endswith(".json"):
                        langs[wid].add(lang)
                        files.append((0 if lang == "EN" else 1, dirpath, f))
        for _, dirpath, f in sorted(files, key=lambda x: x[0]):
            fn = CMAP.get(f.lower(), f)
            for k in load_json_loose(os.path.join(dirpath, f)):
                nk = norm_key(fn, k)
                if wid not in byfk[(fn, nk)]:
                    byfk[(fn, nk)].append(wid)
                if wid not in byk[nk]:
                    byk[nk].append(wid)
                seq[wid] += 1
                order.setdefault((wid, fn, nk), seq[wid])
    # EN 원문 없이 다른 언어 번역만 든 항목(번역 팩)은 소유 모드 후보에서 뒤로 미룬다
    packs = {w for w, ls in langs.items() if "EN" not in ls}
    for d in (byfk, byk):
        for k, ws in d.items():
            ws.sort(key=lambda w: w in packs)
    return byfk, byk, order, modid2wid, modname, packs


def hx_attribution(modid2wid):
    """Hx 런타임 번역 키(Tooltip_HxUI_*, UI_HxMO_*, Tooltip_HxHC_*) -> wid"""
    out = {}

    def wid_of(modid):
        if "/" in modid and modid.split("/", 1)[0].isdigit():
            return modid.split("/", 1)[0]
        return modid2wid.get(modid) or (modid if modid.isdigit() else None)

    p = os.path.join(PACK_CLIENT, "HxKO_UIText_Data.lua")
    if os.path.exists(p):
        src = open(p, encoding="utf-8").read()
        mods = re.findall(r'^    "((?:[^"\\]|\\.)*)",$', src.split("HxKO_UI.full")[0], re.M)
        for m in re.finditer(r'^    \{ "(?:[^"\\]|\\.)*", "([0-9a-f]{8})", (?:\{[^}]*\}, "[a-z]*", )?([\d, ]+) \},$', src, re.M):
            idx = [int(i) for i in m.group(2).split(",")]
            ws = [wid_of(mods[i - 1]) for i in idx if 0 < i <= len(mods)]
            ws = [w for w in ws if w]
            if ws:
                out["Tooltip_HxUI_" + m.group(1)] = sorted(ws)[0]
    p = os.path.join(PACK_CLIENT, "HxKO_ModOptions_Data.lua")
    if os.path.exists(p):
        scope = None
        for line in open(p, encoding="utf-8"):
            m = re.match(r'^    \["((?:[^"\\]|\\.)*)"\] = \{', line)
            if m:
                scope = wid_of(m.group(1))
                continue
            m = re.search(r'= "(UI_HxMO_[^"]+)",$', line)
            if m and scope:
                out[m.group(1)] = scope
    p, pd = os.path.join(PACK_CLIENT, "HxKO_Hardcoded.lua"), os.path.join(PACK_CLIENT, "HxKO_Hardcoded_Data.lua")
    if os.path.exists(p) and os.path.exists(pd):
        scope_w = {}
        for m in re.finditer(r'scope = "([^"]+)", mods = \{([^}]*)\}', open(p, encoding="utf-8").read()):
            ws = [wid_of(x) for x in re.findall(r'"([^"]+)"', m.group(2))]
            ws = [w for w in ws if w]
            if ws:
                scope_w[m.group(1)] = ws[0]
        scope = None
        for line in open(pd, encoding="utf-8"):
            m = re.match(r'^    \["([^"]+)"\] = \{', line)
            if m:
                scope = scope_w.get(m.group(1))
                continue
            m = re.search(r'= "(Tooltip_HxHC_[^"]+)",$', line)
            if m and scope:
                out[m.group(1)] = scope
    return out


def mods_md_titles():
    t = {}
    p = os.path.join(REPO, "MODS.md")
    if os.path.exists(p):
        for m in re.finditer(r"^\| \[(.+?)\]\(https://steamcommunity\.com/sharedfiles/filedetails/\?id=(\d+)\)",
                             open(p, encoding="utf-8").read(), re.M):
            t[m.group(2)] = m.group(1).replace("\\[", "[").replace("\\]", "]").replace("\\|", "|")
    return t


def sortname(t):
    return re.sub(r"^(\[[^\]]*\]\s*|\W+)+", "", t).lower() or t.lower()


def organize_pack(args, write, report):
    byfk, byk, order, modid2wid, modname, packs = scan_workshop(args.workshop)
    hx = hx_attribution(modid2wid)
    titles = dict(modname)
    titles.update(mods_md_titles())
    files = sorted(glob.glob(os.path.join(PACK_KO, "*.json")))
    parsed = {}
    for path in files:
        entries, data = read_file(path)
        parsed[path] = (entries, data)
        for e in entries:          # 지금 머리글에 쓰인 제목을 가장 우선한다(안정성)
            h = e["header"] or ""
            m = WID_RE.search(h)
            if m:
                titles[m.group(1)] = h[: m.start()].rstrip()
    stats = collections.Counter()
    for path in files:
        fn = os.path.basename(path)
        entries, data = parsed[path]
        cur = []
        for e in entries:
            m = WID_RE.search(e["header"] or "")
            cur.append(m.group(1) if m else None)
        ws = []
        for e, c in zip(entries, cur):
            k = e["key"]
            cand = byfk.get((fn, k)) or []
            if k in hx:
                w = hx[k]
            elif c and not (c in packs and cand and cand[0] not in packs):
                w = c          # 이미 모드 머리글 아래 있는 키는 옮기지 않는다 (번역 팩 머리글만 예외)
            elif cand:
                w = cand[0]
            elif byk.get(k):
                w = byk[k][0]
            else:
                w = None
            ws.append(w)
        # 출처를 모르는 키: 같은 빈 줄 블록 안에서 앞뒤 키가 같은 모드면 그 모드로
        blocks = collections.defaultdict(list)
        for i, e in enumerate(entries):
            blocks[e["block"]].append(i)
        for idx in blocks.values():
            i = 0
            while i < len(idx):
                if ws[idx[i]]:
                    i += 1
                    continue
                j = i
                while j < len(idx) and not ws[idx[j]]:
                    j += 1
                prev = ws[idx[i - 1]] if i > 0 else None
                nxt = ws[idx[j]] if j < len(idx) else None
                if prev and prev == nxt:
                    for t in range(i, j):
                        ws[idx[t]] = prev
                i = j
        groups, unknown = collections.defaultdict(list), []
        for e, w in zip(entries, ws):
            if w:
                groups[w].append(e)
                stats["mod"] += 1
            else:
                unknown.append(e)
                stats["unknown"] += 1
        out = []
        for w in sorted(groups, key=lambda w: (sortname(titles.get(w, w)), w)):
            items = sorted(groups[w], key=lambda e: (order.get((w, fn, e["key"]), 10 ** 9), e["pos"]))
            out.append(("%s [%s]" % (titles.get(w, w), w), items))
        # 출처 미확인: 원래 블록(빈 줄) 구분을 유지
        if unknown:
            first = True
            for b, idx in sorted(blocks.items()):
                items = [entries[i] for i in idx if not ws[i]]
                if items:
                    out.append((UNKNOWN if first else None, items))
                    first = False
        apply(path, out, data, set(), write, report)
    report.append("  모드별 배정 %d개, 출처 미확인 %d개" % (stats["mod"], stats["unknown"]))


# ------------------------------------------------------------------ 01 바닐라: 분류별
class Game:
    def __init__(self, root):
        self.root = root
        self.media = os.path.join(root, "media")
        self._cache = {}

    def path(self, *p):
        return os.path.join(self.media, *p)

    def ko(self, key):
        """바닐라 팩 -> 게임 KO 순으로 번역문 찾기 (분류 이름 표시용)"""
        if "ko" not in self._cache:
            d = {}
            for base in (self.path("lua", "shared", "Translate", "KO"), VAN_KO):
                for f in glob.glob(os.path.join(base, "*.json")):
                    d.update(load_json_loose(f))
            self._cache["ko"] = d
        v = self._cache["ko"].get(key)
        return v if isinstance(v, str) and v.strip() else None

    def en_order(self, fn):
        if ("en", fn) not in self._cache:
            self._cache[("en", fn)] = {k: i for i, k in enumerate(load_json_loose(self.path("lua", "shared", "Translate", "EN", fn)))}
        return self._cache[("en", fn)]

    def scripts(self):
        if "scripts" not in self._cache:
            items, recipes = {}, {}
            for p in glob.glob(self.path("scripts", "**", "*.txt"), recursive=True):
                module, cur, kind = "Base", None, None
                for line in open(p, encoding="utf-8", errors="ignore"):
                    s = line.strip()
                    m = re.match(r"^module\s+(\w+)", s)
                    if m:
                        module = m.group(1)
                        continue
                    m = re.match(r"^(item|craftRecipe|entity)\s+(\S+)", s)
                    if m:
                        kind, cur = m.group(1), m.group(2)
                        if kind == "entity":
                            parts = os.path.relpath(p, self.path("scripts")).replace("\\", "/").split("/")
                            sub = parts[parts.index("entities") + 1:-1] if "entities" in parts else []
                            if sub:
                                recipes.setdefault(cur, "entity:" + "/".join(sub))
                        continue
                    m = re.match(r"^(DisplayCategory|category)\s*=\s*([^,]+),?", s)
                    if m and cur:
                        if kind == "item" and m.group(1) == "DisplayCategory":
                            items.setdefault("%s.%s" % (module, cur), m.group(2).strip())
                        elif kind == "craftRecipe" and m.group(1) == "category":
                            recipes.setdefault(cur, m.group(2).strip())
            self._cache["scripts"] = (items, recipes)
        return self._cache["scripts"]

    def recorded_media(self):
        if "rm" not in self._cache:
            d, cat = {}, None
            p = self.path("lua", "shared", "RecordedMedia", "recorded_media.lua")
            if os.path.exists(p):
                src = open(p, encoding="utf-8", errors="ignore").read()
                for block in re.split(r"\nRecMedia\[", src)[1:]:
                    m = re.search(r'category = "([^"]+)"', block)
                    if m:
                        for rid in re.findall(r'"(RM_[0-9a-f-]+)"', block):
                            d.setdefault(rid, m.group(1))
            self._cache["rm"] = d
        return self._cache["rm"]

    def radio(self):
        if "rd" not in self._cache:
            d, chan = {}, None
            p = self.path("radio", "RadioData.xml")
            if os.path.exists(p):
                for line in open(p, encoding="utf-8", errors="ignore"):
                    m = re.search(r'<ChannelEntry [^>]*name="([^"]*)"', line)
                    if m:
                        chan = m.group(1)
                    for rid in re.findall(r'<LineEntry [^>]*ID="([0-9a-fA-F-]+)"', line):
                        d.setdefault("RD_" + rid, chan)
            self._cache["rd"] = d
        return self._cache["rd"]

    def sandbox_pages(self):
        """옵션 이름 -> (페이지 순서, 페이지 이름)"""
        if "sb" not in self._cache:
            d = {}
            p = self.path("lua", "client", "OptionScreens", "ServerSettingsScreen.lua")
            if os.path.exists(p):
                src = open(p, encoding="utf-8", errors="ignore").read()
                i = src.find('name = "Sandbox"')
                body = src[i:] if i >= 0 else ""
                page, n = None, 0
                for line in body.splitlines():
                    m = re.match(r'^\t\t\t\tname = "(\w+)",', line)
                    if m:
                        page, n = m.group(1), n + 1
                        continue
                    m = re.match(r'^\t\t\t\t\t\{ name = "([\w.]+)"', line)
                    if m and page:
                        d.setdefault(m.group(1), (n, page))
                    if line.startswith("\t}") and page:
                        break
            self._cache["sb"] = d
        return self._cache["sb"]


def base_key(k):
    return re.sub(r"^-+\s*", "", k)          # "--UI_prof_x"(꺼 둔 예전 번역)는 원래 키 기준으로 분류


def cat_label(ko, en):
    return "%s (%s)" % (ko, en) if ko and ko != en else en


def rules(table):
    comp = [(label, re.compile(rx)) for label, rx in table]

    def f(k):
        for i, (label, rx) in enumerate(comp):
            if rx.search(k):
                return i, label
        return len(comp), OTHER
    return f


IG_UI_RULES = [
    ("책·잡지·만화·신문 제목", r"^IGUI_(BookTitle|ComicTitle|MagazineTitle|MagazineName\w*|NewspaperTitle|NewspaperDate|Newspaper|LiteratureUI|Pages|RPG)(_|$)"),
    ("사진·엽서·기념품 문구", r"^IGUI_(Photo|PhotoOf|PostcardFrom|SnowGlobeOf|LocketText|Doodle)(_|$)"),
    ("편지·청구서·복권·주사위", r"^IGUI_(\w*Letter|Bill|OverdueBill|ApplicatonLetter|Draws|Rolls|One|Two|Three|With|A|PercentileDice|Loser|Winner|RollDice|ScratchingTicketName\w*)$"),
    ("열쇠 이름", r"^IGUI_(\w+Key|\w+KeyNew|KeyRingName)$"),
    ("반려동물 이름", r"^IGUI_PetName_"),
    ("기술·경험치", r"^IGUI_(perks|XP|skills|Skill)(_|$)"),
    ("캐릭터 상태·건강", r"^IGUI_(health|Health\w*|char|PlayerStats|StatsAndBody|Sleep|ConfirmSleep|StiffnessIn|Disguised|CapabilitiesTooltips|PostDeath|HaloNote|Toggle(Bite|Bleeding|Bullet|Burn|Burned|Deep|Fracture|Glass|Infected|Laceration|Muscle|Scratched)[\w ]*)(_|$)"),
    ("운동", r"^IGUI_(Fitness\w*|BarbellCurl|Burpees|PushUps|SitUps|Squats|BicepsCurl|DumbbellPress)(_|$)"),
    ("외형·옷·화장", r"^IGUI_(Hair|Beard|MakeUp|AddMakeUp|RemoveMakeUp|SelectMakeUp|SelectBodyLocation|garment|ClothingName|ClothingNaming|FabricType|TypeOfPatch)(_|$)"),
    ("감정 표현·대사", r"^IGUI_(Emote|PlayerText|Voice|ObjectAlreadyUsedSayMessage)(_|$)"),
    ("인벤토리·아이템", r"^IGUI_(invpanel|invpage|ItemCat|ItemType|ContainerTitle|FilterType|SortType|Sort|FilterAll|FilterSearch|LootCategory|DisplayCategory|NoCategorySet|ItemNaming|FoodNaming|FoodTemperatureNaming|InventoryName|ItemWithDisplayName\w*|ItemName\w*|Packing|Unpacking|PuttingInContainer|TakingFromContainer|MovingToContainer|HotbarAttachment|AttachedItems|DropItemsOnSquareCenter|ConfirmDeleteItems|PrimaryTooltip|SecondaryTooltip|InventoryTooltip|HealthTooltip|CraftingTooltip|MovableTooltip|Tooltip|Liter|Milliliter|UnknownBerry|PoisonousBerry|Berry|UnknownMushroom|PoisonousMushroom|Mushroom|RemainingPercent|ItemList|Item|Name|Option|JobType)(_|$)"),
    ("가구 배치·해체", r"^IGUI_(Moveables?|Movable\w*|Place3DItem|ExtendedPlacement|Pickup|Place|Rotate|Exit|Cycle\d|HoldButton|ToggleMode|PickupItem|PlaceObject|ApplyRotation|CycleMode|CycleObject|CycleItems|CycleRotation|NoMovable|ItemsInContainer|CanRotate|CanNotRotate|Tool|None|ChanceToBreak|ToHeavy|ItemsSurface|WindowOpen|NeedToBeStandingInside|MustPlaceRoomRoof|Scrap|NoCanScrap|NotRepairable|NotThumpable|DamagedObject|WindowBarricaded)(_|$)"),
    ("제작·건축", r"^IGUI_(Craft\w*|Entities|RecipeMonitor|TISConstruction|Build|BuildingMenu\w*|Repair|Designation\w*|Add|Document|BackButton)(_|$)"),
    ("요리·가전·설비", r"^IGUI_(Furnace|Campfire|Fireplace|BBQ|Oven|Microwave|Generator|Washing|Temperature|Timer\w*|SetAlarm|AlarmIsSetFor|CurrentTime|PowerConsumption|IsOperational|RequiresWaterSupply|RainCollectorHasWater|ComposterHasCompost|RemovePropane|Lights|Color|GasPump|deepfry|potatostorage)(_|$)"),
    ("라디오·TV·미디어", r"^IGUI_(ZomboidRadio|Radio\w*|DeviceOptions|media|RadioMedia|VHS|Hotkey)(_|$)"),
    ("차량", r"^IGUI_(Vehicle\w*|Seat\w*|SwitchSeat|EnterSeat|EnterVehicle|ExitVehicle|CloseTrunk|OpenTrunk|LockTrunk|UnlockTrunk|CloseHood|OpenHood|LockHood|UnlockHood|InflateTire|DeflateTire|TakeEngineParts|RepairEngine|WheelFriction|TotalBreakingForce|LockBroken|OverallCondition|EnginePower|HeadlightFocusing\w*|TrailerAttachName|EditVehicle|SpawnVehicle|Mechanics|Install|Uninstall|Success|Failure|Missing|Open|AnimalTrailer|CarKey|HouseKey)(_|$)"),
    ("동물", r"^IGUI_(Animal\w*|Breed|Hutch|PutAnimalInHutch|ButcherHook|FeedingTroughUI|Trough|MigrationGroup|LureAnimal\d?|KillAnimal|LastTimeMilked|Bear)(_|$)"),
    ("채집·낚시·농사", r"^IGUI_(SearchMode|ScavengeUI|Fish|FishingUI|Fishing|Base\.\w+|(Largemouth|Smallmouth|White|Spotted|Striped)Bass|Bluegill|(White|Black)Crappie|(Redear|Green)Sunfish|YellowPerch|Sauger|BaitFish|Paddlefish|AligatorGar|Muskellunge|(Flathead|Channel|Blue)Catfish|FreshwaterDrum|Walleye|Season)(_|$)"),
    ("지도", r"^IGUI_(Map|MapOption|WorldMap|MiniMap|ViewMap|ToggleMinimap|TextBoxMap|Zone|DesignationZone)(_|$)"),
    ("날씨·기후", r"^IGUI_(climate|Climate\w*|ClimDebuggers|Forecaster|WeatherFX|WeatherPlotter|PuddlesControl|WindTick|ThermoDebug|NewFog|Fog|Day|IntensityEvents|DailyValues|Temp|PlayerClimate)(_|$)"),
    ("거래", r"^IGUI_(TradingUI|ISTradingUIHistorical)(_|$)"),
    ("멀티플레이·서버 관리", r"^IGUI_(AdminPanel|Adm|UserList|UsersList|UserPanel|ServerToolBox|FactionUI|SafehouseUI|Safehouse|Safezone|PvpZone|MP|RolesList|RequestID|TicketUI|WarManager|WarClaimingUI|Chatbox|SelectAccount|MultiplayerZoneEditor|PVPLogTool|Commands|CommandConsole|ThreatStatus|GameStats|Gametime)(_|$)"),
    ("디버그·개발 도구", r"^IGUI_(Debug\w*|\w+Debug\w*|CheatPanel|AnimDebugMonitor|DbViewer|UnitTests|AnimClipViewer|LootStressTest|ScriptView|ScriptManager|RemoveItemTool|SpawnHorde|SpawnPointsEditor|StatisticChart|GlobalObject|IsoRegions|ZombiePopulation|WorldFlares|ItemEditor|AttachmentEditor|CraftRecipesDebug|FMODEvent|BulletTracerEffect|ARFRecording|LuaCommandLine|OutputLog|ReloadTranslations|SpawnNumber|Chart|ChunkState|WorldMapEditor|BuildingRoomsEditor|Custom|SoundName|Any|True|False|XUI|anim|SpawnVehicle)(_|$)"),
    ("조작·튜토리얼·게임 화면", r"^IGUI_(Tutorial\w*|Controller|Keyboard|mouse|Key|UI|NewUI|FirearmRadial|LeftStickButtonRadial|RadialMenuKeyToggle|ReloadRadialInstant|ToggleToRun|ToggleToSprint|StartSprint|StopSprint|ToggleAutoProneAtk\w*|SetCursorToPlayerLocation|PressSpaceContinue|GamePaused|ConfirmLeaveGame|ConfirmQuitToDesktop|TextBox|Yes|No|SetCode|EnterCode|Acceptance|CantDoWhileDragging|Total)(_|$)"),
]
# 회사·상점·직업 이름(명함·전단 문구)은 EN 원본에서 한 덩어리라, 그 범위로 판정한다
BUSINESS_RANGE = ("IGUI_aestheticKey", "IGUI_ObjectAlreadyUsedSayMessage")


def classify_ig_ui(game):
    f = rules(IG_UI_RULES)
    en = game.en_order("IG_UI.json")
    lo, hi = en.get(BUSINESS_RANGE[0]), en.get(BUSINESS_RANGE[1])
    biz = len(IG_UI_RULES) - 0.5

    def c(k):
        b = base_key(k)
        i, label = f(b)
        if label == OTHER and lo is not None and hi is not None and b in en and lo <= en[b] <= hi:
            return biz, "회사·상점·직업 이름 (명함·전단)"
        return i, label
    return c


UI_RULES = [
    ("옵션 화면", r"^UI_(optionscreen|OptionScreen|DisplayOptions|ConfirmMonitorSettings|ControllerTest|Controller|PPT)(_|$)"),
    ("캐릭터 생성 (직업·특성)", r"^UI_(trait|prof|profdesc|characreation|StarterCondition|ClothingType|ClothingInsPanel)(_|$)"),
    ("메인 화면·게임 시작·불러오기", r"^UI_(mainscreen|NewGame|LoadGameScreen|GameLoad|soloscreen|worldscreen|WorldSelect|mapspawn|mapselecter|challengeplayer|advWorld|Loading|News|B42|TermsOfService|Policy|EpilepsyWarning|btn)(_|$)"),
    ("모드·창작마당", r"^UI_(mods|modselector|ModsNagPanel|ModsConflicts|WorkshopSubmit|WorkshopError|ServerWorkshopItem\w*|WorkshopServerItemState)(_|$)"),
    ("서버·멀티플레이", r"^UI_(ServerOption|ServerOptionDesc|ServerOptions|ServerSettings|ServerSettingGroup|servers|ConnectToServer|OnConnectFailed|ServerStatus|Multiplayer|coopscreen|loginscreen|InviteFriends|FriendState|Scoreboard|userpanel|ServerConnectPopup|chat)(_|$)"),
    ("로딩 화면 팁", r"^UI_quick_"),
    ("채집·낚시", r"^UI_(foraging|investigate|search|Chum)(_|$)"),
    ("차량", r"^UI_Vehicle(_|$)"),
    ("제작진", r"^UI_credits(_|$)"),
]
CONTEXT_RULES = [
    ("요리·음식", r"(?i)^ContextMenu_(EvolvedRecipe|FoodType|Eat|Cook|Spill|Pour|Drink|Water|Stir|Bake|Fry|Boil|Food|BBQ|Fill|Empty|AddWater|Add_Bottle)"),
    ("동물", r"(?i)^ContextMenu_(Hutch|FeedingTrough|Animal|Milk|Shear|Butcher|Pet|Leash|Egg|Feed|SetPregnancy|AttachAnimal|Grab_Corpse|Corpse)"),
    ("농사·채집·벌목", r"(?i)^ContextMenu_(Plant|Harvest|Aphids|Seed|Farm|Compost|Forag|Fish|Chum|Gardening|Chop|Tree|Remove_Rock|AddDirt|TakeLogs|Dig|Plow|Shovel)"),
    ("차량", r"(?i)^ContextMenu_(Vehicle|CarBattery|Fuel|Gas|Tire|Trailer|Siphon|Insert_Propane)"),
    ("건축·가구", r"(?i)^ContextMenu_(Wooden|Build|Barricade|Unbarricade|Nail|Door|Brick|Stone|Bar|Firetiles|WallCoverings|Table|Double|Place|Pickup|Climb|Wall|Window|Floor|Stairs|Fence|WiredFence|BigMetalFence|Metal|Log|Light|Turn|Sign|Paint|Tent|Take_down|ObjectHealth|RemoveBrokenGlass|Add_escape_rope|Add_sheet_rope|Rope|Disassemble|Dismantle|Repair)"),
    ("의류·장비", r"(?i)^ContextMenu_(Wear|Equip|FannyPack|TrimBeard|Tie|Unequip|Clothing|Hair|CutHair|Beard|Makeup|FireMode|ChangeFireMode|Stow|Hand|RightRing|LeftRing|Ring|Forward|Backward|Down|Up|Hood|Cap|Zip|Untuck|Tuck|Button|Unbutton|Roll|Sleeve|Partchange|WearBoth|Short|Long|Purple|Pink|Blue|Red|Green|Black|White|Yellow|Orange|Brown|Grey|Gray)"),
    ("치료", r"(?i)^ContextMenu_(Medical|Bandage|Apply_Bandage|Disinfect|Splint|Stitch|Wound|Heal|Pill|Bleach)"),
    ("디버그", r"(?i)^ContextMenu_(Debug|Cheat|Admin)"),
]
TOOLTIP_RULES = [
    ("제작·레시피", r"(?i)^Tooltip_(craft|Recipe|CantCraft|NoRecipes|Unwanted)"),
    ("음식", r"(?i)^Tooltip_(food|needsToBeHot|Charcoal|campfire|lightFire)"),
    ("무기", r"(?i)^Tooltip_(weapon|AmmoStrap|head|handle|blunt|dull)"),
    ("읽을거리", r"(?i)^Tooltip_(BookTitle|literature|Journal|HollowBook)"),
    ("차량", r"(?i)^Tooltip_(Dashboard|Vehicle|LugWrench|Wrench|NoTank)"),
    ("동물", r"(?i)^Tooltip_(Animal|FeedingTrough|trough|Hutch|ButcherUI|EggFertilized)"),
    ("낚시", r"(?i)^Tooltip_(fish|Chum|IsFishingLure|NeedChum)"),
    ("지도·나침반", r"(?i)^Tooltip_(Map|compass)"),
    ("의류·가죽", r"(?i)^Tooltip_(clothing|Leather|Webbing|requireHair)"),
    ("아이템", r"(?i)^Tooltip_(item|container|media|BedType|trash)"),
]
MOVEABLE_RULES = [
    ("바닥재·벽재", r"(?i)(floor|tiles?\b|carpet|wallpaper|squares|planks?\b|bricks?\b)"),
    ("식물", r"(?i)(plant|tree|bonsai|evergreen|flower|bush|fern|cactus|palm|ivy|hedge)"),
    ("욕실", r"(?i)(sink|toilet|bath|shower|mirror|urinal)"),
    ("커튼·블라인드", r"(?i)(curtain|blind)"),
    ("가전·기계", r"(?i)(fridge|freezer|oven|stove|microwave|toaster|dishwasher|washer|dryer|\btv\b|television|radio|computer|machine|grill|barbecue|bbq|generator|fan\b|heater|vending|soda|arcade|jukebox|register|printer|copier|speaker|amp)"),
    ("조명", r"(?i)(lamp|light|lantern|chandelier|candle)"),
    ("침대·의자·소파", r"(?i)(bed\b|beds|futon|crib|chair|bench|sofa|couch|stool|seat|armchair|ottoman)"),
    ("탁자·책상", r"(?i)(table|desk|counter|bar\b|workbench)"),
    ("수납", r"(?i)(shel(f|ves)|cabinet|drawer|dresser|wardrobe|locker|crate|chest|bookcase|rack|box|bin\b|safe|cupboard)"),
    ("장식·간판", r"(?i)(painting|poster|sign|picture|frame|statue|trophy|thropy|rug|clock|globe|canopy|spiffo|banner|flag|mannequin|scarecrow|gravestone|tombstone|hide\b|skull|pole|display|stand\b|ecstacy)"),
    ("설비·도구", r"(?i)(incinerator|loom|grinder|scale|dispenser|phone|hood|barrel|anvil|forge|kiln|furnace|wheel|press|easel|road_block|block)"),
]
STASH_TOWNS = {"LV": "루이빌", "Wp": "웨스트 포인트", "WP": "웨스트 포인트", "BBurg": "브랜든버그", "Irvington": "어빙턴",
               "Mul": "멀드로", "Muld": "멀드로", "Muldraugh": "멀드로", "Riv": "리버사이드", "Riverside": "리버사이드", "Rose": "로즈우드",
               "Rosewood": "로즈우드", "MarchRidge": "마치 릿지", "Ekron": "에크론", "EchoCreek": "에코 크릭",
               "FallasLake": "팰러스 레이크", "ValleyStation": "밸리 스테이션", "World": "카운티 전역 지도"}


def classify_simple(table):
    f = rules(table)
    return lambda k: f(base_key(k))


def classify_itemname(game):
    items, _ = game.scripts()
    order = {}

    def c(k):
        cat = items.get(base_key(k))
        if not cat:
            return (1, OTHER)
        return (0, cat_label(game.ko("IGUI_ItemCat_" + cat), cat))
    return c


ENTITY_FOLDERS = {"walls": "벽·문·창", "furniture": "가구", "outdoors": "야외 시설", "stairs": "계단",
                  "fences_low": "낮은 울타리", "barricades": "바리케이드", "misc": "기타", "admin": "관리자",
                  "agricultural": "농업", "animals": "동물", "appliances": "가전", "blacksmith": "대장간", "pottery": "도기"}


def craft_label(game, cat):
    if cat.startswith("entity:"):        # B42 건축/작업대 (scripts/entities/<폴더>)
        sub = cat[len("entity:"):].split("/")
        if "workstations" in sub:
            return "작업대 (%s)" % ENTITY_FOLDERS.get(sub[0], sub[0])
        return "건축 (%s)" % ENTITY_FOLDERS.get(sub[0], sub[0])
    return cat_label(game.ko("IGUI_CraftingCategories_" + cat) or game.ko("IGUI_CraftCategory_" + cat), cat)


def classify_recipes(game):
    _, recipes = game.scripts()
    norm = lambda x: re.sub(r"[^a-z0-9]", "", x.lower())
    by_norm = {}
    for name, cat in recipes.items():
        by_norm.setdefault(norm(name), cat)

    def c(k):
        b = base_key(k)
        b = b[len("Recipe_"):] if b.startswith("Recipe_") else b
        if re.match(r"(?i)^(base:)?.* growing season$", b):
            return (0, "농사 (재배 시기)")
        cat = recipes.get(b) or by_norm.get(norm(b))
        if not cat:
            return (1, "이전 버전 레시피 (B41 등)")
        return (0, craft_label(game, cat))
    return c


def classify_sandbox(game):
    pages = game.sandbox_pages()
    by_key = {}
    for opt, (n, page) in pages.items():
        tail = opt.split(".")[-1]
        for k in (opt, tail, "Z" + tail, opt.replace(".", "")):
            by_key.setdefault("Sandbox_" + k, (n, page))

    # 페이지 표에 없는 키는 EN 원본 순서에서 바로 앞 키의 페이지를 이어받는다
    strip = lambda k: re.sub(r"(_tooltip|_option\d+|_help)$", "", k)
    en = game.en_order("Sandbox.json")
    carry, last = {}, None
    for k in sorted(en, key=en.get):
        hit = by_key.get(strip(k))
        if hit:
            last = hit
        if last:
            carry[k] = hit or last

    def c(k):
        b = base_key(k)
        hit = by_key.get(strip(b)) or carry.get(b)
        if not hit:
            return (10 ** 6, OTHER)
        n, page = hit
        return (n, cat_label(game.ko("Sandbox_" + page), page))
    return c


def classify_moodles(game):
    def c(k):
        m = re.match(r"^Moodles_([A-Za-z]+?)_(?:lvl|desc|Bad|Good)", base_key(k))
        if not m:
            return (1, OTHER)
        t = m.group(1)
        ko = game.ko("Moodles_%s_lvl1" % t)
        return (0, "%s - %s" % (t, ko) if ko else t)
    return c


def classify_recorded(game):
    rm = game.recorded_media()
    names = {"CDs": "CD", "Home-VHS": "홈 비디오 (VHS)", "Retail-VHS": "시판 VHS"}

    def c(k):
        cat = rm.get(base_key(k))
        return (list(names).index(cat) if cat in names else 9, names.get(cat, cat or OTHER))
    return c


def classify_radio(game):
    rd = game.radio()
    chans = list(dict.fromkeys(ch for ch in rd.values() if ch))     # RadioData.xml 순서

    def c(k):
        ch = rd.get(base_key(k))
        if not ch:
            return (10 ** 6, OTHER)
        return (chans.index(ch), ch)
    return c


def classify_names(game):
    return lambda k: (0, "이름") if base_key(k).startswith("SurvivorName_") else \
        (1, "성") if base_key(k).startswith("SurvivorSurname_") else (2, OTHER)


def classify_stash(game):
    def c(k):
        m = re.match(r"^Stash_([A-Za-z]+)", base_key(k))
        town = re.sub(r"(Stash|Map)$", "", re.sub(r"(Stash|Map)$", "", m.group(1))) if m else None
        if not town:
            return (10 ** 6, OTHER)
        for t in sorted(STASH_TOWNS, key=len, reverse=True):
            if town.startswith(t):
                return (0, STASH_TOWNS[t])
        return (0, town)
    return c


def classify_prefix_groups(groups):
    """groups: [(label, prefix tuple)]"""
    def c(k):
        b = base_key(k)
        for i, (label, prefixes) in enumerate(groups):
            if b.startswith(prefixes):
                return (i, label)
        return (len(groups), OTHER)
    return c


def classify_print(game, fn):
    tok = lambda k: (re.match(r"^Print_(?:Media|Text)_([A-Za-z]+)", base_key(k)) or [None, None])[1]
    count = collections.Counter(tok(k) for k in load_json_loose(os.path.join(VAN_KO, fn)))

    def c(k):
        t = tok(k)
        if t and count[t] >= 10:
            return (0, t)
        return (1, "전단·기타 인쇄물")
    return c


def classify_guide(game):
    # B42 가이드: "<분류>_category_image" 키가 분류의 시작. EN 원본 순서에서 뒤따르는 주제는 그 분류에 속한다
    en = game.en_order("SurvivalGuide.json")
    cats, cur, n = {}, None, 0
    for k in sorted(en, key=en.get):
        m = re.match(r"^SurvivalGuide_(\w+?)_category_image$", k)
        if m:
            cur, n = m.group(1), n + 1
        if cur and not k.startswith("SurvivalGuide_entrie"):
            cats[k] = (n, cur)

    def c(k):
        b = base_key(k)
        if b.startswith("SurvivalGuide_entrie") or b == "SurvivalGuide_WindowTitle":
            return (10 ** 5, "이전 가이드 (B41)")
        hit = cats.get(b)
        if not hit:
            return (10 ** 6, OTHER)
        n, cat = hit
        return (n, cat_label(game.ko("SurvivalGuide_%s_title" % cat), cat))
    return c


VANILLA = {
    "IG_UI.json": classify_ig_ui,
    "UI.json": lambda g: classify_simple(UI_RULES),
    "ContextMenu.json": lambda g: classify_simple(CONTEXT_RULES),
    "Tooltip.json": lambda g: classify_simple(TOOLTIP_RULES),
    "Moveables.json": lambda g: classify_simple(MOVEABLE_RULES),
    "ItemName.json": classify_itemname,
    "Recipes.json": classify_recipes,
    "Sandbox.json": classify_sandbox,
    "Moodles.json": classify_moodles,
    "Recorded_Media.json": classify_recorded,
    "RadioData.json": classify_radio,
    "SurvivorNames.json": classify_names,
    "Stash.json": classify_stash,
    "Print_Media.json": lambda g: classify_print(g, "Print_Media.json"),
    "Print_Text.json": lambda g: classify_print(g, "Print_Text.json"),
    "SurvivalGuide.json": classify_guide,
    "GameSound.json": lambda g: classify_prefix_groups([
        ("소리 분류", ("GameSound_Category",)),
        ("음악", ("GameSound_NewMusic", "GameSound_OldMusic", "GameSound_AmbientMusic")),
        ("효과음·기타", ("GameSound_",))]),
    "Fluids.json": lambda g: classify_prefix_groups([
        ("액체 이름", ("Fluid_Name_",)), ("용기 이름", ("Fluid_Container_",)), ("속성·안내", ("Fluid_",))]),
    "Farming.json": lambda g: classify_prefix_groups([
        ("툴팁·상태", ("Farming_Tooltip", "Farming_Ready", "Farming_Compost")), ("월", ("Farming_Month",)),
        ("작물", ("Farming_",))]),
}


def organize_vanilla(args, write, report):
    game = Game(args.game)
    if not os.path.isdir(game.media):
        raise SystemExit("게임 폴더 없음: %s (--game 으로 지정)" % args.game)
    for path in sorted(glob.glob(os.path.join(VAN_KO, "*.json"))):
        fn = os.path.basename(path)
        entries, data = read_file(path)
        dropped = {e["key"] for e in entries if NOTE_RE.match(e["key"])}
        keep = [e for e in entries if e["key"] not in dropped]
        maker = VANILLA.get(fn)
        if not maker or len(keep) < SMALL_FILE:
            # 분류 대상이 아님 (키가 적은 파일은 메모 키가 곧 구분이라 손대지 않는다)
            report.append("  %-24s 키 %6d  (그대로)" % (fn, len(entries)))
            continue
        classify = maker(game)
        en = game.en_order(fn)
        groups = collections.defaultdict(list)
        rank = {}
        for e in keep:
            r, label = classify(e["key"])
            groups[label].append(e)
            rank[label] = min(rank.get(label, r), r)
        if OTHER in rank:
            rank[OTHER] = 10 ** 9
        out = []
        for label in sorted(groups, key=lambda l: (rank[l], l)):
            items = sorted(groups[label], key=lambda e: (en.get(base_key(e["key"]), 10 ** 9), e["pos"]))
            out.append((label, items))
        apply(path, out, data, dropped, write, report)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--write", action="store_true", help="파일에 반영 (없으면 미리보기)")
    ap.add_argument("--only", choices=["pack", "vanilla"], help="한쪽만 정리")
    ap.add_argument("--game", default=DEF_GAME, help="Project Zomboid 설치 폴더")
    ap.add_argument("--workshop", default=DEF_WS, help="창작마당 108600 폴더")
    args = ap.parse_args()
    report = []
    if args.only in (None, "pack"):
        report.append("[02 통합 번역]")
        organize_pack(args, args.write, report)
    if args.only in (None, "vanilla"):
        report.append("[01 바닐라]")
        organize_vanilla(args, args.write, report)
    print("\n".join(report))
    print("(* = 바뀜%s)" % ("" if args.write else ", --write 를 붙이면 반영"))


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()

# 번역 파일 구조와 관리 방법

번역 json이 어떻게 정리되어 있는지, 번역을 고치거나 추가할 때 어디에 넣어야 하는지, 그리고 게임 안에서 json 밖의 문구를 번역하는 Lua 모듈이 어떻게 동작하는지 정리한 문서입니다. 기본 형식 규칙(접두어, `%%`, 중복 키 금지 등)은 [README의 번역 규칙](README.md#번역-규칙)을 따릅니다.

## 1. json 파일 읽는 법

모든 번역 json은 **머리글 키**로 구역이 나뉘어 있습니다.

```json
{
    "========== Radio Traders [3807707103] ==========": "",
    "UI_RadioTraders_AmmoTradeDone": "%1 %2을(를) %3 %4(으)로 교환했습니다.",
    "UI_RadioTraders_AmmoTradeLowValue": "가진 것으로는 그 교환을 하기에 가치가 부족합니다.",

    "========== Railroader [3774360904] ==========": "",
    ...
}
```

- 머리글 키는 `"========== 구역 이름 ==========": ""` 형식이고 값은 항상 빈 문자열입니다. 게임은 이 키를 쓰지 않으므로 번역에 영향이 없습니다.
- 구역 사이에는 빈 줄이 하나 있습니다.
- 머리글은 정리 도구가 만들고 지우므로 손으로 고칠 필요가 없습니다. 고쳐도 다음 정리 때 다시 만들어집니다.

### 02 통합 번역 (`02___ModKoreanTranslation`): 모드별

| 구역 | 내용 |
|---|---|
| `모드 제목 [창작마당 ID]` | 그 모드가 쓰는 키. 모드 제목 순(앞의 `[B42]` 같은 꼬리표는 무시)으로 정렬하고, 구역 안에서는 모드 원본 번역 파일의 키 순서를 따릅니다. 제목은 [MODS.md](MODS.md)의 이름을 쓰고, 목록에 없는 모드는 `mod.info`의 이름을 씁니다. |
| `출처 미확인 (현재 설치되지 않은 모드)` | 지금 설치된 모드 어디에도 없는 키. 예전에 번역했지만 구독을 끊은 모드, 키 이름이 바뀐 이전 버전 등입니다. 원래 순서를 그대로 두어 같은 모드의 키가 붙어 있습니다. 파일마다 맨 끝에 있습니다. |

창작마당 ID로 모드 페이지를 바로 찾을 수 있습니다: `https://steamcommunity.com/sharedfiles/filedetails/?id=<ID>`

### 01 바닐라 (`01___Vanilla`): 분류별

파일마다 게임 데이터에서 가장 알맞은 기준을 골라 묶었습니다. 구역 안에서는 게임 EN 원본의 키 순서를 따릅니다.

| 파일 | 묶는 기준 | 예시 구역 |
|---|---|---|
| `ItemName.json` | 아이템의 표시 분류(`DisplayCategory`, 게임 스크립트) | `음식 (Food)`, `의복 (Clothing)`, `무기 (Weapon)` |
| `Recipes.json` | 제작 분류(`craftRecipe`의 `category`), 건축·작업대(`scripts/entities/<폴더>`) | `요리 관련 (Cooking)`, `건축 (가구)`, `작업대 (대장간)`, `농사 (재배 시기)` |
| `Sandbox.json` | 샌드박스 설정 화면의 페이지 | `시간 설정 (TimeOptions)`, `좀비 설정 (Zombie)` |
| `IG_UI.json` | 화면·기능 | `책·잡지·만화·신문 제목`, `차량`, `동물`, `디버그·개발 도구` 등 26개 |
| `UI.json` | 화면 | `옵션 화면`, `캐릭터 생성 (직업·특성)`, `서버·멀티플레이`, `로딩 화면 팁` |
| `ContextMenu.json`, `Tooltip.json` | 기능 | `요리·음식`, `건축·가구`, `차량`, `무기` |
| `Moodles.json` | 무들 종류 | `Endurance - 약간 지침` |
| `RadioData.json` | 라디오·TV 채널 (`media/radio/RadioData.xml`) | `LBMW - Kentucky Radio`, `WBLN News` |
| `Recorded_Media.json` | 매체 (`recorded_media.lua`) | `CD`, `시판 VHS`, `홈 비디오 (VHS)` |
| `SurvivalGuide.json` | 생존 가이드 분류 | `전투 (combat)`, `농사 (farming)` |
| `Moveables.json` | 사물 종류 | `욕실`, `조명`, `수납`, `장식·간판` |
| `Stash.json` | 지역 | `루이빌`, `멀드로`, `웨스트 포인트` |
| `SurvivorNames.json` | 이름 / 성 | |
| `Print_Media.json`, `Print_Text.json` | 신문 이름 (나머지는 전단) | `KnoxKnews`, `전단·기타 인쇄물` |
| `GameSound.json`, `Fluids.json`, `Farming.json` | 키 종류 | `음악`, `액체 이름`, `작물` |

- 기준에 맞지 않는 키는 각 파일 맨 끝의 `기타` 구역에 있습니다.
- `"--UI_prof_parkranger"`처럼 `--`로 시작하는 키는 번역자가 꺼 둔 예전 번역입니다. 원래 키와 같은 구역에 남겨 두었습니다.
- 키가 60개보다 적은 파일(지도 이름, 제작진 등)은 원래 모양 그대로 둡니다.
- 예전의 버전 표시 키(`"/** 42.19 **/"`, `"//comment_1"` 등)는 머리글로 대체했습니다. 어떤 버전에서 키가 추가되었는지는 git 기록으로 확인할 수 있습니다.

## 2. 번역 추가·수정하기

1. 해당 파일에서 모드 머리글(또는 바닐라 분류 머리글)을 찾아 그 구역에 키를 넣거나 고칩니다. 위치가 애매하면 아무 데나(예: 파일 끝) 넣어도 됩니다.
2. 저장소 루트에서 정리 도구를 실행합니다.

```bash
python tools/organize_ko_json.py --write
```

새 키는 설치된 모드의 번역 파일과 대조해 알맞은 모드 구역으로 옮겨집니다. 어느 모드 것인지 알 수 없으면 `출처 미확인` 구역으로 갑니다.

## 3. 정리 도구 (`tools/organize_ko_json.py`)

| 옵션 | 설명 |
|---|---|
| (없음) | 바뀔 파일과 구역 수만 보여 줍니다. 파일은 그대로입니다. |
| `--write` | 파일에 반영합니다. |
| `--only pack` / `--only vanilla` | 02 통합 번역 또는 01 바닐라만 정리합니다. |
| `--game <경로>` | Project Zomboid 설치 폴더 (기본: `C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid`) |
| `--workshop <경로>` | 창작마당 폴더 (기본: `...\steamapps\workshop\content\108600`) |

- 값은 바꾸지 않고 순서와 머리글만 바꿉니다. 쓰기 전에 키·값이 원본과 똑같은지 검사하고, 다르면 쓰지 않습니다.
- 몇 번을 실행해도 결과가 같습니다. 이미 모드 머리글 아래 있는 키는 다른 모드로 옮기지 않습니다. 다만 다른 언어 번역만 든 번역 팩 머리글 아래 있던 키는 실제 모드로 옮깁니다.
- 02는 창작마당 모드의 번역 파일(EN 우선)과 아래 4장의 Lua 데이터 파일을 보고 키의 주인을 정합니다. 01은 게임 설치 폴더의 스크립트, 라디오 데이터, 설정 화면 Lua를 읽습니다.
- 파이썬 3.8 이상이면 추가 패키지 없이 돌아갑니다.

## 4. json 밖의 문구를 번역하는 Lua 모듈

모드 중에는 번역 키를 쓰지 않고 영어 문장을 Lua 코드에 직접 적은 것이 많습니다. 통합 번역(`02___ModKoreanTranslation/42/media/lua/client/`)에는 이런 문구를 게임 안에서 바꿔 주는 모듈이 있습니다. 모두 **게임 언어가 한국어이고, 해당 모드가 켜져 있을 때만** 동작하며, 모드 파일 자체는 고치지 않습니다.

| 모듈 | 대상 | 번역문 위치 |
|---|---|---|
| `HxKO_ModOptions.lua` + `_Data.lua` | 모드 옵션 화면(`PZAPI.ModOptions`)의 제목, 설명, 선택지, 툴팁 | `UI.json`의 `UI_HxMO_<옵션 ID>_*` 키 |
| `HxKO_Hardcoded.lua` + `_Data.lua` | 모드가 Lua 표에 넣어 둔 문구 (예: Guns of Marz 무기 툴팁) | `Tooltip.json`의 `Tooltip_HxHC_<범위>_*` 키 |
| `HxKO_UIText.lua` + `_Data.lua` | 컨텍스트 메뉴, 버튼, 라벨, 툴팁, 대화 상자, 원형 메뉴, 화면 글자, 캐릭터 말풍선(`Say`), 머리 위 알림(`HaloTextHelper`) 등에 바로 넘긴 영어 문구 | `Tooltip.json`의 `Tooltip_HxUI_<id>` 키 |
| `HxKO_ItIsOfInterestToMe.lua` | It Is Of Interest To Me 모드의 편지·쪽지 본문 | `media/lua/shared/HxKO_Content/ItIsOfInterestToMe/` 의 txt 파일 493개 |

`HxKO_UIText`가 문구를 찾는 순서:

1. **문장 전체** — 표시하려는 문구가 원문과 같으면(앞뒤 공백 무시) 번역문으로 바꿉니다.
2. **자리표시자 문장** — 모드가 값을 채워 넣는 문장(`"I'm from %CITY."`, `"Ingredient adds: %+d Hunger"`)은 패턴으로 맞추고 값만 끼워 넣습니다.
3. **줄 단위** — 여러 줄 안내문은 줄마다 맞춥니다.
4. **문장 조각** — `"Drop " .. 아이템 이름`처럼 이어 붙인 문장의 영어 조각을 단어 경계에 맞춰 바꿉니다. 한 단어짜리 조각은 문장 맨 앞에 있고 뒤에 영어 문장이 이어지지 않을 때만 바꿉니다.

컨텍스트 메뉴는 **화면에 그릴 때만** 번역하므로, 모드가 메뉴 항목을 영어 이름으로 찾는 코드(`getOptionFromName` 등)는 그대로 동작합니다. 채팅창 내용은 바꾸지 않습니다.

`_Data.lua` 파일은 원문과 번역 키의 대응표로, 직접 고치지 않습니다. 번역문을 고칠 때는 json의 해당 키 값만 바꾸면 됩니다.

## 5. 키 접두어 요약

| 접두어 | 파일 | 용도 |
|---|---|---|
| `UI_HxMO_*` | `UI.json` | 모드 옵션 화면 문구 (`HxKO_ModOptions`) |
| `Tooltip_HxHC_*` | `Tooltip.json` | Lua 표에 든 하드코딩 문구 (`HxKO_Hardcoded`) |
| `Tooltip_HxUI_*` | `Tooltip.json` | 표시 함수에 바로 넘긴 하드코딩 문구 (`HxKO_UIText`) |
| `========== … ==========` | 모든 json | 구역 머리글 (값은 빈 문자열) |

이 키들도 모드 머리글 아래에 정리되어 있으므로, 모드 구역을 보면 그 모드의 json 번역과 하드코딩 번역을 함께 확인할 수 있습니다.

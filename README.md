# Hx's 좀보이드 통합 번역

![Hx's 좀보이드 통합 번역](preview.png)

Project Zomboid **Build 42**의 바닐라와 창작마당 모드를 한국어로 번역하는 모드 모음입니다.

- 스팀 창작마당: [Hx's 좀보이드 통합 번역](https://steamcommunity.com/sharedfiles/filedetails/?id=3040632900)
- 번역된 모드 목록 (검색·필터): https://hx529.github.io/PZ_KoreanLocalization/
- 번역된 모드 목록 (문서): [MODS.md](MODS.md)
- 번역 현황 공유: [Google Sheets](https://docs.google.com/spreadsheets/d/1mvICZ2zet0rIlq-07fFTJWmXbkvNSl0WoWujl3-ULkA/edit?usp=sharing)

## 적용법

1. 창작마당 항목을 구독합니다.
2. 게임의 모드 설정에서 필요한 번역 모드를 켭니다.
3. 모드 우선순서에서 번역 모드를 **가장 아래**에 둡니다. 같은 번역 키는 나중에 불러온 쪽이 적용됩니다.

통합 번역은 바닐라 번역 키를 덮어쓰지 않습니다. 목록의 모드를 쓰지 않아도 바닐라 문구가 바뀌지 않으므로 어떤 모드 조합에서도 켜 두면 됩니다.
무들·특성 설명, 로딩 화면 팁, 바닐라 아이템 이름처럼 **바닐라 문구 자체를 바꾸는 모드**를 쓸 때만 `(선택형) 바닐라 문구 변경 모드용`을 통합 번역보다 아래에 함께 켜 주세요.

## 구성

| 폴더 | 모드 이름 | 내용 |
|---|---|---|
| `01___Vanilla` | [Hx] 바닐라 한글화 | 바닐라 게임 번역, 한국어 거리 이름·지도 주석 |
| `02___ModKoreanTranslation` | [Hx] 모드 한글화 - 통합 번역 | 창작마당 모드 번역 모음. 모드 옵션 화면 문구, 일부 모드의 편지·쪽지 본문 포함 |
| `03___MapTranslation` | [Hx] 모드 한글화 - 맵 선택 번역 | 맵 모드의 지역 이름과 설명 |
| `Translation___Vanilla Override` | [Hx] 모드 한글화 - (선택형) 바닐라 문구 변경 모드용 | 바닐라 문구를 바꾸는 모드에 맞춘 번역 |
| `Translation___*` | [Hx] 모드 한글화 - 모드 이름 | 바닐라 아이템을 덮어쓰는 총기 모드 등, 원하는 사람만 켜도록 분리한 번역 |
| `B41___*` | (B41 전용) 각 모드의 B41 버전 | B41에서만 보이는 예전 `*_KO.txt` 번역. 더 이상 갱신하지 않음 |

분리 모드 가운데 일부는 원본 모드가 있어야 켜집니다(`mod.info`의 `require=`). `Translation___Harder Hotwire`는 창작마당 설명을 먼저 확인해 주세요.

B41 버전은 `B41___*` 폴더에 따로 모아 두었습니다. 모드 ID는 예전과 같아서 B41 사용자는 그대로 쓸 수 있고, B41 폴더의 `42/mod.info`는 폴더 구조 오류를 막기 위한 더미입니다(`require=\NOT`, ID 끝에 `_B41`). B42에서는 `[Hx/B41] … - 더미데이터`로 보이지만 켤 수 없습니다. `common/`도 같은 이유로 빈 폴더(`.gitkeep`)로 둡니다. 반대로 B42 폴더에는 루트 `mod.info`가 없어 B41에 보이지 않습니다. 통합 번역·맵 번역·Dynamic Traits·Firearms·Harder Hotwire·Rain은 B41과 B42가 같은 모드 ID를 쓰고, 나머지는 B41과 B42가 서로 다른 모드입니다.

| B41 폴더 | B41 모드 | 원래 함께 있던 B42 폴더 |
|---|---|---|
| `B41___ModKoreanTranslation` | 통합 번역 | `02___ModKoreanTranslation` |
| `B41___MapTranslation` | 맵 선택 번역 | `03___MapTranslation` |
| `B41___HephasOccupations` | Hephas Occupations & Traits With Vanilla Professions | `Translation___SOTO` |
| `B41___MoreTraitsDynamic` | More Traits Dynamic | `Translation___ImprovedProjectile` |
| `B41___NestedContainers` | Nested Containers | `Translation___KnoxEventExpanded` |
| `B41___OccupationsExpertisesBalance` | Occupations Expertises & Balance | `Translation___EscapeFromKentucky42` |
| `B41___ReadAllBooks` | Read All Magazines and Books | `Translation___DayTrading` |
| `B41___DynamicTraits` | Dynamic Traits | `Translation___Dynamic Traits` |
| `B41___Firearms` | Firearms | `Translation___Firearmas` |
| `B41___HarderHotwire` | Harder Hotwire | `Translation___Harder Hotwire` |
| `B41___RainFirearms` | Rain's Firearms & Gun Parts | `Translation___Rain` |
| `B41___ClearDescriptionForMoodles` | Clear Description for Moodles | `Translation___Traits` |

## 폴더 구조

```
Contents/mods/<모드 폴더>/
├─ common/                     공통 파일
└─ 42/
   ├─ mod.info
   └─ media/lua/
      ├─ shared/Translate/KO/  번역 json (UI.json, IG_UI.json, ItemName.json …)
      └─ client/               json 밖의 문구를 번역하는 Lua (모드 옵션 화면, 하드코딩 문구 등)
tools/organize_ko_json.py      번역 json 정리 도구
```

B42는 `common`과 가장 높은 `42.x` 폴더를 읽습니다. B41은 모드 폴더 루트의 `mod.info`와 `media/`를 읽으며, 이 파일들은 `B41___*` 폴더에만 있습니다.

번역 json은 구역별로 정리되어 있습니다. 통합 번역은 **모드별**(`"========== 모드 제목 [창작마당 ID] ==========": ""` 머리글 아래에 그 모드의 키), 바닐라는 **분류별**(아이템 분류, 제작 분류, 샌드박스 페이지, 라디오 채널 등)입니다. 파일 읽는 법, 번역 추가 절차, 정리 도구, 하드코딩 문구를 번역하는 Lua 모듈은 [STRUCTURE.md](STRUCTURE.md)에 정리되어 있습니다.

## 번역 규칙

번역을 고치거나 추가할 때 지켜야 하는 형식입니다. 어기면 문구가 깨지거나 게임이 강제 종료될 수 있습니다.

- **파일 형식:** UTF-8(BOM 없음) json만 씁니다. 예전 `*_KO.txt`는 쓰지 않습니다.
- **키 이름:** B42에서는 `ItemName_`, `Recipe_`, `EvolvedRecipeName_` 접두어를 붙이지 않습니다. 예: `"Base.Pistol"`, `"MakeBuildingPlan"`. `RecipeGroup_`, `MultiStageBuild_`는 바닐라처럼 접두어를 유지합니다.
- **`%` 기호:** 모든 문구가 서식 처리를 거치므로 글자 `%`는 `%%`로 씁니다. `%1`, `%2` 같은 자리 표시자는 그대로 둡니다.
- **중복 키 금지:** 한 파일 안에 같은 키가 두 번 있으면 게임이 강제 종료됩니다.
- **레시피 이름:** 모드 레시피는 앞에 `[모드 태그]`를 붙입니다. 예: `[BP] 건축 계획서 만들기`
- **샌드박스 페이지 제목:** `[머리글자] 영어 모드 이름` 형식입니다. 예: `[A] Functional Escalators`
- **키 위치:** 새 키는 해당 모드(또는 분류) 머리글 아래에 넣고, 커밋 전에 `python tools/organize_ko_json.py --write`로 정리합니다. 머리글 키(`========== … ==========`)는 도구가 관리하므로 손대지 않습니다.

## 오류 제보

번역이 빠졌거나 영어 키(`Sandbox_…`, `IGUI_…`)가 그대로 보이면, 모드 이름과 보이는 문구를 창작마당 댓글이나 이 저장소의 Issues에 남겨 주세요.

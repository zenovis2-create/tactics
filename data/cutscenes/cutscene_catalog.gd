class_name CutsceneCatalog
extends RefCounted

## 컷씬 카탈로그 — 코드 기반으로 CutsceneData를 빌드
## (외부 .tres 없이 headless 환경에서도 참조 가능)

const CutsceneData = preload("res://scripts/cutscene/cutscene_data.gd")

## CH01 전투 시작 컷씬 (인트로 텍스트)
static func build_ch01_start() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_start"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": "재의 들판. 살아남은 자들이 북쪽으로 이동한다.",
            "duration": 2.5
        },
        {
            "type": "text_card",
            "text": "Rian: 기억이 없다. 하지만 손은 기억하고 있다.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Serin: 이름을 모르면 우리를 따라와. 여기서 죽으면 이름도 없이 끝난다.",
            "duration": 3.5
        }
    ]
    return d

## CH01 전투 클리어 컷씬 (dawn oath 이후)
static func build_ch01_clear() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_clear"
    d.skippable = true
    d.beats = [
        {
            "type": "text_card",
            "text": "Serin: 새벽 맹세가 끝났다. 이제 북쪽으로.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Rian: 이름도 없이 이 자리에 서 있다. 그래도 이 사람들은 살아남았다.",
            "duration": 3.5
        }
    ]
    return d

## CH01 기억 조각 획득 연출
static func build_ch01_fragment_flash() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_fragment_flash"
    d.skippable = false  # 기억 조각 연출은 스킵 불가
    d.beats = [
        {
            "type": "black_screen",
            "text": "",
            "duration": 0.5
        },
        {
            "type": "fragment_flash",
            "fragment_id": "mem_frag_ch01_first_order",
            "text": "기억 조각 복원됨: 첫 번째 명령",
            "duration": 2.0
        },
        {
            "type": "command_unlock",
            "command_id": "tactical_shift",
            "text": "커맨드 해금: 전술 이동",
            "duration": 2.0
        }
    ]
    return d

## CH01_05 전투 시작 컷씬
static func build_ch01_05_intro() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_05_intro"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": "Dawn Oath.",
            "duration": 1.5
        },
        {
            "type": "text_card",
            "text": "Serin: Your memory is tied to the Empire, which means they will come looking for you soon.",
            "duration": 3.5
        },
        {
            "type": "text_card",
            "text": "Rian: Then I find the truth first.",
            "duration": 2.5
        }
    ]
    return d

## CH01_05 전투 종료 컷씬
static func build_ch01_05_outro() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_05_outro"
    d.skippable = true
    d.beats = [
        {
            "type": "text_card",
            "text": "Serin: Good. From here on, I am your ally.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Rian: We move north together and keep the survivors behind us safe.",
            "duration": 3.5
        }
    ]
    return d

static func build_ch06_05_intro() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch06_05_intro"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": "Valgar's Inner Sanctum",
            "duration": 1.5
        },
        {
            "type": "text_card",
            "text": "The sanctum doors part, and the rite chamber beyond them is all iron, incense, and judgment.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Valgar: You crossed every threshold for a name that should have stayed buried.",
            "duration": 3.1
        },
        {
            "type": "text_card",
            "text": "Rian: Then I break the sanctum with the truth still alive inside it.",
            "duration": 3.0
        }
    ]
    return d

static func build_ch06_05_outro() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch06_05_outro"
    d.skippable = true
    d.beats = [
        {
            "type": "text_card",
            "text": "Valgar falls, and the sanctum's iron chants finally lose the voices holding them upright.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Serin: Take the edicts and move. If the rite has a heart, it just stopped beating.",
            "duration": 3.0
        }
    ]
    return d

static func _build_ch07_cutscene(cutscene_id: StringName, title: String, lines: Array[String]) -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = cutscene_id
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": title,
            "duration": 1.5
        }
    ]
    for line in lines:
        d.beats.append({
            "type": "text_card",
            "text": line,
            "duration": 3.0
        })
    return d

static func build_ch07_01_intro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_01_intro", "Blank Market", [
        "The market ward is already lined with watchers, and the route board is the only clear opening.",
        "Serin: Take the board first. Once the lane opens, the patrols lose their handhold.",
        "Rian: Then we move before the square can reset."
    ])

static func build_ch07_01_outro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_01_outro", "Blank Market", [
        "The market route is secured, and the route now bends cleanly into the silence square.",
        "The market proves people are walking into forgetting on purpose, not only by force.",
        "Mira and Neri reappear as the first faces that make the doctrine feel real."
    ])

static func build_ch07_02_intro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_02_intro", "Silent Square", [
        "The silence square is still holding the line together, even after the market route was cut open.",
        "Bran: If they keep the release posts standing, the whole district falls back into step."
    ])

static func build_ch07_02_outro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_02_outro", "Silent Square", [
        "The square breaks open, but Mira and Neri are still moving with the nameless procession.",
        "One square control is secured, and the procession line is broken."
    ])

static func build_ch07_03_intro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_03_intro", "Nameless Procession", [
        "The procession keeps moving, and Mira and Neri are close enough to disappear into the line.",
        "Serin: Pull them out now. The lane is narrower than it looks."
    ])

static func build_ch07_03_outro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_03_outro", "Nameless Procession", [
        "The procession records confirm the road toward the cathedral and the source of the hymn.",
        "Both procession clues are secured, and the cathedral route is confirmed."
    ])

static func build_ch07_04_intro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_04_intro", "Saint's Sermon", [
        "The sermon pulleys keep the hymn moving through the cathedral quarter.",
        "Rian: Cut both channels before the hall seals behind them."
    ])

static func build_ch07_04_outro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_04_outro", "Saint's Sermon", [
        "The last route into Saria's prayer hall is exposed.",
        "The hymn channels break, and the route into the prayer hall is open."
    ])

static func build_ch07_05_intro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_05_intro", "Prayer of Ellyor", [
        "Saria's prayer hall is sealed, and the last checkpoint still answers to the rite.",
        "Serin: Break it here. Once the doors give, we take the next route by force."
    ])

static func build_ch07_05_outro() -> CutsceneData:
    return _build_ch07_cutscene(&"ch07_05_outro", "Prayer of Ellyor", [
        "Ellyor handoff logged: Saria falls, Saria Mercy Staff and Namebound Thread are secured, sigil tuning later unlocks, and the black-hound route is secured.",
        "Black-hound orders and hidden-ruin coordinates secured.",
        "The next route points toward Lete and the forest ruins."
    ])

static func _build_ch08_cutscene(cutscene_id: StringName, title: String, lines: Array[String]) -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = cutscene_id
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": title,
            "duration": 1.5
        }
    ]
    for line in lines:
        d.beats.append({
            "type": "text_card",
            "text": line,
            "duration": 3.0
        })
    return d

static func build_ch08_01_intro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_01_intro", "Vanished Trail", [
        "Following the black-hound orders and ruin coordinates, the squad steps back onto the forest pursuit line.",
        "This is no longer a road through Greenwood. It is a hunting grid built to cut people out of the map."
    ])

static func build_ch08_01_outro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_01_outro", "Vanished Trail", [
        "The first pursuit markers are active. Someone turned the forest's own sense into black-hound doctrine.",
        "The narrowed lane bends toward a moonlit ambush line."
    ])

static func build_ch08_02_intro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_02_intro", "Moonlit Ambush", [
        "The trail splits the squad and marks whoever drifts alone.",
        "Tia recognizes the pattern at once: stolen forest sense rewritten as a method of pursuit."
    ])

static func build_ch08_02_outro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_02_outro", "Moonlit Ambush", [
        "The moon-scent post and relay cache chart the kill lane before it can close.",
        "The next descent leads beneath the forest into the lower ruin holding route."
    ])

static func build_ch08_03_intro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_03_intro", "Ruin Vent", [
        "The lower ruin vents carry ash and human breath, not shelter.",
        "Through narrow cells and watch gaps, every rescue has to fight the route meant to erase it."
    ])

static func build_ch08_03_outro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_03_outro", "Ruin Vent", [
        "The vents open, the holding gate breaks, and the lower-cell records finally speak.",
        "Bracelet shards and broken arrowheads make Tia's loss specific enough to follow."
    ])

static func build_ch08_04_intro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_04_intro", "Black Mark", [
        "The control brands and ledger edits show the same hunt layered over itself.",
        "Rian's authorization line and the later red revisions do not belong to the same intent."
    ])

static func build_ch08_04_outro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_04_outro", "Black Mark", [
        "Tia faces the transfer ledger tied to her sister and refuses the relief of forgetting.",
        "Lete's hunt can only be stopped by carrying the proof forward."
    ])

static func build_ch08_05_intro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_05_intro", "Night of the Hounds", [
        "Special orders, checkpoint plates, and the final transfer slips all point past the forest.",
        "Lete is the last black-hound wall before Karl's outer line and the inner transfer route beyond it."
    ])

static func build_ch08_05_outro() -> CutsceneData:
    return _build_ch08_cutscene(&"ch08_05_outro", "Night of the Hounds", [
        "Lete falls and the black-hound signal line goes dark. Tia chooses memory over erasure.",
        "The surviving proof fixes the next pursuit on both Karl's outer line and the inner transfer route."
    ])

static func _build_ch09a_cutscene(cutscene_id: StringName, title: String, lines: Array[String]) -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = cutscene_id
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": title,
            "duration": 1.5
        }
    ]
    for line in lines:
        d.beats.append({
            "type": "text_card",
            "text": line,
            "duration": 3.0
        })
    return d

static func build_ch09a_01_intro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_01_intro", "Outer Defense Line", [
        "The capital outer line is built to stop testimony before it reaches the city.",
        "Karl still treats the line as duty, but every order now smells like erasure."
    ])

static func build_ch09a_01_outro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_01_outro", "Outer Defense Line", [
        "The outer line breaks, forcing the march onto Karl's bridge sector.",
        "The first capital checkpoint route is secured."
    ])

static func build_ch09a_02_intro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_02_intro", "Bridge of Banners", [
        "The bridge line proves Karl learned formation from someone he still cannot stop recognizing.",
        "The first break in loyalty comes from seeing that the line protects procedure more than people."
    ])

static func build_ch09a_02_outro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_02_outro", "Bridge of Banners", [
        "The bridge orders break open and point toward the oath-processing barracks.",
        "Karl's bridge checkpoint is broken open and the next route is exposed."
    ])

static func build_ch09a_03_intro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_03_intro", "Nameless Oath Hall", [
        "The nameless oath hall turns exhausted soldiers into evidence to be processed out of history.",
        "What looked like relief is revealed as orderly disappearance."
    ])

static func build_ch09a_03_outro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_03_outro", "Nameless Oath Hall", [
        "The oath records expose where Karl's discarded officers were taken.",
        "The officer-trail proof is secured and the detention route opens."
    ])

static func build_ch09a_04_intro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_04_intro", "Abandoned Officers", [
        "The abandoned officers are no longer comrades to save but witnesses to erase.",
        "Karl sees his own command reclassified as expendable proof."
    ])

static func build_ch09a_04_outro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_04_outro", "Abandoned Officers", [
        "The detention ledgers turn the officer line into witness testimony.",
        "The last barrier before the root access line is the censor's spearhead."
    ])

static func build_ch09a_05_intro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_05_intro", "Spear Without a Banner", [
        "Karl leads the squad to the last censor line with his banner already broken.",
        "If the root route is real, it lies beyond the officer line that was ordered to disappear."
    ])

static func build_ch09a_05_outro() -> CutsceneData:
    return _build_ch09a_cutscene(&"ch09a_05_outro", "Spear Without a Banner", [
        "Karl's testimony, root-archive pass, and movement ledger now open the path toward the inner archive.",
        "Karl steps across with his witness intact and the broken standard route is complete."
    ])

static func _build_ch09b_cutscene(cutscene_id: StringName, title: String, lines: Array[String]) -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = cutscene_id
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": title,
            "duration": 1.5
        }
    ]
    for line in lines:
        d.beats.append({
            "type": "text_card",
            "text": line,
            "duration": 3.0
        })
    return d

static func build_ch09b_01_intro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_01_intro", "Root Gate", [
        "Karl's proof and Noah's route align for only a moment, just long enough to force the archive gate to admit them.",
        "The archive is hidden not because it is secret, but because it decides what deserves to count."
    ])

static func build_ch09b_01_outro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_01_outro", "Root Gate", [
        "The west root seal breaks and the east index gives the first archive-core route a name.",
        "The deeper shelves are open, but only through the records that were meant to erase everyone who entered them."
    ])

static func build_ch09b_02_intro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_02_intro", "Library of Erased Names", [
        "The erased shelves show absence as infrastructure rather than accident.",
        "Here, missing names are not lost; they have been filed into managed silence."
    ])

static func build_ch09b_02_outro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_02_outro", "Library of Erased Names", [
        "The west shelf and east revision stack together expose the missing-name route.",
        "The next descent points toward the last keeper's cell."
    ])

static func build_ch09b_03_intro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_03_intro", "Last Keeper", [
        "Noah preserved more than a memory shard here; he preserved the timing of who could bear it.",
        "The keeper route turns the archive into something navigated by trust rather than rank."
    ])

static func build_ch09b_03_outro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_03_outro", "Last Keeper", [
        "The keeper latch opens, the memory lattice stabilizes, and the final record survives long enough to be carried out.",
        "Noah opens the way to the revision chamber where the field itself can be rewritten."
    ])

static func build_ch09b_04_intro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_04_intro", "Rewritten Battlefield", [
        "The battlefield itself starts to revise around the squad as Melkion's logic takes shape.",
        "Rules, routes, and categories all become tools of censorship."
    ])

static func build_ch09b_04_outro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_04_outro", "Rewritten Battlefield", [
        "The revision cores break and the red annotation pillar goes dark before the whole field can be rewritten.",
        "The last descent into the deep archive is finally exposed."
    ])

static func build_ch09b_05_intro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_05_intro", "Abyss of Record", [
        "The deep archive keeps the last decree beside the parts of Rian that were cut away to make it possible.",
        "Melkion stands where memory becomes policy, and the final record can only be restored by breaking him there."
    ])

static func build_ch09b_05_outro() -> CutsceneData:
    return _build_ch09b_cutscene(&"ch09b_05_outro", "Abyss of Record", [
        "Melkion falls, and the final memory returns as burden to carry and answer for, not absolution.",
        "The eclipse coordinates, tower lattice, and last decree now stand as proof, and the march to the final tower begins."
    ])

static func _build_ch10_cutscene(cutscene_id: StringName, title: String, lines: Array[String]) -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = cutscene_id
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": title,
            "duration": 1.5
        }
    ]
    for line in lines:
        d.beats.append({
            "type": "text_card",
            "text": line,
            "duration": 3.0
        })
    return d

static func build_ch10_01_intro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_01_intro", "Eclipse Eve", [
        "The first tower route opens under an eclipse sky already trying to blur names out of the field.",
        "The climb only starts if the squad can hold formation against a world that wants them forgotten."
    ])

static func build_ch10_01_outro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_01_outro", "Eclipse Eve", [
        "The eclipse tablet and lift latch secure the first ascent route.",
        "The outer lift rises, and the tower stops pretending there is any way back but up."
    ])

static func build_ch10_02_intro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_02_intro", "Resonance Tower Crest", [
        "The tower crest punishes any line that breaks its own memory chain.",
        "Advancing here means turning shared memory into actual formation pressure."
    ])

static func build_ch10_02_outro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_02_outro", "Resonance Tower Crest", [
        "The crest cache yields the Resonance Knot and opens the upper relay route.",
        "The climb sharpens from ascent into judgment."
    ])

static func build_ch10_03_intro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_03_intro", "Nameless Corridor", [
        "The nameless corridors are written like revised pages instead of stone hallways.",
        "Noah's presence is the only reason the route stays readable long enough to cross."
    ])

static func build_ch10_03_outro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_03_outro", "Nameless Corridor", [
        "The ward signet and bellward plate survive the corridor's revisions.",
        "The path to the royal hall is no longer a blank margin."
    ])

static func build_ch10_04_intro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_04_intro", "King's Edict", [
        "Karon still speaks as a king before he hardens into something emptier than a throne.",
        "The first phase can break the decrees, but not yet the bell that made them law."
    ])

static func build_ch10_04_outro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_04_outro", "King's Edict", [
        "The royal hall cracks and the bell chamber below becomes the only road left.",
        "What remains is not the court, but the mechanism it built to make forgetting holy."
    ])

static func build_ch10_05_intro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_05_intro", "Last Name", [
        "The last decree stands in the bell chamber beside the names it tried to erase.",
        "Karon can only be broken by proving that memory survives him."
    ])

static func build_ch10_05_outro() -> CutsceneData:
    return _build_ch10_cutscene(&"ch10_05_outro", "Last Name", [
        "The bell falls silent, the tower lattice collapses, and the last decree loses its grip.",
        "What survives is not innocence, but the names and choices carried out of the tower together."
    ])

## ID로 컷씬 조회
static func get_cutscene(cutscene_id: StringName) -> CutsceneData:
    match cutscene_id:
        &"ch01_start":
            return build_ch01_start()
        &"ch01_clear":
            return build_ch01_clear()
        &"ch01_fragment_flash":
            return build_ch01_fragment_flash()
        &"ch01_05_intro":
            return build_ch01_05_intro()
        &"ch01_05_outro":
            return build_ch01_05_outro()
        &"ch06_05_intro":
            return build_ch06_05_intro()
        &"ch06_05_outro":
            return build_ch06_05_outro()
        &"ch07_01_intro":
            return build_ch07_01_intro()
        &"ch07_01_outro":
            return build_ch07_01_outro()
        &"ch07_02_intro":
            return build_ch07_02_intro()
        &"ch07_02_outro":
            return build_ch07_02_outro()
        &"ch07_03_intro":
            return build_ch07_03_intro()
        &"ch07_03_outro":
            return build_ch07_03_outro()
        &"ch07_04_intro":
            return build_ch07_04_intro()
        &"ch07_04_outro":
            return build_ch07_04_outro()
        &"ch07_05_intro":
            return build_ch07_05_intro()
        &"ch07_05_outro":
            return build_ch07_05_outro()
        &"ch08_01_intro":
            return build_ch08_01_intro()
        &"ch08_01_outro":
            return build_ch08_01_outro()
        &"ch08_02_intro":
            return build_ch08_02_intro()
        &"ch08_02_outro":
            return build_ch08_02_outro()
        &"ch08_03_intro":
            return build_ch08_03_intro()
        &"ch08_03_outro":
            return build_ch08_03_outro()
        &"ch08_04_intro":
            return build_ch08_04_intro()
        &"ch08_04_outro":
            return build_ch08_04_outro()
        &"ch08_05_intro":
            return build_ch08_05_intro()
        &"ch08_05_outro":
            return build_ch08_05_outro()
        &"ch09a_01_intro":
            return build_ch09a_01_intro()
        &"ch09a_01_outro":
            return build_ch09a_01_outro()
        &"ch09a_02_intro":
            return build_ch09a_02_intro()
        &"ch09a_02_outro":
            return build_ch09a_02_outro()
        &"ch09a_03_intro":
            return build_ch09a_03_intro()
        &"ch09a_03_outro":
            return build_ch09a_03_outro()
        &"ch09a_04_intro":
            return build_ch09a_04_intro()
        &"ch09a_04_outro":
            return build_ch09a_04_outro()
        &"ch09a_05_intro":
            return build_ch09a_05_intro()
        &"ch09a_05_outro":
            return build_ch09a_05_outro()
        &"ch09b_01_intro":
            return build_ch09b_01_intro()
        &"ch09b_01_outro":
            return build_ch09b_01_outro()
        &"ch09b_02_intro":
            return build_ch09b_02_intro()
        &"ch09b_02_outro":
            return build_ch09b_02_outro()
        &"ch09b_03_intro":
            return build_ch09b_03_intro()
        &"ch09b_03_outro":
            return build_ch09b_03_outro()
        &"ch09b_04_intro":
            return build_ch09b_04_intro()
        &"ch09b_04_outro":
            return build_ch09b_04_outro()
        &"ch09b_05_intro":
            return build_ch09b_05_intro()
        &"ch09b_05_outro":
            return build_ch09b_05_outro()
        &"ch10_01_intro":
            return build_ch10_01_intro()
        &"ch10_01_outro":
            return build_ch10_01_outro()
        &"ch10_02_intro":
            return build_ch10_02_intro()
        &"ch10_02_outro":
            return build_ch10_02_outro()
        &"ch10_03_intro":
            return build_ch10_03_intro()
        &"ch10_03_outro":
            return build_ch10_03_outro()
        &"ch10_04_intro":
            return build_ch10_04_intro()
        &"ch10_04_outro":
            return build_ch10_04_outro()
        &"ch10_05_intro":
            return build_ch10_05_intro()
        &"ch10_05_outro":
            return build_ch10_05_outro()
        _:
            return null

class_name CampaignController
extends Node

signal mode_changed(mode: String)

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")
const CampaignChapterRegistry = preload("res://scripts/campaign/campaign_chapter_registry.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const AccessoryData = preload("res://scripts/data/accessory_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const ArmorData = preload("res://scripts/data/armor_data.gd")
const CampController = preload("res://scripts/camp/camp_controller.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")

const CHAPTER_CH01: StringName = CampaignChapterRegistry.CHAPTER_CH01
const CHAPTER_CH02: StringName = CampaignChapterRegistry.CHAPTER_CH02
const CHAPTER_CH03: StringName = CampaignChapterRegistry.CHAPTER_CH03
const CHAPTER_CH04: StringName = CampaignChapterRegistry.CHAPTER_CH04
const CHAPTER_CH05: StringName = CampaignChapterRegistry.CHAPTER_CH05
const CHAPTER_CH06: StringName = CampaignChapterRegistry.CHAPTER_CH06
const CHAPTER_CH07: StringName = CampaignChapterRegistry.CHAPTER_CH07
const CHAPTER_CH08: StringName = CampaignChapterRegistry.CHAPTER_CH08
const CHAPTER_CH09A: StringName = CampaignChapterRegistry.CHAPTER_CH09A
const CHAPTER_CH09B: StringName = CampaignChapterRegistry.CHAPTER_CH09B
const CHAPTER_CH10: StringName = CampaignChapterRegistry.CHAPTER_CH10
const TEMP_ALLY_LETE = preload("res://data/units/enemy_lete.tres")
const DESPERATE_ENEMY_SKIRMISHER = preload("res://data/units/enemy_skirmisher.tres")
const DESPERATE_ENEMY_BOSS = preload("res://data/units/enemy_roderic.tres")

const RETREAT_OPTION_FULL: String = "defeat_full_retreat"
const RETREAT_OPTION_SACRIFICE: String = "defeat_sacrifice_protocol"
const RETREAT_OPTION_DESPERATE: String = "defeat_desperate_stand"
const RETREAT_OPTION_SACRIFICE_PREFIX: String = "defeat_sacrifice_unit:"
const SUPPORT_OPTION_A: String = "support_context_A"
const SUPPORT_OPTION_B: String = "support_context_B"
const SUPPORT_OPTION_C: String = "support_context_C"
const SUPPORT_PENDING_BONUS: int = 2
const MEMORIAL_QUOTE_PREFIX := "나는後悔ない."
const SACRIFICE_EPITAPHS := {
    &"ally_serin": "등불은 넘겨줬다. 이제 앞으로 가.",
    &"ally_bran": "대열을 무너뜨리지 마라.",
    &"ally_tia": "숲은 너희 발자국을 기억할 거야.",
    &"ally_enoch": "기록은 남겼다. 끝까지 읽어.",
    &"ally_karl": "깃발은 쓰러져도 행군은 끝나지 않는다.",
    &"ally_noah": "이 이름만은 끝까지 지켜.",
    &"ally_mira": "진실은 태워도 재가 남아.",
    &"ally_melkion_ally": "증명은 이제 너희 몫이다."
}

const CHOICE_CH05_CAMP: StringName = &"ch05_camp"
const CHOICE_CH07_INTERLUDE: StringName = &"ch07_interlude"
const CHOICE_CH08_PRE_BOSS: StringName = &"ch08_pre_boss"
const CHOICE_CH09A_CAMP: StringName = &"ch09a_camp"
const CHOICE_CH10_PRE_FINALE: StringName = &"ch10_pre_finale"
const CHOICE_POINT_STAGES: Array[StringName] = [
    CHOICE_CH05_CAMP,
    CHOICE_CH07_INTERLUDE,
    CHOICE_CH08_PRE_BOSS,
    CHOICE_CH09A_CAMP,
    CHOICE_CH10_PRE_FINALE
]
const WORLDVIEW_FRAGMENT_LETE: String = "복수의_순수함"
const WORLDVIEW_FRAGMENT_MIRA: String = "믿음과_의심"
const WORLDVIEW_FRAGMENT_MELKION: String = "진실의_대가"
const WORLDVIEW_REQUIRED_FRAGMENTS: Array[String] = [
    WORLDVIEW_FRAGMENT_LETE,
    WORLDVIEW_FRAGMENT_MIRA,
    WORLDVIEW_FRAGMENT_MELKION
]

const CH01_STAGE_REWARD_LOG: Dictionary = {
    &"CH01_02": [
        "Ashen Field cache logged: field ration bundles secured for the survivor column."
    ],
    &"CH01_03": [
        "Ruined Well survey logged: route notes recovered for the northern gate approach."
    ],
    &"CH01_04": [
        "North Gate relay logged: breach timing notes recovered for the dawn oath push."
    ],
    &"CH01_05": [
        "Dawn Oath handoff logged: Serin is now locked as a full ally for the camp interlude."
    ]
}

const CH01_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH01_02": [
        "Serin clocks that Rian arranged the civilians like a retreat officer, not a drifting survivor.",
        "The escort line bends east and the ruined well becomes the safest next stop."
    ],
    &"CH01_03": [
        "At the ruined well, Rian hears a cold command voice tied to water, supply, and deployment.",
        "The memory ripple points north toward the gate approach."
    ],
    &"CH01_04": [
        "Serin presses Rian on how he read the weak point of the gate so quickly.",
        "The breach opens the road to the Dawn Oath confrontation."
    ]
}

const CH01_STAGE_MEMORY_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "mem_frag_ch01_first_order",
            "summary": "First Order: a cut command echoes over the burning field, but the speaker and intent stay unclear."
        }
    ]
}

const CH01_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "flag_evidence_hardren_seal_obtained",
            "summary": "Hardren seal recovered; the ash-field command chain can be traced north toward the border evidence trail."
        }
    ]
}

const CH01_STAGE_LETTER_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "Letter from Serin",
            "summary": "\"The name on your scabbard is enough for now. We move north together and keep the survivors behind us safe.\""
        }
    ]
}

const CH02_STAGE_REWARD_LOG: Dictionary = {
    &"CH02_01": [
        "Militia sigil secured: accessory route opens with the Militia Emblem."
    ],
    &"CH02_02": [
        "Outer wall cache logged: steel nails and emergency medicine recovered from the rampart flank."
    ],
    &"CH02_03": [
        "Remaining Knights handoff: Bran joins the field line and the Broken Captain Seal is logged."
    ],
    &"CH02_04": [
        "Iron Gate controls logged: Gatekeeper Ring route is now visible in the tunnel records."
    ],
    &"CH02_05": [
        "Hardren Banner reclaimed: Hardren Iron Crest secured for the fortress handoff."
    ]
}

const CH02_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH02_01": [
        "The smoke line breaks just enough for the squad to sight Hardren's outer wall.",
        "A signal tower cache hints that stronger fortress gear still lies inside."
    ],
    &"CH02_02": [
        "The outer wall collapse reveals stranded knights and a tighter path into the fortress interior.",
        "Rian reads the angles too quickly, and Bran's suspicion sharpens."
    ],
    &"CH02_03": [
        "Bran and Rian finally fight on the same line while the remaining knights regroup.",
        "The tunnel controls beneath the iron gate become the only route left."
    ],
    &"CH02_04": [
        "The tunnel levers answer in sequence, opening the last approach into Hardren's banner hall.",
        "The fortress feels familiar to Rian in a way he cannot explain."
    ]
}

const CH02_STAGE_MEMORY_LOG: Dictionary = {
    &"CH02_05": [
        {
            "title": "mem_frag_ch02_hardren_blueprint",
            "summary": "Hardren Blueprint: Rian remembers fortress routes and siege lanes too well for a stranger."
        }
    ]
}

const CH02_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH02_05": [
        {
            "title": "flag_evidence_greenwood_orders_obtained",
            "summary": "Tracking orders and the Greenwood north-route sketch confirm the pursuit is moving toward the forest."
        }
    ]
}

const CH02_STAGE_LETTER_LOG: Dictionary = {
    &"CH02_05": [
        {
            "title": "Bran's Watch Oath",
            "summary": "\"I still do not trust what you were. I will still march with what you are doing now.\""
        }
    ]
}

const CH02_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH02_01": [&"acc_militia_emblem"],
    &"CH02_03": [&"acc_broken_captain_seal"],
    &"CH02_04": [&"acc_gatekeeper_ring"],
    &"CH02_05": [&"acc_hardren_iron_crest"]
}

const CH03_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH03_01": [&"acc_verdant_plume"],
    &"CH03_02": [&"acc_trap_hunter_needle"],
    &"CH03_04": [&"acc_sap_charm"]
}

const CH04_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH04_01": [&"acc_watergate_boots"],
    &"CH04_02": [&"acc_locked_bell_shard"],
    &"CH04_04": [&"acc_sanctified_pendant"],
    &"CH04_05": [&"acc_whiteflow_token"]
}

const CH05_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH05_02": [&"acc_gray_bookmark"],
    &"CH05_03": [&"acc_heatproof_archivist_coat"],
    &"CH05_04": [&"acc_zero_trace_codex"]
}

const CH06_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH06_02": [&"acc_artillery_sight"],
    &"CH06_03": [&"acc_valtor_command_cuirass"],
    &"CH06_04": [&"acc_oath_ring"]
}

const CH07_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH07_02": [&"acc_memory_bell"],
    &"CH07_04": [&"acc_knot_talisman"],
    &"CH07_05": [&"acc_namebound_thread"]
}

const CH08_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH08_02": [&"acc_moonlit_pursuit_sigil"],
    &"CH08_03": [&"acc_ruin_holdfast_charm"],
    &"CH08_04": [&"acc_houndfang_mark"]
}

const CH09A_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH09A_02": [&"acc_bannerline_clasp"],
    &"CH09A_03": [&"acc_nameless_watch_badge"],
    &"CH09A_04": [&"acc_officer_rescue_cipher"]
}

const CH09B_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH09B_02": [&"acc_revision_ward_pin"],
    &"CH09B_03": [&"acc_keeper_thread_seal"],
    &"CH09B_04": [&"acc_archive_proof_relay"]
}

const CH10_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH10_02": [&"acc_resonance_knot"],
    &"CH10_03": [&"acc_tower_ward_signet"],
    &"CH10_04": [&"acc_bell_oath_relic"]
}

const CH03_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH03_03": [&"ar_greenwood_cloak"]
}

const CH04_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH04_05": [&"ar_whiteflow_vestment"]
}

const CH05_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH05_02": [&"wp_archive_ashblade"],
    &"CH05_04": [&"wp_zero_trace_staff"]
}

const CH06_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH06_05": [&"wp_valtor_command_lance"]
}

const CH07_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH07_05": [&"wp_saria_mercy_staff"]
}

const CH08_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH08_04": [&"wp_houndline_bow"]
}

const CH09A_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH09A_05": [&"wp_standard_breaker_blade"]
}

const CH09B_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH09B_03": [&"wp_keeper_root_staff"]
}

const CH10_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH10_04": [&"wp_eclipse_resonance_blade"]
}

const CH05_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH05_05": [&"ar_archive_smoke_coat"]
}

const CH07_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH07_03": [&"ar_elyor_procession_mail"]
}

const CH08_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH08_03": [&"ar_ruin_tracker_coat"]
}

const CH09A_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH09A_04": [&"ar_capital_witness_plate"]
}

const CH09B_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH09B_04": [&"ar_revision_guard_cloak"]
}

const CH10_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH10_03": [&"ar_bellward_plate"]
}

const CH03_STAGE_REWARD_LOG: Dictionary = {
    &"CH03_01": [
        "Verdant route logged: the Greenwood plume trail opens with the first forest cache."
    ],
    &"CH03_02": [
        "Trap-line cache logged: the hunter's needle route is now visible in the records."
    ],
    &"CH03_03": [
        "Refugee escort logged: the woodsman cloak route is secured for the lower trail."
    ],
    &"CH03_04": [
        "Resin ward logged: the sap charm route is now recorded against the wildfire lanes."
    ],
    &"CH03_05": [
        "Greenwood hunt handoff logged: Tia joins, the first boss weapon is secured, and the hunt board route unlocks later."
    ]
}

const CH03_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH03_01": [
        "The lost forest narrows into hunter territory, and every path feels watched.",
        "The first cache proves someone has been moving survivors through Greenwood in secret."
    ],
    &"CH03_02": [
        "Trap lines tighten and Tia's unseen shots start reading the squad before she ever speaks.",
        "The refugee path bends south, but the forest itself points toward a larger fire plan."
    ],
    &"CH03_03": [
        "The column survives, but the safest trail is gone; only the resin basin route remains.",
        "Tia starts treating the squad as something more complicated than an enemy incursion."
    ],
    &"CH03_04": [
        "Burning residue and dimmed beacons reveal that the forest fire was planned, not accidental.",
        "The last shrine lane leads straight to the hunter's altar."
    ]
}

const CH03_STAGE_MEMORY_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "mem_frag_ch03_forest_fire_order",
            "summary": "Forest Fire Order: Rian approved a firebreak plan that burned through Greenwood under imperial command."
        }
    ]
}

const CH03_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "flag_evidence_monastery_manifest_obtained",
            "summary": "Purification manifests and transfer notes point the pursuit toward the drowned monastery."
        }
    ]
}

const CH03_STAGE_LETTER_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "Tia's Uneasy Truce",
            "summary": "\"I do not forgive what your orders did here. I am still coming with you to see what remains.\""
        }
    ]
}

const CH04_STAGE_REWARD_LOG: Dictionary = {
    &"CH04_01": [
        "Flooded Cloister cache logged: the first monastery supply trace is secured."
    ],
    &"CH04_02": [
        "Bell tower cache logged: the locked bell shard route is now visible."
    ],
    &"CH04_03": [
        "Floodgate controls logged: the waterproof vestment route is secured."
    ],
    &"CH04_04": [
        "Relic chamber purification logged: the sanctified pendant route is now visible."
    ],
    &"CH04_05": [
        "Sunken Altar handoff logged: Basil falls, the first random boss weapon route opens later, and the monastery records are secured."
    ]
}

const CH04_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH04_01": [
        "The monastery entry is half drowned, and every safe route depends on the shifting waterline.",
        "Serin recognizes the cloister as sacred ground twisted into a processing site."
    ],
    &"CH04_02": [
        "The bell tower no longer calls worshipers; it clears sightlines and shakes memory loose.",
        "The old flood notes point down into the control works."
    ],
    &"CH04_03": [
        "The flood controls answer like laboratory hardware rather than temple machinery.",
        "The stabilized pressure opens the way to the relic vault."
    ],
    &"CH04_04": [
        "Purifying the last chamber proves the monastery was managing memory, not merely prayer.",
        "The final sealed route leads to Basil's drowned altar."
    ]
}

const CH04_STAGE_MEMORY_LOG: Dictionary = {
    &"CH04_05": [
        {
            "title": "mem_frag_ch04_ark_research",
            "summary": "Ark Research Record: the cloister stored procedures for extraction, stabilization, and managed forgetting."
        }
    ]
}

const CH04_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH04_05": [
        {
            "title": "flag_evidence_archive_transfer_obtained",
            "summary": "Research seals and transfer ledgers point the trail toward the Gray Archive."
        }
    ]
}

const CH04_STAGE_LETTER_LOG: Dictionary = {
    &"CH04_05": [
        {
            "title": "Serin's Broken Faith",
            "summary": "\"They used prayer to wash names out of people. I will not call that mercy.\""
        }
    ]
}

const CH05_STAGE_REWARD_LOG: Dictionary = {
    &"CH05_01": [
        "Ash Gate cache logged: the archive perimeter route is secured."
    ],
    &"CH05_02": [
        "Forbidden stacks cache logged: Gray Bookmark recovered from the first sealed shelf."
    ],
    &"CH05_03": [
        "Burning stair cache logged: Heatproof Archivist Coat secured for the ash climb."
    ],
    &"CH05_04": [
        "Truth Shelf seals logged: Zero Trace Codex secured beside the first edited archive proof."
    ],
    &"CH05_05": [
        "Gray Archive handoff logged: Enoch joins, salvage later unlocks, and the Valtor trail is secured."
    ]
}

const CH05_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH05_01": [
        "The archive burns from the outside inward, turning proof itself into ash.",
        "Half-charred ledgers show names vanishing before bodies do."
    ],
    &"CH05_02": [
        "Moving shelves and sealed rows make the route feel curated rather than merely ruined.",
        "The deeper the squad goes, the more the archive looks like deliberate erasure."
    ],
    &"CH05_03": [
        "The upper tiers are collapsing, forcing the squad to climb through fire and narrowing routes.",
        "Every surviving record feels chosen rather than spared."
    ],
    &"CH05_04": [
        "The last seals open and Enoch names Zero aloud for the first time.",
        "The records show edits and red notes layered over the same commands."
    ]
}

const CH05_STAGE_MEMORY_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "mem_frag_ch05_zero_revealed",
            "summary": "Zero Named: the archive finally names Rian as Zero, but the surrounding records show layers of later edits."
        }
    ]
}

const CH05_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "flag_evidence_fortress_ledger_obtained",
            "summary": "Valtor siege ledgers and surviving-knight manifests point the march toward the iron fortress."
        }
    ]
}

const CH05_STAGE_LETTER_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "Enoch's Margin Note",
            "summary": "\"Memory is evidence, not sentence. The next fortress may still hold people who can prove the difference.\""
        }
    ]
}

const CH06_STAGE_REWARD_LOG: Dictionary = {
    &"CH06_01": [
        "Forward gunline cache logged: Valtor approach routes are secured."
    ],
    &"CH06_02": [
        "Battery line cache logged: Artillery Sight recovered from the fortress gun crews."
    ],
    &"CH06_03": [
        "Quartermaster depths cache logged: Valtor Command Cuirass secured in the quartermaster depths."
    ],
    &"CH06_04": [
        "Oath hall controls logged: Oath Ring secured in the inner hall ledger vault."
    ],
    &"CH06_05": [
        "Valtor handoff logged: Valgar falls, forge later unlocks, and Ellyor relief orders are secured."
    ]
}

const CH06_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH06_01": [
        "The outer smoke clears into a fortress approach built to break attackers before they reach the wall.",
        "Bran reads the lines like a defender while Rian reads them like the one who broke them."
    ],
    &"CH06_02": [
        "The batteries still speak in the language of siege math and deliberate sacrifice.",
        "Each gunline dismantled opens another road toward the inner keep."
    ],
    &"CH06_03": [
        "The prison depths reveal surviving knights, quartermaster routes, and the first trail toward Ellyor.",
        "Even the supply rooms feel like a record of people being reduced to pieces of a fortress."
    ],
    &"CH06_04": [
        "The oath hall still remembers the plan that broke Valtor from within.",
        "The red annotations prove the worst timing was changed after the original route was drawn."
    ]
}

const CH06_STAGE_MEMORY_LOG: Dictionary = {
    &"CH06_05": [
        {
            "title": "mem_frag_ch06_fortress_breach_context",
            "summary": "Fortress Breach Context: Rian opened the wall, but later red edits tightened the trap into slaughter."
        }
    ]
}

const CH06_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH06_05": [
        {
            "title": "flag_evidence_elyor_edict_obtained",
            "summary": "Ellyor relief edicts and civilian transfer rolls confirm the next pursuit leads to the purification rite."
        }
    ]
}

const CH06_STAGE_LETTER_LOG: Dictionary = {
    &"CH06_05": [
        {
            "title": "Bran's Unforgiven March",
            "summary": "\"I still cannot forgive the hand that opened this wall. I can still march beside the one facing what it did.\""
        }
    ]
}

const CH07_STAGE_REWARD_LOG: Dictionary = {
    &"CH07_01": [
        "Market route logged: the first Ellyor rescue lane is secured."
    ],
    &"CH07_02": [
        "Silence square cache logged: Memory Bell recovered from the silence-square watchpost."
    ],
    &"CH07_03": [
        "Procession break logged: Mira and Neri are pulled back from the nameless line, and Elyor Procession Mail is secured."
    ],
    &"CH07_04": [
        "Cathedral channels logged: Knot Talisman secured in the hymn-channel reliquary."
    ],
    &"CH07_05": [
        "Ellyor handoff logged: Saria falls, Saria Mercy Staff and Namebound Thread are secured, sigil tuning later unlocks, and the black-hound route is secured."
    ]
}

const CH07_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH07_01": [
        "The market proves people are walking into forgetting on purpose, not only by force.",
        "Mira and Neri reappear as the first faces that make the doctrine feel real."
    ],
    &"CH07_02": [
        "The queue system is orderly, quiet, and frighteningly persuasive.",
        "Bran recognizes that soldiers would have stood in the same line if given the same promise."
    ],
    &"CH07_03": [
        "The nameless procession breaks, but only after the squad physically turns people away from the rite.",
        "Serin understands Saria's logic without accepting it."
    ],
    &"CH07_04": [
        "The cathedral channels carry the hymn like machinery dressed as mercy.",
        "The last route into Saria's prayer hall opens as the sermon loses its hold."
    ]
}

const CH07_STAGE_MEMORY_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "mem_frag_ch07_zero_named_by_karon",
            "summary": "Zero Named by Karon: the child without a name is given one that saves and binds at the same time."
        }
    ]
}

const CH07_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "flag_evidence_black_hound_orders_obtained",
            "summary": "Black-hound orders and hidden-ruin coordinates point the pursuit toward Lete's forest route."
        }
    ]
}

const CH07_STAGE_LETTER_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "Mira's Unsent Note",
            "summary": "\"I almost gave my child away to silence. I will remember that before I ask for mercy again.\""
        }
    ]
}

const CH08_STAGE_REWARD_LOG: Dictionary = {
    &"CH08_01": [
        "Vanished trail handoff logged: the first black-hound pursuit lane is narrowed to one route."
    ],
    &"CH08_02": [
        "Moonlit ambush cache logged: Moonlit Pursuit Sigil recovered and the kill lane is mapped."
    ],
    &"CH08_03": [
        "Lower-ruin handoff logged: Ruin Holdfast Charm and Ruin Tracker Coat secured from the exposed holding cells."
    ],
    &"CH08_04": [
        "Black-mark control handoff logged: Houndfang Mark and Houndline Bow secured from the erased control brands."
    ],
    &"CH08_05": [
        "Black-hound handoff logged: Lete falls, the pursuit proof survives, and both Karl's outer line and the inner transfer route are fixed as the next objectives."
    ]
}

const CH08_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH08_01": [
        "The forest is no longer only terrain; it has been rewritten into a hunting grid.",
        "The first pursuit forks show the black hounds cutting people out of the map itself."
    ],
    &"CH08_02": [
        "Moonlit ambush lines split the squad and punish whoever drifts alone.",
        "Tia recognizes the pattern as stolen forest sense turned into doctrine."
    ],
    &"CH08_03": [
        "The lower ruins smell like holding pens, not shelter.",
        "The opened vents and seized records make Tia's hope and dread sharper at the same time."
    ],
    &"CH08_04": [
        "The control brands reveal that capture orders and later edits are layered over the same operation.",
        "Rian's authorization line survives under the later red revisions, proving the hunt was rewritten after the first order."
    ]
}

const CH08_STAGE_MEMORY_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "mem_frag_ch08_north_corridor_context_seen",
            "summary": "North Corridor Context: the original order kept a northern route open, while later edits narrowed it into capture and purge."
        }
    ]
}

const CH08_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "flag_evidence_outer_gate_writ_obtained",
            "summary": "Special orders, checkpoint plates, and transfer slips now fix the chase on Karl's outer defense line and the inner transfer route."
        }
    ]
}

const CH08_STAGE_LETTER_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "Tia's Last Unsent Name",
            "summary": "\"I cannot bring her back. I can carry her name forward and make the next erasure stop here.\""
        }
    ]
}

const CH09A_STAGE_REWARD_LOG: Dictionary = {
    &"CH09A_01": [
        "Outer-line cache logged: the first capital checkpoint route is secured."
    ],
    &"CH09A_02": [
        "Bridge cache logged: Bannerline Clasp secured from Karl's bridge checkpoint."
    ],
    &"CH09A_03": [
        "Oath-hall cache logged: Nameless Watch Badge secured inside the oath hall."
    ],
    &"CH09A_04": [
        "Detention cache logged: Officer Rescue Cipher and Capital Witness Plate secured in the detention ledgers."
    ],
    &"CH09A_05": [
        "Broken standard handoff logged: Karl joins, Standard Breaker Blade is secured, and Karl's testimony, root-archive pass, and movement ledger open the path toward the inner archive."
    ]
}

const CH09A_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH09A_01": [
        "The capital outer line is built to stop testimony before it reaches the city.",
        "Karl still treats the line as duty, but every order now smells like erasure."
    ],
    &"CH09A_02": [
        "The bridge line proves Karl learned formation from someone he still cannot stop recognizing.",
        "The first break in loyalty comes from seeing that the line protects procedure more than people."
    ],
    &"CH09A_03": [
        "The nameless oath hall turns exhausted soldiers into evidence to be processed out of history.",
        "What looked like relief is revealed as orderly disappearance."
    ],
    &"CH09A_04": [
        "The abandoned officers are no longer comrades to save but witnesses to erase.",
        "Karl sees his own command reclassified as expendable proof."
    ]
}

const CH09A_STAGE_MEMORY_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "mem_frag_ch09a_returning_names_seen",
            "summary": "Returning Names: Karl remembers Zero as the officer who once said victory only mattered if names came home with it."
        }
    ]
}

const CH09A_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "flag_evidence_root_archive_pass_obtained",
            "summary": "Karl's testimony, root-archive pass, and movement ledger now open the path toward the inner archive."
        }
    ]
}

const CH09A_STAGE_LETTER_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "Karl's Broken Standard",
            "summary": "\"I am not changing sides for you. I am stepping across to see the inside with my own eyes.\""
        }
    ]
}

const CH09B_STAGE_REWARD_LOG: Dictionary = {
    &"CH09B_01": [
        "Root gate cache logged: the first archive-core route is secured."
    ],
    &"CH09B_02": [
        "Erased-shelf cache logged: Revision Ward Pin secured from the first revised shelf."
    ],
    &"CH09B_03": [
        "Last keeper handoff logged: Noah joins, Keeper Thread Seal is secured, and Noah's root staff is recovered."
    ],
    &"CH09B_04": [
        "Revision core logged: Archive Proof Relay and Revision Guard Cloak secured inside the revision core."
    ],
    &"CH09B_05": [
        "Abyss handoff logged: Melkion falls, the final memory returns as burden rather than absolution, and the eclipse coordinates, tower lattice, and last decree are secured as proof for the final tower march."
    ]
}

const CH09B_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH09B_01": [
        "The root gate admits the squad only because Karl's proof and Noah's route overlap for a moment.",
        "The archive is not hidden because it is secret; it is hidden because it decides what counts."
    ],
    &"CH09B_02": [
        "The erased shelves show absence as infrastructure rather than accident.",
        "Names are not missing here; they have been filed into managed silence."
    ],
    &"CH09B_03": [
        "Noah was preserving more than a memory shard; he was preserving the timing of who could bear it.",
        "The keeper route turns the archive into something navigated by trust rather than rank."
    ],
    &"CH09B_04": [
        "The battlefield itself starts to revise around the squad as Melkion's logic takes shape.",
        "Rules, routes, and categories all become tools of censorship."
    ]
}

const CH09B_STAGE_MEMORY_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "mem_frag_ch09b_final_restored",
            "summary": "Final Restored Memory: Rian helped build the machine, then shattered his own memory to leave a way through it; what returns is burden to carry, not absolution."
        }
    ]
}

const CH09B_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "flag_evidence_eclipse_coords_obtained",
            "summary": "Eclipse coordinates, tower lattice, and the last decree now stand as concrete proof of the king's design and the route into the final tower."
        }
    ]
}

const CH09B_STAGE_LETTER_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "Noah's Last Trust",
            "summary": "\"The other you left a path, not an excuse. Carry it as burden, not absolution, and keep choosing people when we climb the final tower.\""
        }
    ]
}

const CH10_STAGE_REWARD_LOG: Dictionary = {
    &"CH10_01": [
        "Eclipse-eve cache logged: the first tower supply route is secured."
    ],
    &"CH10_02": [
        "Tower crest cache logged: Resonance Knot secured from the tower crest relay."
    ],
    &"CH10_03": [
        "Nameless corridor cache logged: Tower Ward Signet and Bellward Plate secured in the nameless corridor."
    ],
    &"CH10_04": [
        "Royal hall handoff logged: Bell Oath Relic and Eclipse Resonance Blade are secured as the first Karon phase falls and the chamber opens."
    ],
    &"CH10_05": [
        "Final resolution logged: Karon falls, the bell is silenced, and the ending state is ready."
    ]
}

const CH10_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH10_01": [
        "The outer ascent proves the tower is already trying to blur names out of the battlefield itself.",
        "The last climb starts with holding formation under a sky that wants everyone forgotten."
    ],
    &"CH10_02": [
        "The resonance towers punish any team that spreads too far apart.",
        "The squad only advances by turning shared memory into actual formation pressure."
    ],
    &"CH10_03": [
        "The nameless corridors are built like revised pages, not stone hallways.",
        "Noah's presence is what keeps the route from collapsing into blankness."
    ],
    &"CH10_04": [
        "Karon still fights like a king before he becomes something larger and emptier than a throne.",
        "The first phase breaks the decrees, but not yet the bell that made them."
    ]
}

const CH10_STAGE_MEMORY_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "mem_frag_ch10_final_choice",
            "summary": "Final Choice: Rian rejects peace by deletion and chooses a world where remembered pain can still lead to new choices."
        }
    ]
}

const CH10_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "flag_ending_resolution_recorded",
            "summary": "The bell stops, the tower lattice collapses, and the campaign resolves around what survives remembering."
        }
    ]
}

const CH10_STAGE_LETTER_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "Neri's Clear Name",
            "summary": "\"My name is Neri. So please, do not forget any of us.\""
        }
    ]
}

var _battle_controller: BattleController
var _campaign_panel: CampaignPanel
var _camp_controller: CampController
var _save_service: SaveService
var _active_mode: String = CampaignState.MODE_BATTLE
var _active_chapter_id: StringName = CHAPTER_CH01
var _active_stage_index: int = 0
var _current_stage: StageData
var _current_panel_title: String = ""
var _current_panel_body: String = ""
var _ch10_complete_phase: StringName = StringName()
var _pending_choice_stage_id: StringName = StringName()
var _pending_choice_stage_index: int = -1
var _chapter_reward_entries: Array[String] = []
var _unlocked_memory_entries: Array[String] = []
var _unlocked_evidence_entries: Array[String] = []
var _unlocked_letter_entries: Array[String] = []
var _deployed_party_unit_ids: Array[StringName] = [&"ally_rian", &"ally_serin"]
var _unlocked_accessory_ids: Array[StringName] = []
var _unlocked_weapon_ids: Array[StringName] = []
var _unlocked_armor_ids: Array[StringName] = []
var _equipped_weapon_by_unit_id: Dictionary = {}
var _equipped_armor_by_unit_id: Dictionary = {}
var _equipped_accessory_by_unit_id: Dictionary = {}
var _defeat_payload: Dictionary = {}
var _defeat_choice_options: Array[Dictionary] = []
var _defeat_choice_prompt: String = ""
var _post_defeat_destination: String = ""
var _desperate_stand_context: Dictionary = {}
var _last_memorial_scene: Dictionary = {}
var _suppress_s_rank_memorial: bool = false
var _active_support_conversation: Dictionary = {}

func setup(battle_controller: BattleController, campaign_panel: CampaignPanel) -> void:
    _battle_controller = battle_controller
    _campaign_panel = campaign_panel
    _camp_controller = CampController.new()
    add_child(_camp_controller)
    _save_service = SaveService.new()
    add_child(_save_service)

    if _battle_controller != null and not _battle_controller.battle_finished.is_connected(_on_battle_finished):
        _battle_controller.battle_finished.connect(_on_battle_finished)
    if _battle_controller != null and not _battle_controller.battle_defeat.is_connected(_on_battle_defeat):
        _battle_controller.battle_defeat.connect(_on_battle_defeat)
    if _battle_controller != null and _battle_controller.bond_service != null and not _battle_controller.bond_service.s_rank_ally_died.is_connected(_on_s_rank_ally_died):
        _battle_controller.bond_service.s_rank_ally_died.connect(_on_s_rank_ally_died)
    if _battle_controller != null and _battle_controller.bond_service != null and not _battle_controller.bond_service.support_progress_updated.is_connected(_on_support_rank_increased):
        _battle_controller.bond_service.support_progress_updated.connect(_on_support_rank_increased)

    if _campaign_panel != null and not _campaign_panel.advance_requested.is_connected(_on_advance_requested):
        _campaign_panel.advance_requested.connect(_on_advance_requested)
    if _campaign_panel != null and not _campaign_panel.deployment_assignment_requested.is_connected(_on_deployment_assignment_requested):
        _campaign_panel.deployment_assignment_requested.connect(_on_deployment_assignment_requested)
    if _campaign_panel != null and not _campaign_panel.weapon_cycle_requested.is_connected(_on_weapon_cycle_requested):
        _campaign_panel.weapon_cycle_requested.connect(_on_weapon_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.armor_cycle_requested.is_connected(_on_armor_cycle_requested):
        _campaign_panel.armor_cycle_requested.connect(_on_armor_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_cycle_requested.is_connected(_on_accessory_cycle_requested):
        _campaign_panel.accessory_cycle_requested.connect(_on_accessory_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.choice_selected.is_connected(_on_choice_selected):
        _campaign_panel.choice_selected.connect(_on_choice_selected)
    if _campaign_panel != null and not _campaign_panel.memorial_finished.is_connected(_on_memorial_scene_finished):
        _campaign_panel.memorial_finished.connect(_on_memorial_scene_finished)

func start_chapter_one_flow(reset_progression: bool = true) -> void:
    if reset_progression:
        _start_new_campaign()
        return
    _prepare_chapter_one_runtime()
    _sync_npc_personality_with_progression(false)
    _enter_stage(_active_stage_index)

func _start_new_campaign() -> void:
    _prepare_chapter_one_runtime()
    var progression: ProgressionData = _get_progression_data()
    if progression != null:
        progression.reset_for_new_campaign()
        _apply_ng_plus_purchases(progression)
    _sync_npc_personality_with_progression(true)
    _enter_stage(_active_stage_index)

func _prepare_chapter_one_runtime() -> void:
    _active_chapter_id = CHAPTER_CH01
    _active_stage_index = 0
    _deployed_party_unit_ids = [&"ally_rian", &"ally_serin"]
    _unlocked_accessory_ids.clear()
    _unlocked_weapon_ids.clear()
    _unlocked_armor_ids.clear()
    _equipped_weapon_by_unit_id.clear()
    _equipped_armor_by_unit_id.clear()
    _equipped_accessory_by_unit_id.clear()
    _chapter_reward_entries.clear()
    _unlocked_memory_entries.clear()
    _unlocked_evidence_entries.clear()
    _unlocked_letter_entries.clear()
    _defeat_payload.clear()
    _defeat_choice_options.clear()
    _defeat_choice_prompt = ""
    _post_defeat_destination = ""
    _desperate_stand_context.clear()
    _last_memorial_scene.clear()

func _apply_ng_plus_purchases(progression: ProgressionData) -> void:
    if progression == null:
        return
    if progression.has_ng_plus_purchase("iron_memory"):
        _restore_ng_plus_fragments(progression)
    if progression.has_ng_plus_purchase("veteran_squad"):
        _prime_ng_plus_veteran_levels(progression)
    if progression.has_ng_plus_purchase("lete_bow") and not _unlocked_weapon_ids.has(&"wp_houndline_bow"):
        _unlocked_weapon_ids.append(&"wp_houndline_bow")
    if progression.has_ng_plus_purchase("mira_archive"):
        _unlock_all_ng_plus_records()
    if progression.has_ng_plus_purchase("divine_blessing"):
        progression.free_name_call = true

func _restore_ng_plus_fragments(progression: ProgressionData) -> void:
    if _battle_controller == null or _battle_controller.progression_service == null:
        return
    for fragment_id in progression.ng_plus_saved_fragments:
        _battle_controller.progression_service.recover_fragment(StringName(fragment_id))
    progression.snapshot_unlock_state()

func _prime_ng_plus_veteran_levels(progression: ProgressionData) -> void:
    for unit_id: StringName in CampaignCatalog.get_party_roster_order():
        progression.set_unit_progress(unit_id, 5, 0)

func _unlock_all_ng_plus_records() -> void:
    for table in [
        CH01_STAGE_MEMORY_LOG,
        CH02_STAGE_MEMORY_LOG,
        CH03_STAGE_MEMORY_LOG,
        CH04_STAGE_MEMORY_LOG,
        CH05_STAGE_MEMORY_LOG,
        CH06_STAGE_MEMORY_LOG,
        CH07_STAGE_MEMORY_LOG,
        CH08_STAGE_MEMORY_LOG,
        CH09A_STAGE_MEMORY_LOG,
        CH09B_STAGE_MEMORY_LOG,
        CH10_STAGE_MEMORY_LOG
    ]:
        for stage_id in table.keys():
            _append_unique_lines(_unlocked_memory_entries, _format_record_entries(table.get(stage_id, [])))
    for table in [
        CH01_STAGE_EVIDENCE_LOG,
        CH02_STAGE_EVIDENCE_LOG,
        CH03_STAGE_EVIDENCE_LOG,
        CH04_STAGE_EVIDENCE_LOG,
        CH05_STAGE_EVIDENCE_LOG,
        CH06_STAGE_EVIDENCE_LOG,
        CH07_STAGE_EVIDENCE_LOG,
        CH08_STAGE_EVIDENCE_LOG,
        CH09A_STAGE_EVIDENCE_LOG,
        CH09B_STAGE_EVIDENCE_LOG,
        CH10_STAGE_EVIDENCE_LOG
    ]:
        for stage_id in table.keys():
            _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(table.get(stage_id, [])))
    for table in [
        CH01_STAGE_LETTER_LOG,
        CH02_STAGE_LETTER_LOG,
        CH03_STAGE_LETTER_LOG,
        CH04_STAGE_LETTER_LOG,
        CH05_STAGE_LETTER_LOG,
        CH06_STAGE_LETTER_LOG,
        CH07_STAGE_LETTER_LOG,
        CH08_STAGE_LETTER_LOG,
        CH09A_STAGE_LETTER_LOG,
        CH09B_STAGE_LETTER_LOG,
        CH10_STAGE_LETTER_LOG
    ]:
        for stage_id in table.keys():
            _append_unique_lines(_unlocked_letter_entries, _format_record_entries(table.get(stage_id, [])))

func advance_step() -> bool:
    if _active_mode == CampaignState.MODE_CUTSCENE:
        var active_flow: Array[StageData] = _get_active_stage_flow()
        var next_stage_index: int = _active_stage_index + 1
        if next_stage_index >= active_flow.size():
            if _current_stage != null and _should_enter_choice_point(_current_stage.choice_point_id):
                _pending_choice_stage_index = -1
                _enter_choice_state(_current_stage.choice_point_id)
                return true
            if _active_chapter_id == CHAPTER_CH01:
                _enter_camp_state()
            elif _active_chapter_id == CHAPTER_CH02:
                _enter_chapter_two_camp()
            elif _active_chapter_id == CHAPTER_CH03:
                _enter_chapter_three_camp()
            elif _active_chapter_id == CHAPTER_CH04:
                _enter_chapter_four_camp()
            elif _active_chapter_id == CHAPTER_CH05:
                _enter_chapter_five_camp()
            elif _active_chapter_id == CHAPTER_CH06:
                _enter_chapter_six_camp()
            elif _active_chapter_id == CHAPTER_CH07:
                _enter_chapter_seven_camp()
            elif _active_chapter_id == CHAPTER_CH08:
                _enter_chapter_eight_camp()
            elif _active_chapter_id == CHAPTER_CH09A:
                _enter_chapter_nine_a_camp()
            elif _active_chapter_id == CHAPTER_CH09B:
                _enter_chapter_nine_b_camp()
            elif _active_chapter_id == CHAPTER_CH10:
                _enter_chapter_ten_resolution()
            else:
                _enter_chapter_complete_state()
            return true
        var next_stage: StageData = active_flow[next_stage_index]
        if _should_enter_choice_point(next_stage.choice_point_id):
            _pending_choice_stage_index = next_stage_index
            _enter_choice_state(next_stage.choice_point_id)
            return true
        _active_stage_index = next_stage_index
        _enter_stage(_active_stage_index)
        return true

    if _active_mode == CampaignState.MODE_CAMP:
        _advance_recovery_chapter_clock()
        if _active_chapter_id == CHAPTER_CH01:
            _enter_chapter_two_intro()
        elif _active_chapter_id == CHAPTER_CH02:
            _enter_chapter_three_intro()
        elif _active_chapter_id == CHAPTER_CH03:
            _enter_chapter_four_intro()
        elif _active_chapter_id == CHAPTER_CH04:
            _enter_chapter_five_intro()
        elif _active_chapter_id == CHAPTER_CH05:
            _enter_chapter_six_intro()
        elif _active_chapter_id == CHAPTER_CH06:
            _enter_chapter_seven_intro()
        elif _active_chapter_id == CHAPTER_CH07:
            _enter_chapter_eight_intro()
        elif _active_chapter_id == CHAPTER_CH08:
            _enter_chapter_nine_a_intro()
        elif _active_chapter_id == CHAPTER_CH09A:
            _enter_chapter_nine_b_intro()
        elif _active_chapter_id == CHAPTER_CH09B:
            _enter_chapter_ten_intro()
        else:
            _enter_chapter_complete_state()
        return true

    if _active_mode == CampaignState.MODE_DEFEAT:
        if _post_defeat_destination == "camp":
            _post_defeat_destination = ""
            _enter_camp_state()
            return true
        return false

    if _active_mode == CampaignState.MODE_CHOICE:
        return false

    if _active_mode == CampaignState.MODE_CHAPTER_INTRO:
        if _active_chapter_id == CHAPTER_CH01:
            _start_chapter_two_flow()
        elif _active_chapter_id == CHAPTER_CH02:
            _start_chapter_three_flow()
        elif _active_chapter_id == CHAPTER_CH03:
            _start_chapter_four_flow()
        elif _active_chapter_id == CHAPTER_CH04:
            _start_chapter_five_flow()
        elif _active_chapter_id == CHAPTER_CH05:
            _start_chapter_six_flow()
        elif _active_chapter_id == CHAPTER_CH06:
            _start_chapter_seven_flow()
        elif _active_chapter_id == CHAPTER_CH07:
            _start_chapter_eight_flow()
        elif _active_chapter_id == CHAPTER_CH08:
            _start_chapter_nine_a_flow()
        elif _active_chapter_id == CHAPTER_CH09A:
            _start_chapter_nine_b_flow()
        elif _active_chapter_id == CHAPTER_CH09B:
            _start_chapter_ten_flow()
        return true

    if _active_mode == CampaignState.MODE_COMPLETE:
        if _active_chapter_id == CHAPTER_CH10 and _ch10_complete_phase == &"resolution":
            _enter_chapter_ten_epilogue()
            return true

    return false

func get_state_snapshot() -> Dictionary:
    var panel_snapshot: Dictionary = {}
    if _campaign_panel != null:
        panel_snapshot = _campaign_panel.get_snapshot()

    return {
        "mode": _active_mode,
        "chapter_id": _active_chapter_id,
        "flow_index": _active_stage_index,
        "flow_total": _get_active_stage_flow().size(),
        "current_stage_id": _current_stage.stage_id if _current_stage != null else StringName(),
        "current_stage_title": _current_stage.get_display_title() if _current_stage != null else "",
        "panel_title": panel_snapshot.get("title", _current_panel_title),
        "panel_body": panel_snapshot.get("body", _current_panel_body)
    }

func get_encyclopedia_context() -> Dictionary:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return {}
    _sync_support_rank_entries()
    if _current_stage != null and _battle_controller != null and not _battle_controller.get_last_result_summary().is_empty():
        _record_enemy_encyclopedia_entries(_current_stage)
    if _active_mode == CampaignState.MODE_CAMP or _active_mode == CampaignState.MODE_COMPLETE:
        _sync_campaign_roster_encyclopedia_entries()
        progression_data.add_chapter_completed(_active_chapter_id)
    return {
        "progression_data": progression_data,
        "active_chapter_id": _active_chapter_id,
        "active_mode": _active_mode
    }

func _enter_stage(stage_index: int) -> void:
    var active_flow: Array[StageData] = _get_active_stage_flow()
    if stage_index < 0 or stage_index >= active_flow.size():
        push_warning("Stage index %d is out of bounds for active chapter flow." % stage_index)
        return

    _current_stage = active_flow[stage_index].duplicate(true)
    _apply_choice_stage_overrides(_current_stage)
    _current_stage.ally_units = _build_runtime_deployed_party(_current_stage)
    _current_stage.ally_spawns = _build_runtime_ally_spawns(_current_stage)
    _active_mode = CampaignState.MODE_BATTLE
    _defeat_payload.clear()
    _defeat_choice_options.clear()
    _defeat_choice_prompt = ""
    _post_defeat_destination = ""
    _last_memorial_scene.clear()
    _clear_panel_state()

    if _battle_controller != null:
        _battle_controller.clear_special_battle_context()
        _battle_controller.set_equipped_weapon_map(_build_runtime_weapon_map())
        _battle_controller.set_equipped_armor_map(_build_runtime_armor_map())
        _battle_controller.set_equipped_accessory_map(_build_runtime_accessory_map())
        _battle_controller.visible = true
        _battle_controller.set_stage(_current_stage)
    mode_changed.emit(_active_mode)

func _on_battle_finished(result: StringName, stage_id: StringName) -> void:
    if not _desperate_stand_context.is_empty() and stage_id == StringName(_desperate_stand_context.get("stage_id", "")):
        if result == &"victory":
            _resolve_desperate_stand_victory()
        return

    if result != &"victory":
        if _active_mode != CampaignState.MODE_DEFEAT:
            _active_mode = CampaignState.MODE_BATTLE
            mode_changed.emit(_active_mode)
        return

    if _current_stage == null or stage_id != _current_stage.stage_id:
        return

    _register_stage_support_progress(_current_stage)
    _record_enemy_encyclopedia_entries(_current_stage)
    _commit_stage_rewards(_current_stage)

    var active_flow: Array[StageData] = _get_active_stage_flow()
    if _active_stage_index >= active_flow.size() - 1:
        if _active_chapter_id == CHAPTER_CH01:
            _enter_camp_state()
        elif _active_chapter_id == CHAPTER_CH02:
            _enter_chapter_two_camp()
        elif _active_chapter_id == CHAPTER_CH03:
            _enter_chapter_three_camp()
        elif _active_chapter_id == CHAPTER_CH04:
            _enter_chapter_four_camp()
        elif _active_chapter_id == CHAPTER_CH05:
            _enter_chapter_five_camp()
        elif _active_chapter_id == CHAPTER_CH06:
            _enter_chapter_six_camp()
        elif _active_chapter_id == CHAPTER_CH07:
            _enter_chapter_seven_camp()
        elif _active_chapter_id == CHAPTER_CH08:
            _enter_chapter_eight_camp()
        elif _active_chapter_id == CHAPTER_CH09A:
            _enter_chapter_nine_a_camp()
        elif _active_chapter_id == CHAPTER_CH09B:
            _enter_chapter_nine_b_camp()
        elif _active_chapter_id == CHAPTER_CH10:
            _enter_chapter_ten_resolution()
        else:
            _enter_chapter_complete_state()
        return

    _active_mode = CampaignState.MODE_CUTSCENE
    _set_panel_state(
        CampaignState.MODE_CUTSCENE,
        _current_stage.get_display_title(),
        _build_cutscene_summary(_current_stage, active_flow[_active_stage_index + 1]),
        "Continue to Next Stage"
    )

func _on_battle_defeat(stage_id: StringName, payload: Dictionary) -> void:
    if _current_stage == null:
        return
    if not _desperate_stand_context.is_empty() and stage_id == StringName(_desperate_stand_context.get("stage_id", "")):
        _apply_full_retreat(payload)
        _post_defeat_destination = "camp"
        _enter_camp_state()
        return
    if stage_id != _current_stage.stage_id:
        return
    _defeat_payload = payload.duplicate(true)
    _enter_defeat_state()

func _on_s_rank_ally_died(unit_id: StringName, unit_name: String, support_rank: int) -> void:
    if _suppress_s_rank_memorial:
        return
    _trigger_memorial_scene(unit_id, unit_name, support_rank)

func _on_support_rank_increased(pair_id: String, new_rank: int) -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return
    if new_rank >= 3:
        progression_data.mark_support_conversation_available(pair_id, new_rank)
    progression_data.record_support_history({
        "pair": pair_id,
        "rank": new_rank,
        "chapter": String(_active_chapter_id),
        "stage_id": String(_current_stage.stage_id) if _current_stage != null else "",
        "timestamp": Time.get_unix_time_from_system(),
        "topic": SupportConversations.get_support_conversation_entry(pair_id, new_rank).get("topic", ""),
        "viewed": false,
        "consume_available": false
    })
    _sync_support_rank_entries()

func _enter_defeat_state() -> void:
    _active_mode = CampaignState.MODE_DEFEAT
    _post_defeat_destination = ""
    _defeat_choice_prompt = "The line broke. Choose how the squad survives the defeat."
    _defeat_choice_options = _build_retreat_choice_options()
    _set_panel_state(
        CampaignState.MODE_DEFEAT,
        "Retreat Resolution",
        "All allies were defeated. Full Retreat stabilizes the survivors, Sacrifice Protocol permanently removes one ally, and Desperate Stand launches a solo 3-wave hold.",
        "Continue"
    )

func _build_retreat_choice_options() -> Array[Dictionary]:
    var final_unit_id := String(_defeat_payload.get("final_ally_unit_id", "")).strip_edges()
    return [
        {
            "id": RETREAT_OPTION_FULL,
            "label": "Full Retreat",
            "hint": "All surviving allies enter recovery for 2 chapters."
        },
        {
            "id": RETREAT_OPTION_SACRIFICE,
            "label": "Sacrifice Protocol",
            "hint": "Choose one ally to hold the line and leave a memorial entry behind."
        },
        {
            "id": RETREAT_OPTION_DESPERATE,
            "label": "Desperate Stand",
            "hint": "Launch a solo 3-wave desperate battle. Victory grants +2 Badges of Heroism; defeat becomes Full Retreat.",
            "disabled": final_unit_id.is_empty()
        }
    ]

func _show_sacrifice_selection() -> void:
    var candidates: Array[StringName] = _get_sacrifice_candidate_ids()
    if candidates.is_empty():
        _apply_full_retreat(_defeat_payload)
        _post_defeat_destination = "camp"
        _enter_camp_state()
        return

    _active_mode = CampaignState.MODE_DEFEAT
    _defeat_choice_prompt = "Pick one ally to hold the line. This death is permanent."
    _defeat_choice_options.clear()
    for unit_id in candidates:
        var unit_name := _get_unit_display_name(unit_id)
        _defeat_choice_options.append({
            "id": "%s%s" % [RETREAT_OPTION_SACRIFICE_PREFIX, String(unit_id)],
            "label": unit_name,
            "hint": "Remove %s from the roster permanently and add a memorial record." % unit_name
        })
    _set_panel_state(CampaignState.MODE_DEFEAT, "Sacrifice Protocol", "One ally holds the line so the rest can return.", "Continue")

func _apply_full_retreat(payload: Dictionary = _defeat_payload) -> void:
    var progression: ProgressionData = _get_progression_data()
    if progression == null:
        return
    progression.recovering_units.clear()
    for unit_id in _get_retreat_recovering_unit_ids(payload):
        var unit_text := String(unit_id)
        if progression.has_sacrificed_unit(unit_text):
            continue
        if not progression.recovering_units.has(unit_text):
            progression.recovering_units.append(unit_text)
    progression.recover_chapter_count = 2 if not progression.recovering_units.is_empty() else 0
    _append_unique_lines(_chapter_reward_entries, ["Full Retreat: recovering allies will be unavailable for 2 chapters."])
    _normalize_deployed_party_ids()
    _autosave_progression()

func _apply_sacrifice(unit_id: String) -> void:
    var normalized_unit_id := StringName(unit_id.strip_edges())
    if normalized_unit_id == StringName() or normalized_unit_id == &"ally_rian":
        return
    var progression: ProgressionData = _get_progression_data()
    if progression == null:
        return
    var unit_text := String(normalized_unit_id)
    var unit_name := _get_unit_display_name(normalized_unit_id)
    var memorial_quote := _build_memorial_quote(_resolve_sacrifice_epitaph(normalized_unit_id, unit_name))
    progression.add_sacrificed_unit(unit_text, unit_name, memorial_quote)
    progression.set_unit_quote(unit_text, memorial_quote)
    progression.add_memorial_record(
        unit_text,
        unit_name,
        memorial_quote,
        String(_active_chapter_id),
        String(_current_stage.stage_id) if _current_stage != null else ""
    )
    progression.recovering_units.erase(unit_text)
    progression.unit_progression.erase(unit_text)
    _deployed_party_unit_ids.erase(normalized_unit_id)
    _equipped_weapon_by_unit_id.erase(unit_text)
    _equipped_armor_by_unit_id.erase(unit_text)
    _equipped_accessory_by_unit_id.erase(unit_text)
    _append_unique_lines(_chapter_reward_entries, ["Sacrifice Protocol: %s was left behind so the squad could retreat." % unit_name])
    _append_memorial_entry(normalized_unit_id, unit_name, "sacrifice_protocol")
    _post_defeat_destination = "camp"
    if _battle_controller != null and _battle_controller.bond_service != null:
        _suppress_s_rank_memorial = true
        _battle_controller.bond_service.notify_unit_died(normalized_unit_id, unit_name)
        _suppress_s_rank_memorial = false
    _show_memorial_scene(unit_text)
    _autosave_progression()

func _execute_desperate_stand() -> void:
    if _battle_controller == null or _current_stage == null:
        return
    var final_unit_id := StringName(String(_defeat_payload.get("final_ally_unit_id", "")).strip_edges())
    if final_unit_id == StringName():
        return
    var desperate_stage := _build_desperate_stand_stage(final_unit_id)
    if desperate_stage == null:
        return
    _desperate_stand_context = {
        "stage_id": String(desperate_stage.stage_id),
        "source_stage_id": String(_current_stage.stage_id),
        "final_unit_id": String(final_unit_id),
        "waves": [
            {"wave": 1, "enemy_count": 3, "boss_reinforcement": false},
            {"wave": 2, "enemy_count": 5, "boss_reinforcement": false},
            {"wave": 3, "enemy_count": 1, "boss_reinforcement": true}
        ],
        "badge_reward": 2,
        "desperate_wave_battle_triggered": true
    }
    _active_mode = CampaignState.MODE_BATTLE
    _defeat_choice_options.clear()
    _defeat_choice_prompt = ""
    _post_defeat_destination = ""
    _clear_panel_state()
    _battle_controller.configure_desperate_wave_battle(_desperate_stand_context)
    _battle_controller.set_stage(desperate_stage)
    mode_changed.emit(_active_mode)

func _build_desperate_stand_stage(final_unit_id: StringName) -> StageData:
    if _current_stage == null:
        return null
    var final_unit_data: UnitData = _get_unit_data_by_id(final_unit_id)
    if final_unit_data == null:
        return null
    var desperate_stage: StageData = _current_stage.duplicate(true)
    desperate_stage.stage_id = StringName("%s_desperate" % String(_current_stage.stage_id))
    desperate_stage.stage_title = "%s — Desperate Stand" % _current_stage.get_display_title()
    desperate_stage.choice_point_id = &""
    desperate_stage.win_condition = &"defeat_all_enemies"
    desperate_stage.loss_condition = &"all_allies_defeated"
    desperate_stage.interactive_objects.clear()
    desperate_stage.ally_units = [_build_runtime_unit_for_stage(final_unit_data, desperate_stage)]
    desperate_stage.ally_spawns = [
        _current_stage.ally_spawns[0] if not _current_stage.ally_spawns.is_empty() else Vector2i(0, max(0, desperate_stage.grid_size.y - 1))
    ]
    desperate_stage.enemy_units.clear()
    desperate_stage.enemy_spawns.clear()
    for index in range(3):
        if DESPERATE_ENEMY_SKIRMISHER != null:
            desperate_stage.enemy_units.append(DESPERATE_ENEMY_SKIRMISHER.duplicate(true))
            desperate_stage.enemy_spawns.append(Vector2i(min(desperate_stage.grid_size.x - 1, 2 + index), 0))
    desperate_stage.objective_text = "Wave 1: 3 enemies. Wave 2: 5 enemies. Wave 3: boss reinforcement."
    return desperate_stage

func _resolve_desperate_stand_victory() -> void:
    var progression: ProgressionData = _get_progression_data()
    if progression != null:
        progression.recovering_units.clear()
        progression.recover_chapter_count = 0
        progression.badges_of_heroism += int(_desperate_stand_context.get("badge_reward", 2))
    _append_unique_lines(_chapter_reward_entries, ["Desperate Stand cleared: +2 Badges of Heroism."])
    if _battle_controller != null:
        _battle_controller.clear_special_battle_context()
    _desperate_stand_context.clear()
    _autosave_progression()
    _enter_camp_state()

func _trigger_memorial_scene(unit_id: StringName, unit_name: String, support_rank: int = 0) -> void:
    var resolved_name := unit_name.strip_edges()
    if resolved_name.is_empty():
        resolved_name = _get_unit_display_name(unit_id)
    _last_memorial_scene = {
        "unit_id": String(unit_id),
        "unit_name": resolved_name,
        "support_rank": support_rank,
        "epitaph": _build_memorial_quote(_resolve_sacrifice_epitaph(unit_id, resolved_name)),
        "duration_seconds": 30.0
    }
    _append_memorial_entry(unit_id, resolved_name, "s_rank_memorial")
    _show_memorial_scene(String(unit_id))

func _append_memorial_entry(unit_id: StringName, unit_name: String, reason: String) -> void:
    var entry := "Memorial — %s (%s)" % [unit_name, reason.replace("_", " ")]
    _append_unique_lines(_unlocked_memory_entries, [entry])

func _show_memorial_scene(sacrificed_unit_id: String) -> void:
    var normalized_unit_id := StringName(sacrificed_unit_id.strip_edges())
    if normalized_unit_id == StringName():
        return
    var progression := _get_progression_data()
    var memorial_record: Dictionary = progression.get_memorial_record(String(normalized_unit_id)) if progression != null else {}
    var resolved_name := String(_last_memorial_scene.get("unit_name", "")).strip_edges()
    if resolved_name.is_empty():
        resolved_name = String(memorial_record.get("unit_name", "")).strip_edges()
    if resolved_name.is_empty():
        resolved_name = _get_unit_display_name(normalized_unit_id)
    var resolved_quote := String(_last_memorial_scene.get("epitaph", "")).strip_edges()
    if resolved_quote.is_empty():
        resolved_quote = String(memorial_record.get("epitaph", "")).strip_edges()
    if resolved_quote.is_empty():
        resolved_quote = _build_memorial_quote(_resolve_sacrifice_epitaph(normalized_unit_id, resolved_name))
    _last_memorial_scene["unit_id"] = String(normalized_unit_id)
    _last_memorial_scene["unit_name"] = resolved_name
    _last_memorial_scene["epitaph"] = resolved_quote
    _last_memorial_scene["duration_seconds"] = float(_last_memorial_scene.get("duration_seconds", 30.0))

    _active_mode = CampaignState.MODE_DEFEAT
    _defeat_choice_prompt = ""
    _defeat_choice_options.clear()
    _post_defeat_destination = "camp" if _post_defeat_destination.is_empty() else _post_defeat_destination
    _set_panel_state(
        CampaignState.MODE_DEFEAT,
        "%s Memorial" % resolved_name,
        "%s is remembered in stone before the squad breaks camp again." % resolved_name,
        "Continue"
    )
    if _campaign_panel != null:
        _campaign_panel.show_memorial_scene({
            "unit_id": String(normalized_unit_id),
            "unit_name": resolved_name,
            "quote": resolved_quote,
            "duration_seconds": float(_last_memorial_scene.get("duration_seconds", 30.0))
        })

func _on_memorial_scene_finished() -> void:
    if _active_mode != CampaignState.MODE_DEFEAT:
        return
    if _post_defeat_destination == "camp":
        _post_defeat_destination = ""
        _enter_camp_state()

func _enter_camp_state() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _post_defeat_destination = ""
    if _camp_controller != null:
        var stage_result: Dictionary = {}
        if _current_stage != null:
            stage_result = {
                "memory_entries": _variant_to_string_array(CH01_STAGE_MEMORY_LOG.get(_current_stage.stage_id, [])),
                "evidence_entries": _variant_to_string_array(CH01_STAGE_EVIDENCE_LOG.get(_current_stage.stage_id, [])),
                "letter_entries": _variant_to_string_array(CH01_STAGE_LETTER_LOG.get(_current_stage.stage_id, []))
            }
        var progression_data: ProgressionData = null
        if _battle_controller != null and _battle_controller.progression_service != null:
            progression_data = _battle_controller.progression_service.get_data()
        _camp_controller.enter_camp(&"ch01", stage_result, progression_data)
    _autosave_progression()
    _set_panel_state(
        CampaignState.MODE_CAMP,
        "CH01 Interlude Camp",
        _build_camp_summary(),
        "Next Battle"
    )

func _autosave_progression() -> void:
    if _save_service == null or _battle_controller == null:
        return
    var prog_svc = _battle_controller.progression_service
    if prog_svc == null:
        return
    var data: ProgressionData = prog_svc.get_data()
    if data != null:
        _save_service.save_progression(data, 0)  # 슬롯 0 = 자동저장

func _register_stage_support_progress(stage: StageData) -> void:
    if stage == null or _battle_controller == null or _battle_controller.bond_service == null:
        return
    for unit_variant in stage.ally_units:
        var unit_data := unit_variant as UnitData
        if unit_data == null or unit_data.unit_id == &"ally_rian":
            continue
        _battle_controller.bond_service.register_support_progress(&"ally_rian", unit_data.unit_id, _active_chapter_id, stage.stage_id)

func _should_enter_choice_point(choice_point_id: StringName) -> bool:
    if choice_point_id == StringName():
        return false
    if not CHOICE_POINT_STAGES.has(choice_point_id):
        return false
    var progression: ProgressionData = _get_progression_data()
    if progression == null:
        return true
    for entry in progression.choices_made:
        if String(entry).begins_with("%s:" % String(choice_point_id)):
            return false
    return true

func _enter_choice_state(stage_id: StringName) -> void:
    _pending_choice_stage_id = stage_id
    _active_mode = CampaignState.MODE_CHOICE
    var choice_data: Dictionary = CampaignShellDialogueCatalog.get_choice_dialogue(stage_id, _get_world_timeline_id(), _has_worldview_complete())
    var title_text: String = String(choice_data.get("title", "Critical Choice"))
    var body_text: String = String(choice_data.get("prompt", "Choose which truth the squad carries forward."))
    _set_panel_state(CampaignState.MODE_CHOICE, title_text, body_text, "")

func _make_choice(option_id: String) -> void:
    if _pending_choice_stage_id == StringName():
        return

    var normalized_option_id := option_id.strip_edges()
    if normalized_option_id.is_empty():
        return

    var progression: ProgressionData = _get_progression_data()
    if progression == null:
        return

    match _pending_choice_stage_id:
        CHOICE_CH05_CAMP:
            if normalized_option_id == "ch05_save_ledgers":
                progression.enoch_wounded = true
                progression.ledger_count = 5
                progression.world_timeline_id = "A"
            else:
                progression.enoch_wounded = false
                progression.ledger_count = 2
                if _is_world_timeline_break_choice(normalized_option_id) or normalized_option_id != "ch05_save_ledgers":
                    progression.world_timeline_id = "B"
        CHOICE_CH07_INTERLUDE:
            if normalized_option_id == "ch07_believe_mira":
                progression.mira_trust_level = 2
                progression.neri_disposition = "hostile"
            else:
                progression.mira_trust_level = -1
                progression.neri_disposition = "neutral"
        CHOICE_CH08_PRE_BOSS:
            progression.lete_early_alliance = normalized_option_id == "ch08_accept_lete"
        CHOICE_CH09A_CAMP:
            if normalized_option_id == "ch09a_public_testimony":
                progression.noah_phase2_multiplier = 2.0
                progression.melkion_awareness = true
            else:
                progression.noah_phase2_multiplier = 1.0
                progression.melkion_awareness = false
        CHOICE_CH10_PRE_FINALE:
            if normalized_option_id == "ch10_name_the_fallen":
                progression.ch10_attack_bonus = 1
                progression.ch10_defense_bonus = 0
            else:
                progression.ch10_attack_bonus = 0
                progression.ch10_defense_bonus = 1

    var choice_record := "%s:%s" % [String(_pending_choice_stage_id), normalized_option_id]
    if not progression.choices_made.has(choice_record):
        progression.choices_made.append(choice_record)

    var resolved_choice_stage_id: StringName = _pending_choice_stage_id
    var resolved_stage_index: int = _pending_choice_stage_index
    _pending_choice_stage_id = StringName()
    _pending_choice_stage_index = -1
    _autosave_progression()

    match resolved_choice_stage_id:
        CHOICE_CH05_CAMP:
            _show_chapter_five_camp_panel()
        CHOICE_CH07_INTERLUDE:
            _show_chapter_seven_camp_panel()
        CHOICE_CH09A_CAMP:
            _show_chapter_nine_a_camp_panel()
        CHOICE_CH08_PRE_BOSS, CHOICE_CH10_PRE_FINALE:
            if resolved_stage_index >= 0:
                _active_stage_index = resolved_stage_index
                _enter_stage(_active_stage_index)

func _on_choice_selected(option_id: String) -> void:
    if not _active_support_conversation.is_empty():
        _resolve_support_conversation_choice(option_id)
        return
    if _active_mode == CampaignState.MODE_DEFEAT:
        var normalized_option_id := option_id.strip_edges()
        if normalized_option_id == RETREAT_OPTION_FULL:
            _apply_full_retreat(_defeat_payload)
            _post_defeat_destination = "camp"
            _enter_camp_state()
            return
        if normalized_option_id == RETREAT_OPTION_SACRIFICE:
            _show_sacrifice_selection()
            return
        if normalized_option_id == RETREAT_OPTION_DESPERATE:
            _execute_desperate_stand()
            return
        if normalized_option_id.begins_with(RETREAT_OPTION_SACRIFICE_PREFIX):
            _apply_sacrifice(normalized_option_id.trim_prefix(RETREAT_OPTION_SACRIFICE_PREFIX))
            return
    _make_choice(option_id)

func _build_cutscene_summary(stage: StageData, next_stage: StageData) -> String:
    var lines: Array[String] = []
    if stage.clear_cutscene_id != StringName():
        lines.append("Clear cutscene: %s" % String(stage.clear_cutscene_id))
    lines.append("Stage clear: %s" % stage.get_display_title())
    _append_unique_lines(lines, _variant_to_string_array(CH01_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH02_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH03_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH04_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH05_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH06_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH07_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH08_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH09A_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH09B_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CH10_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    lines.append("Next battle: %s" % next_stage.get_display_title())
    if not stage.next_destination_summary.is_empty():
        lines.append(stage.next_destination_summary)
    return "\n".join(lines)

func _build_camp_summary() -> String:
    var lines: Array[String] = [
        "Interlude cutscene: ch01_interlude_camp",
        "Serin is now locked in as an ally for the Chapter 1 handoff.",
        "First memory fragment recovered: mem_frag_ch01_first_order.",
        "Hardren seal evidence confirms the first border trail north.",
        "Next destination: move north toward the first campaign evidence trail."
    ]

    var progression_data: ProgressionData = null
    if _battle_controller != null and _battle_controller.progression_service != null:
        progression_data = _battle_controller.progression_service.get_data()
    if progression_data != null:
        lines.append("Burden / Trust: %d / %d" % [progression_data.burden, progression_data.trust])
        lines.append("Ending tendency: %s" % String(progression_data.ending_tendency))
        lines.append("Recovered fragments: %d" % progression_data.recovered_fragments.size())
        lines.append("Recovered fragment ids: %s" % ", ".join(progression_data.get_recovered_fragment_ids()))
        lines.append("Unlocked commands: %d" % progression_data.unlocked_commands.size())
        lines.append("Unlocked command ids: %s" % ", ".join(progression_data.get_unlocked_command_ids()))

    if _current_stage != null and not _current_stage.next_destination_summary.is_empty():
        lines.append(_current_stage.next_destination_summary)
    _append_stage_memorial_summary_line(lines)

    return "\n".join(lines)

func _append_chapter_intro_dialogue(lines: Array[String], chapter_id: StringName) -> void:
    _append_unique_lines(lines, CampaignShellDialogueCatalog.get_intro_dialogue(chapter_id, _get_world_timeline_id(), _has_worldview_complete()))

func _append_chapter_interlude_dialogue(lines: Array[String], chapter_id: StringName) -> void:
    _append_unique_lines(lines, CampaignShellDialogueCatalog.get_interlude_dialogue(chapter_id, _get_world_timeline_id(), _has_worldview_complete()))

func _get_active_camp_dialogue_entries() -> Array[String]:
    if _active_chapter_id == CHAPTER_CH10:
        var resolution_lines := CampaignShellDialogueCatalog.get_resolution_dialogue(_get_world_timeline_id(), _has_worldview_complete())
        _append_stage_memorial_dialogue_entry(resolution_lines)
        return resolution_lines
    var lines: Array[String] = CampaignShellDialogueCatalog.get_interlude_dialogue(_active_chapter_id, _get_world_timeline_id(), _has_worldview_complete())
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return lines
    if _active_chapter_id == CHAPTER_CH07 and progression_data.mira_unlocked:
        _append_unique_lines(lines, CampaignShellDialogueCatalog.get_hidden_recruit_dialogue(&"mira"))
    if _active_chapter_id == CHAPTER_CH08 and progression_data.is_ally_unlocked(&"lete"):
        _append_unique_lines(lines, CampaignShellDialogueCatalog.get_hidden_recruit_dialogue(&"lete"))
    if _active_chapter_id == CHAPTER_CH09B and progression_data.melkion_unlocked:
        _append_unique_lines(lines, CampaignShellDialogueCatalog.get_hidden_recruit_dialogue(&"melkion"))
    if progression_data.worldview_complete:
        _append_unique_lines(lines, CampaignShellDialogueCatalog.get_special_dialogue(&"museum_of_truth", _get_world_timeline_id()))
    _append_stage_memorial_dialogue_entry(lines)
    return lines

func _get_progression_data() -> ProgressionData:
    if _battle_controller != null and _battle_controller.progression_service != null:
        return _battle_controller.progression_service.get_data()
    return null

func _sync_npc_personality_with_progression(reset_state: bool) -> void:
    var npc_personality = _get_npc_personality()
    var progression_data := _get_progression_data()
    if npc_personality == null:
        return
    if reset_state and npc_personality.has_method("reset"):
        npc_personality.reset(progression_data)
        return
    if npc_personality.has_method("bind_progression"):
        npc_personality.bind_progression(progression_data)

func _get_npc_personality():
    return get_node_or_null("/root/NPCPersonality")

func _get_adaptive_dialogue_filter():
    return get_node_or_null("/root/AdaptiveDialogueFilter")

func _apply_adaptive_dialogue_entries(lines: Array[String], base_key: String) -> Array[String]:
    var adapted_lines := lines.duplicate()
    var adaptive_filter = _get_adaptive_dialogue_filter()
    if adaptive_filter == null:
        return adapted_lines

    if base_key == "ch10_final":
        var leonika_line := String(adaptive_filter.get_adapted_dialogue_key("leonika", base_key)).strip_edges()
        if not leonika_line.is_empty():
            adapted_lines.insert(0, "Leonika: %s" % leonika_line)
    elif base_key.begins_with("support_"):
        var support_partner_id := _get_active_support_partner_npc_id()
        if not support_partner_id.is_empty():
            var support_variant := String(adaptive_filter.get_adapted_dialogue_key(support_partner_id, base_key)).strip_edges()
            var support_line := _build_support_variant_line(support_partner_id, support_variant)
            if not support_line.is_empty():
                adapted_lines.insert(0, support_line)

    var npc_personality = _get_npc_personality()
    if npc_personality == null or not npc_personality.has_method("has_pending_chronicle_reference") or not npc_personality.has_pending_chronicle_reference():
        return adapted_lines

    var speaker_id := _find_first_dialogue_speaker_id(adapted_lines)
    if speaker_id.is_empty():
        return adapted_lines
    var chronicle_reference: Dictionary = npc_personality.peek_pending_chronicle_reference() if npc_personality.has_method("peek_pending_chronicle_reference") else {}
    var reference_line := String(adaptive_filter.inject_chronicle_reference(speaker_id, chronicle_reference)).strip_edges()
    if reference_line.is_empty():
        return adapted_lines
    adapted_lines.insert(0, reference_line)
    if npc_personality.has_method("consume_pending_chronicle_reference"):
        npc_personality.consume_pending_chronicle_reference()
    return adapted_lines

func _get_active_support_partner_npc_id() -> String:
    var pair_id := String(_active_support_conversation.get("pair", "")).strip_edges()
    if pair_id.is_empty():
        return ""
    for raw_part in pair_id.split(":", false):
        var normalized_part := String(raw_part).strip_edges()
        if normalized_part == "ally_rian" or normalized_part == "rian":
            continue
        return normalized_part
    return ""

func _build_support_variant_line(npc_id: String, adapted_key: String) -> String:
    var speaker_name := _normalize_dialogue_speaker_name(npc_id)
    if speaker_name.is_empty():
        speaker_name = npc_id.capitalize()
    if adapted_key.ends_with("_FRIENDLY"):
        return "%s: 이번에는 당신의 선택을 믿어도 되겠군요." % speaker_name
    if adapted_key.ends_with("_HOSTILE"):
        return "%s: 아직은 당신의 뜻을 다 믿지 못하겠어요." % speaker_name
    return ""

func _find_first_dialogue_speaker_id(lines: Array[String]) -> String:
    for line in lines:
        var normalized_line := String(line).strip_edges()
        if not normalized_line.contains(":"):
            continue
        var speaker_name := normalized_line.split(":", true, 1)[0]
        var speaker_id := _normalize_dialogue_speaker_id(speaker_name)
        if speaker_id.is_empty():
            continue
        return speaker_id
    return ""

func _normalize_dialogue_speaker_id(speaker_name: String) -> String:
    match speaker_name.strip_edges().to_lower():
        "leonika":
            return "leonika"
        "rian":
            return "rian"
        "noah":
            return "noah"
        "melkion":
            return "melkion"
        "serin":
            return "serin"
        "bran":
            return "bran"
        "tia":
            return "tia"
        "enoch":
            return "enoch"
        "karl":
            return "karl"
        "lete":
            return "lete"
        "mira":
            return "mira"
        _:
            return ""

func _normalize_dialogue_speaker_name(npc_id: String) -> String:
    match npc_id.strip_edges().to_lower():
        "ally_rian", "rian":
            return "Rian"
        "ally_noah", "noah":
            return "Noah"
        "enemy_saria", "leonika":
            return "Leonika"
        "enemy_melkion", "ally_melkion_ally", "melkion":
            return "Melkion"
        "serin":
            return "Serin"
        "bran":
            return "Bran"
        "tia":
            return "Tia"
        "enoch":
            return "Enoch"
        "karl":
            return "Karl"
        "lete":
            return "Lete"
        "mira":
            return "Mira"
        _:
            return ""

func _get_world_timeline_id() -> String:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return "A"
    var normalized_timeline_id := progression_data.world_timeline_id.strip_edges().to_upper()
    return "B" if normalized_timeline_id == "B" else "A"

func _has_worldview_complete() -> bool:
    var progression_data: ProgressionData = _get_progression_data()
    return progression_data != null and progression_data.worldview_complete

func _is_world_timeline_break_choice(option_id: String) -> bool:
    var normalized_option_id := option_id.strip_edges().to_lower()
    if normalized_option_id.is_empty():
        return false
    return normalized_option_id == "ch05_save_enoch" \
        or normalized_option_id.contains("destroy") \
        or normalized_option_id.contains("reject")

func _is_unit_sacrificed(unit_id: StringName) -> bool:
    var progression_data: ProgressionData = _get_progression_data()
    return progression_data != null and progression_data.has_sacrificed_unit(String(unit_id))

func _is_unit_recovering(unit_id: StringName) -> bool:
    var progression_data: ProgressionData = _get_progression_data()
    return progression_data != null and progression_data.recovering_units.has(String(unit_id)) and progression_data.recover_chapter_count > 0

func _build_recovering_label() -> String:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null or progression_data.recover_chapter_count <= 0:
        return ""
    return "Recovering (CH%02d)" % (_chapter_rank(_active_chapter_id) + progression_data.recover_chapter_count)

func _get_unit_display_name(unit_id: StringName) -> String:
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data != null:
        return unit_data.display_name
    return String(unit_id)

func _get_retreat_deployed_unit_ids(payload: Dictionary = _defeat_payload) -> Array[StringName]:
    var unit_ids: Array[StringName] = []
    var raw_ids: Array = payload.get("deployed_ally_ids", [])
    for unit_variant in raw_ids:
        var unit_id := StringName(String(unit_variant).strip_edges())
        if unit_id == StringName() or unit_ids.has(unit_id):
            continue
        unit_ids.append(unit_id)
    if unit_ids.is_empty() and _current_stage != null:
        for unit_variant in _current_stage.ally_units:
            var unit_data := unit_variant as UnitData
            if unit_data != null and not unit_ids.has(unit_data.unit_id):
                unit_ids.append(unit_data.unit_id)
    return unit_ids

func _get_retreat_recovering_unit_ids(payload: Dictionary = _defeat_payload) -> Array[StringName]:
    var unit_ids: Array[StringName] = []
    for unit_id in _get_retreat_deployed_unit_ids(payload):
        if unit_id == &"ally_rian" or _is_unit_sacrificed(unit_id):
            continue
        unit_ids.append(unit_id)
    return unit_ids

func _get_sacrifice_candidate_ids() -> Array[StringName]:
    var unit_ids: Array[StringName] = []
    for unit_id in _get_retreat_deployed_unit_ids(_defeat_payload):
        if unit_id == &"ally_rian" or _is_unit_sacrificed(unit_id):
            continue
        unit_ids.append(unit_id)
    return unit_ids

func _advance_recovery_chapter_clock() -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null or progression_data.recover_chapter_count <= 0:
        return
    progression_data.recover_chapter_count = max(0, progression_data.recover_chapter_count - 1)
    if progression_data.recover_chapter_count == 0:
        progression_data.recovering_units.clear()

func _get_first_available_noncore_unit_id() -> StringName:
    for unit_id in CampaignCatalog.get_party_roster_order():
        if unit_id == &"ally_rian":
            continue
        if _is_recruit_unlocked(unit_id) and not _is_unit_recovering(unit_id):
            return unit_id
    return StringName()

func _sync_campaign_roster_encyclopedia_entries() -> void:
    for unit_data in _get_campaign_party_roster():
        if unit_data != null:
            _recruit_unit(unit_data.unit_id)

func _recruit_unit(unit_id: StringName) -> void:
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return
    progression_data.upsert_encyclopedia_entry(unit_id, {
        "name": unit_data.display_name,
        "type": _resolve_codex_type(unit_data),
        "chapter_introduced": _chapter_rank(_active_chapter_id),
        "stats": _build_encyclopedia_stats(unit_data),
        "quote": _build_encyclopedia_quote(unit_data),
        "support_rank": _resolve_support_rank(unit_id)
    })

func _record_enemy_encyclopedia_entries(stage: StageData) -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if stage == null or progression_data == null:
        return
    for unit_data in stage.enemy_units:
        if unit_data == null:
            continue
        progression_data.upsert_encyclopedia_entry(unit_data.unit_id, {
            "name": unit_data.display_name,
            "type": _resolve_codex_type(unit_data),
            "chapter_introduced": _chapter_rank(_active_chapter_id),
            "stats": _build_encyclopedia_stats(unit_data),
            "quote": _build_encyclopedia_quote(unit_data),
            "support_rank": 0
        })

func _sync_support_rank_entries() -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return
    for unit_key in progression_data.encyclopedia_entries.keys():
        var normalized_key := String(unit_key)
        var entry: Dictionary = progression_data.encyclopedia_entries.get(normalized_key, {})
        if String(entry.get("type", "")).begins_with("Enemy"):
            continue
        entry["support_rank"] = _resolve_support_rank(StringName(normalized_key))
        progression_data.encyclopedia_entries[normalized_key] = entry

func _resolve_support_rank(unit_id: StringName) -> int:
    if _battle_controller == null or _battle_controller.bond_service == null:
        return 0
    return _battle_controller.bond_service.get_support_rank(&"ally_rian", unit_id)

func _resolve_codex_type(unit_data: UnitData) -> String:
    if unit_data == null:
        return "Unknown"
    if unit_data.faction == "enemy":
        return "Enemy"
    if CampaignCatalog.is_hidden_recruit(unit_data.unit_id):
        return "Ally (Hidden)"
    return "Ally"

func _build_encyclopedia_stats(unit_data: UnitData) -> Dictionary:
    if unit_data == null:
        return {}
    return {
        "hp": unit_data.max_hp,
        "attack": unit_data.attack,
        "defense": unit_data.defense,
        "movement": unit_data.movement,
        "range": unit_data.attack_range
    }

func _build_encyclopedia_quote(unit_data: UnitData) -> String:
    if unit_data == null:
        return ""
    if unit_data.faction == "enemy":
        return "%s was first logged on the opposing line." % unit_data.display_name
    return "%s answered the campaign call and entered the field record." % unit_data.display_name

func _build_ch02_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch02_broken_border_fortress",
        "Hardren still stands under smoke and broken watchfires.",
        "Bran's remaining knights are boxed in behind the outer gate.",
        "Accessory and treasure loops stay locked as future Chapter 2 work; this shell only opens the next battlefield."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH02)
    return "\n".join(lines)

func _build_ch02_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch02_hardren_camp",
        "Bran joins the active roster under open suspicion.",
        "Hardren blueprint memory recovered.",
        "Tracking orders now point the march toward Greenwood."
    ]
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH02)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch03_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch03_whispering_greenwood",
        "The Greenwood trail is alive with traps, smoke, and people moving under cover.",
        "Tia's line watches the squad before choosing whether to help or hunt them."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH03)
    return "\n".join(lines)

func _build_ch03_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch03_greenwood_camp",
        "Tia joins the active roster under an uneasy truce.",
        "The forest fire order memory is now recovered.",
        "Monastery manifests point the next route toward the drowned cloister."
    ]
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH03)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch04_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch04_sunken_monastery",
        "The monastery is half drowned, and the only way forward is through controlled water and sealed records.",
        "Serin knows the place by prayer, but the surviving machinery reads like an experiment ledger."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH04)
    return "\n".join(lines)

func _build_ch04_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch04_sunken_monastery_camp",
        "Ark research memory recovered.",
        "Archive transfer evidence secured.",
        "The next route points toward the Gray Archive."
    ]
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH04)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch05_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch05_gray_archive",
        "The Gray Archive is already burning, but the surviving ledgers still point toward the core truth.",
        "Enoch is somewhere inside the sealed stacks, and the trail cannot wait."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH05)
    return "\n".join(lines)

func _build_ch05_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch05_gray_archive_camp",
        "Enoch joins the active roster.",
        "Zero memory recovered with visible record edits.",
        "Valtor siege ledgers now point the march toward the iron fortress."
    ]
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH05)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch06_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch06_valtor_iron_keep",
        "Valtor still stands as a machine of siege math, guilt, and surviving names.",
        "Bran's old fortress is now the next proof that the war was engineered in layers."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH06)
    return "\n".join(lines)

func _build_ch06_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch06_valtor_camp",
        "Valtor breach context memory recovered.",
        "Ellyor relief edicts and civilian transfers are now secured.",
        "The next route points toward the purification rite in Ellyor."
    ]
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH06)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch07_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch07_city_without_names",
        "Ellyor is turning grief into order through queues, hymns, and exhausted citizens asking to forget.",
        "Mira and Neri are somewhere inside that system, and the next forest trail already moves behind it."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH07)
    return "\n".join(lines)

func _build_ch07_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch07_ellyor_camp",
        "Karon naming memory recovered.",
        "Black-hound orders and hidden-ruin coordinates secured.",
        "The next route points toward Lete and the forest ruins."
    ]
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data != null and progression_data.mira_unlocked:
        lines.append("Mira leaves the shrine silence behind and joins the roster.")
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH07)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch08_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch08_black_hound_night",
        "The black-hound trail runs back into the forest, but now every step points toward a hidden ruin and a personal loss.",
        "Tia is no longer chasing only vengeance; she is chasing the last clear truth about what happened here."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH08)
    return "\n".join(lines)

func _build_ch08_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch08_black_hound_camp",
        "North-corridor context memory recovered.",
        "Karl outer-line orders and final transfer slips secured.",
        "Lete's black-hound route is broken, and the forest pursuit now turns into Karl's defense line around the capital plus the inner transfer route beyond it."
    ]
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data != null and progression_data.is_ally_unlocked(&"lete"):
        lines.append("Lete survives the ruin fight, abandons the black-hound oath, and joins the roster.")
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH08)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch09a_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch09a_broken_standard",
        "The capital outer line has become a filter for testimony, survivors, and anyone still carrying names into the city.",
        "Karl stands on the wrong side of that line, but not for much longer."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH09A)
    return "\n".join(lines)

func _build_ch09a_camp_summary() -> String:
    var lines: Array[String] = [
        "Part I interlude: ch09a_broken_standard_camp",
        "Returning-names memory recovered.",
        "Karl's testimony, root-archive pass, and movement ledger now open the path toward the inner archive.",
        "The next route points inward toward the root archive and the last keeper who can navigate it."
    ]
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH09A)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch09b_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch09b_abyss_of_record",
        "The root archive is no longer a military front. It is a machine for deciding what history is allowed to remain.",
        "Noah waits at its edge, and Melkion has already begun editing the battlefield itself."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH09B)
    return "\n".join(lines)

func _build_ch09b_camp_summary() -> String:
    var lines: Array[String] = [
        "Part II interlude: ch09b_record_abyss_camp",
        "Final restored memory secured as burden, not absolution.",
        "Eclipse coordinates, tower lattice, and the last decree are now in hand as concrete proof.",
        "The march now points straight to the final tower."
    ]
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data != null and progression_data.melkion_unlocked:
        lines.append("Melkion's rewritten oath holds for one battle only as the march turns toward the final tower.")
    _append_chapter_interlude_dialogue(lines, CHAPTER_CH09B)
    _append_stage_memorial_summary_line(lines)
    return "\n".join(lines)

func _build_ch10_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch10_nameless_tower",
        "The final tower is no longer about finding truth. It is about choosing what survives once the truth is known.",
        "The eclipse coordinates, tower lattice, and last decree all converge into a final ascent."
    ]
    _append_chapter_intro_dialogue(lines, CHAPTER_CH10)
    return "\n".join(lines)

func _build_ch10_resolution_summary() -> String:
    var lines: Array[String] = []
    if _is_ch10_true_resolution():
        lines = [
            "True resolution: ch10_last_name",
            "Karon falls, the bell stops, and the survivors carry each other's names out of the tower together.",
            "The tower no longer decides what counts; the remembered now decide what survives."
        ]
    else:
        lines = [
            "Final resolution: ch10_last_name",
            "Karon falls, the bell stops, and the world survives only because Rian accepts the memory burden himself.",
            "The tower no longer decides what counts, but the ending still leaves one name carrying what the others cannot."
        ]
    _append_unique_lines(lines, CampaignShellDialogueCatalog.get_resolution_dialogue(_get_world_timeline_id(), _has_worldview_complete()))
    return "\n".join(lines)

func _set_panel_state(mode: String, title_text: String, body_text: String, button_text: String) -> void:
    _current_panel_title = title_text
    _current_panel_body = body_text
    var resolved_button_text := button_text
    if mode == CampaignState.MODE_CAMP or mode == CampaignState.MODE_COMPLETE:
        var progression_data := _get_progression_data()
        if progression_data != null:
            progression_data.add_chapter_completed(_active_chapter_id)
        if mode == CampaignState.MODE_CAMP:
            _sync_campaign_roster_encyclopedia_entries()
            _sync_support_rank_entries()
            resolved_button_text = _resolve_camp_button_text(button_text)
    mode_changed.emit(mode)
    if _campaign_panel != null:
        _campaign_panel.show_state(mode, title_text, body_text, resolved_button_text, _build_panel_payload(mode))
    if _battle_controller != null:
        _battle_controller.visible = mode == CampaignState.MODE_BATTLE

func _clear_panel_state() -> void:
    _current_panel_title = ""
    _current_panel_body = ""
    if _campaign_panel != null:
        _campaign_panel.hide_panel()

func _on_advance_requested() -> void:
    if _active_mode == CampaignState.MODE_CAMP and not _has_active_support_conversation() and _has_available_support_conversation():
        _show_support_conversation()
        return
    advance_step()

func _resolve_camp_button_text(default_text: String) -> String:
    if _has_active_support_conversation():
        return default_text
    if _has_available_support_conversation():
        return "View Support Conversation"
    return default_text

func _has_active_support_conversation() -> bool:
    return not _active_support_conversation.is_empty()

func _has_available_support_conversation() -> bool:
    var progression_data := _get_progression_data()
    return progression_data != null and not progression_data.available_support_conversations.is_empty()

func _get_next_support_conversation() -> Dictionary:
    var progression_data := _get_progression_data()
    if progression_data == null or progression_data.available_support_conversations.is_empty():
        return {}
    var conversation_key := String(progression_data.available_support_conversations[0]).strip_edges()
    var key_parts := conversation_key.rsplit(":", true, 1)
    if key_parts.size() != 2:
        return {}
    return {
        "key": conversation_key,
        "pair": SupportConversations.normalize_pair_id(key_parts[0]),
        "rank": int(key_parts[1])
    }

func _show_support_conversation() -> void:
    var conversation := _get_next_support_conversation()
    if conversation.is_empty():
        return
    var pair_id := String(conversation.get("pair", "")).strip_edges()
    var support_rank := int(conversation.get("rank", 0))
    var entry: Dictionary = SupportConversations.get_support_conversation_entry(pair_id, support_rank)
    var pending_bonus := 0
    if _battle_controller != null and _battle_controller.bond_service != null:
        pending_bonus = _battle_controller.bond_service.get_pending_support_bonus(pair_id)
    var pair_names := _format_support_pair_names(pair_id)
    var prompt := String(entry.get("topic", "")).strip_edges()
    if pending_bonus > 0:
        prompt += "\n\nDeep trust lingers from the last silence: next support rank change gains +%d." % pending_bonus
    _active_support_conversation = {
        "pair": pair_id,
        "rank": support_rank,
        "topic": String(entry.get("topic", "")).strip_edges(),
        "return_title": _current_panel_title,
        "return_body": _current_panel_body,
        "prompt": prompt,
        "choice_stage_id": "support_conversation",
        "dialogue_entries": [
            "%s: %s" % [pair_names[1], String(entry.get("topic", "")).strip_edges()],
            "Rian: The answer will change what this bond becomes next."
        ],
        "presentation_cards": [{
            "eyebrow": "Support",
            "title": "%s / Rank %s" % [pair_names[0], SupportConversations.get_rank_label(support_rank)],
            "body": "Choose how Rian responds. The result changes support rank immediately and can carry trust into the next conversation."
        }],
        "options": _build_support_choice_options(entry),
        "pending_bonus": pending_bonus
    }
    _active_mode = CampaignState.MODE_CHOICE
    _set_panel_state(
        CampaignState.MODE_CHOICE,
        "Support Conversation — %s" % pair_names[0],
        String(entry.get("topic", "")).strip_edges(),
        ""
    )

func _build_support_choice_options(entry: Dictionary) -> Array[Dictionary]:
    return [
        {
            "id": SUPPORT_OPTION_A,
            "label": String(entry.get("context_A", "")).strip_edges(),
            "hint": "응원의 말 · Support Rank +1"
        },
        {
            "id": SUPPORT_OPTION_B,
            "label": String(entry.get("context_B", "")).strip_edges(),
            "hint": "솔직한 느낌 · Support Rank unchanged"
        },
        {
            "id": SUPPORT_OPTION_C,
            "label": String(entry.get("context_C", "")).strip_edges(),
            "hint": "조용히 듣기 · Support Rank -1 now, +2 next conversation"
        }
    ]

func _resolve_support_conversation_choice(option_id: String) -> void:
    if _battle_controller == null or _battle_controller.bond_service == null:
        _active_support_conversation.clear()
        return
    var pair_id := String(_active_support_conversation.get("pair", "")).strip_edges()
    var support_rank := int(_active_support_conversation.get("rank", 0))
    var normalized_option_id := option_id.strip_edges()
    var base_delta := 0
    match normalized_option_id:
        SUPPORT_OPTION_A:
            base_delta = 1
        SUPPORT_OPTION_B:
            base_delta = 0
        SUPPORT_OPTION_C:
            base_delta = -1
        _:
            return
    var bonus_applied: int = _battle_controller.bond_service.consume_pending_support_bonus(pair_id)
    var final_rank: int = _battle_controller.bond_service.modify_support_rank(pair_id, base_delta + bonus_applied)
    if normalized_option_id == SUPPORT_OPTION_C:
        _battle_controller.bond_service.queue_next_support_bonus(pair_id, SUPPORT_PENDING_BONUS)
    var progression_data := _get_progression_data()
    if progression_data != null:
        progression_data.record_support_history({
            "pair": pair_id,
            "rank": support_rank,
            "chapter": String(_active_chapter_id),
            "stage_id": String(_current_stage.stage_id) if _current_stage != null else "",
            "timestamp": Time.get_unix_time_from_system(),
            "topic": String(_active_support_conversation.get("topic", "")).strip_edges(),
            "selected_option": normalized_option_id,
            "selected_text": _resolve_support_choice_label(normalized_option_id),
            "base_delta": base_delta,
            "bonus_applied": bonus_applied,
            "rank_after": final_rank,
            "viewed": true,
            "consume_available": true
        })
    _sync_support_rank_entries()
    _autosave_progression()
    var return_title := String(_active_support_conversation.get("return_title", _current_panel_title))
    var return_body := String(_active_support_conversation.get("return_body", _current_panel_body))
    _active_support_conversation.clear()
    _active_mode = CampaignState.MODE_CAMP
    _set_panel_state(CampaignState.MODE_CAMP, return_title, return_body, "Next Battle")

func _resolve_support_choice_label(option_id: String) -> String:
    for option in _variant_to_dictionary_array(_active_support_conversation.get("options", [])):
        if String(option.get("id", "")).strip_edges() == option_id.strip_edges():
            return String(option.get("label", "")).strip_edges()
    return option_id.strip_edges()

func _format_support_pair_names(pair_id: String) -> Array[String]:
    var normalized_pair := SupportConversations.normalize_pair_id(pair_id)
    var pair_names: Array[String] = []
    for unit_id in normalized_pair.split(":", false):
        pair_names.append(SupportConversations.get_unit_display_name(unit_id))
    if pair_names.size() < 2:
        return ["Rian / Ally", "Ally"]
    pair_names.sort()
    return ["%s / %s" % [pair_names[0], pair_names[1]], pair_names[1] if pair_names[0] == "Rian" else pair_names[0]]

func _enter_chapter_two_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH02 Broken Border Fortress",
        _build_ch02_intro_summary(),
        "Enter Border Smoke"
    )

func _start_chapter_two_flow() -> void:
    _active_chapter_id = CHAPTER_CH02
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_three_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH03 Whispering Greenwood",
        _build_ch03_intro_summary(),
        "Enter Lost Forest"
    )

func _start_chapter_three_flow() -> void:
    _active_chapter_id = CHAPTER_CH03
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_four_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH04 Sunken Monastery",
        _build_ch04_intro_summary(),
        "Enter Flooded Cloister"
    )

func _start_chapter_four_flow() -> void:
    _active_chapter_id = CHAPTER_CH04
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_five_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH05 Gray Archive",
        _build_ch05_intro_summary(),
        "Enter Ash Gate"
    )

func _start_chapter_five_flow() -> void:
    _active_chapter_id = CHAPTER_CH05
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_six_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH06 Iron Keep of Valtor",
        _build_ch06_intro_summary(),
        "Enter Beyond the Smoke"
    )

func _start_chapter_six_flow() -> void:
    _active_chapter_id = CHAPTER_CH06
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_seven_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH07 City Without Names",
        _build_ch07_intro_summary(),
        "Enter Blank Market"
    )

func _start_chapter_seven_flow() -> void:
    _active_chapter_id = CHAPTER_CH07
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_eight_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH08 Night of the Black Hounds",
        _build_ch08_intro_summary(),
        "Enter Vanished Trail"
    )

func _start_chapter_eight_flow() -> void:
    _active_chapter_id = CHAPTER_CH08
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_nine_a_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH09A Broken Standard",
        _build_ch09a_intro_summary(),
        "Enter Outer Defense Line"
    )

func _start_chapter_nine_a_flow() -> void:
    _active_chapter_id = CHAPTER_CH09A
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_nine_b_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH09B Abyss of Record",
        _build_ch09b_intro_summary(),
        "Enter Root Gate"
    )

func _start_chapter_nine_b_flow() -> void:
    _active_chapter_id = CHAPTER_CH09B
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_ten_intro() -> void:
    _ch10_complete_phase = StringName()
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH10 Nameless Tower",
        _build_ch10_intro_summary(),
        "Enter Eclipse Eve"
    )

func _start_chapter_ten_flow() -> void:
    _active_chapter_id = CHAPTER_CH10
    _active_stage_index = 0
    _ch10_complete_phase = StringName()
    _enter_stage(_active_stage_index)

func _enter_chapter_two_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH02 Hardren Interlude", _build_ch02_camp_summary(), "Next Battle")

func _enter_chapter_three_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH03 Greenwood Interlude", _build_ch03_camp_summary(), "Next Battle")

func _enter_chapter_four_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH04 Monastery Interlude", _build_ch04_camp_summary(), "Next Battle")

func _enter_chapter_five_camp() -> void:
    if _current_stage != null and _current_stage.choice_point_id == CHOICE_CH05_CAMP and _should_enter_choice_point(CHOICE_CH05_CAMP):
        _pending_choice_stage_index = -1
        _enter_choice_state(CHOICE_CH05_CAMP)
        return

    _show_chapter_five_camp_panel()

func _show_chapter_five_camp_panel() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH05 Archive Interlude", _build_ch05_camp_summary(), "Next Battle")

func _enter_chapter_six_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH06 Valtor Interlude", _build_ch06_camp_summary(), "Next Battle")

func _enter_chapter_seven_camp() -> void:
    if _current_stage != null and _current_stage.choice_point_id == CHOICE_CH07_INTERLUDE and _should_enter_choice_point(CHOICE_CH07_INTERLUDE):
        _pending_choice_stage_index = -1
        _enter_choice_state(CHOICE_CH07_INTERLUDE)
        return

    _show_chapter_seven_camp_panel()

func _show_chapter_seven_camp_panel() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH07 Ellyor Interlude", _build_ch07_camp_summary(), "Next Battle")

func _enter_chapter_eight_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH08 Black Hound Interlude", _build_ch08_camp_summary(), "Next Battle")

func _enter_chapter_nine_a_camp() -> void:
    if _current_stage != null and _current_stage.choice_point_id == CHOICE_CH09A_CAMP and _should_enter_choice_point(CHOICE_CH09A_CAMP):
        _pending_choice_stage_index = -1
        _enter_choice_state(CHOICE_CH09A_CAMP)
        return

    _show_chapter_nine_a_camp_panel()

func _show_chapter_nine_a_camp_panel() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH09A Broken Standard Interlude", _build_ch09a_camp_summary(), "Next Battle")

func _enter_chapter_nine_b_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH09B Record Abyss Interlude", _build_ch09b_camp_summary(), "Next Battle")

func _enter_chapter_ten_resolution() -> void:
    _ch10_finale_resolution()
    _attach_closest_bond_to_final_result()
    _ch10_complete_phase = &"resolution"
    _active_mode = CampaignState.MODE_COMPLETE
    _set_panel_state(
        CampaignState.MODE_COMPLETE,
        "CH10 True Resolution" if _is_ch10_true_resolution() else "CH10 Final Resolution",
        _build_ch10_resolution_summary(),
        "Continue to Epilogue"
    )
    _autosave_progression()

func _ch10_finale_resolution() -> void:
    var progression: ProgressionData = _get_progression_data()
    if progression == null or not _is_ch10_true_resolution():
        return
    _award_badge(progression, "ending:true_resolution", 10, "Badge of Heroism +10 — the true resolution has been secured.")

func _attach_closest_bond_to_final_result() -> void:
    if _battle_controller == null:
        return
    var closest_bond: Dictionary = _build_closest_bond_summary()
    if closest_bond.is_empty():
        return
    _battle_controller.last_result_summary["closest_bond"] = closest_bond
    if _battle_controller.hud != null and _battle_controller.hud.result_screen != null:
        _battle_controller.hud.result_screen.show_result(_battle_controller.get_last_result_summary())

func _build_closest_bond_summary() -> Dictionary:
    if _battle_controller == null or _battle_controller.bond_service == null:
        return {}
    var best_pair: String = ""
    var best_rank: int = -1
    var best_battles: int = -1
    for companion_id: StringName in _battle_controller.bond_service.COMPANION_IDS:
        var rank: int = _battle_controller.bond_service.get_support_rank(&"ally_rian", companion_id)
        var battles_together: int = _battle_controller.bond_service.get_battles_together(&"ally_rian", companion_id)
        var pair_id := "%s:%s" % [String(&"ally_rian"), String(companion_id)]
        if rank > best_rank or (rank == best_rank and battles_together > best_battles):
            best_pair = pair_id
            best_rank = rank
            best_battles = battles_together
    if best_pair.is_empty() or best_rank < 0:
        return {}
    return {
        "pair": best_pair,
        "rank": best_rank,
        "battles_together": max(best_battles, 0)
    }

func _enter_chapter_ten_epilogue() -> void:
    _ch10_complete_phase = &"epilogue"
    _active_mode = CampaignState.MODE_COMPLETE
    _set_panel_state(
        CampaignState.MODE_COMPLETE,
        "CH10 True Epilogue" if _is_ch10_true_resolution() else "CH10 Epilogue",
        _build_ch10_epilogue_summary(),
        "Complete"
    )

func _enter_chapter_complete_state() -> void:
    _active_mode = CampaignState.MODE_COMPLETE
    var title_text: String = "Chapter Flow Complete"
    var body_text: String = "The active chapter shell is complete and ready for the next destination."
    if _active_chapter_id == CHAPTER_CH02:
        title_text = "Chapter 2 Shell Complete"
        body_text = "The Hardren shell is complete and ready for Greenwood."
    elif _active_chapter_id == CHAPTER_CH03:
        title_text = "Chapter 3 Shell Complete"
        body_text = "The Greenwood shell is complete and ready for the drowned monastery."
    elif _active_chapter_id == CHAPTER_CH04:
        title_text = "Chapter 4 Shell Complete"
        body_text = "The Sunken Monastery shell is complete and ready for the Gray Archive."
    elif _active_chapter_id == CHAPTER_CH05:
        title_text = "Chapter 5 Shell Complete"
        body_text = "The Gray Archive shell is complete and ready for Valtor."
    elif _active_chapter_id == CHAPTER_CH06:
        title_text = "Chapter 6 Shell Complete"
        body_text = "The Valtor shell is complete and ready for Ellyor."
    elif _active_chapter_id == CHAPTER_CH07:
        title_text = "Chapter 7 Shell Complete"
        body_text = "The Ellyor shell is complete and ready for the black-hound pursuit."
    elif _active_chapter_id == CHAPTER_CH08:
        title_text = "Chapter 8 Shell Complete"
        body_text = "The black-hound shell is complete and ready for Karl's outer line."
    elif _active_chapter_id == CHAPTER_CH09A:
        title_text = "Chapter 9A Shell Complete"
        body_text = "The outer-line shell is complete and ready for the root archive."
    elif _active_chapter_id == CHAPTER_CH09B:
        title_text = "Chapter 9B Shell Complete"
        body_text = "The root-archive shell is complete and ready for the final tower."
    elif _active_chapter_id == CHAPTER_CH10:
        title_text = "Chapter 10 Shell Complete"
        body_text = "The final tower shell is complete and the campaign has reached resolution."
    _set_panel_state(CampaignState.MODE_COMPLETE, title_text, body_text, "Complete")

func _get_active_stage_flow() -> Array[StageData]:
    return CampaignChapterRegistry.get_stage_flow(_active_chapter_id)

func _build_panel_payload(mode: String) -> Dictionary:
    var party_entries: Array[String] = []
    var party_details: Array[Dictionary] = []
    var inventory_entries: Array[String] = []
    var memory_entries: Array[String] = []
    var evidence_entries: Array[String] = []
    var letter_entries: Array[String] = []
    var dialogue_entries: Array[String] = []
    var presentation_cards: Array[Dictionary] = []
    var museum_data: Dictionary = {}
    var camp_progression_alerts: Array[String] = []
    var choice_stage_id: StringName = StringName()
    var choice_prompt: String = ""
    var choice_options: Array[Dictionary] = []
    var progression_data := _get_progression_data()
    if _battle_controller != null:
        party_entries = _battle_controller.get_party_summary_lines()
        party_details = _battle_controller.get_party_detail_entries()
        inventory_entries = _battle_controller.get_inventory_entries()
    if mode != CampaignState.MODE_BATTLE:
        party_entries = _build_campaign_party_summary_lines()
        party_details = _build_campaign_party_detail_entries()
    inventory_entries = _merge_unique_lines(_chapter_reward_entries, inventory_entries)
    inventory_entries = _merge_unique_lines(inventory_entries, _build_weapon_inventory_lines())
    inventory_entries = _merge_unique_lines(inventory_entries, _build_armor_inventory_lines())
    inventory_entries = _merge_unique_lines(inventory_entries, _build_accessory_inventory_lines())
    memory_entries = _unlocked_memory_entries.duplicate()
    evidence_entries = _unlocked_evidence_entries.duplicate()
    letter_entries = _unlocked_letter_entries.duplicate()
    if mode == CampaignState.MODE_CAMP:
        dialogue_entries = _get_active_camp_dialogue_entries()
        presentation_cards = _build_camp_presentation_cards()
        museum_data = _build_museum_panel_data(mode)
        if _camp_controller != null:
            var camp_summary := _camp_controller.get_camp_summary()
            if not camp_summary.is_empty():
                camp_progression_alerts = _merge_unique_lines(camp_progression_alerts, [
                    "Burden %d / Trust %d" % [int(camp_summary.get("burden", 0)), int(camp_summary.get("trust", 0))],
                    "Fragments %d / Commands %d" % [int(camp_summary.get("recovered_fragments", 0)), int(camp_summary.get("unlocked_commands", 0))]
                ])
                var memorial_summary := String(camp_summary.get("memorial_summary", "")).strip_edges()
                if not memorial_summary.is_empty():
                    camp_progression_alerts = _merge_unique_lines(camp_progression_alerts, [memorial_summary])
                var memorial_dialogue_entry := String(camp_summary.get("memorial_dialogue_entry", "")).strip_edges()
                if not memorial_dialogue_entry.is_empty() and not dialogue_entries.has(memorial_dialogue_entry):
                    dialogue_entries.append(memorial_dialogue_entry)
        if progression_data != null and progression_data.worldview_complete:
            camp_progression_alerts = _merge_unique_lines(camp_progression_alerts, ["Museum of Truth unlocked"])
    elif mode == CampaignState.MODE_CHOICE:
        if _has_active_support_conversation():
            choice_stage_id = &"support_conversation"
            choice_prompt = String(_active_support_conversation.get("prompt", _current_panel_body))
            choice_options = _variant_to_dictionary_array(_active_support_conversation.get("options", []))
            dialogue_entries = _variant_to_string_array(_active_support_conversation.get("dialogue_entries", []))
            presentation_cards = _variant_to_dictionary_array(_active_support_conversation.get("presentation_cards", []))
        else:
            choice_stage_id = _pending_choice_stage_id
            var choice_data: Dictionary = CampaignShellDialogueCatalog.get_choice_dialogue(choice_stage_id, _get_world_timeline_id(), _has_worldview_complete())
            choice_prompt = String(choice_data.get("prompt", _current_panel_body))
            choice_options = _variant_to_dictionary_array(choice_data.get("options", []))
            dialogue_entries = _variant_to_string_array(choice_data.get("dialogue_entries", []))
    elif mode == CampaignState.MODE_DEFEAT:
        choice_prompt = _defeat_choice_prompt
        choice_options = _defeat_choice_options.duplicate(true)
        if not _last_memorial_scene.is_empty():
            dialogue_entries = ["Rian: We will carry %s forward." % String(_last_memorial_scene.get("unit_name", "the fallen"))]
        presentation_cards = _build_defeat_presentation_cards()
    elif mode == CampaignState.MODE_COMPLETE and _active_chapter_id == CHAPTER_CH10:
        museum_data = _build_museum_panel_data(mode)
        if _ch10_complete_phase == &"epilogue":
            dialogue_entries = _build_ch10_epilogue_dialogue()
            presentation_cards = _build_ch10_epilogue_presentation_cards()
        else:
            dialogue_entries = CampaignShellDialogueCatalog.get_resolution_dialogue(_get_world_timeline_id(), _has_worldview_complete())
            presentation_cards = _build_resolution_presentation_cards()

    var adaptive_dialogue_key := ""
    if mode == CampaignState.MODE_CAMP and _active_chapter_id == CHAPTER_CH10:
        adaptive_dialogue_key = "ch10_final"
    elif mode == CampaignState.MODE_COMPLETE and _active_chapter_id == CHAPTER_CH10 and _ch10_complete_phase != &"epilogue":
        adaptive_dialogue_key = "ch10_final"
    elif mode == CampaignState.MODE_CHOICE and _has_active_support_conversation():
        var support_rank := int(_active_support_conversation.get("rank", 0))
        if support_rank >= 5:
            adaptive_dialogue_key = "support_a"
        elif support_rank >= 4:
            adaptive_dialogue_key = "support_b"
        else:
            adaptive_dialogue_key = "support_c"
    dialogue_entries = _apply_adaptive_dialogue_entries(dialogue_entries, adaptive_dialogue_key)

    var alerts: Array[String] = []
    var recommendation := "Review the current state and continue when ready."
    var active_section := CampaignPanel.SECTION_SUMMARY
    var selected_party_unit_id := ""
    var section_badges: Dictionary = {}

    match mode:
        CampaignState.MODE_CUTSCENE:
            alerts = ["Battle clear", "Next stage unlocked"]
            recommendation = "Read the handoff, check party readiness, then continue to the next stage."
        CampaignState.MODE_CAMP:
            alerts = _build_camp_alerts(memory_entries, evidence_entries, letter_entries, inventory_entries)
            alerts = _merge_unique_lines(alerts, camp_progression_alerts)
            if _has_available_support_conversation():
                alerts = _merge_unique_lines(alerts, ["Support conversation ready"])
            recommendation = _build_camp_recommendation(memory_entries, evidence_entries, letter_entries, inventory_entries)
            if progression_data != null and progression_data.worldview_complete:
                recommendation = "Open Summary to review the Museum of Truth before advancing the campaign."
            if _has_available_support_conversation():
                recommendation = "Open the support conversation before moving to the next battle."
            active_section = CampaignPanel.SECTION_RECORDS
            section_badges = _build_camp_section_badges(party_entries, inventory_entries, memory_entries, evidence_entries, letter_entries)
            if progression_data != null and progression_data.worldview_complete:
                section_badges[CampaignPanel.SECTION_SUMMARY] = "MUSEUM"
        CampaignState.MODE_CHOICE:
            alerts = ["Critical decision", "Two consequences available"]
            recommendation = "Read both outcomes, then lock the route that fits this campaign state."
            active_section = CampaignPanel.SECTION_SUMMARY
        CampaignState.MODE_DEFEAT:
            alerts = ["Battle lost", "Retreat consequences pending"]
            recommendation = "Pick the least damaging route for the roster before advancing the campaign loop."
            active_section = CampaignPanel.SECTION_SUMMARY
        CampaignState.MODE_COMPLETE:
            alerts = ["Chapter handoff complete"]
            if _active_chapter_id == CHAPTER_CH10:
                if _ch10_complete_phase == &"epilogue":
                    recommendation = "The final tower has fallen. Review the epilogue shell before closing the clear state."
                else:
                    recommendation = "The final tower resolution is complete. Review the ending state and epilogue route."
            else:
                recommendation = "The chapter shell is complete and ready for the next destination."
        _:
            alerts = ["Battle state active"]
            recommendation = "Complete the battle objective to unlock the next camp or story step."

    if _campaign_panel != null:
        var panel_snapshot := _campaign_panel.get_snapshot()
        if String(panel_snapshot.get("mode", "")) == mode:
            active_section = String(panel_snapshot.get("active_section", active_section))
            selected_party_unit_id = String(panel_snapshot.get("selected_party_unit_id", ""))

    return {
        "flow_label": _build_panel_flow_label(mode),
        "recommendation": recommendation,
        "party_entries": party_entries,
        "party_details": party_details,
        "honor_entries": _build_honor_roll_entries(),
        "inventory_entries": inventory_entries,
        "memory_entries": memory_entries,
        "evidence_entries": evidence_entries,
        "letter_entries": letter_entries,
        "alerts": alerts,
        "dialogue_entries": dialogue_entries,
        "presentation_cards": presentation_cards,
        "museum_data": museum_data,
        "choice_stage_id": String(choice_stage_id),
        "choice_prompt": choice_prompt,
        "choice_options": choice_options,
        "active_section": active_section,
        "selected_party_unit_id": selected_party_unit_id,
        "section_badges": section_badges,
        "deployment_limit": _get_deployment_limit(),
        "deployed_party_unit_ids": _stringify_unit_ids(_deployed_party_unit_ids),
        "locked_party_unit_ids": ["ally_rian"],
        "available_weapon_entries": _build_weapon_inventory_lines(),
        "available_armor_entries": _build_armor_inventory_lines(),
        "available_accessory_entries": _build_accessory_inventory_lines()
    }

func _build_panel_flow_label(mode: String) -> String:
    match mode:
        CampaignState.MODE_BATTLE:
            return "Battle active -> Objective unresolved -> Camp"
        CampaignState.MODE_CUTSCENE:
            return "Battle clear -> Story handoff -> Next stage"
        CampaignState.MODE_CAMP:
            return "Battle clear -> Camp review -> Next battle"
        CampaignState.MODE_CHOICE:
            return "Decision locked -> Consequence applied -> Campaign resumes"
        CampaignState.MODE_DEFEAT:
            return "Battle lost -> Retreat decision -> Recovery or memorial"
        CampaignState.MODE_CHAPTER_INTRO:
            return "Camp exit -> Mission brief -> Deploy"
        CampaignState.MODE_COMPLETE:
            return "Chapter complete -> Await next destination"
        _:
            return "Loop state active"

func _build_camp_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []

    if _active_chapter_id == CHAPTER_CH01:
        cards.append({
            "eyebrow": "Ally",
            "title": "Serin Steps Into The Line",
            "body": "Serin is no longer a temporary escort. The camp handoff now treats her as a full ally tied directly to the next route."
        })
        cards.append({
            "eyebrow": "Memory",
            "title": "First Order Surfaces",
            "body": "The first recovered command fragment confirms that Rian's battlefield instincts are tied to a real chain of orders, not only instinct."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Hardren Seal Points North",
            "body": "The recovered seal and route evidence now anchor the border pursuit. The next handoff is driven by proof, not guesswork."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH02:
        cards.append({
            "eyebrow": "Ally",
            "title": "Bran Holds The Line",
            "body": "Bran's distrust remains, but the fortress handoff locks him into the active roster and shifts the squad into a harder military rhythm."
        })
        cards.append({
            "eyebrow": "Memory",
            "title": "Hardren Routes Feel Familiar",
            "body": "Rian reads fortress lanes too quickly for a stranger, and the campaign now frames that knowledge as a concrete warning sign."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH03:
        cards.append({
            "eyebrow": "Ally",
            "title": "Tia Tests The Party",
            "body": "The Greenwood handoff turns Tia from a wary forest contact into a rostered ally with her own read on the route ahead."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "The Fire Was Planned",
            "body": "The basin route is no longer only wilderness travel. The event handoff now frames the wildfire residue as proof of deliberate command."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH04:
        cards.append({
            "eyebrow": "Memory",
            "title": "Ark Research Resurfaces",
            "body": "The monastery handoff turns recovered research into an explicit transition card, making the experiment trail feel like evidence rather than flavor text."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Gray Archive Route Confirmed",
            "body": "Transfer ledgers and seals now point cleanly toward the Gray Archive, so the next chapter handoff reads like a deliberate chase of records."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH05:
        cards.append({
            "eyebrow": "Ally",
            "title": "Enoch Names Zero",
            "body": "The archive handoff now treats Enoch's arrival and the first explicit naming of Zero as a runtime reveal rather than a plain summary bullet."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Valtor Ledgers Point Forward",
            "body": "Siege ledgers and surviving-knight rolls are surfaced as a concrete handoff card that carries the march directly toward the iron fortress."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH06:
        cards.append({
            "eyebrow": "Memory",
            "title": "Valtor Breach Remembered",
            "body": "The fortress breach memory is now framed as a deliberate handoff card so the next chapter reads like a military escalation, not only a text recap."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Ellyor Relief Route Opens",
            "body": "Relief edicts and civilian transfer records now point cleanly toward Ellyor, making the city transition explicit in camp."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH07:
        cards.append({
            "eyebrow": "Evidence",
            "title": "Black-Hound Orders Surface",
            "body": "The nameless-city handoff now frames the recovered black-hound orders as the chapter's main proof object instead of leaving them buried in the summary paragraph."
        })
        cards.append({
            "eyebrow": "Route",
            "title": "The Forest Trail Turns Back",
            "body": "The capital route now explicitly bends back toward the forest ruins, so the next hunt reads as a sharp tactical turn instead of a vague continuation."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH08:
        cards.append({
            "eyebrow": "Defense",
            "title": "Karl's Outer Line Identified",
            "body": "The black-hound pursuit now hands off into Karl's outer line through a dedicated presentation card, making the strategic pivot visible at a glance."
        })
        cards.append({
            "eyebrow": "Hunt",
            "title": "Lete's Route Confirmed",
            "body": "The forest and ruin evidence now resolves into a named pursuit path, tying the chapter's end cleanly into the next defense front."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH09A:
        cards.append({
            "eyebrow": "Ally",
            "title": "Karl Opens The Root Route",
            "body": "Karl's testimony, root-archive pass, and movement ledger now land as a dedicated transition card, making his alliance feel like a structural shift in the campaign."
        })
        cards.append({
            "eyebrow": "Archive",
            "title": "Discarded Officers Are Named",
            "body": "The route into the inner archive now carries Karl's witness and the discarded-officer ledger trail as an explicit handoff object."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH09B:
        cards.append({
            "eyebrow": "Ally",
            "title": "Noah Makes The Final Memory Hold",
            "body": "Noah's handoff frames the restored memory as burden, not absolution, so the finale lands as something Rian must carry forward."
        })
        cards.append({
            "eyebrow": "Destination",
            "title": "The March To The Final Tower Starts",
            "body": "Eclipse coordinates, tower lattice, and the last decree now read as concrete proof, turning the camp handoff into a committed march on the final tower."
        })
    var terrain_memory = get_node_or_null("/root/TerrainMemory")
    if terrain_memory != null and terrain_memory.has_method("get_persistent_markers"):
        for marker in terrain_memory.get_persistent_markers():
            cards.append({
                "eyebrow": "전장의자국",
                "title": String(marker.get("chapter_name", String(marker.get("chapter_id", "")).to_upper())),
                "body": "%d회 방문 · 마지막 방문 %s" % [
                    int(marker.get("visit_count", 0)),
                    String(marker.get("last_visit_date", "")).strip_edges()
                ]
            })
    return cards

func _build_museum_panel_data(mode: String) -> Dictionary:
    var progression_data := _get_progression_data()
    if progression_data == null:
        return {}
    var terrain_memory = get_node_or_null("/root/TerrainMemory")
    var terrain_museum_location := ""
    var terrain_markers: Array[Dictionary] = []
    if terrain_memory != null and terrain_memory.has_method("get_museum_location"):
        terrain_museum_location = String(terrain_memory.get_museum_location()).strip_edges()
    if terrain_memory != null and terrain_memory.has_method("get_persistent_markers"):
        terrain_markers = terrain_memory.get_persistent_markers()
    var fragment_ids := progression_data.get_worldview_fragment_ids()
    var terrain_museum_visible := not terrain_museum_location.is_empty() and (mode == CampaignState.MODE_CAMP or mode == CampaignState.MODE_COMPLETE)
    var terrain_museum_cards: Array[Dictionary] = []
    if terrain_museum_visible:
        for marker in terrain_markers:
            if String(marker.get("chapter_id", "")).strip_edges() != terrain_museum_location:
                continue
            terrain_museum_cards.append({
                "speaker": "전장의museum",
                "name": String(marker.get("chapter_name", terrain_museum_location.to_upper())),
                "description": "%d회 되밟은 전장" % int(marker.get("visit_count", 0)),
                "dialogue": "최근 흔적: %s" % String(marker.get("last_visit_date", "")).strip_edges()
            })
            break
    var worldview_visible := progression_data.worldview_complete and (mode == CampaignState.MODE_CAMP or mode == CampaignState.MODE_COMPLETE)
    var cards: Array[Dictionary] = []
    for entry in CampaignShellDialogueCatalog.get_worldview_fragment_cards(fragment_ids, _get_world_timeline_id()):
        cards.append(entry)
    for entry in terrain_museum_cards:
        cards.append(entry)
    return {
        "visible": worldview_visible or terrain_museum_visible,
        "complete": progression_data.worldview_complete or terrain_museum_visible,
        "title": "Museum of Truth" if worldview_visible else "전장의museum",
        "status": "Worldview Fragments %d/3 collected" % fragment_ids.size() if worldview_visible else "%s 방문 기록 보존" % terrain_museum_location.to_upper(),
        "badge": "Hidden Chapter Unlocked" if progression_data.worldview_complete else ("Most Visited Battlefield" if terrain_museum_visible else ""),
        "cards": cards
    }

func _build_defeat_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = [
        {
            "eyebrow": "Retreat",
            "title": "Full Retreat",
            "body": "All surviving allies enter recovery for two chapters and return later."
        },
        {
            "eyebrow": "Cost",
            "title": "Sacrifice Protocol",
            "body": "One ally holds the line permanently and leaves behind a memorial record."
        },
        {
            "eyebrow": "Gamble",
            "title": "Desperate Stand",
            "body": "A solo 3-wave last stand can reverse the collapse and earn +2 Badges of Heroism."
        }
    ]
    if not _last_memorial_scene.is_empty():
        cards.clear()
        cards.append({
            "eyebrow": "Memorial",
            "title": "%s Remembered" % String(_last_memorial_scene.get("unit_name", "The Fallen")),
            "body": String(_last_memorial_scene.get("epitaph", "The squad records the loss before the march continues."))
        })
    return cards

func _build_resolution_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _active_chapter_id == CHAPTER_CH10:
        if _is_ch10_true_resolution():
            cards.append({
                "eyebrow": "True Resolution",
                "title": "The Bell Falls Silent",
                "body": "Karon falls, the bell stops, and the tower loses its right to decide what survives."
            })
            cards.append({
                "eyebrow": "Names",
                "title": "The Survivors Carry Each Other Forward",
                "body": "The final state now reads as a true ending: the surviving names are carried out together instead of merely preserved in summary."
            })
        else:
            cards.append({
                "eyebrow": "Resolution",
                "title": "The Bell Falls Silent",
                "body": "Karon falls, the bell stops, and the tower loses its right to decide what survives, but the cost settles onto Rian alone."
            })
            cards.append({
                "eyebrow": "Burden",
                "title": "One Name Bears The Weight",
                "body": "The normal ending now keeps the bittersweet route: the world survives, but Rian carries the surviving burden away from the others."
            })
    return cards

func _build_ch10_epilogue_summary() -> String:
    var lines: Array[String] = []
    if _is_ch10_true_resolution():
        lines = [
            "CH10 epilogue: the bell is silent, the burden is shared, and the survivors choose to remember together.",
            "The tower no longer edits what remains; the party walks out carrying names, scars, and the work of rebuilding."
        ]
    else:
        lines = [
            "CH10 epilogue: the bell is silent, but the last weight still settles onto Rian after the tower falls.",
            "The others keep their names and the world keeps moving, yet the ending stays exact about what one survivor must remember for everyone else."
        ]
    return "\n".join(lines)

func _build_ch10_epilogue_dialogue() -> Array[String]:
    var lines: Array[String] = []
    if _is_ch10_true_resolution():
        lines = [
            "Serin: \"It did not end here. We kept enough of each other to walk back out.\"",
            "Noah: \"This time memory left people standing.\"",
            "Neri: \"My name is Neri. So please, do not forget any of us.\""
        ]
    else:
        lines = [
            "Serin: \"It was not a clean ending. It was one we managed to leave behind.\"",
            "Noah: \"The names stayed. That has to be enough to carry forward.\"",
            "Neri: \"My name is Neri. So please, do not forget any of us.\""
        ]
    if _has_worldview_complete():
        _append_unique_lines(lines, CampaignShellDialogueCatalog.get_special_dialogue(&"truth_annotation", _get_world_timeline_id()))
    return lines

func _build_ch10_epilogue_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _is_ch10_true_resolution():
        cards.append({
            "eyebrow": "Aftermath",
            "title": "What Was Left Walks Forward Together",
            "body": "The tower is done, the bell is gone silent, and the survivors carry the remaining memory together instead of letting one name disappear under it."
        })
        cards.append({
            "eyebrow": "Name",
            "title": "Neri Says Her Name Clearly",
            "body": "The quiet epilogue lands on a simple proof of victory: a child can still speak her own name out loud and expect the world to remember it."
        })
    else:
        cards.append({
            "eyebrow": "Aftermath",
            "title": "What Was Left Still Has To Be Carried",
            "body": "The world survives the tower, but the post-clear hush makes room for the cost: Rian leaves with the last burden still resting on one name."
        })
        cards.append({
            "eyebrow": "Name",
            "title": "Neri Says Her Name Clearly",
            "body": "Even on the bittersweet route, the epilogue closes on the smallest promise the party protected: Neri can say her name and trust that someone will keep it."
        })
    return cards

func _get_ch10_finale_result() -> Dictionary:
    if _active_chapter_id != CHAPTER_CH10 or _battle_controller == null:
        return {}
    var summary: Dictionary = _battle_controller.get_last_result_summary()
    if not summary.has("finale_result"):
        return {}
    return summary.get("finale_result", {}).duplicate(true)

func _is_ch10_true_resolution() -> bool:
    var finale_result: Dictionary = _get_ch10_finale_result()
    if finale_result.is_empty():
        return false
    var required_calls: int = int(finale_result.get("required_name_call_count", 0))
    return bool(finale_result.get("minimum_anchor_condition_met", false)) and required_calls > 0 and int(finale_result.get("name_call_moments_fired", 0)) >= required_calls

func _commit_stage_rewards(stage: StageData) -> void:
    var progression_data: ProgressionData = _get_progression_data()
    var result_summary: Dictionary = _battle_controller.get_last_result_summary() if _battle_controller != null else {}
    if progression_data != null:
        var star_rating: int = _get_stage_star_rating(stage, result_summary)
        if star_rating >= 3:
            _award_badge(progression_data, "stage_clear:%s:three_star" % String(stage.stage_id), 3, "Badge of Heroism +3 — %s cleared at three stars." % String(stage.stage_id))
        elif star_rating >= 2:
            _award_badge(progression_data, "stage_clear:%s:two_star" % String(stage.stage_id), 1, "Badge of Heroism +1 — %s cleared at two stars." % String(stage.stage_id))
        for badge_id in _get_hidden_objective_badge_ids(stage, result_summary):
            _award_badge(progression_data, badge_id, 2, "Badge of Heroism +2 — hidden objective completed in %s." % String(stage.stage_id))
        _commit_stage_memorial(stage, progression_data, result_summary)
    _append_unique_lines(_chapter_reward_entries, _battle_controller.get_inventory_entries())
    _unlock_weapons_for_stage(stage.stage_id)
    _unlock_armors_for_stage(stage.stage_id)
    _unlock_accessories_for_stage(stage.stage_id)
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH01_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH02_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH03_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH04_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH05_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH06_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH07_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH08_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH09A_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH09B_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CH10_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH01_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH02_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH03_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH04_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH05_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH06_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH07_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH08_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH09A_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH09B_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CH10_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH01_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH02_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH03_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH04_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH05_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH06_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH07_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH08_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH09A_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH09B_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CH10_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH01_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH02_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH03_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH04_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH05_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH06_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH07_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH08_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH09A_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH09B_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CH10_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _check_hidden_recruit_unlocks(stage)

func _get_stage_star_rating(stage: StageData, result_summary: Dictionary) -> int:
    if stage == null:
        return 0
    var star_rating: int = int(result_summary.get("star_rating", 0))
    if not _stage_has_hidden_objective(stage.stage_id):
        return star_rating
    return 3 if not _get_hidden_objective_badge_ids(stage, result_summary).is_empty() else min(star_rating, 2)

func _stage_has_hidden_objective(stage_id: StringName) -> bool:
    match stage_id:
        &"CH07_05", &"CH08_05", &"CH09A_04", &"CH09B_05", &"CH10_05":
            return true
        _:
            return false

func _get_hidden_objective_badge_ids(stage: StageData, result_summary: Dictionary) -> Array[String]:
    var badge_ids: Array[String] = []
    if stage == null:
        return badge_ids
    var hidden_state: Dictionary = result_summary.get("hidden_recruit_state", {})
    var objective_state: Dictionary = result_summary.get("objective_state", {})
    var finale_result: Dictionary = result_summary.get("finale_result", {})
    match stage.stage_id:
        &"CH07_05":
            if bool(hidden_state.get("mira_shrine_investigated", false)):
                badge_ids.append("hidden_objective:CH07_05:shrine")
        &"CH08_05":
            if bool(hidden_state.get("lete_retreated", false)):
                badge_ids.append("hidden_objective:CH08_05:mercy")
        &"CH09A_04":
            if bool(objective_state.get("hold_completed", false)):
                badge_ids.append("hidden_objective:CH09A_04:hold")
        &"CH09B_05":
            if bool(hidden_state.get("melkion_flipped", false)):
                badge_ids.append("hidden_objective:CH09B_05:truth")
        &"CH10_05":
            if bool(finale_result.get("minimum_anchor_condition_met", false)):
                badge_ids.append("hidden_objective:CH10_05:anchors")
        _:
            pass
    return badge_ids

func _award_badge(progression_data: ProgressionData, badge_id: String, amount: int, reward_line: String) -> void:
    if progression_data == null:
        return
    if progression_data.earn_badge(badge_id, amount):
        _append_unique_lines(_chapter_reward_entries, [reward_line])

func _commit_stage_memorial(stage: StageData, progression_data: ProgressionData, result_summary: Dictionary) -> void:
    if stage == null or progression_data == null:
        return
    var memorial_payload := _build_stage_memorial_payload(stage, result_summary)
    if memorial_payload.is_empty():
        return
    progression_data.upsert_stage_memorial(
        String(stage.stage_id),
        String(memorial_payload.get("objective", "")),
        String(memorial_payload.get("marker_type", "flower")),
        int(memorial_payload.get("chapter_when_achieved", 1))
    )

func _build_stage_memorial_payload(stage: StageData, result_summary: Dictionary) -> Dictionary:
    if stage == null:
        return {}
    var objective_text := _get_stage_memorial_objective_text(stage, result_summary)
    if objective_text.is_empty():
        return {}
    var objective_type := _get_stage_memorial_objective_type(stage, result_summary)
    return {
        "objective": objective_text,
        "marker_type": _resolve_stage_memorial_marker_type(objective_text, objective_type, stage),
        "chapter_when_achieved": _get_stage_memorial_chapter_rank(stage)
    }

func _get_stage_memorial_objective_type(stage: StageData, result_summary: Dictionary) -> String:
    if stage == null:
        return ""
    match stage.stage_id:
        &"CH07_05":
            return "shrine"
        &"CH08_05":
            return "mercy"
        &"CH09A_04":
            return "hold"
        &"CH09B_05":
            return "truth"
        &"CH10_05":
            return "anchors"
        _:
            var objective_state: Dictionary = result_summary.get("objective_state", {})
            return String(objective_state.get("objective_type", "")).strip_edges().to_lower()

func _get_stage_memorial_objective_text(stage: StageData, result_summary: Dictionary) -> String:
    if stage == null:
        return ""
    var hidden_state: Dictionary = result_summary.get("hidden_recruit_state", {})
    var objective_state: Dictionary = result_summary.get("objective_state", {})
    var finale_result: Dictionary = result_summary.get("finale_result", {})
    match stage.stage_id:
        &"CH07_05":
            if bool(hidden_state.get("mira_shrine_investigated", false)):
                return "미라의 기록이 잠들어 있던 성소"
        &"CH08_05":
            if bool(hidden_state.get("lete_retreated", false)):
                return "검은 사냥개의 추격에서 살아남을 길"
        &"CH09A_04":
            if bool(objective_state.get("hold_completed", false)):
                return "중앙 승강기와 버려진 장교들의 퇴로"
        &"CH09B_05":
            if bool(hidden_state.get("melkion_flipped", false)):
                return "심연의 기록과 멜키온의 진실"
        &"CH10_05":
            if bool(finale_result.get("minimum_anchor_condition_met", false)):
                return "마지막 종이 기억할 이름의 닻"
    return ""

func _resolve_stage_memorial_marker_type(objective_text: String, objective_type: String, stage: StageData) -> String:
    var normalized := objective_text.to_lower()
    var normalized_type := objective_type.to_lower()
    if normalized.contains("bridge") or normalized.contains("shrine") or normalized_type in ["bridge", "shrine"]:
        return "flower"
    if normalized.contains("mercy") or normalized.contains("truth") or normalized.contains("name") or normalized_type in ["mercy", "truth", "anchors"]:
        return "candle"
    if normalized.contains("hold") or normalized.contains("guard") or normalized.contains("protect") or normalized.contains("officer") or normalized_type in ["hold", "rescue_quota"]:
        return "medal"
    if stage != null and stage.has_memorial_slot() and stage.get_terrain_type(stage.memorial_slot) == &"bridge":
        return "flower"
    return "medal"

func _get_stage_memorial_chapter_rank(stage: StageData) -> int:
    if _active_chapter_id != StringName():
        return CampaignChapterRegistry.get_rank(_active_chapter_id)
    var stage_id_text := String(stage.stage_id).to_upper()
    if stage_id_text.begins_with("CH09A"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH09A)
    if stage_id_text.begins_with("CH09B"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH09B)
    if stage_id_text.begins_with("CH10"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH10)
    if stage_id_text.begins_with("CH08"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH08)
    if stage_id_text.begins_with("CH07"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH07)
    if stage_id_text.begins_with("CH06"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH06)
    if stage_id_text.begins_with("CH05"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH05)
    if stage_id_text.begins_with("CH04"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH04)
    if stage_id_text.begins_with("CH03"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH03)
    if stage_id_text.begins_with("CH02"):
        return CampaignChapterRegistry.get_rank(CHAPTER_CH02)
    return CampaignChapterRegistry.get_rank(CHAPTER_CH01)

func _get_active_stage_memorial() -> Dictionary:
    var progression_data := _get_progression_data()
    if progression_data == null or _current_stage == null:
        return {}
    return progression_data.get_stage_memorial(String(_current_stage.stage_id))

func _append_stage_memorial_summary_line(lines: Array[String]) -> void:
    var memorial := _get_active_stage_memorial()
    if memorial.is_empty():
        return
    var objective := String(memorial.get("objective", "")).strip_edges()
    if objective.is_empty():
        return
    lines.append("이 땅은 당신의 선택을 기억합니다 — %s." % objective)

func _append_stage_memorial_dialogue_entry(lines: Array[String]) -> void:
    var memorial := _get_active_stage_memorial()
    if memorial.is_empty():
        return
    var objective := String(memorial.get("objective", "")).strip_edges()
    if objective.is_empty():
        return
    var line := "Narrator: 이 자리에서 당신은 %s 지켰습니다." % objective
    if not lines.has(line):
        lines.append(line)

func _check_hidden_recruit_unlocks(stage: StageData) -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if stage == null or progression_data == null or _battle_controller == null:
        return
    var result_summary: Dictionary = _battle_controller.get_last_result_summary()
    var hidden_state: Dictionary = result_summary.get("hidden_recruit_state", {})
    _check_lete_retreat_unlock(stage, progression_data, hidden_state)
    _check_mira_unlock(stage, progression_data, hidden_state)
    _check_melkion_unlock(stage, progression_data, hidden_state)

func _check_lete_retreat_unlock(stage: StageData, progression_data: ProgressionData, hidden_state: Dictionary) -> void:
    if stage.stage_id != &"CH08_05" or not bool(hidden_state.get("lete_retreated", false)):
        return
    progression_data.unlock_ally(&"lete")
    var npc_personality = _get_npc_personality()
    if npc_personality != null and npc_personality.has_method("record_story_action"):
        npc_personality.record_story_action("recruit_hidden_unit", {"recruited_npc_id": "lete"})
    _award_worldview_fragment(progression_data, WORLDVIEW_FRAGMENT_LETE, "Worldview Fragment unlocked — 복수의 순수함")
    _award_badge(progression_data, "secret_recruit:lete", 5, "Badge of Heroism +5 — Lete has been recruited.")
    _append_unique_lines(_chapter_reward_entries, ["Lete retreats alive from the ruin fight and joins the active roster."])

func _check_mira_unlock(stage: StageData, progression_data: ProgressionData, hidden_state: Dictionary) -> void:
    if stage.stage_id != &"CH07_05" or not bool(hidden_state.get("mira_unlocked", false)):
        return
    progression_data.mira_unlocked = true
    progression_data.unlock_ally(&"mira")
    var npc_personality = _get_npc_personality()
    if npc_personality != null and npc_personality.has_method("record_story_action"):
        npc_personality.record_story_action("recruit_hidden_unit", {"recruited_npc_id": "mira"})
    _award_worldview_fragment(progression_data, WORLDVIEW_FRAGMENT_MIRA, "Worldview Fragment unlocked — 믿음과 의심")
    _award_badge(progression_data, "secret_recruit:mira", 5, "Badge of Heroism +5 — Mira has been recruited.")
    _append_unique_lines(_chapter_reward_entries, ["Mira answers the shrine record and joins the active roster."])

func _check_melkion_unlock(stage: StageData, progression_data: ProgressionData, hidden_state: Dictionary) -> void:
    if stage.stage_id != &"CH09B_05" or not bool(hidden_state.get("melkion_flipped", false)):
        return
    progression_data.melkion_unlocked = true
    progression_data.unlock_ally(&"melkion")
    var npc_personality = _get_npc_personality()
    if npc_personality != null and npc_personality.has_method("record_story_action"):
        npc_personality.record_story_action("recruit_hidden_unit", {"recruited_npc_id": "melkion"})
    _award_worldview_fragment(progression_data, WORLDVIEW_FRAGMENT_MELKION, "Worldview Fragment unlocked — 진실의 대가")
    _award_badge(progression_data, "secret_recruit:melkion", 5, "Badge of Heroism +5 — Melkion has been recruited.")
    _append_unique_lines(_chapter_reward_entries, ["Melkion rewrites his own record and joins for the next battle only."])

func _award_worldview_fragment(progression_data: ProgressionData, fragment_id: String, reward_line: String) -> void:
    if progression_data == null or not progression_data.add_worldview_fragment(fragment_id):
        return
    _append_unique_lines(_chapter_reward_entries, [reward_line])
    _check_worldview_complete(progression_data)

func _check_worldview_complete(progression_data: ProgressionData) -> void:
    if progression_data == null or progression_data.worldview_complete:
        return
    for fragment_id in WORLDVIEW_REQUIRED_FRAGMENTS:
        if not progression_data.has_worldview_fragment(fragment_id):
            return
    progression_data.worldview_complete = true
    _append_unique_lines(_chapter_reward_entries, [
        "Museum of Truth unlocked — all three hidden viewpoints now resolve into a secret worldview record."
    ])

func _unlock_accessories_for_stage(stage_id: StringName) -> void:
    var unlocks: Variant = []
    if CH02_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH02_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH03_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH03_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH04_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH04_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH05_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH05_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH06_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH06_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH07_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH07_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH08_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH08_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH09A_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH09A_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH09B_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH09B_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CH10_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CH10_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    if typeof(unlocks) != TYPE_ARRAY:
        return
    for accessory_id in unlocks:
        var typed_id: StringName = accessory_id
        if not _unlocked_accessory_ids.has(typed_id):
            _unlocked_accessory_ids.append(typed_id)

func _unlock_weapons_for_stage(stage_id: StringName) -> void:
    var unlocks: Variant = []
    if CH05_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH05_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CH06_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH06_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CH07_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH07_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CH08_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH08_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CH09A_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH09A_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CH09B_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH09B_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CH10_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CH10_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    if typeof(unlocks) != TYPE_ARRAY:
        return
    for weapon_id in unlocks:
        var typed_id: StringName = weapon_id
        if not _unlocked_weapon_ids.has(typed_id):
            _unlocked_weapon_ids.append(typed_id)

func _unlock_armors_for_stage(stage_id: StringName) -> void:
    var unlocks: Variant = []
    if CH03_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH03_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH04_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH04_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH05_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH05_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH07_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH07_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH08_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH08_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH09A_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH09A_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH09B_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH09B_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CH10_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CH10_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    if typeof(unlocks) != TYPE_ARRAY:
        return
    for armor_id in unlocks:
        var typed_id: StringName = armor_id
        if not _unlocked_armor_ids.has(typed_id):
            _unlocked_armor_ids.append(typed_id)

func _variant_to_string_array(value: Variant) -> Array[String]:
    var lines: Array[String] = []
    if typeof(value) != TYPE_ARRAY:
        return lines
    for entry in value:
        lines.append(str(entry))
    return lines

func _variant_to_dictionary_array(value: Variant) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    if typeof(value) != TYPE_ARRAY:
        return entries
    for entry in value:
        if typeof(entry) == TYPE_DICTIONARY:
            entries.append(entry)
    return entries

func _format_record_entries(entries: Variant) -> Array[String]:
    var lines: Array[String] = []
    if typeof(entries) != TYPE_ARRAY:
        return lines

    for entry in entries:
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        lines.append("%s — %s" % [
            String(entry.get("title", "Record")),
            String(entry.get("summary", ""))
        ])
    return lines

func _append_unique_lines(target: Array[String], lines: Array[String]) -> void:
    for line in lines:
        var normalized: String = line.strip_edges()
        if normalized.is_empty():
            continue
        if not target.has(normalized):
            target.append(normalized)

func _merge_unique_lines(base: Array[String], extra: Array[String]) -> Array[String]:
    var merged: Array[String] = base.duplicate()
    _append_unique_lines(merged, extra)
    return merged

func _build_camp_alerts(memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String], inventory_entries: Array[String]) -> Array[String]:
    var alerts: Array[String] = ["Camp ready", "Party update available"]
    if not memory_entries.is_empty():
        alerts.append("Memory log updated")
    if not evidence_entries.is_empty():
        alerts.append("Evidence trail updated")
    if not letter_entries.is_empty():
        alerts.append("Letter received")
    if not inventory_entries.is_empty():
        alerts.append("Recovered supplies logged")
    return alerts

func _build_camp_recommendation(memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String], inventory_entries: Array[String]) -> String:
    if not memory_entries.is_empty() or not evidence_entries.is_empty() or not letter_entries.is_empty():
        return "Start in Records to review the latest memory, evidence, and Serin handoff before checking party readiness."
    if not inventory_entries.is_empty():
        return "Start in Inventory to review recovered supplies, then confirm the party for the northern route."
    return "Review the current party and continue when ready."

func _build_camp_section_badges(party_entries: Array[String], inventory_entries: Array[String], memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String]) -> Dictionary:
    var badges: Dictionary = {}
    if not party_entries.is_empty():
        badges[CampaignPanel.SECTION_PARTY] = "READY"

    var inventory_count: int = inventory_entries.size()
    if inventory_count > 0:
        badges[CampaignPanel.SECTION_INVENTORY] = str(inventory_count)

    var record_count: int = memory_entries.size() + evidence_entries.size() + letter_entries.size()
    if record_count > 0:
        badges[CampaignPanel.SECTION_RECORDS] = "NEW %d" % record_count

    return badges

func _get_deployment_limit() -> int:
    var chapter_rank: int = CampaignChapterRegistry.get_rank(_active_chapter_id)
    if chapter_rank >= 9:
        return 5
    if chapter_rank >= 5:
        return 4
    if chapter_rank >= 3:
        return 3
    return 2

func _apply_choice_stage_overrides(stage: StageData) -> void:
    if stage == null:
        return

    var progression: ProgressionData = _get_progression_data()
    stage.ally_attack_bonus = 0
    stage.ally_defense_bonus = 0
    if progression == null:
        return

    if stage.stage_id == &"CH08_05" and progression.lete_early_alliance:
        var weakened_index: int = -1
        for index in range(stage.enemy_units.size()):
            var enemy_data: UnitData = stage.enemy_units[index]
            if enemy_data == null:
                continue
            if enemy_data.unit_id != &"enemy_lete":
                weakened_index = index
                break
        if weakened_index != -1:
            stage.enemy_units.remove_at(weakened_index)
            if weakened_index < stage.enemy_spawns.size():
                stage.enemy_spawns.remove_at(weakened_index)

    if stage.stage_id == &"CH10_05":
        stage.ally_attack_bonus = progression.ch10_attack_bonus
        stage.ally_defense_bonus = progression.ch10_defense_bonus

func _build_runtime_deployed_party(stage: StageData = _current_stage) -> Array[UnitData]:
    var deployed: Array[UnitData] = []
    _normalize_deployed_party_ids()
    for unit_id in _deployed_party_unit_ids:
        var unit_data: UnitData = _get_unit_data_by_id(unit_id)
        if unit_data != null and _is_recruit_unlocked(unit_id) and not _is_unit_recovering(unit_id):
            deployed.append(_build_runtime_unit_for_stage(unit_data, stage))

    if deployed.is_empty():
        var default_rian: UnitData = CampaignCatalog.get_unit_data(&"ally_rian")
        if default_rian != null:
            deployed.append(_build_runtime_unit_for_stage(default_rian, stage))
        var fallback_unit_id := _get_first_available_noncore_unit_id()
        var default_serin: UnitData = _get_unit_data_by_id(fallback_unit_id)
        if default_serin != null:
            deployed.append(_build_runtime_unit_for_stage(default_serin, stage))
        _apply_veteran_squad_party_levels(deployed)
        return deployed

    while deployed.size() < min(2, _get_deployment_limit()):
        var fallback_unit_id := _get_first_available_noncore_unit_id()
        var fallback_serin: UnitData = _get_unit_data_by_id(fallback_unit_id)
        if fallback_serin == null:
            break
        deployed.append(_build_runtime_unit_for_stage(fallback_serin, stage))

    if stage != null and stage.stage_id == &"CH08_05":
        var progression: ProgressionData = _get_progression_data()
        if progression != null and progression.lete_early_alliance and TEMP_ALLY_LETE != null:
            var allied_lete: UnitData = TEMP_ALLY_LETE.duplicate(true)
            allied_lete.unit_id = &"ally_lete"
            allied_lete.faction = "ally"
            allied_lete.is_boss = false
            allied_lete.boss_pattern = StringName()
            allied_lete.boss_phase_thresholds = {}
            deployed.append(allied_lete)

    _apply_veteran_squad_party_levels(deployed)
    return deployed

func _apply_veteran_squad_party_levels(deployed: Array[UnitData]) -> void:
    var progression: ProgressionData = _get_progression_data()
    if progression == null or not progression.has_ng_plus_purchase("veteran_squad"):
        return
    for unit_data: UnitData in deployed:
        if unit_data == null or String(unit_data.faction) != "ally":
            continue
        var current_progress: Dictionary = progression.get_unit_progress(unit_data.unit_id)
        var current_level: int = int(current_progress.get("level", 1))
        if current_level >= 5:
            continue
        progression.set_unit_progress(unit_data.unit_id, 5, 0)

func _build_runtime_unit_for_stage(unit_data: UnitData, stage: StageData) -> UnitData:
    if unit_data == null:
        return null

    var runtime_unit: UnitData = unit_data.duplicate(true)
    var progression: ProgressionData = _get_progression_data()
    if progression == null:
        return runtime_unit

    if stage != null and stage.stage_id == &"CH06_01" and runtime_unit.unit_id == &"ally_enoch" and progression.enoch_wounded:
        runtime_unit.attack = max(0, runtime_unit.attack - 1)
        runtime_unit.defense = max(0, runtime_unit.defense - 1)

    if stage != null and String(stage.stage_id).begins_with("CH09B") and runtime_unit.unit_id == &"ally_noah" and progression.noah_phase2_multiplier > 1.0:
        runtime_unit.attack = max(runtime_unit.attack + 1, int(round(float(runtime_unit.attack) * progression.noah_phase2_multiplier)))

    if stage != null and stage.stage_id == &"CH10_05":
        runtime_unit.attack += int(stage.ally_attack_bonus)
        runtime_unit.defense += int(stage.ally_defense_bonus)

    return runtime_unit

func _normalize_deployed_party_ids() -> void:
    var normalized: Array[StringName] = [&"ally_rian"]
    for unit_id in _deployed_party_unit_ids:
        if unit_id == &"ally_rian":
            continue
        if not _is_recruit_unlocked(unit_id) or _is_unit_recovering(unit_id):
            continue
        if normalized.has(unit_id):
            continue
        normalized.append(unit_id)
        if normalized.size() >= _get_deployment_limit():
            break

    if normalized.size() == 1:
        var fallback_unit_id := _get_first_available_noncore_unit_id()
        if fallback_unit_id != StringName():
            normalized.append(fallback_unit_id)
    _deployed_party_unit_ids = normalized

func _build_campaign_party_summary_lines() -> Array[String]:
    var lines: Array[String] = []
    for unit_data in _get_campaign_party_roster():
        var role_label: String = "Reserve"
        var recovering: bool = _is_unit_recovering(unit_data.unit_id)
        if unit_data.unit_id == &"ally_rian":
            role_label = "Core"
        elif recovering:
            role_label = _build_recovering_label()
        elif _deployed_party_unit_ids.has(unit_data.unit_id):
            role_label = "Deployed"
        lines.append("%s  HP %d/%d  ATK %d  DEF %d  %s" % [
            unit_data.display_name,
            unit_data.max_hp,
            unit_data.max_hp,
            unit_data.attack,
            unit_data.defense,
            role_label
        ])
    return lines

func _build_honor_roll_entries() -> Array[String]:
    var lines: Array[String] = []
    var progression := _get_progression_data()
    if progression == null:
        return lines
    for record in progression.get_honor_roll():
        var unit_name := String(record.get("unit_name", "The Fallen")).strip_edges()
        var epitaph := String(record.get("epitaph", "")).strip_edges()
        lines.append("%s — %s" % [unit_name, epitaph if not epitaph.is_empty() else "名誉의 자리"])
    return lines

func _build_campaign_party_detail_entries() -> Array[Dictionary]:
    var details: Array[Dictionary] = []
    for unit_data in _get_campaign_party_roster():
        var default_skill_name: String = unit_data.default_skill.display_name if unit_data.default_skill != null else "No skill"
        var deploy_status: String = "Reserve"
        var recovering: bool = _is_unit_recovering(unit_data.unit_id)
        var recovering_label: String = _build_recovering_label() if recovering else ""
        if unit_data.unit_id == &"ally_rian":
            deploy_status = "Core"
        elif recovering:
            deploy_status = recovering_label
        elif _deployed_party_unit_ids.has(unit_data.unit_id):
            deploy_status = "Deployed"
        var weapon_name: String = "None"
        var armor_name: String = "None"
        var accessory_name: String = "None"
        var equipped_weapon_id: StringName = StringName(_equipped_weapon_by_unit_id.get(String(unit_data.unit_id), ""))
        var equipped_armor_id: StringName = StringName(_equipped_armor_by_unit_id.get(String(unit_data.unit_id), ""))
        var equipped_accessory_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_data.unit_id), ""))
        var equipped_weapon: WeaponData = _get_weapon_data_by_id(equipped_weapon_id)
        var equipped_armor: ArmorData = _get_armor_data_by_id(equipped_armor_id)
        var equipped_accessory: AccessoryData = _get_accessory_data_by_id(equipped_accessory_id)
        if equipped_weapon != null:
            weapon_name = equipped_weapon.display_name
        if equipped_armor != null:
            armor_name = equipped_armor.display_name
        if equipped_accessory != null:
            accessory_name = equipped_accessory.display_name
        var accessory_summary: String = equipped_accessory.summary if equipped_accessory != null else ""
        var accessory_flavor_text: String = _get_accessory_flavor_text(equipped_accessory)
        var allowed_weapon_types: PackedStringArray = unit_data.get_allowed_weapon_types()
        var allowed_armor_types: PackedStringArray = unit_data.get_allowed_armor_types()
        var eligible_weapon_ids: Array[StringName] = _get_available_weapon_ids_for_unit(unit_data.unit_id)
        var eligible_armor_ids: Array[StringName] = _get_available_armor_ids_for_unit(unit_data.unit_id)
        details.append({
            "unit_id": String(unit_data.unit_id),
            "name": unit_data.display_name,
            "hp_text": "%d/%d" % [unit_data.max_hp, unit_data.max_hp],
            "status": deploy_status,
            "recovering": recovering,
            "recovering_label": recovering_label,
            "attack": unit_data.attack,
            "defense": unit_data.defense,
            "move": unit_data.movement,
            "range": unit_data.attack_range,
            "skill": default_skill_name,
            "weapon_slot": weapon_name,
            "armor_slot": armor_name,
            "accessory_slot": accessory_name,
            "accessory_summary": accessory_summary,
            "accessory_flavor_text": accessory_flavor_text,
            "weapon_preview_path": _get_weapon_preview_path(equipped_weapon_id),
            "armor_preview_path": _get_armor_preview_path(equipped_armor_id),
            "accessory_preview_path": _get_accessory_preview_path(equipped_accessory_id),
            "allowed_weapon_types": _packed_array_to_string_array(allowed_weapon_types),
            "allowed_armor_types": _packed_array_to_string_array(allowed_armor_types),
            "eligible_weapon_count": eligible_weapon_ids.size(),
            "eligible_armor_count": eligible_armor_ids.size(),
            "eligible_accessory_count": _get_available_accessory_ids().size(),
            "total_weapon_count": _get_available_weapon_ids().size(),
            "total_armor_count": _get_available_armor_ids().size(),
            "total_accessory_count": _get_available_accessory_ids().size()
        })
    return details

func _get_campaign_party_roster() -> Array[UnitData]:
    var roster: Array[UnitData] = []
    for unit_id in CampaignCatalog.get_party_roster_order():
        if not _is_recruit_unlocked(unit_id):
            continue
        if _is_unit_sacrificed(unit_id):
            continue
        var unit_data: UnitData = CampaignCatalog.get_unit_data(unit_id)
        if unit_data != null:
            roster.append(unit_data)
    return roster

func _resolve_sacrifice_epitaph(unit_id: StringName, unit_name: String) -> String:
    var mapped := String(SACRIFICE_EPITAPHS.get(unit_id, "")).strip_edges()
    if not mapped.is_empty():
        return mapped
    return "%s, march on without me." % unit_name

func _build_memorial_quote(epitaph: String) -> String:
    var normalized := epitaph.strip_edges()
    if normalized.is_empty():
        return MEMORIAL_QUOTE_PREFIX
    if normalized.begins_with(MEMORIAL_QUOTE_PREFIX):
        return normalized
    return "%s %s" % [MEMORIAL_QUOTE_PREFIX, normalized]

func _get_unit_data_by_id(unit_id: StringName) -> UnitData:
    return CampaignCatalog.get_unit_data(unit_id)

func _get_accessory_data_by_id(accessory_id: StringName) -> AccessoryData:
    return CampaignCatalog.get_accessory_data(accessory_id)

func _get_weapon_data_by_id(weapon_id: StringName) -> WeaponData:
    return CampaignCatalog.get_weapon_data(weapon_id)

func _get_armor_data_by_id(armor_id: StringName) -> ArmorData:
    return CampaignCatalog.get_armor_data(armor_id)

func _is_recruit_unlocked(unit_id: StringName) -> bool:
    var progression_data: ProgressionData = _get_progression_data()
    if _is_unit_sacrificed(unit_id):
        return false
    match unit_id:
        &"ally_bran":
            return _active_chapter_id == CHAPTER_CH02 and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 2
        &"ally_tia":
            return _active_chapter_id == CHAPTER_CH03 and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 3
        &"ally_enoch":
            return _active_chapter_id == CHAPTER_CH05 and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 5
        &"ally_karl":
            return _active_chapter_id == CHAPTER_CH09A and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 9
        &"ally_noah":
            return _active_chapter_id == CHAPTER_CH09B and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 10
        &"ally_lete":
            return progression_data != null and progression_data.is_ally_unlocked(&"lete")
        &"ally_mira":
            return progression_data != null and progression_data.mira_unlocked
        &"ally_melkion_ally":
            return progression_data != null \
                and progression_data.melkion_unlocked \
                and (_active_chapter_id == CHAPTER_CH09B or (_active_chapter_id == CHAPTER_CH10 and _active_stage_index == 0))
        _:
            return true

func _chapter_rank(chapter_id: StringName) -> int:
    return CampaignChapterRegistry.get_rank(chapter_id)

func debug_seed_chapter_camp(chapter_id: StringName, stage_index: int, stage: StageData) -> void:
    _active_chapter_id = chapter_id
    _active_stage_index = stage_index
    _current_stage = stage

    match chapter_id:
        CHAPTER_CH01:
            _enter_camp_state()
        CHAPTER_CH02:
            _enter_chapter_two_camp()
        CHAPTER_CH03:
            _enter_chapter_three_camp()
        CHAPTER_CH04:
            _enter_chapter_four_camp()
        CHAPTER_CH05:
            _enter_chapter_five_camp()
        CHAPTER_CH06:
            _enter_chapter_six_camp()
        CHAPTER_CH07:
            _enter_chapter_seven_camp()
        CHAPTER_CH08:
            _enter_chapter_eight_camp()
        CHAPTER_CH09A:
            _enter_chapter_nine_a_camp()
        CHAPTER_CH09B:
            _enter_chapter_nine_b_camp()
        CHAPTER_CH10:
            _enter_chapter_ten_resolution()
        _:
            _enter_chapter_complete_state()

func debug_unlock_accessory_ids(ids: Array) -> void:
    for accessory_id in ids:
        var typed_id: StringName = accessory_id
        if not _unlocked_accessory_ids.has(typed_id):
            _unlocked_accessory_ids.append(typed_id)

func debug_unlock_weapon_ids(ids: Array) -> void:
    for weapon_id in ids:
        var typed_id: StringName = weapon_id
        if not _unlocked_weapon_ids.has(typed_id):
            _unlocked_weapon_ids.append(typed_id)

func debug_unlock_armor_ids(ids: Array) -> void:
    for armor_id in ids:
        var typed_id: StringName = armor_id
        if not _unlocked_armor_ids.has(typed_id):
            _unlocked_armor_ids.append(typed_id)

func _build_runtime_ally_spawns(stage: StageData) -> Array[Vector2i]:
    var spawns: Array[Vector2i] = stage.ally_spawns.duplicate()
    var required_count: int = stage.ally_units.size()
    if spawns.size() >= required_count:
        return spawns

    var taken: Dictionary = {}
    for cell in spawns:
        taken[cell] = true
    for cell in stage.enemy_spawns:
        taken[cell] = true
    for cell in stage.blocked_cells:
        taken[cell] = true

    var anchor: Vector2i = spawns[spawns.size() - 1] if not spawns.is_empty() else Vector2i.ZERO
    var offsets: Array[Vector2i] = [
        Vector2i(1, 0),
        Vector2i(-1, 0),
        Vector2i(0, -1),
        Vector2i(1, -1),
        Vector2i(-1, -1),
        Vector2i(0, 1),
        Vector2i(1, 1),
        Vector2i(-1, 1)
    ]

    for offset in offsets:
        if spawns.size() >= required_count:
            break
        var candidate: Vector2i = anchor + offset
        if candidate.x < 0 or candidate.y < 0 or candidate.x >= stage.grid_size.x or candidate.y >= stage.grid_size.y:
            continue
        if taken.has(candidate):
            continue
        taken[candidate] = true
        spawns.append(candidate)

    return spawns

func _stringify_unit_ids(unit_ids: Array[StringName]) -> Array[String]:
    var values: Array[String] = []
    for unit_id in unit_ids:
        values.append(String(unit_id))
    return values

func assign_unit_to_sortie(unit_id: StringName) -> void:
    if unit_id == &"ally_rian":
        return
    if not _is_recruit_unlocked(unit_id) or _is_unit_recovering(unit_id):
        return

    _normalize_deployed_party_ids()
    if _deployed_party_unit_ids.has(unit_id):
        return

    if _deployed_party_unit_ids.size() < _get_deployment_limit():
        _deployed_party_unit_ids.append(unit_id)
    else:
        var replace_index: int = _find_replaceable_deployed_index()
        _deployed_party_unit_ids[replace_index] = unit_id

    _normalize_deployed_party_ids()
    if _campaign_panel != null:
        _campaign_panel.show_state(
            _active_mode,
            _current_panel_title,
            _current_panel_body,
            _campaign_panel.advance_button.text,
            _build_panel_payload(_active_mode)
        )

func cycle_accessory_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return

    var available_ids: Array[StringName] = _get_available_accessory_ids()
    if available_ids.is_empty():
        return

    var current_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_id), ""))
    var next_index: int = 0
    if current_id != StringName() and available_ids.has(current_id):
        next_index = (available_ids.find(current_id) + 1) % available_ids.size()
    var next_id: StringName = available_ids[next_index]
    _equipped_accessory_by_unit_id[String(unit_id)] = String(next_id)

    if _campaign_panel != null:
        _campaign_panel.show_state(
            _active_mode,
            _current_panel_title,
            _current_panel_body,
            _campaign_panel.advance_button.text,
            _build_panel_payload(_active_mode)
        )

func cycle_weapon_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_weapon_ids_for_unit(unit_id)
    if available_ids.is_empty():
        return
    var current_id: StringName = StringName(_equipped_weapon_by_unit_id.get(String(unit_id), ""))
    var next_index: int = 0
    if current_id != StringName() and available_ids.has(current_id):
        next_index = (available_ids.find(current_id) + 1) % available_ids.size()
    var next_id: StringName = available_ids[next_index]
    _equipped_weapon_by_unit_id[String(unit_id)] = String(next_id)
    if _campaign_panel != null:
        _campaign_panel.show_state(_active_mode, _current_panel_title, _current_panel_body, _campaign_panel.advance_button.text, _build_panel_payload(_active_mode))

func cycle_armor_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_armor_ids_for_unit(unit_id)
    if available_ids.is_empty():
        return
    var current_id: StringName = StringName(_equipped_armor_by_unit_id.get(String(unit_id), ""))
    var next_index: int = 0
    if current_id != StringName() and available_ids.has(current_id):
        next_index = (available_ids.find(current_id) + 1) % available_ids.size()
    var next_id: StringName = available_ids[next_index]
    _equipped_armor_by_unit_id[String(unit_id)] = String(next_id)
    if _campaign_panel != null:
        _campaign_panel.show_state(_active_mode, _current_panel_title, _current_panel_body, _campaign_panel.advance_button.text, _build_panel_payload(_active_mode))

func _on_deployment_assignment_requested(unit_id: StringName) -> void:
    assign_unit_to_sortie(unit_id)

func _on_weapon_cycle_requested(unit_id: StringName) -> void:
    cycle_weapon_for_unit(unit_id)

func _on_armor_cycle_requested(unit_id: StringName) -> void:
    cycle_armor_for_unit(unit_id)

func _on_accessory_cycle_requested(unit_id: StringName) -> void:
    cycle_accessory_for_unit(unit_id)

func _get_available_weapon_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for weapon_id in _unlocked_weapon_ids:
        if _get_weapon_data_by_id(weapon_id) != null:
            available.append(weapon_id)
    return available

func _get_available_armor_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for armor_id in _unlocked_armor_ids:
        if _get_armor_data_by_id(armor_id) != null:
            available.append(armor_id)
    return available

func _get_available_weapon_ids_for_unit(unit_id: StringName) -> Array[StringName]:
    var available: Array[StringName] = []
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return available
    for weapon_id in _get_available_weapon_ids():
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon != null and String(weapon.weapon_type) in unit_data.get_allowed_weapon_types():
            available.append(weapon_id)
    return available

func _get_available_armor_ids_for_unit(unit_id: StringName) -> Array[StringName]:
    var available: Array[StringName] = []
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return available
    for armor_id in _get_available_armor_ids():
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor != null and String(armor.armor_type) in unit_data.get_allowed_armor_types():
            available.append(armor_id)
    return available

func _get_available_accessory_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for accessory_id in _unlocked_accessory_ids:
        if _get_accessory_data_by_id(accessory_id) != null:
            available.append(accessory_id)
    return available

func _packed_array_to_string_array(values: PackedStringArray) -> Array[String]:
    var result: Array[String] = []
    for value in values:
        result.append(String(value))
    return result

func _get_weapon_preview_path(weapon_id: StringName) -> String:
    return CampaignCatalog.get_weapon_preview_path(weapon_id)

func _get_armor_preview_path(armor_id: StringName) -> String:
    return CampaignCatalog.get_armor_preview_path(armor_id)

func _get_accessory_preview_path(_accessory_id: StringName) -> String:
    return CampaignCatalog.get_accessory_preview_path(_accessory_id)

func _build_weapon_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for weapon_id in _get_available_weapon_ids():
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon == null:
            continue
        var equipped_unit: String = _find_equipped_weapon_unit_name(weapon.weapon_id)
        var suffix: String = "" if equipped_unit.is_empty() else " [Equipped: %s]" % equipped_unit
        lines.append("Weapon: %s — %s%s" % [weapon.display_name, weapon.summary, suffix])
    return lines

func _build_armor_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for armor_id in _get_available_armor_ids():
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor == null:
            continue
        var equipped_unit: String = _find_equipped_armor_unit_name(armor.armor_id)
        var suffix: String = "" if equipped_unit.is_empty() else " [Equipped: %s]" % equipped_unit
        lines.append("Armor: %s — %s%s" % [armor.display_name, armor.summary, suffix])
    return lines

func _build_accessory_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for accessory_id in _get_available_accessory_ids():
        var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
        if accessory == null:
            continue
        var equipped_unit: String = _find_equipped_unit_name(accessory.accessory_id)
        var suffix: String = "" if equipped_unit.is_empty() else " [Equipped: %s]" % equipped_unit
        var detail_parts: Array[String] = []
        var summary_text := String(accessory.summary).strip_edges()
        var flavor_text := _get_accessory_flavor_text(accessory)
        if not summary_text.is_empty():
            detail_parts.append(summary_text)
        if not flavor_text.is_empty() and flavor_text != summary_text:
            detail_parts.append(flavor_text)
        var detail_text := " / ".join(detail_parts)
        if detail_text.is_empty():
            detail_text = accessory.display_name
        lines.append("%s — %s%s" % [accessory.display_name, detail_text, suffix])
    return lines

func _get_accessory_flavor_text(accessory: AccessoryData) -> String:
    if accessory == null:
        return ""
    var flavor_text := String(accessory.flavor_text).strip_edges()
    if not flavor_text.is_empty():
        return flavor_text
    return String(accessory.summary).strip_edges()

func _build_runtime_accessory_map() -> Dictionary:
    var result: Dictionary = {}
    for unit_id in _equipped_accessory_by_unit_id.keys():
        var accessory_id: StringName = StringName(_equipped_accessory_by_unit_id[unit_id])
        var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
        if accessory != null:
            result[unit_id] = accessory
    return result

func _build_runtime_weapon_map() -> Dictionary:
    var result: Dictionary = {}
    for unit_id in _equipped_weapon_by_unit_id.keys():
        var weapon_id: StringName = StringName(_equipped_weapon_by_unit_id[unit_id])
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon != null:
            result[unit_id] = weapon
    return result

func _build_runtime_armor_map() -> Dictionary:
    var result: Dictionary = {}
    for unit_id in _equipped_armor_by_unit_id.keys():
        var armor_id: StringName = StringName(_equipped_armor_by_unit_id[unit_id])
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor != null:
            result[unit_id] = armor
    return result

func _find_equipped_unit_name(accessory_id: StringName) -> String:
    for unit_id in _equipped_accessory_by_unit_id.keys():
        if StringName(_equipped_accessory_by_unit_id[unit_id]) == accessory_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                return unit_data.display_name
    return ""

func _find_equipped_weapon_unit_name(weapon_id: StringName) -> String:
    for unit_id in _equipped_weapon_by_unit_id.keys():
        if StringName(_equipped_weapon_by_unit_id[unit_id]) == weapon_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                return unit_data.display_name
    return ""

func _find_equipped_armor_unit_name(armor_id: StringName) -> String:
    for unit_id in _equipped_armor_by_unit_id.keys():
        if StringName(_equipped_armor_by_unit_id[unit_id]) == armor_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                return unit_data.display_name
    return ""

func _find_replaceable_deployed_index() -> int:
    for index in range(_deployed_party_unit_ids.size()):
        if _deployed_party_unit_ids[index] != &"ally_rian":
            return index
    return max(0, _deployed_party_unit_ids.size() - 1)

class_name CampaignController
extends Node

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

const CH01_INTERLUDE_DIALOGUE: Array[String] = [
    "Serin: Your memory is tied to the Empire, which means they will come looking for you soon.",
    "Rian: Then I find the truth first.",
    "Serin: Good. From here on, I am your ally.",
    "Rian: Ally...",
    "Serin: Your past can wait. Right now, you are standing with the people you chose to protect.",
    "Rian: Thank you.",
    "Serin: Save it. Just do not die, Rian."
]

const CH02_INTRO_DIALOGUE: Array[String] = [
    "Bran: If the smoke line has not collapsed yet, Hardren is still bleeding men behind that gate.",
    "Rian: Then we cut a path before the siege closes again.",
    "Serin: We move fast, but we do not leave anyone trapped in the smoke."
]

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

const CH02_INTERLUDE_DIALOGUE: Array[String] = [
    "Bran: I will keep watch on you myself until I know why Hardren obeyed your memory.",
    "Rian: Watch all you want. I am going to the forest either way.",
    "Serin: Then we move together. Suspicion can march beside duty for one more chapter."
]

const CH03_INTRO_DIALOGUE: Array[String] = [
    "Tia: One more step and I put an arrow through the stranger who walks like he knows our forest.",
    "Rian: Then aim carefully. I am here for the truth, not the trees.",
    "Serin: If the Greenwood trail holds the next orders, we cannot turn back now."
]

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

const CH03_INTERLUDE_DIALOGUE: Array[String] = [
    "Tia: I am not forgiving you. I am making sure the next trail ends somewhere real.",
    "Rian: That is enough. Walk beside me and keep the truth in sight.",
    "Serin: Then we carry the forest with us and head for the monastery."
]

const CH04_INTRO_DIALOGUE: Array[String] = [
    "Serin: The flooded cloister was never meant to sound this empty.",
    "Rian: Then we follow the water until it reaches the record room.",
    "Tia: If this place hid the next orders, it hid them under prayer and stone."
]

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

const CH04_INTERLUDE_DIALOGUE: Array[String] = [
    "Serin: Faith was supposed to keep names intact, not strip them out of the living.",
    "Rian: Then we carry these records forward and let the archive answer for them.",
    "Tia: If the Gray Archive kept the transfers, that is where this trail turns next."
]

const CH05_INTRO_DIALOGUE: Array[String] = [
    "Enoch: If the Gray Archive still burns, the records we need are disappearing as we speak.",
    "Rian: Then we go through the ash before the last names are gone.",
    "Serin: And if the archive calls you Zero again, we read the whole page before we judge it."
]

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

const CH05_INTERLUDE_DIALOGUE: Array[String] = [
    "Enoch: Zero is a name in the archive, not the end of the argument.",
    "Rian: Then we carry the ledgers to Valtor and see what still survives there.",
    "Serin: Good. We judge the living by what they choose now, not only by what the ash preserved."
]

const CH06_INTRO_DIALOGUE: Array[String] = [
    "Bran: Valtor still stands because men I failed are trapped behind its guns.",
    "Rian: Then we take the guns apart and open the keep.",
    "Enoch: The fortress ledgers say the next truth is still alive inside those walls."
]

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

const CH06_INTERLUDE_DIALOGUE: Array[String] = [
    "Bran: I do not forgive you. I do see that you are not running from what happened here.",
    "Rian: Then we carry Valtor with us and stop the next rite before it empties more names.",
    "Enoch: Ellyor is no longer rumor. The ledgers make it an order."
]

const CH07_INTRO_DIALOGUE: Array[String] = [
    "Serin: Ellyor is asking people to surrender their pain in exchange for silence.",
    "Rian: Then we break the line before it turns into a prayer no one can leave.",
    "Bran: If the city still has names left, we hold them there."
]

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

const CH07_INTERLUDE_DIALOGUE: Array[String] = [
    "Serin: I understand why Saria called forgetting mercy. I still refuse it.",
    "Rian: Then we keep every name we can carry and chase the next trail into the forest.",
    "Bran: The orders are clear enough. Black hounds, hidden ruins, and no more lines for the nameless."
]

const CH08_INTRO_DIALOGUE: Array[String] = [
    "Tia: The black-hound trail is fresh. If my sister is alive, it is somewhere past those ruins.",
    "Rian: Then we follow every mark before it disappears.",
    "Serin: And this time we do not let the forest hide what the orders did."
]

const CH08_STAGE_REWARD_LOG: Dictionary = {
    &"CH08_01": [
        "Vanished trail cache logged: the first black-hound pursuit route is secured."
    ],
    &"CH08_02": [
        "Ambush cache logged: Moonlit Pursuit Sigil recovered from the split-line hunt route."
    ],
    &"CH08_03": [
        "Ruin vent cache logged: Ruin Holdfast Charm and Ruin Tracker Coat secured from the lower holding cells."
    ],
    &"CH08_04": [
        "Black mark controls logged: Houndfang Mark and Houndline Bow secured from the ruin control brand."
    ],
    &"CH08_05": [
        "Black-hound handoff logged: Lete falls, the hidden-ruin truth is exposed, and Karl's outer line becomes the next objective."
    ]
}

const CH08_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH08_01": [
        "The forest is no longer only terrain; it has been rewritten into a hunting grid.",
        "The first pursuit traces show the black hounds cutting people out of the map itself."
    ],
    &"CH08_02": [
        "Moonlit ambush lines split the party and punish whoever drifts alone.",
        "Tia recognizes the pattern as stolen forest sense turned into doctrine."
    ],
    &"CH08_03": [
        "The lower ruins smell like holding pens, not shelter.",
        "Every recovered route makes Tia's hope and dread sharper at the same time."
    ],
    &"CH08_04": [
        "The control marks reveal that capture orders and later edits are layered over the same operation.",
        "The last signal route opens straight into Lete's hunting ground."
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
            "summary": "Special orders, checkpoint plates, and transfer slips now point the chase toward Karl's outer defense line."
        }
    ]
}

const CH08_STAGE_LETTER_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "Tia's Last Unsent Name",
            "summary": "\"I cannot bring her back. I can carry her name forward and make the next lie stop here.\""
        }
    ]
}

const CH08_INTERLUDE_DIALOGUE: Array[String] = [
    "Tia: I do not forgive you. I am done pretending forgetting would help me breathe.",
    "Rian: Then we take what the ruin gave us and walk it straight into Karl's line.",
    "Serin: Good. We carry the names forward and make the next wall answer for them."
]

const CH09A_INTRO_DIALOGUE: Array[String] = [
    "Karl: The outer line still answers to me, even if the truth behind it has already rotted.",
    "Rian: Then we cross it and make the line tell us what it was built to hide.",
    "Bran: If the soldiers behind it are still ours, we pull them out before the censors burn them too."
]

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
        "Broken standard handoff logged: Karl joins, Standard Breaker Blade is secured, root access seals are secured, and the inner archive route opens."
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

const CH09A_INTERLUDE_DIALOGUE: Array[String] = [
    "Karl: I am not done judging you. I am done letting the censors decide what survives us.",
    "Rian: Then walk with us into the archive and judge what remains there.",
    "Bran: Good. Bring your witness, not your banner."
]

const CH09B_INTRO_DIALOGUE: Array[String] = [
    "Noah: The gate was never the hard part. The hard part was waiting for the right version of you to arrive here.",
    "Rian: Then we finish this before the archive edits the last reason to remember anything.",
    "Enoch: Melkion already has the shelves moving. Every step deeper is a fight against arrangement itself."
]

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
        "Abyss handoff logged: Melkion falls, the final memory is restored, and eclipse coordinates are secured."
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
            "summary": "Final Restored Memory: Rian was complicit in the machine and also the one who shattered his own memory to leave a way through it."
        }
    ]
}

const CH09B_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "flag_evidence_eclipse_coords_obtained",
            "summary": "Eclipse coordinates, tower lattice, and the last decree now point directly to the final tower."
        }
    ]
}

const CH09B_STAGE_LETTER_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "Noah's Last Trust",
            "summary": "\"The other you left a path, not an excuse. I kept it until this version of you could still choose people.\""
        }
    ]
}

const CH09B_INTERLUDE_DIALOGUE: Array[String] = [
    "Noah: The final memory gives context, not forgiveness.",
    "Rian: Good. I need the truth sharp enough to carry into the tower.",
    "Karl: Then we stop reading the archive and start answering the king who needed it."
]

const CH10_INTRO_DIALOGUE: Array[String] = [
    "Serin: This is the last climb. No one leaves their name behind here.",
    "Rian: Then we carry every name we saved all the way to the bell.",
    "Noah: The tower remembers the eclipse. We only need to make it remember people instead."
]

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

const CH10_RESOLUTION_DIALOGUE: Array[String] = [
    "Serin: It did not end. We kept it here, together.",
    "Bran: Then the names that survived this tower are the only wall worth rebuilding.",
    "Tia: It still hurts. I am still here.",
    "Enoch: No one gets edited out of this ending.",
    "Karl: A name survived the march back. That is enough to start from.",
    "Noah: This time, memory left people standing."
]

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

func setup(battle_controller: BattleController, campaign_panel: CampaignPanel) -> void:
    _battle_controller = battle_controller
    _campaign_panel = campaign_panel
    _camp_controller = CampController.new()
    add_child(_camp_controller)
    _save_service = SaveService.new()
    add_child(_save_service)

    if _battle_controller != null and not _battle_controller.battle_finished.is_connected(_on_battle_finished):
        _battle_controller.battle_finished.connect(_on_battle_finished)

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

func start_chapter_one_flow() -> void:
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
    _enter_stage(_active_stage_index)

func advance_step() -> bool:
    if _active_mode == CampaignState.MODE_CUTSCENE:
        _active_stage_index += 1
        var active_flow: Array[StageData] = _get_active_stage_flow()
        if _active_stage_index >= active_flow.size():
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
        _enter_stage(_active_stage_index)
        return true

    if _active_mode == CampaignState.MODE_CAMP:
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

func _enter_stage(stage_index: int) -> void:
    var active_flow: Array[StageData] = _get_active_stage_flow()
    if stage_index < 0 or stage_index >= active_flow.size():
        push_warning("Stage index %d is out of bounds for active chapter flow." % stage_index)
        return

    _current_stage = active_flow[stage_index].duplicate(true)
    _current_stage.ally_units = _build_runtime_deployed_party()
    _current_stage.ally_spawns = _build_runtime_ally_spawns(_current_stage)
    _active_mode = CampaignState.MODE_BATTLE
    _clear_panel_state()

    if _battle_controller != null:
        _battle_controller.set_equipped_weapon_map(_build_runtime_weapon_map())
        _battle_controller.set_equipped_armor_map(_build_runtime_armor_map())
        _battle_controller.set_equipped_accessory_map(_build_runtime_accessory_map())
        _battle_controller.visible = true
        _battle_controller.set_stage(_current_stage)

func _on_battle_finished(result: StringName, stage_id: StringName) -> void:
    if result != &"victory":
        _active_mode = CampaignState.MODE_BATTLE
        _set_panel_state(
            CampaignState.MODE_BATTLE,
            "Battle Failed",
            "Retry the current stage to continue the Chapter 1 campaign shell.",
            "Retry"
        )
        return

    if _current_stage == null or stage_id != _current_stage.stage_id:
        return

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

func _enter_camp_state() -> void:
    _active_mode = CampaignState.MODE_CAMP
    if _camp_controller != null:
        var stage_result: Dictionary = {}
        if _current_stage != null:
            stage_result = {
                "memory_entries": _variant_to_string_array(CH01_STAGE_MEMORY_LOG.get(_current_stage.stage_id, [])),
                "evidence_entries": _variant_to_string_array(CH01_STAGE_EVIDENCE_LOG.get(_current_stage.stage_id, [])),
                "letter_entries": _variant_to_string_array(CH01_STAGE_LETTER_LOG.get(_current_stage.stage_id, []))
            }
        _camp_controller.enter_camp(&"ch01", stage_result)
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

    if _current_stage != null and not _current_stage.next_destination_summary.is_empty():
        lines.append(_current_stage.next_destination_summary)

    return "\n".join(lines)

func _build_ch02_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch02_broken_border_fortress",
        "Hardren still stands under smoke and broken watchfires.",
        "Bran's remaining knights are boxed in behind the outer gate.",
        "Accessory and treasure loops stay locked as future Chapter 2 work; this shell only opens the next battlefield."
    ]
    _append_unique_lines(lines, CH02_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch02_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch02_hardren_camp",
        "Bran joins the active roster under open suspicion.",
        "Hardren blueprint memory recovered.",
        "Tracking orders now point the march toward Greenwood."
    ]
    _append_unique_lines(lines, CH02_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch03_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch03_whispering_greenwood",
        "The Greenwood trail is alive with traps, smoke, and people moving under cover.",
        "Tia's line watches the squad before choosing whether to help or hunt them."
    ]
    _append_unique_lines(lines, CH03_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch03_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch03_greenwood_camp",
        "Tia joins the active roster under an uneasy truce.",
        "The forest fire order memory is now recovered.",
        "Monastery manifests point the next route toward the drowned cloister."
    ]
    _append_unique_lines(lines, CH03_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch04_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch04_sunken_monastery",
        "The monastery is half drowned, and the only way forward is through controlled water and sealed records.",
        "Serin knows the place by prayer, but the surviving machinery reads like an experiment ledger."
    ]
    _append_unique_lines(lines, CH04_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch04_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch04_sunken_monastery_camp",
        "Ark research memory recovered.",
        "Archive transfer evidence secured.",
        "The next route points toward the Gray Archive."
    ]
    _append_unique_lines(lines, CH04_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch05_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch05_gray_archive",
        "The Gray Archive is already burning, but the surviving ledgers still point toward the core truth.",
        "Enoch is somewhere inside the sealed stacks, and the trail cannot wait."
    ]
    _append_unique_lines(lines, CH05_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch05_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch05_gray_archive_camp",
        "Enoch joins the active roster.",
        "Zero memory recovered with visible record edits.",
        "Valtor siege ledgers now point the march toward the iron fortress."
    ]
    _append_unique_lines(lines, CH05_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch06_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch06_valtor_iron_keep",
        "Valtor still stands as a machine of siege math, guilt, and surviving names.",
        "Bran's old fortress is now the next proof that the war was engineered in layers."
    ]
    _append_unique_lines(lines, CH06_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch06_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch06_valtor_camp",
        "Valtor breach context memory recovered.",
        "Ellyor relief edicts and civilian transfers are now secured.",
        "The next route points toward the purification rite in Ellyor."
    ]
    _append_unique_lines(lines, CH06_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch07_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch07_city_without_names",
        "Ellyor is turning grief into order through queues, hymns, and exhausted citizens asking to forget.",
        "Mira and Neri are somewhere inside that system, and the next forest trail already moves behind it."
    ]
    _append_unique_lines(lines, CH07_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch07_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch07_ellyor_camp",
        "Karon naming memory recovered.",
        "Black-hound orders and hidden-ruin coordinates secured.",
        "The next route points toward Lete and the forest ruins."
    ]
    _append_unique_lines(lines, CH07_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch08_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch08_black_hound_night",
        "The black-hound trail runs back into the forest, but now every step points toward a hidden ruin and a personal loss.",
        "Tia is no longer chasing only vengeance; she is chasing the last clear truth about what happened here."
    ]
    _append_unique_lines(lines, CH08_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch08_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch08_black_hound_camp",
        "North-corridor context memory recovered.",
        "Karl outer-line orders and transfer slips secured.",
        "Lete's black-hound route is broken, but the forest pursuit now turns into Karl's defense line around the capital."
    ]
    _append_unique_lines(lines, CH08_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch09a_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch09a_broken_standard",
        "The capital outer line has become a filter for testimony, survivors, and anyone still carrying names into the city.",
        "Karl stands on the wrong side of that line, but not for much longer."
    ]
    _append_unique_lines(lines, CH09A_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch09a_camp_summary() -> String:
    var lines: Array[String] = [
        "Part I interlude: ch09a_broken_standard_camp",
        "Returning-names memory recovered.",
        "Karl's testimony and root-archive pass are secured.",
        "The next route points inward toward the root archive and the last keeper."
    ]
    _append_unique_lines(lines, CH09A_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch09b_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch09b_abyss_of_record",
        "The root archive is no longer a military front. It is a machine for deciding what history is allowed to remain.",
        "Noah waits at its edge, and Melkion has already begun editing the battlefield itself."
    ]
    _append_unique_lines(lines, CH09B_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch09b_camp_summary() -> String:
    var lines: Array[String] = [
        "Part II interlude: ch09b_record_abyss_camp",
        "Final restored memory secured.",
        "Eclipse coordinates and tower lattice are now in hand.",
        "The next route points directly to the final tower."
    ]
    _append_unique_lines(lines, CH09B_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch10_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch10_nameless_tower",
        "The final tower is no longer about finding truth. It is about choosing what survives once the truth is known.",
        "The eclipse coordinates, tower lattice, and last decree all converge into a final ascent."
    ]
    _append_unique_lines(lines, CH10_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch10_resolution_summary() -> String:
    var lines: Array[String] = [
        "Final resolution: ch10_last_name",
        "Karon falls, the bell stops, and the campaign resolves around memory that remained shared instead of erased.",
        "The tower no longer decides what counts; the survivors do."
    ]
    _append_unique_lines(lines, CH10_RESOLUTION_DIALOGUE)
    return "\n".join(lines)

func _set_panel_state(mode: String, title_text: String, body_text: String, button_text: String) -> void:
    _current_panel_title = title_text
    _current_panel_body = body_text
    if _campaign_panel != null:
        _campaign_panel.show_state(mode, title_text, body_text, button_text, _build_panel_payload(mode))
    if _battle_controller != null:
        _battle_controller.visible = mode == CampaignState.MODE_BATTLE

func _clear_panel_state() -> void:
    _current_panel_title = ""
    _current_panel_body = ""
    if _campaign_panel != null:
        _campaign_panel.hide_panel()

func _on_advance_requested() -> void:
    advance_step()

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
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH05 Archive Interlude", _build_ch05_camp_summary(), "Next Battle")

func _enter_chapter_six_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH06 Valtor Interlude", _build_ch06_camp_summary(), "Next Battle")

func _enter_chapter_seven_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH07 Ellyor Interlude", _build_ch07_camp_summary(), "Next Battle")

func _enter_chapter_eight_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH08 Black Hound Interlude", _build_ch08_camp_summary(), "Next Battle")

func _enter_chapter_nine_a_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH09A Broken Standard Interlude", _build_ch09a_camp_summary(), "Next Battle")

func _enter_chapter_nine_b_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH09B Record Abyss Interlude", _build_ch09b_camp_summary(), "Next Battle")

func _enter_chapter_ten_resolution() -> void:
    _active_mode = CampaignState.MODE_COMPLETE
    _set_panel_state(
        CampaignState.MODE_COMPLETE,
        "CH10 Final Resolution",
        _build_ch10_resolution_summary(),
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
        if _active_chapter_id == CHAPTER_CH01:
            dialogue_entries = CH01_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH02:
            dialogue_entries = CH02_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH03:
            dialogue_entries = CH03_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH04:
            dialogue_entries = CH04_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH05:
            dialogue_entries = CH05_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH06:
            dialogue_entries = CH06_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH07:
            dialogue_entries = CH07_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH08:
            dialogue_entries = CH08_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH09A:
            dialogue_entries = CH09A_INTERLUDE_DIALOGUE.duplicate()
        elif _active_chapter_id == CHAPTER_CH09B:
            dialogue_entries = CH09B_INTERLUDE_DIALOGUE.duplicate()
        else:
            dialogue_entries = CH10_RESOLUTION_DIALOGUE.duplicate()
        presentation_cards = _build_camp_presentation_cards()
    elif mode == CampaignState.MODE_COMPLETE and _active_chapter_id == CHAPTER_CH10:
        dialogue_entries = CH10_RESOLUTION_DIALOGUE.duplicate()
        presentation_cards = _build_resolution_presentation_cards()

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
            recommendation = _build_camp_recommendation(memory_entries, evidence_entries, letter_entries, inventory_entries)
            active_section = CampaignPanel.SECTION_RECORDS
            section_badges = _build_camp_section_badges(party_entries, inventory_entries, memory_entries, evidence_entries, letter_entries)
        CampaignState.MODE_COMPLETE:
            alerts = ["Chapter handoff complete"]
            recommendation = "The Chapter 1 shell is complete and ready for the next destination."
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
        "inventory_entries": inventory_entries,
        "memory_entries": memory_entries,
        "evidence_entries": evidence_entries,
        "letter_entries": letter_entries,
        "alerts": alerts,
        "dialogue_entries": dialogue_entries,
        "presentation_cards": presentation_cards,
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
            "body": "Karl's testimony and broken-standard handoff now land as a dedicated transition card, making his alliance feel like a structural shift in the campaign."
        })
        cards.append({
            "eyebrow": "Archive",
            "title": "Discarded Officers Are Named",
            "body": "The route into the root archive now carries the weight of the discarded-officer records as an explicit handoff object."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH09B:
        cards.append({
            "eyebrow": "Ally",
            "title": "Noah Fixes The Archive Route",
            "body": "The abyss handoff now makes Noah's presence and the final archive-route alignment feel like a concrete arrival, not only a summary line."
        })
        cards.append({
            "eyebrow": "Destination",
            "title": "The Final Tower Is Confirmed",
            "body": "Eclipse coordinates and tower lattice are now framed as the final transition object, tightening the handoff into CH10."
        })
        return cards

    return cards

func _build_resolution_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _active_chapter_id == CHAPTER_CH10:
        cards.append({
            "eyebrow": "Resolution",
            "title": "The Bell Falls Silent",
            "body": "The final resolution now reads as a concrete runtime handoff: Karon falls, the bell stops, and the tower loses its right to decide what survives."
        })
        cards.append({
            "eyebrow": "Memory",
            "title": "Names Remain Shared",
            "body": "The ending state now frames survival through shared memory instead of erased authority, turning the finale into a readable conclusion rather than only a summary paragraph."
        })
    return cards

func _commit_stage_rewards(stage: StageData) -> void:
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
        lines.append(String(entry))
    return lines

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

func _build_runtime_deployed_party() -> Array[UnitData]:
    var deployed: Array[UnitData] = []
    _normalize_deployed_party_ids()
    for unit_id in _deployed_party_unit_ids:
        var unit_data: UnitData = _get_unit_data_by_id(unit_id)
        if unit_data != null and _is_recruit_unlocked(unit_id):
            deployed.append(unit_data)

    if deployed.is_empty():
        var default_rian: UnitData = CampaignCatalog.get_unit_data(&"ally_rian")
        var default_serin: UnitData = CampaignCatalog.get_unit_data(&"ally_serin")
        if default_rian != null:
            deployed.append(default_rian)
        if default_serin != null:
            deployed.append(default_serin)
        return deployed

    while deployed.size() < min(2, _get_deployment_limit()):
        var fallback_serin: UnitData = CampaignCatalog.get_unit_data(&"ally_serin")
        if fallback_serin == null:
            break
        deployed.append(fallback_serin)

    return deployed

func _normalize_deployed_party_ids() -> void:
    var normalized: Array[StringName] = [&"ally_rian"]
    for unit_id in _deployed_party_unit_ids:
        if unit_id == &"ally_rian":
            continue
        if not _is_recruit_unlocked(unit_id):
            continue
        if normalized.has(unit_id):
            continue
        normalized.append(unit_id)
        if normalized.size() >= _get_deployment_limit():
            break

    if normalized.size() == 1:
        normalized.append(&"ally_serin")
    _deployed_party_unit_ids = normalized

func _build_campaign_party_summary_lines() -> Array[String]:
    var lines: Array[String] = []
    for unit_data in _get_campaign_party_roster():
        var role_label: String = "Reserve"
        if unit_data.unit_id == &"ally_rian":
            role_label = "Core"
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

func _build_campaign_party_detail_entries() -> Array[Dictionary]:
    var details: Array[Dictionary] = []
    for unit_data in _get_campaign_party_roster():
        var default_skill_name: String = unit_data.default_skill.display_name if unit_data.default_skill != null else "No skill"
        var deploy_status: String = "Reserve"
        if unit_data.unit_id == &"ally_rian":
            deploy_status = "Core"
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
        var allowed_weapon_types: PackedStringArray = unit_data.get_allowed_weapon_types()
        var allowed_armor_types: PackedStringArray = unit_data.get_allowed_armor_types()
        var eligible_weapon_ids: Array[StringName] = _get_available_weapon_ids_for_unit(unit_data.unit_id)
        var eligible_armor_ids: Array[StringName] = _get_available_armor_ids_for_unit(unit_data.unit_id)
        details.append({
            "unit_id": String(unit_data.unit_id),
            "name": unit_data.display_name,
            "hp_text": "%d/%d" % [unit_data.max_hp, unit_data.max_hp],
            "status": deploy_status,
            "attack": unit_data.attack,
            "defense": unit_data.defense,
            "move": unit_data.movement,
            "range": unit_data.attack_range,
            "skill": default_skill_name,
            "weapon_slot": weapon_name,
            "armor_slot": armor_name,
            "accessory_slot": accessory_name,
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
        var unit_data: UnitData = CampaignCatalog.get_unit_data(unit_id)
        if unit_data != null:
            roster.append(unit_data)
    return roster

func _get_unit_data_by_id(unit_id: StringName) -> UnitData:
    return CampaignCatalog.get_unit_data(unit_id)

func _get_accessory_data_by_id(accessory_id: StringName) -> AccessoryData:
    return CampaignCatalog.get_accessory_data(accessory_id)

func _get_weapon_data_by_id(weapon_id: StringName) -> WeaponData:
    return CampaignCatalog.get_weapon_data(weapon_id)

func _get_armor_data_by_id(armor_id: StringName) -> ArmorData:
    return CampaignCatalog.get_armor_data(armor_id)

func _is_recruit_unlocked(unit_id: StringName) -> bool:
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
    if not _is_recruit_unlocked(unit_id):
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
        lines.append("%s — %s%s" % [accessory.display_name, accessory.summary, suffix])
    return lines

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

class_name CampaignContentRegistry
extends RefCounted

# ---------------------------------------------------------------------------
# Stage Reward Logs  (narrative reward text shown after each stage)
# ---------------------------------------------------------------------------

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

const CH06_STAGE_REWARD_LOG: Dictionary = {
    &"CH06_01": [
        "Forward gunline cache logged: Valtor approach routes secured."
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
        "Valtor handoff logged: Valgar fell, Ellyor relief orders were secured, and forge access unlocks later."
    ]
}

const CH07_STAGE_REWARD_LOG: Dictionary = {
    &"CH07_01": [
        "Market route logged: Ellyor's first rescue lane secured."
    ],
    &"CH07_02": [
        "Silence square cache logged: Memory Bell recovered from the silence-square watchpost."
    ],
    &"CH07_03": [
        "Procession break logged: Mira and Neri were pulled back from the nameless line, and Ellyor Procession Mail was secured."
    ],
    &"CH07_04": [
        "Cathedral channels logged: Knot Talisman secured in the hymn-channel reliquary."
    ],
    &"CH07_05": [
        "Ellyor handoff logged: Saria fell, Saria Mercy Staff and Namebound Thread were secured, sigil tuning unlocks later, and the black-hound route was secured."
    ]
}

const CH08_STAGE_REWARD_LOG: Dictionary = {
    &"CH08_01": [
        "Vanished trail cache logged: First black-hound pursuit route secured."
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
        "Black-hound handoff logged: Lete fell, the hidden-ruin truth was exposed, and the pursuit turns toward Kyle's outer line."
    ]
}

const CH09A_STAGE_REWARD_LOG: Dictionary = {
    &"CH09A_01": [
        "Outer-line cache logged: First capital checkpoint route secured."
    ],
    &"CH09A_02": [
        "Bridge cache logged: Bannerline Clasp secured from Kyle's bridge checkpoint."
    ],
    &"CH09A_03": [
        "Oath-hall cache logged: Nameless Watch Badge secured inside the oath hall."
    ],
    &"CH09A_04": [
        "Detention cache logged: Officer Rescue Cipher and Capital Witness Plate secured in the detention ledgers."
    ],
    &"CH09A_05": [
        "Broken standard handoff logged: Kyle joined, Standard Breaker Blade and the root-access seals were secured, and the inner archive route opens."
    ]
}

const CH09B_STAGE_REWARD_LOG: Dictionary = {
    &"CH09B_01": [
        "Root gate cache logged: First archive-core route secured."
    ],
    &"CH09B_02": [
        "Erased-shelf cache logged: Revision Ward Pin secured from the first revised shelf."
    ],
    &"CH09B_03": [
        "Last keeper handoff logged: Noah joined, Keeper Thread Seal was secured, and Noah's root staff was recovered."
    ],
    &"CH09B_04": [
        "Revision core logged: Archive Proof Relay and Revision Guard Cloak secured inside the revision core."
    ],
    &"CH09B_05": [
        "Abyss handoff logged: Melkion fell, the final memory was restored, and eclipse coordinates were secured."
    ]
}

const CH10_STAGE_REWARD_LOG: Dictionary = {
    &"CH10_01": [
        "Eclipse-eve cache logged: first tower supply route secured."
    ],
    &"CH10_02": [
        "Tower crest cache logged: Resonance Knot secured from the tower crest relay."
    ],
    &"CH10_03": [
        "Nameless corridor cache logged: Tower Ward Signet and Bellward Plate secured in the nameless corridor."
    ],
    &"CH10_04": [
        "Royal hall handoff logged: Bell Oath Relic and Eclipse Resonance Blade were secured, the first Karuon phase fell, and the chamber opens."
    ],
    &"CH10_05": [
        "Final resolution logged: Karuon fell, the bell was silenced, and the ending state is now set."
    ]
}

# ---------------------------------------------------------------------------
# Stage Cutscene Notes
# ---------------------------------------------------------------------------

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
        "The prison depths reveal surviving knights, quartermaster routes, and the first clear trail toward Ellyor.",
        "Even the supply rooms feel like a record of people being reduced to pieces of a fortress."
    ],
    &"CH06_04": [
        "The oath hall still remembers the plan that broke Valtor from within.",
        "The red annotations prove the worst timing was changed after the original route was drawn."
    ]
}

const CH07_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH07_01": [
        "The market proves people are choosing forgetting as often as they are being pushed into it.",
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

const CH09A_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH09A_01": [
        "The capital outer line is built to stop testimony before it can reach the city.",
        "Kyle still treats the line as duty, but every order now smells like erasure."
    ],
    &"CH09A_02": [
        "The bridge line proves Kyle learned formation from someone he still cannot stop recognizing.",
        "The first break in Kyle's loyalty comes from seeing that the line protects procedure more than people."
    ],
    &"CH09A_03": [
        "The nameless oath hall turns exhausted soldiers into evidence to be processed out of history.",
        "What looked like relief is revealed as orderly disappearance."
    ],
    &"CH09A_04": [
        "The abandoned officers are no longer comrades to save but witnesses to erase.",
        "Kyle sees his own command reclassified as expendable proof."
    ]
}

const CH09B_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH09B_01": [
        "The root gate admits the squad only because Kyle's proof and Noah's route overlap for a moment.",
        "The archive is not hidden because it is secret; it is hidden because it decides what counts as history."
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
        "Noah's presence is the only thing keeping the route from collapsing into blankness."
    ],
    &"CH10_04": [
        "Karuon still fights like a king before he becomes something larger and emptier than a throne.",
        "Breaking the first phase shatters the decrees, but not yet the bell that made them."
    ]
}

# ---------------------------------------------------------------------------
# Stage Memory Logs
# ---------------------------------------------------------------------------

const CH01_STAGE_MEMORY_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "mem_frag_ch01_first_order",
            "summary": "First Order: a cut command echoes over the burning field, but the speaker and intent stay unclear."
        }
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

const CH03_STAGE_MEMORY_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "mem_frag_ch03_forest_fire_order",
            "summary": "Forest Fire Order: Rian approved a firebreak plan that burned through Greenwood under imperial command."
        }
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

const CH05_STAGE_MEMORY_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "mem_frag_ch05_zero_revealed",
            "summary": "Zero Named: the archive finally names Rian as Zero, but the surrounding records show layers of later edits."
        }
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

const CH07_STAGE_MEMORY_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "mem_frag_ch07_zero_named_by_karon",
            "summary": "Zero Named by Karuon: the child without a name is given one that saves and binds at the same time."
        }
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

const CH09A_STAGE_MEMORY_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "mem_frag_ch09a_returning_names_seen",
            "summary": "Returning Names: Kyle remembers Zero as the officer who once said victory only mattered if names came home with it."
        }
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

const CH10_STAGE_MEMORY_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "mem_frag_ch10_final_choice",
            "summary": "Final Choice: Rian rejects peace by deletion and chooses a world where remembered pain can still lead to new choices."
        }
    ]
}

# ---------------------------------------------------------------------------
# Stage Evidence Logs
# ---------------------------------------------------------------------------

const CH01_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "flag_evidence_hardren_seal_obtained",
            "summary": "Hardren seal recovered; the ash-field command chain can be traced north toward the border evidence trail."
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

const CH03_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "flag_evidence_monastery_manifest_obtained",
            "summary": "Purification manifests and transfer notes point the pursuit toward the drowned monastery."
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

const CH05_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "flag_evidence_fortress_ledger_obtained",
            "summary": "Valtor siege ledgers and surviving-knight manifests point the march toward the iron fortress."
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

const CH07_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "flag_evidence_black_hound_orders_obtained",
            "summary": "Black-hound orders and hidden-ruin coordinates point the pursuit toward Lete's forest route."
        }
    ]
}

const CH08_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "flag_evidence_outer_gate_writ_obtained",
            "summary": "Special orders, checkpoint plates, and transfer slips now point the chase toward Kyle's outer defense line."
        }
    ]
}

const CH09A_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "flag_evidence_root_archive_pass_obtained",
            "summary": "Kyle's testimony, root-archive pass, and movement ledger now open the path toward the inner archive."
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

const CH10_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "flag_ending_resolution_recorded",
            "summary": "The bell stops, the tower lattice collapses, and the campaign resolves around what survives remembering."
        }
    ]
}

# ---------------------------------------------------------------------------
# Stage Letter Logs
# ---------------------------------------------------------------------------

const CH01_STAGE_LETTER_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "Letter from Serin",
            "summary": "\"The name on your scabbard is enough for now. We move north together and keep the survivors behind us safe.\""
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

const CH03_STAGE_LETTER_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "Tia's Uneasy Truce",
            "summary": "\"I do not forgive what your orders did here. I am still coming with you to see what remains.\""
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

const CH05_STAGE_LETTER_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "Enoch's Margin Note",
            "summary": "\"Memory is evidence, not sentence. The next fortress may still hold people who can prove the difference.\""
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

const CH07_STAGE_LETTER_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "Mira's Unsent Note",
            "summary": "\"I almost gave my child away to silence. I will remember that before I ask for mercy again.\""
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

const CH09A_STAGE_LETTER_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "Kyle's Broken Standard",
            "summary": "\"I am not changing sides for you. I am stepping across to see the inside with my own eyes.\""
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

const CH10_STAGE_LETTER_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "Neri's Clear Name",
            "summary": "\"My name is Neri. So please, do not forget any of us.\""
        }
    ]
}

# ---------------------------------------------------------------------------
# Accessory Unlock Tables
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Weapon Unlock Tables
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Armor Unlock Tables
# ---------------------------------------------------------------------------

const CH03_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH03_03": [&"ar_greenwood_cloak"]
}

const CH04_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH04_05": [&"ar_whiteflow_vestment"]
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

# ---------------------------------------------------------------------------
# Material Reward Table
# ---------------------------------------------------------------------------

const CHAPTER_MATERIAL_REWARDS: Dictionary = {
    &"ch02": [{"material_id": &"iron_frag", "count": 2}, {"material_id": &"coal", "count": 1}],
    &"ch03": [{"material_id": &"forest_essence", "count": 2}, {"material_id": &"fiber_bundle", "count": 1}],
    &"ch04": [{"material_id": &"sanctified_shard", "count": 2}, {"material_id": &"forest_essence", "count": 1}],
    &"ch05": [{"material_id": &"archive_ash", "count": 2}, {"material_id": &"coal", "count": 1}],
    &"ch06": [{"material_id": &"command_plate", "count": 2}, {"material_id": &"iron_frag", "count": 1}],
    &"ch07": [{"material_id": &"memory_thread", "count": 2}, {"material_id": &"forest_essence", "count": 1}],
    &"ch08": [{"material_id": &"memory_thread", "count": 1}, {"material_id": &"sanctified_shard", "count": 1}],
    &"ch09a": [{"material_id": &"iron_frag", "count": 1}, {"material_id": &"command_plate", "count": 1}],
    &"ch09b": [{"material_id": &"archive_ash", "count": 1}, {"material_id": &"memory_thread", "count": 1}],
    &"ch10": [{"material_id": &"sanctified_shard", "count": 1}, {"material_id": &"command_plate", "count": 1}]
}

# ---------------------------------------------------------------------------
# Interlude / Intro / Resolution Dialogues
# ---------------------------------------------------------------------------

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

const CH08_INTERLUDE_DIALOGUE: Array[String] = [
    "Tia: I do not forgive you. I am done pretending forgetting would help me breathe.",
    "Rian: Then we take what the ruin gave us and walk it straight into Kyle's line.",
    "Serin: Good. We carry the names forward and make the next wall answer for them."
]

const CH09A_INTRO_DIALOGUE: Array[String] = [
    "Kyle: The outer line still answers to me, even if the truth behind it has already rotted.",
    "Rian: Then we cross it and make the line tell us what it was built to hide.",
    "Bran: If the soldiers behind it are still ours, we pull them out before the censors burn them too."
]

const CH09A_INTERLUDE_DIALOGUE: Array[String] = [
    "Kyle: I am not done judging you. I am done letting the censors decide what survives us.",
    "Rian: Then walk with us into the archive and judge what remains there.",
    "Bran: Good. Bring your witness, not your banner."
]

const CH09B_INTRO_DIALOGUE: Array[String] = [
    "Noah: The gate was never the hard part. The hard part was waiting for the right version of you to arrive here.",
    "Rian: Then we finish this before the archive edits the last reason to remember anything.",
    "Enoch: Melkion already has the shelves moving. Every step deeper is a fight against arrangement itself."
]

const CH09B_INTERLUDE_DIALOGUE: Array[String] = [
    "Noah: The final memory gives context, not forgiveness.",
    "Rian: Good. I need the truth sharp enough to carry into the tower.",
    "Kyle: Then we stop reading the archive and start answering the king who needed it."
]

const CH10_INTRO_DIALOGUE: Array[String] = [
    "Serin: This is the last climb. No one leaves their name behind here.",
    "Rian: Then we carry every name we saved all the way to the bell.",
    "Noah: The tower remembers the eclipse. We only need to make it remember people instead."
]

const CH10_RESOLUTION_DIALOGUE: Array[String] = [
    "Serin: It did not end. We kept it here, together.",
    "Bran: Then the names that survived this tower are the only wall worth rebuilding.",
    "Tia: It still hurts. I am still here.",
    "Enoch: No one gets edited out of this ending.",
    "Kyle: A name survived the march back. That is enough to start from.",
    "Noah: This time, memory left people standing."
]

# ---------------------------------------------------------------------------
# Presentation Cards
# ---------------------------------------------------------------------------

const CAMP_PRESENTATION_CARDS: Dictionary = {
    &"CH01": [
        {
            "eyebrow": "Ally",
            "title": "Serin Steps Into The Line",
            "body": "Serin is no longer a temporary escort. The camp handoff now treats her as a full ally tied directly to the next route."
        },
        {
            "eyebrow": "Memory",
            "title": "First Order Surfaces",
            "body": "The first recovered command fragment confirms that Rian's battlefield instincts are tied to a real chain of orders, not only instinct."
        },
        {
            "eyebrow": "Evidence",
            "title": "Hardren Seal Points North",
            "body": "The recovered seal and route evidence now anchor the border pursuit. The next handoff is driven by proof, not guesswork."
        }
    ],
    &"CH02": [
        {
            "eyebrow": "Ally",
            "title": "Bran Holds The Line",
            "body": "Bran's distrust remains, but the fortress handoff locks him into the active roster and shifts the squad into a harder military rhythm."
        },
        {
            "eyebrow": "Memory",
            "title": "Hardren Routes Feel Familiar",
            "body": "Rian reads fortress lanes too quickly for a stranger, and the campaign now frames that knowledge as a concrete warning sign."
        }
    ],
    &"CH03": [
        {
            "eyebrow": "Ally",
            "title": "Tia Tests The Party",
            "body": "The Greenwood handoff turns Tia from a wary forest contact into a rostered ally with her own read on the route ahead."
        },
        {
            "eyebrow": "Evidence",
            "title": "The Fire Was Planned",
            "body": "The basin route is no longer only wilderness travel. The event handoff now frames the wildfire residue as proof of deliberate command."
        }
    ],
    &"CH04": [
        {
            "eyebrow": "Memory",
            "title": "Ark Research Resurfaces",
            "body": "The monastery handoff turns recovered research into an explicit transition card, making the experiment trail feel like evidence rather than flavor text."
        },
        {
            "eyebrow": "Evidence",
            "title": "Gray Archive Route Confirmed",
            "body": "Transfer ledgers and seals now point cleanly toward the Gray Archive, so the next chapter handoff reads like a deliberate chase of records."
        }
    ],
    &"CH05": [
        {
            "eyebrow": "Ally",
            "title": "Enoch Names Zero",
            "body": "The archive handoff now treats Enoch's arrival and the first explicit naming of Zero as a runtime reveal rather than a plain summary bullet."
        },
        {
            "eyebrow": "Evidence",
            "title": "Valtor Ledgers Point Forward",
            "body": "Siege ledgers and surviving-knight rolls are surfaced as a concrete handoff card that carries the march directly toward the iron fortress."
        }
    ],
    &"CH06": [
        {
            "eyebrow": "Memory",
            "title": "Valtor Breach Remembered",
            "body": "The fortress breach memory is now framed as a deliberate handoff card so the next chapter reads like a military escalation, not only a text recap."
        },
        {
            "eyebrow": "Evidence",
            "title": "Ellyor Relief Route Opens",
            "body": "Relief edicts and civilian transfer records now point cleanly toward Ellyor, making the city transition explicit in camp."
        }
    ],
    &"CH07": [
        {
            "eyebrow": "Evidence",
            "title": "Black-Hound Orders Surface",
            "body": "The nameless-city handoff now frames the recovered black-hound orders as the chapter's main proof object instead of leaving them buried in the summary paragraph."
        },
        {
            "eyebrow": "Route",
            "title": "The Forest Trail Turns Back",
            "body": "The capital route now explicitly bends back toward the forest ruins, so the next hunt reads as a sharp tactical turn instead of a vague continuation."
        }
    ],
    &"CH08": [
        {
            "eyebrow": "Defense",
            "title": "Kyle's Outer Line Identified",
            "body": "The black-hound pursuit now hands off into Kyle's outer line through a dedicated presentation card, making the strategic pivot visible at a glance."
        },
        {
            "eyebrow": "Hunt",
            "title": "Lete's Route Confirmed",
            "body": "The forest and ruin evidence now resolves into a named pursuit path, tying the chapter's end cleanly into the next defense front."
        }
    ],
    &"CH09A": [
        {
            "eyebrow": "Ally",
            "title": "Kyle Opens The Root Route",
            "body": "Kyle's testimony and broken-standard handoff now land as a dedicated transition card, making his alliance feel like a structural shift in the campaign."
        },
        {
            "eyebrow": "Archive",
            "title": "Discarded Officers Are Named",
            "body": "The route into the root archive now carries the weight of the discarded-officer records as an explicit handoff object."
        }
    ],
    &"CH09B": [
        {
            "eyebrow": "Ally",
            "title": "Noah Fixes The Archive Route",
            "body": "The abyss handoff now makes Noah's presence and the final archive-route alignment feel like a concrete arrival, not only a summary line."
        },
        {
            "eyebrow": "Destination",
            "title": "The Final Tower Is Confirmed",
            "body": "Eclipse coordinates and tower lattice are now framed as the final transition object, tightening the handoff into CH10."
        }
    ]
}

const RESOLUTION_PRESENTATION_CARDS: Dictionary = {
    &"CH10": [
        {
            "eyebrow": "Resolution",
            "title": "The Bell Falls Silent",
            "body": "The final resolution now reads as a concrete runtime handoff: Karuon falls, the bell stops, and the tower loses its right to decide what survives."
        },
        {
            "eyebrow": "Memory",
            "title": "Names Remain Shared",
            "body": "The ending state now frames survival through shared memory instead of erased authority, turning the finale into a readable conclusion rather than only a summary paragraph."
        }
    ]
}

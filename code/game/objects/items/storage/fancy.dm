/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Cigarette Box
 *		Cigar Case
 *		Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	desc = "Mmm. Donuts."
	resistance_flags = FLAMMABLE
	var/icon_type = "donut"
	var/spawn_type = null
	var/fancy_open = FALSE

/obj/item/storage/fancy/PopulateContents()
	GET_COMPONENT(STR, /datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/fancy/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/fancy/examine(mob/user)
	..()
	if(fancy_open)
		if(length(contents) == 1)
			to_chat(user, "There is one [icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left.")

/obj/item/storage/fancy/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/fancy/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/fancy/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	icon_type = "donut"
	name = "donut box"
	spawn_type = /obj/item/reagent_containers/food/snacks/donut
	fancy_open = TRUE

/obj/item/storage/fancy/donut_box/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/food/snacks/donut))

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon = 'icons/obj/food/containers.dmi'
	item_state = "eggbox"
	icon_state = "eggbox"
	icon_type = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	name = "egg box"
	desc = "A carton for containing eggs."
	spawn_type = /obj/item/reagent_containers/food/snacks/egg

/obj/item/storage/fancy/egg_box/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 12
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/food/snacks/egg))

/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/candle
	fancy_open = TRUE

/obj/item/storage/fancy/candle_box/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 5

/obj/item/storage/fancy/candle_box/attack_self(mob_user)
	return

////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "\improper Lucky Strikes packet"
	desc = "The most popular brand of cigarettes, sponsors of the Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_BELT
	icon_type = "cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/space_cigarette

/obj/item/storage/fancy/cigarettes/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 6
	STR.can_hold = typecacheof(list(/obj/item/clothing/mask/cigarette, /obj/item/lighter))

/obj/item/storage/fancy/cigarettes/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to extract contents.</span>")

/obj/item/storage/fancy/cigarettes/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/obj/item/clothing/mask/cigarette/W = locate(/obj/item/clothing/mask/cigarette) in contents
	if(W && contents.len > 0)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, user)
		user.put_in_hands(W)
		contents -= W
		to_chat(user, "<span class='notice'>You take \a [W] out of the pack.</span>")
	else
		to_chat(user, "<span class='notice'>There are no [icon_type]s left in the pack.</span>")

/obj/item/storage/fancy/cigarettes/update_icon()
	if(fancy_open || !contents.len)
		cut_overlays()
		if(!contents.len)
			icon_state = "[initial(icon_state)]_empty"
		else
			icon_state = initial(icon_state)
			add_overlay("[icon_state]_open")
			var/cig_position = 1
			for(var/C in contents)
				var/mutable_appearance/inserted_overlay = mutable_appearance(icon)

				if(istype(C, /obj/item/lighter/greyscale))
					inserted_overlay.icon_state = "lighter_in"
				else if(istype(C, /obj/item/lighter))
					inserted_overlay.icon_state = "zippo_in"
				else
					inserted_overlay.icon_state = "cigarette"

				inserted_overlay.icon_state = "[inserted_overlay.icon_state]_[cig_position]"
				add_overlay(inserted_overlay)
				cig_position++
	else
		cut_overlays()

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ismob(M))
		return
	var/obj/item/clothing/mask/cigarette/cig = locate(/obj/item/clothing/mask/cigarette) in contents
	if(cig)
		if(M == user && contents.len > 0 && !user.wear_mask)
			var/obj/item/clothing/mask/cigarette/W = cig
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, M)
			M.equip_to_slot_if_possible(W, SLOT_WEAR_MASK)
			contents -= W
			to_chat(user, "<span class='notice'>You take \a [W] out of the pack.</span>")
		else
			..()
	else
		to_chat(user, "<span class='notice'>There are no [icon_type]s left in the pack.</span>")

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper Winfield Packet"
	desc = "A packet of six pre-war imported Winfield Australian cigarettes. A label on the packaging reads, \"...anyhow, have a Winfield\""
	icon_state = "dromedary"
	spawn_type = /obj/item/clothing/mask/cigarette/dromedary

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Kings packet"
	desc = "Only a king could afford the treatment after smoking these."
	icon_state = "uplift"
	spawn_type = /obj/item/clothing/mask/cigarette/uplift

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Marlboro packet"
	desc = "Smoked by the best."
	icon_state = "robust"
	spawn_type = /obj/item/clothing/mask/cigarette/robust

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Marlboro Gold packet"
	desc = "Smoked by the very best."
	icon_state = "robustg"
	spawn_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Viceroy packet."
	desc = "Since 1913."
	icon_state = "carp"
	spawn_type = /obj/item/clothing/mask/cigarette/carp

/obj/item/storage/fancy/cigarettes/cigpack_syndicate //not in vending machines at time of writing 14/02/19
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndie"
	spawn_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Sakura packet"
	desc = "You can't understand the letters, but the packet smells funny."
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/nicotine

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims //same as syndi
	name = "\improper Shady Jim's Super Slims packet"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_xeno //same as syndi
	name = "\improper Xeno Filtered packet"
	desc = "Loaded with 100% pure slime. And also nicotine."
	icon_state = "slime"
	spawn_type = /obj/item/clothing/mask/cigarette/xeno

/obj/item/storage/fancy/cigarettes/cigpack_cannabis //same as syndi
	name = "\improper Freak Brothers' Special packet"
	desc = "A label on the packaging reads, \"Endorsed by Phineas, Freddy and Franklin.\""
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/cannabis

/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker //same as syndi
	name = "\improper Leary's Delight packet"
	desc = "Banned in over 36 galaxies."
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/mindbreaker

/obj/item/storage/fancy/cigarettes/cigpack_bigboss
	name = "\improper Big Boss Smokes"
	desc = "For the big man, you need big boss smokes!."
	icon_state = "bigboss"
	spawn_type = /obj/item/clothing/mask/cigarette/bigboss

/obj/item/storage/fancy/cigarettes/cigpack_pyramid
	name = "\improper Pyramid Smokes"
	desc = "For the fine mans Smoke."
	icon_state = "pyramid"
	spawn_type = /obj/item/clothing/mask/cigarette/pyramid

/obj/item/storage/fancy/cigarettes/cigpack_greytort
	name = "\improper Grey Tortoise Smokes"
	desc = "Imported famous cigarettes from the East Coast."
	icon_state = "greytort"
	spawn_type = /obj/item/clothing/mask/cigarette/greytort

/obj/item/storage/fancy/rollingpapers //this IS in vending machines need coins
	name = "rolling paper pack"
	desc = "A pack of rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	icon_type = "rolling paper"
	spawn_type = /obj/item/rollingpaper

/obj/item/storage/fancy/rollingpapers/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 10
	STR.can_hold = typecacheof(list(/obj/item/rollingpaper))

/obj/item/storage/fancy/rollingpapers/update_icon()
	cut_overlays()
	if(!contents.len)
		add_overlay("[icon_state]_empty")

/////////////
//CIGAR BOX//
/////////////

/obj/item/storage/fancy/cigarettes/cigars //in machine, need coin
	name = "\improper premium cigar case"
	desc = "A case of premium cigars. Very expensive."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	w_class = WEIGHT_CLASS_NORMAL
	icon_type = "premium cigar"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar

/obj/item/storage/fancy/cigarettes/cigars/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 5
	STR.can_hold = typecacheof(list(/obj/item/clothing/mask/cigarette/cigar))

/obj/item/storage/fancy/cigarettes/cigars/update_icon()
	cut_overlays()
	if(fancy_open)
		icon_state = "[initial(icon_state)]_open"

		var/cigar_position = 1 //generate sprites for cigars in the box
		for(var/obj/item/clothing/mask/cigarette/cigar/smokes in contents)
			var/mutable_appearance/cigar_overlay = mutable_appearance(icon, "[smokes.icon_off]_[cigar_position]")
			add_overlay(cigar_overlay)
			cigar_position++

	else
		icon_state = "[initial(icon_state)]"

/obj/item/storage/fancy/cigarettes/cigars/cohiba //this IS in vending machines, need coin
	name = "\improper cohiba robusto cigar case"
	desc = "A case of imported Cohiba cigars, renowned for their strong flavor."
	icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/storage/fancy/cigarettes/cigars/havana //this IS in vending machines, need coin
	name = "\improper premium havanian cigar case"
	desc = "A case of classy Havanian cigars."
	icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/havana

/*
 * Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = "A heart-shaped box for holding tiny chocolates."
	icon = 'icons/obj/food/containers.dmi'
	item_state = "chocolatebox"
	icon_state = "chocolatebox"
	icon_type = "chocolate"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	spawn_type = /obj/item/reagent_containers/food/snacks/tinychocolate

/obj/item/storage/fancy/heart_box/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 8
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/food/snacks/tinychocolate))

//fonky shotgun bullet

/obj/item/storage/box/rubbershot
	name = "box of rubber shots"
	desc = "A box full of rubber shots, designed for riot shotguns."
	icon = 'icons/obj/ammo.dmi'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	var/icon_type = "b"
	var/spawn_type = /obj/item/ammo_casing/shotgun/rubbershot
	var/fancy_open = FALSE

/obj/item/storage/box/rubbershot/PopulateContents()
	GET_COMPONENT(STR, /datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/box/rubbershot/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/box/rubbershot/examine(mob/user)
	..()
	if(fancy_open)
		if(length(contents) == 1)
			to_chat(user, "There is one [icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left.")

/obj/item/storage/box/rubbershot/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/box/rubbershot/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/rubbershot/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/rubbershot/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 14
	STR.can_hold = typecacheof(list(/obj/item/ammo_casing/shotgun/rubbershot))

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/storage/box/rubbershot/beanbag
	name = "box of beanbag slugs"
	desc = "A box full of beanbag slugs, designed for riot shotguns."
	icon = 'icons/obj/ammo.dmi'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	icon_type = "stun"
	spawn_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/storage/box/rubbershot/beanbag/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 14
	STR.can_hold = typecacheof(list(/obj/item/ammo_casing/shotgun/beanbag))

/obj/item/storage/box/lethalshot
	name = "box of buckshot shotgun shots"
	desc = "A box full of lethal buckshot rounds, designed for riot shotguns."
	icon = 'icons/obj/ammo.dmi'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	var/icon_type = "g"
	var/spawn_type = /obj/item/ammo_casing/shotgun/buckshot
	var/fancy_open = FALSE

/obj/item/storage/box/lethalshot/PopulateContents()
	GET_COMPONENT(STR, /datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/box/lethalshot/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/box/lethalshot/examine(mob/user)
	..()
	if(fancy_open)
		if(length(contents) == 1)
			to_chat(user, "There is one [icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left.")

/obj/item/storage/box/lethalshot/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/box/lethalshot/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/lethalshot/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/lethalshot/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 14
	STR.can_hold = typecacheof(list(/obj/item/ammo_casing/shotgun/buckshot))

/obj/item/storage/box/magnumshot
	name = "box of magnum buckshot shotgun shots"
	desc = "A box full of lethal magnum buckshot rounds, designed for hunting shotguns."
	icon = 'icons/obj/ammo.dmi'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	var/icon_type = "g"
	var/spawn_type = /obj/item/ammo_casing/shotgun/magnumshot
	var/fancy_open = FALSE

/obj/item/storage/box/magnumshot/PopulateContents()
	GET_COMPONENT(STR, /datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/box/magnumshot/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/box/magnumshot/examine(mob/user)
	..()
	if(fancy_open)
		if(length(contents) == 1)
			to_chat(user, "There is one [icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left.")

/obj/item/storage/box/magnumshot/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/box/magnumshot/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/magnumshot/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/magnumshot/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 14
	STR.can_hold = typecacheof(list(/obj/item/ammo_casing/shotgun/magnumshot))


/obj/item/storage/box/slugshot
	name = "box of slug shotgun shots"
	desc = "A box full of slug rounds, designed for riot shotguns."
	icon = 'icons/obj/ammo.dmi'
	var/icon_type = "l"
	var/spawn_type = /obj/item/ammo_casing/shotgun
	var/fancy_open = FALSE

/obj/item/storage/box/slugshot/PopulateContents()
	GET_COMPONENT(STR, /datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/box/slugshot/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/box/slugshot/examine(mob/user)
	..()
	if(fancy_open)
		if(length(contents) == 1)
			to_chat(user, "There is one [icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left.")

/obj/item/storage/box/slugshot/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/box/slugshot/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/slugshot/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/slugshot/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 14
	STR.can_hold = typecacheof(list(/obj/item/ammo_casing/shotgun))

/obj/item/storage/box/beanbag
	name = "box of beanbags"
	desc = "A box full of beanbag shells."
	icon = 'icons/obj/ammo.dmi'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	var/icon_type = "stun"
	var/spawn_type = /obj/item/ammo_casing/shotgun/beanbag
	var/fancy_open = FALSE

/obj/item/storage/box/beanbag/PopulateContents()
	GET_COMPONENT(STR, /datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/box/beanbag/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/box/beanbag/examine(mob/user)
	..()
	if(fancy_open)
		if(length(contents) == 1)
			to_chat(user, "There is one [icon_type] left.")
		else
			to_chat(user, "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left.")

/obj/item/storage/box/beanbag/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/box/beanbag/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/beanbag/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/box/beanbag/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 14
	STR.can_hold = typecacheof(list(/obj/item/ammo_casing/shotgun/beanbag))

//Rings//

/obj/item/storage/fancy/ringbox
	name = "ring box"
	desc = "A tiny box covered in soft red felt made for holding rings."
	icon = 'icons/obj/ring.dmi'
	icon_state = "gold ringbox"
	icon_type = "gold ring"
	w_class = WEIGHT_CLASS_TINY
	spawn_type = /obj/item/clothing/gloves/ring

/obj/item/storage/fancy/ringbox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.can_hold = typecacheof(list(/obj/item/clothing/gloves/ring))

/obj/item/storage/fancy/ringbox/diamond
	icon_state = "diamond ringbox"
	icon_type = "diamond ring"
	spawn_type = /obj/item/clothing/gloves/ring/diamond

/obj/item/storage/fancy/ringbox/silver
	icon_state = "silver ringbox"
	icon_type = "silver ring"
	spawn_type = /obj/item/clothing/gloves/ring/silver
# combat.R: One hostile encounter: fight() or flee().
# Used by event_hostile() in campus.R and by run_finale().
# Uses ask_choice(), luck_check(), luck_scale(), apply_effect(), and STAT_COLS
# from main.R, and FLEE_CHANCE, CRIT_CHANCE, CRIT_MULT, DAMAGE_SD, MIN_DAMAGE,
# LUCKY_TAIL, and campus_buffs from campus_data.R.

# combat.R: Fight until one side drops or the player flees.
# Input: player. enemy = rows of monsters or bosses: one row for a campus
#        monster, several rows for enemies fought at the same time (finale).
#        Any list with name, hp, atk, def, and spd also works as one enemy.
#        can_flee = FALSE bans fleeing (the finale): the player is told once
#        that there is nowhere to flee and the Flee option is hidden.
# On each of their turns the player may also use one item. That does not
# use up the turn, see use_item(). Items cannot be used on an enemy's turn:
# the menu only appears on the player's turn.
# If an item changes the player's spd, the turn order starts over from the
# current spd of both sides as soon as that turn ends.
# Return: list(player = updated player, outcome = "win", "loss", or "fled").
#         "win" means every enemy row is at 0 hp.
#         On "loss" the returned player has hp 0.
#         On "fled" the caller applies flee() to the returned player.
#         "fled" never happens when can_flee is FALSE.
fight <- function(player, enemy, can_flee = TRUE) {
  # fighters[id + 1] is the name that goes with a turn_order() id.
  fighters <- c("You", enemy$name)
  enemy_max_hp <- enemy$hp

  cat("\nEncounter:", paste(enemy$name, collapse = " and "), "\n")
  cat("  You: atk ", player$atk, " | def ", player$def, " | spd ", player$spd,
      "\n", sep = "")
  for (i in seq_along(enemy$hp)) {
    cat("  ", enemy$name[i], ": atk ", enemy$atk[i], " | def ", enemy$def[i],
        " | spd ", enemy$spd[i], "\n", sep = "")
  }
  show_fight_hp(player, enemy, enemy_max_hp)
  if (!can_flee) {
    cat("There is nowhere to flee!\n")
  }

  # Plan the turns once. If the fight outlasts the plan, plan twice as many:
  # turn_order() always counts from the start of the fight, so the turns
  # already played stay the same.
  order <- turn_order(player$spd, enemy$spd, 50L)
  cat("Turn order:", paste(fighters[order[1:8] + 1L], collapse = " > "),
      "> ...\n")
  turn <- 0L
  planned_spd <- player$spd

  repeat {
    # If an item changed the player's spd, the turn they used it in has now
    # ended. Start the order over from the current spd of both sides.
    if (player$spd != planned_spd) {
      planned_spd <- player$spd
      order <- turn_order(player$spd, enemy$spd, 50L)
      turn <- 0L
      cat("\nYour spd is now ", player$spd, ". New turn order: ",
          paste(fighters[order[1:8] + 1L], collapse = " > "), " > ...\n",
          sep = "")
    }

    turn <- turn + 1L
    if (turn > length(order)) {
      order <- turn_order(player$spd, enemy$spd, 2L * length(order))
    }
    actor <- order[turn]

    if (actor == 0L) {
      # The player's turn: attack one enemy or try to run.
      cat("\nYour turn.\n")
      # Flee is hidden when it is banned, and Use item once an item has been
      # used this turn. Using an item comes back to this menu: the turn only
      # ends with Attack or Flee.
      item_used <- FALSE
      repeat {
        choice <- ask_choice(c("Attack", "Flee", "Use item"),
                             show = c(TRUE, can_flee, !item_used))
        if (choice != 3L) {
          break
        }

        result <- use_item(player)
        player <- result$player
        item_used <- result$used
        if (item_used) {
          show_fight_hp(player, enemy, enemy_max_hp)
        }
      }

      if (choice == 2L) {
        if (luck_check(player, FLEE_CHANCE)) {
          cat("You got away.\n")
          return(list(player = player, outcome = "fled"))
        }
        # GROUP DECISION: what a failed flee attempt costs. For now it costs
        # this turn and nothing else, so the enemies simply keep their turns.
        cat("You could not get away. You lose this turn.\n")
        next
      }

      alive <- which(enemy$hp > 0L)
      target <- alive[1]
      if (length(alive) > 1L) {
        cat("Who do you attack?\n")
        picked <- ask_choice(paste0(enemy$name[alive], " (", enemy$hp[alive],
                                    " hp)"))
        target <- alive[picked]
      }

      hit <- calc_damage(player$atk, enemy$def[target], player$luck)
      enemy$hp[target] <- max(0L, enemy$hp[target] - hit$damage)
      report_hit(hit, enemy$name[target], by_player = TRUE)
      show_fight_hp(player, enemy, enemy_max_hp)

      if (enemy$hp[target] == 0L) {
        cat(enemy$name[target], "is down.\n")
      }
      if (all(enemy$hp == 0L)) {
        cat("You defeated", paste(enemy$name, collapse = " and "), "\n")
        return(list(player = player, outcome = "win"))
      }
    } else {
      # An enemy's turn. An enemy at 0 hp has turns in the plan but skips them.
      if (enemy$hp[actor] == 0L) {
        next
      }

      # Enemies have no luck, so calc_damage() keeps its default of 0.
      hit <- calc_damage(enemy$atk[actor], player$def)
      player$hp <- max(0L, player$hp - hit$damage)
      cat("\n")
      report_hit(hit, enemy$name[actor], by_player = FALSE)
      show_fight_hp(player, enemy, enemy_max_hp)

      if (player$hp == 0L) {
        cat("You were defeated by", enemy$name[actor], "\n")
        return(list(player = player, outcome = "loss"))
      }
    }
  }
}

# combat.R: The price of a successful flee.
# The player never dies from fleeing but always gets one random debuff.
# Input: player who just fled. Return: the updated player list.
flee <- function(player) {
  debuffs <- campus_buffs[campus_buffs$type == "debuff", ]
  debuff <- debuffs[sample(nrow(debuffs), 1), ]

  before <- player
  player <- apply_effect(player, debuff, luck_scale(player, "debuff"))
  # Fleeing never kills, whatever the debuff does to hp.
  player$hp <- max(1L, player$hp)
  player$buffs <- c(player$buffs, debuff$name)

  cat("Fleeing cost you: ", debuff$name, ". ", debuff$description, "\n",
      sep = "")
  # Show what the debuff really changed. LUCK can shrink it, see luck_scale().
  show_stat_change(before, player)

  player
}

# combat.R: The "Use item" option of a fight. Shows the whole inventory and
# lets the player use one consumable item from it, or go back.
# An item is consumable if its row in prep_perks or shop_items says so.
# Using it applies its row with apply_effect() and removes it from the
# inventory. fight() only calls this on the player's turn, and restarts the
# turn order after that turn if the item changed spd.
# Input: player.
# Return: list(player = updated player, used = TRUE if an item was used).
use_item <- function(player) {
  inventory <- player$inventory
  cat("Inventory:",
      if (length(inventory) > 0L) paste(inventory, collapse = ", ") else "empty",
      "\n")

  # One table of every item in the game, to look the inventory names up in.
  cols <- c("name", "description", "consumable", STAT_COLS)
  items <- rbind(prep_perks[cols], shop_items[cols])
  rows <- match(inventory, items$name)
  usable <- !is.na(rows) & items$consumable[rows]

  if (!any(usable)) {
    cat("Nothing here can be used in a fight.\n")
    return(list(player = player, used = FALSE))
  }

  # Offer only the consumable entries, plus a way out.
  options <- c(paste0(inventory, ": ", items$description[rows]), "Back")
  picked <- ask_choice(options, show = c(usable, TRUE))
  if (picked == length(options)) {
    return(list(player = player, used = FALSE))
  }

  before <- player
  player <- apply_effect(player, items[rows[picked], ])
  player$inventory <- inventory[-picked]
  cat("You used ", inventory[picked], ".\n", sep = "")
  show_stat_change(before, player)

  list(player = player, used = TRUE)
}

# combat.R: Print which stats changed between two versions of the player,
# for example "  hp +40, spd -10". Prints nothing if none did.
# Input: before and after = the player list. Return: nothing.
show_stat_change <- function(before, after) {
  change <- unlist(after[STAT_COLS]) - unlist(before[STAT_COLS])
  changed <- change != 0
  if (any(changed)) {
    cat("  ", paste0(STAT_COLS[changed], " ", sprintf("%+d", change[changed]),
                     collapse = ", "), "\n", sep = "")
  }

  invisible(NULL)
}

# combat.R: Damage of one hit.
# The hit is drawn from a normal distribution whose median is atk and whose
# standard deviation is DAMAGE_SD * atk. The defender's def then blocks a
# percent of it.
# Input: atk of the attacker, def of the defender (a percent), and the
#        attacker's luck. Enemies have no luck, so leave it at 0 for them.
# Return: list(damage = whole number, never less than MIN_DAMAGE,
#              p      = cdf of the draw, between 0 and 1: the share of this
#                       attacker's hits that would have been weaker,
#              crit   = TRUE or FALSE).
calc_damage <- function(atk, def, luck = 0L) {
  z <- rnorm(1)                      # one standard normal draw
  p <- pnorm(z)                      # where that draw sits in the distribution
  roll <- atk * (1 + DAMAGE_SD * z)  # the same draw on the damage scale

  # A crit comes on top of the draw, so p still describes the draw alone.
  crit <- luck_check(list(luck = luck), CRIT_CHANCE)
  if (crit) {
    roll <- roll * CRIT_MULT
  }

  # A negative def (a debuff) lets more damage through. More than 100 would
  # turn a hit into healing, so it stops there.
  blocked <- min(def, 100) / 100
  damage <- max(MIN_DAMAGE, as.integer(round(roll * (1 - blocked))))

  list(damage = damage, p = p, crit = crit)
}

# combat.R: Who acts in each of the first n_turns turns of a fight, based on SPD.
# Honkai: Star Rail style. A fighter acts once every 10000 / spd units of
# time, so a faster one sometimes acts twice in a row. When two fighters act
# at the same time the player goes first, then the enemies in row order.
# It always counts from the start of the fight, so call it once per fight,
# not once per turn.
# Input: player_spd. enemy_spd = one spd per enemy row. n_turns.
# Return: whole-number vector of length n_turns. 0 means the player acts,
#         1 means the first enemy row acts, 2 the second, and so on.
turn_order <- function(player_spd, enemy_spd, n_turns) {
  # A spd of 0 or less would never act, so treat it as the slowest possible.
  spd <- pmax(c(player_spd, enemy_spd), 1L)
  ids <- c(0L, seq_along(enemy_spd))

  # The first n_turns action times of every fighter, one fighter after the
  # other. No fighter can need more than n_turns of them.
  times <- as.vector(outer(seq_len(n_turns), 10000 / spd))
  who <- rep(ids, each = n_turns)

  # Rounding keeps tiny decimal errors from deciding a tie the wrong way.
  who[order(round(times, 6), who)][seq_len(n_turns)]
}

# combat.R: Print one hit: the damage, a crit note, and a lucky or unlucky
# note when the draw landed in the lowest or highest LUCKY_TAIL of its
# distribution. Lucky and unlucky are from the player's side: the player's
# strong hit and an enemy's weak hit are both lucky.
# Input: hit = what calc_damage() returned. enemy_name = the enemy hit or
#        hitting. by_player = TRUE if the player dealt the hit.
# Return: nothing, it only prints.
report_hit <- function(hit, enemy_name, by_player) {
  if (by_player) {
    cat("You hit", enemy_name, "for", hit$damage, "damage.")
    whose <- "your"
  } else {
    cat(enemy_name, "hits you for", hit$damage, "damage.")
    whose <- paste0(enemy_name, "'s")
  }
  cat(if (hit$crit) " Critical hit!\n" else "\n")

  strong <- hit$p > 1 - LUCKY_TAIL
  weak <- hit$p < LUCKY_TAIL
  if (strong || weak) {
    cat(if (strong == by_player) "Lucky!" else "Unlucky.",
        "That was one of", whose, if (strong) "hardest" else "weakest",
        "hits.\n")
  }

  invisible(NULL)
}

# combat.R: Print the current hp of everyone in the fight on one line.
# Input: player. enemy = the enemy rows. enemy_max_hp = their hp when the
#        fight started. Return: nothing, it only prints.
show_fight_hp <- function(player, enemy, enemy_max_hp) {
  cat("  HP: You ", player$hp, "/", player$max_hp,
      paste0(" | ", enemy$name, " ", enemy$hp, "/", enemy_max_hp,
             collapse = ""),
      "\n", sep = "")

  invisible(NULL)
}

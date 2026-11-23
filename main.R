# UCLA Halloween Horror — Group 49 prototype
# In RStudio, set the working directory to this folder
# (Session > Set Working Directory > To Source File Location),
# source this file, then run play_game() in the Console.
# To test your own version of a module, source it after main.R.
# The design these files follow is in docs/dev_README.Rmd.
#
# Changed since docs/Guide.docx: the stat is atk, not attack, for the player
# and for enemies. fight() can also return outcome "fled". The temporary
# versions now live in prep.R, combat.R, campus.R, and finale.R, and main.R
# sources them at the bottom of this file.
#
# File map. Level data is kept apart from the code that talks to the player.
#   main.R         new_player(), ask_choice(), shared helpers, play_game()
#   prep_data.R    PREP_ROUNDS, prep_locations, prep_perks
#   prep.R         run_prep()
#   campus_data.R  event settings, monsters, campus_buffs, choice_events, shop_items
#   campus.R       run_campus() and the three event types
#   combat.R       fight(), flee()
#   finale_data.R  finale_intro, bosses
#   finale.R       run_finale()

# main.R: Stat names shared by the player and the data tables.
# In prep_perks, campus_buffs, and shop_items these columns are changes
# that apply_effect() adds to the player.
# In monsters and bosses, hp, atk, def, and spd are the enemy's own stats.
# Every stat is a whole number (integer) at all times.
STAT_COLS <- c("hp", "max_hp", "atk", "def", "spd", "luck")

# main.R: Shared player state. Agree on new fields as a group.
# The starting numbers are placeholders for Texts & Numbers to set.
new_player <- function() {
  list(
    hp = 100L,                 # Current hp. run_campus() resets it to max_hp
    max_hp = 100L,             # Range 100 to 1000
    atk = 20L,                 # Median of the random damage of one hit
    def = 0L,                  # Percent of incoming damage blocked
    spd = 100L,                # Turn order in fights, length of the campus walk
    luck = 0L,                 # Flee success, crit rate, size of event effects
    money = 10L,               # Mostly for prep perks. Campus shops are rare
    inventory = character(0),  # Item and perk names
    buffs = character(0)       # Buff and debuff names
  )
}

# main.R: Show a numbered menu and return a valid choice.
ask_choice <- function(options) {
  numbers <- seq_along(options)
  cat(paste0(numbers, ". ", options), sep = "\n")

  repeat {
    answer <- trimws(readline("Choose a number: "))
    choice <- match(answer, as.character(numbers))

    if (!is.na(choice)) {
      return(choice)
    }

    cat("Please enter one of the listed numbers.\n")
  }
}

# main.R: Print the player's current stats and money.
# Input: player. Return: nothing, it only prints.
show_status <- function(player) {
  # TODO: print hp / max_hp, atk, def, spd, luck, and money,
  #       then the names in player$inventory and player$buffs.
  invisible(NULL)
}

# main.R: Add one row of stat changes to the player.
# Input: player. effect = one row of prep_perks, campus_buffs, or shop_items.
#        scale = multiplier for the size of the change. 1 means as written
#        in the table. See luck_scale().
# Return: the updated player list.
apply_effect <- function(player, effect, scale = 1) {
  # TODO: multiply each STAT_COLS value in effect by scale, round it to a
  #       whole number, and add it to the matching player field.
  #       Then keep hp between 0 and max_hp.
  player
}

# main.R: How much LUCK changes the size of a buff or debuff.
# Used for choice events (campus.R) and the flee debuff (combat.R).
# Input: player. type = "buff" or "debuff", as in campus_buffs$type.
# Return: one number to pass to apply_effect() as scale.
luck_scale <- function(player, type) {
  # TODO: with more player$luck, return more than 1 for a "buff" and less
  #       than 1 for a "debuff". Never return less than 0.
  1
}

# main.R: LUCK-based yes or no, shared by flee attempts and crits.
# Input: player. base_chance = chance of success (0 to 1) when luck is 0.
# Return: TRUE or FALSE.
luck_check <- function(player, base_chance) {
  # TODO: raise base_chance according to player$luck, keep it between 0 and 1,
  #       then draw at random.
  TRUE
}

# main.R: One shop visit, shared by prep locations and campus shop events.
# Input: player. items = rows of prep_perks or shop_items to put on sale.
# At most one purchase per call: return after a purchase or after Leave.
# Cost-0 prep perks are paid for with the prep round, so they must not repeat.
# Return: the updated player list.
run_shop <- function(player, items) {
  # TODO: list each item with its cost and description, plus a "Leave" option.
  #       On a purchase: check player$money, subtract the cost, call
  #       apply_effect(), and add the item name to player$inventory.
  player
}

# main.R: Connect the phases and pass the updated player forward.
# run_campus() and run_finale() both return list(player = , outcome = ).
play_game <- function() {
  cat("UCLA Halloween Horror\n")
  player <- run_prep(new_player())

  result <- run_campus(player)

  if (result$outcome == "win") {
    result <- run_finale(result$player)
  }

  if (result$outcome == "win") {
    cat("\nYou survived UCLA Halloween Horror!\n")
  } else {
    cat("\nGame over.\n")
  }

  invisible(result)
}

# Level data first, then the modules that read it.
# Sourced last so the shared helpers above already exist.
source("prep_data.R")
source("campus_data.R")
source("finale_data.R")
source("prep.R")
source("combat.R")
source("campus.R")
source("finale.R")

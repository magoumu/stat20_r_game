# campus.R: The walk from the Hill to MS4000A, one random event at a time.
# Reads the settings and tables in campus_data.R.
# Uses fight() and flee() from combat.R and ask_choice(), apply_effect(),
# luck_scale(), and run_shop() from main.R.

# campus.R: Run the whole campus walk.
# Input: player after prep.
# Return: list(player = updated player, outcome = "win" or "loss").
#         "win" means the player reached MS4000A alive.
run_campus <- function(player) {
  cat("\nYou walk down from the Hill. Campus is crawling with monsters.\n")

  # Current hp starts here, at whatever max_hp the prep phase built up.
  player$hp <- player$max_hp
  n_events <- campus_length(player)

  for (i in seq_len(n_events)) {
    type <- pick_event_type()

    if (type == "hostile") {
      player <- event_hostile(player)
    } else if (type == "choice") {
      player <- event_choice(player)
    } else if (type == "shop") {
      player <- event_shop(player)
    } else {
      stop("Unknown event type: ", type)
    }

    # Every event returns the player. A player at 0 hp ends the game.
    if (player$hp <= 0L) {
      return(list(player = player, outcome = "loss"))
    }
  }

  list(player = player, outcome = "win")
}

# campus.R: How many events stand between the player and MS4000A.
# Input: player. Return: a whole number of events, never less than 1.
campus_length <- function(player) {
  # TODO: start from BASE_EVENTS and remove events for a high player$spd.
  BASE_EVENTS
}

# campus.R: Choose the type of the next event.
# Return: one value of EVENT_TYPES.
pick_event_type <- function() {
  # TODO: draw one of EVENT_TYPES at random using EVENT_WEIGHTS.
  "hostile"
}

# campus.R: Event type 1, a monster blocks the way. Fight or flee.
# Input: player. Return: the updated player list.
event_hostile <- function(player) {
  # TEMPORARY body: always the first monster, and no reward for a win.
  # TODO: pick a random monsters row and print its intro.
  #       After fight():
  #         "win"  -> add reward_money, apply a random campus_buffs row of
  #                   type "buff" as written (scale 1), and add its name
  #                   to player$buffs.
  #         "fled" -> flee() handles the debuff.
  #         "loss" -> nothing to do, run_campus() sees hp at 0.
  enemy <- monsters[1, ]
  result <- fight(player, enemy)
  player <- result$player

  if (result$outcome == "fled") {
    player <- flee(player)
  }

  player
}

# campus.R: Event type 2, a prompt with buff options and debuff options.
# Input: player. Return: the updated player list.
event_choice <- function(player) {
  # TODO: pick a random choice_events row and print the prompt.
  #       Offer CHOICES_SHOWN of its four options with ask_choice(), or one
  #       more if EXTRA_CHOICE_PERK is in player$inventory.
  #       GROUP DECISION: how the shown options are picked from the four,
  #       for example always at least one buff.
  #       Find the chosen option's effect name in campus_buffs and apply it
  #       with apply_effect(player, row, luck_scale(player, row$type)).
  #       Add the name to player$buffs.
  player
}

# campus.R: Event type 3, a rare shop appears.
# Input: player. Return: the updated player list.
event_shop <- function(player) {
  # TODO: choose which shop_items rows are on sale and pass them to run_shop().
  player
}

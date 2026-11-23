# combat.R: One hostile encounter: fight() or flee().
# Used by event_hostile() in campus.R and by run_finale().
# Uses ask_choice(), luck_check(), luck_scale(), and apply_effect() from
# main.R, and FLEE_CHANCE, CRIT_CHANCE, and campus_buffs from campus_data.R.

# combat.R: Fight until one side drops or the player flees.
# Input: player. enemy = rows of monsters or bosses: one row for a campus
#        monster, several rows for enemies fought at the same time (finale).
#        Any list with name, hp, atk, def, and spd also works as one enemy.
# Return: list(player = updated player, outcome = "win", "loss", or "fled").
#         "win" means every enemy row is at 0 hp.
#         On "loss" the returned player has hp 0.
#         On "fled" the caller applies flee() to the returned player.
fight <- function(player, enemy) {
  # TEMPORARY body moved from the main.R prototype: ONE enemy row only,
  # one hit each per round, fixed damage, def and spd are ignored, and
  # fleeing always works.
  # TODO: call turn_order() once before the loop, with enough turns to
  #       outlast the fight, and follow that order instead of strict
  #       alternation.
  #       Use calc_damage() for every hit, in both directions. Pass
  #       player$luck only for the player's hits.
  #       With several enemy rows: let the player pick a target with
  #       ask_choice(), and skip the turns of enemies at 0 hp.
  #       Use luck_check(player, FLEE_CHANCE) to decide whether a flee
  #       attempt works.
  #       GROUP DECISION: what a failed flee attempt costs. The design says
  #       fleeing never kills the player.
  cat("\nEncounter:", enemy$name, "| Your attack:", player$atk, "\n")

  while (player$hp > 0L) {
    cat("Your HP:", player$hp, "| Enemy HP:", enemy$hp, "\n")
    choice <- ask_choice(c("Attack", "Flee"))

    if (choice == 2L) {
      cat("You fled from", enemy$name, "\n")
      return(list(player = player, outcome = "fled"))
    }

    # The enemy only hits back if it survives your attack.
    enemy$hp <- enemy$hp - player$atk
    if (enemy$hp <= 0L) {
      cat("You defeated", enemy$name, "\n")
      return(list(player = player, outcome = "win"))
    }

    player$hp <- max(0L, player$hp - enemy$atk)
  }

  cat("You were defeated by", enemy$name, "\n")
  list(player = player, outcome = "loss")
}

# combat.R: The price of a successful flee.
# The player never dies from fleeing but always gets one random debuff.
# Input: player who just fled. Return: the updated player list.
flee <- function(player) {
  # TODO: pick a random campus_buffs row of type "debuff" and apply it with
  #       apply_effect(player, row, luck_scale(player, "debuff")).
  #       Add its name to player$buffs. Never let it take hp to 0.
  player
}

# combat.R: Damage of one hit.
# Input: atk of the attacker, def of the defender (a percent), and the
#        attacker's luck. Enemies have no luck, so leave it at 0 for them.
# Return: damage as a whole number.
calc_damage <- function(atk, def, luck = 0L) {
  # TODO: draw the hit from a normal distribution whose median is atk.
  #       On a crit, decided by CRIT_CHANCE and luck, make it bigger.
  #       Then remove def percent of it: hit * (1 - def / 100).
  #       Round to a whole number and decide the minimum damage of a hit.
  atk
}

# combat.R: Who acts in each of the first n_turns turns of a fight, based on SPD.
# It always counts from the start of the fight, so call it once per fight,
# not once per turn.
# Input: player_spd. enemy_spd = one spd per enemy row. n_turns.
# Return: whole-number vector of length n_turns. 0 means the player acts,
#         1 means the first enemy row acts, 2 the second, and so on.
turn_order <- function(player_spd, enemy_spd, n_turns) {
  # TODO: Honkai: Star Rail style. A fighter acts once every 10000 / spd
  #       units of time, so a faster one sometimes acts twice in a row.
  #       List every fighter's action times and put them in order.
  rep(c(0L, seq_along(enemy_spd)), length.out = n_turns)
}

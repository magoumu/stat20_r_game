# finale.R: The MS4000A scene and the boss fight.
# The finale is one large hostile fight against both bosses at the same time.
# Reads finale_intro and bosses from finale_data.R. Uses fight() from combat.R.

# finale.R: Run the finale.
# Input: player after the campus walk.
# Return: the result from fight(), list(player = , outcome = ).
#         play_game() counts anything other than "win" as game over.
run_finale <- function(player) {
  # TEMPORARY body: only the last boss, because the temporary fight() takes
  # one enemy row. The boss intro lines are not printed.
  # TODO: print every bosses$intro, then pass the whole table at once:
  #       fight(player, bosses).
  cat("", finale_intro, sep = "\n")
  boss <- bosses[nrow(bosses), ]
  fight(player, boss)
}

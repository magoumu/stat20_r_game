# finale_data.R: Level data for the finale. No functions in this file.
# finale.R reads these. Add or rebalance content here, not in finale.R.
# The text and numbers below are EXAMPLES to show the format. Replace them.

# Lines printed when the player walks into MS4000A.
finale_intro <- c(
  "You reach MS4000A.",
  "The lecture hall is dark. Two figures are waiting at the front."
)

# One row per boss. The player fights all of them at the same time.
# Same stat columns as monsters, so the whole table can be passed to fight()
# as the enemy. def is a percent of incoming damage blocked.
bosses <- data.frame(
  name  = c("Mighty Erik", "Superhuman Yoshua"),
  intro = c(
    "Mighty Erik steps out from behind the podium.",
    "Superhuman Yoshua rises from the back row."
  ),
  hp    = c(60L, 80L),
  atk   = c(16L, 20L),
  def   = c(10L, 20L),
  spd   = c(95L, 120L)
)

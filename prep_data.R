# prep_data.R: Level data for the prep phase. No functions in this file.
# prep.R reads these tables. Add or rebalance content here, not in prep.R.
# All rows below are EXAMPLE ROWS to show the columns. Replace them.

# MICHAEL's NOTE: If you want to store prep data in a different format, you can do that. Just make sure to change prep.R to read it correctly.

# How many prep actions the player gets before heading to campus.
PREP_ROUNDS <- 3L

# One row per place the player can visit on the Hill.
prep_locations <- data.frame(
  location    = c("Bruin Plate", "De Neve", "BFit", "CVS"),
  description = c(
    "Dining hall. Clean food that builds you up.",
    "Dining hall. Comfort food that toughens you up.",
    "Gym. Workouts that make you hit harder and move faster.",
    "Convenience store. Buy medicines that helps you to recover from attacks or snacks that builds you up."
  )
)

# One row per perk on offer.
# location must match a value in prep_locations$location.
# cost is paid from player$money. Use 0 for perks that only cost a prep round.
# The STAT_COLS columns are changes added to the player by apply_effect().
# Leave hp at 0 here: current hp is set to max_hp when the campus walk starts,
# so raise max_hp instead. def is a percent.
# A perk can also unlock something without changing stats: "Fortune Cookie"
# is the EXTRA_CHOICE_PERK named in campus_data.R.
prep_perks <- data.frame(
  name        = c("Protein Bowl", "Late Night Burger", "Fortune Cookie", "Leg Day", "Treadmill Sprint", "First Aid Kit", "Pain Relievers", "Energy Drink"),
  location    = c("Bruin Plate",  "De Neve",           "De Neve",        "BFit",    "BFit",             "CVS",           "CVS",             "CVS"),
  cost        = c(3L,             2L,                  4L,               0L,        0L,                  4L,              3L,               3L),
  # TRUE = kept in the inventory and used during a fight, see use_item() in
  # combat.R. FALSE = takes effect when bought.
  consumable  = c(FALSE,          FALSE,               FALSE,            FALSE,     FALSE,               TRUE,            TRUE,             TRUE),
  description = c(
    "A bigger health bar.",
    "Greasy armor.",
    "You will see one more option in campus choice events.",
    "Stronger hits.",
    "Faster feet.",
    "Basic medical supplies useful for injuries.",
    "Faster recovery from attack.",
    "A drink that boosts your energy."
  ),
  hp          = c(0L,             0L,                  0L,               0L,        0L,                   40L,            0L,               0L),
  max_hp      = c(20L,            0L,                  0L,               0L,        0L,                   0L,             0L,               0L),
  atk         = c(0L,             0L,                  0L,               8L,        0L,                   0L,             0L,               0L),
  def         = c(0L,             5L,                  0L,               0L,        0L,                   0L,            10L,               0L),
  spd         = c(0L,             0L,                  0L,               0L,        10L,                  0L,             0L,               10L),
  luck        = c(0L,             0L,                  0L,               0L,        0L,                   0L,             0L,               0L)
)

# Stop when this file is sourced if a perk names a location that is not
# in prep_locations.
stopifnot(prep_perks$location %in% prep_locations$location)

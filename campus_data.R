# campus_data.R: Level data for the campus walk. No functions in this file.
# campus.R and combat.R read these. Add or rebalance content here, not there.
# All rows and numbers below are EXAMPLES to show the format. Replace them.

# How many events the walk has before SPD changes it. See campus_length().
# 1 only keeps the prototype short. Raise it before taking events away for SPD.
BASE_EVENTS <- 1L

# The three event types and how likely each one is. See pick_event_type().
EVENT_TYPES   <- c("hostile", "choice", "shop")
EVENT_WEIGHTS <- c(0.5,       0.4,      0.1)

# Chance that a flee attempt works, before LUCK. See fight() in combat.R.
FLEE_CHANCE <- 0.5

# Chance that a hit is a crit, before LUCK, and how many times bigger a crit
# is. See calc_damage() in combat.R.
CRIT_CHANCE <- 0.1
CRIT_MULT   <- 1.5

# How much one hit varies: the standard deviation of its normal distribution,
# as a share of the attacker's atk. 0.2 with atk 20 means most hits land
# between 13 and 27. See calc_damage() in combat.R.
DAMAGE_SD <- 0.2

# The least damage one hit can do, however high the defender's def is.
MIN_DAMAGE <- 1L

# A hit drawn from the lowest or the highest LUCKY_TAIL of its distribution
# gets an unlucky or lucky message. See report_hit() in combat.R.
LUCKY_TAIL <- 0.05

# How many options of a choice event the player normally sees, and the
# prep perk (a prep_perks$name) that shows one more. See event_choice().
CHOICES_SHOWN     <- 2L
EXTRA_CHOICE_PERK <- "Fortune Cookie"

# One row per monster. hp, atk, def, and spd are the monster's own stats.
# def is a percent of incoming damage blocked.
# One row of this table is passed to fight() as the enemy.
monsters <- data.frame(
  name         = c("Campus Zombie", "Bruin Walk Ghoul", "Joel Bruin"),
  intro        = c(
    "A zombie staggers out of Powell Library.",
    "A ghoul drifts through the flyer crowd on Bruin Walk.",
    "A fake mascot shape-shifted from the Bruin Bear Statue."
  ),
  hp           = c(40L, 60L,  80L),
  atk          = c(12L, 16L,  20L),
  def          = c(0L,  10L,  15L),
  spd          = c(90L, 110L, 120L),
  reward_money = c(3L,  5L,   10L)
)

# The buff and debuff table for campus events.
# type is "buff" or "debuff". Won fights give a random buff, fleeing gives
# a random debuff, and choice events name their effects in choice_events.
# The STAT_COLS columns are changes added to the player by apply_effect().
# LUCK changes their size for choice events and fleeing. See luck_scale().
campus_buffs <- data.frame(
  name        = c("Adrenaline Rush", "Lucky Penny", "Twisted Ankle", "Midterm Dread", "Free Food", "Sudden Rain"),
  type        = c("buff",            "buff",        "debuff",        "debuff",        "buff",      "debuff"),
  description = c(
    "Your heart is pounding. You hit harder.",
    "Heads up on Bruin Walk. Things go your way.",
    "You landed badly. You move slower.",
    "You remembered the midterm. Your guard drops.",
    "You got food. You have more energy.",
    "You didn't bring an umbrella. You need to move slower to avoid the puddles."
  ),
  hp          = c(0L,                0L,            0L,              0L,                5L,           0L),
  max_hp      = c(0L,                0L,            0L,              0L,                0L,           0L),
  atk         = c(4L,                0L,            0L,              0L,                2L,           0L),
  def         = c(0L,                0L,            0L,              -5L,               0L,           0L),
  spd         = c(0L,                0L,            -10L,            0L,                0L,           -5L),
  luck        = c(0L,                2L,            0L,              0L,                0L,           0L)
)

# One row per choice event. Each event has four options: two whose effect
# is a buff and two whose effect is a debuff. The player sees only some of
# them, see CHOICES_SHOWN. effect_1 is what option_1 does, and so on.
# Every effect must match a campus_buffs$name.
choice_events <- data.frame(
  prompt   = c("A cloaked figure blocks Bruin Walk and holds out a flyer."),
  option_1 = c("Walk around them"),
  option_2 = c("Ask what the club does"),
  option_3 = c("Sprint past"),
  option_4 = c("Take the flyer and read it"),
  effect_1 = c("Lucky Penny"),
  effect_2 = c("Adrenaline Rush"),
  effect_3 = c("Twisted Ankle"),
  effect_4 = c("Midterm Dread")
)

# Stop when this file is sourced if an event names an effect that is not
# in campus_buffs. A typo here would otherwise break the player later.
stopifnot(choice_events$effect_1 %in% campus_buffs$name,
          choice_events$effect_2 %in% campus_buffs$name,
          choice_events$effect_3 %in% campus_buffs$name,
          choice_events$effect_4 %in% campus_buffs$name)

# One row per item a campus shop can sell. cost is paid from player$money.
# The STAT_COLS columns are changes added to the player by apply_effect().
shop_items <- data.frame(
  name        = c("First Aid Kit", "Energy Drink", "Running Shoes", "Pain Reliever"),
  cost        = c(4L,              3L,             3L,              3L),
  # TRUE = kept in the inventory and used during a fight, see use_item() in
  # combat.R. FALSE = takes effect when bought.
  consumable  = c(TRUE,            TRUE,           FALSE,           TRUE),
  description = c(
    "Patch yourself up.",
    "Wings, briefly.",
    "Speed you up.",
    "Pain pain go away."
  ),
  hp          = c(40L,             0L,             0L,              0L),
  max_hp      = c(0L,              0L,             0L,              0L),
  atk         = c(0L,              0L,             0L,              0L),
  def         = c(0L,              0L,             0L,              10L),
  spd         = c(0L,              10L,            10L,             0L),
  luck        = c(0L,              0L,             0L,              0L)
)

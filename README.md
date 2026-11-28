
# Development Notes

**Authors**: Seongwoo Choi UID 706984104, Joy Rui Xi Lim UID 106984220, Junyi Li UID 506942191, Michael Mu 906648946

## Objective

We are creating a terminal text-based R mini game. GUI is not needed.

This game has two phases: prep and fight. You are a UCLA student living on the hill. Use your “prep”
rounds in workouts and food, and purchase supplies in the residential area to gain powers, perks, and options.

Then, you go to school only to find the campus flooded with monsters. Use your perks and powers to defeat the monsters and reach MS4000A, where you confront the Superhuman Yoshua and his soldier Mighty Erik.

## Game Structure

### Player Object

The player object has items, buffs and base player statistics.

The prep and combat phase updates player statistic.

The player statistic is composed of following **INTEGERS!!!**:
- hp (current): you die when your HP falls to 0 at any point in the game. Initialize in campus phase (=max_hp).
- max_hp: self-explanatory. Range 100-1000.
- spd (speed): determines how many rounds one get before the other one acts (same logic as the Honkai: Star Rail SPD system), as well as walk length to MS4000A.
- atk (attack): base damage you deal to an enemy. However, combat is random so it will be applied as median of a gaussian distribution.
- def (defense): looking at something like enemy_atk * (1-def%) = received damage.
- luck: LUCK determines flee success rate, crit rate, and modulates buff magnitude in type 2 event.
- money: most useful in prep phase as campus shops are rare.

HP and ATK are the key fight rounds, HP deduction is modulated by high DEF
SPD determines how many rounds until finale, LUCK determines flee success rate and possibility of getting buff over debuff in type 2 event.

### Updating Player

The current idea is to update the player object with an 

### Prep (i.e., Hill) Phase

Texts & Numbers: TBD

Coding: TBD

The prep phase on the hill is a directory of locations + items. Therefore, we separate defined events (`prep_data.R`) from the prep actor file.

Prep Locations: TBD, written example items in BPlate, De Neve, BFit, CVS.

### Campus Phase

Texts & Numbers: TBD, TBD

Coding: Michael

The campus phase is a series of random events that pulls from a predefined event library (`campus_data.R`), with 3 modes
1) P=50% hostile (`combat.R`): fight() or flee() with round-based, random damage; win = +buff.
        - Fight is random sample() that exchanges damage between player and monster until one party dies.
        - Flee guarantee not die but guarantees a random debuff, magnitude modulated by luck.
2) P=40% choice events (2 buff and 2 debuff choices each, of which only 2 will be available unless player gets a prep phase perk where 3 choices will be available).
3) P=10% - rare campus shops.

### Finale is basically a large hostile fight where you fight two people at the same time

Texts & Numbers: TBD

Coding: TBD


#### (1) Hostile: combat.R Behavior

How a fight works:

- **Turn order.** Every fighter acts once every `10000 / spd` units of time, so a faster fighter sometimes acts twice in a row. On a tie the player goes first. The order is planned once when the fight starts. Enemies at 0 hp skip their turns.
- **Damage.** One hit is a draw from a normal distribution with median `atk` and standard deviation `DAMAGE_SD * atk`. The defender's `def` percent is then removed. A negative `def` (from a debuff) lets more damage through. A hit never does less than `MIN_DAMAGE`.
- **Crits.** A hit is a crit with chance `CRIT_CHANCE` plus LUCK, and is then multiplied by `CRIT_MULT`. Enemies have no LUCK, so they crit at the base chance.
- **Lucky and unlucky messages.** If the draw is in the lowest or highest 5% of its distribution (`LUCKY_TAIL`), the game prints a message from the player's side. The player's strong hit and an enemy's weak hit are "Lucky!". The reverse are "Unlucky."
- **Status check.** The hp of everyone in the fight is printed after every hit.
- **Several enemies.** `fight()` accepts several enemy rows. With more than one alive, the player picks a target.

What the player can do on their turn:

1. **Attack.** Ends the turn.
2. **Flee.** Works with chance `FLEE_CHANCE` plus LUCK. A failed attempt costs the turn. A successful one ends the fight, and `flee()` gives one random debuff, made smaller by LUCK. Fleeing never takes hp below 1.
3. **Use item.** Shows the inventory and lets the player use one consumable item. This does not end the turn, but only one item can be used per turn. Items cannot be used on an enemy's turn.

In the finale there is nowhere to flee: the game says so once and the Flee option is hidden. `run_finale()` does this by calling `fight(player, boss, can_flee = FALSE)`.

Changes to shared code in `main.R`:

- `ask_choice(options, show)` has a new optional argument. `show` is one TRUE or FALSE per option, and only the TRUE ones are printed. It returns the position in the full list, so the meaning of each number stays the same when an option is hidden. Calls without `show` work as before.
- `apply_effect()`, `luck_scale()`, and `luck_check()` are now written. They were stubs, and combat needs them.
- New setting `LUCK_STEP`: what one point of LUCK is worth. It is added to flee and crit chance, and it changes the size of buffs and debuffs.

#### FOR COLLABORATORS (11.27):

- A failed flee attempt costs the turn and nothing else. This was listed as a group decision.
- An item's effect is permanent, like every other stat change.
- A `spd` change during a fight (Energy Drink) restarts the turn order. The player finishes the turn they used the item in, then the order is planned again from the start with the current `spd` of both sides, and the new order is printed.

All of these numbers need to be balanced.

| Setting | File | Now | Meaning |
| :--- | :--- | :--- | :--- |
| `DAMAGE_SD` | `campus_data.R` | 0.2 | How much a hit varies, as a share of `atk` |
| `CRIT_MULT` | `campus_data.R` | 1.5 | How many times bigger a crit is |
| `MIN_DAMAGE` | `campus_data.R` | 1 | The least damage one hit can do |
| `LUCKY_TAIL` | `campus_data.R` | 0.05 | Share of hits at each end that get a message |
| `LUCK_STEP` | `main.R` | 0.05 | One LUCK point = 5 percentage points |

With the example numbers, the starting player always beats the Campus Zombie and always loses to both bosses together.

## How to Pull This Off

### Use Git

Git is why you are viewing this here.

You need to know:

- Pull: get the folder from github or any git server really.
- Stage change: tell your git you changed these stuff.
- Commit: tell your git to save the current state of the folder. Only changed files will be updated. Previous versions are retained.
- Push: tell your git to upload the committed state to github.
- Merge: combine the changes you & your teammates made at a commit, locally.
- Branch: committing directly to main may conflict with others if they do not merge, so isolate your changes on a dedicated branch. For our purpose, if you only edited your files, this can be skipped, don't do that in your future workplace.
- GitHub Pull Request

Again, for our purpose, Branch and PR are for when you believe you made a significant modification to other people's code that affects previously validated functionality. Otherwise, just commit and push, it won't be a big problem. If you see a new commit by others, merge -> check for errors and bugs when your code interacts with theirs -> commit & push, or branch, or contact team.

To learn git, google or see https://git-scm.com/docs/gittutorial

**READ THESE NOTES:**

1. MAKE A SHORT NOTE WHAT YOU CHANGED IN YOUR COMMIT MESSAGE! REFER TO THE FIRST ONE.
1. Don't forget to stage changes before you commit.
2. Try not to destroy other people's files. You can always revert single files to the last commited state.
3. DO NOT EDIT `.gitignore` unless you have a clear purpose.
4. IT IS STRONGLY RECOMMENDED YOU EDIT THIS FILE AS YOU CODE/DESIGN TEXTS&NUMBERS. It will make everybody's life easier.
5. It is ok to commit & push incomplete changes, just make sure each commit accomplishes something and is not too redundant.

P.S., Michael Mu: I recommend Visual Studio Code recommend over RStudio.

### Splitting the storywriting and the coding

I think texts & numbers is a crucial, low code roles where you make sure the game is playable.

The team members taking charge of Texts & Numbers need to communicate to make sure the game is balanced and every event is plausible (by writing the descriptions of items, etc)

You would want the player to have enough HP, not too much even with buffs, to kill your opponent, and the fight also cannot be too easy (this can be accomplished by suggesting suitable defaults and attainable ranges for the player statistics, definign enemy statistics for coder's reference).

We develop prep and campus first. Texts & Numbers should be one person's job whilst coding another's. This way we can work in 2 teams of 2.

### Workflow for each phase:

**(PUT YOUR NAMES HERE & COMMIT & PUSH if you already have an idea what you want to do!!)**

|Phase|Texts & Numbers|Coder|
| :--- | :---: | ---: |
|prep|TBD|TBD|
|campus-combat|TBD|Michael|
|campus-other|TBD|Michael|
|finale|TBD|TBD|

While the coder wait on texts and numbers, they should start developing what can be developed, leave placeholder texts/numbers so they don't push everything at the last minute.

P.S., eventually, this development document can be easily converted into a report.

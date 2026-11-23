# UCLA Halloween Horror — Group 49 prototype
# In RStudio, source this file, then run play_game() in the Console.
# When a teammate's module is ready, source it after main.R to test it.

# main.R: Shared player state. Agree on new fields as a group.
new_player <- function() {
  list(
    hp = 20L,
    max_hp = 20L,
    attack = 5L,
    inventory = character(0),  # Item names
    buffs = character(0)       # Buff names
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

# prep.R: Add locations, items, and buffs here.
# Input: player. Return: the updated player list.
run_prep <- function(player) {
  cat("\nYou start on the Hill.\n")
  choice <- ask_choice(c("Visit BFit", "Head straight to campus"))
  
  if (choice == 1L) {
    player$attack <- player$attack + 2L
    cat("Your attack increased to", player$attack, "\n")
  }
  
  player
}

# combat.R: Add combat actions, item use, and damage rules here.
# Enemy fields: name, hp, attack.
# Return: list(player = updated player, outcome = "win" or "loss").
fight <- function(player, enemy) {
  cat("\nEncounter:", enemy$name, "| Your attack:", player$attack, "\n")
  
  while (player$hp > 0L) {
    cat("Your HP:", player$hp, "| Enemy HP:", enemy$hp, "\n")
    choice <- ask_choice(c("Attack", "Flee"))
    
    if (choice == 2L) {
      cat("You fled from", enemy$name, "\n")
      return(list(player = player, outcome = "loss"))
    }
    
    # The enemy only hits back if it survives your attack.
    enemy$hp <- enemy$hp - player$attack
    if (enemy$hp <= 0L) {
      cat("You defeated", enemy$name, "\n")
      return(list(player = player, outcome = "win"))
    }
    
    player$hp <- max(0L, player$hp - enemy$attack)
  }
  
  cat("You were defeated by", enemy$name, "\n")
  list(player = player, outcome = "loss")
}

# finale.R: Add the boss setup and finale dialogue here.
# Input: player after the campus fight. Return: the result from fight().
run_finale <- function(player) {
  cat("\nYou reach MS4000A.\n")
  boss <- list(name = "MS4000A Boss", hp = 20L, attack = 5L)
  fight(player, boss)
}

# main.R: Connect the phases and pass the updated player forward.
play_game <- function() {
  cat("UCLA Halloween Horror\n")
  player <- run_prep(new_player())
  
  # Add more campus encounters here once the group has designed them.
  zombie <- list(name = "Campus Zombie", hp = 10L, attack = 3L)
  result <- fight(player, zombie)
  
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

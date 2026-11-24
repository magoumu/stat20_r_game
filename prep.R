# prep.R: The prep phase on the Hill.
# Reads PREP_ROUNDS, prep_locations, and prep_perks from prep_data.R.
# Uses ask_choice(), show_status(), and run_shop() from main.R.

# prep.R: Run the whole prep phase.
# Input: player. Return: the updated player list.
run_prep <- function(player) {
  # TEMPORARY body moved from the main.R prototype.
  # TODO: show_status(player) so the player sees their starting money.
  #       Repeat PREP_ROUNDS times: offer prep_locations$location plus
  #       "Head to campus" with ask_choice(), then visit_location().
  
  show_status(player)
  
  cat("\nYou start on the Hill.\n")
  
  for (i in seq_len(PREP_ROUNDS)){
    cat("Prep round", i, "of", PREP_ROUNDS, "\n")
    choices <- c(prep_locations$location, "Head straight to campus.")
    choice <- ask_choice(choices)
    
    if(choice == length(choices)){
      break
    }
    
    location <- prep_locations$location[choice]
    
    player <- visit_location(player, location)
  }

  cat("Your preparation is complete. Time to head to campus! \n")

  player
}

# prep.R: Visit one prep location and offer its perks.
# Input: player. location = one value of prep_locations$location.
# Return: the updated player list.
visit_location <- function(player, location) {
  # TODO: print the location's description, pick the prep_perks rows
  #       for this location, and pass them to run_shop().
  
  #Find the related description
  location_info <- prep_locations[prep_locations$location == location]
  
  #print the location
  cat(location_info$description)
  
  #Find items available at that location
  available_items <- prep_perks[prep_perks$location == location, ]
  
  #Let the player shop
  player <- run_shop(player, available_items)
  player
}

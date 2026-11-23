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
  cat("\nYou start on the Hill.\n")
  choice <- ask_choice(c("Visit BFit", "Head straight to campus"))

  if (choice == 1L) {
    player$atk <- player$atk + 8L
    cat("Your attack increased to", player$atk, "\n")
  }

  player
}

# prep.R: Visit one prep location and offer its perks.
# Input: player. location = one value of prep_locations$location.
# Return: the updated player list.
visit_location <- function(player, location) {
  # TODO: print the location's description, pick the prep_perks rows
  #       for this location, and pass them to run_shop().
  player
}

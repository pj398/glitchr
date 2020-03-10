#-----------------------------------------------------------------------------#
# Code for the functions that databend the images
#-----------------------------------------------------------------------------#

# Glitch method for databending via find-and-replace --------------------------
glitch_far <- function(input_data, n_changes = 5, tune = 100) {
  glitched <- input_data
  for (i in 1:n_changes) {
    change_rows <- grep(pattern = sample(unique(input_data), 1), x = input_data)
    change_samp <- sample(change_rows,
                          (length(change_rows) / 100) * min(tune, 100))
    change_to <- sample(unique(input_data), 1)
    for (safe in change_samp) {
      if(safe > (length(input_data) / 100) * 0.5) {
        glitched[safe] <- change_to
      }
    }
  }
  glitched
}

# Glitch method for databending via chance operations -------------------------
glitch_co <- function(input_data, n_changes = 10, noise = 20) {
  # Generate a safe copy of the raw file
  glitched <- input_data
  # Sample to find the change points (indices for the raw vector)
  change_points <- runif(n = n_changes,
                         min = as.integer((length(input_data) / 100) * 0.5),
                         max = length(input_data) -
                           ((length(input_data) / 100) * 5))
  # Now iterate over these change points
  for (i in change_points) {
    # Then, decide what to do at each change point
    how_to_mess <- sample(c("add", "move", "clone", "delete"), 1)

    # And mess with it in that way
    if(how_to_mess == "add") {
      glitched <- append(glitched, sample(unique(input_data),
                                          sample(1:noise, 1), TRUE), i)
    }
    if(how_to_mess == "move") {
      move_seed <- sample(1:noise, 1)
      move_data <- glitched[i:(i + move_seed)]
      glitched <- glitched[-(i:(i + move_seed))]
      safe_range <- (length(glitched) / 100) *
        10:(length(glitched) - (length(glitched) / 100) * 5)
      glitched <- append(glitched, move_data,
                         after = sample(safe_range, 1))
    }
    if(how_to_mess == "clone") {
      move_seed <- sample(1:noise, 1)
      move_data <- glitched[i:(i + move_seed)]
      safe_range <- (length(glitched) / 100) *
        2:(length(glitched) - (length(glitched) / 100) * 5)
      glitched <- append(glitched, move_data,
                         after = sample(safe_range, 1))
    }
    if(how_to_mess == "delete") {
      move_seed <- sample(1:noise, 1)
      move_data <- glitched[i:(i + move_seed)]
      glitched <- glitched[-(i:(i + move_seed))]
    }
  }
  # Make sure the glitched data ends up the same length as the input data
  size_diff <- length(glitched) - length(input_data)
  corr_min <- as.integer((length(raw_image) / 100) * 0.5)
  corr_max <- length(glitched) - ((length(input_data) / 100) * 5)
  if(size_diff > 0) { # Delete stuff if output longer than input
    glitched <- glitched[-sample(corr_min:corr_max, size = size_diff)]
  }
  if (size_diff < 0) { # Add stuff if output shorter than input
    glitched <- append(glitched,
                       sample(unique(input_data), abs(size_diff), TRUE),
                       after = length(glitched)/2)
  }
  # Output the glitched data
  glitched
}

#-----------------------------------------------------------------------------#
# Code for the functions that databend the images
#-----------------------------------------------------------------------------#

#' Create glitches by databending raw vectors.
#'
#' A function for databending a raw vector by making stochastic changes. (Note
#' that this currently works for PNG images, but other file types have not been
#' tested.)
#'
#' @param input_data A raw vector representing the file to databend.
#' @param method A character string. Which method should be used for the
#'   databending. Either "far" (find and replace), which is the default, or
#'   "chops" (chance operations). These are explained below.
#' @param n_changes A numeric value. How many unique elements \emph{F} should be
#'   selected for replacement?
#' @param tune A numeric value between 1 and 100. What percentage of the
#'   occurences of \eqn{F} should be replaced when using the \code{"far"}
#'   method?
#' @param noise A numeric value. This sets the ceiling of how big the chunks
#'   that are selected when making changes using the \code{"chops"} method can
#'   be. The higher the value, the more data in the raw vector will be changed.
#' @return A raw vector representing a modified version of the input vector.
#'
#' @details There are some key differences between the two glitch methods. The
#'   \code{"far"} (find and replace) method databends the raw vector by randomly
#'   sampling unique observed values \eqn{F} and replacing them with another
#'   randomly sampled unique value \eqn{R}. .
#'
#'   The \code{"chops"} (chance operations) method databends the raw vector by
#'   randomly selecting \eqn{N} change points and randomly making a change
#'   \eqn{M} at each change point. The changes \eqn{M} can be one of the
#'   following operations with equal probability: \itemize{ \item \code{add}:
#'   take all unique values of the raw vector, randomly sample a number of them,
#'   and then insert these in at the change point. \item \code{move}: take a
#'   chunk of elements starting at the change point, delete them, and then
#'   reinsert them at a random point in the raw vector. \item \code{clone}: as
#'   with move, but don’t delete the chunk, simply copy it to another location.
#'   \item \code{delete}: take a chunk of elements starting at the change point
#'   and delete them. } This chance operations method uses a more interesting
#'   process for bending the data, but is less stable and occasionally breaks
#'   the underlying image resulting in grey blocks in the rendered image.
#'
#' @seealso For more description of the glitch methods, read my blog post at
#'   \url{https://www.petejon.es/posts/2020-03-09-glitch-art-in-r/} which also
#'   links off to general resources on databending and glitch art.
#'
#' @examples
#' data(demo_img1)
#' my_glitch1 <- glitch_png(demo_img1, method = "far",
#'                         n_changes = 3, tune = 5)
#'
#' my_glitch2 <- glitch_png(demo_img1, method = "chops",
#'                         n_changes = 5, noise = 15)
#' \dontrun{
#' my_glitch1 %>%
#'   magick::image_read() %>%
#'   magick::image_scale(magick::geometry_size_pixels(width = 550)) %>%
#'   print()
#' }
#'
#' @export
glitch_png <- function(input_data, method = "far",
                      n_changes = 5, tune = 100, noise = 20) {
  glitched <- input_data

  if(method == "far") {
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
  }

  if(method == "chops") {
    change_points <- stats::runif(n = n_changes,
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
    corr_min <- as.integer((length(input_data) / 100) * 0.5)
    corr_max <- length(glitched) - ((length(input_data) / 100) * 5)
    if(size_diff > 0) { # Delete stuff if output longer than input
      glitched <- glitched[-sample(corr_min:corr_max, size = size_diff)]
    }
    if (size_diff < 0) { # Add stuff if output shorter than input
      glitched <- append(glitched,
                         sample(unique(input_data), abs(size_diff), TRUE),
                         after = length(glitched)/2)
    }
  }

  return(glitched)
}

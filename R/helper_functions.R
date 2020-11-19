#-----------------------------------------------------------------------------#
# Code for some utility functions that help the databending process
#-----------------------------------------------------------------------------#

# A wrapper for reading raw files
get_raw <- function(...) {
  readr::read_file_raw(...)
}

#' Plot the raw vector as an image in the RStudio Viewer.
#'
#' Helper function to plot the raw vector as an image in the RStudio Viewer pane
#' (or another configured browser) using the magick package.
#'
#' @param raw_vector The raw vector object in R which you wish to plot.
#' @param height_px The width in pixels to scale the image before viewing. To
#'   ensure the correct aspect ratio is maintained when specifying height, set
#'   \code{width_px = NULL}.
#' @param width_px The width in pixels to scale the image before viewing.
#'
#' @return A printable magick tibble.
#'
#' @examples
#' \dontrun{
#'   glitch_it(demo_img1, method = "far",
#'             n_changes = 3, tune = 5) %>%
#'   plot_vector(width_px = 300)
#' }
#' @export
plot_vector <- function(raw_vector, height_px = NULL, width_px = 550) {
  raw_vector %>%
    magick::image_read() %>%
    magick::image_scale(magick::geometry_size_pixels(height = height_px,
                                                     width = width_px)) %>%
    print()
}

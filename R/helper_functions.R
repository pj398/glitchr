#-----------------------------------------------------------------------------#
# Code for some utility functions that help the databending process
#-----------------------------------------------------------------------------#

# A wrapper for reading raw files
get_raw <- function(...) {
  readr::read_file_raw(...)
}

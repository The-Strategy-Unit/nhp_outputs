#' measure_selection UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_measure_selection_ui <- function(id, width = 4) {
  ns <- shiny::NS(id)

  shiny::tagList(
    bs4Dash::column(
      width,
      shiny::selectInput(ns("activity_type"), "Activity Type", NULL)
    ),
    bs4Dash::column(
      width,
      shiny::selectInput(ns("pod"), "Point of Delivery", NULL, multiple = TRUE)
    ),
    bs4Dash::column(width, shiny::selectInput(ns("measure"), "Measure", NULL))
  )
}

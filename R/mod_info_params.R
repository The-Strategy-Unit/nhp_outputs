#' info_params UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_params_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::h1("Information: parameter inputs"),
    bs4Dash::box(
      collapsible = FALSE,
      headerBorder = FALSE,
      width = 12,
      shiny::verbatimTextOutput(ns("params"))
    )
  )

}

#' info_params Server Functions
#'
#' @noRd
mod_info_params_server <- function(id, selected_data) {

  shiny::moduleServer(id, function(input, output, session) {

    ns <- session$ns

    params_data <- shiny::reactive({
      selected_data() |> get_params()
    })

    output$params <- shiny::renderPrint({ params_data() })

  })

}

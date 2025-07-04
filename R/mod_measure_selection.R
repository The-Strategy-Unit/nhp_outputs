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

#' measure_selection Server Functions
#'
#' @noRd
mod_measure_selection_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    atpmo <- get_activity_type_pod_measure_options()

    # handle onload
    shiny::observe({
      activity_types <- atpmo |>
        dplyr::distinct(
          dplyr::across(
            tidyselect::starts_with("activity_type")
          )
        ) |>
        set_names()

      shiny::updateSelectInput(
        session,
        "activity_type",
        choices = activity_types
      )
    })

    shiny::observeEvent(input$activity_type, {
      at <- shiny::req(input$activity_type)

      pods <- atpmo |>
        dplyr::filter(.data$activity_type == at) |>
        dplyr::distinct(
          dplyr::across(
            tidyselect::starts_with("pod")
          )
        ) |>
        set_names()

      shiny::updateSelectInput(session, "pod", choices = pods, selected = pods)
    })

    shiny::observeEvent(input$pod, {
      at <- shiny::req(input$activity_type)
      p <- shiny::req(input$pod)

      measure_names <- get_golem_config("measures")

      measures <- atpmo |>
        dplyr::filter(.data$activity_type == at, .data$pod %in% p) |>
        purrr::pluck("measures")

      shiny::updateSelectInput(
        session,
        "measure",
        choices = purrr::set_names(measures, measure_names[measures]),
        selected = ifelse(at == "ip", "beddays", measures[[1]])
      )
    })

    selected_measure <- shiny::reactive({
      at <- shiny::req(input$activity_type)
      p <- shiny::req(input$pod)
      m <- shiny::req(input$measure)

      # ensure a valid set of pod/measure has been selected. If activity type changes we may end up with invalid options
      shiny::req(
        nrow(dplyr::filter(atpmo, .data$pod %in% p, .data$measures == m)) > 0
      )

      list(activity_type = at, pod = p, measure = m)
    })

    selected_measure
  })
}

#' result_selection UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_result_selection_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::selectInput(ns("dataset"), "Dataset", NULL),
    shiny::selectInput(ns("scenario"), "Scenario", NULL),
    shiny::selectInput(ns("create_datetime"), "Model Run Time", NULL)
  )
}

#' result_selection Server Functions
#'
#' @noRd
mod_result_selection_server <- function(id, user_allowed_datasets) {
  shiny::moduleServer(id, function(input, output, session) {
    results_sets <- shiny::reactive({
      cosmos_get_result_sets() |>
        dplyr::filter(.data$dataset %in% user_allowed_datasets()) |>
        dplyr::group_nest(.data$dataset, .data$scenario, .key = "create_datetime") |>
        dplyr::mutate(
          dplyr::across(.data$create_datetime, purrr::map, tibble::deframe)
        ) |>
        dplyr::group_nest(.data$dataset, .key = "scenario") |>
        dplyr::mutate(
          dplyr::across(.data$scenario, purrr::map, tibble::deframe)
        ) |>
        tibble::deframe()
    })

    shiny::observe({
      x <- shiny::req(results_sets())
      shiny::updateSelectInput(session, "dataset", choices = names(x))
    })

    scenarios <- shiny::reactive({
      x <- shiny::req(results_sets())
      v <- shiny::req(input$dataset)
      shiny::req(v %in% names(x))
      x[[v]]
    })

    shiny::observe({
      x <- shiny::req(scenarios())
      shiny::updateSelectInput(session, "scenario", choices = names(x))
    })

    create_datetimes <- shiny::reactive({
      x <- shiny::req(scenarios())
      v <- shiny::req(input$scenario)
      shiny::req(v %in% names(x))
      x[[v]]
    })

    shiny::observe({
      x <- shiny::req(create_datetimes())

      labels <- \(.x) .x |>
        lubridate::as_datetime("%Y%m%d_%H%M%S", tz = "UTC") |>
        lubridate::with_tz() |>
        format("%d/%m/%Y %H:%M:%S")

      choices <- purrr::set_names(names(x), labels)
      shiny::updateSelectInput(session, "create_datetime", choices = choices)
    })

    selected_model_run <- shiny::reactive({
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      rs <- shiny::req(results_sets())

      id <- purrr::reduce(c(ds, sc, cd), .init = rs, \(.x, .y) {
        shiny::req(.y %in% names(.x))
        .x[[.y]]
      })

      list(ds = ds, sc = sc, cd = cd, id = id)
    })

    return(selected_model_run)
  })
}

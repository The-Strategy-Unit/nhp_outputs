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
    shiny::selectInput(ns("create_datetime"), "Model Run Time", NULL),
    shiny::selectInput(ns("site_selection"), "Site", NULL),
    shinyjs::hidden(
      shiny::downloadButton(ns("download_results"), "Download results (.json)")
    )
  )
}

#' result_selection Server Functions
#'
#' @noRd
mod_result_selection_server <- function(id, user_allowed_datasets) {
  shiny::moduleServer(id, function(input, output, session) {
    results_sets <- shiny::reactive({
      app_version <- Sys.getenv("NHP_APP_VERSION", "dev") |>
        stringr::str_replace("(\\d+\\.\\d+)\\..*", "\\1")

      rs <- get_result_sets(input$dataset)

      # handle case where no result sets are available
      shiny::req(nrow(rs) > 0)

      rs |>
        dplyr::filter(.data$dataset %in% user_allowed_datasets()) |>
        dplyr::group_nest(.data$dataset, .data$scenario, .key = "create_datetime") |>
        dplyr::mutate(
          dplyr::across("create_datetime", purrr::map, tibble::deframe)
        ) |>
        dplyr::group_nest(.data$dataset, .key = "scenario") |>
        dplyr::mutate(
          dplyr::across("scenario", purrr::map, tibble::deframe)
        ) |>
        tibble::deframe()
    })

    shiny::observe({
      show_button <- !getOption("golem.app.prod", TRUE) || "nhp_power_users" %in% session$groups
      shinyjs::toggle("download_results", selector = show_button)
    })

    output$download_results <- shiny::downloadHandler(
      filename = function() {
        params <- shiny::req(selected_model_run())$params

        glue::glue("{params$dataset}-{params$scenario}-{params$create_datetime}.json")
      },
      content = function(file) {
        shiny::req(selected_model_run()) |>
          jsonlite::write_json(file, pretty = TRUE, auto_unbox = TRUE)
      }
    )

    shiny::observe({
      # TODO: THERE IS A CIRCULAR REFERENCE NOW ON THIS
      #       change to use the available datasets object instead
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

    run_id <- shiny::reactive({
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      rs <- shiny::req(results_sets())

      purrr::reduce(c(ds, sc, cd), .init = rs, \(.x, .y) {
        shiny::req(.y %in% names(.x))
        .x[[.y]]
      })
    })

    shiny::observe({
      id <- shiny::req(run_id())

      trust_sites <- get_trust_sites(id)

      shiny::updateSelectInput(session, "site_selection", choices = trust_sites)
    }) |>
      shiny::bindEvent(run_id())

    selected_model_run <- shiny::reactive({
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)
      id <- shiny::req(run_id())
      site <- shiny::req(input$site_selection)

      list(ds = ds, sc = sc, cd = cd, id = id, site = site)
    })

    return(selected_model_run)
  })
}

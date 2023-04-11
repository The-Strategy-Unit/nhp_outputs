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
    available_datasets <- shiny::reactive({
      get_user_allowed_datasets(session$user)
    })

    return (shiny::reactive(NULL))
    
    shiny::observe({
      ds <- available_datasets()
      shiny::updateSelectInput(session, "dataset", choices = ds)
    }) |>
      shiny::bindEvent(available_datasets())

    result_sets <- shiny::reactive({
      app_version <- Sys.getenv("NHP_APP_VERSION", "dev") |>
        stringr::str_replace("(\\d+\\.\\d+)\\..*", "\\1")

      rs <- get_result_sets(input$dataset)

      # handle case where no result sets are available
      shiny::req(length(rs) > 0)

      rs |>
        stringr::str_remove("^.*/|\\.json$") |>
        stringr::str_split("-") |>
        purrr::map_dfr(
          purrr::set_names,
          c("scenario", "create_datetime")
        ) |>
        dplyr::mutate(filename = rs)
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

    scenarios <- shiny::reactive({
      x <- shiny::req(result_sets())
      sort(unique(x$scenario))
    })

    shiny::observe({
      x <- shiny::req(scenarios())
      shiny::updateSelectInput(session, "scenario", choices = names(x))
    })

    create_datetimes <- shiny::reactive({
      x <- shiny::req(scenarios())
      result_sets() |>
        dplyr::filter(.data$scenario == x) |>
        dplyr::pull(.data$create_datetime) |>
        unique() |>
        sort()
    })

    shiny::observe({
      x <- shiny::req(create_datetimes())

      labels <- \(.x) .x |>
        lubridate::as_datetime("%Y%m%d_%H%M%S", tz = "UTC") |>
        lubridate::with_tz() |>
        format("%d/%m/%Y %H:%M:%S")

      # choices <- purrr::set_names(names(x), labels)
      choices <- x
      shiny::updateSelectInput(session, "create_datetime", choices = choices)
    })

    selected_model_run_data <- shiny::reactive({
      rs <- result_sets()
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      filename <- result_sets() |>
        dplyr::filter(.data$scenario == sc, .data$create_datetime == cd) |>
        dplyr::pull(filename)

      get_results(filename)
    })

    shiny::observe({
      id <- shiny::req(selected_model_run_data())

      trust_sites <- get_trust_sites(id)

      shiny::updateSelectInput(session, "site_selection", choices = trust_sites)
    }) |>
      shiny::bindEvent(selected_model_run_data())

    selected_model_run <- shiny::reactive({
      list(
        data = selected_model_run_data(),
        site = input$site_selection
      )
    })

    return(selected_model_run)
  })
}

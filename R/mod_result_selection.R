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

    shiny::observe({
      ds <- available_datasets()
      shiny::updateSelectInput(session, "dataset", choices = ds)
    }) |>
      shiny::bindEvent(available_datasets())

    result_sets <- shiny::reactive({
      ds <- shiny::req(input$dataset)
      rs <- get_result_sets(ds)

      print(rs)
      # handle case where no result sets are available
      shiny::req(length(rs) > 0)

      rs |>
        stringr::str_remove_all("^.*/|\\.json(\\.gz)?$") |>
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
        params <- shiny::req(selected_results())$params

        glue::glue("{params$dataset}-{params$scenario}-{params$create_datetime}.json")
      },
      content = function(file) {
        shiny::req(selected_results()) |>
          jsonlite::write_json(file, pretty = TRUE, auto_unbox = TRUE)
      }
    )

    scenarios <- shiny::reactive({
      x <- shiny::req(result_sets())
      sort(unique(x$scenario))
    })

    shiny::observe({
      x <- shiny::req(scenarios())
      shiny::updateSelectInput(session, "scenario", choices = x)
    })

    create_datetimes <- shiny::reactive({
      x <- shiny::req(input$scenario)

      result_sets() |>
        shiny::req() |>
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

      choices <- purrr::set_names(x, labels)
      shiny::updateSelectInput(session, "create_datetime", choices = choices)
    })

    selected_filename <- shiny::reactive({
      rs <- result_sets()
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      result_sets() |>
        shiny::req() |>
        dplyr::filter(.data$scenario == sc, .data$create_datetime == cd) |>
        dplyr::pull(.data$filename)
    })

    selected_results <- shiny::reactive({
      selected_filename() |>
        shiny::req() |>
        get_results()
    }) |>
      shiny::bindCache(selected_filename())

    shiny::observe({
      trust_sites <- selected_results() |>
        shiny::req() |>
        get_trust_sites()

      shiny::updateSelectInput(session, "site_selection", choices = trust_sites)
    })

    return_reactive <- shiny::reactive({
        list(
          data = selected_results(),
          site = input$site_selection
        )
      })
    
    return_reactive
  })
}

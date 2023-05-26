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
mod_result_selection_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    # static data files ----
    providers <- c("Synthetic" = "synthetic", readRDS(app_sys("app", "data", "providers.Rds")))

    # reactives ----
    available_datasets <- shiny::reactive({
      get_user_allowed_datasets(session$user)
    })

    result_sets <- shiny::reactive({
      app_version <- Sys.getenv("NHP_APP_VERSION", "dev") |>
        stringr::str_replace("(\\d+\\.\\d+)\\..*", "\\1")

      get_result_sets(available_datasets(), app_version)
    })

    scenarios <- shiny::reactive({
      ds <- shiny::req(input$dataset)
      
      result_sets() |>
        dplyr::filter(.data[["dataset"]] == ds) |>
        dplyr::arrange(dplyr::desc(.data[["create_datetime"]])) |>
        dplyr::pull("scenario") |>
        unique()
    }) |>
      shiny::bindEvent(input$dataset)
      
    create_datetimes <- shiny::reactive({
      x <- shiny::req(input$scenario)

      result_sets() |>
        shiny::req() |>
        dplyr::filter(.data[["scenario"]] == x) |>
        dplyr::pull(.data[["create_datetime"]]) |>
        unique() |>
        sort() |>
        rev()
    })

    selected_filename <- shiny::reactive({
      rs <- result_sets()
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      result_sets() |>
        shiny::req() |>
        dplyr::filter(
          .data[["dataset"]] == ds,
          .data[["scenario"]] == sc,
          .data[["create_datetime"]] == cd
        ) |>
        dplyr::pull(.data[["file"]])
    })

    selected_results <- shiny::reactive({
      selected_filename() |>
        shiny::req() |>
        get_results()
    }) |>
      shiny::bindCache(selected_filename())

    # observers to update the dropdowns ----
    shiny::observe({
      rs <- shiny::req(result_sets())
      ds <- unique(rs$dataset)

      shiny::updateSelectInput(
        session,
        "dataset",
        choices = providers[providers %in% ds]
      )
    })

    shiny::observe({
      sc <- shiny::req(scenarios())

      shiny::updateSelectInput(
        session,
        "scenario",
        choices = sc
      )
    })

    shiny::observe({
      cd <- shiny::req(create_datetimes())

      labels <- \(.x) .x |>
        lubridate::as_datetime("%Y%m%d_%H%M%S", tz = "UTC") |>
        lubridate::with_tz() |>
        format("%d/%m/%Y %H:%M:%S")

      shiny::updateSelectInput(
        session,
        "create_datetime",
        choices = purrr::set_names(cd, labels)
      )
    })

    shiny::observe({
      trust_sites <- selected_results() |>
        shiny::req() |>
        get_trust_sites()

      shiny::updateSelectInput(session, "site_selection", choices = trust_sites)
    })

    # download button ----

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

    # return reactive ----
    return_reactive <- shiny::reactive({
      list(
        data = selected_results(),
        site = input$site_selection
      )
    })

    return_reactive
  })
}

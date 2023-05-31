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
    
    url_query <- shiny::reactive({
      stringr::str_split(session$clientData$url_hash, "/")[[1]][-1]
    })

    # static data files ----
    providers <- c("Synthetic" = "synthetic", readRDS(app_sys("app", "data", "providers.Rds")))

    # reactives ----
    allowed_datasets <- shiny::reactive({
      get_user_allowed_datasets(session$user)
    })

    result_sets <- shiny::reactive({
      app_version <- Sys.getenv("NHP_APP_VERSION", "dev") |>
        stringr::str_replace("(\\d+\\.\\d+)\\..*", "\\1")

      get_result_sets(allowed_datasets(), app_version)
    })

    filter_result_sets <- function(ds, sc, cd) {
      result_sets() |>
        shiny::req() |>
        dplyr::filter(
          .data[["dataset"]] == ds,
          .data[["scenario"]] == sc,
          .data[["create_datetime"]] == cd
        ) |>
        require_rows()
    }

    datasets <- shiny::reactive({
      rs <- shiny::req(result_sets())
      ds <- unique(rs$dataset)

      providers[providers %in% ds]
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
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      filter_result_sets(ds, sc, cd)$file
    })

    selected_results <- shiny::reactive({
      selected_filename() |>
        shiny::req() |>
        get_results()
    }) |>
      shiny::bindCache(selected_filename())

    # observers to update the dropdowns ----
    shiny::observe({
      ds <- shiny::req(datasets())

      shiny::updateSelectInput(
        session,
        "dataset",
        choices = ds
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
    
    # url routing ----
    # observe the url route and update the select options
    shiny::observe(
      {
        c(ds, sc, cd) %<-% shiny::req(url_query())

        # decode the scenario
        sc <- utils::URLdecode(sc)

        # make sure the options are valid
        filter_result_sets(ds, sc, cd)

        shiny::updateSelectInput(session, "dataset", selected = ds)
        shiny::updateSelectInput(session, "scenario", selected = sc)
        shiny::updateSelectInput(session, "create_datetime", selected = cd)
      },
      # make sure priority of this observer is higher than the observer for updating the url
      priority = -1
    )

    # update the url route after dropdowns change
    shiny::observe(
      {
        ds <- shiny::req(input$dataset)
        sc <- shiny::req(input$scenario)
        cd <- shiny::req(input$create_datetime)

        # make sure the options are valid
        filter_result_sets(ds, sc, cd)

        # encode the scenario
        sc <- utils::URLencode(sc)

        shinyjs::runjs(
          glue::glue(
            "window.location.href='#/{ds}/{sc}/{cd}';"
          )
        )
      },
      # make sure the priority of this observer is lower than the observer for updating the dropdowns
      priority = -2
    )

    # download button ----

    shiny::observe({
      show_button <- !getOption("golem.app.prod", FALSE) || "nhp_power_users" %in% session$groups
      shinyjs::toggle("download_results", selector = show_button)
    })

    output$download_results <- shiny::downloadHandler(
      filename = function() {
        paste0(selected_results()$params$id, ".json")
      },
      content = function(file) {
        selected_results() |>
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

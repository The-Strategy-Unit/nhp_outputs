mod_result_selection_parse_url_hash <- function(url_hash) {
  stringr::str_split(url_hash, "/")[[1]][-1]
}

mod_result_selection_filter_result_sets <- function(result_sets, ds, sc, cd) {
  result_sets |>
    shiny::req() |>
    dplyr::filter(
      .data[["dataset"]] == ds,
      .data[["scenario"]] == sc,
      .data[["create_datetime"]] == cd
    ) |>
    require_rows()
}

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
    shiny::h1("NHP Model Results"),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 6,
      shiny::selectInput(ns("dataset"), "Dataset", NULL),
      shiny::selectInput(ns("scenario"), "Scenario", NULL),
      shiny::selectInput(ns("create_datetime"), "Model run time", NULL),
      shiny::selectInput(ns("site_selection"), "Site (all sites selected if left empty)", NULL, multiple = TRUE)
    ),
    bs4Dash::box(
      title = "Download results data",
      collapsible = FALSE,
      width = 6,
      htmltools::p(
        "Download a file containing results for the selected model run.",
        "The data is provided for each site and for the overall trust level."
      ),
      shinyjs::hidden(
        shiny::downloadButton(ns("download_results_xlsx"), "Download results (.xlsx)"),
        shiny::downloadButton(ns("download_results_json"), "Download results (.json)")
      )
    ),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 6,
      htmltools::p(
        "Further information about the model and these results can be found on the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
          "model project information site."
        )
      ),
      htmltools::p(
        "Note that some data is not available at site level.",
        "A&E data will be hidden and the 'Impact of Changes' tab is at trust level only.",
        "Check the notes box in each tab for details."
      )
    )
  )
}

#' result_selection Server Functions
#'
#' @noRd
mod_result_selection_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # it's not easy to mock changing the url_hash in a unit test, so instead we
    # use this pattern:
    #   * url_query is a reactiveVal, not a reactive, so we can update the value
    #     and test things that depend upon it
    #   * we use a function thats defined outside of this module for parsing the
    #     url which can be tested by itself, but mocked in tests of the module
    #   * we observe the url_hash, perform the business logic, and update the
    #     url_query reactiveVal
    url_query <- shiny::reactiveVal()

    shiny::observe({
      session$clientData$url_hash |>
        mod_result_selection_parse_url_hash() |>
        url_query()
    })

    # static data files ----
    providers <- c("Synthetic" = "synthetic", readRDS(app_sys("app", "data", "providers.Rds")))
    sites <- jsonlite::read_json(app_sys("app", "data", "sites.json"), simplify_vector = TRUE)

    # reactives ----
    allowed_datasets <- shiny::reactive({
      get_user_allowed_datasets(session$groups)
    })

    result_sets <- shiny::reactive({
      app_version <- Sys.getenv("NHP_APP_VERSION", "dev") |>
        stringr::str_replace("(\\d+\\.\\d+)\\..*", "\\1")

      get_result_sets(allowed_datasets(), app_version)
    })

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
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)

      result_sets() |>
        shiny::req() |>
        dplyr::filter(
          .data[["dataset"]] == ds,
          .data[["scenario"]] == sc
        ) |>
        dplyr::pull(.data[["create_datetime"]]) |>
        unique() |>
        sort() |>
        rev()
    })

    selected_filename <- shiny::reactive({
      ds <- shiny::req(input$dataset)
      sc <- shiny::req(input$scenario)
      cd <- shiny::req(input$create_datetime)

      mod_result_selection_filter_result_sets(result_sets(), ds, sc, cd)$file
    })

    selected_results <- shiny::reactive({
      selected_filename() |>
        shiny::req() |>
        get_results()
    }) |>
      shiny::bindCache(selected_filename())

    trust_sites <- shiny::reactive({
      selected_results() |>
        shiny::req() |>
        get_trust_sites() |>
        stringr::str_subset("trust", TRUE)
    })

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
      trust_sites <- purrr::set_names(
        trust_sites(),
        \(.x) {
          purrr::map_chr(
            .x,
            \(.y) glue::glue("{sites[[.y]] %||% lookup_ods_org_code_name(.y)} ({.y})")
          )
        }
      )

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
        mod_result_selection_filter_result_sets(result_sets(), ds, sc, cd)

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
        mod_result_selection_filter_result_sets(result_sets(), ds, sc, cd)

        # encode the scenario
        sc <- utils::URLencode(sc)

        shinyjs::runjs(
          glue::glue(
            "window.location.href = ",
            "window.location.toString().replace(window.location.hash, '') + ",
            "'#/{ds}/{sc}/{cd}';"
          )
        )
      },
      # make sure the priority of this observer is lower than the observer for updating the dropdowns
      priority = -2
    )

    # download buttons ----

    shiny::observe({
      show_button <- !getOption("golem.app.prod", FALSE) || "nhp_power_users" %in% session$groups
      shinyjs::toggle("download_results_xlsx", selector = show_button)
      shinyjs::toggle("download_results_json", selector = show_button)
    })

    output$download_results_xlsx <- shiny::downloadHandler(
      filename = function() {
        paste0(selected_results()$params$id, ".xlsx")
      },
      content = function(file) {
        selected_results() |>
          purrr::pluck("results") |>
          purrr::map(
            dplyr::select,
            -tidyselect::where(is.list)
          ) |>
          writexl::write_xlsx(file)
      }
    )

    output$download_results_json <- shiny::downloadHandler(
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
      sites <- input$site_selection

      if (length(sites) == length(trust_sites())) {
        sites <- character(0)
      }

      list(
        data = selected_results(),
        site = sites
      )
    })

    return_reactive
  })
}

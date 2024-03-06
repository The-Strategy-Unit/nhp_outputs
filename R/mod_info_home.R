#' info_home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_home_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("NHP Model Results"),
    shiny::fluidRow(
      bs4Dash::column(
        width = 6,
        bs4Dash::box(
          title = "Notes",
          collapsible = FALSE,
          width = 12,
          htmltools::p(
            "See",
            htmltools::a(
              href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
              "the model project information site"
            ),
            "for an overview, user guide and methodology for the model and this app."
          ),
          htmltools::p(
            "Use the multi-choice site selection box (upper left) to filter results by sites.",
            "A&E results will not be shown if you select sites."
          )
        ),
        bs4Dash::box(
          title = "Download results data",
          collapsible = FALSE,
          width = 12,
          htmltools::p(
            "Download a file containing results data for the selected model run.",
            "The data is provided for each site and for the overall trust level."
          ),
          # TODO: hide these until data is loaded
          shiny::downloadButton(ns("download_results_xlsx"), "Download results (.xlsx)"),
          shiny::downloadButton(ns("download_results_json"), "Download results (.json)")
        ),
        bs4Dash::box(
          title = "Download outputs report",
          collapsible = FALSE,
          width = 12,
          htmltools::p(
            "Download a file containing the input parameters and",
            "outputs (charts and tables) for the selected model run and selected sites.",
            "This will take a moment.",
          ),
          # TODO: hide until data is loaded
          shiny::downloadButton(ns("download_report_html"), "Download report (.html)")
        )
      ),
      bs4Dash::column(
        width = 6,
        bs4Dash::box(
          title = "Model run information",
          collapsible = FALSE,
          width = 12,
          htmltools::p(
            "This is a reminder of the metadata for the model run you selected."
          ),
          shinycssloaders::withSpinner(
            gt::gt_output(ns("params_model_run"))
          )
        )
      )
    )
  )
}

mod_info_home_download_excel <- function(data) {
  function(file) {
    data() |>
      purrr::pluck("results") |>
      purrr::map(
        dplyr::select,
        -tidyselect::where(is.list)
      ) |>
      writexl::write_xlsx(file)
  }
}

mod_info_home_download_json <- function(data) {
  function(file) {
    jsonlite::write_json(data(), file, pretty = TRUE, auto_unbox = TRUE)
  }
}

mod_info_home_download_report_html <- function(data, sites) {
  function(file) {
    temp_report <- file.path(tempdir(), "report.Rmd")
    file.copy(app_sys("report.Rmd"), temp_report, overwrite = TRUE)

    params <- list(r = data(), sites = sites())

    download_notification <- shiny::showNotification(
      "Rendering report...",
      duration = NULL,
      closeButton = FALSE
    )
    on.exit(shiny::removeNotification(download_notification), add = TRUE)

    rmarkdown::render(
      temp_report,
      output_file = file,
      params = params,
      envir = new.env(parent = globalenv())
    )
  }
}

#' info_home Server Functions
#'
#' @noRd
mod_info_home_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    params_model_run <- shiny::reactive({
      p <- get_params(selected_data())

      p_model_run <- purrr::keep(p, rlang::is_atomic)

      p_model_run[["start_year"]] <- scales::number(
        p_model_run[["start_year"]] + ((p_model_run[["start_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "", decimal.mark = "/"
      )
      p_model_run[["end_year"]] <- scales::number(
        p_model_run[["end_year"]] + ((p_model_run[["end_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "",
        decimal.mark = "/"
      )

      p_model_run[["create_datetime"]] <- p_model_run[["create_datetime"]] |>
        lubridate::fast_strptime("%Y%m%d_%H%M%S") |>
        format("%d-%b-%Y %H:%M:%S")

      p_model_run |>
        unlist() |>
        tibble::enframe()
    })

    output$params_model_run <- gt::render_gt({
      params_model_run() |>
        gt::gt("name") |>
        gt_theme()
    })

    # download buttons ----

    output$download_results_xlsx <- shiny::downloadHandler(
      filename = \() {
        paste0(
          selected_data()$params$id,
          "_results-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".xlsx"
        )
      },
      content = mod_info_home_download_excel(selected_data)
    )

    output$download_results_json <- shiny::downloadHandler(
      filename = \() {
        paste0(
          selected_data()$params$id,
          "_results-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".json"
        )
      },
      content = mod_info_home_download_json(selected_data)
    )

    output$download_report_html <- shiny::downloadHandler(
      filename = \() {
        paste0(
          selected_data()$params$id,
          "_report-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".html"
        )
      },
      content = mod_info_home_download_report_html(selected_data, selected_site)
    )

  })
}

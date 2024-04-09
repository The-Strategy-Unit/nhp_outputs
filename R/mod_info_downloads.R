#' info_downloads UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_downloads_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Information: downloads"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Results data",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing results data for the selected model run.",
          "The data is provided for each site and for the overall trust level."
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_results_xlsx"),
            "Download results (.xlsx)"
          )
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_results_json"),
            "Download results (.json)"
          )
        )
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
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_report_html"),
            "Download report (.html)"
          )
        )
      )
    )
  )
}

mod_info_downloads_download_excel <- function(data) {
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

mod_info_downloads_download_json <- function(data) {
  function(file) {
    jsonlite::write_json(data(), file, pretty = TRUE, auto_unbox = TRUE)
  }
}

mod_info_downloads_download_report_html <- function(data, sites) {
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

#' info_downloads Server Functions
#'
#' @noRd
mod_info_downloads_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {

    # observers ----
    shiny::observe({
      shiny::req(selected_data())

      shinyjs::enable("download_results_xlsx")
      shinyjs::enable("download_results_json")
      shinyjs::enable("download_report_html")
    }) |>
      shiny::bindEvent(selected_data())

    # download buttons ----

    output$download_results_xlsx <- shiny::downloadHandler(
      filename = \() {
        paste0(
          selected_data()$params$id,
          "_results-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".xlsx"
        )
      },
      content = mod_info_downloads_download_excel(selected_data)
    )

    output$download_results_json <- shiny::downloadHandler(
      filename = \() {
        paste0(
          selected_data()$params$id,
          "_results-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".json"
        )
      },
      content = mod_info_downloads_download_json(selected_data)
    )

    output$download_report_html <- shiny::downloadHandler(
      filename = \() {
        paste0(
          selected_data()$params$id,
          "_report-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".html"
        )
      },
      content = mod_info_downloads_download_report_html(selected_data, selected_site)
    )
  })
}

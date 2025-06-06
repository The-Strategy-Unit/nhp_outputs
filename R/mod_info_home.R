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
          title = "About",
          collapsible = FALSE,
          width = 12,
          htmltools::p("Welcome to this NHP online tool."),
          htmltools::p(
            "This tool is designed to help facilitate a demand and capacity modelling process to support the development of robust, local NHP proposals."
          ),
          htmltools::p(
            "The New Hospital Programme requires estimates of future activity levels to inform the design of a new hospital."
          ),
          htmltools::p(
            "This tool is designed to help determine how hospital activity might change in the years to come (relative to a baseline year) and to provide a high-level view of the physical capacity required to meet that demand."
          ),
          htmltools::p(
            "For more information or help, please visit the",
            htmltools::a(
              href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/",
              "model information site"
            ),
            "or contact the",
            htmltools::a(
              href = "mailto:mlcsu.nhpanalytics@nhs.net",
              "MLCSU NHP Analytics mailbox"
            ),
            "."
          )
        ),
        bs4Dash::box(
          title = "App notes",
          collapsible = FALSE,
          width = 12,
          htmltools::p(
            "Select from the 'Results' section in the navbar (left) to view outputs from the selected model run."
          ),
          htmltools::p(
            "Use the multi-choice 'Site selection' box in the navbar to filter results by sites."
          ),
          htmltools::p(
            "From the 'Information' section you can download the results data and reports containing the parameters and outputs (by sites, if selected) for this model run."
          )
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

#' info_home Server Functions
#'
#' @noRd
mod_info_home_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    params_model_run <- shiny::reactive({
      p <- get_params(selected_data())

      p_model_run <- purrr::keep(p, rlang::is_atomic)

      p_model_run[["start_year"]] <- scales::number(
        p_model_run[["start_year"]] +
          ((p_model_run[["start_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "",
        decimal.mark = "/"
      )
      p_model_run[["end_year"]] <- scales::number(
        p_model_run[["end_year"]] +
          ((p_model_run[["end_year"]] + 1) %% 100) / 100,
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

    # renders ----

    output$params_model_run <- gt::render_gt({
      params_model_run() |>
        gt::gt("name") |>
        gt_theme()
    })
  })
}

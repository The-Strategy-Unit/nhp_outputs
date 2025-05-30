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
        title = "Notes",
        collapsible = FALSE,
        width = 12,
        htmltools::p("These files will download one at a time and may take a moment to be generated.")
      ),
      bs4Dash::box(
        title = "Download results data",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing results data for the selected model run.",
          "The data is provided for each site and for the overall trust level.",
          "See details of the content on",
          htmltools::a(
            href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/results.html",
            "the project information site."
          )
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
        title = "Download parameters report (Extract A)",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing the input parameters for",
          "the selected model run."
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_report_parameters_html"),
            "Download parameters report (.html)"
          )
        )
      ),
      bs4Dash::box(
        title = "Download summary outputs report (Extract B)",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing the outputs (charts and tables) for the",
          "selected model run and selected sites. This will take a moment.",
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_report_outputs_html"),
            "Download outputs report (.html)"
          )
        )
      )
    )
  )
}

mod_info_downloads_download_excel <- function(data) {
  function(file) {
    results_dfs <- data() |>
      purrr::pluck("results") |>
      purrr::map(
        dplyr::select,
        -tidyselect::where(is.list)
      )

    # Rename as per
    # https://www.datadictionary.nhs.uk/attributes/emergency_care_attendance_category.html
    results_dfs[["attendance_category"]] <- results_dfs[["attendance_category"]] |>
      dplyr::mutate(
        attendance_category = dplyr::case_match(
          .data[["attendance_category"]],
          "1" ~ "unplanned_first_attendance",
          "2" ~ "unplanned_follow-up_attendance_this_department",
          "3" ~ "unplanned_follow-up_attendance_another_department",
          "4" ~ "planned_follow-up_attendance",
          "X" ~ "not_applicable",
          .default = "unknown"
        )
      )

    # Add the mitigator reference numbers
    results_dfs[["step_counts"]] <- results_dfs[["step_counts"]] |>
      dplyr::left_join(get_mitigator_lookup(), by = "strategy") |>
      dplyr::relocate("mitigator_name", "mitigator_code", .after = "strategy")

    params_list <- data() |>
      purrr::pluck("params") |>
      purrr::keep(rlang::is_atomic)

    params_list[["start_year"]] <- scales::number(
      params_list[["start_year"]] + ((params_list[["start_year"]] + 1) %% 100) / 100,
      0.01,
      big.mark = "", decimal.mark = "/"
    )

    params_list[["end_year"]] <- scales::number(
      params_list[["end_year"]] + ((params_list[["end_year"]] + 1) %% 100) / 100,
      0.01,
      big.mark = "",
      decimal.mark = "/"
    )

    params_list[["create_datetime"]] <- params_list[["create_datetime"]] |>
      lubridate::fast_strptime("%Y%m%d_%H%M%S") |>
      format("%d-%b-%Y %H:%M:%S")

    params_df <- params_list |> unlist() |> tibble::enframe()

    data_dictionary <- jsonlite::read_json(
      app_sys("app", "data", "excel_dictionary.json"),
      simplifyVector = TRUE
    )

    c(list(metadata = params_df), data_dictionary, results_dfs) |>
      writexl::write_xlsx(file)
  }
}

mod_info_downloads_download_json <- function(data) {
  function(file) {
    jsonlite::write_json(
      data(),
      file,
      pretty = TRUE,
      auto_unbox = TRUE,
      digits = NA  # max precision
    )
  }
}

mod_info_downloads_download_report_html <- function(
    data,
    sites = NULL,
    report_type = c("parameters", "outputs")) {
  force(data)
  report_type <- match.arg(report_type)
  function(file) {
    report_file <- glue::glue("report-{report_type}.Rmd")
    temp_report <- file.path(tempdir(), report_file)
    file.copy(app_sys(report_file), temp_report, overwrite = TRUE)

    if (report_type == "parameters") params <- list(r = data())
    if (report_type == "outputs") params <- list(r = data(), sites = sites())

    download_notification <- shiny::showNotification(
      glue::glue("Rendering {report_type} report..."),
      duration = NULL,
      closeButton = FALSE
    )

    on.exit(shiny::removeNotification(download_notification), add = TRUE)

    params$wd <- getwd()

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

      shinyjs::enable("download_report_parameters_html")
      shinyjs::enable("download_report_outputs_html")
    }) |>
      shiny::bindEvent(selected_data())

    # download buttons ----

    filename_stub <- shiny::reactive({
      p <- selected_data()$params
      create_datetime <- stringr::str_replace(p$create_datetime, "_", "-")
      paste(p$dataset, p$scenario, create_datetime, sep = "-") |> tolower()
    })

    # results

    output$download_results_xlsx <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_results.xlsx"),
      content = mod_info_downloads_download_excel(selected_data)
    )

    output$download_results_json <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_results.json"),
      content = mod_info_downloads_download_json(selected_data)
    )

    # params

    output$download_report_parameters_html <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_report-parameters_extract-a.html"),
      content = mod_info_downloads_download_report_html(
        selected_data,
        report_type = "parameters"
      )
    )

    # outputs (plots, tables, etc)

    output$download_report_outputs_html <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_report-outputs_extract-b.html"),
      content = mod_info_downloads_download_report_html(
        selected_data,
        selected_site,
        report_type = "outputs"
      )
    )
  })
}

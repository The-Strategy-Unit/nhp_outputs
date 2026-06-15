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
    results_dfs[["attendance_category"]] <- results_dfs[[
      "attendance_category"
    ]] |>
      dplyr::mutate(
        attendance_category = dplyr::recode_values(
          .data[["attendance_category"]],
          "1" ~ "unplanned_first_attendance",
          "2" ~ "unplanned_follow-up_attendance_this_department",
          "3" ~ "unplanned_follow-up_attendance_another_department",
          "4" ~ "planned_follow-up_attendance",
          "X" ~ "not_applicable",
          default = "unknown"
        )
      )

    # Add the mitigator reference numbers
    results_dfs[["step_counts"]] <- results_dfs[["step_counts"]] |>
      dplyr::left_join(get_tpma_lookup(), by = "strategy") |>
      dplyr::relocate("tpma_label", "tpma_code", .after = "strategy")

    params_list <- data() |>
      purrr::pluck("params") |>
      purrr::keep(rlang::is_atomic)

    params_list[["start_year"]] <- scales::number(
      params_list[["start_year"]] +
        ((params_list[["start_year"]] + 1) %% 100) / 100,
      0.01,
      big.mark = "",
      decimal.mark = "/"
    )

    params_list[["end_year"]] <- scales::number(
      params_list[["end_year"]] +
        ((params_list[["end_year"]] + 1) %% 100) / 100,
      0.01,
      big.mark = "",
      decimal.mark = "/"
    )

    params_list[["create_datetime"]] <- params_list[["create_datetime"]] |>
      lubridate::fast_strptime("%Y%m%d_%H%M%S") |>
      format("%d-%b-%Y %H:%M:%S")

    params_df <- params_list |> unlist() |> tibble::enframe()

    data_dictionary <- yyjsonr::read_json_file(
      app_sys("app", "data", "excel_dictionary.json")
    )

    c(list(metadata = params_df), data_dictionary, results_dfs) |>
      writexl::write_xlsx(file)
  }
}

mod_info_downloads_download_json <- function(data) {
  # TODO: should we just save the json file to disk when we download it, and
  # avoid re-serializing it here?
  function(file) {
    jsonlite::write_json(
      data(),
      file,
      pretty = TRUE,
      auto_unbox = TRUE,
      digits = NA # max precision
    )
  }
}

mod_info_downloads_download_report_html <- function(
  data,
  sites = NULL,
  report_type = c("parameters", "outputs")
) {
  force(data)
  report_type <- match.arg(report_type)
  function(file) {
    report_file <- glue::glue("report-{report_type}.Rmd")
    temp_report <- file.path(tempdir(), report_file)
    file.copy(app_sys(report_file), temp_report, overwrite = TRUE)

    if (report_type == "parameters") {
      params <- list(r = data())
    }
    if (report_type == "outputs") {
      params <- list(r = data(), sites = sites())
    }

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

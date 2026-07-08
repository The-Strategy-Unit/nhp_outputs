mod_info_downloads_reformat_all_results <- function(r) {
  r$results <- purrr::imap(
    r$results,
    \(dat, dat_name) {
      if (dat_name == "step_counts") {
        mod_info_downloads_reformat_step_counts(dat)
      } else {
        mod_info_downloads_reformat_results(dat)
      }
    }
  )
  r
}

mod_info_downloads_reformat_step_counts <- function(dat) {
  dat |>
    dplyr::summarise(
      .by = -c(.data$model_run, .data$value),
      model_runs = list(.data$value),
      value = purrr::map_dbl(.data$model_runs, mean)
    )
}

mod_info_downloads_reformat_results <- function(dat) {
  baseline <- dat |>
    dplyr::filter(.data$model_run == 0) |>
    dplyr::select(-.data$model_run) |>
    dplyr::rename(baseline = .data$value)

  summaries <- dat |>
    dplyr::filter(.data$model_run != 0) |>
    dplyr::summarise(
      .by = -c(.data$model_run, .data$value),
      principal = mean(.data$value),
      model_runs = list(.data$value),
      median = stats::quantile(.data$value, 0.5),
      lwr_pi = stats::quantile(.data$value, 0.1),
      upr_pi = stats::quantile(.data$value, 0.9)
    )

  # Join by all common cols
  join_cols <- intersect(names(baseline), names(summaries))
  dplyr::left_join(baseline, summaries, by = join_cols)
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

    env <- new.env(parent = globalenv())
    source(app_sys("report-helpers.R"), local = env)

    rmarkdown::render(
      temp_report,
      output_file = file,
      params = params,
      envir = env
    )
  }
}

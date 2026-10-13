mod_info_downloads_reformat_all_results <- function(r) {
  purrr::modify_at(r, "results", reformat_all_results)
}

reformat_all_results <- function(results_list) {
  main_names <- setdiff(names(results_list), "step_counts")
  results_list |>
    purrr::modify_at("attendance_category", recode_attcat_table) |>
    purrr::modify_at(main_names, add_stats_to_results_table) |>
    purrr::modify_at("step_counts", reformat_step_counts)
}

reformat_step_counts <- function(tbl) {
  group_cols <- setdiff(colnames(tbl), c("model_run", "value"))
  tbl |>
    dplyr::summarise(
      dplyr::across("value", mean),
      .by = tidyselect::all_of(group_cols)
    ) |>
    dplyr::left_join(get_tpma_lookup(), "strategy") |>
    dplyr::relocate(c("tpma_label", "tpma_code"), .after = "strategy")
}


add_stats_to_results_table <- function(tbl) {
  group_cols <- sub("^model_run$", "stage", setdiff(colnames(tbl), "value"))
  stat_cols <- c("principal", "median", "lwr_pi", "upr_pi")
  tbl |>
    dplyr::mutate(
      stage = dplyr::if_else(.data[["model_run"]] == 0, "baseline", "horizon")
    ) |>
    dplyr::summarise(
      principal = mean(.data[["value"]]),
      median = unname(stats::quantile(.data[["value"]], 0.5)),
      lwr_pi = unname(stats::quantile(.data[["value"]], 0.1)),
      upr_pi = unname(stats::quantile(.data[["value"]], 0.9)),
      .by = tidyselect::all_of(group_cols)
    ) |>
    tidyr::pivot_longer(tidyselect::all_of(stat_cols), names_to = "stat") |>
    tidyr::pivot_wider(names_from = "stage") |>
    tidyr::pivot_wider(names_from = "stat", values_from = "horizon")
}


# https://www.datadictionary.nhs.uk/attributes/emergency_care_attendance_category.html
recode_attcat_table <- function(tbl) {
  tbl |>
    dplyr::mutate(dplyr::across("attendance_category", \(x) {
      dplyr::recode_values(
        x,
        "1" ~ "unplanned_first_attendance",
        "2" ~ "unplanned_follow-up_attendance_this_department",
        "3" ~ "unplanned_follow-up_attendance_another_department",
        "4" ~ "planned_follow-up_attendance",
        "X" ~ "not_applicable",
        default = "unknown"
      )
    }))
}


mod_info_downloads_download_excel <- function(reshaped_data) {
  function(file) {
    results_dfs <- reshaped_data()[["results"]]
    params_df <- format_params(reshaped_data()[["params"]])
    dict_file <- app_sys("app", "data", "excel_dictionary.json")
    data_dict <- yyjsonr::read_json_file(dict_file)

    rlang::inject(list(metadata = params_df, !!!data_dict, !!!results_dfs)) |>
      writexl::write_xlsx(file)
  }
}

mod_info_downloads_download_json <- function(reshaped_data) {
  # TODO: should we just save the json file to disk when we download it, and
  # avoid re-serializing it here?
  function(file) {
    yyjsonr::write_json_file(
      reshaped_data(),
      file,
      yyjsonr::opts_write_json(pretty = TRUE, auto_unbox = TRUE)
    )
  }
}

mod_info_downloads_download_report_html <- function(
  reshaped_data,
  sites = NULL,
  report_type = c("parameters", "outputs")
) {
  force(reshaped_data)
  report_type <- match.arg(report_type)
  function(file) {
    report_file <- glue::glue("report-{report_type}.Rmd")
    temp_report <- file.path(tempdir(), report_file)
    file.copy(app_sys(report_file), temp_report, overwrite = TRUE)

    if (report_type == "parameters") {
      params <- list(r = reshaped_data())
    }
    if (report_type == "outputs") {
      params <- list(r = reshaped_data(), sites = sites())
    }

    download_notification <- shiny::showNotification(
      glue::glue("Rendering {report_type} report..."),
      duration = NULL,
      closeButton = FALSE
    )

    on.exit(shiny::removeNotification(download_notification), add = TRUE)

    # Parent is the package namespace so the report can see unexported functions
    env <- new.env(parent = topenv(environment(sys.function())))
    source(app_sys("report-helpers.R"), local = env)

    rmarkdown::render(
      temp_report,
      output_file = file,
      params = params,
      envir = env
    )
  }
}

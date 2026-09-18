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
    dplyr::filter_out(model_run == 0) |>
    dplyr::summarise(
      dplyr::across("value", mean),
      .by = tidyselect::all_of(group_cols)
    ) |>
    dplyr::left_join(get_tpma_lookup(), "strategy") |>
    dplyr::relocate(c("tpma_label", "tpma_code"), .after = "strategy")
}

add_stats_to_results_table <- function(tbl) {
  group_cols <- setdiff(colnames(tbl), c("model_run", "value"))
  stat_cols <- c("mean", "median", "p10", "p90")
  tbl |>
    dplyr::mutate(
      stage = dplyr::if_else(.data[["model_run"]] == 0, "baseline", "principal")
    ) |>
    dplyr::summarise(
      mean = mean(.data[["value"]]),
      median = stats::quantile(.data[["value"]], 0.5),
      p10 = stats::quantile(.data[["value"]], 0.1),
      p90 = stats::quantile(.data[["value"]], 0.9),
      .by = tidyselect::all_of(group_cols)
    ) |>
    tidyr::pivot_longer(tidyselect::all_of(stat_cols), names_to = "stat") |>
    tidyr::pivot_wider(names_from = "stage") |>
    tidyr::pivot_wider(names_from = "stat", values_from = "principal") |>
    dplyr::rename(principal = "mean", lwr_pi = "p10", upr_pi = "p90")
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


mod_info_downloads_download_excel <- function(data, filename) {
  results_dfs <- purrr::pluck(data(), "results")

  params_df <- data() |>
    purrr::pluck("params") |>
    purrr::keep(rlang::is_atomic) |>
    purrr::modify_at(c("start_year", "end_year"), reformat_fyear) |>
    purrr::modify_at("create_datetime", format_create_datetime) |>
    unlist() |>
    tibble::enframe()

  dict_file <- app_sys("app", "data", "excel_dictionary.json")
  data_dict <- yyjsonr::read_json_file(dict_file)

  rlang::inject(list(metadata = params_df, !!!data_dict, !!!results_dfs)) |>
    writexl::write_xlsx(filename)
}

mod_info_downloads_download_json <- function(data, filename) {
  # TODO: should we just save the json file to disk when we download it, and
  # avoid re-serializing it here?
  jsonlite::write_json(
    data(),
    filename,
    pretty = TRUE,
    auto_unbox = TRUE,
    digits = NA # max precision
  )
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

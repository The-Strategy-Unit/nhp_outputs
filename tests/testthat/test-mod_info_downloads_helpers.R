test_that("add_stats_to_results_table does what we expect", {
  init_tbl <- tibble::tibble(
    pod = "aae",
    measure = "ambulance",
    model_run = seq(0, 10),
    value = seq(11)
  )
  group_cols <- setdiff(colnames(init_tbl), "value")
  stat_cols <- c("principal", "median", "lwr_pi", "upr_pi")

  int_tbl <- init_tbl |>
    dplyr::mutate(
      stage = dplyr::if_else(.data[["model_run"]] == 0, "baseline", "horizon")
    ) |>
    dplyr::summarise(
      principal = mean(.data[["value"]]),
      median = unname(stats::quantile(.data[["value"]], 0.5)),
      lwr_pi = unname(stats::quantile(.data[["value"]], 0.1)),
      upr_pi = unname(stats::quantile(.data[["value"]], 0.9)),
      .by = tidyselect::all_of(sub("^model_run$", "stage", group_cols))
    )
  exp_int_tbl <- tibble::tibble(
    pod = "aae",
    measure = "ambulance",
    stage = c("baseline", "horizon"),
    principal = c(1, 6.5),
    median = c(1, 6.5),
    lwr_pi = c(1, 2.9),
    upr_pi = c(1, 10.1)
  )
  expect_identical(int_tbl, exp_int_tbl)

  int_tbl2 <- int_tbl |>
    tidyr::pivot_longer(tidyselect::all_of(stat_cols), names_to = "stat")

  exp_int_tbl2 <- tibble::tibble(
    pod = "aae",
    measure = "ambulance",
    stage = rep(c("baseline", "horizon"), each = length(stat_cols)),
    stat = rep(stat_cols, times = 2),
    value = c(rep(1, length(stat_cols)), 6.5, 6.5, 2.9, 10.1)
  )
  expect_identical(int_tbl2, exp_int_tbl2)

  int_tbl3 <- tidyr::pivot_wider(int_tbl2, names_from = "stage")
  exp_int_tbl3 <- tibble::tibble(
    pod = "aae",
    measure = "ambulance",
    stat = stat_cols,
    baseline = rep(1, length(stat_cols)),
    horizon = c(6.5, 6.5, 2.9, 10.1)
  )
  expect_identical(int_tbl3, exp_int_tbl3)

  int_tbl4 <- int_tbl3 |>
    tidyr::pivot_wider(names_from = "stat", values_from = "horizon")
  exp_int_tbl4 <- tibble::tibble(
    pod = "aae",
    measure = "ambulance",
    baseline = 1,
    principal = 6.5,
    median = 6.5,
    lwr_pi = 2.9,
    upr_pi = 10.1
  )
  expect_identical(int_tbl4, exp_int_tbl4)
})

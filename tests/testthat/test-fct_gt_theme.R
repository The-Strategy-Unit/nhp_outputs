library(shiny)
library(mockery)

test_that("it themes tables correctly", {
  set.seed(1)

  table <- tibble::tribble(
    ~g,
    ~x,
    ~y,
    "a",
    1,
    2,
    "a",
    3,
    4,
    "b",
    5,
    6,
    "b",
    7,
    8
  ) |>
    gt::gt(groupname_col = "g") |>
    gt_theme()

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

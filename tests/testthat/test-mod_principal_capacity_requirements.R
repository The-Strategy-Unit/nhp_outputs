library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

beds_expected <- tibble::tribble(
  ~quarter, ~ward_type, ~ward_group, ~baseline, ~principal, ~model_run, ~value, ~variant,
  "q1", "a", "a", 50, 45, 1, 1, "a",
  "q1", "a", "a", 50, 45, 2, 2, "a",
  "q1", "a", "a", 50, 45, 3, 3, "b",
  "q1", "a", "b", 60, 75, 1, 4, "a",
  "q1", "a", "b", 60, 75, 2, 5, "a",
  "q1", "a", "b", 60, 75, 3, 6, "b",
  "q1", "b", "c", 80, 90, 1, 7, "a",
  "q1", "b", "c", 80, 90, 2, 8, "a",
  "q1", "b", "c", 80, 90, 3, 9, "b"
)

beds_data_filtered_expected <- beds_expected |>
  dplyr::filter(model_run == 1) |>
  dplyr::select("quarter", "ward_type", "ward_group", "baseline", "principal")

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
test_that("ui is created correctly", {
  set.seed(123)
  expect_snapshot(mod_principal_capacity_requirements_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helper functions
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("beds_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically

  data <- beds_expected |>
    dplyr::filter(model_run == 1) |>
    dplyr::select("quarter", "ward_type", "ward_group", "baseline", "principal")

  table <- c("q1", "q2", "q3", "q4") |>
    purrr::map_dfr(\(.x) dplyr::mutate(data, quarter = .x)) |>
    mod_principal_capacity_requirements_beds_table()

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})


# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls get_bed_occupancy correctly", {
  m <- mock(beds_expected)

  stub(mod_principal_capacity_requirements_server, "get_bed_occupancy", m)

  shiny::testServer(mod_principal_capacity_requirements_server, args = list(reactiveVal()), {
    selected_data("data")

    expect_equal(beds_data(), beds_data_filtered_expected)

    expect_called(m, 1)
    expect_args(m, 1, "data")
  })
})

test_that("it renders the table", {
  m <- mock(
    mod_principal_capacity_requirements_get_utilisation_table(beds_expected)
  )
  stub(mod_principal_capacity_requirements_server, "get_bed_occupancy", beds_expected)
  stub(mod_principal_capacity_requirements_server, "mod_principal_capacity_requirements_beds_table", m)

  shiny::testServer(mod_principal_capacity_requirements_server, args = list(reactiveVal()), {
    selected_data("data")

    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, beds_data_filtered_expected)
  })
})

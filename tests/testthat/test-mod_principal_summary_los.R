library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)
  expect_snapshot(mod_principal_summary_los_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_summary_los_data summarises the data", {
  data <- list(
    results = list(
      los_group = tibble::tribble(
        ~pod, ~measure, ~sitetret, ~los_group, ~baseline, ~principal,
        "a", "beddays", "trust", "0-day", 1, 2,
        "a", "beddays", "trust", "1-7 days", 3, 4,
        "a", "beddays", "trust", "8-14 days", 5, 6,
        "b", "beddays", "trust", "0-day", 7, 8,
        "a", "admissions", "trust", "0-day", 1, 2,
        "a", "admissions", "trust", "1-7 days", 3, 4,
        "a", "admissions", "trust", "8-14 days", 5, 6,
        "b", "admissions", "trust", "0-day", 7, 8
      )
    )
  )

  expected <- tibble::tribble(
    ~pod_name, ~los_group, ~baseline, ~principal,
    "A", "0-day", 1, 2,
    "A", "1-7 days", 3, 4,
    "A", "8-14 days", 5, 6,
    "B", "0-day", 7, 8
  ) |>
    dplyr::mutate(
      los_group = factor(
        los_group,
        levels = c("0-day", "1-7 days", "8-14 days", "15-21 days", "22+ days")
      ),
      change = principal - baseline,
      change_pcnt = change / baseline
    )

  stub(
    mod_principal_summary_los_data,
    "mod_principal_high_level_pods",
    tibble::tibble(
      pod = c("a", "b"),
      pod_name = c("A", "B")
    )
  )

  actual <- mod_principal_summary_los_data(
    r = data,
    sites = "trust",
    measure = "beddays"
  )

  expect_equal(actual, expected)
})

test_that("mod_principal_summary_los_table creates a gt object", {
  set.seed(1)

  data <- tibble::tibble(
    pod_name = c("a", "a", "b", "b"),
    los_group = c("x", "y", "x", "y"),
    baseline = 1:4,
    principal = 5:8
  ) |>
    dplyr::mutate(
      los_group = factor(los_group),
      change = principal - baseline,
      change_pcnt = change / baseline
    )

  table <- mod_principal_summary_los_table(data)

  expect_snapshot(gt::as_raw_html(table))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


test_that("it sets up the reactives correctly", {
  d <- tibble::tibble(value = 1:2)
  m <- mock(d, cycle = TRUE)

  stub(mod_principal_summary_los_server, "mod_principal_summary_los_data", m)

  shiny::testServer(
    mod_principal_summary_los_server, args = list(reactiveVal(), reactiveVal()), {
      selected_data(1)
      selected_site("a")

      expect_equal(summary_los_data_beddays(), d)
      expect_equal(summary_los_data_admissions(), d)
    }
  )

  expect_called(m, 2)
  expect_args(m, 1, 1, "a", "beddays")
  expect_args(m, 2, 1, "a", "admissions")

})

test_that("it creates the table", {
  m <- mock()
  stub(mod_principal_summary_los_server, "gt::render_gt", m)
  stub(mod_principal_summary_los_server, "mod_principal_summary_los_data", NULL)
  stub(mod_principal_summary_los_server, "mod_principal_summary_los_table", NULL)

  shiny::testServer(mod_principal_summary_los_server, args = list(reactiveVal()), {
    expect_called(m, 2)
  })
})

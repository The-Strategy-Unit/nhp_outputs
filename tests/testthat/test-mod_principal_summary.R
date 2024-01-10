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
  expect_snapshot(mod_principal_summary_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_summary_data summarises the data", {
  m1 <- mock(
    tibble::tribble(
      ~pod, ~sitetret, ~baseline, ~principal,
      "a_1", "trust", 1, 2,
      "a_2", "trust", 3, 4,
      "b_1", "trust", 4, 5,
      "b_2", "trust", 6, 7,
      "c_1", "trust", 8, 9
    ),
    cycle = TRUE
  )
  m2 <- mock(
    tibble::tribble(
      ~quarter, ~model_run, ~baseline, ~principal,
      "q1", 1, 1, 2,
      "q1", 1, 3, 4,
      "q2", 1, 1, 2,
      "q2", 1, 3, 4,
      "q1", 2, 1, 2,
      "q1", 2, 3, 4,
      "q2", 2, 1, 2,
      "q2", 2, 3, 4,
    )
  )

  expected <- tibble::tribble(
    ~sitetret, ~pod_name, ~baseline, ~principal,
    "trust", "A 1",            1, 2,
    "trust", "A 1",            1, 2,
    "trust", "A 2",            3, 4,
    "trust", "A 2",            3, 4,
    "trust", "B 1",            4, 5,
    "trust", "B 1",            4, 5,
    "trust", "B 2",            6, 7,
    "trust", "B 2",            6, 7,
    "trust", "Beds Available", 4, 6
  )

  stub(
    mod_principal_summary_data,
    "mod_principal_high_level_pods",
    tibble::tibble(
      activity_type = c("ip", "ip", "op", "aae"),
      pod = c("a_1", "a_2", "b_1", "b_2"),
      pod_name = c("A 1", "A 2", "B 1", "B 2")
    )
  )

  stub(mod_principal_summary_data, "get_principal_high_level", m1)
  stub(mod_principal_summary_data, "get_bed_occupancy", m2)

  actual <- mod_principal_summary_data("data")

  expect_called(m1, 2)
  expect_called(m2, 1)

  expect_args(m1, 1, "data", c("admissions", "attendances", "walk-in", "ambulance"))
  expect_args(m1, 2, "data", "tele_attendances")
  expect_args(m2, 1, "data")

  expect_equal(actual, expected)
})

test_that("mod_principal_summary_table creates a gt object", {
  data <- tibble::tibble(
    pod_name = c("a", "b", "c"),
    baseline = 1:3,
    principal = 4:6
  )

  expect_snapshot(mod_principal_summary_table(data))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


test_that("it sets up the reactives correctly", {
  d <- tibble::tibble(
    sitetret = c("a", "b"),
    value = 1:2
  )
  m <- mock(d, cycle = TRUE)

  stub(mod_principal_summary_server, "mod_principal_summary_data", m)

  shiny::testServer(mod_principal_summary_server, args = list(reactiveVal(), reactiveVal()), {
    selected_data(1)
    selected_site("a")

    expect_equal(summary_data(), d)
    expect_equal(site_data(), tibble::tibble(value = 1))

    selected_data(2)
    selected_site("b")

    expect_equal(summary_data(), d)
    expect_equal(site_data(), tibble::tibble(value = 2))
  })

  expect_called(m, 2)
  expect_args(m, 1, 1)
  expect_args(m, 2, 2)
})

test_that("it creates the table", {
  m <- mock()
  stub(mod_principal_summary_server, "gt::render_gt", m)
  stub(mod_principal_summary_server, "mod_principal_summary_data", NULL)
  stub(mod_principal_summary_server, "mod_principal_summary_table", NULL)

  shiny::testServer(mod_principal_summary_server, args = list(reactiveVal()), {
    expect_called(m, 1)
  })
})

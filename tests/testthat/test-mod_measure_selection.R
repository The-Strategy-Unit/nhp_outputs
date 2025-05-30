library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

atpmo_expected <- tibble::tribble(
  ~activity_type, ~activity_type_name, ~pod, ~pod_name, ~measures,
  "aae", "A&E", "aae_type-01", "Type 1 Department", "ambulance",
  "aae", "A&E", "aae_type-02", "Type 2 Department", "ambulance",
)

set_names <- function(x) {
  rlang::set_names(x[[1]], x[[2]])
}

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_measure_selection_ui("id"))
  expect_snapshot(mod_measure_selection_ui("id"), 3)
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it loads the reference data and set's the activity_type dropdown", {
  m <- mock()

  stub(
    mod_measure_selection_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected,
    2
  )
  stub(
    mod_measure_selection_server,
    "shiny::updateSelectInput",
    m,
    2
  )

  activity_types <- atpmo_expected |>
    dplyr::distinct(
      dplyr::across(
        tidyselect::starts_with("activity_type")
      )
    ) |>
    set_names()

  shiny::testServer(mod_measure_selection_server, {
    # need to trigger an invalidation to run the initial observe
    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, session, "activity_type", choices = activity_types)
  })
})

test_that("it updates the pod dropdown when activity_type changes", {
  m <- mock()

  stub(
    mod_measure_selection_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected,
    2
  )
  stub(
    mod_measure_selection_server,
    "shiny::updateSelectInput",
    m,
    2
  )

  at <- "aae"
  pods <- atpmo_expected |>
    dplyr::filter(.data$activity_type == at) |>
    dplyr::distinct(
      dplyr::across(
        tidyselect::starts_with("pod")
      )
    ) |>
    set_names()

  shiny::testServer(mod_measure_selection_server, {
    session$setInputs(activity_type = at)

    expect_called(m, 2)
    expect_args(m, 2, session, "pod", choices = pods, selected = pods)
  })
})

test_that("it updates the measure dropdown when pod changes", {
  m <- mock()

  stub(
    mod_measure_selection_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected,
    2
  )
  stub(
    mod_measure_selection_server,
    "shiny::updateSelectInput",
    m,
    2
  )

  shiny::testServer(mod_measure_selection_server, {
    session$setInputs(activity_type = "aae", pod = "aae_type-01")

    expect_called(m, 3)
    expect_args(
      m,
      3,
      session,
      "measure",
      choices = c(`Ambulance Arrivals` = "ambulance"),
      selected = "ambulance"
    )
  })
})

test_that("it returns a reactive", {
  stub(mod_measure_selection_server, "shiny::reactive", "reactive", 2)

  shiny::testServer(function(input, output, session) {
    r <- mod_measure_selection_server("id")
  }, {
    expect_equal(r, "reactive")
  })
})

test_that("selected_measure contains the selected dropdown values", {
  stub(
    mod_measure_selection_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected,
    2
  )

  at <- "aae"
  p <- "aae_type-01"
  m <- "ambulance"

  shiny::testServer(mod_measure_selection_server, {
    # first, test that we get errors if values aren't set
    expect_error(selected_measure())
    session$setInputs(activity_type = at)
    expect_error(selected_measure())
    session$setInputs(activity_type = at, pod = p)
    expect_error(selected_measure())

    session$setInputs(activity_type = at, pod = p, measure = m)
    expect_equal(
      selected_measure(),
      list(activity_type = at, pod = p, measure = m)
    )
  })
})

test_that("selected_measure contains the selected multi-pod dropdown values", {
  stub(
    mod_measure_selection_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected,
    2
  )

  at <- "aae"
  p <- c("aae_type-01", "aae_type-02")
  m <- "ambulance"

  shiny::testServer(mod_measure_selection_server, {
    # first, test that we get errors if values aren't set
    expect_error(selected_measure())
    session$setInputs(activity_type = at)
    expect_error(selected_measure())
    session$setInputs(activity_type = at, pod = p)
    expect_error(selected_measure())

    session$setInputs(activity_type = at, pod = p, measure = m)
    expect_equal(
      selected_measure(),
      list(activity_type = at, pod = p, measure = m)
    )
  })
})

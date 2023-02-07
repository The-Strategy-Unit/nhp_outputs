library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

available_result_sets <- tibble::tribble(
  ~dataset, ~scenario, ~create_datetime, ~id,
  "a", "1", "20220101_012345", "a__1__20220101_012345",
  "a", "2", "20220102_103254", "a__2__20220102_103254",
  "a", "1", "20220203_112233", "a__1__20220203_112233",
  "b", "1", "20220201_112233", "b__1__20220201_112233"
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_result_selection_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it populates the list of available result sets", {
  m <- mock(available_result_sets, cycle = TRUE)

  stub(mod_result_selection_server, "cosmos_get_result_sets", m)

  testServer(mod_result_selection_server, args = list(reactiveVal()), {
    expected <- list(
      a = list(
        "1" = c(
          "20220101_012345" = "a__1__20220101_012345",
          "20220203_112233" = "a__1__20220203_112233"
        ),
        "2" = c(
          "20220102_103254" = "a__2__20220102_103254"
        )
      ),
      b = list(
        "1" = c(
          "20220201_112233" = "b__1__20220201_112233"
        )
      )
    )

    user_allowed_datasets("a")
    actual <- results_sets()
    expect_equal(actual, expected["a"])

    user_allowed_datasets(c("a", "b"))
    actual <- results_sets()
    expect_equal(actual, expected)

    expect_called(m, 2)
  })
})

test_that("it shows the download button when golem.app.prod = FALSE", {
  withr::local_options(c("golem.app.prod" = FALSE))

  m <- mock()
  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shinyjs::toggle", m)

  testServer(mod_result_selection_server, args = list(reactiveVal()), {
    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, "download_results", selector = TRUE)
  })
})

test_that("it shows the download button when the user is in the correct group", {
  withr::local_options(c("golem.app.prod" = TRUE))

  m <- mock()
  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shinyjs::toggle", m)

  testServer(mod_result_selection_server, args = list(reactiveVal()), {
    session$private$flush()
  })

  session <- shiny::MockShinySession$new()
  session$groups <- "nhp_power_users"
  testServer(mod_result_selection_server, args = list(reactiveVal()), session = session, {
    session$private$flush()
  })

  expect_called(m, 2)
  expect_args(m, 1, "download_results", selector = FALSE)
  expect_args(m, 2, "download_results", selector = TRUE)
})

test_that("it sets up the dropdowns", {
  m <- mock()

  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shiny::updateSelectInput", m)

  testServer(mod_result_selection_server, args = list(reactiveVal("a")), {
    session$private$flush()
    session$setInputs(dataset = "a")
    session$setInputs(scenario = "1")

    expect_called(m, 3)
    expect_args(m, 1, session, "dataset", choices = "a")
    expect_args(m, 2, session, "scenario", choices = c("1", "2"))
    expect_args(m, 3, session, "create_datetime", choices = c(
      "01/01/2022 01:23:45" = "20220101_012345",
      "03/02/2022 11:22:33" = "20220203_112233"
    ))
  })
})

test_that("chosing an invalid dataset causes an error", {
  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shiny::updateSelectInput", NULL)

  testServer(mod_result_selection_server, args = list(reactiveVal("a", "b")), {
    session$setInputs(dataset = "Z")

    expect_error(scenarios())
  })
})

test_that("chosing an invalid combination of dataset and scenario causes an error", {
  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shiny::updateSelectInput", NULL)

  testServer(mod_result_selection_server, args = list(reactiveVal("a", "b")), {
    session$setInputs(dataset = "a")
    session$setInputs(scenario = "Z")

    expect_error(create_datetimes())
  })
})

test_that("it returns a reactive", {
  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)

  testServer(mod_result_selection_server, args = list(reactiveVal("a")), {
    session$setInputs(
      dataset = "a",
      scenario = "1",
      create_datetime = "20220101_012345",
      site_selection = "trust"
    )

    expect_equal(selected_model_run(), list(
      ds = "a", sc = "1", cd = "20220101_012345", id = "a__1__20220101_012345", site = "trust"
    ))
  })

  server <- function(input, output, session) {
    results <- mod_result_selection_server("id", reactiveVal("a"))
  }
  testServer(server, {
    expect_true(shiny::is.reactive(results))
  })
})

test_that("it downloads the results", {
  m <- mock(list(data = 1))
  stub(mod_result_selection_server, "cosmos_get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "cosmos_get_full_model_run_data", m)

  testServer(mod_result_selection_server, args = list(reactiveVal("a")), {
    session$setInputs(
      dataset = "a",
      scenario = "1",
      create_datetime = "20220101_012345",
      site_selection = "trust"
    )

    results_file <- output$download_results
    withr::local_file(results_file)

    expect_called(m, 1)
    expect_args(m, 1, "a__1__20220101_012345")

    results <- readr::read_lines(results_file)
    expect_equal(results, c("{", "  \"data\": 1", "}"))
  })
})

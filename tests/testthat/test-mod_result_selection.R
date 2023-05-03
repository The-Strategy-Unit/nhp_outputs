library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

available_result_sets <- c(
  "1-20220101_012345",
  "2-20220102_103254",
  "1-20220203_112233",
  "1-20220201_112233"
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

  stub(mod_result_selection_server, "get_result_sets", m)

  testServer(mod_result_selection_server, args = list(reactiveVal()), {
    session$setInputs(dataset = "synthetic")

    expected <- tibble::tibble(
      scenario = c("1", "2", "1", "1"),
      create_datetime = c("20220101_012345", "20220102_103254", "20220203_112233", "20220201_112233"),
      filename = available_result_sets
    )

    actual <- result_sets()
    expect_equal(actual, expected)

    expect_called(m, 1)
    expect_args(m, 1, "synthetic")
  })
})

test_that("it shows the download button when golem.app.prod = FALSE", {
  withr::local_options(c("golem.app.prod" = FALSE))

  m <- mock()
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
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
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
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
  m_get_result_sets <- mock(character(), available_result_sets)

  stub(mod_result_selection_server, "get_user_allowed_datasets", "a")
  stub(mod_result_selection_server, "get_result_sets", m_get_result_sets)
  stub(mod_result_selection_server, "shiny::updateSelectInput", m)

  testServer(mod_result_selection_server, args = list(reactiveVal("a")), {
    session$private$flush()
    session$setInputs(dataset = "b")
    session$setInputs(scenario = "1")
    session$setInputs(dataset = "a")

    expect_called(m, 9)
    expect_args(m, 1, session, "dataset", choices = "a")

    expect_args(m, 2, session, "scenario", choices = character(0))
    expect_args(m, 3, session, "create_datetime", choices = character(0))
    expect_args(m, 4, session, "trust", choices = character(0))

    expect_args(m, 5, session, "scenario", choices = character(0))
    expect_args(m, 6, session, "create_datetime", choices = character(0))
    expect_args(m, 7, session, "trust", choices = character(0))

    expect_args(m, 8, session, "scenario", choices = c("1", "2"))
    expect_args(m, 9, session, "create_datetime", choices = c(
      "01/01/2022 01:23:45" = "20220101_012345",
      "01/02/2022 11:22:33" = "20220201_112233",
      "03/02/2022 11:22:33" = "20220203_112233"
    ))
  })
})

test_that("it returns a reactive", {
  m <- mock("data")

  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "get_results", m)
  stub(mod_result_selection_server, "get_trust_sites", "trust")

  testServer(mod_result_selection_server, args = list(reactiveVal("a")), {
    result_sets <- \() tibble::tibble(
      scenario = c("1", "1", "2"),
      create_datetime = c("20220101_012345", "", "20220101_012345")
    )

    session$setInputs(dataset = "a")
    session$setInputs(scenario = "1")
    session$setInputs(create_datetime = "20220101_012345")
    session$setInputs(site_selection = "trust")

    expect_equal(
      return_reactive(),
      list(
        data = "data",
        site = "trust"
      )
    )
  })

  expect_called(m, 1)
  expect_args(m, 1, "1-20220101_012345")

  server <- function(input, output, session) {
    results <- mod_result_selection_server("id", reactiveVal("a"))
  }
  testServer(server, {
    expect_true(shiny::is.reactive(results))
  })
})

test_that("it downloads the results", {
  expected <- list(
    params = list(
      "dataset" = "a",
      "scenario" = "1",
      "create_datetime" = "20220101_012345"
    )
  )

  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "get_trust_sites", "trust")
  stub(mod_result_selection_server, "get_results", expected)

  testServer(mod_result_selection_server, args = list(reactiveVal("a")), {
    session$setInputs(dataset = "a")
    session$setInputs(scenario = "1")
    session$setInputs(create_datetime = "20220101_012345")
    session$setInputs(site_selection = "trust")

    results_file <- output$download_results
    withr::local_file(results_file)

    expect_true(stringr::str_ends(results_file, "a-1-20220101_012345.json"))

    results <- readr::read_lines(results_file)
    expect_equal(results, c(
      "{",
      "  \"params\": {",
      "    \"dataset\": \"a\",",
      "    \"scenario\": \"1\",",
      "    \"create_datetime\": \"20220101_012345\"",
      "  }",
      "}"
    ))
  })
})

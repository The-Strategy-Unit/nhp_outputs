library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

available_result_sets <- tibble::tribble(
  ~file, ~dataset, ~scenario, ~create_datetime, ~id,
  "1", "a", "a1", "20210203_012345", "1.json",
  "1", "a", "a1", "20220101_103254", "1.json",
  "2", "a", "a2", "20230101_000000", "2.json",
  "3", "b", "b3", "20230101_000000", "3.json"
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
  m_ad <- mock(c("a", "b"), cycle = TRUE)
  m_rs <- mock(available_result_sets, cycle = TRUE)

  stub(mod_result_selection_server, "get_user_allowed_datasets", m_ad)
  stub(mod_result_selection_server, "get_result_sets", m_rs)

  testServer(mod_result_selection_server, {
    session$setInputs(dataset = "a")

    actual <- result_sets()
    expect_equal(actual, available_result_sets)

    expect_called(m_ad, 1)
    expect_args(m_ad, 1, NULL)

    expect_called(m_rs, 1)
    expect_args(m_rs, 1, c("a", "b"), "dev")
  })
})

test_that("it shows the download button when golem.app.prod = FALSE", {
  withr::local_options(c("golem.app.prod" = FALSE))

  m <- mock()
  stub(mod_result_selection_server, "get_user_allowed_datasets", c("a", "b"))
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shinyjs::toggle", m)

  testServer(mod_result_selection_server, {
    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, "download_results", selector = TRUE)
  })
})

test_that("it shows the download button when the user is in the correct group", {
  withr::local_options(c("golem.app.prod" = TRUE))

  m <- mock()
  stub(mod_result_selection_server, "get_user_allowed_datasets", c("a", "b"))
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "shinyjs::toggle", m)

  testServer(mod_result_selection_server, {
    session$private$flush()
  })

  session <- shiny::MockShinySession$new()
  session$groups <- "nhp_power_users"
  testServer(mod_result_selection_server, session = session, {
    session$private$flush()
  })

  expect_called(m, 2)
  expect_args(m, 1, "download_results", selector = FALSE)
  expect_args(m, 2, "download_results", selector = TRUE)
})

test_that("it sets up the dropdowns", {
  m <- mock()
  m_get_result_sets <- mock(available_result_sets)

  stub(mod_result_selection_server, "readRDS", c("A" = "a", "B" = "b"))
  stub(mod_result_selection_server, "get_user_allowed_datasets", "a")
  stub(mod_result_selection_server, "get_result_sets", m_get_result_sets)
  stub(mod_result_selection_server, "shiny::updateSelectInput", m)

  testServer(mod_result_selection_server, {
    session$private$flush()
    session$setInputs(dataset = "b")
    session$setInputs(scenario = "b3")
    session$setInputs(dataset = "a")
    session$setInputs(scenario = "a1")

    expect_args(m, 1, session, "dataset", choices = c("A" = "a", "B" = "b"))

    expect_args(m, 2, session, "scenario", choices = c("b3"))
    expect_args(m, 3, session, "create_datetime", choices = c(
      "01/01/2023 00:00:00" = "20230101_000000"
    ))

    expect_args(m, 4, session, "scenario", choices = c("a2", "a1"))
    expect_args(m, 5, session, "create_datetime", choices = c(
      "01/01/2022 10:32:54" = "20220101_103254",
      "03/02/2021 01:23:45" = "20210203_012345"
    ))
  })
})

test_that("it returns a reactive", {
  m <- mock("data")

  stub(mod_result_selection_server, "get_user_allowed_datasets", c("a", "b"))
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "get_results", m)
  stub(mod_result_selection_server, "get_trust_sites", "trust")

  testServer(mod_result_selection_server, {
    result_sets <- \() tibble::tibble(
      scenario = c("1", "1", "2"),
      create_datetime = c("20220101_012345", "", "20220101_012345")
    )

    session$setInputs(dataset = "a")
    session$setInputs(scenario = "a1")
    session$setInputs(create_datetime = "20210203_012345")
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
  expect_args(m, 1, "1")

  server <- function(input, output, session) {
    results <- mod_result_selection_server("id")
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
      "create_datetime" = "20220101_012345",
      "id" = "1"
    )
  )

  stub(mod_result_selection_server, "get_user_allowed_datasets", c("a", "b"))
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)
  stub(mod_result_selection_server, "get_trust_sites", "trust")
  stub(mod_result_selection_server, "get_results", expected)


  testServer(mod_result_selection_server, {
    session$setInputs(dataset = "a")
    session$setInputs(scenario = "a1")
    session$setInputs(create_datetime = "20210203_012345")
    session$setInputs(site_selection = "trust")

    results_file <- output$download_results
    withr::local_file(results_file)

    expect_true(stringr::str_ends(results_file, "1.json"))

    results <- readr::read_lines(results_file)
    expect_equal(results, c(
      "{",
      "  \"params\": {",
      "    \"dataset\": \"a\",",
      "    \"scenario\": \"1\",",
      "    \"create_datetime\": \"20220101_012345\",",
      "    \"id\": \"1\"",
      "  }",
      "}"
    ))
  })
})

test_that("mod_result_selection_server_parse_url_hash parses the selections out of the url hash", {
  actual <- mod_result_selection_parse_url_hash("#/abc/def/hij")
  expect_equal(actual, c("abc", "def", "hij"))
})

test_that("we correctly parse the url_hash", {
  m <- mock(c("abc", "def", "hij"))

  stub(mod_result_selection_server, "get_user_allowed_datasets", c("a", "b"))
  stub(mod_result_selection_server, "get_result_sets", available_result_sets)

  stub(
    mod_result_selection_server,
    "mod_result_selection_parse_url_hash",
    m
  )

  testServer(mod_result_selection_server, {
    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, "#mockhash")
    expect_equal(url_query(), c("abc", "def", "hij"))
  })
})

test_that("we update dropdown selections when url_query changes", {
  m <- mock()
  stub(mod_result_selection_server, "shiny::updateSelectInput", m)
  stub(mod_result_selection_server, "get_user_allowed_datasets", c("a", "b"))
  stub(mod_result_selection_server, "get_result_sets", NULL)
  stub(mod_result_selection_server, "mod_result_selection_filter_result_sets", NULL)

  testServer(mod_result_selection_server, {
    # need to flush before and after
    session$private$flush()
    url_query(c("abc", "def%20hij", "klm"))
    session$private$flush()

    expect_called(m, 3)
    expect_args(m, 1, session, "dataset", selected = "abc")
    expect_args(m, 2, session, "scenario", selected = "def hij")
    expect_args(m, 3, session, "create_datetime", selected = "klm")
  })
})

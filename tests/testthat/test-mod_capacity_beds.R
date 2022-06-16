library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

specialties_expected <- tibble::tribble(
  ~type, ~code, ~main_specialty, ~treatment_function, ~description,
  "Surgical", "100", TRUE, TRUE, "General Surgery",
  "Medical", "300", TRUE, TRUE, "General Internal Medicine"
)
kh03_expected <- tibble::tribble(
  ~specialty_code, ~specialty_group, ~available, ~occupied,
  "100", "general_and_acute", 60, 55,
  "300", "general_and_acute", 140, 125
)
mainspef_agg_expected <- tibble::tribble(
  ~mainspef, ~baseline, ~principal, ~median, ~lwr_ci, ~upr_ci,
  "100", 1000, 2000, 2100, 1900, 2300,
  "100", 1000, 2000, 2100, 1900, 2300,
  "300", 2000, 4000, 4200, 3800, 4600,
  "300", 2000, 4000, 4200, 3800, 4600
)
beds_data_expected <- tibble::tribble(
  ~mainspef, ~baseline, ~principal, ~median, ~lwr_ci, ~upr_ci, ~specialty_group, ~available, ~occupied,
  "100", 2000, 4000, 4200, 3800, 4600, "general_and_acute", 60, 55,
  "300", 4000, 8000, 8400, 7600, 9200, "general_and_acute", 140, 125
)
# Begin Exclude Linting
new_available_beds_expected <- tibble::tribble(
  ~mainspef, ~baseline, ~principal, ~median, ~lwr_ci, ~upr_ci, ~specialty_group, ~available, ~occupied, ~new_available, ~type, ~main_specialty, ~treatment_function, ~description,
  "100", 2000, 4000, 4200, 3800, 4600, "General and Acute", 60, 55, 129.4, "Surgical", TRUE, TRUE, "General Surgery",
  "300", 4000, 8000, 8400, 7600, 9200, "General and Acute", 140, 125, 294.1, "Medical", TRUE, TRUE, "General Internal Medicine"
)
# End Exclude Linting

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_capacity_beds_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helper functions
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("load_specialties loads the specialties csv", {
  m <- mock("specialties")

  stub(mod_capacity_beds_load_specialties, "readr::read_csv", m)
  stub(mod_capacity_beds_load_specialties, "app_sys", identity)

  expect_equal(
    mod_capacity_beds_load_specialties(),
    "specialties"
  )
  expect_called(m, 1)
  expect_args(m, 1, "specialties.csv", col_types = "cc__c")
})

test_that("get_beds_data loads the data from cosmos", {
  files_mock <- mock(kh03_expected)
  file_path_mock <- mock()

  stub(mod_capacity_beds_get_beds_data, "readr::read_csv", files_mock)
  stub(mod_capacity_beds_get_beds_data, "app_sys", file_path_mock)
  stub(
    mod_capacity_beds_get_beds_data, "cosmos_get_mainspef_agg", mainspef_agg_expected
  )

  bd <- mod_capacity_beds_get_beds_data("ds", "id")

  expect_called(files_mock, 1)
  expect_args(file_path_mock, 1, "data", "kh03", "ds.csv")
  expect_equal(bd, beds_data_expected)
})

test_that("get_new_available_beds processes the data correctly", {
  actual <- mod_capacity_beds_get_new_available_beds(beds_data_expected, 0.85, specialties_expected)
  expect_equal(actual, new_available_beds_expected, tolerance = 0.1)

  # handle the case where baseline is 0
  bd1 <- beds_data_expected
  bd1[2, "baseline"] <- 0

  expected <- slice(new_available_beds_expected, 1)
  actual <- mod_capacity_beds_get_new_available_beds(bd1, 0.85, specialties_expected)
  expect_equal(actual, expected, tolerance = 0.1)

  # handle the case where principal is 0
  bd2 <- beds_data_expected
  bd2[1, "principal"] <- 0

  expected <- slice(new_available_beds_expected, 2)
  actual <- mod_capacity_beds_get_new_available_beds(bd2, 0.85, specialties_expected)
  expect_equal(actual, expected, tolerance = 0.1)
})

test_that("get_available_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically
  expect_snapshot(mod_capacity_beds_get_available_table(new_available_beds_expected))
})

test_that("get_available_plot returns a ggplot object", {
  p <- mod_capacity_beds_get_available_plot(new_available_beds_expected)
  expect_s3_class(p, "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it loads the specialties csv", {
  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "mod_capacity_beds_load_specialties", specialties_expected)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(selected_model_run), {
    expect_equal(specialties, specialties_expected)
  })
})

test_that("it calls get_beds_data correctly", {
  m <- mock("beds_data")

  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "mod_capacity_beds_load_specialties", specialties_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_beds_data", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(selected_model_run), {
    selected_model_run(c(ds = "ds", sc = "sc", mr = "mr", id = "ds__sc__mr"))

    expect_equal(beds_data(), "beds_data")

    expect_called(m, 1)
    expect_args(m, 1, "ds", "ds__sc__mr")
  })
})

test_that("it calls get_new_available_beds correctly", {
  m <- mock("new_beds")

  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "mod_capacity_beds_load_specialties", specialties_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_beds_data", beds_data_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_new_available_beds", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(selected_model_run), {
    selected_model_run(c(ds = "ds", sc = "sc", mr = "mr", id = "ds__sc__mr"))
    session$setInputs(occupancy_rate = 85)

    expect_equal(new_beds(), "new_beds")

    expect_called(m, 1)
    expect_args(m, 1, beds_data_expected, 0.85, specialties_expected)
  })
})

test_that("it renders the table", {
  m <- mock(
    mod_capacity_beds_get_available_table(new_available_beds_expected)
  )
  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "mod_capacity_beds_load_specialties", specialties_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_beds_data", beds_data_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_new_available_beds", new_available_beds_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_available_table", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(selected_model_run), {
    selected_model_run(c(ds = "ds", sc = "sc", mr = "mr", id = "ds__sc__mr"))
    session$setInputs(occupancy_rate = 85)

    expect_called(m, 1)
    expect_args(m, 1, new_available_beds_expected)
  })
})

test_that("it renders the plot", {
  m <- mock()
  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "mod_capacity_beds_load_specialties", specialties_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_beds_data", beds_data_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_new_available_beds", new_available_beds_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_available_plot", "plot")
  stub(mod_capacity_beds_server, "plotly::ggplotly", "plotly")
  stub(mod_capacity_beds_server, "plotly::layout", "plotly_layout")
  stub(mod_capacity_beds_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(selected_model_run), {
    selected_model_run(c(ds = "ds", sc = "sc", mr = "mr", id = "ds__sc__mr"))
    session$setInputs(occupancy_rate = 85)

    expect_called(m, 1)
    expect_args(m, 1, "plotly_layout")
  })
})

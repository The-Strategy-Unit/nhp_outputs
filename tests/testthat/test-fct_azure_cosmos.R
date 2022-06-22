library(shiny)
library(mockery)

test_that("cosmos_get_container creates a reference to a container", {
  withr::local_envvar(c("COSMOS_ENDPOINT" = "ep", "COSMOS_KEY" = "key", "COSMOS_DB" = "db"))

  m <- mock("endpoint", "database", "container")

  stub(cosmos_get_container, "AzureCosmosR::cosmos_endpoint", m)
  stub(cosmos_get_container, "AzureCosmosR::get_cosmos_database", m)
  stub(cosmos_get_container, "AzureCosmosR::get_cosmos_container", m)

  expect_equal(cosmos_get_container("my_container"), "container")
  expect_called(m, 3)
  expect_args(m, 1, "ep", "key")
  expect_args(m, 2, "endpoint", "db")
  expect_args(m, 3, "database", "my_container")
})

test_that("cosmos_get_result_sets gets the list of model runs", {
  m_cont <- mock("container")
  m <- mock(tibble::tribble(
    ~dataset, ~scenario, ~create_datetime, ~id,
    "a", "2", "1", "a__2__1",
    "b", "2", "2", "b__2__2",
    "a", "1", "2", "a__1__2"
  ))
  stub(cosmos_get_result_sets, "cosmos_get_container", m_cont)
  stub(cosmos_get_result_sets, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_result_sets(), tibble::tribble(
    ~dataset, ~scenario, ~create_datetime, ~id,
    "a", "1", "2", "a__1__2",
    "a", "2", "1", "a__2__1",
    "b", "2", "2", "b__2__2"
  ))

  qry <- "SELECT c.dataset, c.scenario, c.create_datetime, c.id FROM c"
  expect_called(m, 1)
  expect_args(m, 1, "container", qry)

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_available_aggregations gets the list of available aggregations", {
  m_cont <- mock("container")
  m <- mock(list(list(data = list(available_aggregations = c("a", "b")))))
  stub(cosmos_get_available_aggregations, "cosmos_get_container", m_cont)
  stub(cosmos_get_available_aggregations, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_available_aggregations("id"), c("a", "b"))
  qry <- "SELECT c.available_aggregations FROM c"
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id", as_data_frame = FALSE)

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_run_years gets the model run years", {
  m_cont <- mock("container")
  m <- mock(list(list(data = list(start_year = 1, end_year = 2))))
  stub(cosmos_get_model_run_years, "cosmos_get_container", m_cont)
  stub(cosmos_get_model_run_years, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_model_run_years("id"), list(start_year = 1, end_year = 2))
  qry <- "SELECT c.start_year, c.end_year FROM c"
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id", as_data_frame = FALSE, metadata = FALSE)

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_principal_high_level gets the results", {
  m_cont <- mock("container")
  m <- mock(tibble::tribble(
    ~pod, ~baseline, ~principal,
    "aae_1", 1, 2,
    "aae_2", 2, 4,
    "ip_1", 5, 6,
    "ip_2", 7, 8
  ))
  stub(cosmos_get_principal_high_level, "cosmos_get_container", m_cont)
  stub(cosmos_get_principal_high_level, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_principal_high_level("id"), tibble::tribble(
    ~pod, ~baseline, ~principal,
    "aae", 3, 6,
    "ip_1", 5, 6,
    "ip_2", 7, 8
  ))
  qry <- paste(
    "SELECT r.pod, r.baseline, r.principal",
    "FROM c JOIN r in c.results['default']",
    "WHERE r.measure NOT IN ('beddays', 'tele_attendances')"
  )
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_core_activity gets the results", {
  m_cont <- mock("container")
  m <- mock("data")
  stub(cosmos_get_model_core_activity, "cosmos_get_container", m_cont)
  stub(cosmos_get_model_core_activity, "AzureCosmosR::query_documents", m)

  qry <- "
    SELECT
      r.pod,
      r.measure,
      r.baseline,
      r.median,
      r.lwr_ci,
      r.upr_ci
    FROM c
    JOIN r IN c.results[\"default\"]
  "

  expect_equal(cosmos_get_model_core_activity("id"), "data")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_run_distribution gets the results", {
  m_cont <- mock("container")
  m <- mock(
    list(list(data = list(selected_variants = 4:7))),
    tibble::tribble(
      ~baseline, ~model_runs,
      100, c(100, 200, 300)
    )
  )
  stub(cosmos_get_model_run_distribution, "cosmos_get_container", m_cont)
  stub(cosmos_get_model_run_distribution, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_model_run_distribution("id", "pod", "measure"), tibble::tribble(
    ~baseline, ~model_run, ~value, ~variant,
    100, 1, 100, 5,
    100, 2, 200, 6,
    100, 3, 300, 7
  ))

  qry <- glue::glue("
    SELECT
        r.baseline,
        r.model_runs
    FROM c
    JOIN r IN c.results[\"default\"]
    WHERE
        r.pod = 'pod'
    AND
        r.measure = 'measure'
  ")
  expect_called(m, 2)
  expect_args(m, 1, "container",
    "SELECT c.selected_variants FROM c",
    partition_key = "id", as_data_frame = FALSE, metadata = FALSE
  )
  expect_args(m, 2, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_run_distribution validates the pod argument", {
  expect_error(
    cosmos_get_model_run_distribution("id", "invalid+pod", "measure"),
    "invalid characters in pod"
  )
})

test_that("cosmos_get_model_run_distribution validates the measure argument", {
  expect_error(
    cosmos_get_model_run_distribution("id", "pod", "invalid+measure"),
    "invalid characters in measure"
  )
})

test_that("cosmos_get_aggregation gets the results", {
  m_cont <- mock("container")
  m <- mock("data")
  stub(cosmos_get_aggregation, "cosmos_get_container", m_cont)
  stub(cosmos_get_aggregation, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_aggregation("id", "pod", "measure", "agg_col"), "data")
  qry <- glue::glue("
    SELECT
      r.sex,
      r.agg_col,
      r.baseline,
      r.principal,
      r.median,
      r.lwr_ci,
      r.upr_ci
    FROM c
    JOIN r in c.results[\"sex+agg_col\"]
    WHERE
      r.pod = 'pod'
    AND
      r.measure = 'measure'
  ")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_aggregation validates the pod argument", {
  expect_error(
    cosmos_get_aggregation("id", "invalid+pod", "measure", "agg_col"),
    "invalid characters in pod"
  )
})

test_that("cosmos_get_aggregation validates the measure argument", {
  expect_error(
    cosmos_get_aggregation("id", "pod", "invalid+measure", "agg_col"),
    "invalid characters in measure"
  )
})

test_that("cosmos_get_aggregation validates the agg_col argument", {
  expect_error(
    cosmos_get_aggregation("id", "pod", "measure", "invalid+agg_col"),
    "invalid characters in agg_col"
  )
})

test_that("cosmos_get_principal_change_factors gets the results", {
  m_cont <- mock("container")
  m <- mock(tibble::tibble(strategy = c("a", "b", NA)))
  stub(cosmos_get_principal_change_factors, "cosmos_get_container", m_cont)
  stub(cosmos_get_principal_change_factors, "AzureCosmosR::query_documents", m)

  expect_equal(
    cosmos_get_principal_change_factors("id", "aae"),
    tibble::tibble(strategy = c("a", "b", "-"))
  )
  qry <- glue::glue("
    SELECT
      r.measure,
      s.change_factor,
      s.strategy,
      s.baseline ?? s[\"value\"][0] \"value\"
    FROM c
    JOIN r IN c.aae
    JOIN s IN r.change_factors
  ")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "change_factors")
})

test_that("cosmos_get_principal_change_factors validates the arguments", {
  m <- mock(tibble::tibble(strategy = c("a", "b", NA)), cycle = TRUE)
  stub(cosmos_get_principal_change_factors, "cosmos_get_container", NULL)
  stub(cosmos_get_principal_change_factors, "AzureCosmosR::query_documents", m)

  cosmos_get_principal_change_factors("id", "aae")
  cosmos_get_principal_change_factors("id", "ip")
  cosmos_get_principal_change_factors("id", "op")

  expect_error(cosmos_get_principal_change_factors("id", "x"), "Invalid activity_type")
  expect_called(m, 3)
})

test_that("cosmos_get_bed_occupancy gets the results", {
  m_cont <- mock("container")
  m <- mock("data")
  stub(cosmos_get_bed_occupancy, "cosmos_get_container", m_cont)
  stub(cosmos_get_bed_occupancy, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_bed_occupancy("id"), "data")
  qry <- "
    SELECT
        r.measure,
        r.ward_group,
        r.baseline,
        r.principal,
        r.median,
        r.lwr_ci,
        r.upr_ci
    FROM c
    JOIN r IN c.results[\"bed_occupancy\"]
  "
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

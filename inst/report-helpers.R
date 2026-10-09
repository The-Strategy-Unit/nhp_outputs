# TODO: move to reskit
get_params <- function(r) {
  is_scalar_numeric <- \(x) rlang::is_scalar_atomic(x) && is.numeric(x)

  to_interval <- function(x) {
    if (
      length(x) == 2 && purrr::every(x, is_scalar_numeric) && is.null(names(x))
    ) {
      x |>
        purrr::flatten_dbl() |>
        purrr::set_names(c("lo", "hi"))
    } else {
      x
    }
  }

  recursive_discard <- function(x) {
    if (!is.list(x)) {
      return(x)
    }

    x |>
      purrr::map(recursive_discard) |>
      purrr::discard(\(.y) length(.y) == 0) |>
      to_interval()
  }
  recursive_discard(r$params)
}

# Model run information ----

#' Create a table of model run metadata
#' @param params List: Parameter selections for a given model scenario. As read
#'  in by [get_params]
#' @noRd
tabulate_model_run_info <- function(params) {
  params |>
    format_params() |>
    gt::gt("name") |>
    gt_theme() |>
    gt::tab_options(table.align = "left")
}


# Params ----

#' Convert a list of parameter data to a list of 'gt' objects
#' @inheritParams tabulate_model_run_info
#' @noRd
param_tables_to_list <- function(params) {
  # We can use some functions developed for the app but need to catch
  # shiny::need() errors as NULLs.

  possibly_table_baseline_adjustment <- purrr::possibly(
    info_params_table_baseline_adjustment
  )

  possibly_table_demographic_adjustment <- purrr::possibly(
    info_params_table_demographic_adjustment
  )

  possibly_table_waiting_list_adjustment <- purrr::possibly(
    info_params_table_waiting_list_adjustment
  )
  possibly_table_expat_repat_adjustment <- purrr::possibly(
    info_params_table_expat_repat_adjustment
  )

  possibly_table_non_demographic_adjustment <- purrr::possibly(
    info_params_table_non_demographic_adjustment
  )

  possibly_table_activity_avoidance <- purrr::possibly(
    info_params_table_activity_avoidance
  )
  possibly_table_efficiencies <- purrr::possibly(
    info_params_table_efficiencies
  )

  params_list <- list(
    "Baseline adjustment" = possibly_table_baseline_adjustment(params),
    "Demographic adjustment" = possibly_table_demographic_adjustment(params),
    "Waiting list adjustment" = list(
      "Table" = possibly_table_waiting_list_adjustment(params)
    ),
    "Expatriation" = list(
      "Table" = possibly_table_expat_repat_adjustment(params, "expat")
    ),
    "Repatriation (local)" = list(
      "Table" = possibly_table_expat_repat_adjustment(params, "repat_local")
    ),
    "Repatriation (non-local)" = list(
      "Table" = possibly_table_expat_repat_adjustment(params, "repat_nonlocal")
    ),
    "Non-demographic adjustment" = list(
      "Variant" = p[["non-demographic_adjustment"]][["variant"]],
      "Value type" = p[["non-demographic_adjustment"]][["value-type"]],
      "Table" = possibly_table_non_demographic_adjustment(params)
    ),
    "Activity avoidance" = possibly_table_activity_avoidance(params),
    "Efficiencies" = possibly_table_efficiencies(params)
  ) |>
    purrr::compact()

  invisible(params_list)
}

#' Expand a list of parameter tables to RMarkdown
#' @param param_tables_list A list. The outcome of passing a model parameter
#'  object `params` to [param_tables_to_list]. Each element is a parameter group
#'  ('baseline adjustment', etc) and contains a 'gt' table object describing
#'  the parameter selections, or a further list with elements for a 'gt' object
#'  and a character value.
#' @noRd
expand_param_tables_to_rmd <- function(param_tables_list) {
  l1_names <- names(param_tables_list) # 'l1' as in 'level 1' of the list

  for (l1 in l1_names) {
    cat("##", l1, "\n\n")
    l1_object <- param_tables_list[[l1]]
    l1_is_gt <- inherits(l1_object, "gt_tbl")
    l1_is_list <- is.list(l1_object)

    if (l1_is_gt) {
      render_params_gt(l1_object)
    }

    if (!l1_is_gt && l1_is_list) {
      l2_names <- names(l1_object)

      for (l2 in l2_names) {
        l2_object <- l1_object[[l2]]
        l2_is_char <- is.character(l2_object)
        l2_is_gt <- inherits(l2_object, "gt_tbl")
        l2_is_empty <- is.null(l2_object)

        if (l2_is_empty) {
          cat("No parameters were selected.\n\n")
        }

        if (l2_is_char) {
          cat(paste0(l2, ":"), l2_object, "\n\n")
        }

        if (l2_is_gt) {
          render_params_gt(l2_object)
        }
      }
    }
  }
}

#' Render a 'gt' table of parameter selections as raw HTML
#' @param param_table A data.frame. Contains parameter selections made in the
#'  inputs app. The data.frame is an element of `param_tables_list` provided
#'  to [expand_param_tables_to_rmd].
#' @noRd
render_params_gt <- function(param_table) {
  param_table |>
    gt::tab_options(table.align = "left") |>
    gt::as_raw_html() |>
    cat()
}

#' Expand a list of parameter selection reasons to RMarkdown
#' @param reasons_list A list. The 'reasons' element of a list `p` (i.e.
#'  the parameter selections for a given model scenario). Each element is a
#'  string describing the reason for a given parameter selection.
#' @noRd
expand_reasons_to_rmd <- function(reasons_list) {
  mitigators_json_path <- app_sys("app", "data", "mitigators.json")

  lookup <- c(
    yyjsonr::read_json_file(mitigators_json_path) |> unlist(),
    "baseline_adjustment" = "Baseline adjustment",
    "demographic_factors" = "Demographic factors",
    "waiting_list_adjustment" = "Waiting list adjustment",
    "expat_repat" = "Expatriation and repatriation",
    "non-demographic_adjustment" = "Non-demographic adjustment",
    "activity_avoidance" = "Activity avoidance",
    "efficiencies" = "Efficiencies",
    "inequalities" = "Inequalities",
    "ip" = "Inpatient",
    "op" = "Outpatient",
    "aae" = "Accident & Emergency"
  )

  reasons_list <- reasons_list |>
    remove_blanks_recursively() |>
    rename_recursively(lookup)

  l1_names <- names(reasons_list) # 'l1' as in 'level 1' of the list

  for (l1 in l1_names) {
    cat("##", l1, "\n\n")

    l1_object <- reasons_list[[l1]]
    l1_is_list <- is.list(l1_object)

    if (!l1_is_list) {
      cat(l1_object, "\n\n")
    }

    if (l1_is_list) {
      l2_names <- names(l1_object)

      for (l2 in l2_names) {
        cat("###", l2, "\n\n")

        l2_object <- l1_object[[l2]]
        l2_is_list <- is.list(l2_object)

        if (!l2_is_list) {
          cat(l2_object, "\n\n")
        }

        if (l2_is_list) {
          l3_names <- names(l2_object)

          for (l3 in l3_names) {
            cat("####", l3, "\n\n")

            l3_object <- l2_object[[l3]]
            l3_is_list <- is.list(l3_object)

            if (!l3_is_list) {
              cat(l3_object, "\n\n")
            }

            if (l3_is_list) warning("Unexpected depth in reasons list object.")
          }
        }
      }
    }
  }
}

#' Rename elements of a nested list regardless of depth
#' @param list_in List. The object for which you'd like to update element names
#'  according to `names_lookup`.
#' @param names_lookup Character. A vector of replacement element names, named
#'  for the element anme that they're replacing (e.g. `c("old" = "new")`).
#' @noRd
rename_recursively <- function(list_in, names_lookup) {
  name_exists <- names(list_in) %in% names(names_lookup)

  names(list_in)[name_exists] <- names_lookup[names(list_in)[name_exists]]

  purrr::map(
    list_in,
    \(x) if (is.list(x)) rename_recursively(x, names_lookup) else x
  )
}

#' Remove empty strings from a (possibly nested) list
#' @param list_in List. A list for which you'd like to remove any blank (`""`)
#'   elements.
#' @noRd
remove_blanks_recursively <- function(list_in) {
  if (!is.list(list_in)) {
    return(list_in)
  }

  list_in |>
    purrr::discard(\(x) isTRUE(x == "")) |>
    purrr::map(remove_blanks_recursively)
}

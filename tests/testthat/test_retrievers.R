library(statsDK)
library(testthat)

# retrieve_subjects ----
context("Testing retrieve_subjects")

subjects <- retrieve_subjects()

test_that("we have indeed received data for subjects", {
  expect_true(is.data.frame(subjects))
  expect_true(nrow(subjects) > 0)
  expect_true(ncol(subjects) > 0)
})

# retrieve_tables ----
context("Testing retrieve_tables")

tables <- retrieve_tables()

test_that("we have indeed received data for tables", {
  expect_true(is.data.frame(tables))
  expect_true(nrow(tables) > 0)
  expect_true(ncol(tables) > 0)
})


# retrieve_metadata ----
context("Testing retrieve_metadata")

folk_meta <- retrieve_metadata("FOLK1A")

test_that("we have indeed received meta data", {
  expect_true(is.list(folk_meta))
  expect_true(length(folk_meta) > 0)
  expect_true(folk_meta$id == "FOLK1A")
})

# retrieve_data ----
context("Testing retrieve_data")

folk <- suppressMessages(
  retrieve_data("FOLK1A")
  )

test_that("we have indeed received data", {
  expect_true(is.data.frame(folk))
  expect_true(nrow(folk) > 0)
  expect_true(ncol(folk) > 0)
})



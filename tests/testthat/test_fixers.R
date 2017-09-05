library(statsDK)
library(stringr)
library(testthat)

# fix_time ----
context("Testing fix_time")

bev_1 <- suppressMessages(
  retrieve_data("BEV3A", BEVÆGELSEV = "B02", Tid = "2017M06,2017M05")
)
bev_2 <- fix_time(bev_1)

folk_1 <- suppressMessages(
  retrieve_data("FOLK1A", "OMRÅDE" = "*")
)
folk_2 <- fix_time(folk_1)

test_that("the dates are as expected", {
  expect_true(all(stringr::str_detect(bev_1$time, "\\d{4}\\w\\d{2}")))
  expect_true(all(stringr::str_detect(bev_2$time, "\\d{4}-\\d{2}-\\d{2}")))
  expect_true(all(stringr::str_detect(folk_1$time, "\\d{4}\\w\\d{1}")))
  expect_true(all(stringr::str_detect(folk_2$time, "\\d{4}-\\d{2}-\\d{2}")))
})

# get_variables ----
context("Testing get_variables")

metadata <- retrieve_metadata("BEV3A")

# See the variables as a data frame
variables <- get_variables(metadata)

test_that("we have a nice tidy data frame", {
  expect_true(is.data.frame(variables))
  expect_true(nrow(variables) > 0)
  expect_true(ncol(variables) > 0)
})
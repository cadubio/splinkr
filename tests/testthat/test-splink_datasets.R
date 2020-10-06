testthat::context("splinkr functions")

test_that("splink_datasets works", {

  testthat::expect_equal(class(splinkr_datasets()), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_equal(class(splinkr_datasets(filter = c("univer", "brasil"))), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_warning(splinkr_datasets(), NA)
  testthat::expect_warning(splinkr_datasets(filter = c("univer")), NA)

})

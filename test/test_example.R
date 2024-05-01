source("test/example.R")

# Import the testthat package 
library(testthat) 


# Define the tests using test_that 
test_that(
  "Sum of numbers",
  {
    expect_equal(add(5, 4), 9) 
    expect_identical(add(2, 2), 4) 
  }
)

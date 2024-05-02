library(testthat)

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(caret))
suppressPackageStartupMessages(library(arulesCBA))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(lubridate))

# Load the function
source("src/Product/modules/model.R")

library(testthat)
library(purrr)


# Define a test dataset
test_data <- data.frame(
  Class = c("Fruit", "Vegetable", "Fruit", "Vegetable", "Fruit"),
  Item1 = c("Apple", "Carrot", "Banana", "Tomato", "Grapes"),
  Item2 = c("Orange", "Broccoli", "Apple", "Potato", "Pineapple"),
  stringsAsFactors = FALSE
)


# Define tests for the create_model function
test_that("Tests para modelo", {
  
  # Suppress warnings within this block
  suppressWarnings({
    # call the function
    model <- create_model(test_data, support_value = 0.1, confidence_value = 0.8)

    expect_equal(class(model), "list")
    expect_equal(length(model$rules), 10)
    expect_equal(nrow(model$transactions), 5)
    expect_equal(ncol(model$transactions), 12)
    
    # Fit the model with weights and the rules
    classifier <- CBA_ruleset(Class ~ .,
                              rules = model$rules,
                              default = uncoveredMajorityClass(Class ~ ., model$transactions, model$rules),
                              method = "majority")
    to_predict <- data.frame(
      Item1 = c("Apple"),
      Item2 = c("Orange"),
      stringsAsFactors = FALSE
    )
    
    
    # Convert data to transactions
    trans_predict <- as(to_predict, "transactions")
    
    # Make predictions
    prediction <- predict(classifier, trans_predict)
    
    expect_equal(prediction, factor("Fruit", levels = c("Fruit", "Vegetable")))
    
    rules <- extract_rules(classifier)
    expect_equal(rules, read.csv("test/test_rules.csv"))
    
  })
})


# Function to perform a grid search on a CBA classifier
# 
# Args:
#   support_values: Vector of values for the support of association rules
#   confidence_values: Vector of values for the confidence of association rules
#   train: Training dataset
#   test: Test dataset
#   y_test: Vector of class labels for the test dataset
# 
# Returns:
#   Vector of 3 elements containing the best support, confidence, and accuracy found during the grid search.
#   The first element is the best support value, the second element is the best confidence value, and the third element is the accuracy associated with these values.
# 
grid_search <- function(support_values, confidence_values, train, test, y_test) {
  ## Initialize variables to store the best parameters and accuracy
  best_support <- NULL
  best_confidence <- NULL
  best_accuracy <- 0

  ## Grid search loop
  for (support in support_values) {
    for (confidence in confidence_values) {
      ## Train the classifier
      classifier <- CBA(duration ~ ., data = train, supp = support, conf = confidence)

      ## Make predictions on validation set
      predictions <- predict(classifier, test)

      accuracy <- sum(predictions == y_test) / length(predictions)
      
      ## Update best parameters if current accuracy is higher
      if (accuracy > best_accuracy) {
        best_support <- support
        best_confidence <- confidence
        best_accuracy <- accuracy
      }
    }
  }
  
  ## Return vector of best parameters and accuracy
  c(best_support, best_confidence, best_accuracy)
}
# # Example values for the grid search
# support_values <- seq(0.01, 0.1, by = 0.01)
# confidence_values <- seq(0.01, 0.1, by = 0.01)

# Function to extract and preprocess rules from a classifier object and test dataset
# 
# Args:
#   classifier: The classifier object containing association rules
#   test: The test dataset used for extracting column values
# 
# Returns:
#   A dataframe containing preprocessed association rules
# 
extract_rules <- function(classifier, test) {
  # Convert classifier rules to a dataframe
  rules <- DATAFRAME(classifier$rules)
  
  # Create new columns in rules dataframe with NA values
  for (colname in colnames(test)) {
    rules[[colname]] <- NA
  }
  
  # Extract values for each column from the LHS of rules
  for (colname in colnames(test)) {
    rules[[colname]] <- ifelse(grepl(colname, rules$LHS), gsub(paste(".*",colname,"=([^,}]*).*",sep = ""), "\\1", rules$LHS), rules[[colname]])
  }
  
  # Extract the target variable values from the RHS of rules
  rules$Class <- ifelse(grepl("Class", rules$RHS), gsub(".*Class=([^,}]*).*", "\\1", rules$RHS), rules$Class)
  
  # Remove LHS and RHS columns
  rules$LHS <- NULL
  rules$RHS <- NULL
  
    rules
}
  # Function to filter rules based on a given statement
  # 
  # Args:
  #   rules: Dataframe containing association rules
  #   statement: Statement to filter rules by
  # 
  # Returns:
  #   Subset of rules dataframe that satisfies the given statement
  # 
get_used_rules <- function(rules, statement) {
  # Create conditions for filtering rules based on the statement
  conditions <- lapply(colnames(statement), function(colname) {
    rules[[colname]] == statement[[colname]] | is.na(rules[[colname]])
  })
  
  # Combine conditions using logical AND
  conditions_combined <- Reduce(`&`, conditions)
  
  # Filter rules dataframe based on combined conditions
  rules %>% filter(!!conditions_combined)
}

# Function to compute confusion matrix
# 
# Args:
#   predictions: Predicted class labels
#   actual_labels: Actual class labels
# 
# Returns:
#   Confusion matrix
# 
confusion_matrix <- function(predictions, actual_labels) {
  # Create confusion matrix
  confusion_matrix <- table(predictions, actual_labels)
    # Print confusion matrix
  print("Confusion Matrix:")
  print(confusion_matrix)
  return(confusion_matrix)
}

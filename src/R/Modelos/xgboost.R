# Function to evaluate the model and generate a confusion matrix
# 
# Args:
#   predictions: Predicted values from the model
#   y_test: Actual class labels from the test dataset
# 
# Returns:
#   Confusion matrix
# 
confusion_matrix <- function(predictions, y_test) {
  # Generate confusion matrix
  confusion_matrix <- table(predictions, y_test)
  
  # Print confusion matrix
  print("Confusion Matrix:")
  print(confusion_matrix)
  
  return(confusion_matrix)
}
# Function to perform grid search for XGBoost model with different objective functions
# 
# Args:
#   X_train: Training data features
#   y_train: Training data labels
#   X_test: Test data features
#   y_test: Test data labels
#   objective_functions: Vector of objective functions for XGBoost
#   nrounds_values: Vector of values for the number of boosting rounds
#   weight: Optional vector of weights for training instances
# 
# Returns:
#   List containing the best parameters found during grid search for each objective function and their associated accuracies
# 
grid_search <- function(X_train, y_train, X_test, y_test, objective_functions, nrounds_values, w_train = NULL, w_test = NULL) {
  # Initialize variables to store the best parameters and accuracy for each objective function
  best_params <- list()
  
  # Grid search loop for each objective function
  for (objective in objective_functions) {
    # Initialize variables to store the best parameters and accuracy for the current objective function
    best_nrounds <- NULL
    best_accuracy <- 0
    
    # Grid search loop for number of boosting rounds
    for (nrounds in nrounds_values) {

      # FIXME Check failed: info.labels.Size() == preds.Size() (700 vs. 1400) : Invalid shape of labels.
      print(nrow(X_train))
      print(length(y_train))
      print(nrow(X_test))
      print(length(y_test))

      # Train the XGBoost model
      xgb_model <- xgboost(data = X_train, label = y_train, nrounds = nrounds, objective = objective, num_class = 2, weight = w_train)
      # Make predictions on test set
      predictions <- predict(xgb_model, newdata = X_test, weights = w_test)      
      # Calculate accuracy
      accuracy <- sum(predictions == y_test) / length(y_test)  # Use length(y_test) instead of length(predictions)
      
      # Update best parameters if current accuracy is higher
      if (accuracy > best_accuracy) {
        best_nrounds <- nrounds
        best_accuracy <- accuracy
      }
    }
    
    # Store the best parameters and accuracy for the current objective function
    best_params[[objective]] <- list(best_nrounds = best_nrounds, best_accuracy = best_accuracy)
  }
  
  # Return list of best parameters and accuracies for each objective function
  return(best_params)
}

# # Definir las opciones de la búsqueda de cuadrícula
# objective_functions <- c("binary:logistic", "binary:hinge")  # Ejemplo de diferentes funciones objetivas
# nrounds_values <- c(10, 20, 30)  # Ejemplo de diferentes números de rondas de refuerzo

# # Realizar la búsqueda de cuadrícula
# best_params <- xgboost_grid_search(X_train, y_train, X_test, y_test, objective_functions, nrounds_values)

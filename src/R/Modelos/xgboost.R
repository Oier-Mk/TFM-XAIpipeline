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
grid_search <- function(X_train, y_train, X_test, y_test, objective_functions, nrounds_values, train_weights = NULL, test_weights = NULL) {
  # Inicializar variables para almacenar los mejores parámetros y precisión
  best_params <- list()
  
  # Búsqueda en cuadrícula para cada valor de soporte
  for (objective in objective_functions) {
    # Búsqueda en cuadrícula para cada valor de confianza
    for (nrounds in nrounds_values) {

      # xgb_model <- xgboost(data = X_train, label = y_train, nrounds = nrounds, objective = objective, num_class = 2, weight = w_train)
      # predictions <- predict(xgb_model, newdata = X_test, weights = w_test)
      xgb_model <- xgboost(data = X_train, label = y_train, nrounds = nrounds, objective = objective, num_class = 2, weight = train_weights)
      
      # predictions <- predict(xgb_model, newdata = X_test, weights = test_weights)

      accuracy <- sum(predictions == y_test) / length(predictions)
      
      # Almacenar los mejores parámetros y precisión
      if (is.null(best_params$accuracy) || accuracy > best_params$accuracy) {
        best_params$objective_functions <- objective
        best_params$nrounds_values <- nrounds
        best_params$accuracy <- accuracy
      }
    }
  }
  
  # Devolver los mejores parámetros y precisión encontrados
  return(best_params)
}

# # Definir las opciones de la búsqueda de cuadrícula
# objective_functions <- c("binary:logistic", "binary:hinge")  # Ejemplo de diferentes funciones objetivas
# nrounds_values <- c(10, 20, 30)  # Ejemplo de diferentes números de rondas de refuerzo

# # Realizar la búsqueda de cuadrícula
# best_params <- xgboost_grid_search(X_train, y_train, X_test, y_test, objective_functions, nrounds_values)

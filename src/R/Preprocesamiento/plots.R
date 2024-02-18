library(ggplot2)
library(cowplot)
library(gridExtra)
library(grid)

plot_histogram <- function(data, f = TRUE, v = FALSE) {
  
  column_names <- colnames(data)
  
  limites_x <- range(apply(data, 2, function(x) range(x, na.rm = TRUE)))
  
  limites_y <- c(0, max(apply(data, 2, function(x) max(table(x), na.rm = TRUE))))
  
  plots <- list()
  
  for (col in column_names) {
    plot <- ggplot(data, aes_string(x = col)) +
      geom_histogram(fill = "blue", alpha = I(0.2), color = "black") +  # Puedes ajustar el ancho del bin según tus necesidades
      xlab(col) +
      ylab("Frequency") +
      ggtitle(paste("HG for", col)) +
      theme(plot.title = element_text(hjust = 0.5)) 
    
    if(v) {
      plot <- plot + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    }
    if(f) {
      plot <- plot + coord_cartesian(xlim = limites_x, ylim = limites_y)
    }
    
    plots[[col]] <- plot
  }
  plot_grid(plotlist = plots, ncol = 3, align = "hv", labels = "AUTO")
}
plot_density <- function(data, f = TRUE, v = FALSE) {
  
  column_names <- colnames(data)
  # Encuentra los límites para el eje X (máximo y mínimo a través de todas las columnas)
  limites_x <- range(apply(data, 2, function(x) range(x, na.rm = TRUE)))
  
  # Encuentra los límites para el eje Y (máximo de la densidad a través de todas las columnas)
  limites_y <- range(apply(data, 2, function(x) density(x, na.rm = TRUE)$y))
  
  plots <- list()
  
  for (col in column_names) {
    plot <- ggplot(data, aes_string(x = col)) +
      geom_density(stat = "density", alpha = I(0.2), fill = "red") +
      xlab(col) +
      ylab("Density") +
      ggtitle(paste("DC for", col)) +
      theme(plot.title = element_text(hjust = 0.5)) 
    
    
    if(v) {
      plot <- plot + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    }
    if(f) {
      plot <- plot + coord_cartesian(xlim = limites_x, ylim = limites_y)
    }
    
    
    plots[[col]] <- plot
  }
  plot_grid(plotlist = plots, ncol = 3, align = "hv", labels = "AUTO")
}
plot_bar <- function(data, v = FALSE) {
  
  # Identify categorical columns
  categorical_cols <- sapply(data, function(x) is.factor(x) | is.character(x))
  categorical_cols <- names(categorical_cols[categorical_cols])
  
  plots <- list()
  
  for (col in categorical_cols) {
    plot <- ggplot(data, aes_string(x = col)) +
      geom_bar(fill = "blue", alpha = 0.7) +
      xlab(col) +
      ylab("Count") +
      ggtitle(paste("Bar Plot for", col)) +
      theme(plot.title = element_text(hjust = 0.5))
    
    if (v) {
      plot <- plot + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    }
    
    plots[[col]] <- plot
  }
  
  plot_grid(plotlist = plots, ncol = 3, align = "hv", labels = "AUTO")
}

plot_scatter <- function(data, f = TRUE) {
  
  column_names <- colnames(data)
  
  # Encuentra los límites para el eje X (máximo y mínimo a través de todas las columnas)
  limites_x <- range(apply(data, 2, function(x) range(x, na.rm = TRUE)))
  
  # Encuentra los límites para el eje Y (máximo de la densidad a través de todas las columnas)
  limites_y <- range(apply(data, 2, function(x) density(x, na.rm = TRUE)$y))
  
  plots <- list()
  
  for (col in column_names) {
    plot <- ggplot(data, aes_string(x = col)) +
      geom_point(stat = "density", alpha = I(0.2), fill = "red") +
      xlab(col) +
      ylab("Density") +
      ggtitle(paste("DC for", col)) +
      theme(plot.title = element_text(hjust = 0.5)) 
    
    if(f) {
      plot <- plot + coord_cartesian(xlim = limites_x, ylim = limites_y)
    }
    
    
    plots[[col]] <- plot
  }
  plot_grid(plotlist = plots, ncol = 3, align = "hv", labels = "AUTO")
}
scatter_plots_col <- function(data, target_column) {
  column_names <- setdiff(colnames(data), target_column)
  plots <- list()
  
  for (col in column_names) {
    # Crear gráfico de dispersión y agregar título
    plot <- ggplot(data, aes_string(x = col, y = target_column)) +
      geom_point(color = "#FF5733") +
      geom_smooth(method="gam") + 
      labs(title = paste("Stt for", col, "vs", target_column)) +
      theme_minimal()
    
    plots[[col]] <- plot
  }
  
  # Organizar gráficos en una cuadrícula
  grid.arrange(grobs = plots, ncol = 3, align = "hv", labels = "AUTO")
}
scatter_plots_elected_col <- function(data, cols, target_column) {
  column_names <- cols
  plots <- list()
  
  for (col in column_names) {
    # Crear gráfico de dispersión y agregar título
    plot <- ggplot(data, aes_string(x = col, y = target_column)) +
      geom_point(color = "#FF5733") +
      geom_smooth(method="gam") + 
      labs(title = paste("Stt for", col, "vs", target_column)) +
      theme_minimal()
    
    plots[[col]] <- plot
  }
  
  # Organizar gráficos en una cuadrícula
  grid.arrange(grobs = plots, ncol = 3, align = "hv", labels = "AUTO")
}
scatter_plots_cols <- function(data, columns, target_column) {
  combinations <- combn(columns, 2, simplify = TRUE)
  plots <- list()
  
  for (i in 1:ncol(combinations)) {
    col1 <- combinations[1, i]
    col2 <- combinations[2, i]
    
    # Crear gráfico de dispersión y agregar título
    plot <- ggplot(data, aes_string(x = col1, y = col2, color = target_column)) +
      geom_point() +
      labs(title = paste("Stt", col1, "vs", col2)) +
      theme_minimal()
    
    plots[[i]] <- plot
  }
  
  # Organizar gráficos en una cuadrícula
  grid.arrange(grobs = plots, ncol = 3, align = "hv", labels = "AUTO")
}
plot_qq <- function(data, f = TRUE) {
  
  column_names <- colnames(data)
  # Encuentra los límites para el eje X (máximo y mínimo a través de todas las columnas)
  limites_x <- range(apply(data, 2, function(x) range(x, na.rm = TRUE)))
  
  # Encuentra los límites para el eje Y (máximo de la densidad a través de todas las columnas)
  limites_y <- range(apply(data, 2, function(x) density(x, na.rm = TRUE)$y))
  
  plots <- list()
  
  for (col in column_names) {
    plot <- ggplot(data = data, aes_string(sample = col)) +
      geom_qq() +
      geom_qq_line(color = "red") +
      labs(title = paste("QQ for ", col) , x = "Theoretical Quantiles", y = "Sample Quantiles") +
      theme_minimal()
    if(f) {
      plot <- plot + coord_cartesian(xlim = limites_x, ylim = limites_y)
    }
    plots[[col]] <- plot
  }
  plot_grid(plotlist = plots, ncol = 3, align = "hv", labels = "AUTO")
}
plot_boxplot_vars <- function(data, x_val, y_val) {
  plot <- ggplot(data, aes_string(x = paste0("factor(", x_val, ")"), y = y_val, fill = paste0("factor(sum(", y_val, "))"))) +
    geom_boxplot(position = "dodge") +
    xlab(x_val) +
    ylab(y_val) +
    ggtitle(paste("Grouped Boxplot of ", x_val, " vs. ", y_val)) 
  plot
}
plot_boxplot <- function(data, f = TRUE) {
  
  column_names <- colnames(data)
  plots <- list()

  # Encuentra los límites para el eje X (máximo y mínimo a través de todas las columnas)
  limites_x <- range(apply(data, 2, function(x) range(x, na.rm = TRUE)))
  
  # Encuentra los límites para el eje Y (máximo de la densidad a través de todas las columnas)
  limites_y <- range(apply(data, 2, function(x) density(x, na.rm = TRUE)$y))
  
  
  for (col in column_names) {
    # Calcular estadísticas
    media <- mean(data[[col]], na.rm = TRUE)
    desviacion_tipica <- sd(data[[col]], na.rm = TRUE)
    cuartiles <- quantile(data[[col]], probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
    outliers <- sum(data[[col]] > cuartiles[3] + 1.5 * IQR(data[[col]], na.rm = TRUE) | data[[col]] < cuartiles[1] - 1.5 * IQR(data[[col]], na.rm = TRUE), na.rm = TRUE)
    
    # Crear gráfico de caja y agregar estadísticas al título
    plot <- ggplot(data, aes_string(y = col)) +
      geom_boxplot(fill = "skyblue", color = "#001f9b", orientation = "horizontal") +
      labs(title = paste("BP ", col),
           subtitle = paste("Media: ", round(media, 2),
                            "\nDesviacion: ", round(desviacion_tipica, 2),
                            "\nQ1 =", round(cuartiles[1], 2),
                            "\nQ2 =", round(cuartiles[2], 2),
                            "\nQ3 =", round(cuartiles[3], 2),
                            "\nN de Outliers: ", outliers)) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) # +
      # coord_flip()

        # Limitar ejes fuera del bucle si f es TRUE
      if (f) {
      #    plot <- plot + coord_cartesian(xlim = limites_x, ylim = limites_y)
          plot <- plot + coord_cartesian(ylim = c(0.4, 1.75)) 

      }
      plots[[col]] <- plot

  }
    
  

    # Organizar gráficos en una cuadrícula
  grid.arrange(grobs = plots, ncol = 3, align = "hv", labels = "AUTO")
  
}

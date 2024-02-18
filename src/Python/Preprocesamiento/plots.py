import pandas as pd

import seaborn as sns
import matplotlib.pyplot as plt

from matplotlib.colors import ListedColormap
import matplotlib.pyplot as plt


def plot_histogram(data):
    """
    Generate histograms for each column in the DataFrame.

    Parameters:
    - data: pandas DataFrame

    Returns:
    - None (displays histograms)
    """
    # Set the style for the plots
    sns.set(style="whitegrid")

    # Determine the number of subplots based on the number of columns
    num_cols = data.shape[1]
    num_rows = (num_cols + 2) // 3  # Ensure an even number of rows for better layout

    # Create subplots
    fig, axes = plt.subplots(nrows=num_rows, ncols=3, figsize=(15, 3 * num_rows))
    # fig.tight_layout(pad=8.0)

    # Flatten the axes array for easier iteration
    axes = axes.flatten()

    # Add a big split between the lines to allow the reading of the attributes
    plt.subplots_adjust(hspace=2)

    # Loop through each column and create a histogram
    for i, col in enumerate(data.columns):
        ax = axes[i]
        sns.histplot(data[col], ax=ax, kde=True, color='skyblue', bins=30)
        ax.set_title(f'Histogram for {col}')
        ax.set_xlabel(col)
        # rotate the x-axis labels for better visibility
        ax.tick_params(axis='x', rotation=45)
        ax.set_ylabel('Frequency')

    # If the number of columns is not a multiple of 3, remove the last empty subplots
    if num_cols % 3 != 0:
        for j in range(num_cols % 3, 3):
            fig.delaxes(axes[-j])

    # Show the plots
    plt.show()

def plot_boxplot(data):
    """
    Generate boxplots for each column in the DataFrame.

    Parameters:
    - data: pandas DataFrame

    Returns:
    - None (displays boxplots)
    """
    # Set the style for the plots
    sns.set_theme(style="whitegrid")

    # Determine the number of subplots based on the number of columns
    num_cols = data.shape[1]
    num_rows = (num_cols + 2) // 3  # Ensure an even number of rows for better layout

    # Create subplots
    fig, axes = plt.subplots(nrows=num_rows, ncols=3, figsize=(15, 3 * num_rows))
    fig.tight_layout(pad=3.0)

    # Flatten the axes array for easier iteration
    axes = axes.flatten()

    # Loop through each column and create a boxplot
    for i, col in enumerate(data.columns):
        ax = axes[i]
        sns.boxplot(x=data[col], ax=ax, color='skyblue')
        ax.set_title(f'Boxplot for {col}')
        ax.set_xlabel(col)

    # If the number of columns is not a multiple of 3, remove the last empty subplots
    if num_cols % 3 != 0:
        for j in range(num_cols % 3, 3):
            fig.delaxes(axes[-j])

    # Show the plots
    plt.show()

def categorical_plot(col: pd.Series, title: str, x_label: str, y_label: str):
    """
    Function to create a categorical plot for a given column.

    Parameters:
    col (pd.Series): A pandas Series representing the column to plot.
    title (str): Title of the plot.
    x_label (str): Label for the x-axis.
    y_label (str): Label for the y-axis.

    Returns:
    None
    """
    # Count the classes
    class_counts = col.value_counts()
    
    # Calculate percentages
    total = class_counts.sum()
    percentages = (class_counts / total) * 100
    
    # Create bar plot
    bars = plt.bar(class_counts.index, class_counts.values)
    
    # Add percentage and count labels on each bar
    for bar, percentage, count in zip(bars, percentages, class_counts):
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width() / 2.0, height, f'{percentage:.1f}%', ha='center', va='bottom')
        plt.text(bar.get_x() + bar.get_width() / 2.0, height / 2, count, ha='center', va='center')
    
    # Set labels and title
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.title(title)
    plt.show()


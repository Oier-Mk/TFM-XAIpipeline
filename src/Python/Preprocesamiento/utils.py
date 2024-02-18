import pandas as pd
import numpy as np

def read_german_dataset():
    '''
    This function reads the german dataset from the UCI Machine Learning Repository and saves it as a csv file.
    '''
    # Load the dataset
    url = 'https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.data'
    # Load the dataset
    df = pd.read_csv(url, sep=' ', header=None)
    # Add column names
    df.columns = [
        'Status of existing checking account', 
        'Duration in month', 
        'Credit history', 
        'Purpose', 
        'Credit amount', 
        'Savings account/bonds', 
        'Present employment since', 
        'Installment rate in percentage of disposable income', 
        'Personal status and sex', 
        'Other debtors / guarantors', 
        'Present residence since', 
        'Property', 
        'Age in years', 
        'Other installment plans', 
        'Housing', 
        'Number of existing credits at this bank', 
        'Job', 
        'Number of people being liable to provide maintenance for', 
        'Telephone', 
        'Foreign worker', 
        'Class'
    ]
    # Save the dataset
    df.to_csv('data/Statlog.csv', index=False)
                  
def load_data(file_path: str) -> pd.DataFrame:
    '''
    This function reads a csv file and returns a pandas DataFrame.
    '''
    # Load the dataset
    df = pd.read_csv(file_path)
    return df

def get_missing_values(data: pd.DataFrame) -> pd.DataFrame:
    '''
    This function returns the columns with missing values and the number of missing values for each column.
    '''
    # Get the number of missing values for each column
    na_counts = data.isnull().sum()
    # Get the columns with missing values
    na_columns = na_counts[na_counts > 0]
    if not np.any(na_columns):
        print('No missing values found')
    else:
        [print(i) for i in na_columns]


def replace_categorical_values(df):
    '''
    This function replaces the categorical values in the dataset with the corresponding attribute mapping.
    '''
    # Define mapping for each attribute
    categories = {
        'A11': '< 0 DM',
        'A12': '0 - 200 DM',
        'A13': '>= 200 DM',
        'A14': 'no checking account',
        'A30': 'no credits/all paid',
        'A31': 'all credits paid',
        'A32': 'existing credits paid',
        'A33': 'delay in paying',
        'A34': 'critical account',
        'A40': 'car (new)',
        'A41': 'car (used)',
        'A42': 'furniture/equipment',
        'A43': 'radio/television',
        'A44': 'domestic appliances',
        'A45': 'repairs',
        'A46': 'education',
        'A47': 'vacation',
        'A48': 'retraining',
        'A49': 'business',
        'A410': 'others',
        'A61': '< 100 DM',
        'A62': '100 - 500 DM',
        'A63': '500 - 1000 DM',
        'A64': '>= 1000 DM',
        'A65': 'unknown/no savings',
        'A71': 'unemployed',
        'A72': '< 1 year',
        'A73': '1 - 4 years',
        'A74': '4 - 7 years',
        'A75': '>= 7 years',
        'A91': 'male: divorced/separated',
        'A92': 'female: divorced/separated/married',
        'A93': 'male: single',
        'A94': 'male: married/widowed',
        'A95': 'female: single',
        'A101': 'none',
        'A102': 'co-applicant',
        'A103': 'guarantor',
        'A121': 'real estate',
        'A122': 'building society savings',
        'A123': 'car or other',
        'A124': 'unknown/no property',
        'A141': 'bank',
        'A142': 'stores',
        'A143': 'none',
        'A151': 'rent',
        'A152': 'own',
        'A153': 'for free',
        'A171': 'unemployed/non-resident',
        'A172': 'unskilled resident',
        'A173': 'skilled employee',
        'A174': 'management/self-employed',
        'A191': 'none',
        'A192': 'yes, registered',
        'A201': 'yes',
        'A202': 'no'
    }


    # Iterate through each column and replace categorical values
    for column in df.columns:
        if df[column].dtype == 'object':
            df[column] = df[column].map(categories)

    return df

def split_personal_status_and_sex(data):
    """
    Split the 'Personal status and sex' column into 'Gender' and 'Marital Status'.

    Args:
    - data (pd.Series): The series containing the 'Personal status and sex' column.

    Returns:
    - pd.DataFrame: DataFrame with 'Gender' and 'Marital Status' columns.
    """
    # Mapping of categories to separate gender and marital status
    category_mapping = {
        'male: divorced/separated': ('male', 'divorced/separated'),
        'female: divorced/separated/married': ('female', 'divorced/separated/married'),
        'male: single': ('male', 'single'),
        'male: married/widowed': ('male', 'married/widowed'),
        'female: single': ('female', 'single')
    }

    # Splitting the column based on the mapping
    split_data = data['Personal status and sex'].map(category_mapping)

    # Creating new DataFrame with separated columns
    new_data = pd.DataFrame(split_data.tolist(), columns=['Gender', 'Marital Status'])

    # delete from new_data 'Personal status and sex'
    data.drop('Personal status and sex', axis=1, inplace=True)

    # Concatenating the new DataFrame with the original DataFrame
    new_data = pd.concat([data, new_data], axis=1)

    # the column 'Class' is the last column in the dataset, so we move it to the first position
    class_col = new_data.pop('Class')
    new_data.insert(0, 'Class', class_col)

    return new_data

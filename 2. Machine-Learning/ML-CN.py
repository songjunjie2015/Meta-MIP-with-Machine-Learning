import pandas as pd
import numpy as np
from sklearn.neural_network import MLPRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score
import matplotlib.pyplot as plt

# 数据预处理
def load_data(train_path, pre_path):

    train_data = pd.read_csv(train_path, header=None)
    X_train = train_data.iloc[:, :2].values
    y_train = train_data.iloc[:, 3:4].values


    pred_data = pd.read_csv(pre_path, header=None)
    X_pred = pred_data.iloc[:, :2].values
    Y_pred = pred_data.iloc[:, 3:4].values


    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_pred_scaled = scaler.transform(X_pred)

    return X_train_scaled, y_train, X_pred_scaled, Y_pred

# 模型构建与训练
def train_model(X, y):

    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=0.1, random_state=2)
    

    model = MLPRegressor(
        hidden_layer_sizes=(128,128,128,128),  
        activation='relu',             
        solver='adam',                 
        random_state=1,
        max_iter=20000,
        early_stopping=True,
        learning_rate_init= 0.005
    )
    

    model.fit(X_train, np.ravel(y_train))
    

    y_pred = model.predict(X_val)
    mse = mean_squared_error(y_val, y_pred)
    r2 = r2_score(y_val, y_pred)
    print(f"验证集评估:\nMSE: {mse:.4f}\nR²: {r2:.4f}")
    
    return model

def save_predictions_to_csv(output_path, predictions):
    try:

        existing_data = pd.read_csv(output_path, header=None)

        updated_data = pd.concat([existing_data, pd.DataFrame(predictions)], axis=1)
    except FileNotFoundError:
  
        updated_data = pd.DataFrame(predictions)
    

    updated_data.to_csv(output_path, index=False, header=False)
    print(f"\n预测结果已追加至: {output_path}")

if __name__ == "__main__":

    train_csv = 'train_data.csv'
    pre_csv = 'valid.csv'
    output_path = 'valid-2.csv'
    

    X_train, y_train, X_pre, Y_pre = load_data(train_csv, pre_csv)
    

    all_predictions = pd.DataFrame()


    for random_state in range(1, 6):
        print(f"\n正在训练模型，random_state={random_state}...")
        

        X_train_split, X_val_split, y_train_split, y_val_split = train_test_split(
            X_train, y_train, test_size=0.1, random_state=2
        )
        

        model = MLPRegressor(
            hidden_layer_sizes=(16,16,16),  
            activation='tanh',                       
            solver='adam',                          
            random_state=random_state,            
            max_iter=20000,
            learning_rate_init=0.005,
            early_stopping=True,
            batch_size=16,
            n_iter_no_change=150,
        )
        

        model.fit(X_train_split, np.ravel(y_train_split))
        

        y_val_pred = model.predict(X_val_split)
        mse = mean_squared_error(y_val_split, y_val_pred)
        r2 = r2_score(y_val_split, y_val_pred)
        print(f"验证集评估 (random_state={random_state}):\nMSE: {mse:.4f}\nR²: {r2:.4f}")
        

        predictions = model.predict(X_pre)
        

        all_predictions[f'RandomState_{random_state}'] = predictions.flatten()
        

    all_predictions.to_csv(output_path, index=False)
    print(f"\n所有预测结果已保存至: {output_path}")
% Evaluation script for the collaborative filtering problem. Loads data
% matrix, splits known values into training and testing sets, and computes
% the MSE of the predicted to the true known entries of the test data.
%
% Loads data from Data.mat and calls PredictMissingValues.m.

% Setup
rand('seed', 1);  % fix random seed for reproducibility
kfold_k = 3;

% Constants
filename = 'Data.mat';
prc_trn = 0.5;  % percentage of training data
nil = 99;  % missing value indicator

% Load data
L = load(filename);
X = L.X;

% Split intro training and testing index sets
idx = find(X ~= nil); 
n = numel(idx);

indices = crossvalind('Kfold', n, kfold_k);

for i=1:kfold_k
    % Keep i-th set away for testing
    idx_tst = idx(indices==i);
    % Use the rest for training
    idx_trn = idx(indices~=i);
    
    % Build training and testing matrices
    X_trn = ones(size(X))*nil;
    X_trn(idx_trn) = X(idx_trn);  % add known training values

    X_tst = ones(size(X))*nil;
    X_tst(idx_tst) = X(idx_tst);  % add known training values

    % Predict the missing values here!
    X_pred = PredictMissingValues(X_trn, nil);

    % Compute MSE
    mse = sqrt(mean((X_tst(X_tst ~= nil) - X_pred(X_tst ~= nil)).^2));  % error on known test values

    disp(['Root of Mean-squared error: ' num2str(mse)]);
end

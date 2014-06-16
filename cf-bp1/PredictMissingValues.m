function X_pred = PredictMissingValues(X, nil, s)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

%% Parameters
SVD_K = s.SVD_K;

%% 0. Preprocessing
% a. Calculate the mean of all observed ratings
X_pred = X;
X_mean_imputed = X;
mu = mean(mean(X_pred(X_pred ~= nil)));

%% 1. Imputation
% Impute the missing values by replacing them with average values

% Replace missing ratings with average ratings by that user
X_pred_avg = zeros(size(X_mean_imputed, 1), 1);
for i=1:size(X_mean_imputed, 1)
    xi = X_pred(i, :);
    X_pred_avg(i) = mean(xi(xi ~= nil));
    xi(xi == nil) = X_pred_avg(i);
    X_mean_imputed(i, :) = xi;
end

%% 2. Train
% Train the model

[U, D, V] = svd(X_mean_imputed, 0);

U_trunc = U(:, 1:SVD_K);
D_trunc = D(1:SVD_K, 1:SVD_K);
V_trunc = V(:, 1:SVD_K);

% U_p = U_trunc * sqrt(D_trunc);
% V_p = sqrt(D_trunc) * V_trunc';
X_svd = U_trunc * D_trunc * V_trunc';


%% 3. Predict
% Replaced unknown values in X_pred with new values
X_pred(X_pred == nil) = X_svd(X_pred == nil);


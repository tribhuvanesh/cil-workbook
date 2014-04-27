function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

% your collaborative filtering code here!
X_pred_copy = X;
X_pred = X;

% Simple Baseline - Replace missing values with average value over all of item's
% ratings. RMSE = 4.653
% Also serves to impute the missing values
X_pred_avg = zeros(size(X_pred_copy, 1), 1);
for i=1:size(X_pred_copy, 1)
    xi = X_pred_copy(i, :);
    X_pred_avg(i) = mean(xi(xi ~= nil));
    xi(xi == nil) = X_pred_avg(i);
    X_pred_copy(i, :) = xi;
end

% SVD solution
[U, D, V] = svd(X_pred_copy);
% k = 100; % 4.653
% k = 50; % 4.5737
% k = 25; % 4.4412
% k = 10; % 4.3754
% k = 7; % 4.3593
k = 5; % 4.357
% k = 4; % 4.3651
% k = 2; % 4.4155

U_trunc = U(:, 1:k);
D_trunc = D(1:k, 1:k);
V_trunc = V(:, 1:k);

size(U_trunc)
size(D_trunc)
size(V_trunc)

U_p = U_trunc * sqrt(D_trunc);
V_p = sqrt(D_trunc) * V_trunc';
X_pred_copy = U_trunc * D_trunc * V_trunc';

for i=1:size(X_pred, 1)
    for j=1:size(X_pred, 2)
        if X_pred(i, j) == nil
            % X_pred(i, j) = U_p(i) * V_p(j);
            X_pred(i, j) = X_pred_copy(i, j);
        end
    end
end

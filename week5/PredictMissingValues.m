function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

KMEANS_K = 18;

%% 0. Preprocessing
% a. Calculate the mean of all observed ratings
X_pred = X;
X_mean_imputed = X;
mu = mean(mean(X_pred(X_pred ~= nil)));

%% 1. Imputation
% Impute the missing values by replacing them with average values

% Replace missing ratings with average ratings by that user
X_pred_avg = zeros(size(X_mean_imputed, 1), 1);
% X_for_kmeans = X;
for i=1:size(X_mean_imputed, 1)
    xi = X(i, :);
    X_pred_avg(i) = mean(xi(xi ~= nil));
    xi(xi == nil) = X_pred_avg(i);
    X_mean_imputed(i, :) = xi;
    % X_for_kmeans(i, :) = X_mean_imputed(i, :) - X_pred_avg(i);
end

%% K-means and SVD
% Apply k-means to cluster similar users
kmeans_idx = kmeans(X_mean_imputed, KMEANS_K);

% For each cluster, perform SVD and impute missing values
for i=1:KMEANS_K
    % Obtain all users belonging to cluster i
    X_org_k = X(kmeans_idx == i, :);
    X_mean_imputed_k = X_mean_imputed(kmeans_idx == i, :);
    
    % Obtain average rating of each item/column in this cluster
    % Repeat to form matrix of size X_org_k
    X_mean_rating_k = repmat(mean(X_mean_imputed_k), size(X_org_k, 1), 1);
    
    % Replace unknown ratings with imputed ratings
    X_org_k(X_org_k == nil) = X_mean_rating_k(X_org_k == nil);
    X_pred(kmeans_idx == i, :) = X_org_k;
end
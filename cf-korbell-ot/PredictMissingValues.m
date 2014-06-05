function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

%% Parameters
% Parameters and stuff

DIM_F = 100;
NUM_USERS = size(X, 1);
NUM_ITEMS = size(X, 2);

GAMMA_BIAS = 0.005;
GAMMA = 0.005;
LAMBDA = 0.1;
NUM_ITER = 2;

SVD_K = 25;

%% Preprocessing
% Preprocessing stuff

global_mean = mean(X(X ~= nil));
% Each row contains p_u
%P = rand(NUM_USERS, DIM_F);
% Each row contains q_i
%Q = rand(NUM_ITEMS, DIM_F);
% Error matrix
% E = zeros(NUM_USERS, NUM_ITEMS);

% Obtain triplets [user, item, rating]
[users, items] = find(X ~= nil);
[X_pred, P, Q] = StandardSVD(X, X, nil);
Q = Q';
triplet_matrix = [users, items, X_pred(sub2ind(size(X), users, items))];




%% Perform SGD
% Perform Stochastic Gradient Descent

bias_users = zeros(NUM_USERS, 1);
bias_movies = zeros(NUM_ITEMS, 1);

factor_matrix = randn(size(Q));

for niters=1:NUM_ITER
    for row=1:size(triplet_matrix, 1)
        u = triplet_matrix(row, 1);
        i = triplet_matrix(row, 2);
        r = triplet_matrix(row, 3);
        
        temp = X(u, :);
        temp = find(temp ~= nil);
        %sum(factor_matrix(temp,:), 1)
        e_ui = r - global_mean - (P(u, :) + length(temp) ^ -0.5 * sum(factor_matrix(temp,:), 1))*Q(i, :)' - bias_users(u) - bias_movies(i);
        temp1 = Q(i, :) + GAMMA * (e_ui*P(u, :) - LAMBDA*Q(i, :));
        temp2 = P(u, :) + GAMMA * (e_ui*Q(i, :) - LAMBDA*P(u, :));
        bias_users(u) =  bias_users(u) + GAMMA_BIAS * (e_ui - LAMBDA * bias_users(u));
        bias_movies(i) =  bias_movies(i) + GAMMA_BIAS * (e_ui - LAMBDA * bias_movies(i));
        %length(temp)
        correction = e_ui * length(temp) ^ -0.5 * Q(i, :);
        correction = repmat(correction, length(temp),1);
        factor_matrix(temp, :) = factor_matrix(temp, :) +GAMMA * (correction - LAMBDA * factor_matrix(temp, :)) ;
        Q(i, :) = temp1;
        P(u, :) = temp2;
    end
end

%X_pred = P*Q' + global_mean + repmat(bias_users, 1, NUM_ITEMS) + repmat(bias_movies', NUM_USERS, 1);
for i = 1:size(X_pred,1)
    temp = X(i, :);
    temp = find(temp ~= nil);
    for j= 1:size(X_pred,2)
        if(X(i,j) == nil)
            X_pred(i,j) = global_mean +  (P(i,:) + length(temp) ^ -0.5 * sum(factor_matrix(temp,:), 1)) * Q(j,:)' + bias_users(i) + bias_movies(j);
        end
    end
end
X_pred(X ~= nil) = X(X ~= nil);

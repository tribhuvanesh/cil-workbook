function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

%% Parameters
% Parameters and stuff

DIM_F = 100;
NUM_USERS = size(X, 1);
NUM_ITEMS = size(X, 2);

GAMMA = 0.005;
LAMBDA = [0.1, 0.09];
NUM_ITER = 2;
REDUCER = 0.45;

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

for niters=1:NUM_ITER
    for row=1:size(triplet_matrix, 1)
        u = triplet_matrix(row, 1);
        i = triplet_matrix(row, 2);
        r = triplet_matrix(row, 3);
        e_ui = r - global_mean - P(u, :)*Q(i, :)' - bias_users(u) - bias_movies(i);
        temp1 = Q(i, :) + GAMMA * (e_ui*P(u, :) - LAMBDA(2)*Q(i, :));
        temp2 = P(u, :) +GAMMA * (e_ui*Q(i, :) - LAMBDA(1)*P(u, :));
        bias_users(u) =  bias_users(u) + GAMMA * (e_ui - LAMBDA(1) * bias_users(u));
        bias_movies(i) =  bias_movies(i) + GAMMA * (e_ui - LAMBDA(2) * bias_movies(i));
        Q(i, :) = temp1;
        P(u, :) = temp2;
    end
    GAMMA = GAMMA * REDUCER;
end

X_pred = P*Q' + global_mean + repmat(bias_users, 1, NUM_ITEMS) + repmat(bias_movies', NUM_USERS, 1);
X_pred(X ~= nil) = X(X ~= nil);

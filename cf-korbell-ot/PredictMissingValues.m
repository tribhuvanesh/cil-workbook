function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

%% Parameters
% Parameters and stuff

DIM_F = 100;
NUM_USERS = size(X, 1);
NUM_ITEMS = size(X, 2);

GAMMA = 0.001;
LAMBDA = 1.5;

%% Preprocessing
% Preprocessing stuff

global_mean = mean(X(X ~= nil));
% Each row contains p_u
P = rand(NUM_USERS, DIM_F);
% Each row contains q_i
Q = rand(NUM_ITEMS, DIM_F);
% Error matrix
% E = zeros(NUM_USERS, NUM_ITEMS);

%% Perform SGD
% Perform Stochastic Gradient Descent
for u=1:NUM_USERS
    for i=1:NUM_ITEMS
        if X(u, i) ~= nil
            e_ui = X(u, i) - Q(i, :)*P(u, :)';
            temp1 = Q(i, :) + GAMMA * (e_ui*P(u, :) - LAMBDA*Q(i, :));
            temp2 = P(u, :) + GAMMA * (e_ui*Q(i, :) - LAMBDA*P(u, :));
            Q(i, :) = temp1;
            P(u, :) = temp2;
        end
    end
end

X_pred = P*Q';
% X_pred(X ~= nil) = X(X ~= nil);

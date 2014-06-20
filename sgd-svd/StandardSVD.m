function [X_pred, U, V] = StandardSVD(X_pred, X, nil, s)
%%STANDARDSVD Imputes missing values in data and provides initial weight
%%vectors
% The objective of this function is to serve as a fix to the cold-start
% problem in the SGD-SVD Collaborative Filtering code.
% It imputes missing values based on Simon Funk's "Try this at home"
% approach
% Additionally, it initializes the User and Item weight vectors, using
% which we realized a boost in scores
%% Parameters
    BR = s.BR;
    SVD_K = s.SVD_K;
    SVD_LAMBDA = s.SVD_LAMBDA;
    
    num_users = size(X_pred,1);
    num_movies = size(X_pred, 2);
    offset = zeros(num_users,1); 
    rated = zeros(num_users,1);
    
    % Compute global mean
    tmp = X;
    tmp(X == nil) = 0;
    avg = ((sum(tmp, 1) ./ sum(tmp ~= 0, 1)))';
    avg(isnan(avg)) = mean(X_pred(X_pred ~= nil));
    observed = sum(tmp ~= 0, 1)';
    global_average = mean(avg);
    
    % Blend global averages and user's observed ratings
    avg = ((BR*global_average) + (avg .* observed)) ./ (BR + observed);
    
    for i= 1:size(X_pred,1)
        counter = 0;
        o = 0;
        for j = 1:num_movies
              if X_pred(i,j)~= nil
                  counter = counter + 1;
                  o = o + X_pred(i, j) - avg(j);     
              end    
        end
        rated(i) = counter;
        offset(i) = o/counter;
    end

    offset_average = mean(offset);
    offset = (BR*offset_average + offset .*rated) ./ (BR + rated);

    tmp = repmat(avg', num_users, 1) + repmat(offset, 1, num_movies);
    X_pred(X == nil) = tmp(X == nil);

    m = mean(X_pred);
    s  = std(X_pred); 
    X_pred = stdize(X_pred);

    % Perform SVD to initialize weight vectors
    [U, D, V] = svd(X_pred, 0);
    D = D + eye(size(D)) * SVD_LAMBDA;
    U = U * sqrt(D);
    U = U(:, 1:SVD_K);
    V = V * sqrt(D)';
    V = V(:, 1:SVD_K)';
    tmp = U * V;
    X_pred(X == nil) = tmp(X == nil);
    
    % Unstandardize
    X_pred = X_pred .* repmat(s, size(X,1), 1);
    X_pred = (X_pred + repmat(m,size(X,1),1));
end

function Y = stdize(X)
    Y = (X - repmat(mean(X),size(X,1),1))./repmat(std(X), size(X,1), 1);
end
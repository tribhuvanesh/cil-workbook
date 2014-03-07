function [ mu, lambda, U ] = PCAanalyse( X )
%PCAANALYSE Summary of this function goes here
%   Detailed explanation goes here

% Get mean for each of the d rows
mu = mean(X, 1);

[U, lambda] = eig(cov(X));

end


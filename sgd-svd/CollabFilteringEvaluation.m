% Evaluation script for the collaborative filtering problem. Loads data
% matrix, splits known values into training and testing sets, and computes
% the MSE of the predicted to the true known entries of the test data.
%
% Loads data from Data.mat and calls PredictMissingValues.m.

% Setup
rand('seed', 1);  % fix random seed for reproducibility

% Filenames for corresponding datasets
dataset_cil = '../datasets/cil.mat';
dataset_ml = '../datasets/DataMovieLens100k.mat';
dataset_j1 = '../datasets/jester1.mat';
dataset_j2 = '../datasets/jester2.mat';
dataset_j3 = '../datasets/jester3.mat';

filename = dataset_cil;

%prc_trn = 0.8;  % percentage of training data
nil = 99;  % missing value indicator

s = struct;

% Parameters for KFold
s.kfold_k = 5;
s.dataset = '../datasets/cil.mat';

% CIL best params
% Parameters for StandardSVD
s.BR = 10;
s.SVD_K = 11;
s.SVD_LAMBDA = 10;

% Parameters for PredictMissingValues
s.PRC_TRN = 0.95;
s.GAMMA = 0.005;
s.LAMBDA = [0.1, 0.09];
s.NUM_PASSES = 5; 
s.REDUCER = 0.35;

% Load data
L = load(filename);
X = L.X;

% Split intro training and testing index sets
idx = find(X ~= nil); 
n = numel(idx);

trn_arr = [0.25 0.5 0.75 1.0];

for i=1:numel(trn_arr)
	prc_trn = trn_arr(i);
    s.comments = sprintf('4.1364 in 12secs - CIL - prc_trn=%d - lab', prc_trn*100);
    s.SAVE_FILENAME = sprintf('korbell-ot-lab-star-cil-prc_trn%d.mat', prc_trn*100);
    disp(s.SAVE_FILENAME);
    for j=1:10
        fprintf('Pass = %d\n', j);

        n_trn = round(n*prc_trn);
        rp = randperm(n);
        idx_trn = idx(rp(1:n_trn));
        idx_tst = idx(rp(n_trn+1:end));

        % Build training and testing matrices
        X_trn = ones(size(X))*nil;
        X_trn(idx_trn) = X(idx_trn);  % add known training values

        X_tst = ones(size(X))*nil;
        X_tst(idx_tst) = X(idx_tst);  % add known training values


        % Predict the missing values here!
        X_pred = PredictMissingValues(X_trn, nil, s);

        % Compute MSE
        mse = sqrt(mean((X_tst(X_tst ~= nil) - X_pred(X_tst ~= nil)).^2));  % error on known test values

        disp(['Root of Mean-squared error: ' num2str(mse)]);
    end
end    
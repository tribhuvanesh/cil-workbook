function [ ] = CollabFilteringEvaluationKFoldFunc( s )
%COLLABFILTERINGEVALUATIONKFOLDFUNC Summary of this function goes here
%   Detailed explanation goes here

%     %% Experimental configuration
% 
%     s = struct;
% 
%     % Parameters for KFold
%     s.kfold_k = 5;
%     s.dataset = '../datasets/cil.mat';
%     s.comments = '4.1364 in 12secs - CIL - svd_k=11 - lab';
%     s.SAVE_FILENAME = 'korbell-ot-lab-star-cil-svd_k11.mat';
% 
%     %% CIL best params
%     % Parameters for StandardSVD
%     s.BR = 10;
%     s.SVD_K = 11;
%     s.SVD_LAMBDA = 10;
% 
%     % Parameters for PredictMissingValues
%     s.PRC_TRN = 0.95;
%     s.GAMMA = 0.005;
%     s.LAMBDA = [0.1, 0.09];
%     s.NUM_PASSES = 5; 
%     s.REDUCER = 0.35;

    %% ML100 Best params
    % % Parameters for StandardSVD
    % s.BR = 10;
    % s.SVD_K = 10;
    % s.SVD_LAMBDA = 10;
    % 
    % % Parameters for PredictMissingValues
    % s.PRC_TRN = 1.0;
    % s.GAMMA = 0.02;
    % s.LAMBDA = [0.4, 0.2];
    % s.NUM_PASSES = 3;
    % s.REDUCER = 0.35;

    %% JES1 Best params
    % % Parameters for StandardSVD
    % s.BR = 10;
    % s.SVD_K = 11;
    % s.SVD_LAMBDA = 10;
    % 
    % % Parameters for PredictMissingValues
    % s.PRC_TRN = 1.0;
    % s.GAMMA = 0.01;
    % s.LAMBDA = [0.2, 0.04];
    % s.NUM_PASSES = 3;
    % s.REDUCER = 0.35;

    %% Rest

    % Setup
    % rand('seed', 1);  % fix random seed for reproducibility
    kfold_k = s.kfold_k;
    comments = s.comments;

    ENABLE_FILE_SAVES = 1;
    SAVE_FILENAME = s.SAVE_FILENAME;

    % Filenames for corresponding datasets
    dataset_cil = '../datasets/cil.mat';
    dataset_ml = '../datasets/DataMovieLens100k.mat';
    dataset_j1 = '../datasets/jester1.mat';
    dataset_j2 = '../datasets/jester2.mat';
    dataset_j3 = '../datasets/jester3.mat';

    filename = s.dataset;
    nil = 99;  % missing value indicator

    % Load data
    L = load(filename);
    X = L.X;

    % Split intro training and testing index sets
    idx = find(X ~= nil); 
    n = numel(idx);

    indices = crossvalind('Kfold', n, kfold_k);
    mse_arr = zeros(kfold_k, 1);

    run_time_arr = zeros(kfold_k, 1);

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
        tic
        X_pred = PredictMissingValues(X_trn, nil, s);
        run_time_arr(i) = toc;

        % Compute MSE
        mse = sqrt(mean((X_tst(X_tst ~= nil) - X_pred(X_tst ~= nil)).^2));  % error on known test values
        mse_arr(i) = mse;

        disp(['Root of Mean-squared error: ' num2str(mse)]);
    end

    if ENABLE_FILE_SAVES
        mse_prev = [];
        run_time_prev = [];

        if exist(SAVE_FILENAME, 'file') == 2
            temp = load(SAVE_FILENAME);

            if isfield(temp, 'mse_arr')
                mse_prev = temp.mse_arr;
            end

            if isfield(temp, 'run_time_arr')
                run_time_prev = temp.run_time_arr;
            end        

            mse_arr = [mse_prev mse_arr];
            run_time_arr = [run_time_prev run_time_arr];
        else
            created_at = 0;
            save(SAVE_FILENAME, 'created_at');
            save(SAVE_FILENAME, 'comments');
        end

        save(SAVE_FILENAME, 'mse_arr', '-append');
        save(SAVE_FILENAME, 'run_time_arr', '-append');

    end

end


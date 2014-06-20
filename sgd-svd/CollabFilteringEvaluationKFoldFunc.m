function [ ] = CollabFilteringEvaluationKFoldFunc( s )
%COLLABFILTERINGEVALUATIONKFOLDFUNC Runs KFold for SGD-SVD given the model
% parameters in struct 's'
%   This function initiates a K-Fold cross validation and stores
%   experimental observed data using the GoldenBrown
%   SGD-SVD algorithm, whose parameters are set in struct s. These
%   parameters, along with their default values are:
%   1. K-Fold parameters
%     kfold_k = 5;
%     dataset = '../datasets/cil.mat';
% 
%   2. StandardSVD Parameters
%     BR = 10;
%     SVD_K = 11;
%     SVD_LAMBDA = 10;
% 
%   3. PredictMissingValues Parameters
%     PRC_TRN = 0.95;
%     GAMMA = 0.005;
%     LAMBDA = [0.1, 0.09];
%     NUM_PASSES = 5; 
%     REDUCER = 0.35;
%
%   4. Others
%     SAVE_FILENAME
%     comments

    % Setup
    % rand('seed', 1);  % Uncomment when reproducibility it required
    kfold_k = s.kfold_k;
    comments = s.comments;

    ENABLE_FILE_SAVES = 1;
    SAVE_FILENAME = s.SAVE_FILENAME;

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

        % Predict the missing values here. Also, time it.
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


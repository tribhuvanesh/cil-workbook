function X_pred = PredictMissingValues(X, nil, s)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

    %% Experimental setup
    % PRC_TRN \in [0.0, 1.0]. Rest is used for validation during gradient descent
    PRC_TRN = s.PRC_TRN;

    NUM_USERS = size(X, 1);
    NUM_ITEMS = size(X, 2);

    GAMMA = s.GAMMA;
    LAMBDA = s.LAMBDA;
    NUM_PASSES = s.NUM_PASSES;
    REDUCER = s.REDUCER;
    DIM_F = 11;

    ENABLE_PLOTS = 0;
    ENABLE_FILE_SAVES = 1;

    %% Split data
    % Split data into training and validation dataset
    % Split intro training and validation index sets
    idx = find(X ~= nil);
    n = numel(idx);

    n_trn = round(n*PRC_TRN);
    rp = randperm(n);
    idx_trn = idx(rp(1:n_trn));
    idx_vldn = idx(rp(n_trn+1:end));

    % Build training and validation matrices
    X_trn = ones(size(X))*nil;
    X_trn(idx_trn) = X(idx_trn);  % add known training values

    X_vldn = ones(size(X))*nil;
    X_vldn(idx_vldn) = X(idx_vldn);  % add known validation values

    X = X_trn;

    %% Preprocessing
    % Impute missing values and initialize weight vectors

    global_mean = mean(X(X ~= nil));

    % Obtain triplets [user, item, rating]
    [users, items] = find(X ~= nil);
    if s.SVD_K == 0
        % Treat this as a special case, where P and Q are randomly
        % initialized. i.e, no imputing of missing ratings and
        % initialization of weight vectors using StandardSVD
        P = ones(NUM_USERS, DIM_F) * 0.1;
        Q = ones(NUM_ITEMS, DIM_F) * 0.1;
        X_pred = X;
        X_mean_imputed = X;
        mu = mean(mean(X_pred(X_pred ~= nil)));
        % Replace missing ratings with average ratings by that user
        X_pred_avg = zeros(size(X_mean_imputed, 1), 1);
        for i=1:size(X_mean_imputed, 1)
            xi = X_pred(i, :);
            X_pred_avg(i) = mean(xi(xi ~= nil));
            xi(xi == nil) = X_pred_avg(i);
            X_mean_imputed(i, :) = xi;
        end
        X_pred = X_mean_imputed;    
    else
        % Go ahead with the StandardSVD procedure of
        [X_pred, P, Q] = StandardSVD(X, X, nil, s);
        Q = Q';
    end
    triplet_matrix = [users, items, X_pred(sub2ind(size(X), users, items))];
    NUM_TRN_DATA = size(triplet_matrix, 1);

    %% Perform SGD
    % Perform Stochastic Gradient Descent

    bias_users = zeros(NUM_USERS, 1);
    bias_movies = zeros(NUM_ITEMS, 1);

    %=== (Un)comment this if data needs to be iterated and shuffled at end
    % of each pass
    mse_by_iter = zeros(floor(NUM_TRN_DATA/5000), 1);
    for niters=1:NUM_PASSES
        for row=1:NUM_TRN_DATA
            u = triplet_matrix(row, 1);
            i = triplet_matrix(row, 2);
            r = triplet_matrix(row, 3);
            e_ui = r - global_mean - P(u, :)*Q(i, :)' - bias_users(u) - bias_movies(i);
            temp1 = Q(i, :) + GAMMA * (e_ui*P(u, :) - LAMBDA(2)*Q(i, :));
            temp2 = P(u, :) + GAMMA * (e_ui*Q(i, :) - LAMBDA(1)*P(u, :));
            bias_users(u) =  bias_users(u) + GAMMA * (e_ui - LAMBDA(1) * bias_users(u));
            bias_movies(i) =  bias_movies(i) + GAMMA * (e_ui - LAMBDA(2) * bias_movies(i));
            Q(i, :) = temp1;
            P(u, :) = temp2;

            if ENABLE_PLOTS || ENABLE_FILE_SAVES
                ind = (niters-1)*NUM_TRN_DATA + row;
                if mod(ind, 5000) == 0
                    X_pred = P*Q' + global_mean + repmat(bias_users, 1, NUM_ITEMS) + repmat(bias_movies', NUM_USERS, 1);
                    X_pred(X ~= nil) = X(X ~= nil);
                    mse_by_iter(floor(ind/1000), 1) = sqrt(mean((X_vldn(X_vldn ~= nil) - X_pred(X_vldn ~= nil)).^2));  % error on known test values
                end
            end
        end
        % Shuffle the data points
        triplet_matrix = triplet_matrix(randperm(NUM_TRN_DATA), :);
        GAMMA = GAMMA * REDUCER;
    end
    %===

    %=== (Un)comment this in case the data needs to be uniformly sampled
    % UNISAMP_ITER = 100000;
    % mse_by_iter_unisamp = zeros(floor(UNISAMP_ITER/1000), 1);
    % for niters=1:UNISAMP_ITER
    %     row = datasample(triplet_matrix, 1);
    %     u = row(1);
    %     i = row(2);
    %     r = row(3);
    %     e_ui = r - global_mean - P(u, :)*Q(i, :)' - bias_users(u) - bias_movies(i);
    %     temp1 = Q(i, :) + GAMMA * (e_ui*P(u, :) - LAMBDA(2)*Q(i, :));
    %     temp2 = P(u, :) + GAMMA * (e_ui*Q(i, :) - LAMBDA(1)*P(u, :));
    %     bias_users(u) =  bias_users(u) + GAMMA * (e_ui - LAMBDA(1) * bias_users(u));
    %     bias_movies(i) =  bias_movies(i) + GAMMA * (e_ui - LAMBDA(2) * bias_movies(i));
    %     Q(i, :) = temp1;
    %     P(u, :) = temp2;
    %     
    %     if ENABLE_PLOTS
    %         ind = niters;
    %         if mod(ind, 1000) == 0
    %             X_pred = P*Q' + global_mean + repmat(bias_users, 1, NUM_ITEMS) + repmat(bias_movies', NUM_USERS, 1);
    %             X_pred(X ~= nil) = X(X ~= nil);
    %             mse_by_iter_unisamp(floor(ind/1000), 1) = sqrt(mean((X_vldn(X_vldn ~= nil) - X_pred(X_vldn ~= nil)).^2));  % error on known test values
    %         end
    %     end
    %     
    %     if niters == UNISAMP_ITER/2
    %         GAMMA = GAMMA * REDUCER;
    %     end
    % end
    %===

    %% Save to file
    % Save to file

    SAVE_FILENAME = s.SAVE_FILENAME;

    if ENABLE_FILE_SAVES
        mse_by_iter_prev = [];

        if exist(SAVE_FILENAME, 'file') == 2
            temp = load(SAVE_FILENAME);

            if isfield(temp, 'mse_by_iter')
                mse_by_iter_prev = temp.mse_by_iter;
            end

            mse_by_iter = [mse_by_iter_prev mse_by_iter];
        else
            created_at = now;
            save(SAVE_FILENAME, 'created_at');
            % save(SAVE_FILENAME, 'comments', '-append');
        end

        save(SAVE_FILENAME, 'mse_by_iter', '-append');
        save(SAVE_FILENAME, 'NUM_TRN_DATA', '-append');
        save(SAVE_FILENAME, 'NUM_PASSES', '-append');

    end


    %% GRAPHS

    if ENABLE_PLOTS
        % 1. Iterations vs. RMSE
        figure
        plot(mse_by_iter)
    %     hold on
    %     plot(mse_by_iter_unisamp)
        title('RMSE vs. Iterations')
        xlabel('Number of iterations (in 1000s)')
        ylabel('RMSE')
    end

    %% FINAL

    X_pred = P*Q' + global_mean + repmat(bias_users, 1, NUM_ITEMS) + repmat(bias_movies', NUM_USERS, 1);
    X_pred(X ~= nil) = X(X ~= nil);

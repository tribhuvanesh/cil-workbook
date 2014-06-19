%% ExptRunner
% This script produces results as discussed in Section IV.C of the paper

% The intention of this script is to produce the data required for plotting
% the effect of various parameters of the GoldenBrown SGD-SVD algorithm.
% The produced .mat files can be visualized in the graphs-factory.ipynb 
% iPython notebook.
% The different parameters for the algorithm can be partitioned into 3
% sections - 1) KFold (for validation/experiments), 2) StandardSVD (For SVD
% intialization) and 3) PredictMissingValues (For Stochastic Gradient Descent)

%% Experiment Setup
EXPT_TIMES = 10;

% Use this struct to store all parameters of the model
s = struct;

% Load default params
% Parameters for KFold
s.kfold_k = 5;
% Choose between: cil, ml100, jes1, jes2 and jes3
s.dataset = '../datasets/cil.mat';

%% CIL tuned parameters
% These parameters serve as the default parameters when one of them is
% being varied

% Parameters for StandardSVD
s.BR = 10;
s.SVD_K = 11;
s.SVD_LAMBDA = 10;

% Parameters for PredictMissingValues
% PRC_TRN of (k-1)/k% is used for training
% 1-PRC_TRN of (k-1)/k% is used for validation
% 1/k is used for testing
s.PRC_TRN = 0.95;
s.GAMMA = 0.005;
s.LAMBDA = [0.1, 0.09];
s.NUM_PASSES = 5; 
s.REDUCER = 0.35;

%% SVD_K experiment
svd_k = [5 11 15 25 50 0];
for i=1:numel(svd_k)
    for j=1:EXPT_TIMES
        s.SVD_k = svd_k(i);
        s.comments = sprintf('4.1364 in 12secs - CIL - svd_k=%d - lab', svd_k(i));
        s.SAVE_FILENAME = sprintf('korbell-ot-lab-star-cil-svd_k%d.mat', svd_k(i));

        disp(s.SAVE_FILENAME);
        fprintf('Pass=%d\n', j);

        CollabFilteringEvaluationKFoldFunc(s);
    end
end

%% Gamma experiment
gamma = [0.001 0.005 0.01 0.02];
for i=1:numel(gamma)
    s.comments = sprintf('4.1364 in 12secs - CIL - gamma=%d - lab', gamma(i));
    s.SAVE_FILENAME = sprintf('korbell-ot-lab-star-cil-gamma%d.mat', gamma(i)*1000);
    disp(s.SAVE_FILENAME);

    for j=1:EXPT_TIMES
        s.GAMMA = gamma(i);
        fprintf('Pass=%d\n', j);

        CollabFilteringEvaluationKFoldFunc(s);
    end
end    

%% Reducer experiment
reducer = [0.1 0.35 0.5 0.75 1.0];
for i=1:numel(reducer)
    s.comments = sprintf('4.1364 in 12secs - CIL - reducer=%d - lab', reducer(i));
    s.SAVE_FILENAME = sprintf('korbell-ot-lab-star-cil-reducer%d.mat', reducer(i)*100);
    disp(s.SAVE_FILENAME);

    for j=1:EXPT_TIMES
        s.REDUCER = reducer(i);
        fprintf('Pass=%d\n', j);

        CollabFilteringEvaluationKFoldFunc(s);
    end
end  

%% BlendRatio experiment
br = [5 10 25 50 0];
for i=1:numel(br)
    s.comments = sprintf('4.1364 in 12secs - CIL - br=%d - lab', br(i));
    s.SAVE_FILENAME = sprintf('korbell-ot-lab-star-cil-br%d.mat', br(i));
    disp(s.SAVE_FILENAME);

    for j=1:EXPT_TIMES
        s.BR = br(i);
        fprintf('Pass=%d\n', j);

        CollabFilteringEvaluationKFoldFunc(s);
    end
end  
    
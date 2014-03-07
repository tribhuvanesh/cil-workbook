function I_comp = Compress(I)

% Your compression code goes here

% I_comp.I = I; % this is just a stump to make the evaluation script run, replace it with your code!

k = 100;
d = 10;

% Extract the design matrix, with tiled column vectors, each representing a
% data point
X = extract(I, d);
% Center the data
m = size(X, 1);
n = size(X, 2);
M = repmat(mean(X, 2), 1, n);
X_centered = X - M;

[mu, lambda, U] = PCAanalyse(X_centered);

% Sort the eigenvector and eigenvalue matrices
[lambda_sorted, eig_val_order_idx] = sort(diag(lambda));
U_sorted = U(:, eig_val_order_idx);
% Get the first k eigenvectors
U_k = U_sorted(:, 1:k);
size(U_k')
size(X_centered)

% Transform the data using U_k
Z_k = U_k' * X_centered';

I_comp.compressed = Z_k;
I_comp.M = M;

end
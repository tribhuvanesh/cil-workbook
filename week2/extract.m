function [ X ] = extract( I, d )
%EXTRACT Extracts non-overlapping d x d patches

% Pad the last row to make num_rows % d = 0
if rem(size(I,1), d) ~= 0
    I = [I; repmat(I(end, :), rem(size(I, 1), d), 1)];
end

% Pad the last column to make num_cols % d = 0
if rem(size(I,2), d) ~= 0
    I = [I repmat(I(end, :), 1, rem(size(I, 2), d))];
end

X_t = zeros(size(I,1)*size(I, 2)/(d*d), d*d);

n = 1;
size(I)
size(X_t)
for i = 1:d:size(I, 1)
    for j = 1:d:size(I, 2)
        patch = I(i:i+d-1, j:j+d-1);
        X_t(n, :) = patch(:)';
        n = n + 1;
    end
end

X = X_t';


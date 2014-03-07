function [ X ] = extract( I, d )
%EXTRACT Extracts non-overlapping d x d patches

if size(size(I), 2) == 3
    % Iterate over all three channels
    for i=1:3
        % Concatenate for each channel
        % size(extract(I(:, :, 1), d))
        X = [extract(I(:, :, 1), d) extract(I(:, :, 2), d) extract(I(:, :, 3), d)];
    end
elseif size(size(I), 2) == 2
    % Iterate only over the single channel
    X = mymat2cell(I, d);
end    

end

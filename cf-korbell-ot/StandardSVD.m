function [X_pred, U, V] = StandardSVD(X_pred, X, nil)
    num_users = size(X_pred,1);
    num_movies = size(X_pred, 2);
    avg =zeros(num_movies,1);
    offset = zeros(num_users,1);
    br = 10; %blending ratio
    observed = zeros(num_movies,1);  
    rated = zeros(num_users,1);
    
    % Calculate averge rating for each movie   
%     for i= 1:size(X_pred,2)
%         curr_col = X_pred(:, i);
%         avg(i) = mean(curr_col(curr_col~=nil));
%         len = size(curr_col(curr_col~=nil),1);
%         observed(i) = len;
%     end

    tmp = X;
    tmp(X == nil) = 0;
    avg = ((sum(tmp, 1) ./ sum(tmp ~= 0, 1)))';
    observed = sum(tmp ~= 0, 1)';

    global_average = mean(avg);
    
    %Calculate better average
%     for i = 1:size(avg)
%         r = (br*global_average + avg(i) *observed(i))/ (br + observed(i));
%         avg(i) = r;
%     end
    
    avg = ((br*global_average) + (avg .* observed)) ./ (br + observed);
    
    %size(avg)
    
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
    
%     counter = sum(X ~= nil, 2)
%     tmp = X;
%     tmp = tmp - repmat(avg)

    offset_average = mean(offset);
%     for i = 1:size(offset)
%         r = (br*offset_average + offset(i) *rated(i))/ (br + rated(i));
%         offset(i) = r;
%     end
    offset = (br*offset_average + offset .*rated) ./ (br + rated);


%     for i = 1:size(X_pred,1)
%         for j= 1:size(X_pred,2)
%             if(X(i,j) == nil)
%                 X_pred(i,j) = avg(j) + offset(i);
%             end
%         end
%     end

    % For user u, and movie i
    % r_ui = avg_i + offset_u
    tmp = repmat(avg', num_users, 1) + repmat(offset, 1, num_movies);
    X_pred(X == nil) = tmp(X == nil);


    m = mean(X_pred);
    s  = std(X_pred); 
    X_pred = stdize(X_pred);
    k = 11;
    lambda = 125;
    [U,S,V] = svd(X_pred,0);
    I = eye(size(S,1));
    S = S + I * lambda;
    U = U * sqrt(S);
    U = U(:,1:k);
    V =  sqrt(S)* V ;
    V = V(:,1:k);
    V = V';
%     for i = 1:size(X_pred,1)
%         for j= 1:size(X_pred,2)
%             if(X(i,j) == nil)
%                 X_pred(i,j) = U(i,:) * V(:,j);
%             end
%         end
%     end
    tmp = U * V;
    X_pred(X == nil) = tmp(X == nil);
    %unstandardize
    X_pred = X_pred.*repmat(s, size(X,1), 1);
    X_pred = (X_pred + repmat(m,size(X,1),1));
end

function Y = stdize(X)
    Y = zeros(size(X));
    Y = (X - repmat(mean(X),size(X,1),1))./repmat(std(X), size(X,1), 1);
end


function X_pred = PredictMissingValues(X, nil)
% Predict missing entries in matrix X based on known entries. Missing
% values in X are denoted by the special constant value nil.

% your collaborative filtering code here!
%X_pred = stdize(X);
X_pred = StochasticSVD(X, nil);
end
function Y = stdize(X)
 Y = zeros(size(X));
 Y = (X - repmat(mean(X),size(X,1),1))./repmat(std(X), size(X,1), 1);
end

function [X_pred, U, V] = StandardSVD(X_pred, X, nil)
num_users = size(X_pred,1);
num_movies = size(X_pred, 2);
avg =zeros(num_movies,1);
offset = zeros(num_users,1);
br = 10; %blending ratio
observed = zeros(num_movies,1);  
rated = zeros(num_users,1);

for i= 1:size(X_pred,2)
    curr_col = X_pred(:, i);
    avg(i) = mean(curr_col(curr_col~=nil));
    len = size(curr_col(curr_col~=nil),1);
    observed(i) = len;
end

global_average = mean(avg)
%Calculate better average
for i = 1:size(avg)
    r = (br*global_average + avg(i) *observed(i))/ (br + observed(i));
    avg(i) = r;
end    
for i= 1:size(X_pred,1)
    counter = 0;
    o =0;
    for j = 1:num_movies
          if X_pred(i,j)~= nil
              counter = counter + 1;
              o = o + X_pred(i, j) - avg(j);     
          end    
    end
    rated(i) = counter;
    offset(i) = o/counter;
end

offset_average = mean(offset);
for i = 1:size(offset)
    r = (br*offset_average + offset(i) *rated(i))/ (br + rated(i));
    offset(i) = r;
end   
%Calculate better offset averages


for i = 1:size(X_pred,1)
    for j= 1:size(X_pred,2)
        if(X(i,j) == nil)
            X_pred(i,j) = avg(j) + offset(i);
        end
    end
end


m = mean(X_pred);
s  = std(X_pred); 
X_pred = stdize(X_pred);
k = 8;
lambda = 125;
[U,S,V] = svd(X_pred,0);
I = eye(size(S,1));
S = S + I * lambda;
U = U * sqrt(S);
U = U(:,1:k);
V =  sqrt(S)* V ;
V = V(:,1:k);
V = V';
for i = 1:size(X_pred,1)
    for j= 1:size(X_pred,2)
        if(X(i,j) == nil)
            X_pred(i,j) = U(i,:) * V(:,j);
        end
    end
end
%unstandardize
X_pred = X_pred.*repmat(s, size(X,1), 1);
X_pred = (X_pred + repmat(m,size(X,1),1));
end


function X_pred = StochasticSVD(X, nil)
X_pred = X;
[row,col] = find(X~=nil);
average = mean(X(X~=nil));
learningRate = 0.005;
regularizer = 0.02;
%numFeatures = 8 ;
[X_pred, Users, Movies] = StandardSVD(X_pred, X, nil);
for i = 1:2
for u = 1:size(Users, 1)
    for m = 1:size(Movies, 2)
         if(X(u, m) ~= nil)     
            rating = average + Users(u,:) * Movies(:,m);
            %rating
            error = (X(u, m) - rating);
            Movies(:,m) = Movies(:,m) + learningRate *( error * Users(u,:)' - regularizer * Movies(:,m));
            Users(u,:) = Users(u,:) + learningRate *( error * Movies(:,m)' - regularizer * Users(u,:));
         end  
    end
end
end

for i = 1:size(X_pred,1)
    for j= 1:size(X_pred,2)
        if(X(i,j) == nil)
            X_pred(i,j) = average +  Users(i,:) * Movies(:,j);
        end
    end
end
end
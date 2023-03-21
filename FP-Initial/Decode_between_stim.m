function Accuracy = Decode_Stim(A, Batch_data)

target_X = {};
Non_target_X = {};

for i = 0:Batch_data{1, 1}.total_stim-1
    target_i = (i*Batch_data{1, 1}.repetitions+1 : i*Batch_data{1, 1}.repetitions + Batch_data{1, 1}.repetitions);
    non_target_i = (1:numel(A(:,1)));
    non_target_i(target_i) = [];
    cumMean_A(i+1, :) = movmean(A(i+1,:), 20);
    temp_non_target = cumMean_A(non_target_i, :);
    target_X{i+1,1} = transpose(downsample(transpose(cumMean_A(target_i, :)), 40));
    random_non_target = randi(numel(non_target_i), Batch_data{1,1}.repetitions,1);
    Non_target_X{i+1,1} = transpose(downsample(transpose(temp_non_target(random_non_target, :)), 40));    
end

Accuracy = {};
for i = 1:numel(target_X)
    Xi = [target_X{i,1};Non_target_X{i,1}];

    %Xi = test_dataset;
    [H L] = size(Xi);
    Y = [zeros(H/2, 1); ones(H/2,1)];
    
    % binary classification
    % Divide data into train and test datasets
    
    rand_num = randperm(size(Xi,1));
    X_train = Xi(rand_num(1:round(0.8*length(rand_num))),:);
    y_train = Y(rand_num(1:round(0.8*length(rand_num))),:);
    
    X_test = Xi(rand_num(round(0.8*length(rand_num))+1:end),:);
    y_test = Y(rand_num(round(0.8*length(rand_num))+1:end),:);
    %% CV partition
    
    c = cvpartition(y_train,'k',10);
    %% feature selection
    
    opts = statset('display','iter');
    classf = @(train_data, train_labels, test_data, test_labels)...
        sum(predict(fitcsvm(train_data, train_labels,'KernelFunction','rbf'), test_data) ~= test_labels);
    
    [fs, history] = sequentialfs(classf, X_train, y_train, 'cv', c, 'options', opts,'nfeatures', 2);
    %% Best hyperparameter
    X_train_w_best_feature = [];
    for i = 1:sum(fs)
        for ii = 1:height(X_train)
            X_train_w_best_feature(ii, i) = X_train(ii, mean(fs(i)-2:fs(i)+2));
        end
    end
    
    Mdl = fitcsvm(X_train_w_best_feature, y_train,'KernelFunction','rbf','OptimizeHyperparameters','auto',...
          'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
          'expected-improvement-plus','ShowPlots',false)); % Bayes' Optimization 
    
    
    CVMdl = crossval(Mdl);
    oofLabel = kfoldPredict(CVMdl);
    Loss = kfoldLoss(CVMdl, 'mode','individual');
    Accuracy{i,1} = (1-Loss) .*100;
end


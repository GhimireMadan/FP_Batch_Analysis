function Accuracy = Decode_between_stim(X_target, X_nonTarget, total_target)

Accuracy = [];

Xi = [X_target;X_nonTarget];

%Xi = test_dataset;
[H L] = size(Xi);
Y = [zeros(H/2, 1); ones(H/2,1)];

% binary classification
% Divide data into train and test datasets

rand_num = randperm(size(Xi,1));
X = Xi(rand_num, :);
Y = Y(rand_num,:);

% X_train = Xi(rand_num(1:round(0.8*length(rand_num))),:);
% y_train = Y(rand_num(1:round(0.8*length(rand_num))),:);
% 
% X_test = Xi(rand_num(round(0.8*length(rand_num))+1:end),:);
% y_test = Y(rand_num(round(0.8*length(rand_num))+1:end),:);
%% CV partition

c = cvpartition(Y,'k',10);
%% feature selection

opts = statset('display','iter');
classf = @(X, Y, test_data, test_labels)...
    sum(predict(fitcsvm(X, Y,'KernelFunction','rbf'), test_data) ~= test_labels);

[fs, history] = sequentialfs(classf, X(:, 3:end-3), Y, 'cv', c, 'options', opts,'nfeatures', 2);
%% Best hyperparameter
X_train_w_best_feature = [];
for i = 1:sum(fs)
    fs_idx = find(fs == 1);
    for ii = 1:height(X)
        if fs_idx(i) <=2
            X_train_w_best_feature(ii, i) = mean(X(ii, 1:fs_idx(i)+2));
        if fs_idx(i) >=49            
            X_train_w_best_feature(ii, i) = mean(X(ii, fs_idx(i)-2:end));
        else
        X_train_w_best_feature(ii, i) = mean(X(ii, (fs_idx(i)-2:fs_idx(i)+2)));
        end
    end
end

Mdl = fitcsvm(X, Y,'KernelFunction','rbf','OptimizeHyperparameters','auto',...
      'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
      'expected-improvement-plus','ShowPlots',false)); % Bayes' Optimization 


CVMdl = crossval(Mdl);
oofLabel = kfoldPredict(CVMdl);
Loss = kfoldLoss(CVMdl, 'mode','individual');
Accuracy = (1-Loss) .*100;

%%


% X_test_w_best_feature = [];
% for i = 1:sum(fs)
%     fs_idx = find(fs == 1);
%     for ii = 1:height(X_test)
%         X_test_w_best_feature(ii, i) = mean(X_test(ii, (fs_idx(i)-2:fs_idx(i)+2)));
%     end
% end
% 
% test_accuracy_for_iter = sum((predict(Mdl,X_test_w_best_feature) == y_test))/length(y_test)*100



%% hyperplane

% figure;
% %subplot(3, 3 , total_target);
% hgscatter = gscatter(X_train_w_best_feature(:,1),X_train_w_best_feature(:,2), Y, 'br');
% hold on;
% h_sv=plot(Mdl.SupportVectors(:,1),Mdl.SupportVectors(:,2),'ko','markersize',8);
% 
% 
% % test set
% 
% %gscatter(X_test_w_best_feature(:,1),X_test_w_best_feature(:,2),y_test,'br','xx')
% 
% %% decision plane
% XLIMs = get(gca,'xlim');
% YLIMs = get(gca,'ylim');
% [xp,yp] = meshgrid([XLIMs(1):0.01:XLIMs(2)],[YLIMs(1):0.01:YLIMs(2)]);
% dd = [xp(:), yp(:)];
% pred_mesh = predict(Mdl, dd);
% redcolor = [1, 0.8, 0.8];
% bluecolor = [0.8, 0.8, 1];
% pos = find(pred_mesh == 1);
% h1 = plot(dd(pos,1), dd(pos,2),'s','color',redcolor,'Markersize',5,'MarkerEdgeColor',redcolor,'MarkerFaceColor',redcolor);
% pos = find(pred_mesh == 2);
% h2 = plot(dd(pos,1), dd(pos,2),'s','color',bluecolor,'Markersize',5,'MarkerEdgeColor',bluecolor,'MarkerFaceColor',bluecolor);
% uistack(h1,'bottom');
% uistack(h2,'bottom');
% legend([hgscatter;h_sv],{'Actx','MGB','support vectors'})
end
clc;

%% preparing dataset
% dataset_A = Pure_tone_resp_A;
% dataset_C = Pure_tone_resp_C;
dataset_A = Batch_data{1, 1}.dFF_sorted_A(:, 501:2500, :);
dataset_C = Batch_data{1, 1}.dFF_sorted_C(:, 501:2500, :);

%% split dataset into target and non-target dataset. Need to do for different channels separately.
% Channel A

target_A_X = {};
Non_target_A_X = {};

for i = 0:Batch_data{1, 1}.total_stim-1
    cumMean_A = [];
    for ii = 1:height(dataset_A)
        cumMean_A(ii,:) = movmean(dataset_A(ii,:), 20);
    end
    target_i = (i*Batch_data{1, 1}.repetitions+1 : i*Batch_data{1, 1}.repetitions + Batch_data{1, 1}.repetitions);
    non_target_i = (1:numel(cumMean_A(:,1)));
    non_target_i(target_i) = [];
    temp_non_target = cumMean_A(non_target_i, :);
    target_A_X{i+1,1} = transpose(downsample(transpose(cumMean_A(target_i, :)), 40));
    random_non_target = randi(numel(non_target_i), Batch_data{1,1}.repetitions,1);
    Non_target_A_X{i+1,1} = transpose(downsample(transpose(temp_non_target(random_non_target, :)), 40));    
end

% Channel C

target_C_X = {};
Non_target_C_X = {};

for i = 0:Batch_data{1, 1}.total_stim-1
    cumMean_C = [];
    for ii = 1:height(dataset_C)
        cumMean_C(ii,:) = movmean(dataset_C(ii,:), 20);
    end
    target_i1 = (i*Batch_data{1, 1}.repetitions+1 : i*Batch_data{1, 1}.repetitions + Batch_data{1, 1}.repetitions);
    non_target_i1 = (1:numel(cumMean_C(:,1)));
    non_target_i1(target_i1) = [];
    temp_non_target1 = cumMean_C(non_target_i1, :);
    target_C_X{i+1,1} = transpose(downsample(transpose(cumMean_C(target_i1, :)), 40));
    random_non_target1 = randi(numel(non_target_i1), Batch_data{1,1}.repetitions,1);
    Non_target_C_X{i+1,1} = transpose(downsample(transpose(temp_non_target1(random_non_target1, :)), 40));    
end

%% calculate coding accuracy between target and non target stimulus.

Accuracy = [];
for total_target = 1:numel(target_A_X)
    Accuracy(:, total_target) = Decode_between_stim(target_A_X{i,1}, target_C_X{i,1}, total_target);
end

mean(Accuracy, 1)



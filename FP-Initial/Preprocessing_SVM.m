clc;

%%%% preparing dataset
% dataset_A = Pure_tone_resp_A;
% dataset_C = Pure_tone_resp_C;
dataset_A = Batch_data{1, 1}.dFF_sorted_A(:, 501:2500, :);
dataset_C = Batch_data{1, 1}.dFF_sorted_C(:, 501:2500, :);

%%

target_A_X = {};
Non_target_A_X = {};

for i = 0:Batch_data{1, 1}.total_stim-1
    target_i = (i*Batch_data{1, 1}.repetitions+1 : i*Batch_data{1, 1}.repetitions + Batch_data{1, 1}.repetitions);
    non_target_i = (1:numel(dataset_A(:,1)));
    non_target_i(target_i) = [];
    temp_non_target = dataset_A(non_target_i, :);
    target_A_X{i+1,1} = transpose(downsample(transpose(dataset_A(target_i, :)), 40));
    random_non_target = randi(numel(non_target_i), Batch_data{1,1}.repetitions,1);
    Non_target_A_X{i+1,1} = transpose(downsample(transpose(temp_non_target(random_non_target, :)), 40));    
end


dataset_C = Batch_data{1, 1}.dFF_sorted_C(:, 501:2500, :);
target_C_X = {};
Non_target_C_X = {};

for i = 0:Batch_data{1, 1}.total_stim-1
    target_i = (i*Batch_data{1, 1}.repetitions+1 : i*Batch_data{1, 1}.repetitions + Batch_data{1, 1}.repetitions);
    non_target_i = (1:numel(dataset_C(:,1)));
    non_target_i(target_i) = [];
    temp_non_target = dataset_C(non_target_i, :);
    target_C_X{i+1,1} = transpose(downsample(transpose(dataset_C(target_i, :)), 40));
    random_non_target = randi(numel(non_target_i), Batch_data{1,1}.repetitions,1);
    Non_target_C_X{i+1,1} = transpose(downsample(transpose(temp_non_target(random_non_target, :)), 40));    
end

downsampled_dataset_A = [];
for i = 1:height(dataset_A)
    %cumMean_A(i, :) = movmean(dataset_A(i,:), 20);
    downsampled_dataset_A(i,:) = downsample(dataset_A(i,:), 40);
end

downsampled_dataset_C = [];
for i = 1:height(dataset_C)
    %cumMean_C(i, :) = movmean(dataset_C(i,:), 20);
    downsampled_dataset_C(i,:) = downsample(dataset_C(i,:), 40);
end
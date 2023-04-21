clc
clear all
%% Choose a spreadsheet
% first make a variable with path to your spreadsheet containing your
% experimental information
addpath('./utils/')
%addpath(genpath('W:\Code\Madan'))

% These are the example inputs, only change the values in the below 5 lines
% to the desired experimental setup. 
% Setting the right animal ID, run and date of experiment is very
% important. any mistake here would give an error
input.AnimalID = '669'; 
input.Run = 'Run 1';
input.Date_of_experiment = 42123;
input.spreadsheet = 'W:\Data\Fiber_Photometry\DataPath.xlsx'; % This spreadsheet would provide the path of the data.
Batch_data = [];
input.data_window = [-1 5]; % Data window depends on the type of parameter used. two values are required, 0 is the time of trigger, -1 gives 1 second of baseline perion and the second value is the total duration to be collected for each trial.
sampling_rate = 1017; % Only change if your sampling rate is different 
baseline_window = abs(min(input.data_window)*1017); %baseline window is calculated based on the data window
response_time = (baseline_window + 1):baseline_window + 500; % provides the response window after stimulus and is useful for FRA only
allign_by = 'ToTr'; %It alligns the data based on the trigger source

%% selects animals based on the above mentioned criteria

opts = detectImportOptions(input.spreadsheet);
opts.VariableNamingRule = 'Preserve';
opts = setvartype(opts,{'AnimalID'},'char');

input.data_matrix = readtable(input.spreadsheet, opts);
input.data_matrix = input.data_matrix(input.data_matrix.Exclude ~= 1,:);

%data_matrix = readmatrix(input.spreadsheet, 'OutputType', 'string', "TreatAsMissing", 'NAN');
%input.data_matrix = readtable(input.spreadsheet, 'VariableNamingRule','preserve');
input.Animal = find(strcmp(input.data_matrix.("Animal ID"), input.AnimalID) == 1);
input.RunID = find(strcmp(input.data_matrix.("Run"), input.Run) == 1);

input.Date = ismember(input.data_matrix.('Date of experiment'), input.Date_of_experiment);
% Extract the elements of a at those indexes.
input.Date_idx = find((input.Date) == 1);


input.data_spreadsheet = input.data_matrix(intersect(intersect(input.Animal, input.Date_idx, "stable"), input.RunID, 'stable'), :);

if isempty(input.data_spreadsheet) == 1
    error('Check animal ID, Run and Date')
end

% Preprocess the selected data and alligns with the stimulus files and
% generates a summary data

for i = 1:numel(input.data_spreadsheet(:,1))
    date(i,1) = input.Date_of_experiment(i);
    % Use the approperiate function to obtain data
    %Batch_data{i,1} = FRA_preprocessing(input.data_spreadsheet, input.data_window, i, response_time);
    Batch_data{i,1} = FP_Initial(input.data_spreadsheet, input.data_window, i, allign_by);
    %Batch_data{i,1} = Initial_Isolation(input.data_spreadsheet, input.data_window, i, allign_by);
end
fprintf('Complete!')

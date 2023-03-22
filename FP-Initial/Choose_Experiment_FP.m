clc
clear all
%% Choose a spreadsheet
% first make a variable with path to your spreadsheet containing your
% experimental information
addpath('./utils/')

% These are the example inputs, only change the values in the below 5 lines
% to the desired experimental setup. Currently, this code is set up to run
% FRA and SAM noise parameters. Future patch is necessary to run further
% parameters
input.parameter_used = 'RLF'; % very important to set the parameter files. Currently it works with 'FRA', 'RLF', and 'sAM'
input.AnimalID = '607';
input.Run = 'Run 1';
input.Date_of_experiment = [31423];
input.spreadsheet = 'W:\Data\Fiber_Photometry\DataPath.xlsx';
Batch_data = [];
input.data_window = [-1 4];
sampling_rate = 1017;
baseline_window = abs(min(input.data_window)*1017);
response_time = (baseline_window + 1):baseline_window + 500;
allign_by = 'ToTr';

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

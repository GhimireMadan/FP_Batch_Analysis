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
input.AnimalID = '585';
input.Date_of_experiment = [20723];
input.spreadsheet = 'W:\Data\Fiber_Photometry\DataPath';
Batch_data = [];
input.data_window = [-1 5];
sampling_rate = 1017;

%% selects animals based on the above mentioned criteria
input.data_matrix = readtable(input.spreadsheet, 'TextType', 'char','VariableNamingRule','preserve');
input.Animal = find(strcmp(input.data_matrix.("Animal ID"), input.AnimalID) == 1);

input.Date = ismember(input.data_matrix.('Date of experiment'), input.Date_of_experiment);
% Extract the elements of a at those indexes.
input.Date_idx = find(input.Date);


input.data_spreadsheet = input.data_matrix(intersect(input.Animal, input.Date_idx), :);

% Preprocess the selected data and alligns with the stimulus files and
% generates a summary data

for i = 1:numel(input.data_spreadsheet(:,1))
    date(i,1) = input.Date_of_experiment(i);
    Batch_data{i,1} = FP_Batch_Analysis(input.data_spreadsheet, input.data_window, i);
end


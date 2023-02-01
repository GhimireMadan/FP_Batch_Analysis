clc
clear all
%% Choose a spreadsheet
% first make a variable with path to your spreadsheet containing your
% experimental information
addpath('./utils/')
input.AnimalID = '585A';
input.Date_of_experiment = [10923, 11023, 11323, 11723, 11723, 11823, 11923, 12723, 13023];
input.spreadsheet = 'W:\Data\Fiber_Photometry\DataPath';

%
input.data_matrix = readtable(input.spreadsheet, 'TextType', 'char','VariableNamingRule','preserve');
input.Animal = find(strcmp(input.data_matrix.("Animal ID"), input.AnimalID) == 1);

input.Date = ismember(input.data_matrix.('Date of experiment'), input.Date_of_experiment);
% Extract the elements of a at those indexes.
input.Date_idx = find(input.Date);


input.data_spreadsheet = input.data_matrix(intersect(input.Animal, input.Date_idx), :);

Batch_data = [];
input.data_window = [-1 4];

for i = 1:numel(input.data_spreadsheet(:,1))
    date(i,1) = input.Date_of_experiment(i);
    Batch_data{i,1} = FP_Batch_Analysis(input.data_spreadsheet, input.data_window, i);
end


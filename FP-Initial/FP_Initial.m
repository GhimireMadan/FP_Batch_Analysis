function d = BrandNew_Improved_Code(data_spreadsheet, data_window, i, allign_by)

d.synapse_path = data_spreadsheet.("Synapse Path"){i,1};
d.Tosca_path = data_spreadsheet.("Tosca Path"){i,1};


% Extract data for desired time frame. It takes the data window from the
% input and filters the data around the trials.
data = TDTbin2mat(d.synapse_path);
d.Samples_per_time = 1017;
baseline_window = abs(min(data_window)*1017);
Total_time = max(data_window);
%response_time = baseline_window:baseline_window + 500;
% Extract data for desired time frame. This extracts data 1 second before
data = TDTfilter(data, allign_by, 'TIME', data_window);
d.time = min(data_window):(max(data_window)-1);
x465A = transpose(data.streams.x465A.filtered);
isobestic_A = transpose(data.streams.x405A.filtered);
x465A = cellfun(@(x) x(1:d.Samples_per_time*Total_time), x465A,'UniformOutput',false);
isobestic_A = cellfun(@(x) x(1:d.Samples_per_time*Total_time), isobestic_A,'UniformOutput',false);
d.dFF_A = [];
for i = 1:numel(x465A)
    baseline_corrected_dum(i,:) = x465A{i,1} - isobestic_A{i,1};
    d.dFF_A(i,:) = ((baseline_corrected_dum(i,:)-mean(baseline_corrected_dum(i, 1:baseline_window)))/mean(baseline_corrected_dum(i, 1:baseline_window)))*100;
end
% z-score to normalize activity over all trials
%bin.data_normalized = zscore(bin.baseline_corrected, 0,'all');


% Extract trial information from Tosca

[d.Trial_id, ~]  = tosca_read_run(d.Tosca_path);
Trial_Results = {};
for i = 1:numel(d.Trial_id)
    Trial_Results{i,1} = d.Trial_id{1, i}.Result;
end

Trial_number = [];
for i = 1:numel(d.Trial_id)
    Trial_number(i, 1) = d.Trial_id{1, i}.trial;
end
trial_count = max(Trial_number);
d.total_stim = numel(unique(Trial_number));
d.repetitions = floor(numel(Trial_number)/trial_count);
trials2use = 1:(trial_count*d.repetitions);
d.total_trial = numel(trials2use);

%total_rep = floor(numel(trials2use)/numel(unique(Inner_Sequence)));

% find trials with error
aa = strfind(Trial_Results, 'Error');
Error_idx = find(not(cellfun('isempty',aa)));

if isfield(data.streams, 'x465B') ==1
   x465B = transpose(data.streams.x465C.filtered);
   x465B = cellfun(@(x) x(1:d.Samples_per_time*Total_time), x465B,'UniformOutput',false);
   isobestic_B = transpose(data.streams.x405C.filtered);
   isobestic_B = cellfun(@(x) x(1:d.Samples_per_time*Total_time), isobestic_B,'UniformOutput',false);

   d.dFF_B = [];

    for i = 1:numel(x465B)
        baseline_corrected_dum1(i,:) = x465B{i,1} - isobestic_B{i,1};
        d.dFF_B(i,:) = ((baseline_corrected_dum1(i,:)-mean(baseline_corrected_dum1(i, 1:baseline_window)))/mean(baseline_corrected_dum(i, 1:baseline_window)))*100;
    end

end

if isfield(data.streams, 'x465C') ==1
   x465C = transpose(data.streams.x465C.filtered);
   x465C = cellfun(@(x) x(1:d.Samples_per_time*Total_time), x465C,'UniformOutput',false);
   isobestic_C = transpose(data.streams.x405C.filtered);
   isobestic_C = cellfun(@(x) x(1:d.Samples_per_time*Total_time), isobestic_C,'UniformOutput',false);

   d.dFF_C = [];

    for i = 1:numel(x465C)
        baseline_corrected_dum1(i,:) = x465C{i,1} - isobestic_C{i,1};
        d.dFF_C(i,:) = ((baseline_corrected_dum1(i,:)-mean(baseline_corrected_dum1(i, 1:baseline_window)))/mean(baseline_corrected_dum(i, 1:baseline_window)))*100;
    end

end

if isfield(data.streams, 'x465D') ==1
   x465D = transpose(data.streams.x465C.filtered);
   x465D = cellfun(@(x) x(1:d.Samples_per_time*Total_time), x465D,'UniformOutput',false);
   isobestic_D = transpose(data.streams.x405C.filtered);
   isobestic_D = cellfun(@(x) x(1:d.Samples_per_time*Total_time), isobestic_D,'UniformOutput',false);

   d.dFF_D = [];

    for i = 1:numel(x465D)
        baseline_corrected_dum1(i,:) = x465D{i,1} - isobestic_D{i,1};
        d.dFF_D(i,:) = ((baseline_corrected_dum1(i,:)-mean(baseline_corrected_dum1(i, 1:baseline_window)))/mean(baseline_corrected_dum(i, 1:baseline_window)))*100;
    end

end


% sort data by trials # Frequency
if isfield(d.Trial_id{1, 1}, 'Start') ==1
    field_list = get_fieldnames(d.Trial_id{1, 1}.Start);
    field_list = regexprep(field_list, '\.$', '');
    d.field_list = field_list;
    %
    Stim_ID = [];
    for idiot= 1:numel(field_list)
        tmpstr = field_list{1, idiot};
        splittmpstr = split(tmpstr, '.');
        numsubstrs = length(splittmpstr);
        for i = 1:numel(d.Trial_id)
            temp1 = d.Trial_id{1,i}.Start;
            for iii = 1:numsubstrs
                temp2 = temp1.(splittmpstr{iii});
                temp1 = temp2;
            end
            Stim_ID(i,idiot) = temp2;
        end
    end
    
    %Stim_ID = Stim_ID;
    Stim_ID(Error_idx, :) = [];
    d.Inner_idx = Stim_ID(:, 1);
    d.Inner_sequence = unique(d.Inner_idx);
    if numel(Stim_ID(1,:)) == 2
        d.Outer_Idx = Stim_ID(:, 2);
        d.Outer_sequence = unique(d.Outer_Idx);
        [d.Stim_ID_sorted, d.sorted_idx] = sortrows(Stim_ID, [2, 1]);
    else
      [Stim_ID_sorted, d.sorted_idx] = sort(Stim_ID); 
    end
    
    
    d.dFF_sorted_A = d.dFF_A(d.sorted_idx, :);
    d.dFF_A_sorted_innerTOouter = permute(reshape(d.dFF_sorted_A', [], d.repetitions, trial_count),[2,1,3]);
    d.mean_A = transpose(reshape(mean(d.dFF_A_sorted_innerTOouter), [], trial_count));
    d.std_A = transpose(reshape(std(d.dFF_A_sorted_innerTOouter), [], trial_count));
    d.SEM_A = d.std_A./ sqrt(d.repetitions);
    
   
    d.dFF_B(Error_idx, :) = [];
    d.dFF_sorted_B = d.dFF_B(d.sorted_idx, :);
    d.dFF_B_sorted_innerTOouter = permute(reshape(d.dFF_sorted_B', [], repetitions, trial_count),[2,1,3]);
    d.mean_B = transpose(reshape(mean(d.dFF_B_sorted_innerTOouter), [], trial_count));
    d.std_B = transpose(reshape(std(d.dFF_B_sorted_innerTOouter), [], trial_count));
    d.SEM_B = d.std_B./ sqrt(d.repetitions);

    d.dFF_C(Error_idx, :) = [];
    d.dFF_sorted_C = d.dFF_C(d.sorted_idx, :);
    d.dFF_C_sorted_innerTOouter = permute(reshape(d.dFF_sorted_C', [], d.repetitions, trial_count),[2,1,3]);
    d.mean_C = transpose(reshape(mean(d.dFF_C_sorted_innerTOouter), [], trial_count));
    d.std_C = transpose(reshape(std(d.dFF_C_sorted_innerTOouter), [], trial_count));
    d.SEM_C = d.std_C./ sqrt(d.repetitions);

    d.dFF_D(Error_idx, :) = [];
    d.dFF_sorted_D = d.dFF_D(d.sorted_idx, :);
    d.dFF_D_sorted_innerTOouter = permute(reshape(d.dFF_sorted_D', [], repetitions, trial_count),[2,1,3]);
    d.mean_D = transpose(reshape(mean(d.dFF_D_sorted_innerTOouter), [], trial_count));
    d.std_D = transpose(reshape(std(d.dFF_D_sorted_innerTOouter), [], trial_count));
    d.SEM_D = d.std_D./ sqrt(d.repetitions)


end


end
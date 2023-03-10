function d = FP_Batch_Analysis(data_spreadsheet, data_window, i) 

d.synapse_path = data_spreadsheet.("Synapse Path"){i,1};
d.Tosca_path = data_spreadsheet.("Tosca Path"){i,1};

% Extract data for desired time frame. It takes the data window from the
% input and filters the data around the trials.
data = TDTbin2mat(d.synapse_path);
d.Samples_per_time = 1017;
baseline_window = abs(min(data_window)*1017);
Total_time = max(data_window);
% Extract data for desired time frame. This extracts data 1 second before
data = TDTfilter(data, 'ToTr', 'TIME', data_window);
d.time = min(data_window):(max(data_window)-1);
x465A = transpose(data.streams.x465A.filtered);
isobestic_A = transpose(data.streams.x405A.filtered);
x465A = cellfun(@(x) x(1:d.Samples_per_time*Total_time), x465A,'UniformOutput',false);
isobestic_A = cellfun(@(x) x(1:d.Samples_per_time*Total_time), isobestic_A,'UniformOutput',false);
d.baseline_corrected_A = [];
for i = 1:numel(x465A)
    baseline_corrected_dum(i,:) = x465A{i,1} - isobestic_A{i,1};
    d.baseline_corrected_A(i,:) = ((baseline_corrected_dum(i,:)-mean(baseline_corrected_dum(i, 1:baseline_window)))/mean(baseline_corrected_dum(i, 1:baseline_window)))*100;
end

if isfield(data.streams, 'x465C') ==1
   x465C = transpose(data.streams.x465C.filtered);
   x465C = cellfun(@(x) x(1:d.Samples_per_time*Total_time), x465C,'UniformOutput',false);
   isobestic_C = transpose(data.streams.x405C.filtered);
   isobestic_C = cellfun(@(x) x(1:d.Samples_per_time*Total_time), isobestic_C,'UniformOutput',false);

   d.baseline_corrected_C = [];

    for i = 1:numel(x465C)
        baseline_corrected_dum1(i,:) = x465C{i,1} - isobestic_C{i,1};
        d.baseline_corrected_C(i,:) = ((baseline_corrected_dum1(i,:)-mean(baseline_corrected_dum1(i, 1:baseline_window)))/mean(baseline_corrected_dum(i, 1:baseline_window)))*100;
    end
end
 
% Correct motion artifact and baseline by removing the isobestic activity and baseline
% correction

clear baseline_corrected_dum;
% z-score to normalize activity over all trials
%bin.data_normalized = zscore(bin.baseline_corrected, 0,'all');

% Extract trial information from Tosca

[d.Trial_id, ~]  = tosca_read_run(d.Tosca_path);
Trial_Results = {};
for i = 1:numel(d.Trial_id)
    Trial_Results{i,1} = d.Trial_id{1, i}.Result;
end

Trial_number = {};
for i = 1:numel(d.Trial_id)
    Trial_number{i,1} = d.Trial_id{1, i}.trial;
end
trial_count = max(cell2mat(Trial_number));
repetitions = floor(numel(cell2mat(Trial_number))/trial_count);
trials2use = 1:(trial_count*repetitions);

% find trials with error
aa = strfind(Trial_Results, 'Error');
Error_idx = find(not(cellfun('isempty',aa)));

%remove trials with errors
d.baseline_corrected_A(Error_idx, :) = [];
if isfield(data.streams, 'x465C') ==1
    d.baseline_corrected_C(Error_idx, :) = [];
end

%if d.trial_id == 

if isfield(d.Trial_id{1, 1}.Start, 'Tone') ==1

    % sort data by trials # Frequency
    Freq_info = [];
    for i = 1:numel(d.Trial_id)
        Freq_info(i,1) = d.Trial_id{1, i}.Start.Tone.Tone.Frequency_kHz;
    end
    total_rep = floor(numel(trials2use)/numel(unique(Freq_info)));
    
    d.total_freq = unique(Freq_info);
    Freq_info(Error_idx, :) = [];
    Freq_info = Freq_info(1:numel(d.total_freq)*total_rep);
    
    [Trial, Trial_idx] = sort(Freq_info);
    sorted_dataFreq_A = d.baseline_corrected_A(Trial_idx, :);
    if isfield(data.streams, 'x465C') ==1
        sorted_dataFreq_C = d.baseline_corrected_C(Trial_idx, :);
    end
        
    Amplitude_info = [];
    for i = 1:numel(d.Trial_id)
        Amplitude_info(i,1) = d.Trial_id{1, i}.Start.Tone.Level.dB_SPL;
    end
    Amplitude_info(Error_idx, :) = [];
    Amplitude_info = Amplitude_info(1:numel(d.total_freq)*total_rep);    

    
    int_data_A = {};
    int_data_C = {};
    for i = 1:numel(d.total_freq)
        int_data_A{i,1} = sorted_dataFreq_A((i-1)*total_rep+1:i*total_rep, :);
            if isfield(data.streams, 'x465C') ==1
                int_data_C{i,1} = sorted_dataFreq_C((i-1)*total_rep+1:i*total_rep, :);
            end
        
    end
    
    % Sort intensity for each frequency
    d.total_intensity = unique(Amplitude_info);
    d.Amplitude_info_sorted_by_Freq = reshape(Amplitude_info(Trial_idx), total_rep, []);
    [~, Amplitude_sort_idx] = sort(d.Amplitude_info_sorted_by_Freq);
    d.rep_per_stimuli = total_rep/ numel(unique(Amplitude_info));
    % [bin.cnt_unique, bin.unique_Freq] = hist(bin.Trial, unique(bin.Trial));
    % bin.cum_unique = cumsum(bin.cnt_unique);
    d.sorted_data_A = {};
    d.sorted_data_C = {};
    for i = 1:numel(d.total_freq)
        temp_idx = Amplitude_sort_idx(:,i);
        temp_data_A = int_data_A{i,1};
        d.sorted_data_A{i,1} = temp_data_A(temp_idx,:);
        if isfield(data.streams, 'x465C') ==1
            temp_data_C = int_data_C{i,1};
            d.sorted_data_C{i,1} = temp_data_C(temp_idx,:);
        end        
        
    end
end

if isfield(d.Trial_id{1, 1}.Start, 'Noise') ==1
    Freq_info = [];
    for i = 1:numel(d.Trial_id)
        Freq_info(i,1) = d.Trial_id{1, i}.Start.Noise.SAM.Frequency_Hz;
    end
    Freq_info(Error_idx, :) = [];
    d.total_rep = floor(numel(Freq_info)/numel(unique(Freq_info)));
    d.freq = unique(Freq_info);
    d.total_freq = numel(d.freq);
    

    %total_rep = floor(numel(trials2use)/numel(unique(Freq_info)));
    
    %d.total_freq = numel(unique(Freq_info));
    %Freq_info(Error_idx, :) = [];
    %Freq_info = Freq_info(1:numel(d.total_freq)*total_rep);
    
    [Trial, Trial_idx] = sort(Freq_info);
    sorted_dataFreq_A = d.baseline_corrected_A(Trial_idx, :);
    if isfield(data.streams, 'x465C') ==1
        sorted_dataFreq_C = d.baseline_corrected_C(Trial_idx, :);
    end
%     [sorted_Freq, Freq_idx] = sort(Freq_info);
%     sorted_A = d.baseline_corrected_A(Freq_idx, :);
%     sorted_C = d.baseline_corrected_C(Freq_idx, :);

    [r,c] = size(d.baseline_corrected_A);
    nlay  = 3;
    d.sorted_data_A   = permute(reshape(sorted_dataFreq_A',[c,d.total_rep,d.total_freq]),[2,1,3]);
    d.mean_data_A = [];
    for i = 1: d.total_freq
        d.mean_data_A(i, :) = mean(d.sorted_data_A(:,:,i), 1);
        d.std_A(i,:) = std(d.sorted_data_A(:,:,i), 1); 
        d.SEM_A(i,:) = d.std_A(i,:)/sqrt(d.total_rep);
    end

        if isfield(data.streams, 'x465C') ==1
            d.sorted_data_C   = permute(reshape(sorted_dataFreq_A',[c,d.total_rep,d.total_freq]),[2,1,3]);
            d.mean_data_C = [];
            for i = 1: d.total_freq
                d.mean_data_C(i, :) = mean(d.sorted_data_C(:,:,i), 1);
                d.std_C(i,:) = std(d.sorted_data_C(:,:,i), 1);
                d.SEM_C(i,:) = d.std_C(i,:)/sqrt(d.total_rep);
            end 
        end
    
end
% Create a final matrix. The data are organized by freqency trials in
% ascending order of intensity (x-y) and frequency (z)
%d.final_mat = permute(reshape(cell2mat(d.sorted_data_final), height(d.sorted_data_final{1}),length(d.sorted_data_final{1}),[]),[1 2 3]);

%

%% Response map
if isfield(d.Trial_id{1, 1}.Start, 'Tone') ==1
    Response_Map_A = {};
    Response_Map_A = {};
    for i = 1:numel(d.total_freq)
        Response_Map_A{1,i} = mean(d.sorted_data_A{i,1}(:, 1000:2000), 2); 
        if isfield(data.streams, 'x465C') ==1
            Response_Map_C{1,i} = mean(d.sorted_data_C{i,1}(:, 1000:2000), 2);
        end
    end
    d.Response_Map_per_trial_A = flip(cell2mat(Response_Map_A));
    
    if isfield(data.streams, 'x465C') ==1
        d.Response_Map_per_trial_C = flip(cell2mat(Response_Map_C));
    end
    
    total_amp = numel(unique(Amplitude_info));
    
    
    d.Response_Map_mean_A = [];
    d.Response_Map_mean_C = [];
    for i = 1:numel(d.Response_Map_per_trial_A(:,1))
        for j = (1:total_amp)-1
            p = d.Response_Map_per_trial_A((j*d.rep_per_stimuli)+1:(j+1)*d.rep_per_stimuli, :);
            d.Response_Map_mean_A(j+1,:) = mean(p);
            
            if isfield(data.streams, 'x465C') ==1
                q = d.Response_Map_per_trial_C((j*d.rep_per_stimuli)+1:(j+1)*d.rep_per_stimuli, :);
                d.Response_Map_mean_C(j+1,:) = mean(q);
            end
        end
    end

    %d.org_meanResp_allTrials =reshape(d.Response_Map_per_trial, d.rep_per_stimuli, length(d.Response_Map_mean), []);
    
end
end
















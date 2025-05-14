% This script converts behavioral data from CSV files to MATLAB mat files
% written by TAO Ran @ HHB714   
% Initiated 2025-04-08
% Last updated 2025-04-08

% Prepare environment
clear;clc;
spm('defaults', 'FMRI');
% Get SPM path
SPMFolder = fileparts(which('spm'));
if isempty(SPMFolder)
    error('SPM not found in MATLAB path. Please add SPM to your MATLAB path.');
end

% Change this variable to the participant number you want to process

for iP = [101:116]
    thisParticipant = iP;
Participant = ['sub-',num2str(thisParticipant)];

% Set up directory paths
CodeFolder = pwd;
BIDSFolder = fileparts(CodeFolder);
RawFolder = [BIDSFolder, filesep, 'rawdata'];
SourceFolder = [BIDSFolder, filesep, 'sourcedata'];
FiguresFolder = [BIDSFolder, filesep, 'figures'];
ParticipantNiftiFolder = fullfile(SourceFolder, Participant, 'MRI');

TaskSessions = {'TASK_A_1','TASK_A_2','TASK_B_iden','TASK_B_sem'};

%% Process TASK_A_1
% Read timing information from CSV file
timing_file = fullfile(pwd, 'TA1_use_Time.csv');
if exist(timing_file, 'file')
    timing_data = readtable(timing_file);
else
    error('Timing file not found: %s', timing_file);
end

% Get timing information for this participant
participant_row = timing_data.Subject == thisParticipant;
if ~any(participant_row)
    error('Subject %d not found in timing file', thisParticipant);
end

% Extract timing information
TASK_A_1_Age_onset = timing_data.Age(participant_row);
TASK_A_1_Tone_onset = timing_data.Tone(participant_row);
TASK_A_1_Gender_onset = timing_data.Gender(participant_row);
TASK_A_1_Accent_onset = timing_data.Accent(participant_row);
TASK_A_1_Semantic_onset = [timing_data.Sem1(participant_row), timing_data.Sem2(participant_row)];

% Prepare variables for multicond.mat
names = {'Accent','Age', 'Gender',  'Semantics','Tone'};
onsets = {TASK_A_1_Accent_onset, TASK_A_1_Age_onset, TASK_A_1_Gender_onset, TASK_A_1_Semantic_onset, TASK_A_1_Tone_onset};
durations = {56, 56, 56, 56, 56};

% Save multicond.mat
output_dir = fullfile(SourceFolder, Participant, 'fMRI', 'TASK_A_1');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
save(fullfile(output_dir, 'multicond.mat'), 'names', 'onsets', 'durations'); 

%% Process TASK_A_2
% Read timing information from CSV file
timing_file_TA2 = fullfile(pwd, 'TA2_use_Time.csv');
if exist(timing_file_TA2, 'file')
    timing_data_TA2 = readtable(timing_file_TA2);
else
    error('Timing file not found: %s', timing_file_TA2);
end

% Get timing information for this participant
participant_row_TA2 = timing_data_TA2.Subject == thisParticipant;
if ~any(participant_row_TA2)
    error('Subject %d not found in TA2 timing file', thisParticipant);
end

% Extract timing information
TASK_A_2_Age_onset = timing_data_TA2.Age1(participant_row_TA2);
TASK_A_2_Tone_onset = timing_data_TA2.Tone1(participant_row_TA2);
TASK_A_2_Gender_onset = timing_data_TA2.Gender1(participant_row_TA2);
TASK_A_2_Accent_onset = timing_data_TA2.Accent1(participant_row_TA2);
TASK_A_2_Semantic_onset = [timing_data_TA2.Sem3(participant_row_TA2), timing_data_TA2.Sem4(participant_row_TA2)];

% Prepare variables for multicond.mat
names = {'Accent','Age', 'Gender',  'Semantics','Tone'};
onsets = {TASK_A_2_Accent_onset, TASK_A_2_Age_onset, TASK_A_2_Gender_onset, TASK_A_2_Semantic_onset, TASK_A_2_Tone_onset};
durations = {56, 56, 56, 56, 56};

% Save multicond.mat
output_dir = fullfile(SourceFolder, Participant, 'fMRI', 'TASK_A_2');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
save(fullfile(output_dir, 'multicond.mat'), 'names', 'onsets', 'durations'); 

%% Process TASK_B_iden
% Read timing information from Excel file
timing_file_iden = fullfile(pwd, 'Iden_use_time.xlsx');
timing_data_iden = readtable(timing_file_iden);
participant_row_iden = find(timing_data_iden.Subject == thisParticipant);

% Get column names
colNames = timing_data_iden.Properties.VariableNames;

% Extract timings for each condition
for i = 1:length(colNames)
    colName = colNames{i};
    if startsWith(colName, 'Age_No')
        TASK_B_iden_Age_No_onset = str2num(timing_data_iden{participant_row_iden, i}{1});
    elseif startsWith(colName, 'Age_Yes')
        TASK_B_iden_Age_Yes_onset = str2num(timing_data_iden{participant_row_iden, i}{1});
    elseif startsWith(colName, 'Gender_No')
        TASK_B_iden_Gender_No_onset = str2num(timing_data_iden{participant_row_iden, i}{1});
    elseif startsWith(colName, 'Gender_Yes')
        TASK_B_iden_Gender_Yes_onset = str2num(timing_data_iden{participant_row_iden, i}{1});
    end
end

% Prepare variables for multicond.mat
names = {'Age_No', 'Age_Yes', 'Gender_No', 'Gender_Yes'};
onsets = {TASK_B_iden_Age_No_onset, TASK_B_iden_Age_Yes_onset, TASK_B_iden_Gender_No_onset, TASK_B_iden_Gender_Yes_onset};
durations = {zeros(1, length(TASK_B_iden_Age_No_onset)), zeros(1, length(TASK_B_iden_Age_Yes_onset)), ...
            zeros(1, length(TASK_B_iden_Gender_No_onset)), zeros(1, length(TASK_B_iden_Gender_Yes_onset))};

% Save multicond.mat
output_dir = fullfile(SourceFolder, Participant, 'fMRI', 'TASK_B_iden');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end 
save(fullfile(output_dir, 'multicond.mat'), 'names', 'onsets', 'durations'); 

%% Process TASK_B_sem
% Read timing information from Excel file
timing_file_sem = fullfile(pwd, 'Sem_use_time.xlsx');
timing_data_sem = readtable(timing_file_sem);
participant_row_sem = find(timing_data_sem.Subject == thisParticipant);

% Get column names
colNames = timing_data_sem.Properties.VariableNames;

% Extract timings for each condition
for i = 1:length(colNames)
    colName = colNames{i};
    if strcmp(colName, 'Semantics_No')
        TASK_B_sem_Semantics_No_onset = str2num(timing_data_sem{participant_row_sem, i}{1});
    elseif strcmp(colName, 'Semantics_Yes') 
        TASK_B_sem_Semantics_Yes_onset = str2num(timing_data_sem{participant_row_sem, i}{1});
    end
end

% Prepare variables for multicond.mat
names = {'Semantics_No', 'Semantics_Yes'};
onsets = {TASK_B_sem_Semantics_No_onset, TASK_B_sem_Semantics_Yes_onset};
durations = {zeros(1, length(TASK_B_sem_Semantics_No_onset)), zeros(1, length(TASK_B_sem_Semantics_Yes_onset))};

% Save multicond.mat
output_dir = fullfile(SourceFolder, Participant, 'fMRI', 'TASK_B_sem');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
save(fullfile(output_dir, 'multicond.mat'), 'names', 'onsets', 'durations');
end
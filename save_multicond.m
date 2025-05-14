% Script to save multicond.mat file for TASK_A_1
% written by TAO Ran @ HHB714
% Initiated 2025-04-08
% Last updated 2025-04-08

% Define the condition names, values (onsets), and durations
names = {'Age', 'Tone', 'Gender', 'Accent', 'Semantics'};
values = {TASK_A_1_Age_onset, TASK_A_1_Tone_onset, TASK_A_1_Gender_onset, TASK_A_1_Accent_onset, TASK_A_1_Semantic_onset};
duration = {56, 56, 56, 56, 56};

% Create the output directory path
output_dir = fullfile('sourcedata', 'sub-102', 'fMRI', 'TASK_A_1');

% Save the variables to multicond.mat
save(fullfile(output_dir, 'multicond.mat'), 'names', 'values', 'duration'); 
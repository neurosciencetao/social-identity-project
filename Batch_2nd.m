% This script performs fMRI second-level analysis
% written by TAO Ran @ HHB714
% Initiated 2025-04-09
% Last updated 2025-04-09

% Prepare environment
clear;clc;
spm('defaults', 'FMRI');
% Get SPM path
SPMFolder = fileparts(which('spm'));
if isempty(SPMFolder)
    error('SPM not found in MATLAB path. Please add SPM to your MATLAB path.');
end

% Check if BrainNet Viewer is in path, otherwise add local copy
if isempty(which('BrainNet'))
    localBNV = fullfile(pwd, 'BrainNetViewer');
    if exist(localBNV, 'dir')
        addpath(localBNV);
        if isempty(which('BrainNet'))
            error('BrainNet Viewer not found even after adding ./BrainNetViewer. Please check your setup.');
        else
            fprintf('BrainNet Viewer loaded from local ./BrainNetViewer folder.\n');
        end
    else
        error('BrainNet Viewer not found in MATLAB path, and ./BrainNetViewer does not exist.');
    end
end

CodeFolder = pwd;
BIDSFolder = fileparts(CodeFolder);
RawFolder = [BIDSFolder, filesep, 'rawdata'];
SourceFolder = [BIDSFolder, filesep, 'sourcedata'];
DerivativesFolder = [BIDSFolder, filesep, 'derivatives'];
FiguresFolder = [BIDSFolder, filesep, 'figures'];

% Create figures folder if it doesn't exist
if ~exist(DerivativesFolder, 'dir')
    mkdir(DerivativesFolder);
end

if ~exist(FiguresFolder, 'dir')
    mkdir(FiguresFolder);
end
% Change this variable to the participant number you want to process
% Before processing, ensure the participant's raw data is in the ./rawdata/participant folder, e.g., rawdata/103
Participants = [101:116];

% Define all contrasts and their corresponding file paths
ContrastInfo = {
    % Localization task contrasts
    {'Accent', 'Localization', ['con_.*',num2str(1),'.nii'], 10},
    {'Age', 'Localization', ['con_.*',num2str(2),'.nii'], 10},
    {'Gender', 'Localization', ['con_.*',num2str(3),'.nii'], 10},
    {'Semantics', 'Localization', ['con_.*',num2str(4),'.nii'], 10},
    {'Tone', 'Localization', ['con_.*',num2str(5),'.nii'], 10},
    {'Accent-Tone', 'Localization', ['con_.*',num2str(6),'.nii'], 10},
    {'Age-Tone', 'Localization', ['con_.*',num2str(7),'.nii'], 10},
    {'Gender-Tone', 'Localization', ['con_.*',num2str(8),'.nii'], 10},
    {'Semantics-Tone', 'Localization', ['con_.*',num2str(9),'.nii'], 10},
    % {'Semantics-AgeGender', 'Localization', ['con_.*',num2str(10),'.nii'], 10},
    % Social identity interaction task contrasts
    {'Age-No-Yes', 'TASK_B_iden', 'con_0005.nii', 10},
    {'Gender-No-Yes', 'TASK_B_iden', 'con_0006.nii', 10},
    {'Social-No-Yes', 'TASK_B_iden', 'con_0007.nii', 10},
    {'Age-Yes-No', 'TASK_B_iden', 'con_0008.nii', 10},
    {'Gender-Yes-No', 'TASK_B_iden', 'con_0009.nii', 10},
    {'Social-Yes-No', 'TASK_B_iden', 'con_0010.nii', 10},
    {'Semantics-No-Yes', 'TASK_B_sem', 'con_0003.nii', 10},
    {'Semantics-Yes-No', 'TASK_B_sem', 'con_0004.nii', 10}
};

for iC = 1:length(ContrastInfo)
    contrastName = ContrastInfo{iC}{1};
    taskFolder = ContrastInfo{iC}{2};
    conFilePattern = ContrastInfo{iC}{3};
    extentThreshold = ContrastInfo{iC}{4};
    
    ContrastFolder = fullfile(DerivativesFolder, contrastName);
    if ~exist(ContrastFolder, 'dir')
        mkdir(ContrastFolder);
    end

    if exist(fullfile(ContrastFolder, 'SPM.mat'), 'file')
        delete(fullfile(ContrastFolder, 'SPM.mat'));
    end

    Scans = cell(length(Participants),1);
    for iP = 1:length(Participants)
        thisParticipant = Participants(iP);
        Participant = ['sub-',num2str(thisParticipant)];
        ParticipantConFolder = fullfile(SourceFolder, Participant, 'fMRI', taskFolder);
        
        % prepare the input files
        Scans{iP,1} = spm_select('ExtFPList', fullfile(ParticipantConFolder), conFilePattern, 1);
    end

    matlabbatch{1}.spm.stats.factorial_design.dir = {ContrastFolder};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = Scans;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = contrastName;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{4}.spm.stats.results.conspec.extent = extentThreshold;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.jpg = true;
    matlabbatch{4}.spm.stats.results.export{2}.tspm.basename = 'Threshold_001';

    save([ContrastFolder, filesep, 'second-level_', contrastName, '.mat'],"matlabbatch")
    spm_jobman('run', matlabbatch);
    
end % end of the loop for different contrasts
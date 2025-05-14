% This script performs fMRI second-level analysis
% written by TAO Ran @ HHB714
% Initiated 2025-04-09
% Last updated 2025-05-12 (with BNV integration)

% Prepare environment
clear;clc;
spm('defaults', 'FMRI');
% Get SPM path
SPMFolder = fileparts(which('spm'));
if isempty(SPMFolder)
    error('SPM not found in MATLAB path. Please add SPM to your MATLAB path.');
end

% --- BNV Integration: Get BrainNet Viewer path ---
brainnet_viewer_main_file = which('BrainNet.m');
if isempty(brainnet_viewer_main_file)
    error('BrainNet Viewer (BrainNet.m) not found in MATLAB path. Please add BrainNet Viewer to your MATLAB path.');
end
brainnet_viewer_path = fileparts(brainnet_viewer_main_file);
% addpath(brainnet_viewer_path); % BNV should already be in path if which() found it.

CodeFolder = pwd;
BIDSFolder = fileparts(CodeFolder);
RawFolder = [BIDSFolder, filesep, 'rawdata'];   
SourceFolder = [BIDSFolder, filesep, 'sourcedata'];
DerivativesFolder = [BIDSFolder, filesep, 'derivatives'];
FiguresFolder = [BIDSFolder, filesep, 'figures']; % General figures folder

grayMatterMaskFile = fullfile(CodeFolder, 'mask', 'spm_gray_matter_mask_p20.nii');
% Ensure this file exists before proceeding with the batch that uses it
if ~exist(grayMatterMaskFile, 'file')
    error('Gray matter mask file not found: %s. Please run the create_gray_matter_mask.m script first.', grayMatterMaskFile);
end

% --- BNV Integration: Define folder for BNV configuration files ---
ConfigFolder = fullfile(CodeFolder,'bnv_configs'); % Assuming you store BNV .mat option files here
if ~exist(ConfigFolder, 'dir')
    mkdir(ConfigFolder);
    fprintf('Created ConfigFolder for BNV option files: %s\n', ConfigFolder);
end

% Create derivatives and figures folders if they don't exist
if ~exist(DerivativesFolder, 'dir')
    mkdir(DerivativesFolder);
end
if ~exist(FiguresFolder, 'dir')
    mkdir(FiguresFolder);
end

Participants = [101:116];

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

% --- BNV Integration: Define BNV surface and option file ---
% For a "flattened" or "inflated" brain, use an inflated surface file.
% Check BNV's Data/SurfTemplate folder for available surfaces like:
% 'BrainMesh_ICBM152_inflated.nv', 'BrainMesh_ICBM152_smoothed.nv', or 'lh.inflated.surf.nv' + 'rh.inflated.surf.nv' (for separate hemispheres)
% If using separate L/R hemisphere surfaces, you might need to call plot_contrast_with_bnv twice or adapt the function.
% For a single whole-brain inflated view, 'BrainMesh_ICBM152_inflated.nv' is a common choice if available.
% If not available, you might need to obtain one or use the standard 'BrainMesh_ICBM152.nv'.
bnvSurfaceFile = fullfile(brainnet_viewer_path, 'Data', 'SurfTemplate', 'BrainMesh_ICBM152_smoothed.nv'); 
% Maybe use inflated surface for better visualization.
if ~exist(bnvSurfaceFile, 'file')
    fprintf('Warning: Default smoothed surface %s not found. Trying standard surface.\n', bnvSurfaceFile);
    bnvSurfaceFile = fullfile(brainnet_viewer_path, 'Data', 'SurfTemplate', 'BrainMesh_ICBM152.nv');
    if ~exist(bnvSurfaceFile, 'file')
        error('BNV surface file not found. Please check BrainNet Viewer installation and paths.');
    end
end

% This is the .mat file you saved from BNV GUI (File -> Save Option)
% Ensure this file exists in your ConfigFolder.
bnvOptionFilename = 'MyPositiveMultiView_Option.mat'; % As per your screenshot
bnvOptionFileFullPath = fullfile(ConfigFolder, bnvOptionFilename);

if ~exist(bnvOptionFileFullPath, 'file')
    warning(['BNV .mat option file not found: %s. BNV plotting will be skipped. \n' ...
             'Please save your desired BNV settings from the GUI (File -> Save Option) to this location.'], bnvOptionFileFullPath);
    canPlotBNV = false;
else
    canPlotBNV = true;
end


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
        Scans{iP,1} = spm_select('ExtFPList', fullfile(ParticipantConFolder), conFilePattern, 1);
    end

    matlabbatch = {}; % Initialize matlabbatch for each contrast
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
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf; % Process all contrasts defined by Contrast Manager
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none'; % Uncorrected p-value
    matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001; % p < 0.001 uncorrected
    matlabbatch{4}.spm.stats.results.conspec.extent = extentThreshold; % Voxel extent threshold
    % matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
    % use a gray matter mask
    matlabbatch{4}.spm.stats.results.conspec.mask.image.name = {grayMatterMaskFile};
    matlabbatch{4}.spm.stats.results.conspec.mask.image.mtype = 0; 

    % matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1; % Volumetric NIfTI
    matlabbatch{4}.spm.stats.results.export{1}.jpg = true; % Export results table as JPG
    % Export thresholded spmT map. The output will be named based on 'basename' and the spmT file.
    % e.g., if spmT is spmT_0001.nii, output is spmT_0001_Threshold_001.nii
    matlabbatch{4}.spm.stats.results.export{2}.tspm.basename = 'Threshold_001'; 

    fprintf('--- Running SPM Batch for Contrast: %s ---\n', contrastName);
    save(fullfile(ContrastFolder, ['second-level_batch_', contrastName, '.mat']),"matlabbatch");
    spm_jobman('run', matlabbatch);
    fprintf('--- SPM Batch for Contrast: %s Finished ---\n', contrastName);

    % --- BNV Integration: Plotting after SPM results ---
    if canPlotBNV
        % Construct the path to the thresholded spmT file generated by the results report
        % SPM typically names this [basename]_[spmT_filename].nii
        % Since consess{1} produces spmT_0001.nii, the thresholded map will be:
        thresholdedSpMTFileForBNV = fullfile(ContrastFolder, 'spmT_0001_Threshold_001.nii');
        
        % Define the output image filename for BNV
        bnvOutputImageFile = fullfile(ContrastFolder, [contrastName, '_BNV_Plot.png']);
        
        % Call the plotting function
        plot_contrast_with_bnv(bnvSurfaceFile, thresholdedSpMTFileForBNV, bnvOptionFileFullPath, bnvOutputImageFile);
    else
        fprintf('Skipping BNV plotting for %s as BNV option file was not found.\n', contrastName);
    end
    
end % end of the loop for different contrasts

fprintf('--- All Second-Level Analyses and Plotting Finished ---\n');

function plot_contrast_with_bnv(surfaceFile, volumeFile, bnvOptionFile, outputImageFile)
% PLOT_CONTRAST_WITH_BNV Generates a brain surface plot using BrainNet Viewer.
%
%   Inputs:
%       surfaceFile     - Full path to the brain surface file (e.g., .nv).
%                         For a "flattened" or "blown-up" look, use an inflated surface.
%       volumeFile      - Full path to the NIfTI volume file to map (e.g., thresholded spmT.nii).
%       bnvOptionFile   - Full path to the BrainNet Viewer .mat option file
%                         (saved from BNV GUI: File -> Save Option).
%       outputImageFile - Full path for the output image (e.g., .png).

fprintf('--- Initializing BrainNet Viewer Plotting ---\n');
fprintf('  Surface: %s\n', surfaceFile);
fprintf('  Volume: %s\n', volumeFile);
fprintf('  BNV Options: %s\n', bnvOptionFile);
fprintf('  Output Image: %s\n', outputImageFile);

% Basic checks for file existence
if ~exist(surfaceFile, 'file')
    warning('BNV Plotting: Surface file not found: %s. Skipping plot.', surfaceFile);
    return;
end
if ~exist(volumeFile, 'file')
    warning('BNV Plotting: Volume file (thresholded spmT) not found: %s. Skipping plot.', volumeFile);
    fprintf('  Ensure SPM results export generated this file.\n');
    return;
end
if ~exist(bnvOptionFile, 'file')
    warning('BNV Plotting: BNV .mat option file not found: %s. Skipping plot.', bnvOptionFile);
    fprintf('  Please ensure you have saved BNV options from the GUI (File -> Save Option) as a .mat file.\n');
    return;
end

% Ensure output directory exists
outputDir = fileparts(outputImageFile);
if ~exist(outputDir, 'dir')
    try
        mkdir(outputDir);
        fprintf('  Created output directory for BNV image: %s\n', outputDir);
    catch ME_mkdir
        warning('BNV Plotting: Could not create output directory %s. Error: %s. Skipping plot.', outputDir, ME_mkdir.message);
        return;
    end
end

try
    % It's good practice to clear any persistent global EC structure BNV might use,
    % especially when calling it in a loop.
    clear global EC; 
    
    % Call BrainNet Viewer's mapping configuration function
    BrainNet_MapCfg(surfaceFile, volumeFile, bnvOptionFile, outputImageFile);
    
    if exist(outputImageFile, 'file')
        fprintf('  BrainNet Viewer rendering complete. Image saved to: %s\n', outputImageFile);
    else
        warning('BNV Plotting: Output image file was NOT created: %s. BrainNet Viewer might have encountered an issue or failed silently.', outputImageFile);
    end
catch ME_bnv
    fprintf(2, 'ERROR during BrainNet Viewer plotting (BrainNet_MapCfg call):\n');
    fprintf(2, '  Message: %s\n', ME_bnv.message);
    if ~isempty(ME_bnv.stack)
        for k_err = 1:length(ME_bnv.stack)
            fprintf(2, '  File: %s, Name: %s, Line: %d\n', ME_bnv.stack(k_err).file, ME_bnv.stack(k_err).name, ME_bnv.stack(k_err).line);
        end
    end
    warning('BNV Plotting: Plotting failed. Please check your BNV setup, paths, the .mat option file, and the NIfTI data.');
end
fprintf('--- BrainNet Viewer Plotting Finished ---\n\n');
end
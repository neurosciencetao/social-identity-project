% create_gray_matter_mask.m
% Generates a gray matter binary mask using SPM's TPM.nii and saves it to code/mask/

clear; clc;
spm('defaults','FMRI');
SPMFolder = fileparts(which('spm'));
if isempty(SPMFolder)
    error('SPM not found in path!');
end

maskFolder = fullfile(pwd, 'mask');
if ~exist(maskFolder, 'dir')
    mkdir(maskFolder);
end

gmThreshold = 0.2;
maskFile = fullfile(maskFolder, sprintf('spm_gray_matter_mask_p%02d.nii', round(gmThreshold*100)));

if exist(maskFile, 'file')
    fprintf('Mask already exists: %s\n', maskFile);
else
    tpmFile = fullfile(SPMFolder, 'tpm', 'TPM.nii');
    V = spm_vol([tpmFile, ',1']); % 1st volume: gray matter
    Y = spm_read_vols(V);
    Ymask = Y > gmThreshold;
    Vmask = V;
    Vmask.fname = maskFile;
    Vmask.dt = [spm_type('uint8') spm_platform('bigend')];
    Vmask.pinfo = [1;0;0];
    Vmask.descrip = sprintf('SPM GM mask > %.2f', gmThreshold);
    spm_write_vol(Vmask, Ymask);
    fprintf('Gray matter mask saved to: %s\n', maskFile);
end
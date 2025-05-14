% This script performs fMRI preprocessing
% written by TAO Ran @ HHB714
% Initiated 2025-03-28
% Last updated 2025-03-28

% Prepare environment
clear;clc;
spm('defaults', 'FMRI');
% Get SPM path
SPMFolder = fileparts(which('spm'));
if isempty(SPMFolder)
    error('SPM not found in MATLAB path. Please add SPM to your MATLAB path.');
end

% Change this variable to the participant number you want to process
% Before processing, ensure the participant's raw data is in the ./rawdata/participant folder, e.g., rawdata/103
thisParticipant = 103;
Participant = ['sub-',num2str(thisParticipant)];

CodeFolder = pwd;
BIDSFolder = fileparts(CodeFolder);
RawFolder = [BIDSFolder, filesep, 'rawdata'];
SourceFolder = [BIDSFolder, filesep, 'sourcedata'];
FiguresFolder = [BIDSFolder, filesep, 'figures'];

TaskSessions = {'TASK_A_1','TASK_A_2','TASK_B_iden','TASK_B_sem'};

%% MRI conversion: dcm2niix
dcm2niixPath = fullfile(CodeFolder, 'MRIcroGL', 'Resources', 'dcm2niix.exe');

dicomDir = fullfile(RawFolder, num2str(thisParticipant), 'MRI');
outputDir = fullfile(SourceFolder, Participant);

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

if exist(fullfile(outputDir,'MRI'),'dir')
    disp('Removing existing MRI directory...');
    rmdir(fullfile(outputDir,'MRI'), 's');
end

% Create a temporary directory within outputDir to store conversion results
tempDir = fullfile(outputDir, 'temp_dcm2niix');
if ~exist(tempDir, 'dir')
    mkdir(tempDir);
end


% Updated command using new syntax
% Key changes:
% 1. Using -f for filename format
% 2. Using -o to specify output directory (explicitly needed)
% 3. Changed -p y to -p n (disable Philips precise float)
% 4. Removed -b y, -l y options
% 5. Kept -i y (ignore derived images) and -x y (crop)
% 6. Kept -z n (no compression)
command = sprintf('"%s" -f "%%f/%%p/%%t_%%s" -o "%s" -z n -i y -p n -x y "%s"', dcm2niixPath, tempDir, dicomDir);

disp(['Running conversion for sub-', Participant, '...']);
disp(command);

if system(command) == 0
    disp('Conversion successful.');
    % Check if temp directory contains the MRI subfolder with converted files
    if exist(fullfile(tempDir, 'MRI'), 'dir')
        % Move MRI folder to MRI
        if ~exist(fullfile(outputDir, 'MRI'), 'dir')
            mkdir(fullfile(outputDir, 'MRI'));
        end

        % Move contents from temp/MRI to outputDir/MRI
        movefile(fullfile(tempDir, 'MRI', '*'), fullfile(outputDir, 'MRI'));
        disp(['Files moved to ', fullfile(outputDir, 'MRI')]);
    else
        disp('Warning: Expected MRI subfolder not found in temporary directory.');
        % Try moving all contents from temp to MRI
        if ~exist(fullfile(outputDir, 'MRI'), 'dir')
            mkdir(fullfile(outputDir, 'MRI'));
        end
        movefile(fullfile(tempDir, '*'), fullfile(outputDir, 'MRI'));
        disp(['All temp files moved to ', fullfile(outputDir, 'MRI')]);
    end
else
    disp(['Conversion failed for sub-', Participant]);
end

% Clean up temp directory
if exist(tempDir, 'dir')
    rmdir(tempDir, 's');
    disp('Temporary directory removed.');
end

disp('-----------------------------------');
%% Preprocessing
ParticipantNiftiFolder = fullfile(SourceFolder, Participant, 'MRI');
TaskFolders = dir(ParticipantNiftiFolder);

T1Folder = dir(fullfile(ParticipantNiftiFolder,'t1_mprage_sag_iso_3_22*'));
T1File = cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,T1Folder.name),'^202.*Crop_1.nii',Inf));

clear matlabbatch % prevent influence from previous analysis

matlabbatch{1}.spm.spatial.realign.estwrite.data = {
    cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{1}),'^202.*nii',Inf))
    cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{2}),'^202.*nii',Inf))
    cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{3}),'^202.*nii',Inf))
    cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{4}),'^202.*nii',Inf))
    }';

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
matlabbatch{2}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{2}.spm.spatial.coreg.estwrite.source = T1File;
matlabbatch{2}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {fullfile(SPMFolder, 'tpm', 'TPM.nii,1')};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {fullfile(SPMFolder, 'tpm', 'TPM.nii,2')};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {fullfile(SPMFolder, 'tpm', 'TPM.nii,3')};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {fullfile(SPMFolder, 'tpm', 'TPM.nii,4')};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {fullfile(SPMFolder, 'tpm', 'TPM.nii,5')};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {fullfile(SPMFolder, 'tpm', 'TPM.nii,6')};
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'eastern';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [1 1];
matlabbatch{3}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{3}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
    NaN NaN NaN];
matlabbatch{4}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','rfiles'));
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 3)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{3}, '.','rfiles'));
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(4) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 4)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{4}, '.','rfiles'));
matlabbatch{4}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
    78 76 85]; % also consider the suggested box: [-90 -126 -72; 90 90 108]
matlabbatch{4}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{4}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{4}.spm.spatial.normalise.write.woptions.prefix = 'w';
matlabbatch{5}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{5}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{5}.spm.spatial.smooth.dtype = 0;
matlabbatch{5}.spm.spatial.smooth.im = 0;
matlabbatch{5}.spm.spatial.smooth.prefix = 's';


save([ParticipantNiftiFolder, filesep, 'Preprocess.mat'],"matlabbatch")
spm_jobman('run', matlabbatch);

%% Visualize head movement
% Set working directory
BIDS_dir = BIDSFolder;
figure_dir = FiguresFolder;

% Create figure
figure('Position', [50 50 1500 1000]);

% Define natural colors
colors = {[217,95,2]/255, [27,158,119]/255, [117,112,179]/255};  % Orange, Teal, Purple

% Create subplots for each task
for task_idx = 1:length(TaskSessions)
    % Find the rp file in the task directory
    task_dir = fullfile(BIDS_dir, 'sourcedata', Participant, 'MRI', TaskSessions{task_idx});
    rp_files = dir(fullfile(task_dir, 'rp_*.txt'));

    if isempty(rp_files)
        warning('No rp_*.txt file found in %s', task_dir);
        continue;
    end

    % Load the data
    raw_data = load(fullfile(task_dir, rp_files(1).name));

    % Convert radians to degrees for rotation parameters (columns 4-6)
    raw_data(:,4:6) = raw_data(:,4:6) * 180/pi;

    % Create subplot
    subplot(2, 2, task_idx);

    % Create time vector
    time = 1:size(raw_data, 1);

    % Plot translations (left y-axis)
    yyaxis left
    plot(time, raw_data(:, 1), '-', 'Color', colors{1}, 'LineWidth', 1, 'DisplayName', 'X trans');
    hold on;
    plot(time, raw_data(:, 2), '-', 'Color', colors{2}, 'LineWidth', 1, 'DisplayName', 'Y trans');
    plot(time, raw_data(:, 3), '-', 'Color', colors{3}, 'LineWidth', 1, 'DisplayName', 'Z trans');

    % Add reference lines for translation
    plot(xlim(), [3 3], 'r-', 'LineWidth', 2, 'DisplayName', 'Upper threshold');
    plot(xlim(), [-3 -3], 'r-', 'LineWidth', 2, 'HandleVisibility', 'off');
    ylabel('Translation (mm)');
    ylim([-6 6]);

    % Plot rotations (right y-axis)
    yyaxis right
    plot(time, raw_data(:, 4), ':', 'Color', colors{1}, 'LineWidth', 2, 'DisplayName', 'Pitch');
    plot(time, raw_data(:, 5), ':', 'Color', colors{2}, 'LineWidth', 2, 'DisplayName', 'Roll');
    plot(time, raw_data(:, 6), ':', 'Color', colors{3}, 'LineWidth', 2, 'DisplayName', 'Yaw');

    % Add reference lines for rotation
    plot(xlim(), [1 1], 'r-', 'LineWidth', 2, 'HandleVisibility', 'off');
    plot(xlim(), [-1 -1], 'r-', 'LineWidth', 2, 'HandleVisibility', 'off');
    ylabel('Rotation (degrees)');
    ylim([-2 2]);

    % Customize the subplot
    xlabel('Time (volumes)');
    title(sprintf('Task: %s', TaskSessions{task_idx}), 'FontSize', 12);
    grid on;
    box off;

    % Set colors for y-axes
    yyaxis left
    ax = gca;
    ax.YColor = 'k';
    yyaxis right
    ax.YColor = 'k';

    % Make grid lighter
    grid minor;
    ax.GridAlpha = 0.15;
    ax.MinorGridAlpha = 0.1;

    % Only show legend for the first subplot
    if task_idx == 1
        legend('Location', 'northwest');
    end
end

% Add overall title
sgtitle(sprintf('%s Head Movement Parameters Across Tasks', Participant), 'FontSize', 14);

% Adjust font size
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 10);

% Save the figure
saveas(gcf, fullfile(figure_dir, [Participant '-head_movement_across_tasks.png']));

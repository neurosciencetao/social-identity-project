% This script performs fMRI fist-level analysis
% written by TAO Ran @ HHB714
% Initiated 2025-03-28
% Last updated 2025-04-09

% Prepare environment
clear;clc;
spm('defaults', 'FMRI');
% Get SPM path
SPMFolder = fileparts(which('spm'));
if isempty(SPMFolder)
    error('SPM not found in MATLAB path. Please add SPM to your MATLAB path.');
end

CodeFolder = pwd;
BIDSFolder = fileparts(CodeFolder);
RawFolder = [BIDSFolder, filesep, 'rawdata'];
SourceFolder = [BIDSFolder, filesep, 'sourcedata'];
FiguresFolder = [BIDSFolder, filesep, 'figures'];

TaskSessions = {'TASK_A_1','TASK_A_2','TASK_B_iden','TASK_B_sem'};

% Change this variable to the participant number you want to process
% Before processing, ensure the participant's raw data is in the ./rawdata/participant folder, e.g., rawdata/103
for iP = [101:116]
    thisParticipant = iP;
    Participant = ['sub-',num2str(thisParticipant)];
    ParticipantNiftiFolder = fullfile(SourceFolder, Participant, 'MRI');


    %% First-level analysis for Localization tasks: TASK_A_1 & TASK_A_2

    TaskFolder = fullfile(SourceFolder, Participant, 'fMRI', 'Localization');
    if ~exist(TaskFolder, 'dir')
        mkdir(TaskFolder);
    end

    % Delete SPM.mat file if it exists
    SPM_mat_file = fullfile(TaskFolder, 'SPM.mat');
    if exist(SPM_mat_file, 'file')
        delete(SPM_mat_file);
    end

    % Find realignment parameters file
    rp_file_Task_A_1 = cellstr(spm_select('FPList', fullfile(ParticipantNiftiFolder, TaskSessions{1}), '^rp.*\.txt$'));
    if isempty(rp_file_Task_A_1)
        warning('No realignment parameter file found for %s', TaskSessions{1});
    end

    rp_file_Task_A_2 = cellstr(spm_select('FPList', fullfile(ParticipantNiftiFolder, TaskSessions{2}), '^rp.*\.txt$'));
    if isempty(rp_file_Task_A_2)
        warning('No realignment parameter file found for %s', TaskSessions{2});
    end

    clear matlabbatch % prevent influence from previous analysis

    matlabbatch{1}.spm.stats.fmri_spec.dir = {TaskFolder};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{1}),'^swr202.*nii',Inf));
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{1}, 'multicond.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = rp_file_Task_A_1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{2}),'^swr202.*nii',Inf));
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{2}, 'multicond.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = rp_file_Task_A_2;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Accent';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Age';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Gender';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Semantics';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Tone';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Accent - Tone';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [1 0 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Age - Tone';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 1 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'Gender - Tone';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'Semantics - Tone';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Semantics - AgeGender';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [0 -1 -1 2 0];
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'repl';
    matlabbatch{3}.spm.stats.con.delete = 1;
    matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{4}.spm.stats.results.conspec.extent = 50;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.jpg = true;


    save([TaskFolder, filesep, 'first-level.mat'],"matlabbatch")
    spm_jobman('run', matlabbatch);

    %% First-level analysis for TASK_B_iden

    TaskFolder = fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{3});
    if ~exist(TaskFolder, 'dir')
        mkdir(TaskFolder);
    end

    % Delete SPM.mat file if it exists
    SPM_mat_file = fullfile(TaskFolder, 'SPM.mat');
    if exist(SPM_mat_file, 'file')
        delete(SPM_mat_file);
    end

    % Find realignment parameters file
    rp_file_Task_B_iden = cellstr(spm_select('FPList', fullfile(ParticipantNiftiFolder, TaskSessions{3}), '^rp.*\.txt$'));
    if isempty(rp_file_Task_B_iden)
        warning('No realignment parameter file found for %s', TaskSessions{3});
    end

    clear matlabbatch % prevent influence from previous analysis

    matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{3})};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{3}),'^swr202.*nii',Inf));
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{3}, 'multicond.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = rp_file_Task_B_iden;
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Age_No';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Age_Yes';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Gender_No';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Gender_Yes';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Age_No-Yes';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [1 -1 0 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Gender_No-Yes';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Social_No-Yes';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [1 -1 1 -1];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'Age_Yes-No';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [-1 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'Gender_Yes-No';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Social_Yes-No';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [-1 1 -1 1];
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{4}.spm.stats.results.conspec.extent = 0;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.jpg = true;

    save([TaskFolder, filesep, 'first-level.mat'],"matlabbatch")
    spm_jobman('run', matlabbatch);

    %% First-level analysis for TASK_B_sem

    TaskFolder = fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{4});
    if ~exist(TaskFolder, 'dir')
        mkdir(TaskFolder);
    end

    % Delete SPM.mat file if it exists
    SPM_mat_file = fullfile(TaskFolder, 'SPM.mat');
    if exist(SPM_mat_file, 'file')
        delete(SPM_mat_file);
    end

    % Find realignment parameters file
    rp_file_Task_B_sem = cellstr(spm_select('FPList', fullfile(ParticipantNiftiFolder, TaskSessions{4}), '^rp.*\.txt$'));
    if isempty(rp_file_Task_B_sem)
        warning('No realignment parameter file found for %s', TaskSessions{4});
    end

    clear matlabbatch % prevent influence from previous analysis

    matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{4})};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',fullfile(ParticipantNiftiFolder,TaskSessions{4}),'^swr202.*nii',Inf));
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(SourceFolder, Participant, 'fMRI', TaskSessions{4}, 'multicond.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = rp_file_Task_B_sem;
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Semantic_No';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Semantic_Yes';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Semantic_No-Yes';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Semantic_Yes-No';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{4}.spm.stats.results.conspec.extent = 50;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.jpg = true;

    save([TaskFolder, filesep, 'first-level.mat'],"matlabbatch")
    spm_jobman('run', matlabbatch);

end % end of the loop for different participants
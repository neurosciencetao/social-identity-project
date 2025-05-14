%-----------------------------------------------------------------------
% Job saved on 13-May-2025 18:17:18 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.factorial_design.dir = {'D:\Documents\Research\Zhang-Kaile\MRIresults\derivatives\Accent'};
%%
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-101\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-102\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-103\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-104\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-105\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-106\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-107\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-108\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-109\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-110\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-111\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-112\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-113\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-114\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-115\fMRI\Localization\con_0001.nii,1'
                                                          'D:\Documents\Research\Zhang-Kaile\MRIresults\sourcedata\sub-116\fMRI\Localization\con_0001.nii,1'
                                                          };
%%
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
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Accent';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec.extent = 10;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.image.name = {'D:\Documents\Research\Zhang-Kaile\MRIresults\code\mask\spm_gray_matter_mask_p30.nii'};
matlabbatch{4}.spm.stats.results.conspec.mask.image.mtype = 0;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.jpg = true;
matlabbatch{4}.spm.stats.results.export{2}.tspm.basename = 'Threshold_001';

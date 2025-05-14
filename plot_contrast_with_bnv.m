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
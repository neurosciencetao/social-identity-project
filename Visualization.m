% Visualize results using BrainNet Viewer
spmTFile = fullfile(ContrastFolder, 'spmT_0001.nii');
if exist(spmTFile, 'file')
    % Get BrainNet Viewer template files
    templateFolder = fullfile(fileparts(which('BrainNet')), 'Data', 'SurfTemplate');
    surfaceFile = fullfile(templateFolder, 'BrainMesh_ICBM152.nv');
    
    % Define view angles for comprehensive visualization
    % [azimuth, elevation] pairs for different views
    views = {
        {'Left',     [270, 0]},   % Left view
        {'Right',    [90, 0]},    % Right view
        {'Dorsal',   [0, 90]},    % Top view
        {'Ventral',  [0, -90]},   % Bottom view
        {'Anterior', [180, 0]},   % Front view
        {'Posterior',[0, 0]}      % Back view
    };
    
    % Get T threshold for p < 0.001 uncorrected
    % Degrees of freedom = number of subjects - 1
    df = length(Participants) - 1;
    t_threshold = tinv(1-0.001, df); % One-tailed threshold
    
    for v = 1:length(views)
        viewName = views{v}{1};
        viewAngle = views{v}{2};
        
        % Create output figure name for this view
        figName = fullfile(FiguresFolder, sprintf('%s_%s_BrainNet.png', contrastName, viewName));
        
        % Create configuration file
        cfgFile = fullfile(FiguresFolder, sprintf('%s_%s_BrainNet.cfg', contrastName, viewName));
        fid = fopen(cfgFile, 'w');
        fprintf(fid, 'FileName=%s\n', figName);
        fprintf(fid, 'Threshold=%f\n', t_threshold);  % Apply statistical threshold
        fprintf(fid, 'Size=%d\n', extentThreshold);
        fprintf(fid, 'ColorMap=jet\n');
        fprintf(fid, 'ColorBar=1\n');
        fprintf(fid, 'Alpha=0.7\n');  % Slightly more transparent to see structure better
        fprintf(fid, 'View=%d,%d\n', viewAngle(1), viewAngle(2));
        fprintf(fid, 'NoseDir=1\n');  % Ensure consistent orientation
        fprintf(fid, 'Zoom=1.2\n');   % Slightly zoomed in view
        fclose(fid);
        
        % Call BrainNet Viewer's visualization function
        BrainNet_MapCfg(surfaceFile, spmTFile, cfgFile);
        
        fprintf('Visualization saved for %s view: %s\n', viewName, figName);
    end
else
    warning('SPM T-map file not found: %s', spmTFile);
end
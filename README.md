# Social Identity Project

This repository contains MATLAB code for analyzing social identity-related MRI data.

## Project Structure

- `Batch_1st.m`, `Batch_2nd.m`: Main analysis scripts
- `Batch_Preprocess.m`: Preprocessing pipeline
- `create_gray_matter_mask.m`: Function for creating gray matter masks
- `plot_contrast_with_bnv.m`: Visualization functions
- `Visualization.m`: Additional visualization tools

## Requirements

- MATLAB
- SPM12
- BrainNet Viewer (for visualization)

## Usage

1. Ensure all dependencies are installed
2. Run preprocessing using `Batch_Preprocess.m`
3. Run first-level analysis using `Batch_1st.m`
4. Run second-level analysis using `Batch_2nd.m`
5. Visualize results using the visualization scripts 
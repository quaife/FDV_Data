# Fire Dynamic Vision (FDV) Examples

Sample data and FDV code for experiments in the paper titled "Fire Dynamic Vision: Image Segmentation and Tracking for Multi-Scale Fire and Plume Behavior"

## Description

This repository contains infrared and visual video data for three experiments presented in the paper listed above:
* Infrared dataset of fire spread (infrared_fire.mat)
* Visual video of fire spread (visual_fire.mp4)
* Visual video of plume evolution (visual_plume.mp4)

Each video dataset has a corresponding file with sample FDV code that performs the processing steps described in our paper (infrared_fire.m, visual_fire.m, visual_plume.m) and a file that visualizes all output and results from the FDV code (infrared_fire_results.m, visual_fire_results.m, visual_plume_results.m). The code files come pre-loaded with values from the paper, but you are invited to experiment with the datasets and try your own!

## Getting Started

### Using MATLAB

Both this code and the infrared dataset are set up to run in MATLAB. For those who do not have access to a MATLAB license, please visit the MATLAB Online (basic) resource provided by Mathworks! This is a free version of MATLAB available to run in your browser for a set number of hours per month.

### Setting Up

Download the video data and code files from this repository (FDV_Data) and have them in your current working directory prior to running. The MATLAB scripts, the video to be processed, and Cleaner.m must be in your current working directory. The visualization scripts can be run after their corresponding processing files (e.g., run infrared_fire.m first and then run infrared_fire_results.m).

All files contain a clearly marked section at the top with all values that may be edited. Further descriptions on how these values are used are found in comments throughout the code.

The visualization files can be run in sections depending on what you want to visualize; each file contains instructions on how to do this with MATLAB.

### Executing program

To run the code, have all aforementioned files in your current working directory and select 'Run' under the 'EDITOR' menu in MATLAB's interface.

Note that the scripts visual_fire.m and visual_plume.m are designed to read frames from a video. To load an image sequence rather than a video, sample MATLAB code to load all frames from a directory and preallocate needed space is as follows:
```
% Replace this path with the path to your frames
% This example assumes sequentially numbered images in a directory called 'frames' within the current working directory.
directory = dir("./frames/*.png");
file_names = {directory.name}';
total_frames = numel(file_names);
clear directory
final{total_frames} = [];
```

From this point, you will load the frames in a for loop using the syntax:
```
temp = imread(file_names{i});
```

If an image sequence is used instead of a video, remember to manually declare the fps and Hz variables, as in the infrared_fire.m file.

## Author

Daryn Sagel, dsagel@fsu.edu

## Correspondence

Bryan Quaife, bquaife@fsu.edu

## Copyright

This project is licensed under the MIT License. See the [LICENSE](./LICENSE.txt) file for the full text.
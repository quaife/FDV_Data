# Fire Dynamic Vision (FDV) Examples

Sample data and FDV code for experiments in the paper titled "Fire Dynamic Vision: Image Segmentation and Tracking for Multi-Scale Fire and Plume Behavior"

## Description

This repository contains infrared and visual video data for three experiments presented in the paper listed above:
* Infrared dataset of fire spread (infrared_fire.mat)
* Visual video of fire spread (visual_fire.mp4)
* Visual video of plume evolution (visual_plume.mp4 or image sequence within 'visual_plume_frames' directory)

Each video dataset has a corresponding file with sample FDV code that performs the processing steps described in our paper (infrared_fire.m, visual_fire.m, visual_plume.m) and a shared file that visualizes all output and results from the FDV code (visualize.m). The code files contain suggested values from the paper, but you are invited to experiment with the datasets and try your own!

The 'Examples' directory contains sample output from each of the above files.

## Getting Started

### Using MATLAB

Both this code and the infrared dataset are set up to run in MATLAB. For those who do not have access to a MATLAB license, please visit the MATLAB Online (basic) resource provided by Mathworks! This is a free version of MATLAB available to run in your browser for a set number of hours per month.

### Setting Up

Download the video data and code files from this repository (FDV_Data) and have them in your current working directory prior to running. The MATLAB scripts, the video to be processed, Cleaner.m, and GetImageVals.m (for video and image datasets) must be in your current working directory. The visualization script can be run after successfully running one of the processing files (e.g., run infrared_fire.m first and then visualize.m).

All files contain a clearly marked section at the top with all values that may be edited. Further descriptions on how these values are used are found in comments throughout the code.

The visualization file can be run in sections depending on what you want to visualize; the file contains instructions on how to do this with MATLAB.

### Executing program

To run the code, have all necessary aforementioned files in your current working directory and select 'Run' under the 'EDITOR' menu in MATLAB's interface.

Note that the visual_fire.m script is designed to demonstrate how to read frames from a video and the visual_plume.m script is designed to demonstrate how to load frames from an image sequence. In this scenario, the images are stored in a file inside the current working directory. After downloading the 'visual_plume_frames' directory, please unzip the file prior to use. The plume images are also provided in video format.

Note that you should specify a sampling frequency (Hz) that evenly divides into the video's framerate. For example, good sampling frequencies for a video recorded at 30 Hz include 1 Hz, 2 Hz, 3 Hz, 5 Hz, 6 Hz, 7.5 Hz, 10 Hz, 15 Hz, and 30 Hz, among others. If an image sequence is used instead of a video, remember to manually declare the fps variable, as in the infrared_fire.m and visual_plume.m files.

For RGB-HSV image-based processing, the best practice is to select many points within the area of interest when prompted to click on points representative of that region. This helps to ensure the intended range of color values is fully captured.

## Author

Daryn Sagel, dsagel@fsu.edu

## Correspondence

Bryan Quaife, bquaife@fsu.edu

## License and Citation

If this code is used in your research or publications, please cite the following reference to acknowledge the original work:

Sagel, D., & Quaife, B. (2025). Fire dynamic vision: Image segmentation
and tracking for multi-scale fire and plume behavior. Environmental
Modelling & Software, 185, 106286.

This project is licensed under the MIT License. See the [LICENSE](./LICENSE.txt) file for the full text.

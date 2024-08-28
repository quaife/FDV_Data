% Fire Dynamic Vision (FDV) sample script for processing visual fire data
% Created by Daryn Sagel, dsagel@fsu.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit values in the following section as needed:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the video, get total videa time (in seconds) and fps
v = VideoReader('visual_fire.mp4'); % Edit this line to change file name

% If not processing the entire dataset, enter start and stop times
start = 1; % seconds
stop = 24; % seconds

% Select the frequency to sample (Hz)
Hz = 2;

% Define the per-pixel spatial resolution
length_per_px = 200/252; % cm/px

% Define search radius and nearest neighbor thresholds for cleaning layers
% Add layers as needed! Make sure you insert code for them below.
rad2 = 10; num2 = 70; % search radius 10 px, 70 nonzero neighbors (large structures)
rad1 = 3; num1 = 10; % search radius 3 px, 10 nonzero neighbors (small structures)

% Alpha shape parameter for boundary calculation
alpha = 1/3;

% Recommended RGB value ranges from the paper are
% R: [220 255] G: [0 255] B: [0 255]
% Recommended HSV value ranges from the paper are
% H: [0 1]   S: [0 1]   V: [0 1]
% To use these values, set papervals = 1. Otherwise, papervals = 0.
papervals = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get framerate from video data
fps = v.FrameRate;

% Calculate how many frames are between samples
% (in case of sampling at a rate other than the video's framerate)
fphz = round(fps/Hz);

% Preallocate space for next steps
total_frames = (stop - start)*Hz;
final{total_frames} = [];
final_clean{total_frames} = [];
points{total_frames} = [];
boundary{total_frames} = [];
vel_horizontal = []; % list of all horizontal velocities (in px/timestep)
vel_vertical = []; % list of all vertical velocities (in px/timestep)
xyuv{total_frames-1} = []; % velocities associated with x-y coordinates

% Use suggested RGB-HSV ranges or find your own
if papervals == 0
    % Pick a sample frame from middle of video for RGB and HSV selection
    framenum = fps * floor((start + stop) / 2);
    temp = read(v, framenum);
    
    % Select RGB values from sample frame
    [~, suggestedrangeRGB] = GetImageVals(temp);
    % Resulting array is arranged as:
    % [ r_low   b_low   g_low  ]
    % [ r_high  b_high  g_high ]
    
    % Segment sample frame
    mask = temp(:,:,1) >= suggestedrangeRGB(1,1) & temp(:,:,1) <= suggestedrangeRGB(2,1) ...
        & temp(:,:,2) >= suggestedrangeRGB(1,2) & temp(:,:,2) <= suggestedrangeRGB(2,2) ...
        & temp(:,:,3) >= suggestedrangeRGB(1,3) & temp(:,:,3) <= suggestedrangeRGB(2,3);
    temp(:,:,1) = double(temp(:,:,1)).*double(mask);
    temp(:,:,2) = double(temp(:,:,2)).*double(mask);
    temp(:,:,3) = double(temp(:,:,3)).*double(mask);
    
    % Select HSV values from remaining points in sample frame
    [~, suggestedrangeHSV] = GetImageVals(rgb2hsv(temp));
    
    clear temp mask framenum
elseif papervals == 1
    suggestedrangeRGB = [220 0 0; 255 255 255];
    suggestedrangeHSV = [0 0 0; 1 1 1];
end

% Segment frames according to RGB and HSV thresholds
counter = 1;
for i = start*fps:fphz:stop*fps - fphz
    toDisp = ['Segmenting frame #', num2str(counter), ' of ', num2str(total_frames)];
    disp(toDisp)
    
    temp = read(v,i);
    
    % Segment RGB
    mask = temp(:,:,1) >= suggestedrangeRGB(1,1) & temp(:,:,1) <= suggestedrangeRGB(2,1) ...
        & temp(:,:,2) >= suggestedrangeRGB(1,2) & temp(:,:,2) <= suggestedrangeRGB(2,2) ...
        & temp(:,:,3) >= suggestedrangeRGB(1,3) & temp(:,:,3) <= suggestedrangeRGB(2,3);
    temp(:,:,1) = double(temp(:,:,1)).*double(mask);
    temp(:,:,2) = double(temp(:,:,2)).*double(mask);
    temp(:,:,3) = double(temp(:,:,3)).*double(mask);
    
    % Convert to HSV
    temp = rgb2hsv(temp);
    
    % Segment HSV
    mask = temp(:,:,1) >= suggestedrangeHSV(1,1) & temp(:,:,1) <= suggestedrangeHSV(2,1) ...
        & temp(:,:,2) >= suggestedrangeHSV(1,2) & temp(:,:,2) <= suggestedrangeHSV(2,2) ...
        & temp(:,:,3) >= suggestedrangeHSV(1,3) & temp(:,:,3) <= suggestedrangeHSV(2,3);
    temp(:,:,1) = double(temp(:,:,1)).*double(mask);
    temp(:,:,2) = double(temp(:,:,2)).*double(mask);
    temp(:,:,3) = double(temp(:,:,3)).*double(mask);
    
    % Flatten image array to 2D
    final{counter} = temp(:,:,1) + temp(:,:,2) + temp(:,:,3);
    
    counter = counter + 1;
end

clear i mask temp toDisp counter v

% Clean frames using hierarchical cleaning layers according to values
% defined at the top of this script
for i = 1:total_frames
    
    toDisp = ['Cleaning frame #', num2str(i)];
    disp(toDisp)
    
    temp = final{i};
    temp(temp ~= 0) = 1;
    
    clean = temp;
    clean = Cleaner(clean,rad2,num2);
    clean = Cleaner(clean,rad2,num2);
    final_clean{i} = double(Cleaner(clean,rad1,num1));
end

clear i temp toDisp clean

% Convert 2D image matrices to list of x-y coordinates
for i = 1:total_frames
    toDisp = ['Converting frame #', num2str(i), ' to coordinates'];
    disp(toDisp)
    
    % Find nonzero points and save as coordinates
    [r,c] = find(flipud(final_clean{i}));
    points{i} = [c r];
end

clear i toDisp r c

% In case a video contains blank frames or frames have been dropped, check
% that a frame is not blank and, if it is, interpolate it as the average
% of the positions in the frames before and after
for i = 2:total_frames-1
   if isempty(points{i})
       length_before = length(points{i-1});
       length_after = length(points{i+1});
       if length_before < length_after
           points{i} = (points{i-1} + points{i+1}(1:length_before,:))./2;
       else
           points{i} = (points{i-1}(1:length_after,:) + points{i+1})./2;
       end
   end
end

clear length_before length_after

% Calculate alpha-shape boundary
alpha_param = 1/alpha; % MATLAB interprets input as being 1/alpha

% Image boundaries used to remove points along the edge of the screen
% (these are the boundary of the image, not the area of interest)
max_x = size(final_clean{1},2);
max_y = size(final_clean{1},1);

for i = 1:total_frames
    toDisp = ['Bounding frame #', num2str(i)];
    disp(toDisp)
    
    % 'HoleThreshold' tells the algorithm whether to fill holes of a
    % certain size (px) within the alpha shape
    shp = alphaShape(points{i}(:,1),points{i}(:,2),alpha_param,'HoleThreshold',2000);
    [~,P] = boundaryFacets(shp);
    
    % Remove points along edge of screen
    P = P(P(:,1) > 1 & P(:,1) < max_x & P(:,2) > 1 & P(:,2) < max_y, :);
    
    boundary{i} = P;
end

clear i alpha_param max_x max_y toDisp shp P

% Greedy matching all points between timesteps
% Matching is done from the set of points in t_2 to the points in t_1 to 
% ensure all displacements have a source
for i = 1:total_frames-1
    toDisp = ['Matching frame #', num2str(i)];
    disp(toDisp)
    
    % Number of points in t_2 set
    npoints = size(boundary{i+1},1);
    % Points in t_1
    P = boundary{i};
    
    for j = 1:npoints
        % Select a point from t_2
        PQ = [boundary{i+1}(j,1) boundary{i+1}(j,2)];
        
        % Determine the distance between point PQ and all points in t_1
        k = dsearchn(P,PQ);
        
        % Resulting match is [P(k,1) P(k,2)]
        % Find dx (u), dy (v)
        dx = boundary{i+1}(j,1) - P(k,1);
        dy = boundary{i+1}(j,2) - P(k,2);
        
        % Save results
        xyuv{i} = [xyuv{i}; P(k,1) P(k,2) dx dy];
        vel_horizontal = [vel_horizontal; dx];
        vel_vertical = [vel_vertical; dy];
    end    
end

clear i P PQ npoints toDisp j k dx dy

% Spatial and temporal conversions
vel_horizontal_converted = vel_horizontal .* length_per_px .* Hz;
vel_vertical_converted = vel_vertical .* length_per_px .* Hz;

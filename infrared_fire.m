
% Fire Dynamic Vision (FDV) sample script for processing infrared data
% Created by Daryn Sagel, dsagel@fsu.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit values in the following section as needed:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load infrared data
load("infrared_fire.mat");

% Enter the total amount of time
total_time = 67; % seconds

% If not processing the entire dataset, enter start and stop times
start = 1; % seconds
stop = 40; % seconds

% Define the video's framerate (fps) and the frequency to sample (Hz)
fps = 1;
Hz = 1;

% Define the per-pixel spatial resolution
length_per_px = 0.8696; % cm/px

% Set temperature thresholding range as [lower_limit upper_limit]
% Below are sample values for this dataset, given in degrees Celsius
temperature_thresholds = [200 800];

% Define search radius and nearest neighbor thresholds for cleaning layers
% Add layers as needed! Make sure you insert code for them below.
rad2 = 15; num2 = 200; % search radius 15 px, 200 nonzero neighbors (large structures)
rad1 = 3; num1 = 5; % search radius 3 px, 5 nonzero neighbors (small structures)

% Alpha shape parameter for boundary calculation
alpha = 1/3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate how many frames are between samples
% (in case of sampling at a rate other than the video's framerate)
fphz = fps/Hz;

% Preallocate space for next steps
total_frames = (stop - start)*Hz;
final{total_frames} = [];
final_clean{total_frames} = [];
points{total_frames} = [];
boundary{total_frames} = [];
vel_horizontal = []; % list of all horizontal velocities (in px/timestep)
vel_vertical = []; % list of all vertical velocities (in px/timestep)
xyuv{total_frames-1} = []; % velocities associated with x-y coordinates

% Segment frames according to temperature thresholds
counter = 1;
for i = start*fps:fphz:stop*fps-fphz
    
    toDisp = ['Segmenting frame #', num2str(counter), ' of ', num2str(total_frames)];
    disp(toDisp)
    
    temp = temperatures(:,:,i);
    mask = temp >= temperature_thresholds(1) & temp <= temperature_thresholds(2);
    final{counter} = double(temp) .* double(mask);
    
    counter = counter + 1;
end

clear i mask toDisp counter temp

% Clean frames using hierarchical cleaning layers according to values
% defined at the top of this script
for i = 1:total_frames
    
    toDisp = ['Cleaning frame #', num2str(i)];
    disp(toDisp)
    
    temp = final{i};
    temp(temp ~= 0) = 1;
    
    clean = temp;
    clean = Cleaner(clean,rad2,num2);
    clean = Cleaner(clean,rad1,num1);
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

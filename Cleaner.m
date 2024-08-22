% Fire Dynamic Vision (FDV) function for per-layer hierarchical cleaning
% Created by Daryn Sagel, dsagel@fsu.edu

% © 2024 Daryn Sagel
% This file is part of Fire Dynamic Vision.
% This code is licensed under the MIT License.
% See the LICENSE file in the project root for license terms.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There is no need to run this script, but it should be in your current
% working directory when running infrared_fire.m, visual_fire.m, and
% visual_plume.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cleaned_mat = Cleaner(original_mat, search_radius, num_needed)

[rows, cols] = size(original_mat);

[row_idx, col_idx] = find(original_mat);
idx = [row_idx col_idx];

cleaned_mat = original_mat;

for i = 1:size(idx,1)
    leftpos_x = idx(i,1)-search_radius;
    if leftpos_x < 1
        leftpos_x = 1;
    end
    
    rightpos_x = idx(i,1)+search_radius;
    
    if rightpos_x > rows
        rightpos_x = rows;
    end
    
    uppos_y = idx(i,2)-search_radius;
    
    if uppos_y < 1
        uppos_y = 1;
    end
    
    downpos_y = idx(i,2)+search_radius;

    if downpos_y > cols
        downpos_y = cols;
    end
    
    neighbors = original_mat(leftpos_x:rightpos_x, uppos_y:downpos_y);
    numnonzero = find(neighbors);
    
    if numel(numnonzero) < num_needed
        cleaned_mat(idx(i,1), idx(i,2)) = 0;
    end
end
end


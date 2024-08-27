% Fire Dynamic Vision (FDV) function for color selection in an image
% Created by Daryn Sagel, dsagel@fsu.edu

% © 2024 Daryn Sagel
% This file is part of Fire Dynamic Vision.
% This code is licensed under the MIT License.
% See the LICENSE file in the project root for license terms.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There is no need to run this script, but it should be in your current
% working directory when running visual_fire.m and visual_plume.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [colorvals, suggestedrange] = GetImageVals(img)

toDisp = ['Press ENTER when done selecting points.'];
disp(toDisp)

imshow(img)
[x,y] = ginput;
numpts = size(x,1);

x = round(x);
y = round(y);

colorvals = zeros(numpts, 3);

for i = 1:numpts
    color = img(y(i),x(i),:);
    color = reshape(color,[1 3]);
    colorvals(i,:) = color;
end

rmin = min(colorvals(:,1));
rmax = max(colorvals(:,1));
gmin = min(colorvals(:,2));
gmax = max(colorvals(:,2));
bmin = min(colorvals(:,3));
bmax = max(colorvals(:,3));

suggestedrange = [rmin gmin bmin; rmax gmax bmax];
end


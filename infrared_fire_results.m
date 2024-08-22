% Fire Dynamic Vision (FDV) sample script for viewing infrared results
% Created by Daryn Sagel, dsagel@fsu.edu

% © 2024 Daryn Sagel
% This file is part of Fire Dynamic Vision.
% This code is licensed under the MIT License.
% See the LICENSE file in the project root for license terms.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run this script only after successfully running "infrared_fire.m" file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RUN THIS SECTION FIRST
% Run each section below depending on what you want to see!
% Click into the section you want to run and then use MATLAB's
% 'Run Section' option under the 'EDITOR' menu

% Length of time to pause between frames when viewing:
pause_time = 0.5;
% To manually advance to the next frame, leave pause empty below: pause()

%% Viewing segmented frames

figure
for i = 1:total_frames
    imshow(final{i})
    title(i)
    pause(pause_time)
end

clear i

%% View cleaned frames

figure
for i = 1:total_frames
    imshow(final_clean{i})
    title(i)
    pause(pause_time)
end

clear i

%% View calculated boundaries

figure
for i = 1:total_frames
    imshow(flipud(final_clean{i}))
    hold on
    plot(boundary{i}(:,1),boundary{i}(:,2),'co','MarkerSize',5,'MarkerFaceColor','c')
    hold off
    set(gca,'YDir','normal')
    title(i)
    pause(pause_time)
end

clear i

%% View displacements

figure
for i = 1:total_frames-1
    imshow(flipud(final{i}))
    hold on
    plot(boundary{i+1}(:,1),boundary{i+1}(:,2),'gs','MarkerSize',3,'MarkerFaceColor','g')
    plot(boundary{i}(:,1),boundary{i}(:,2),'yo','MarkerSize',3,'MarkerFaceColor','y')
    q = quiver(xyuv{i}(:,1),xyuv{i}(:,2),xyuv{i}(:,3),xyuv{i}(:,4),0,'c','LineWidth',3);
    q.ShowArrowHead = 'off';
    hold off
    set(gca,'YDir','normal')
    title(i)
    pause(pause_time)
end

clear i q

%% View semi-log histograms for horizontal and vertical velocities

% Removing 0-value entries because these correspond to motions below the
% video's spatial resolution (undetected) or areas without motion
horizontalvel = vel_horizontal_converted(vel_horizontal_converted ~= 0);
verticalvel = vel_vertical_converted(vel_vertical_converted ~= 0);

figure
subplot(1,2,1)
histogram(horizontalvel,'FaceColor',[0.3010 0.2450 0.9330],'Normalization','probability','BinWidth',Hz)
set(gca,'YScale','log')
ylabel("Occurrences")
xlabel("Horizontal Velocity (length/timestep)")
title(['Hz: ',num2str(Hz),', Mean: ',num2str(mean(horizontalvel)),', Samples: ', num2str(numel(horizontalvel))])

subplot(1,2,2)
histogram(verticalvel,'FaceColor',[1.0 0.750 0.70],'Normalization','probability','BinWidth',Hz)
set(gca,'YScale','log')
%ylim([0 1])
%xlim([-40 60])
ylabel("Occurrences")
xlabel("Vertical Velocity (length/timestep)")
title(['Hz: ',num2str(Hz),', Mean: ',num2str(mean(verticalvel)),', Samples: ', num2str(numel(verticalvel))])

clear horizontalvel verticalvel

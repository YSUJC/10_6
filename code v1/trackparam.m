%% Use this script to load sequence and initial parameters. 
%%
%% Change 'title' to choose the sequence you wish to run.
%%
%% Setting dump_frames to true will cause all of the tracking results
%% to be written out as .jpg images in the subdirectory ./result/title.

%% select sequence
title = 'ShopAssistant2cor';
% title = 'OneStopEnter2cor';
% title = 'ThreePastShop2cor';
% title ='camera1';

%% save results or not 
dump_frames = true;     %% or false
opt.dump = dump_frames;

%% specific parameters for each sequence
%% p = [x y width height rotation];
switch (title)
    case 'camera1';         p = [17,214,13,38,0.0];  
    case 'ThreePastShop2cor';  p = [235,188,38,120,0.00];
    case 'OneStopEnter2cor';  p = [120,52,18,52,0.00];                                                                                      
    case 'ShopAssistant2cor';  p = [151,66,20,60,0.00];               
    otherwise;  error(['unknown title ' title]);
end

%% load images
dataPath = ['data\' title '\'];

%% create folder
if ~isdir(['results/' title])
    mkdir('results/', title);
end


function [new_h, new_w] = update_hw(img, p, label, th, fb_ratio1, fb_ratio2)
%% function [new_h, new_w] = update_hw(img, p, h, w, label, th, fb_ratio1,
%% fb_ratio2)
%%
%% Call this function to adjust the size of tracking window 
%% 
%% Function specification:
%% Input
%%      img             :        original frame
%%      p               :        similarity parameters of the object in 1st
%%                               frame. p = [x y width height rotation]
%%      label           :        label for training image
%%      th              :        ratio of the size of the current tracking 
%%                               window to that of the tracking window in 
%%                               1st frame
%%      fb_ratio1       :        number of "dark" pixels in the
%%                               foreground in 1st frame
%%      fb_ratio2       :        number of "bright" pixels in the
%%                               background in 1st frame
%% Output
%%      new_h           :       new height
%%      new_w           :       new width
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 12/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

%% current numbers of "bright" pixels and "dark" pixels 
[a b c] = size(img);
y1 = a/2; x1 = b/2;
h1=p(4);w1=p(3);
bg = img(uint8(y1-p(4)/2-p(4)/6+1:y1+p(4)/2+p(4)/6), uint8(x1-p(3)/2-p(3)/6+1:x1+p(3)/2+p(3)/6));
fg = img(y1-p(4)/2+1:y1+p(4)/2, x1-p(3)/2+1:x1+p(3)/2);
img = img(:)';
fga = img(find(label==1));
bga = img(find(label==-1));
bg(y1-p(4)/2+1:y1+p(4)/2, x1-p(3)/2+1:x1+p(3)/2) = max(fga)-100;
bg = bg(:);
bg_bg = sum(abs(max(fga)-bg)<50);
fg(uint8(y1-p(4)/2+p(4)/6+1:y1+p(4)/2-p(4)/6), uint8(x1-p(3)/2+p(3)/6+1:x1+p(3)/2-p(3)/6)) = 255;
fg = fg(:);
fg_fg = sum(abs(fg-min(bga))<50); 
fb_ratio1_new = fg_fg;
fb_ratio2_new = bg_bg;

%% change of "bright" pixels and "dark" pixels 
delta1 = fb_ratio1_new - fb_ratio1;
delta2 = fb_ratio2_new - fb_ratio2;

alpha = 1;      %% percentage of change
smooth = 0.3;   %% smoothness term

%% the change is slight and ignorable
if abs(delta1) <= 5 && abs(delta2) <= 5
    new_h = th*h1; new_w = th*w1;
    return;
end

%% the tracking window is bigger than the true target
if delta1 > delta2
    alpha = sqrt(1-abs(delta1)/(h1*w1));
end

%% the tracking window is smaller than the true target
if delta2 > delta1
    alpha = sqrt(abs(delta2)/(h1*w1)+1);
end

%% new height and new width 
new_h = ceil((alpha + (1-alpha)*smooth)*h1*th);
new_w = ceil((alpha + (1-alpha)*smooth)*w1*th);

function [ry, w, pos, neg] = boost_softseg(img, x0, label)
%% function [ry, w, pos, neg] = boost_softseg(img, x0, label)
%%
%% Call this function to run BCSS 
%% 
%% Function specification:
%% Input
%%      img            :       original frame
%%      x0             :       a vector of image after reshape
%%      label          :       label for training samples
%% Output
%%      ry             :       image after BCSS 
%%      w              :       weight vector of BCSS
%%      pos            :       statistical information of positive samples
%%                             1st column is mean and 2nd column is
%%                             variance
%%      neg            :       statistical information of negative samples
%%                             1st column is mean and 2nd column is
%%                             variance
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 12/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

[a b c] = size(img);
fg = x0(:,find(label==1));
bg = x0(:,find(label==-1));
fg_m = mean(fg,2); fg_o = var(fg,0,2);
bg_m = mean(bg,2); bg_o = var(bg,0,2);
pos = [fg_m fg_o];
neg = [bg_m bg_o];

%% boosting
w = wlearner(x0, label, pos, neg);

%% projection
y0 = w'*x0;
ma_ = max(y0(:));
mi_ = min(y0(:));
yy = 255 * (y0-mi_) / (ma_-mi_);
ry = reshape(yy,a,b);


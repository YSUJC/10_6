%% BCSS and ICA-R Tracking Main Entry
%%
%% For more details, refer to
%%      Fan Yang, Huchuan Lu and Yen-Wei Chen, Robust Tracking Based on Boosted Color 
%%      Soft Segmentation and ICA-R£¬International Conference on Image Processing (ICIP), 
%%      Hong Kong, 2010.
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of Technology, China
%% Date: 12/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

clc;
clear;
trackparam;                                     %% load initial parameters
warning('off');
temp = importdata([dataPath 'datainfo.txt']);
LoopNum = temp(3);                              %% frame number
iframe = imread([dataPath '1.jpg']);
sz = size(iframe);                              %% frame size
bin = 256;                                      
y=p(2);x=p(1);h=p(4);w=p(3);                    %% center points, height and width
s = [h w];
drawopt = [];

%% extract object region
bound1 = min(min([h,h],[y,sz(1)-y]));
bound2 = min(min([w,w],[x,sz(2)-x]));
img = iframe(y-bound1+1:y+bound1,x-bound2+1:x+bound2,:);

%% generate reference signal r
r = zeros(bound1*2,bound2*2);
offset = 3;
r(bound1-offset:bound1+offset, bound2-offset:bound2+offset) = 255;

%% pre-processing
img = double(img);
[a b c] = size(img);
mp = max(img,[],3);
img = img ./ (repmat(mp,[1 1 3])+250);
x0(1,:) = reshape(img(:,:,1),1,a*b);
x0(2,:) = reshape(img(:,:,2),1,a*b);
x0(3,:) = reshape(img(:,:,3),1,a*b);
label = -ones(a,b);
label(a/2-h/2+1:a/2+h/2, b/2-w/2+1:b/2+w/2, :) = 1;
label = label(:)';

[yi, w_ica] = ica_r(img, x0, r);                        %% ICA-R projection
[ys, w_ss, pos, neg] = boost_softseg(img, x0, label);   %% Boosted Color 
                                                        %% Soft
                                                        %% Segmentation

%% image with pixel value ranging [0,1] after ICA-R projection
ma_ = max(yi(:));
mi_ = min(yi(:));
Yi = (yi-mi_) / (ma_-mi_);

%% image with pixel value ranging [0,1] after BCSS projection
ma_ = max(ys(:));
mi_ = min(ys(:));
Ys = (ys-mi_) / (ma_-mi_);

%% fusion
Y = exp(-(Yi-1).^2 / 0.2) .* exp(-(Ys-1).^2 / 0.2);

%% convert the joint probabilisitc map to a gray image
ma_ = max(Y(:));
mi_ = min(Y(:));
Yy = 255*(Y-mi_) / (ma_-mi_);
ry = reshape(Yy,a,b);
obj = ry(a/2-h/2+1:a/2+h/2,b/2-w/2+1:b/2+w/2);      %% object region

%% initial foreground pixels and background pixels 
ry1 = ry(:)';
fg = ry1(find(label==1));
bg = ry1(find(label==-1));
th = (mean(fg)+mean(bg))/2;

%% update parameters
lr_ica = 5; lr_ss = 5; lr_scale=5;
ff = 0.9; eta = 0.5;
up_flag = 1;
tmp_zero = zeros(size(img));

%% draw results
drawopt = drawtrackresult(drawopt, 1, uint8(iframe), [h w], [y x]);

%% store results
rst = [x y w h];

%% tracking starts
for f = 2:LoopNum
    frame = imread([dataPath int2str(f) '.jpg']);
    
    %% compute ICA-R and BCSS projection 
    yi = proj(frame, w_ica);
    ys = proj(frame, w_ss);
    
    %% compute the joint probabilistic map
    ma_ = max(yi(:));
    mi_ = min(yi(:));
    Yi = (yi-mi_) / (ma_-mi_);
    ma_ = max(ys(:));
    mi_ = min(ys(:));
    Ys = (ys-mi_) / (ma_-mi_);
    Y = exp(-(Yi-1).^2 / 0.2) .* exp(-(Ys-1).^2 / 0.2);
    ma_ = max(Y(:));
    mi_ = min(Y(:));
    Yy = 255*(Y-mi_) / (ma_-mi_);
    ry = reshape(Yy,sz(1),sz(2));
    
    %% meanshift
    targetLocation = [y x];
    targetWindowSize = [h w];
    iterativeNum = 0;     
    maxIterativeNum = 10;
    o_r_min = targetLocation(1)-targetWindowSize(1)/2;   
    o_r_max = targetLocation(1)+targetWindowSize(1)/2;
    o_c_min = targetLocation(2)-targetWindowSize(2)/2;   
    o_c_max = targetLocation(2)+targetWindowSize(2)/2;   
    while (iterativeNum<maxIterativeNum)       
        temp = ry(o_r_min:o_r_max,o_c_min:o_c_max);
        sumTemp = sum(sum(temp));
        targetLocation(1) = round([o_r_min:o_r_max]*sum(temp')'/sumTemp);
        targetLocation(2) = round([o_c_min:o_c_max]*sum(temp )'/sumTemp);
        targetLocation(1) = targetLocation(1) - (max(sz(1),targetLocation(1)+targetWindowSize(1)/2)-sz(1));
        targetLocation(2) = targetLocation(2) - (max(sz(2),targetLocation(2)+targetWindowSize(2)/2)-sz(2));
        targetLocation(1) = targetLocation(1) - min(0,targetLocation(1)-targetWindowSize(1)/2-1);
        targetLocation(2) = targetLocation(2) - min(0,targetLocation(2)-targetWindowSize(2)/2-1);
        o_r_min = targetLocation(1)-targetWindowSize(1)/2;   o_r_max = targetLocation(1)+targetWindowSize(1)/2;
        o_c_min = targetLocation(2)-targetWindowSize(2)/2;   o_c_max = targetLocation(2)+targetWindowSize(2)/2; 
        iterativeNum = iterativeNum + 1;
    end
    targetLocation = [ round(0.5*o_r_min+0.5*o_r_max) round(0.5*o_c_min+0.5*o_c_max) ];
    
    %% new center
    x = targetLocation(2);
    y = targetLocation(1);

    %% determine the nmubers of "bright" pixels in the background 
    %% and "dark" pixels in the foreground for 1st time
    bound1 = min(min([h,h],[y,sz(1)-y]));
    bound2 = min(min([w,w],[x,sz(2)-x]));
    if ~exist('fb_ratio1') && ~exist('fb_ratio2')
        ry = double(ry(y-bound1+1:y+bound1,x-bound2+1:x+bound2));
        ry = imresize(ry, [a b], 'nearest');
        ry1 = ry(:)';
        fga = ry1(find(label==1));
        bga = ry1(find(label==-1));
        fg_fg = sum(abs(fg-min(bg))<50);
        y1 = a/2; x1 = b/2;
        bg = ry(uint8(y1-p(4)/2-p(4)/6+1:y1+p(4)/2+p(4)/6), uint8(x1-p(3)/2-p(3)/6+1:x1+p(3)/2+p(3)/6));
        bg(y1-p(4)/2+1:y1+p(4)/2, x1-p(3)/2+1:x1+p(3)/2) = max(fga)-100;
        bg = bg(:);
        bg_bg = sum(abs(max(fga)-bg)<50);
        fg = ry(y1-p(4)/2+1:y1+p(4)/2, x1-p(3)/2+1:x1+p(3)/2);
        fg(uint8(y1-p(4)/2+p(4)/6+1:y1+p(4)/2-p(4)/6), uint8(x1-p(3)/2+p(3)/6+1:x1+p(3)/2-p(3)/6)) = 255;
        fg = fg(:);
        fg_fg = sum(abs(fg-min(bga))<50); 
        fb_ratio1 = fg_fg;
        fb_ratio2 = bg_bg; 
    end
    
    %% scale change 
    if mod(f,lr_scale) == 0 && up_flag
        new_img = double(ry(y-bound1+1:y+bound1,x-bound2+1:x+bound2));
        new_img = imresize(new_img, [a b], 'nearest');
        th = sqrt(h*w/((p(3)*p(4))));
        [h, w] = update_hw(new_img, p, label, th, fb_ratio1, fb_ratio2);   %% detemine the change of size
    end
    targetWindowSize = [h w];           %% new height and width
    
    %% image accumulate
    nimg = double(frame(y-bound1+1:y+bound1,x-bound2+1:x+bound2,:));
    nimg = imresize(nimg, [a b], 'nearest');
    img = (img + nimg)/2;              

    %% update ICA-R weight vector
    if mod(f,lr_ica) == 0
        timg = img ./ (repmat(mp,[1 1 3])+250);
        x0(1,:) = reshape(timg(:,:,1),1,a*b);
        x0(2,:) = reshape(timg(:,:,2),1,a*b);
        x0(3,:) = reshape(timg(:,:,3),1,a*b);
        [yi, w_ica_new] = ica_r(timg, x0, r);
        w_ica = w_ica + 0.5*w_ica_new;
    end
    
    %% update BCSS weight vector
    if mod(f,lr_ss) == 0
        timg = img ./ (repmat(mp,[1 1 3])+250);
        x0(1,:) = reshape(timg(:,:,1),1,a*b);
        x0(2,:) = reshape(timg(:,:,2),1,a*b);
        x0(3,:) = reshape(timg(:,:,3),1,a*b);    
        [ry, w_ss_new, pos, neg] = boost_softseg(timg, x0, label);
        w_ss = w_ss + 0.5*w_ss_new;
    end
    
    rst = [rst; x y w h];       %% save results
    drawopt = drawtrackresult(drawopt, f, uint8(frame), targetWindowSize, targetLocation);
    if (isfield(opt,'dump') && opt.dump > 0)
        imwrite(frame2im(getframe(gcf)),sprintf('results/%s/%s.%04d.jpg',title,title,f));
    end
end

%% store results
strFileName = sprintf('results/%s.mat', title);
save(strFileName, 'rst');

    


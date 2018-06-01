function w = wlearner(data, label, pos, neg)
%% function w = weaklearner(data, label, pos, neg)
%%
%% Call this function to run boosting to obtain 
%% the weight vector w
%% 
%% Function specification:
%% Input
%%      data            :       input training data
%%      label           :       label for training data
%%      pos             :       statistical information of positive samples
%%                              1st column is mean and 2nd column is
%%                              variance
%%      neg             :       statistical information of negative samples
%%                              1st column is mean and 2nd column is
%%                              variance
%% Output
%%      w               :       weight vector
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 12/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com> 

[dim,num_data] = size(data);
d = ones(1,num_data)/num_data;
W = zeros(dim,1);
Errors = zeros(dim,1);
iter_num = 10;
alpha = ones(iter_num,1);
y = zeros(dim,num_data);
p_mean = pos(:,1); p_theta2 = pos(:,2);
n_mean = neg(:,1); n_theta2 = neg(:,2);
w = zeros(dim,1);

for t = 1:iter_num
    ii = zeros(dim,1);
    for i = 1:dim
        x = data(i,:);  
        y(i,:) = sign(exp(0.5*(x-p_mean(i)).^2/p_theta2(i)) - exp(0.5*(x-n_mean(i)).^2/n_theta2(i))); 
        err = sum((y(i,:) ~= label) .* d);      
        [minerr1,inx1] = min(err);           
        [minerr2,inx2] = min(1-err);
        if minerr1 < minerr2,
            W(i) = 1;         
            Errors(i) = minerr1;         
        else
            W(i) = - 1;
            Errors(i) = minerr2;         
        end
    end                   
    [et,inx] = min(Errors);
    alpha(t) = 0.5*log((1-et)/et);
    yh = W(inx).*y(inx,:).*label;
    d = d .* exp(-alpha(t)*yh);
    d = d/sum(d);
    ii(inx) = ii(inx)+1;
    w = w + alpha(t)*W(inx)*ii;
end


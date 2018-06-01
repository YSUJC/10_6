function y = proj(I, w)
%% function y = proj(I, w)
%%
%% Call this function to map an image using weight vector w 
%% 
%% Function specification:
%% Input
%%      I            :       original frame
%%      w            :       computed weight vector of BCSS or ICA-R
%% Output
%%      y            :       projected image
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 12/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

I=double(I);
c1=I(:,:,1)/255;
c2=I(:,:,2)/255;
c3=I(:,:,3)/255;

[a,b]=size(c1);         

c1=reshape(c1,1,a*b);
c2=reshape(c2,1,a*b);
c3=reshape(c3,1,a*b);

x(1,:) = c1;
x(2,:) = c2;
x(3,:) = c3;
len=a*b; 

%% remove the mean center the mixture  
x = x - mean( x,2 )* ones( 1, len );

%% whiten the observed signals  
[ Ex, Dx ] = eig( cov( x' ) );
Q = sqrt( inv( Dx ) ) * Ex';
x = Q * x;

%% projection
y = w' * x;

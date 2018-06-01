function [ry, w_new] = ica_r(img, x0, r)
%% function [ry, w_new] = ica_r(img, x0, r)
%%
%% Call this function to perform ICA-R
%% Deatails please refer to 
%% Q.H. Lin, Y.R. Zheng, F.L. Yin, H. Liang, and V.D. Cal-
%% houn, "A fast algorithmfor one-unit ICA-R," Information
%% Sciences, vol. 177, no. 5, pp. 1265¨C1275, 2007.
%% 
%% Function specification:
%% Input
%%      img            :       original frame
%%      x0             :       a vector of image after reshape
%%      r              :       reference signal
%% Output
%%      ry             :       image after ICA-R 
%%      w_new          :       weight vector of ICA-R
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 12/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

%% read input signal
x = x0;
r=double(r);
r=r(:)';
[a,b,c]=size(img);     

len=a*b;   
%% remove the mean center the mixture
x = x - mean( x, 2 )* ones( 1, len );

%% whiten the observed signals 
[ Ex, Dx ] = eig( cov( x' ) );
Q = sqrt( inv( Dx ) ) * Ex';
x = Q * x;
[ m, n ] = size( x );

%% generate gaussian random variety v 
v = randn( 1, len );
v = v - mean( v ) * ones( size( v ) );
v = v / sqrt( var ( v ) );

%% seting and initializing some parameters
gamma = 0.3;
w_new = zeros( m, 1);
w_old = zeros( m, 1);
w_plus = zeros(m, 1);
mu = 0.4;
max_iterat = 70;    
iterat = 0;          
rho = 0.7;
xi = 0.001;             %% threshold
eta = 0.5;
y = zeros(1, len);      %% output signal
Delta_L = zeros(m, 1);
epsilon_IPI = 2e-2;     %% decision threshold
look = [];
ort = 1;

%% main iteration
while iterat < max_iterat && abs(ort-1)<1e-8
    y = w_new' * x;
    G_y = exp( -y.^2 / 2 );
    G_v = exp( -v.^2 / 2 );
    rho =  mean( G_y ) - mean( G_v );
    g_w = (y-r)*(y-r)' - xi;
    mu = max( 0, mu + gamma * g_w );
    D_G   =  -y .* exp( -y.^2 / 2 );
    D_D_G = ( y.^2 - ones( size( y ) ) ) .* exp( -y .^2 / 2 );
    D_g   =  2*(y-r);
    D_D_g =  2;
    D_L   =  rho * mean( x .*( ones( m, 1) * D_G), 2) - 0.5 * mu  * mean( x.*(ones(m,1)*D_g), 2);
    D_w   =  rho * mean( D_D_G ) - 0.5 * mu * D_D_g;
    w_old = w_new;
    w_plus = w_old -eta*D_L/D_w;
    w_new = w_plus./norm(w_plus,2);
    iterat = iterat + 1;
    ort = w_old'*w_new;
end

%% projection
y = w_new'*x;
ma_ = max(y(:));
mi_ = min(y(:));
yy = 255 * (y-mi_) / (ma_-mi_);
ry = reshape(yy,a,b);

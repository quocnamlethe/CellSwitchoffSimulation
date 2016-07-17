function [SIRMeric]=SIR_RayleighCh2(BS_Locations,User_locations, n, Sigma_dB, SIRMericType)
% n: path loss exponent 
if nargin <3
    n=4;
end
if nargin <4
      Sigma_dB=0;
end

if nargin <5
    SIRMericType='SIR'; 
end
% global UsersIn
% ModelParamters.lambda=UsersIn*10^-6;
% Win=ModelParamters.Win;
% % Wind2=(1-2/sqrt(size(BS_Locations,1)))*Win; 
% Wind2=Win; 
% ModelParamters.Win=Wind2;
% 
%               
%               
% [User_locations]= PointProcess('BPP' , ModelParamters);
%==========
% User_locations=User_locations(1:UsersIn,:);

D=pdist2(BS_Locations,User_locations); % euclidean distance
LB=size(D,1); Lu=size(D,2);
Flag=zeros(LB,Lu); 
[D_min,ind] = min(D); %  min(D,[], 2) returns a column vector containing the smallest element in each row
% all signals experiance Rayleigh fading with mean 1
for j=1:Lu
    Flag(ind(j), j)=1;
end

mu=1; 
% [N_BSs]=size(BS_Locations,1); 
Fading=exprnd(mu,LB,Lu); % vector independent exponential random variable with mean mu=1
                    % Rayleigh fading with mean 1 
% find(min(Distanaces))
% Sigma_dB=0; % sigma_dB : Variance[dB]
Shadowing=10.^(Sigma_dB*randn(LB,Lu)/10); % % Log-distance or Log-normal shadowing
HD=Fading.*(D.^-n).*Shadowing; 

P=sum(HD.*Flag); 
I=sum(HD.*~Flag); 

% I=D.^-alpha*h-P;
SIR=P./I; 
SIR=SIR'; 
% Avg_SIR=mean(SIR);
SIR_dB=10*log10(SIR);
switch SIRMericType
    case 'SIR'
      SIRMeric=SIR_dB;  
    case 'MedianSIR'
SIRMeric=median(SIR_dB); 
% DeploymentGain=median(SIR_dB)-10*log10(1.351); 
    case 'MeanSIR'
SIRMeric=mean(SIR_dB); 
end

end

% syms x
% eqn1=sqrt(x)*(pi/2-atan(1/sqrt(x)))==1;
% solx = solve(eqn1,x);
% % result
% % solx=1.351
% 
% solx_dB=10*log10(solx);
% % Result
% % solx_dB10=1.3 




%  /* Copyright (C) 2016 Faraj Lagum @ Carleton University - All Rights Reserved
%   You may use and modify this code, but not to distribute it.  
%  If You don't have a license to use this code, please write to:
%  faraj.lagum@sce.carleton.ca. */


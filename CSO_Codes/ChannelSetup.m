function ChannelParamters=ChannelSetup()
% Type of models




% [1] Peterbed lattice models 
% hexUni        Hexagonal Layout with uniform perterbation 
% hexGau        Hexagonal Layout with Gaussian perterbation 
% sqUni         Square layout with uniform perterbation
% sqGau         Square layout with Gaussian perterbation
% SSI
% MHCI
% MHCII

% defaults
n=4;    % Path-loss Exponent 
Sigma_dB=0; % Log-distance or Log-normal shadowing in [dB]; e.g Sigma_dB=6 [dB]  
SIRMericType='SIR'; % Other options: MedianSIR and MeanSIR;              
AssociationType='ClosestBS'; %   Other options:StrongestBS





ChannelParamters=struct('n', n, ...
                  'Sigma_dB', Sigma_dB, ...
                  'SIRMericType', SIRMericType, ...
                  'AssociationType',AssociationType);              
end

%  /* Copyright (C) 2016 Faraj Lagum @ Carleton University - All Rights Reserved
%   You may use and modify this code, but not to distribute it.  
%  If You don't have a license to used this code, please write to:
%  faraj.lagum@sce.carleton.ca. */
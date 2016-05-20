%function Example 
%======= Base Stations ======%
 BS_ModlPrmtrs=ModelParaSet();        
 BS_ModlPrmtrs.lambda=100*10^-6;          
 BS_ModlPrmtrs.alpha_norm=0;             
[Bs_Locations]= UT_LatticeBased('hexUni' , BS_ModlPrmtrs); 

%===========================%
%===== Users ===============%
 UsersIn=150;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 BS_ModlPrmtrs.alpha_norm=2;
 [User_Locations]=UT_LatticeBased('hexUni', User_ModlPrmtrs); 
%  [Bs_Locations]= UT_PPP('BPP' , User_ModlPrmtrs); 

 % =====Channed ===========
%  Exponent=4; %pathloss Exponent
%  Shadow= 6; % [dB]  % Log-distance or Log-normal shadowing
%  
ChannelParamters=ChannelSetup(); 
ChannelParamters.AssociationType='StrongestBS'; 

 %======= Simulation =========
 Drops=50;
 %=========
 
% [CN, CV, CD] = CoV_Metrics(Bs_Locations, BS_ModlPrmtrs); %disp(CoV)



% [SIR_dB]=SIR_RayleighCh3(Bs_Locations, User_Locations, ChannelParamters);
%=====================
BigNumber=UsersIn*Drops*2; % it just to reserve more than enough matrix
SIR_dB=zeros(BigNumber,1); 
%====================
totalsofar=0;
for idrop=1:Drops
     
     [Bs_Locations]= UT_LatticeBased('hexUni' , BS_ModlPrmtrs);
     
     [User_Locations]=UT_LatticeBased('hexUni', User_ModlPrmtrs);
     UL=size(User_Locations,1); 
     i_BlockIndex=1+totalsofar:totalsofar+UL;  


[SIR_dB(i_BlockIndex)]=SIR_RayleighCh3(Bs_Locations, User_Locations, ChannelParamters);
    totalsofar=totalsofar+UL; 
    
end

SIR_dB=SIR_dB(1:totalsofar); 
Median_SIR=median(SIR_dB); 

%  /* Copyright (C) 2016 Faraj Lagum @ Carleton University - All Rights Reserved
%   You may use and modify this code, but not to distribute it.  
%  If You don't have a license to use this code, please write to:
%  faraj.lagum@sce.carleton.ca. */


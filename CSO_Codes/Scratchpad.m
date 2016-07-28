load('data/Test_SOvsSIRData2.mat', 'CsoTest');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;
ModelParameters.metric = 'CD';

% Initialize channel parameters
ChannelParamters = ChannelSetup(); 
ChannelParamters.AssociationType = 'StrongestBS';
ChannelParamters.SIRMericType = 'SIR';

coveragePercentage = 5;
percentSO = 0:0.05:0.9;

% Initialize Users
UsersIn=10000;
User_ModlPrmtrs=ModelParaSet();        
User_ModlPrmtrs.lambda=UsersIn*10^-6;
User_ModlPrmtrs.win=ModelParameters.win * 0.6;
BS_ModlPrmtrs.alpha_norm=2;

SIRData = zeros(570,2);

% Generate user locations
[User_Locations]=UT_LatticeBased('hexUni', User_ModlPrmtrs);

for j = 1:length(SIRData)
     SIR_dB = SIR_RayleighCh3(CsoTest.TestBs(2).RawData(j).ActiveBs,User_Locations,ChannelParamters);
     SIRData(j,1) = CsoTest.TestBs(2).RawData(j).SwitchOff;
     SIRData(j,2) = prctile(SIR_dB,coveragePercentage);
end

k = 2;
SirTemp = zeros(10,3);
for m = 1:length(percentSO)
    SirIndex = find(SIRData(:,1) == percentSO(m));
    avgSirData = nanmean(SIRData(SirIndex,2));
    avgSO = nanmean(SIRData(SirIndex,1));
    SirTemp(m+1,:) = [percentSO(m), avgSirData, avgSO];
end
CsoTest.TestBs(k).TestPlot(l).SirData = SirTemp;
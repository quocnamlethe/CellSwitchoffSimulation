ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          
ModelParameters.alpha_norm = 0;
CsoTest = CsoTestSet(4);
CsoTest.ModelParameters = ModelParameters;

[Bs_Locations]= UT_LatticeBased('hexUni' , ModelParameters);

CsoTest.ModelParameters = ModelParameters;
CsoTest.InitialBs.ActiveBs = Bs_Locations;

% Initialize channel parameters
ChannelParamters = ChannelSetup(); 
ChannelParamters.AssociationType = 'StrongestBS';
ChannelParamters.SIRMericType = 'SIR';

% Initialize Users
UsersIn=10000;
User_ModlPrmtrs=ModelParaSet();        
User_ModlPrmtrs.lambda=UsersIn*10^-6;
User_ModlPrmtrs.win=[-400,400,-400,400];
BS_ModlPrmtrs.alpha_norm=2; %TODO: Changed from 2

% Generate user locations
[User_Locations]=UT_LatticeBased('hexUni', User_ModlPrmtrs);

[CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
CsoTest.InitialBs.CN = CN;
CsoTest.InitialBs.CV = CV;
CsoTest.InitialBs.CD = CD;

for k = 1:4
    CsoTest.TestBs(k).ActiveBs = Bs_Locations;
    CsoTest.TestBs(k).InactiveBs = [];
    CsoTest.TestBs(k).CN = CN;
    CsoTest.TestBs(k).CV = CV;
    CsoTest.TestBs(k).CD = CD;
end

CsoTest.TestBs(1) = GreedyDeletion(CsoTest.TestBs(1),0.33);
CsoTest.TestBs(2) = GenieAidedSO(CsoTest.TestBs(2),0.33,ModelParameters);

for k = 1:4
    [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
    CsoTest.TestBs(k).CN = CN;
    CsoTest.TestBs(k).CV = CV;
    CsoTest.TestBs(k).CD = CD;
end

[SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(1).ActiveBs,User_Locations,ChannelParamters);
SIR_dB = prctile(SIR_dB,95);
fprintf('Greedy Delete: %f\n',SIR_dB);
[SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(2).ActiveBs,User_Locations,ChannelParamters);
SIR_dB = prctile(SIR_dB,95);
fprintf('Genie: %f\n',SIR_dB);

save(strcat('data/testing',num2str(1),'.mat'), 'CsoTest');
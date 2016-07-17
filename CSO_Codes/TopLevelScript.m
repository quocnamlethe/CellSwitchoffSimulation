ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          
ModelParameters.alpha_norm = 0;
CsoTest = CsoTestSet(4);
CsoTest.ModelParameters = ModelParameters;

[Bs_Locations]= UT_LatticeBased('hexUni' , ModelParameters);

CsoTest.ModelParameters = ModelParameters;
CsoTest.InitialBs.ActiveBs = Bs_Locations;

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

CsoTest.TestBs(1) = MaxRegSoWithShift(CsoTest.TestBs(1),1/3,ModelParameters);
CsoTest.TestBs(2) = GenieAidedSO(CsoTest.TestBs(2),1/3,ModelParameters);

for k = 1:4
    [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
    CsoTest.TestBs(k).CN = CN;
    CsoTest.TestBs(k).CV = CV;
    CsoTest.TestBs(k).CD = CD;
end

save(strcat('data/testing',num2str(1),'.mat'), 'CsoTest');
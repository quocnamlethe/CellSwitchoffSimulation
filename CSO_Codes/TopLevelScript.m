ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          
ModelParameters.alpha_norm = 0.6;
CsoTest = CsoTestSet();
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

CsoTest.TestBs(1) = MinEdgeSO(CsoTest.TestBs(1),0.50);

for k = 1:4
    [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
    CsoTest.TestBs(k).CN = CN;
    CsoTest.TestBs(k).CV = CV;
    CsoTest.TestBs(k).CD = CD;
end

save(strcat('data/testing',num2str(1),'.mat'), 'CsoTest');
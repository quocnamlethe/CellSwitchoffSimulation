% load('data/CsoTest1.mat', 'CsoTest');
% 
% CsoTest.TestBs(1).ActiveBs = CsoTest.InitialBs;
% CsoTest.TestBs(1).InactiveBs = [];

ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          
ModelParameters.alpha_norm = 0.5;

CsoTest = CsoTestSet();
CsoTest.ModelParameters = ModelParameters;

for j = 1:10
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

%     for k = 1:50
%         DD = pdist2(CsoTest.TestBs(1).ActiveBs, CsoTest.TestBs(1).ActiveBs);
%         DD(DD==0) = inf;
%         [Nearest,index] = min(DD);
%         [point, index] = min(Nearest);
%         CsoTest.TestBs(1).InactiveBs = [CsoTest.TestBs(1).InactiveBs; CsoTest.TestBs(1).ActiveBs(index,:)];
%         CsoTest.TestBs(1).ActiveBs(index,:) = [];
%     end

    CsoTest.TestBs(1) = MinDistSO(CsoTest.TestBs(1),0.50);
    CsoTest.TestBs(2) = NumNearestSO(CsoTest.TestBs(2),0.50);
    
    for k = 1:2
        [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
        CsoTest.TestBs(k).CN = CN;
        CsoTest.TestBs(k).CV = CV;
        CsoTest.TestBs(k).CD = CD;
    end

    save(strcat('data/testing',num2str(j),'.mat'), 'CsoTest');
end

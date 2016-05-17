% Wait bar
hwait = waitbar(0,'Calculating');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          

% Initialize the test set
testNum = 5;
CsoTest = CsoTestSet(testNum);

warning off;
for m = 1:9
    % Variable switch off percentage
    percentSO = 0.1 * m;
    
    % Initialize the testPlot structure for each test method
    for k = 1:testNum
        testPlot = CsoTest.TestBs(k).TestPlot;
        testPlot = [testPlot, TestPlotSet(strcat(num2str(percentSO*100),'%'))];
        CsoTest.TestBs(k).TestPlot = testPlot;
    end
    
    % Test for incrementing perturbation values
    for l = 0:10
        waitbar(((m - 1)*11 + l)/(9*11),hwait);
        ModelParameters.alpha_norm = 0.1 * l;
        CsoTest.ModelParameters = ModelParameters;

        % Test 10 times per perturbation value
        for j = 1:10
            % Generate base station locations
            [Bs_Locations]= UT_LatticeBased('hexUni' , ModelParameters);

            % Set up the initial base station locations and CoVs
            CsoTest.InitialBs.ActiveBs = Bs_Locations;
            [CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
            CsoTest.InitialBs.CN = CN;
            CsoTest.InitialBs.CV = CV;
            CsoTest.InitialBs.CD = CD;

            % Initialize the test structures
            for k = 1:testNum
                CsoTest.TestBs(k).ActiveBs = Bs_Locations;
                CsoTest.TestBs(k).InactiveBs = [];
                CsoTest.TestBs(k).CN = CN;
                CsoTest.TestBs(k).CV = CV;
                CsoTest.TestBs(k).CD = CD;
            end

            % Run SO algorithms on the base station locations
            CsoTest.TestBs(1) = AverageNearestSO(CsoTest.TestBs(1),percentSO,1);
            CsoTest.TestBs(2) = AverageNearestSO(CsoTest.TestBs(2),percentSO,2);
            CsoTest.TestBs(3) = NumNearestSO(CsoTest.TestBs(3),percentSO);
            CsoTest.TestBs(4) = MinVoronoiSO(CsoTest.TestBs(4),percentSO,ModelParameters);
            CsoTest.TestBs(5) = MaxRegSo(CsoTest.TestBs(5),percentSO,ModelParameters);

            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:testNum
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
                CsoTest.TestBs(k).CN = CN;
                CsoTest.TestBs(k).CV = CV;
                CsoTest.TestBs(k).CD = CD;
                
                CnData = CsoTest.TestBs(k).TestPlot(m).CnData;
                CnData = [CnData ; CsoTest.InitialBs.CN, CN];
                CsoTest.TestBs(k).TestPlot(m).CnData = CnData;
                
                CvData = CsoTest.TestBs(k).TestPlot(m).CvData;
                CvData = [CvData ; CsoTest.InitialBs.CV, CV];
                CsoTest.TestBs(k).TestPlot(m).CvData = CvData;
                
                CdData = CsoTest.TestBs(k).TestPlot(m).CdData;
                CdData = [CdData ; CsoTest.InitialBs.CD, CD];
                CsoTest.TestBs(k).TestPlot(m).CdData = CdData;
            end
        end
    end
end
warning on;

save('data/TestData.mat', 'CsoTest');
close(hwait);

PlotTestPoints();

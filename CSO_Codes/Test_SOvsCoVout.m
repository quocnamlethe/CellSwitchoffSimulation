% Wait bar
hwait = waitbar(0,'Calculating');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          

% Initialize the test set
testNum = 5;
CsoTest = CsoTestSet(testNum);
Cov = zeros(1,10);
CovAvg = zeros(1,5);

warning off;
for l = 1:5
    % Test for incrementing perturbation values
    ModelParameters.alpha_norm = 0.25 * l - 0.25;
    CsoTest.ModelParameters = ModelParameters;
    
    % Initialize the testPlot structure for each test method
    for k = 1:testNum
        testPlot = CsoTest.TestBs(k).TestPlot;
        testPlot = [testPlot, TestPlotSet(num2str(ModelParameters.alpha_norm))];
        CsoTest.TestBs(k).TestPlot = testPlot;
    end
    
    % Test 10 times per switch off percentage
    for j = 1:10        
        % Generate base station locations
        [InitialBs]= UT_LatticeBased('hexUni' , ModelParameters);

        % Set up the initial base station locations and CoVs
        CsoTest.InitialBs.ActiveBs = InitialBs;
        [CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
        CsoTest.InitialBs.CN = CN;
        CsoTest.InitialBs.CV = CV;
        CsoTest.InitialBs.CD = CD;
        
        % Get current CD value
        Cov(j) = CD;

        % Test each switch off percentage
        for m = 0:9
            % TODO Fix wait bar to match new values
            waitbar(((l - 1)*10*10 + (j - 1)*10 + m)/(5*10*10),hwait);
            
            % Variable switch off percentage
            percentSO = 0.1 * m;

            % Initialize the test structures
            for k = 1:testNum
                CsoTest.TestBs(k).ActiveBs = InitialBs;
                CsoTest.TestBs(k).InactiveBs = [];
            end

            % Run SO algorithms on the base station locations
            if percentSO > 0
                fprintf('SO: %f\n',percentSO);
                fprintf('Pert: %f\n\n',ModelParameters.alpha_norm);
                CsoTest.TestBs(1) = AverageNearestSO(CsoTest.TestBs(1),percentSO,2);
                CsoTest.TestBs(2) = MaxRegSoWithShift(CsoTest.TestBs(2),percentSO,ModelParameters);
                CsoTest.TestBs(3) = RandomSO(CsoTest.TestBs(3),percentSO);
                CsoTest.TestBs(4) = GenieAidedSO(CsoTest.TestBs(4),percentSO,ModelParameters);
                CsoTest.TestBs(5) = NeighborhoodSO(CsoTest.TestBs(5),percentSO);
            end
                
            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:testNum
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
                CsoTest.TestBs(k).CN = CN;
                CsoTest.TestBs(k).CV = CV;
                CsoTest.TestBs(k).CD = CD;
                
                CnData = CsoTest.TestBs(k).TestPlot(l).CnData;
                CnData = [CnData ; percentSO, CN];
                CsoTest.TestBs(k).TestPlot(l).CnData = CnData;
                
                CvData = CsoTest.TestBs(k).TestPlot(l).CvData;
                CvData = [CvData ; percentSO, CV];
                CsoTest.TestBs(k).TestPlot(l).CvData = CvData;
                
                CdData = CsoTest.TestBs(k).TestPlot(l).CdData;
                CdData = [CdData ; percentSO, CD];
                CsoTest.TestBs(k).TestPlot(l).CdData = CdData;
            end
        end
    end
    
    % Get the median of tested input CoVs
    CovAvg(l) = mean(Cov);
    
    % Set Tag to average CoV value
    for k = 1:testNum
        CsoTest.TestBs(k).TestPlot(l).Tag = num2str(CovAvg(l),2);
        CdTemp = zeros(10,2);
        for m = 0:9
            CdData = CsoTest.TestBs(k).TestPlot(l).CdData;
            CdIndex = find(CdData(:,1) == 0.1*m);
            avgCdData = mean(CdData(CdIndex,2));
            CdTemp(m+1,:) = [0.1*m, avgCdData];
        end
        CsoTest.TestBs(k).TestPlot(l).CdData = CdTemp;
    end
end
warning on;

save('data/Test_SOvsCoVoutData.mat', 'CsoTest');
close(hwait);

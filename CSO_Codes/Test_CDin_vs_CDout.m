% Wait bar
hwait = waitbar(0,'Calculating');
tic;

% Load InitialBsSets
load('data/InitialBsSet.mat', 'BsSet');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;
ModelParameters.metric = 'CD';

% Initialize the test set
algNum = 4;
drop = 1000;
testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
CsoTest = CsoTestSet(algNum);
Cov = zeros(1,drop);
CovAvg = zeros(1,5);
RawCd = zeros(algNum,drop);
percentSO = [0.10 0.35 0.65 0.90];

warning off;
for m = 1:length(percentSO)
    
    % Initialize the testPlot structure for each test method
    for k = 1:algNum
        testPlot = CsoTest.TestBs(k).TestPlot;
        testPlot = [testPlot, TestPlotSet(num2str(percentSO(m)))]; 
        testPertLen = length(testPert);
        testPlot(m).CdData = zeros(testPertLen,2);
        CsoTest.TestBs(k).TestPlot = testPlot;
    end
    
    for l = 1:length(testPert)
        % Test for incrementing perturbation values
        ModelParameters.alpha_norm = testPert(l);
        CsoTest.ModelParameters = ModelParameters;
        
        BsSetIndex = zeros(1,drop);
        dropCount = 1;
        for n = 1:length(BsSet)
            if BsSet(n).Pert == testPert(l)
                pertIndex = n;
                break;
            end
        end

        % Test 10 times per switch off percentage
        for j = 1:drop
            waitbar(((m-1)*length(testPert)*drop + (l - 1)*drop + j)/(length(percentSO)*length(testPert)*drop),hwait);

            % Generate base station locations
            InitialBs = BsSet(pertIndex).BsSet(j).Bs;
            %[InitialBs]= UT_LatticeBased('hexUni' , ModelParameters);

            % Set up the initial base station locations and CoVs
            CsoTest.InitialBs.ActiveBs = InitialBs;
            [CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
            CsoTest.InitialBs.CD = CD;

            % Get current CD value
            Cov(j) = CD;

            % Initialize the test structures
            for k = 1:algNum
                CsoTest.TestBs(k).ActiveBs = InitialBs;
                CsoTest.TestBs(k).InactiveBs = [];
            end

            % Run SO algorithms on the base station locations
            CsoTest.TestBs(1) = RandomSO(CsoTest.TestBs(1),percentSO(m));
            CsoTest.TestBs(2) = SemiGreedyDeletion(CsoTest.TestBs(2),percentSO(m));
            CsoTest.TestBs(3) = GreedyDeletion(CsoTest.TestBs(3),percentSO(m));
            CsoTest.TestBs(4) = GreedyAddSO(CsoTest.TestBs(4),percentSO(m));

            CsoTest.RawBs = [CsoTest.RawBs RawBs(CsoTest.InitialBs.ActiveBs,CsoTest.InitialBs.InactiveBs,testPert(l),percentSO(m))];
            for k = 1:algNum
                CsoTest.RawBs = [CsoTest.RawBs RawBs(CsoTest.TestBs(k).ActiveBs,CsoTest.TestBs(k).InactiveBs,testPert(l),percentSO(m))];
            end

            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:algNum
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
                CsoTest.TestBs(k).CD = CD;

    %             CdData = CsoTest.TestBs(k).TestPlot.CdData;
    %             CdData = [CdData ; percentSO, CD];
                RawCd(k,j) = CD;
    %             CsoTest.TestBs(k).TestPlot.CdData = CdData;
            end
        end

        % Get the median of tested input CoVs
    %     CovAvg(l) = mean(Cov);
        for k = 1:algNum
            CsoTest.TestBs(k).TestPlot(m).CdData(l,1) = mean(Cov);
            CsoTest.TestBs(k).TestPlot(m).CdData(l,2) = mean(RawCd(k,:));
        end
    end
end
warning on;

save('data/Test_CDin_vs_CDoutData_1.mat', 'CsoTest');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);

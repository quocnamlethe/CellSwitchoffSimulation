% Wait bar
hwait = waitbar(0,'Calculating');
tic;

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;
ModelParameters.metric = 'CD';

% Initialize channel parameters
ChannelParamters = ChannelSetup(); 
ChannelParamters.AssociationType = 'StrongestBS';
ChannelParamters.SIRMericType = 'SIR';

coveragePercentage = 5;

% Initialize the test set
algNum = 5;
drop = 10;
testPert = [0 0.359938995 2];
percentSO = 0:0.05:0.9;
CsoTest = CsoTestSet(algNum);
Cov = zeros(10,1); %TODO: FIX
CovAvg = zeros(1,5);

% Initialize Users
 UsersIn=10000;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 User_ModlPrmtrs.win=ModelParameters.win * 0.6;
 BS_ModlPrmtrs.alpha_norm=2;
 
for k = 1:algNum
    CsoTest.TestBs(k).TestPlot = repmat([TestPlotSet('initial')],1,5);
    CsoTest.TestBs(k).RawData = repmat(RawBs([],[],[],[]),1,drop*length(testPert)*length(percentSO));
end

plotData = nan(100,3); %TODO FIX BACK TO 100

warning off;
for l = 1:length(testPert)
    % Test for incrementing perturbation values
    ModelParameters.alpha_norm = testPert(l);
    %CsoTest.ModelParameters = ModelParameters;
    
    % Initialize the testPlot structure for each test method
    for k = 1:algNum
        testPlot = CsoTest.TestBs(k).TestPlot;
        testPlot(l) = TestPlotSet(num2str(ModelParameters.alpha_norm));
        testPlot(l).CnData = plotData;
        testPlot(l).CvData = plotData;
        testPlot(l).CdData = plotData;
        testPlot(l).SirData = plotData;
        CsoTest.TestBs(k).TestPlot = testPlot;
    end
    
    % Test 10 times per switch off percentage
    for j = 1:drop
        % Generate base station locations
        [InitialBs]= UT_LatticeBased('hexUni' , ModelParameters);
        
        % Generate user locations
        [User_Locations]=UT_LatticeBased('hexUni', User_ModlPrmtrs);

        % Set up the initial base station locations and CoVs
        CsoTest.InitialBs.ActiveBs = InitialBs;
        [CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
        CsoTest.InitialBs.CN = CN;
        CsoTest.InitialBs.CV = CV;
        CsoTest.InitialBs.CD = CD;
        numBs = size(InitialBs,1);
        
        % Calculate initial SIR value
        [InitialSIR] = SIR_RayleighCh3(InitialBs,User_Locations,ChannelParamters);
        
        % percentile
        InitialSIR = prctile(InitialSIR,coveragePercentage);
        
        % Get current CD value
        Cov(j) = CD;

        % Test each switch off percentage
        for m = 1:length(percentSO)
            index = (l-1)*length(percentSO)*drop + (j-1)*length(percentSO) + m;
            % TODO Fix wait bar to match new values
            waitbar(index/(length(testPert)*length(percentSO)*drop),hwait);

            % Initialize the test structures
            for k = 1:algNum
                CsoTest.TestBs(k).ActiveBs = InitialBs;
                CsoTest.TestBs(k).InactiveBs = [];
            end

            CsoTest.TestBs(4) = GenieAidedSO(CsoTest.TestBs(4),percentSO(m),ModelParameters);
            
            % Run SO algorithms on the base station locations
            if percentSO > 0
                CsoTest.TestBs(1) = GreedyDeletion(CsoTest.TestBs(1),percentSO(m));
                CsoTest.TestBs(2) = MaxRegSoWithShift(CsoTest.TestBs(2),percentSO(m),ModelParameters);
                CsoTest.TestBs(3) = RandomSO(CsoTest.TestBs(3),percentSO(m));
                CsoTest.TestBs(5) = NeighborhoodSO(CsoTest.TestBs(5),percentSO(m));
            end
            
            for k = 1:algNum
                CsoTest.TestBs(k).RawData(index) = RawBs(CsoTest.TestBs(k).ActiveBs,CsoTest.TestBs(k).InactiveBs,testPert(l),percentSO(m));
            end
                
            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:algNum                
                [SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(k).ActiveBs,User_Locations,ChannelParamters);
                
                % percentile
                SIR_dB = prctile(SIR_dB,coveragePercentage);
                SirData = CsoTest.TestBs(k).TestPlot(l).SirData;
                realSO = 1 - size(CsoTest.TestBs(k).ActiveBs,1)/numBs;
                if (realSO < 0)
                    realSO = 0;
                end
                SirData(((j-1)*10 + m + 1),:) = [percentSO(m), SIR_dB, realSO]; %TODO:CHANGE BACK TO 10
                CsoTest.TestBs(k).TestPlot(l).SirData = SirData;
                
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
                CsoTest.TestBs(k).CN = CN;
                CsoTest.TestBs(k).CV = CV;
                CsoTest.TestBs(k).CD = CD;
                
                CdData = CsoTest.TestBs(k).TestPlot(l).CdData;
                CdData = [CdData ; percentSO(m), CD, size(CsoTest.TestBs(k).ActiveBs,1)];
                CsoTest.TestBs(k).TestPlot(l).CdData = CdData;
            end
        end
    end
    
    % Get the median of tested input CoVs
    CovAvg(l) = mean(Cov);
    
    % Set Tag to average CoV value
    for k = 1:algNum
        if CovAvg(l) > 0.001
            CsoTest.TestBs(k).TestPlot(l).Tag = num2str(CovAvg(l),2);
        else
            CsoTest.TestBs(k).TestPlot(l).Tag = '0';
        end
        SirTemp = zeros(10,3); %TODO CHANGE BACK TO 10
        SirData = CsoTest.TestBs(k).TestPlot(l).SirData;
        CdTemp = zeros(10,3);
        CdData = CsoTest.TestBs(k).TestPlot(l).CdData;
        for m = 1:length(percentSO) %TODO CHANGE BACK TO 9
            SirIndex = find(SirData(:,1) == percentSO(m));
            avgSirData = nanmean(SirData(SirIndex,2));
            avgSO = nanmean(SirData(SirIndex,3));
            SirTemp(m+1,:) = [percentSO(m), avgSirData, avgSO];
            
            CdIndex = find(CdData(:,1) == percentSO(m));
            avgCdData = mean(CdData(CdIndex,2));
            CdTemp(m+1,:) = [percentSO(m), avgCdData, avgSO];
        end
        CsoTest.TestBs(k).TestPlot(l).SirData = SirTemp;
        CsoTest.TestBs(k).TestPlot(l).CdData = CdTemp;
    end
end
warning on;

save('data/Test_SOvsSIRData2.mat', 'CsoTest');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);

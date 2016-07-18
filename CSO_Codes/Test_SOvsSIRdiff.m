% Wait bar
hwait = waitbar(0,'Calculating');
tic;

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;

% Initialize channel parameters
ChannelParamters = ChannelSetup(); 
ChannelParamters.AssociationType = 'StrongestBS';
ChannelParamters.SIRMericType = 'SIR';

% Initialize the test set
testNum = 5;
CsoTest = CsoTestSet(testNum);
Cov = zeros(1,1); %TODO: FIX
CovAvg = zeros(1,5);

% Initialize Users
 UsersIn=10000;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 BS_ModlPrmtrs.alpha_norm=2;
 
% Initialize Channel
 Exponent = 4; %pathloss Exponent
 Shadow = 6; % [dB]  % Log-distance or Log-normal shadowing
 
 SIRMericType='MedianSIR';
 
for k = 1:testNum
    CsoTest.TestBs(k).TestPlot = repmat([TestPlotSet('initial')],1,5);
end

plotData = zeros(100,3);

warning off;
for l = 1:5
    % Test for incrementing perturbation values
    ModelParameters.alpha_norm = 0.25 * l - 0.25;
    %CsoTest.ModelParameters = ModelParameters;
    
    % Initialize the testPlot structure for each test method
    for k = 1:testNum
        testPlot = CsoTest.TestBs(k).TestPlot;
        testPlot(l) = TestPlotSet(num2str(ModelParameters.alpha_norm));
        testPlot(l).CnData = plotData;
        testPlot(l).CvData = plotData;
        testPlot(l).CdData = plotData;
        testPlot(l).SirData = plotData;
        CsoTest.TestBs(k).TestPlot = testPlot;
    end
    
    % Test 1 times per switch off percentage
    for j = 1:10        % TODO: FIX SIZE
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
        
        % 95th percentile
        InitialSIR = prctile(InitialSIR,95);
        % 50th percentile
        % InitialSIR = prctile(InitialSIR,50);
        
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

            CsoTest.TestBs(4) = GenieAidedSO(CsoTest.TestBs(4),percentSO,ModelParameters);
            
            % Run SO algorithms on the base station locations
            if percentSO > 0
                CsoTest.TestBs(1) = AverageNearestSO(CsoTest.TestBs(1),percentSO,2);
                CsoTest.TestBs(2) = MaxRegSoWithShift(CsoTest.TestBs(2),percentSO,ModelParameters);
                CsoTest.TestBs(3) = RandomSO(CsoTest.TestBs(3),percentSO);
                CsoTest.TestBs(5) = NeighborhoodSO(CsoTest.TestBs(5),percentSO);
            end
                
            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:testNum                
                [SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(k).ActiveBs,User_Locations,ChannelParamters);
                
                % 95th percentile
                SIR_dB = prctile(SIR_dB,95);
                % 50th percentile
                % SIR_dB = prctile(SIR_dB,50);
                SirData = CsoTest.TestBs(k).TestPlot(l).SirData;
                SirData(((j-1)*10 + m + 1),:) = [percentSO, (SIR_dB - InitialSIR), 1 - size(CsoTest.TestBs(k).ActiveBs,1)/numBs];
                CsoTest.TestBs(k).TestPlot(l).SirData = SirData;
            end
        end
    end
    
    % Get the median of tested input CoVs
    CovAvg(l) = mean(Cov);
    
    % Set Tag to average CoV value
    for k = 1:testNum
        if CovAvg(l) > 0.001
            CsoTest.TestBs(k).TestPlot(l).Tag = num2str(CovAvg(l),2);
        else
            CsoTest.TestBs(k).TestPlot(l).Tag = '0';
        end
        SirTemp = zeros(10,3);
        for m = 0:9
            SirIndex = find(SirData(:,1) == 0.1*m);
            avgSirData = nanmean(SirData(SirIndex,2));
            avgSO = nanmean(SirData(SirIndex,3));
            SirTemp(m+1,:) = [0.1*m, avgSirData, avgSO];
        end
        CsoTest.TestBs(k).TestPlot(l).CdData = SirTemp;
    end
end
warning on;

save('data/Test_SOvsSIRdiffData4.mat', 'CsoTest');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);

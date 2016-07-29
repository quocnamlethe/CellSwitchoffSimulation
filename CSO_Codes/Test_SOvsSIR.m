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
Cov = zeros(10,1); %TODO: FIX
CovAvg = zeros(1,5);

% Initialize Users
 UsersIn=10000;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 User_ModlPrmtrs.win=[-400,400,-400,400];
 BS_ModlPrmtrs.alpha_norm=2; %TODO: Changed from 2
 
% Initialize Channel
 Exponent = 4; %pathloss Exponent
 Shadow = 6; % [dB]  % Log-distance or Log-normal shadowing
 
 SIRMericType='MedianSIR';
 
for k = 1:testNum
    CsoTest.TestBs(k).TestPlot = repmat([TestPlotSet('initial')],1,5);
end

plotData = nan(100,3); %TODO FIX BACK TO 100

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
    
    % Test 10 times per switch off percentage
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
        %InitialSIR = prctile(InitialSIR,95);
        % 50th percentile
        InitialSIR = prctile(InitialSIR,50);
        
        % Get current CD value
        Cov(j) = CD;

        % Test each switch off percentage
        for m = 0:9 %TODO CHANGE BACK TO 9
            % TODO Fix wait bar to match new values
            waitbar(((l - 1)*10*10 + (j - 1)*10 + m)/(5*10*10),hwait);
            
            % Variable switch off percentage
            percentSO = 0.1 * m; %TODO CHANGE BACK TO 0.1

            % Initialize the test structures
            for k = 1:testNum
                CsoTest.TestBs(k).ActiveBs = InitialBs;
                CsoTest.TestBs(k).InactiveBs = [];
            end

            CsoTest.TestBs(4) = GenieAidedSO(CsoTest.TestBs(4),percentSO,ModelParameters);
            
            % Run SO algorithms on the base station locations
            if percentSO > 0
                CsoTest.TestBs(1) = GreedyDeletion(CsoTest.TestBs(1),percentSO);
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
                realSO = 1 - size(CsoTest.TestBs(k).ActiveBs,1)/numBs;
                if (realSO < 0)
                    realSO = 0;
                end
                SirData(((j-1)*10 + m + 1),:) = [percentSO, SIR_dB, realSO]; %TODO:CHANGE BACK TO 10
                CsoTest.TestBs(k).TestPlot(l).SirData = SirData;
                
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
                CsoTest.TestBs(k).CN = CN;
                CsoTest.TestBs(k).CV = CV;
                CsoTest.TestBs(k).CD = CD;
                
                CdData = CsoTest.TestBs(k).TestPlot(l).CdData;
                CdData = [CdData ; percentSO, CD, size(CsoTest.TestBs(k).ActiveBs,1)];
                CsoTest.TestBs(k).TestPlot(l).CdData = CdData;
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
        SirTemp = zeros(10,3); %TODO CHANGE BACK TO 10
        SirData = CsoTest.TestBs(k).TestPlot(l).SirData;
        CdTemp = zeros(10,3);
        CdData = CsoTest.TestBs(k).TestPlot(l).CdData;
        for m = 0:9 %TODO CHANGE BACK TO 9
            SirIndex = find(SirData(:,1) == 0.1*m);
            avgSirData = nanmean(SirData(SirIndex,2));
            avgSO = nanmean(SirData(SirIndex,3));
            SirTemp(m+1,:) = [0.1*m, avgSirData, avgSO];
            
            CdIndex = find(CdData(:,1) == 0.1*m);
            avgCdData = mean(CdData(CdIndex,2));
            CdTemp(m+1,:) = [0.1*m, avgCdData, avgSO];
        end
        CsoTest.TestBs(k).TestPlot(l).SirData = SirTemp;
        CsoTest.TestBs(k).TestPlot(l).CdData = CdTemp;
    end
end
warning on;

save('data/Test_SOvsSIRData.mat', 'CsoTest');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);
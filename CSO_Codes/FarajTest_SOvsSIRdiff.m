% Wait bar
hwait = waitbar(0,'Calculating');
tic;

% Load InitialBsSets
load('data/InitialBsSet.mat', 'BsSet');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 200e-6;

% Initialize channel parameters
ChannelParamters = ChannelSetup(); 
ChannelParamters.AssociationType = 'StrongestBS';
ChannelParamters.SIRMericType = 'SIR';
ChannelParamters.n = 3;
ChannelParamters.Sigma_dB = 6;

% Initialize the test set
algNum = 5;
drop = 100;
percentile = 5;
testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
percentSO = 0:0.05:0.9;
CsoTest = CsoTestSet(algNum);
Cov = zeros(1,1); %TODO: FIX
CovAvg = zeros(1,5);
RawSIR = zeros(algNum,drop,2);

% Initialize Users
 UsersIn=10000;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 User_ModlPrmtrs.win = ModelParameters.win * 0.6;
 BS_ModlPrmtrs.alpha_norm=2;
 
 
for k = 1:algNum
    CsoTest.TestBs(k).TestPlot = repmat([TestPlotSet('initial')],1,5);
end

plotData = zeros(100,3);

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
    
    BsSetIndex = zeros(1,drop);
    dropCount = 1;
    for n = 1:length(BsSet)
        if BsSet(n).Pert == testPert(l)
            pertIndex = n;
            break;
        end
    end
    
    % Test 1 times per switch off percentage
    for m = 1:length(percentSO)        % TODO: FIX SIZE
        
        % Variable switch off percentage
        %percentSO = 0.1 * m;

        % Test each switch off percentage
        for j = 1:drop
            % TODO Fix wait bar to match new values
            waitbar(((l - 1)*length(percentSO)*drop + (m - 1)*drop + j)/(length(testPert)*length(percentSO)*drop),hwait);
            
            % Generate base station locations
            InitialBs = BsSet(pertIndex).BsSet(j).Bs;
            %[InitialBs]= UT_LatticeBased('hexUni' , ModelParameters);

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
            InitialSIR = prctile(InitialSIR,percentile);

            % Get current CD value
            Cov(j) = CD;

            % Initialize the test structures
            for k = 1:algNum
                CsoTest.TestBs(k).ActiveBs = InitialBs;
                CsoTest.TestBs(k).InactiveBs = [];
            end

            CsoTest.TestBs(2) = GenieAidedSO(CsoTest.TestBs(2),percentSO(m),ModelParameters);
            
            % Run SO algorithms on the base station locations
            if percentSO(m) > 0
                CsoTest.TestBs(1) = RandomSO(CsoTest.TestBs(1),percentSO(m));
                CsoTest.TestBs(2) = GenieAidedSO(CsoTest.TestBs(2),percentSO(m),ModelParameters);
                CsoTest.TestBs(3) = GreedyDeletion(CsoTest.TestBs(3),percentSO(m));
                CsoTest.TestBs(4) = GreedyAddSO(CsoTest.TestBs(4),percentSO(m));
                CsoTest.TestBs(5) = SemiGreedyDeletion(CsoTest.TestBs(5),percentSO(m));
            end
            
            CsoTest.RawBs = [CsoTest.RawBs RawBs(CsoTest.InitialBs.ActiveBs,CsoTest.InitialBs.InactiveBs,testPert(l),percentSO(m))];
            for k = 1:algNum
                CsoTest.RawBs = [CsoTest.RawBs RawBs(CsoTest.TestBs(k).ActiveBs,CsoTest.TestBs(k).InactiveBs,testPert(l),percentSO(m))];
            end
                
            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:algNum                
                [SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(k).ActiveBs,User_Locations,ChannelParamters);
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
                
                % 95th percentile
                SIR_dB = prctile(SIR_dB,percentile);
                % 50th percentile
                % SIR_dB = prctile(SIR_dB,50);
                RawSIR(k,j,1) = SIR_dB;
                RawSIR(k,j,2) = 1 - size(CsoTest.TestBs(k).ActiveBs,1)/numBs;
                CsoTest.TestBs(k).RawData = [CsoTest.TestBs(k).RawData TestData(CsoTest.TestBs(k).ActiveBs,CsoTest.TestBs(k).InactiveBs,testPert(l),percentSO(m),CsoTest.InitialBs.CD,CD,SIR_dB)];
%                 SirData = CsoTest.TestBs(k).TestPlot(l).SirData;
%                 SirData(((j-1)*10 + m + 1),:) = [percentSO, (SIR_dB - InitialSIR), 1 - size(CsoTest.TestBs(k).ActiveBs,1)/numBs];
%                 CsoTest.TestBs(k).TestPlot(l).SirData = SirData;
            end
        end
        
        % Get the median of tested input CoVs
        CovAvg(l) = mean(Cov);
        
        for k = 1:algNum
            if CovAvg(l) > 0.001
            CsoTest.TestBs(k).TestPlot(l).Tag = num2str(CovAvg(l),2);
            else
                CsoTest.TestBs(k).TestPlot(l).Tag = '0';
            end
            CsoTest.TestBs(k).TestPlot(l).SirData(m,1) = percentSO(m);
            CsoTest.TestBs(k).TestPlot(l).SirData(m,2) = mean(RawSIR(k,:,1));
            CsoTest.TestBs(k).TestPlot(l).SirData(m,3) = mean(RawSIR(k,:,2));
        end
    end
    
%     % Get the median of tested input CoVs
%     CovAvg(l) = mean(Cov);
%     
%     % Set Tag to average CoV value
%     for k = 1:algNum
%         if CovAvg(l) > 0.001
%             CsoTest.TestBs(k).TestPlot(l).Tag = num2str(CovAvg(l),2);
%         else
%             CsoTest.TestBs(k).TestPlot(l).Tag = '0';
%         end
%         SirTemp = zeros(10,3);
%         for m = 0:9
%             SirIndex = find(SirData(:,1) == 0.1*m);
%             avgSirData = nanmean(SirData(SirIndex,2));
%             avgSO = nanmean(SirData(SirIndex,3));
%             SirTemp(m+1,:) = [0.1*m, avgSirData, avgSO];
%         end
%         CsoTest.TestBs(k).TestPlot(l).CdData = SirTemp;
%     end
end
warning on;

save('data/Test_SOvsSIRdiffFarajData_a4_s0.mat', 'CsoTest');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);

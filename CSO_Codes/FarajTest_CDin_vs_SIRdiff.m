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
ChannelParamters.n = 3;
ChannelParamters.Sigma_dB = 6;

% Initialize the test set
algNum = 5;
drop = 100;
percentile = 5;
testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
CsoTest = CsoTestSet(algNum);
Cov = zeros(1,1); %TODO: FIX
CovAvg = zeros(1,5);
percentSO = [0.10 0.35 0.65 0.90];

% Initialize Users
 UsersIn=10000;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 User_ModlPrmtrs.win = ModelParameters.win * 0.6;
 BS_ModlPrmtrs.alpha_norm=2;
 
% Initialize Channel
 Exponent = 4; %pathloss Exponent
 Shadow = 6; % [dB]  % Log-distance or Log-normal shadowing
 
for k = 1:algNum
    CsoTest.TestBs(k).TestPlot = repmat([TestPlotSet('initial')],1,5);
end

plotData = zeros(length(testPert),3);

warning off;
for l = 1:length(percentSO)
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
    
    % Test 1 times per switch off percentage
    for m = 1:length(testPert)
        % Test for incrementing perturbation values
        ModelParameters.alpha_norm = testPert(m);
        
        SirTemp = zeros(drop,3,length(testPert));
        
        for j = 1:drop
            % TODO Fix wait bar to match new values
            waitbar(((l - 1)*drop*length(testPert) + (m - 1)*drop + j)/(length(percentSO)*length(testPert)*drop),hwait);
            
            % Generate base station locations
            [InitialBs]= UT_LatticeBased('hexUni' , ModelParameters);

            % Generate user locations
            [User_Locations]=UT_LatticeBased('hexUni', User_ModlPrmtrs);

            % Set up the initial base station locations and CoVs
            CsoTest.InitialBs.ActiveBs = InitialBs;
            [CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
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

            % Run SO algorithms on the base station locations
            if percentSO > 0
                CsoTest.TestBs(1) = RandomSO(CsoTest.TestBs(1),percentSO(l));
                CsoTest.TestBs(2) = GenieAidedSO(CsoTest.TestBs(2),percentSO(l),ModelParameters);
                CsoTest.TestBs(3) = GreedyDeletion(CsoTest.TestBs(3),percentSO(l));
                CsoTest.TestBs(4) = GreedyAddSO(CsoTest.TestBs(4),percentSO(l));
                CsoTest.TestBs(5) = SemiGreedyDeletion(CsoTest.TestBs(5),percentSO(l));
            end
            
            CsoTest.RawBs = [CsoTest.RawBs RawBs(CsoTest.InitialBs.ActiveBs,CsoTest.InitialBs.InactiveBs,testPert(m),percentSO(l))];
            for k = 1:algNum
                CsoTest.RawBs = [CsoTest.RawBs RawBs(CsoTest.TestBs(k).ActiveBs,CsoTest.TestBs(k).InactiveBs,testPert(m),percentSO(l))];
            end
                
            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:algNum                
                [SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(k).ActiveBs,User_Locations,ChannelParamters);
                
                % 95th percentile
                SIR_dB = prctile(SIR_dB,percentile);
                %SirData = CsoTest.TestBs(k).TestPlot(l).SirData;
                SirTemp(m,:,k) = [((m-1)*0.1), SIR_dB, 0];
                %SirData(((m-1)*drop + j),:) = [((m-1)*0.2), (SIR_dB - InitialSIR), 0];
                %CsoTest.TestBs(k).TestPlot(l).SirData = SirData;
            end
        end
        % Get the median of tested input CoVs
        CovAvg(m) = mean(Cov);
        
        % Set Tag to percent SO value
        for k = 1:algNum
            CsoTest.TestBs(k).TestPlot(l).Tag = num2str(percentSO(l),2);
%             for n = 1:drop
                avgSirData = nanmean(SirTemp(:,2,k));
%             end
            CsoTest.TestBs(k).TestPlot(l).SirData(m,:) = [((m-1)*0.1), avgSirData, CovAvg(m)];
        end
    end
end
warning on;

save('data/Test_CDinvsSIRdiffFarajData_a3_s6_sir95.mat', 'CsoTest');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);

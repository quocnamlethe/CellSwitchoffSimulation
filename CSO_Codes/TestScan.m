% Wait bar
hwait = waitbar(0,'Calculating');
starttime = tic;

% Load InitialBsSets
load('data/InitialBsSet.mat', 'BsSet');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 600e-6;

% Initialize channel parameters
ChannelParamters = ChannelSetup(); 
ChannelParamters.AssociationType = 'StrongestBS';
ChannelParamters.SIRMericType = 'SIR';
ChannelParamters.n = 4;
ChannelParamters.Sigma_dB = 0;

% Initialize the test set
algNum = 1;
drop = 1;
testPert = [0.450877783];%[0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
percentSO = [0.5];%0:0.05:0.9;
CsoTest = CsoTestSet(algNum);
RawSIR = zeros(algNum,drop,2);

% Initialize Users
 UsersIn=2000;
 User_ModlPrmtrs=ModelParaSet();        
 User_ModlPrmtrs.lambda=UsersIn*10^-6;
 User_ModlPrmtrs.win = ModelParameters.win * 0.6;
 BS_ModlPrmtrs.alpha_norm=2;

plotData = zeros(100,3);

warning off;
for l = 1:length(testPert)
    % Test for incrementing perturbation values
    ModelParameters.alpha_norm = testPert(l);
    %CsoTest.ModelParameters = ModelParameters;
    
    BsSetIndex = zeros(1,drop);
    dropCount = 1;
    for n = 1:length(BsSet)
        if BsSet(n).Pert == testPert(l)
            pertIndex = n;
            break;
        end
    end
    
    % Test 1 times per switch off percentage
    for m = 1:length(percentSO)

        % Test each switch off percentage
        for j = 1:drop
            % TODO Fix wait bar to match new values
            waitbar(((l - 1)*length(percentSO)*drop + (m - 1)*drop + j)/(length(testPert)*length(percentSO)*drop),hwait);
            
            % Generate base station locations
            %InitialBs = BsSet(pertIndex).BsSet(j).Bs;
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

            % Initialize the test structures
            for k = 1:algNum
                CsoTest.TestBs(k).ActiveBs = InitialBs;
                CsoTest.TestBs(k).InactiveBs = [];
            end
            
            % Run SO algorithms on the base station locations
            if percentSO(m) > 0
                CsoTest.TestBs(1) = InterchangeSA_SO(CsoTest.TestBs(1),percentSO(m));
            end
                
            % Calculate the CoVs and input them into the test plot
            % structures
            for k = 1:algNum                
                [SIR_dB] = SIR_RayleighCh3(CsoTest.TestBs(k).ActiveBs,User_Locations,ChannelParamters);
                [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);

                CsoTest.TestBs(k).RawData = [CsoTest.TestBs(k).RawData TestData(CsoTest.TestBs(k).ActiveBs,CsoTest.TestBs(k).InactiveBs,testPert(l),percentSO(m),CsoTest.InitialBs.CD,CD,SIR_dB)];
            end
        end
        
    end
    
end
warning on;

save('data/TestScan_SA.mat', 'CsoTest');
runTime = toc(starttime);
fprintf('Runtime: %f\n',runTime);
close(hwait);

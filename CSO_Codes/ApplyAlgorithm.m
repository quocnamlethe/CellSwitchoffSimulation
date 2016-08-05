% Wait bar
hwait = waitbar(0,'Calculating');
tic;

% Load InitialBsSets
load('data/InitialBsSet.mat', 'BsSet');

load('data/AlgorithmSO.mat', 'AlgorithmSO');

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 200e-6;

algNum = 5;
testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
percentSO = 0:0.05:0.9;
drop = 100;

if isempty(AlgorithmSO)
    AlgorithmSO = repmat(struct('Algorithm',0','Perturbation',repmat(struct('Perturbation',0,'SO',repmat(struct('SO',0,'Drop',repmat(struct('ActiveBs',[],'InactiveBs',[]),1,100)),1,19)),1,11)),1,algNum);
    for j = 1:algNum
        AlgorithmSO(j).Algorithm = j;
    end
end

numCases = length(testPert)*drop*length(percentSO);
BsStruct = struct('ActiveBs',[],'InactiveBs',[]);

for j = 1:length(testPert)
    for k = 1:length(percentSO)
        for l = 1:drop
            index = l + (k-1)*drop + (j-1)*length(percentSO)*drop;
            waitbar(index/numCases,hwait,[num2str(index/numCases) '%']);
            BsStruct.ActiveBs = BsSet(j).BsSet(l).Bs;
            AlgorithmSO(2).Perturbation(j).Perturbation = testPert(j);
            AlgorithmSO(2).Perturbation(j).SO(k).SO = percentSO(k);
            AlgorithmSO(2).Perturbation(j).SO(k).Drop(l) = GenieAidedSO(BsStruct,percentSO(k),ModelParameters);
        end
    end
end

save('data/AlgorithmSO.mat', 'AlgorithmSO');

runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);
hwait = waitbar(0,'Calculating');
tic;

% Initialize the model parameters
ModelParameters = ModelParaSet();
ModelParameters.lambda = 200e-6;
ModelParameters.metric = 'CD';

drop = 100;
testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];

BsSet = repmat(struct('Pert',0,'BsSet',repmat(struct('Pert',0,'Bs',[]),1,drop)),1,length(testPert));

for k = 1:length(testPert)
    ModelParameters.alpha_norm = testPert(k);
    BsSet(k).Pert = testPert(k);
    for l = 1:drop
        waitbar(((k-1)*drop+drop)/(drop*length(testPert)),hwait,['Calculating ' num2str(((k-1)*drop+l)/(drop*length(testPert)))]);
        index = (k-1)*drop + l;
        BsSet(k).BsSet(l) = struct('Pert',testPert(k),'Bs', UT_LatticeBased('hexUni' , ModelParameters));
    end
end

save('data/InitialBsSet.mat', 'BsSet');
runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);
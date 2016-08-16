function [BaseStationSO] = BestPairwiseInterchangeSO(BaseStation,percentSO)
% BestPairwiseInterchangeSO - The best pairwise interchange switch off
% algorithm
% 
% Syntax: [BaseStationSO] = BestPairwiseInterchangeSO(BaseStation,percentSO)
%
% Outputs:
%   BaseStationSO - a structure containing the model description 
%   representing a set of base stations and their CoVs
%   BaseStation = struct('ActiveBs',[x1,y2;x2,y2...],'InactiveBs',[]);
%
% Inputs:
%   BaseStation - a structure containing the model description 
%   representing a set of base stations and their CoVs
%   percentSO - the percentage of the base stations to switch off
%   BaseStation = struct('ActiveBs',[x1,y2;x2,y2...],'InactiveBs',[]);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Best Pairwise Interchange Switch Off algorithm:
%       1) Start with a random sample
%       2) Find the two closest points in the sample
%       3) Interchange each of the two points with points outside of the
%          set and keep the one that improves the objective function most
%       Note: The objective function is the minimum distance

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);
    
    % Create loop condition
    new_S = 1;
    
    % Create the distance matrix for all active base stations
    DistMat = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
    DistMat(DistMat==0) = inf;
    
    % Start with a random sample of the active base stations
    S = randsample(nPoints,nPoints - numSO);
    V = 1:nPoints;
    
    % Loop until S no longer changes
    while new_S == 1
        new_S = 0;
        
        % Find the two closest points
        minDist = min(DistMat(S,S));
        x = find(minDist == min(minDist));
        
        SS = S;
        
        otherElements = setxor(V,S);
        
        S1 = S;
        S2 = S;
        
        % Interchange with all points to find the best pairwise interchange
        for j = 1:length(otherElements)
            S1(x(1)) = otherElements(j);
            S2(x(2)) = otherElements(j);
            f_S1 = min(min(DistMat(S1,S1)));
            f_S2 = min(min(DistMat(S2,S2)));
            f_SS = min(min(DistMat(SS,SS)));
            
            % Determine which pairwise interchange was best
            if ((f_S1 > f_SS) && (f_S1 > f_S2))
                SS = S1;
                new_S = 1;
            elseif ((f_S2 > f_SS) && (f_S2 > f_S1))
                SS = S2;
                new_S = 1;
            end
        end
        
        S = SS;
    end
    
    BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(setxor(V,S),:)];
    BaseStation.ActiveBs = BaseStation.ActiveBs(S,:);

    % Output the resulting base station set
    BaseStationSO = BaseStation;

end
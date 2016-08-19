function [BaseStationSO] = NeighborhoodSOFP(BaseStation,percentSO)
% NeighborhoodSOFP - The first point neighborhood switch off algorithm
% 
% Syntax: [BaseStationSO] = NeighborhoodSOFP(BaseStation,percentSO)
%
% Outputs:
%   BaseStationSO - a structure containing the model description 
%   representing a set of base stations and their CoVs
%
% Inputs:
%   BaseStation - a structure containing the model description 
%   representing a set of base stations and their CoVs
%   percentSO - the percentage of the base stations to switch off
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Minimum Distance and Second Nearest Neighbour Switch Off algorithm:
%       1) Calculate the base station distance to all neighbours
%       2) Calculate the nearest neighbours of all of the base stations
%       3) Identify the base stations with the minimum distance to their 
%          nearest neighbour (There will be 2 or more)
%       4) Calculate the second nearest neighbours of the remaining base
%          stations
%       5) Remove the base station with the minimum second nearest
%          neighbour distance

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);
    realSO = 0;
    
    % Choose R
    % Calculate the base station distance to all neighbours
    DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
    maxDist = max(max(DD));
    sortDD = sort(reshape(DD,[length(DD)*length(DD),1]));
    
    radius = maxDist/2;
    rsize = radius;
    bestRadius = 0;
    bestSO = nPoints;
    
    %while(rsize > maxDist*0.01)
    for k = 1:5
        S = randsample(nPoints,1);
        V = 1:nPoints;
        offBS = [];
        
        W = setxor(V,[S; offBS]);
        neighborSO = DD(W,S);
        W(neighborSO < radius) = [];
        while(~isempty(W))
            xk = randsample(W,1);
            S = [S ; xk];
            W = setxor(W,xk);
            neighborSO = DD(W,xk);
            W(neighborSO < radius) = [];
        end
        S = unique(S);
        realSO = nPoints - size(S,1);
        if (bestSO > abs(realSO - numSO))
            if (realSO ~= 0)
                bestRadius = radius;
                bestSO = abs(realSO - numSO);
            end
        end
        if (realSO > numSO)
            radius = radius - rsize/2;
            rsize = rsize/2;
        elseif (realSO < numSO)
            radius = radius + rsize/2;
            rsize = rsize/2;
        end
    end
    
    S = randsample(nPoints,1);
    V = 1:nPoints;
    offBS = [];

    W = setxor(V,[S; offBS]);
    neighborSO = DD(W,S);

    W(neighborSO < radius) = [];
    while(~isempty(W))
        xk = randsample(W,1);
        S = [S ; xk];
        W = setxor(W,xk);
        neighborSO = DD(W,xk);
        W(neighborSO < radius) = [];
    end
    S = unique(S);
    
    realSO = nPoints - size(S,1);
    
    BaseStation.InactiveBs = BaseStation.ActiveBs(setxor(V,S),:);
	BaseStation.ActiveBs = BaseStation.ActiveBs(unique(S),:);
    
    % greedy addition and greedy deletion steps
    if (realSO > numSO)
        BaseStation = GreedyAddSOn(BaseStation,realSO - numSO);
    elseif (realSO < numSO)
        BaseStation = MinDistNumNearestSO(BaseStation,(numSO - realSO)/size(S,1));
    end
    
    % Output the resulting base station set
    BaseStationSO = BaseStation;

end


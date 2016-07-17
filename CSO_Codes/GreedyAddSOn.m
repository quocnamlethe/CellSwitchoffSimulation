function [BaseStationSO] = GreedyAddSOn(BaseStation,numSOn)
% GreedyAddSO - The maximum being nearest neighbour cell switch off 
% algorithm
% 
% Syntax: [BaseStationSO] = GreedyAddSO(BaseStation,percentSO)
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
%   Maximum Being Nearest Neighbour Switch Off algorithm:
%       1) Count the number of base stations that are the nearest neighbour
%          of each base station in the set
%       2) Remove the base station with the largest nearest neighbour count
%       3) If a tie occurs, remove the base station with the minimum
%          nearest neighbour distance
    
    offBS = BaseStation.InactiveBs;
    
    DD = pdist2(offBS, offBS);
    [~,index] = max(max(DD));
    
    S = offBS(index,:);
    offBS(index,:) = [];

    % Switch off numSO base stations
    for k = 1:numSOn
        % Calculate the base station distance to all neighbours
        DD = pdist2(offBS, S);
        DDmin = min(DD,[],2);
        [maxSum,index] = max(DDmin);
        
        S = [S ; offBS(index,:)];
        offBS(index,:) = [];
    end
    
    BaseStation.InactiveBs = offBS;
    BaseStation.ActiveBs = [BaseStation.ActiveBs ; S];
    
    % Output the resulting base station set
    BaseStationSO = BaseStation;

end


function [BaseStationSO] = NoNearestSO(BaseStation,percentSO)
% NoNearestSO - The isolated nearest neighbour cell switch off algorithm
% 
% Syntax: [BaseStationSO] = NoNearestSO(BaseStation,percentSO)
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
%   Isolated Nearest Neighbour Switch Off algorithm:
%       1) Identify the base station that have a nearest neigbour count of
%          0.
%       2) Remove the nearest neighbour of the identified base station
%          sequentially based on the nearest neighbour distances (minimum
%          first) until switch off goal is reached.
%       3) If the switch off goal is not reached, increment the nearest
%          neighbour count and repeat.

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);

    % Switch off numSO base stations
    for k = 1:numSO
        % Initialize the neighbour count
        neighbourCount = 0;
        
        % Calculate the base station distance to all neighbours
        DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
        
        % Replace distance to self with infinity (important for min
        % function)
        DD(DD==0) = inf;
        
        % Calculate the nearest neighbour of each base station
        [Nearest,index] = min(DD);
        
        % Calculate the nearest neighbour count of each base station
        [a,b] = hist(index,1:length(DD));

        % Initialize the notNearest array
        notNearest = [];
        
        % Increment the nearest neighbour count until a base station has
        % that number of nearest neighbours
        while isempty(notNearest)
            notNearest = find(a == neighbourCount);
            neighbourCount = neighbourCount + 1;
        end
        
        % Identify the base station with the identified nearest neighbour
        % count with the minimum nearest neighbour distance
        [Nearest,index] = min(Nearest(notNearest));
        index = notNearest(index);
        
        % Switch off the base station with the minimum nearest neighbour
        % distance
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    % Output the resulting base station set
    BaseStationSO = BaseStation;
    
end


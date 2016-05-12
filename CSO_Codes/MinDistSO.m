function [BaseStationSO] = MinDistSO(BaseStation,percentSO)
% MinDistSO - The random minimum distance cell switch off algorithm
% 
% Syntax: [BaseStationSO] = MinDistSO(BaseStation,percentSO)
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
%   Random Minimum Distance Switch Off algorithm:
%       1) Calculate the base station distance to all neighbours
%       2) Calculate the nearest neighbours of all of the base stations
%       3) Identify the base stations with the minimum distance to their 
%          nearest neighbour (There will be 2 or more)
%       4) Remove the first base station with the minimum nearest neighbour
%          distance

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);

    % Switch off numSO base stations
    for k = 1:numSO
        % Calculate the base station distance to all neighbours
        DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
        
        % Replace distance to self with infinity (important for min
        % function)
        DD(DD==0) = inf;
        
        % Calculate the nearest neighbour of each base station
        [Nearest,index] = min(DD);
        
        % Find the base station with the minimum nearest neighbour distance
        [point, index] = min(Nearest);
        
        % Switch off the base station with the minimum nearest neighbour
        % distance
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    % Output the resulting base station set
    BaseStationSO = BaseStation;
    
end


function [BaseStationSO] = AverageNearestSO(BaseStation,percentSO,numNearest)
% ThirdNearestSO - The average distance of n nearest neighbour cell 
% switch off algorithm
% 
% Syntax: [BaseStationSO] = AverageNearestSO(BaseStation,percentSO,numNearest)
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
%   Minimum Average Distance of N Nearest Neighbour Switch Off algorithm:
%       1) Calculate the base station distance to all neighbours
%       2) Calculate the average distance to the three nearest neighbours
%       3) Remove the base station with the minimum average three nearest
%          neighbour distance

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);

    for k = 1:numSO
        % Calculate the base station distance to all neighbours
        DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
        
        % Replace distance to self with infinity (important for min
        % function)
        DD(DD==0) = inf;
        
        % Preallocate variable memory
        Nearest = zeros(1,length(DD),numNearest);
        index = zeros(1,length(DD),numNearest);
        
        % Calculate the three nearest neighbour of each base station
        for l = 1:numNearest
            [Nearest(:,:,l),index(:,:,l)] = min(DD);
            for j = 1:length(DD)
                DD(index(j),j) = inf;
            end
        end
        
        AverageNearest = sum(Nearest,3) / numNearest;
        
        % Calculate the minimum average three nearest neighbour distance
        [minval,index] = min(AverageNearest);
        
        % Switch off the base station with the minimum average three 
        % nearest neighbour distance
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    % Output the resulting base station set
    BaseStationSO = BaseStation;

end


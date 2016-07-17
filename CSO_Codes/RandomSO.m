function [BaseStationSO] = RandomSO(BaseStation,percentSO)
% RandomSO - The random switch off algorithm
% 
% Syntax: [BaseStationSO] = RandomSO(BaseStation,percentSO)
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
%   Random Switch Off algorithm:
%       1) Randomly switch off base stations

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);
    
    [y,inX] = datasample(BaseStation.ActiveBs(:,1),numSO);
    
    % Switch off the random base stations
    BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(inX,:)];
    BaseStation.ActiveBs(inX,:) = [];

    % Output the resulting base station set
    BaseStationSO = BaseStation;

end


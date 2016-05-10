function [BaseStationSO] = MinDistSO(BaseStation,numSO)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * numSO);

    for k = 1:numSO
        DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
        DD(DD==0) = inf;
        [Nearest,index] = min(DD);
        [point, index] = min(Nearest);
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    BaseStationSO = BaseStation;
    
end


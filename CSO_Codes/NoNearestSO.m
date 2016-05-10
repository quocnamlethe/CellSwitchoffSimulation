function [BaseStationSO] = NoNearestSO(BaseStation,numSO)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    neighborCount = 0;
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * numSO);

    for k = 1:numSO
        neighborCount = 0;
        DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
        DD(DD==0) = inf;
        [Nearest,index] = min(DD);
        [a,b] = hist(index,1:length(DD));
%         x = linspace(1,length(DD),length(DD));
%         notNearest = setxor(b,x);
        notNearest = [];
        
        while isempty(notNearest)
            notNearest = find(a == neighborCount);
            neighborCount = neighborCount + 1;
        end
        
        [Nearest,index] = min(Nearest(notNearest));
        index = notNearest(index);
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    BaseStationSO = BaseStation;
    
end


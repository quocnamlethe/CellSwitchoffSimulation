function [BaseStationSO] = MinDistNumNearestSO(BaseStation,numSO)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * numSO);

    for k = 1:numSO
        DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
        DD(DD==0) = inf;
        [Nearest,index] = min(DD);
        [a,b] = hist(index,unique(index));
        maxval = max(a);
        c = find(a == maxval);
        b = b(c);
        
        minval = min(Nearest);
        minindex = find(Nearest == minval);
        Nearest = Nearest(minindex);
        
        [Nearest,index] = min(Nearest(b));
        index = b(index);
        
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    BaseStationSO = BaseStation;

end


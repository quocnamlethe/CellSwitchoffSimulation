function [BaseStationSO] = NeighborhoodSO(BaseStation,percentSO)
% NeighborhoodSO - The furthest point neighborhood switch off algorithm
% 
% Syntax: [BaseStationSO] = NeighborhoodSO(BaseStation,percentSO)
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
    radius = maxDist/2;
    rsize = radius;
    bestRadius = 0;
    bestSO = nPoints;
    %while(rsize > maxDist*0.01)
    for k = 1:50
        offBS = [];
        [S,index] = datasample(BaseStation.ActiveBs,1);
        W = BaseStation.ActiveBs;
        W(index,:) = [];
        DD = pdist2(W,S);
        index = find(DD < radius);
        offBS = [offBS ; W(index,:)];
        W(index,:) = [];
        while(~isempty(W))
            if (size(W,1) > 1)
                DD = pdist2(W,S);
                DDsum = sum(DD,2);
                [maxSum,index] = max(DDsum);
            else
                index = 1;
            end
            xk = W(index,:);
            W(index,:) = [];
            S = [S ; xk];
            DD = pdist2(W,xk);
            index = find(DD < radius);
            offBS = [offBS ; W(index,:)];
            W(index,:) = [];
        end
        realSO = size(BaseStation.ActiveBs,1) - size(S,1);
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
    
    offBS = [];
    [S,index] = datasample(BaseStation.ActiveBs,1);
    W = BaseStation.ActiveBs;
    W(index,:) = [];
    DD = pdist2(W,S);
    index = find(DD < bestRadius);
    offBS = [offBS ; W(index,:)];
    W(index,:) = [];
    while(~isempty(W))
        if (size(W,1) > 1)
            DD = pdist2(W,S);
            DDsum = sum(DD,2);
            [maxSum,index] = max(DDsum);
        else
            index = 1;
        end
        xk = W(index,:);
        W(index,:) = [];
        S = [S ; xk];
        DD = pdist2(W,xk);
        index = find(DD < bestRadius);
        offBS = [offBS ; W(index,:)];
        W(index,:) = [];
    end
    
    realSO = size(BaseStation.ActiveBs,1) - size(S,1);
    
    BaseStation.InactiveBs = offBS;
	BaseStation.ActiveBs = S;
    
    % greedy addition and greedy deletion steps
    if (realSO > numSO)
        BaseStation = GreedyAddSOn(BaseStation,realSO - numSO);
    elseif (realSO < numSO)
        BaseStation = MinDistNumNearestSO(BaseStation,(numSO - realSO)/size(S,1));
    end
    
    % Output the resulting base station set
    BaseStationSO = BaseStation;
    
%     for k = 1:numSO
%         % Calculate the base station distance to all neighbours
%         DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
%         
%         % Replace distance to self with infinity (important for min
%         % function)
%         DD(DD==0) = inf;
%         
%         % Calculate the nearest neighbour of each base station
%         [Nearest,index] = min(DD);
%         
%         % Calculate the second nearest neighbour of each base station
%         for j = 1:length(DD)
%             DD(index(j),j) = inf;
%         end
%         [Nearest2,index2] = min(DD);
%         
%         % Calculate the minimum nearest neighbour distance
%         minval = min(Nearest);
%         
%         % Identify the base stations with the minimum nearest neighbour
%         % distance
%         minindex = find(Nearest == minval);
%         minindex = index(minindex);
%         
%         % Calculate the nearest neighbour count of each base station with
%         % the minimum nearest neighbour distance
%         [a,b] = hist(index,1:length(BaseStation.ActiveBs));
%         a = a(minindex);
%         b = b(minindex);
%         
%         % Calculate the maximum nearest neighbour count of base stations
%         % with the minimum nearest neighbour distance
%         maxval = max(a);
%         c = find(a == maxval);
%         b = b(c);
%         
%         % Identify the base station with the second minimum nearest
%         % neighbour distance
%         [Nearest2,index2] = min(Nearest2(b));
%         index2 = b(index2);
%         
%         % Switch off the base station with the minimum nearest neighbour
%         % distance
%         BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index2,:)];
%         BaseStation.ActiveBs(index2,:) = [];
%     end
% 
%     % Output the resulting base station set
%     BaseStationSO = BaseStation;

end


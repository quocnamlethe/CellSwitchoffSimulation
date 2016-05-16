function [BaseStationSO] = MinEdgeSO(BaseStation,percentSO)
% ThirdNearestSO - The third nearest neighbour cell switch off algorithm
% 
% Syntax: [BaseStationSO] = ThirdNearestSO(BaseStation,percentSO)
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
%   Minimum Average Distance of the three Nearest Neighbour Switch Off algorithm:
%       1) Calculate the base station distance to all neighbours
%       2) Calculate the average distance to the three nearest neighbours
%       3) Remove the base station with the minimum average three nearest
%          neighbour distance

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);

    for k = 1:numSO
%         % Calculate the base station distance to all neighbours
%         DD = pdist2(BaseStation.ActiveBs, BaseStation.ActiveBs);
%         
%         % Replace distance to self with infinity (important for min
%         % function)
%         DD(DD==0) = inf;
%         
%         % Preallocate variable memory
%         Nearest = zeros(1,length(DD),3);
%         index = zeros(1,length(DD),3);
%         
%         % Calculate the three nearest neighbour of each base station
%         for l = 1:3
%             [Nearest(:,:,l),index(:,:,l)] = min(DD);
%             for j = 1:length(DD)
%                 DD(index(j),j) = inf;
%             end
%         end
%         
%         AverageNearest = (Nearest(:,:,1) + Nearest(:,:,2) + Nearest(:,:,3)) / 3;
%         
%         % Calculate the minimum average three nearest neighbour distance
%         [minval,index] = min(AverageNearest);
%         
%         % Switch off the base station with the minimum average three 
%         % nearest neighbour distance
%         BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
%         BaseStation.ActiveBs(index,:) = [];

        bound = boundary(BaseStation.ActiveBs(:,1), BaseStation.ActiveBs(:,2));
        bound = unique(bound);

        TRI = delaunay(BaseStation.ActiveBs(:,1),BaseStation.ActiveBs(:,2));

        A = [TRI(:,2) TRI(:,1); TRI(:,3) TRI(:,2); TRI(:,1) TRI(:,3)]; % a mtris of the end points of each edge
        SORTED = sort(A,2); % Sort the rows of A
        Edges = unique(SORTED,'rows');

        [a1] = ismember(Edges(:,1),bound);
        [a2] = ismember(Edges(:,2),bound);

        Iboth = ~(a1 & a2); 
        Iboth = [Iboth, Iboth];
        Eboth = Edges.*Iboth; 
        Eb = Eboth;
        Eb(any(Eb == 0,2),:) = []; 
        L = size(Eb,1);
        
        if L < 2  % if we have less than three points that mean we cannot calculate the CoV
            D_CoV2=NaN;
        else
            D = zeros(L,1); 
            for i = 1:L
                X1 = BaseStation.ActiveBs(Eb(i,1),:); 
                X2 = BaseStation.ActiveBs(Eb(i,2),:); 
                D(i) = pdist([X1; X2]); 
            end
        end
        
        % Calculate the nearest neighbour count of each base station with
        % the minimum nearest neighbour distance
        rotEb = rot90(Eb);
        [a,b] = hist([rotEb(1,:),rotEb(2,:)],1:length(BaseStation.ActiveBs));
        
        A = zeros(length(BaseStation.ActiveBs),1); 
        for i = 1:length(BaseStation.ActiveBs)
            index = find(Eb(:,:) == i);
            index = mod(index(:,1),length(D)) + 1;
            S = sum(D(index));
            A(i) = S / length(index);
        end
        
        [Closest,index] = min(A);
        
        % Switch off the base station with the minimum average three 
        % nearest neighbour distance
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
        
    end

    % Output the resulting base station set
    BaseStationSO = BaseStation;

end


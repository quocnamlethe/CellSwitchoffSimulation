function [BaseStationSO] = MaxRegSqSO(BaseStation,percentSO,modelParam)
% MaxRegSqSO - The maximum regularity cell switch off algorithm
% 
% Syntax: [MaxRegSqSO] = MaxRegSo(BaseStation,percentSO,modelParam)
%
% Outputs:
%   BaseStationSO - a structure containing the model description 
%   representing a set of base stations and their CoVs
%
% Inputs:
%   BaseStation - a structure containing the model description 
%   representing a set of base stations and their CoVs
%   percentSO - the percentage of the base stations to switch off
%   modelParam - the parameters for the model of the area (Requires window
%   size)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Maximum Regularity Switch Off algorithm:
%       1) Calculate the new base station density based on the cell switch
%       off percentage
%       2) Calculate the theoretical locations of base stations that would
%       maximize regularity (hexigonal lattice)
%       3) Keep the closest base station to each of the theoretical
%       locations. This is done sequentially and the base stations with the
%       minimum distances from the theoretical locations are kept first
    
    % Calculate the new base station density based on the cell switch off
    % percentage
    ModelParameters = ModelParaSet();
    ModelParameters.win = modelParam.win;
    ModelParameters.lambda = modelParam.lambda * (1 - percentSO);          
    ModelParameters.alpha_norm = 0;
    modelParam = ModelParameters;
    
    % Assume the Active Base stations are off
    tempBs = BaseStation.ActiveBs;
    BaseStation.ActiveBs = BaseStation.InactiveBs;
    BaseStation.InactiveBs = tempBs;
    
    % Calculate the theoretical locations for base stations that would
    % maximize regularity and center both the theoretical base stations and
    % the inputted base stations
    [regPoints]= UT_LatticeBased('sqUni' , modelParam);
    regPoints = CenterBs(regPoints);
    activeCenter = CenterBs(BaseStation.InactiveBs);
    
    % Initialize minimum average distance to infinity to ensure first loop
    % will overwrite the minimum average distance
    minAvgDist = inf;
    
    % Rotate the theoretical base stations and determine which rotation
    % provides the average minimum distances to the inputted base stations.
    % The theoretical base stations are rotated by 1 degree each time loop
    for k = 0:359
        % Rotate the theoretical base station by 1 degree per loop
        rotPoints = RotateBs(regPoints,k*2*pi/360);
        
        % Calculate the minimum distances to each theoretical base station
        % and the average minimum distances to each theoretical base
        % station
        DD = pdist2(activeCenter, rotPoints);
        minDist = min(DD);
        avgDist = mean(minDist);
        
        % Identify the rotation orientation with the minimum average
        % minimum distance to each theoretical base station
        if avgDist < minAvgDist
            regPoints = rotPoints;
            minAvgDist = avgDist;
        end
    end
    
    % Cut off any points that are ouside of the window
    [rx, ry] = Polygon_rx_ry(modelParam.win);
    in = inpolygon(regPoints(:,1),regPoints(:,2),rx,ry);
    regPoints = regPoints(in,:);
    
    % Calculate the number of base stations to keep on
    numOn = length(regPoints);
 
    % Calculate the base station distance to the regular points and keep on
    % the closest base stations to the theoretical base stations
    % sequentially.
    index = zeros(1,numOn);
    for k = 1:numOn
        DD = pdist2(activeCenter, regPoints(k,:));
        [~, minindex] = min(DD);
        index(k) = minindex;
    end
    
    % Keep on the base station with the minimum distance to the theoretical
    % base stations
    BaseStation.ActiveBs = [BaseStation.ActiveBs ; BaseStation.InactiveBs(index,:)];
    BaseStation.InactiveBs(index,:) = [];

    % Output the resulting base station set
    BaseStationSO = BaseStation;
    
end

% This function centers the inputted base stations. The base stations are
% in the format of [X1,Y1;X2,Y2;...]
function [BsOut] = CenterBs(BsIn)
    minx = min(BsIn(:,1));
    maxx = max(BsIn(:,1));
    miny = min(BsIn(:,2));
    maxy = max(BsIn(:,2));

    centerx = (minx + maxx) / 2;
    centery = (miny + maxy) / 2;
    
    BsIn(:,1) = BsIn(:,1) - centerx;
    BsIn(:,2) = BsIn(:,2) - centery;
    
    BsOut = BsIn;
end

% This function rotates the inputted base stations by rot radians. The base
% stations are in the format of [X1,Y1;X2,Y2;...]
function [BsOut] = RotateBs(BsIn, rot)
    rotMat = [cos(rot) -sin(rot) ; sin(rot) cos(rot)];
    BsOut = BsIn * rotMat;
end

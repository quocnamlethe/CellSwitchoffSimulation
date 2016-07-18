function [BaseStationSO] = GenieAidedSO(BaseStation,percentSO,modelParam) % TODO Header comments
% GenieAidedSO - The genie aided cell switch off algorithm
% 
% Syntax: [BaseStationSO] = GenieAidedSO(BaseStation,percentSO,modelParam)
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
%   Genie Aided Switch Off algorithm:
%       1) Calculate the new base station density based on the cell switch
%       off percentage
%       2) Calculate the theoretical locations of base stations that would
%       maximize regularity (hexigonal lattice)
%       3) Replace the real locations with the theoretical locations of
%       base stations (Genie moved the base stations to best locations)

    nPoints = length(BaseStation.ActiveBs);
    numOn = round(nPoints * (1 - percentSO));

    % Calculate the new base station density based on the cell switch off
    % percentage
    ModelParameters = ModelParaSet();
    ModelParameters.lambda = modelParam.lambda * (1 - percentSO);          
    ModelParameters.alpha_norm = 0;
    ModelParameters.win = modelParam.win * 2;

    [rx, ry] = Polygon_rx_ry(modelParam.win);
    
    % Assume the Active Base stations are off
    tempBs = BaseStation.ActiveBs;
    BaseStation.ActiveBs = BaseStation.InactiveBs;
    BaseStation.InactiveBs = tempBs;
    
    % Calculate the theoretical locations for base stations that would
    % maximize regularity and center both the theoretical base stations and
    % the inputted base stations
    [regPoints]= UT_LatticeBased('hexUni' , ModelParameters);
    regPoints = CenterTheoreticalBs(regPoints);
    centeredPoints = regPoints;
    
    minOnDiff = nPoints;
    
    % Rotate the theoretical base stations and determine which rotation
    % provides the average minimum distances to the inputted base stations.
    % The theoretical base stations are rotated by 1 degree each time loop
    for k = 0:359
        % Rotate the theoretical base station by 1 degree per loop
        rotPoints = RotateBs(centeredPoints,k*2*pi/360);
        
        inp = inpolygon(rotPoints(:,1),rotPoints(:,2),rx,ry);
        OnDiff = abs(sum(inp) - numOn);
        if (OnDiff < minOnDiff)
            minOnDiff = OnDiff;
            regPoints = rotPoints(inp,:);
        end
    end
    
    % Keep on the base station with the minimum distance to the theoretical
    % base stations
    BaseStation.ActiveBs = [BaseStation.ActiveBs ; regPoints];
    BaseStation.InactiveBs = [];

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

function [BsOut] = CenterTheoreticalBs(BsIn)

    DD = pdist2(BsIn,[0,0]);
    [~,minIndex] = min(DD);
    
    centerx = BsIn(minIndex,1);
    centery = BsIn(minIndex,2);
    
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

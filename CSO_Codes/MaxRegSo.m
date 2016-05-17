function [BaseStationSO] = MaxRegSo(BaseStation,percentSO,modelParam) % TODO Header comments
% MinVoronoiSO - The minimum voronoi area cell switch off algorithm
% 
% Syntax: [BaseStationSO] = MinVoronoiSO(BaseStation,percentSO)
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
%   Minimum Voronoi Area Switch Off algorithm:
%       1) Calculate the base station voronoi areas
%       2) Identify the base station with the minimum voronoi area
%       3) Remove the base station with the minimum voronoi area

    % Calculate the number of base stations to switch off
    nPoints = length(BaseStation.ActiveBs);
    numSO = round(nPoints * percentSO);
    
    activePoints = nPoints - numSO;
    rx = BaseStation.ActiveBs(:,1);
    ry = BaseStation.ActiveBs(:,2);
    
    ModelParameters = ModelParaSet();
    ModelParameters.lambda = modelParam.lambda * (1 - percentSO);          
    ModelParameters.alpha_norm = 0;
    modelParam = ModelParameters;
    
    Win = modelParam.win;
    
    minx = min(rx); 
    maxx = max(rx);
    miny = min(ry); 
    maxy = max(ry);
    rangex = maxx - minx;
    rangey = maxy - miny;
    stepx = floor(rangex/floor(sqrt(activePoints)));
    stepy = floor(rangey/floor(sqrt(activePoints)));
    
    [X,Y] = meshgrid(minx:stepx:maxx, miny:stepy:maxy);
    
    colx = size(X,2);
    rowx = size(X,1);
    
    translation = repmat([0; stepx/2],[floor(rowx/2),colx]);
    translation = padarray(translation,[rowx-size(translation,1)],0,'post');
    X = X + translation;
    
    regPoints = [reshape(X,[],1),reshape(Y,[],1)];
    regPoints(:,1) = regPoints(:,1) - (max(regPoints(:,1)) + min(regPoints(:,1)))/2;
    regPoints(:,2) = regPoints(:,2) - (max(regPoints(:,2)) + min(regPoints(:,2)))/2;
    
    [rx, ry ] = Polygon_rx_ry(Win);
    
    in = inpolygon(regPoints(:,1),regPoints(:,2),rx,ry);
    regPoints = regPoints(in,:);
    
    tempBs = BaseStation.ActiveBs;
    BaseStation.ActiveBs = BaseStation.InactiveBs;
    BaseStation.InactiveBs = tempBs;
    
    [regPoints]= UT_LatticeBased('hexUni' , modelParam);
    regPoints = CenterBs(regPoints);
    activeCenter = CenterBs(BaseStation.InactiveBs);
    
    rotPoints = regPoints;
    minAvgDist = inf;
    
    for k = 0:100
        rotPoints = RotateBs(regPoints,k*2*pi/100);
        DD = pdist2(activeCenter, rotPoints);
        minDist = min(DD);
        avgDist = mean(minDist);
        if avgDist < minAvgDist
            regPoints = rotPoints;
            minAvgDist = avgDist;
        end
    end
    
    numOn = length(regPoints);
 
    % Calculate the base station distance to the regular points
    index = zeros(1,numOn);
    for k = 1:numOn
        DD = pdist2(activeCenter, regPoints(k,:));
        [~, minindex] = min(DD);
        index(k) = minindex;
    end
%     DD = pdist2(BaseStation.InactiveBs, regPoints);
%     [onPoints, index] = min(DD);
    
%     figure(2)
%     plot(regPoints(:,1),regPoints(:,2),'+b',BaseStation.InactiveBs(:,1),BaseStation.InactiveBs(:,2),'+r');
%     hold on;
%     [vxp,vyp] = voronoi(regPoints(:,1),regPoints(:,2));
%     plot(vxp,vyp,'r-','linewidth',2)
%     axis([-500 500 -500 500]);
%     hold off;
    
    BaseStation.ActiveBs = [BaseStation.ActiveBs ; BaseStation.InactiveBs(index,:)];
    BaseStation.InactiveBs(index,:) = [];

    % Output the resulting base station set
    BaseStationSO = BaseStation;
    
end

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

function [BsOut] = RotateBs(BsIn, rot)
    rotMat = [cos(rot) -sin(rot) ; sin(rot) cos(rot)];
    BsOut = BsIn * rotMat;
end

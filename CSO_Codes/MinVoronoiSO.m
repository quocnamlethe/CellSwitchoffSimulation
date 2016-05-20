function [BaseStationSO] = MinVoronoiSO(BaseStation,percentSO,modelParam)
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
%   modelParam - the parameters for the model of the area (Requires window
%   size)
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

    % Switch off numSO base stations
    for k = 1:numSO
        Xu = BaseStation.ActiveBs;
        Win = modelParam.win;
        [rx, ry ] = Polygon_rx_ry(Win);
        Ep = 1.5;
        EA = 1;

        in = inpolygon(Xu(:,1),Xu(:,2),Ep*rx,Ep*ry); 
        Xu = Xu(in,:);
        minx = min(rx) * EA; 
        maxx = max(rx) * EA;
        miny = min(ry) * EA; 
        maxy = max(ry) * EA;
        
        %Xu = Mirror_BordersPoints(Xu,Win);

        [v, c] = voronoin(Xu);
        L = size(c ,1);
        Tess_area = zeros(1,L);
        for i = 1 : L
            ind = c{i}';
            if any(v(ind,1) > maxx) || any(v(ind,1) < minx) ...
                        || any(v(ind,2) > maxy) || any(v(ind,2) < miny) % take less time than using inpolygon function by afactor of 2.8 to 12 depending on the number of users. 
                    Tess_area(i) = Inf;
            else
                    Tess_area(i) = polyarea( v(ind,1), v(ind,2));
            end
        end
        
        % Find the base station with the minimum voronoi area
        [point, index] = min(Tess_area);
        
        % Switch off the base station with the minimum nearest neighbour
        % distance
        BaseStation.InactiveBs = [BaseStation.InactiveBs; BaseStation.ActiveBs(index,:)];
        BaseStation.ActiveBs(index,:) = [];
    end

    % Output the resulting base station set
    BaseStationSO = BaseStation;
    
end


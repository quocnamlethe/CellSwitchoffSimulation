function [lattice] = HexLattice()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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
    lattice = regPoints(in,:);


end


function [] = DrawCell(origin,scaling,onColor,offColor,onoff)
%UNTITLED2 Summary of this function goes here
%   origin - The center of the base station
%   scaling - The scaling size of the base station (Initial size is 10x15)
%   onColor - The color of an on base station e.g. [0,0,0]
%   offColor - The color of an off base station e.g. [0.5,0.5,0.5]
%   onoff - The state of the base station

    % Outer lines
    x = [-2 0 2 -2];
    y = [0 10 0 0];
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    
    % Zig Zag
    ls = @(y) -2 + 2/10*y;
    rs = @(y) 2 - 2/10*y;
    x = [ls(1) rs(3) ls(5) rs(7)];
    y = [1 3 5 7];
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    x = [rs(1) ls(3) rs(5) ls(7)];
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);

    xrot = @(r,rot) r*cos(rot);
    yrot = @(r,rot) r*sin(rot) + 10;
    rot = linspace(-pi/3.5,pi/3.5);
    
    xin = xrot(1,rot);
    yin = yrot(1,rot);
    drawLine(xin,yin,origin,scaling,onColor,offColor,onoff);
    points = RotatePoints([xin' , yin'],[0 10],pi);
    drawLine(points(:,1),points(:,2),origin,scaling,onColor,offColor,onoff);
    
    xin = xrot(2,rot);
    yin = yrot(2,rot);
    drawLine(xin,yin,origin,scaling,onColor,offColor,onoff);
    points = RotatePoints([xin' , yin'],[0 10],pi);
    drawLine(points(:,1),points(:,2),origin,scaling,onColor,offColor,onoff);
    
    axis off
end

function drawLine(x,y,origin,scaling,onColor,offColor,onoff)
    x = x * scaling + origin(1);
    y = y * scaling + origin(2) - 5*scaling; % To change the origin point of the base station change the 5 value
    if strcmp(onoff,'on')
        line(x,y,'LineWidth',0.7*scaling/12,'Color',onColor);
    else
        line(x,y,'LineWidth',0.5*scaling/12,'Color',offColor);
    end
end

function [pointsOut] = RotatePoints(pointsIn,center,rotation)
%UNTITLED Summary of this function goes here
%   pointsIn - points to be rotated in the form of [x1,y1 ; x2,y2 ; ...]
%   center - the center of rotation in the form of [x,y]
%   rotation - the amount to rotate the points by 
%   pointsOut - the rotated points in the form of [x1,y1 ; x2,y2 ; ...]

    rotMat = [cos(rotation) -sin(rotation) ; sin(rotation) cos(rotation)];
    centerMat = repmat(center,size(pointsIn,1),1);
    centeredPoints = pointsIn - centerMat;
    pointsOut = centeredPoints * rotMat + centerMat;

end




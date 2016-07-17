function [] = DrawCell(origin,scaling,onColor,offColor,onoff)
%UNTITLED2 Summary of this function goes here
%   origin - The center of the base station
%   scaling - The scaling size of the base station (Initial size is 10x15)
%   onoff - The state of the base station

    % Outer lines
    x = [-2 0 2];
    y = [0 10 0];
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    
    % Zig Zag
    ls = @(y) -2 + 2/10*y;
    rs = @(y) 2 - 2/10*y;
    x = [ls(1) rs(3) ls(5) rs(7)];
    y = [1 3 5 7];
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    x = [rs(1) ls(3) rs(5) ls(7)];
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    
    % Signal lines
    xin = [0;1;2;3;4;5]/2;
    yin = [-0.5;0.5;-0.5;0.5;-0.5;0.5]/2;
    [x,y] = rotateSignalLine(xin,yin,pi/6);
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    [x,y] = rotateSignalLine(xin,yin,5*pi/6);
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    [x,y] = rotateSignalLine(xin,yin,3*pi/2);
    drawLine(x,y,origin,scaling,onColor,offColor,onoff);
    axis off
end

function drawLine(x,y,origin,scaling,onColor,offColor,onoff)
    x = x * scaling + origin(1);
    y = y * scaling + origin(2) - 7.5*scaling;
    if strcmp(onoff,'on')
        line(x,y,'LineWidth',0.7,'Color',onColor);
    else
        line(x,y,'LineWidth',0.5,'Color',offColor);
    end
end

function [x,y] = rotateSignalLine(xin,yin,rot)
    rotMat = [cos(rot) -sin(rot) ; sin(rot) cos(rot)];
    rotxy = [xin yin];
    rotxy = rotxy + repmat([1 0],size(rotxy,1),1);
    rotxy = rotxy * rotMat;
    rotxy = rotxy + repmat([0 10],size(rotxy,1),1);
    x = rotxy(:,1);
    y = rotxy(:,2);
end


function [] = DrawCell(origin,scaling,onoff)
%UNTITLED2 Summary of this function goes here
%   origin - The center of the base station
%   scaling - The scaling size of the base station (Initial size is 10x15)
%   onoff - The state of the base station

    % Outer lines
    x = [-2 -2+2/10*(10-2*cos(pi/3)) 2-2/10*(10-2*cos(pi/3)) 2];
    y = [0 10-2*cos(pi/3) 10-2*cos(pi/3) 0];
    drawLine(x,y,origin,scaling,onoff);
    
    % Zig Zag
    ls = @(y) -2 + 2/10*y;
    rs = @(y) 2 - 2/10*y;
    x = [ls(1) rs(3) ls(5) rs(7)];
    y = [1 3 5 7];
    drawLine(x,y,origin,scaling,onoff);
    x = [rs(1) ls(3) rs(5) ls(7)];
    drawLine(x,y,origin,scaling,onoff);
    
    % Top triangle?
    x = [0 2*sin(pi/3) -2*sin(pi/3) 0];
    y = [12 10-2*cos(pi/3) 10-2*cos(pi/3) 12];
    %drawLine(x,y,origin,scaling,onoff);
    
    hold on
    
    x = x * scaling + origin(1);
    y = y * scaling + origin(2) - 7.5*scaling;
    if strcmp(onoff,'on')
        fill(x,y,'k','LineWidth',4,'EdgeColor','k');
    else
        fill(x,y,[0.7 0.7 0.7],'LineWidth',2,'EdgeColor',[0.7 0.7 0.7]);
    end
    
    % Signal lines
    xin = [0;1;2;3;4;5]/2;
    yin = [-0.5;0.5;-0.5;0.5;-0.5;0.5]/2;
    [x,y] = rotateSignalLine(xin,yin,pi/6);
    drawLine(x,y,origin,scaling,onoff);
    [x,y] = rotateSignalLine(xin,yin,5*pi/6);
    drawLine(x,y,origin,scaling,onoff);
    [x,y] = rotateSignalLine(xin,yin,3*pi/2);
    drawLine(x,y,origin,scaling,onoff);
end

function drawLine(x,y,origin,scaling,onoff)
    x = x * scaling + origin(1);
    y = y * scaling + origin(2) - 7.5*scaling;
    if strcmp(onoff,'on')
        line(x,y,'LineWidth',4,'Color','k');
    else
        line(x,y,'LineWidth',2,'Color',[0.7 0.7 0.7]);
    end
end

function [x,y] = rotateSignalLine(xin,yin,rot)
    rotMat = [cos(rot) -sin(rot) ; sin(rot) cos(rot)];
    rotxy = [xin yin];
    rotxy = rotxy + repmat([2.4 0],size(rotxy,1),1);
    rotxy = rotxy * rotMat;
    rotxy = rotxy + repmat([0 10],size(rotxy,1),1);
    x = rotxy(:,1);
    y = rotxy(:,2);
end


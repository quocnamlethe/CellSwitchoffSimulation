function [] = DrawCell2(ax,origin,scaling)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % Inner Triangle
    x = [0 sin(pi/3) -sin(pi/3) 0] * 0.5;
    y = [1 -cos(pi/3) -cos(pi/3) 1] * 0.5;
    drawLine(x,y,origin,scaling);
    
    % Outer Triangle
    x = [0 3*sin(pi/3) -3*sin(pi/3) 0];
    y = [3 -3*cos(pi/3) -3*cos(pi/3) 3];
    %drawLine(x,y,origin,scaling);
    
    % Connect Inner and Outer Triangle
    x = [0 0];
    y = [1 3] .* [0.5 1];
    drawLine(x,y,origin,scaling);
    x = [sin(pi/3) 3*sin(pi/3)] .* [0.5 1];
    y = [-cos(pi/3) -3*cos(pi/3)] .* [0.5 1];
    drawLine(x,y,origin,scaling);
    x = [-sin(pi/3) -3*sin(pi/3)] .* [0.5 1];
    y = [-cos(pi/3) -3*cos(pi/3)] .* [0.5 1];
    drawLine(x,y,origin,scaling);
    
    % Zig Zags
    leg1x = @(ii) ii*2*sin(pi/3)/4-3*sin(pi/3) ;
    leg1y = @(ii) ii*2*cos(pi/3)/4-3*cos(pi/3);
    leg2x = @(ii) -ii*2*sin(pi/3)/4+3*sin(pi/3);
    leg2y = @(ii) ii*2*cos(pi/3)/4-3*cos(pi/3);
    leg3x = @(ii) 0;
    leg3y = @(ii) 3-ii*2/4;
    % Draw bottom
    x = [leg1x(1) leg2x(2) leg1x(3)];
    y = [leg1y(1) leg2y(2) leg1y(3)];
    drawLine(x,y,origin,scaling);
    x = [leg2x(1) leg1x(2) leg2x(3)];
    y = [leg2y(1) leg1y(2) leg2y(3)];
    drawLine(x,y,origin,scaling);
    % Draw left
    x = [leg1x(1) leg3x(2) leg1x(3)];
    y = [leg1y(1) leg3y(2) leg1y(3)];
    drawLine(x,y,origin,scaling);
    x = [leg3x(1) leg1x(2) leg3x(3)];
    y = [leg3y(1) leg1y(2) leg3y(3)];
    drawLine(x,y,origin,scaling);
    % Draw right
    x = [leg2x(1) leg3x(2) leg2x(3)];
    y = [leg2y(1) leg3y(2) leg2y(3)];
    drawLine(x,y,origin,scaling);
    x = [leg3x(1) leg2x(2) leg3x(3)];
    y = [leg3y(1) leg2y(2) leg3y(3)];
    drawLine(x,y,origin,scaling);
    
    % Signal lines
    xin = [0;1;2;3;4;5]/3;
    yin = [-0.5;0.5;-0.5;0.5;-0.5;0.5]/3;
    [x,y] = rotateSignalLine(xin,yin,pi/2);
    drawLine(x,y,origin,scaling);
    [x,y] = rotateSignalLine(xin,yin,7*pi/6);
    drawLine(x,y,origin,scaling);
    [x,y] = rotateSignalLine(xin,yin,11*pi/6);
    drawLine(x,y,origin,scaling);
end

function drawLine(x,y,origin,scaling)
    x = x * scaling + origin(1);
    y = y * scaling + origin(2);
    line(x,y);
end

function [x,y] = rotateSignalLine(xin,yin,rot)
    rotMat = [cos(rot) -sin(rot) ; sin(rot) cos(rot)];
    rotxy = [xin yin];
    rotxy = rotxy + repmat([2 0],size(rotxy,1),1);
    rotxy = rotxy * rotMat;
    x = rotxy(:,1);
    y = rotxy(:,2);
end


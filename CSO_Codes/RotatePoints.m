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


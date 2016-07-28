function [BaseStations] = RawBs(ActiveBs, InactiveBs, Perturbation, SwitchOff)
% BaseStationSet - The model description used to represent a set of base
% stations and their CoVs
% 
% Syntax: [BaseStations] = BaseStationSet(Tag)
%
% Outputs:
%   BaseStations - a structure containing the model description 
%   representing a set of base stations and their CoVs
%
% Inputs:
%   Tag - the tag used to identify this set of base stations
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Base Station Set:
%       Tag - the tag used to identify this set of base stations
%       ActiveBs - the active base stations in the set
%       InactiveBs - the inactive base stations in the set
%       CN - the nearest CoV metric
%       CV - the Voronoi CoV metric
%       CD - the Delaunay CoV metric
%       TestPlot - An array of TestPlot structures that contain test plot
%       points
    
    % Defining and returning the BaseStation structure
    BaseStations = struct( 'ActiveBs', ActiveBs, ...
                           'InactiveBs', InactiveBs, ...
                           'Perturbation', Perturbation, ...
                           'SwitchOff', SwitchOff ...
                           );

end


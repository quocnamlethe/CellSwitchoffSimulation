function [TestPlot] = TestPlotSet(Tag)
% TestPlotSet - The model description used to represent a set of test plots
% points
% 
% Syntax: [TestPlot] = TestPlotSet(Tag)
%
% Outputs:
%   TestPlot - a structure containing array of test plot points
%
% Inputs:
%   Tag - the tag used to identify this test plot set
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Test Plot Set:
%       Tag - the tag used to identify this test plot set
%       ActiveBs - the active base stations in the set
%       CnData - the nearest CoV metric plot set [Input CoV, Output CoV]
%       CvData - the Voronoi CoV metric plot set [Input CoV, Output CoV]
%       CdData - the Delaunay CoV metric plot set [Input CoV, Output CoV]
    
    % Defining and returning the BaseStation structure
    TestPlot = struct( 'Tag', Tag, ...
                       'CnData', [], ...
                       'CvData', [], ...
                       'CdData', [], ...
                       'SirData', [] ...
                       );

end


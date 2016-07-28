function [CsoTest] = CsoTestSet(testNum)
% CsoTestSet - The model description used to represent a cell switch off
% test set
% 
% Syntax: [CsoTest] = CsoTestSet()
%
% Inputs:
%   testNum - the number of tests in the test set
%
% Outputs:
%   CsoTest - a structure containing the model description representing the
%   cell switch off test set
%
% Other m-files required: BaseStationSet.m, ModelParaSet.m
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Cell Switch Off Test Set:
%       InitialBs - the unaltered set of base stations (all active)
%       ModelParameters - the model description used to generate the base 
%                         station locations
%       TestBs - the set of base stations that were tested (cells were 
%                switched off). Has indexes 1,2,3,4.
%       CnData - the CN CoV data points for the test set
%       CvData - the CV CoV data points for the test set
%       CdData - the CD CoV data points for the test set

    % Initializing the Initial BaseStation set
    InitialBs = BaseStationSet('Initial');
    % Initializing the model parameters
    ModelParameters = ModelParaSet();

    % Initializing the Test BaseStation sets
    TestBs = [];
    for k = 1:testNum
        TestBs = [TestBs, BaseStationSet(strcat('test', num2str(k)))];
    end
    
    % Defining and returning the Cell Switch Off test set structure
    CsoTest = struct( 'InitialBs', InitialBs, ...
                      'ModelParameters', ModelParameters, ...
                      'TestBs', TestBs, ...
                      'RawBs', [] ...
                      );

end


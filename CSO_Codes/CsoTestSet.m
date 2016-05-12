function [CsoTest] = CsoTestSet()
% CsoTestSet - The model description used to represent a cell switch off
% test set
% 
% Syntax: [CsoTest] = CsoTestSet()
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

    % Initializing the Initial BaseStation set
    InitialBs = BaseStationSet('Initial');
    % Initializing the model parameters
    ModelParameters = ModelParaSet();

    % Initializing the Test BaseStation sets
    TestBs = [];
    for k = 1:4
        TestBs = [TestBs, BaseStationSet(strcat('test', num2str(k)))];
    end
    
    % Defining and returning the Cell Switch Off test set structure
    CsoTest = struct( 'InitialBs', InitialBs, ...
                      'ModelParameters', ModelParameters, ...
                      'TestBs', TestBs ...
                      );

end


function [CsoTest] = CsoTestSet()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    InitialBs = BaseStationSet('Initial');
    ModelParameters = ModelParaSet();

    TestBs = [];    
    for k = 1:4
        TestBs = [TestBs, BaseStationSet(strcat('test', num2str(k)))];
    end
    
    CsoTest = struct( 'InitialBs', InitialBs, ...
                      'ModelParameters', ModelParameters, ...
                      'TestBs', TestBs ...
                      );

end


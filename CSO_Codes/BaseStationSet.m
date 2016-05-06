function [BaseStations] = BaseStationSet(Tag)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    ActiveBs = [];
    InactiveBs = [];
    CN = 0;
    CV = 0;
    CD = 0;
    
    BaseStations = struct( 'Tag', Tag, ...
                           'ActiveBs', ActiveBs, ...
                           'InactiveBs', InactiveBs, ...
                           'CN', CN, ...
                           'CV', CV, ...
                           'CD', CD ...
                           );

end


function [CoV, CoV_V, CoV_D] = CoV_Metrics(Xu, ModelParameters)
% CoV_Metrics - Calculates the CoV metrics for a set of points Xu
% 
% Syntax: [CoV, CoV_V, CoV_D] = CoV_Metrics(Xu, ModelParameters)
%
% Inputs:
%   Xu - the set of points (Nx2 matrix)
%   ModelPar - the model paramters structure generated by the ModelParaSet
%   function
% 
% Outputs:
%   CoV - the nearest CoV metric
%   CoV_V - the Voronoi CoV metric
%   CoV_D - the Delaunay CoV metric 
%
% Other m-files required: Polygon_rx_ry.m, Mirror_BordersPoints.m
% Subfunctions:
%   [N_CoV] = Nearest_CoV(Xu, ModelParameters) - calculates the nearest CoV
%   [COV] = Voronoin_CoV(Xu,ModelParameters) - calculates the voronoi CoV
%   [D_CoV]=Delaunay_CoV(Xu, ModelParameters) - calculates the delaunay CoV
% MAT-files required: none
%
% Additional Info:
%   Model Parameters:
%       win - the study region
%       lambda - the density of the points per 1 m^2
%       alpha_norm - the normalized perterbation distance
%       r_norm - the normalized hard-core distance
%       gama - TODO
%       metric - the CoV metric. Options are: 'CN', 'CV', 'CD', or 'All'

    MetricType = ModelParameters.metric; 

    switch MetricType
        case 'CN'
            CoV = Nearest_CoV(Xu, ModelParameters);
            CoV_V = NaN;
            CoV_D = NaN;
        case 'CV'
            CoV = NaN;
            CoV_V = Voronoin_CoV(Xu, ModelParameters);
            CoV_D = NaN;
        case 'CD'
            CoV = NaN;
            CoV_V = NaN;
            CoV_D = Delaunay_CoV(Xu, ModelParameters);
        case 'All'
            CoV = Nearest_CoV(Xu, ModelParameters);
            CoV_V = Voronoin_CoV(Xu, ModelParameters);
            CoV_D = Delaunay_CoV(Xu, ModelParameters);
    end

    %==========================================================================
    % Nested functions 
    % [1]
    % Calculates the nearest CoV
    function [N_CoV] = Nearest_CoV(Xu, ModelParameters)
            %=========== 
            win = ModelParameters.win;  
            [rx, ry ] = Polygon_rx_ry(win);
            in = inpolygon(Xu(:,1),Xu(:,2),rx,ry); 
            Xu = Xu(in,:);
            nPoint = size(Xu,1);
            
            if nPoint < 3 % if we have only two points, then the CN is NaN
               N_CoV=NaN;
            else

            k = boundary(Xu(:,1), Xu(:,2));
            k = unique(k); 
            nk=length(k);
            
            %===========
            DD = pdist2(Xu, Xu);
            DD(DD==0) = inf;
            if (nk < nPoint-1)
                 DD(:,k)=[]; 
            end

            Nearest = min(DD);
            N_CoV = std(Nearest)/mean(Nearest)/0.5227;
            end
            %===========
    end
    % =========================================================================
    % [2]
    % Calculates the voronoi CoV
    function [COV] = Voronoin_CoV(Xu,ModelParameters)
        %=========== 
        win=ModelParameters.win;  
        [rx, ry ] = Polygon_rx_ry(win);
        Ep=1;

        if Ep >= 1
            in = inpolygon(Xu(:,1),Xu(:,2),Ep*rx,Ep*ry); 
            Xu = Xu(in,:);
            minx = min(rx); 
            maxx = max(rx);
            miny = min(ry); 
            maxy = max(ry);
        else   
            in = inpolygon(Xu(:,1),Xu(:,2),rx,ry);
            Xu = Xu(in,:);
            minx = min(Ep*rx);
            maxx = max(Ep*rx);
            miny = min(Ep*ry); 
            maxy = max(Ep*ry);
        end               

        nPoints=length(Xu); 
        if nPoints < 3 % this condition to avoid having errors in the function "voronoin" when the number of points is very samll (Not enough unique points specified).
            COV=NaN;
        else
            [v, c] = voronoin(Xu);
            L=size(c ,1);
            Tess_area=zeros(1,L);
            for i = 1 : L
                ind = c{i}';
                if any(v(ind,1) > maxx) || any(v(ind,1) < minx) ...
                       || any(v(ind,2) > maxy) || any(v(ind,2) < miny) % take less time than using inpolygon function by afactor of 2.8 to 12 depending on the number of users. 
                    Tess_area(i) = Inf;
                else
                    Tess_area(i) = polyarea( v(ind,1), v(ind,2));
                end
            end
            areas = Tess_area(isfinite(Tess_area));                   
            COV = std(areas)/mean(areas)/0.5293;
        end
    end
    %==========================================================================
    % [3]
    % Calculates the delaunay CoV
    function [D_CoV]=Delaunay_CoV(Xu, ModelParameters)
        win = ModelParameters.win; 
        [rx, ry ] = Polygon_rx_ry(win);

        in = inpolygon(Xu(:,1),Xu(:,2),rx,ry);      
        Xu = Xu(in,:);
        nPoints=length(Xu);
        
        if nPoints < 3  % if we have less than three points that means we cannot calculate the CoV
            D_CoV1 = NaN;
        else
            [Xm, Ib] = Mirror_BordersPoints(Xu, win);
            TRI = delaunay(Xm(:,1),Xm(:,2));

            A=[TRI(:,2) TRI(:,1); TRI(:,3) TRI(:,2); TRI(:,1) TRI(:,3)]; % a matrix of the end points of each edge
            SORTED=sort(A,2); % Sort the rows of A
            Edges = unique(SORTED,'rows');

            %================
            I = Edges <= nPoints; % Flag 1 for points that inside the region and flag 0 for the points outside the region
                                  % our knowledge about the points that our side the region
                                  % have index greater than nPoints because we know that the
                                  % function Mirror_BordersPoints adds the mirrored points to points list after the last point of the original set  before mirroring)  
                                  % function 
            EDGES = Edges.*I; % replace the index of each point that is out side the region with zero. 
            EDGES(any(EDGES == 0,2),:) = []; % remove rows that have zero element (= removing edges that have at least one endpoint outside the region.  
            L = size(EDGES,1); 
            D = zeros(L,1); 
            for i=1:L
                X1 = Xm(EDGES(i,1),:); 
                X2 = Xm(EDGES(i,2),:); 
                D(i) = pdist([X1; X2]); 
            end
            D_CoV1 = std(D)/mean(D)/0.492;
        end

        %=======================
        %=======================
        if nPoints < 3  % if we have less than three points that mean we cannot calculate the CoV
            D_CoV2=NaN;
        else
            k = boundary(Xu(:,1), Xu(:,2));
            k = unique(k);
            
            TRI = delaunay(Xu(:,1),Xu(:,2));

            A = [TRI(:,2) TRI(:,1); TRI(:,3) TRI(:,2); TRI(:,1) TRI(:,3)]; % a mtris of the end points of each edge
            SORTED = sort(A,2); % Sort the rows of A
            Edges = unique(SORTED,'rows');

            [a1] = ismember(Edges(:,1),k);
            [a2] = ismember(Edges(:,2),k);

            Iboth = ~(a1 & a2); 
            Iboth = [Iboth, Iboth];
            Eboth = Edges.*Iboth; 
            Eb = Eboth;
            Eb(any(Eb == 0,2),:) = []; 
            L = size(Eb,1); 
            if L < 2  % if we have less than three points that mean we cannot calculate the CoV
                D_CoV2=NaN;
            else
                D = zeros(L,1); 
                for i = 1:L
                    X1 = Xu(Eb(i,1),:); 
                    X2 = Xu(Eb(i,2),:); 
                    D(i) = pdist([X1; X2]); 
                end
                D_CoV2 = std(D)/mean(D)/0.492;
            end
        end

        %=======================
        %=======================
        
        TF = isnan(D_CoV2);
        if TF == 1
           D_CoV = D_CoV1;
        else
           D_CoV = D_CoV2;
        end
    end
end

%  /* Copyright (C) 2016 Faraj Lagum @ Carleton University - All Rights Reserved
%   You may use and modify this code, but not to distribute it.  
%  If You don't have a license to used this code, please write to:
%  faraj.lagum@sce.carleton.ca. */
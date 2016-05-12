
function [Xu,Indx] =Mirror_BordersPoints(user_cordinates, Win)


 minx = Win(1); maxx =Win(2);
 miny = Win(3); maxy =Win(4);
 Rx=maxx-minx;
 Ry=maxy-miny;
 % voronoin
 Length=length(user_cordinates);
 if Length < 3 % this condition to avoid having errors in the function "voronoin" when the number of points is very samll (Not enough unique points specified).
     
     % What we do here is to mirror all the points without using the border points test
        Xcorner=user_cordinates(:, 1); Ycorner=user_cordinates(:,2);
        Xmirrored=[[-Xcorner+2*minx Ycorner]; [Xcorner -Ycorner+2*miny]; [-Xcorner+2*Rx+2*minx Ycorner]; [Xcorner -Ycorner+2*Ry+2*miny]];

        Xu=[user_cordinates; Xmirrored];

      else
 [v, c] = voronoin(user_cordinates);
    
 % ========================
 
 
 
 
 % =======================
 % This part of the code is used to identify the points that have vertices  outside the region boundary 
    
    I=find(v(:,1)< minx | v(:,2)< miny | v(:,1)>maxx | v(:,2)>maxy);
    Indx=zeros(length(c),1);  % index of the points that have at least one  vertix outside the region 
    total_so_far=1;
    
    for k=1:length(c)
        if length(setdiff(I, [c{k,:}]))< length(I)
           Indx(total_so_far)=k;
          
           total_so_far=total_so_far+1; 
        end
    end
        Indx=Indx(1:total_so_far-1); 

        Xcorner=user_cordinates(Indx, 1); Ycorner=user_cordinates(Indx,2); %  the points that have at least one  vertix outside the region 
        
   % end of the new added part 
        
    %================================



    % mirroring points that have vertices  outside the region boundary and add them to the original points  
    Xmirrored=[[-Xcorner+2*minx Ycorner]; [Xcorner -Ycorner+2*miny]; [-Xcorner+2*Rx+2*minx Ycorner]; [Xcorner -Ycorner+2*Rx+2*miny]];
    Xu=[user_cordinates; Xmirrored];
 end
    
    end

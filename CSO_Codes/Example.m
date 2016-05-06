%function Example 

 ModelParamters=ModelParaSet();
 ModelParamters.lambda=100e-6;          
 ModelParamters.alpha_norm=0;             
[Bs_Locations]= UT_LatticeBased('hexUni' , ModelParamters); 
[CN, CV, CD] = CoV_Metrics(Bs_Locations, ModelParamters); %disp(CoV)

xp=Bs_Locations(:,1); yp=Bs_Locations(:,2);
% 
plot(xp,yp,'+b','linewidth',2);
hold on
% [vx,vy] = voronoi(x,y);
%  plot(x,y,'b+',vx,vy,'b-','linewidth',0.5)
% hold on 

% r=25;
% 
% Xp=AddUniPerterb(Bs_Locations,r); 
% 
%     xp=Xp(:,1); yp=Xp(:,2);
    
delaunay(xp,yp);
DT=delaunayTriangulation(xp,yp); 
%figure(1)
%DefaultFigureSetting

triplot(DT,':g','linewidth',2)
hold on 
box on
axis square
[vxp,vyp] = voronoi(xp,yp);
plot(xp,yp,'r+',vxp,vyp,'r-','linewidth',2)
%voronoi(x,y,'-b','linewidth',2)
hold off
axis([-500 500 -500 500]);
set(gca,'fontsize',14)
ax=gca; 
ax.XTick=0;
ax.YTick=0;
% saveas(gcf,'C:\Users\faraj.lagum\Documents\MATLAB\VTC_2016_Project\FiguresBanK_VTC\DelaunayVoronoi.eps', 'epsc'); 




%  /* Copyright (C) 2016 Faraj Lagum @ Carleton University - All Rights Reserved
%   You may use and modify this code, but not to distribute it.  
%  If You don't have a license to used this code, please write to:
%  faraj.lagum@sce.carleton.ca. */
function [] = PlotSOvsCovOut()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_CDin_vs_CDoutData_1.mat', 'CsoTest');
    
    LegendInfo = {'Random','Semi-greedy deletion','Greedy deletion','Greedy construction','$$ \rm Output \it C_{\rm D} = \rm Input \it C_{\rm D}$$','Genie-aided'};
    LegendPosition = [0.6 0.2 0.3 0.3];
    
    FigLocation = 'data\';
    
    testNum = 4;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'c' 'b' 'y'];
    Marker_Size = 8;
    Line_Width = 2;
    LabelFontSize = 18;
    x = linspace(0,1,11);
    
    for m = 1:4
        f = figure;
        set(f,'name',['CoV In vs CoV Out for ',CsoTest.TestBs(1).TestPlot(m).Tag,' Switch Off'],'numbertitle','off');
        
        tempTag = CsoTest.TestBs(1).TestPlot(m).Tag;
        FigName=[sprintf('Fig_%d_SO_%s_CD',m,tempTag),'.eps']; 

        h = [];
        hold on;

        for k = 1:testNum
            plotdata = CsoTest.TestBs(k).TestPlot(m).CdData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            plot(plotdata(:,1),plotdata(:,2),strcat('-',colours(k),markers(k)),'markersize',Marker_Size,'LineWidth',Line_Width);
        end
        
        plot(x,x,strcat('-',colours(testNum+1),markers(testNum+1)),'markersize',Marker_Size,'LineWidth',Line_Width);
        plot(x,0,strcat('-',colours(testNum+2),markers(testNum+2)),'markersize',Marker_Size,'LineWidth',Line_Width);
        
        axis([0 1.05 -0.1 1.05]);
%         xlabel('Input CD');
%         ylabel('Output CD');
        xlabel('$$ \rm Input \it C_{\rm D}$$','Interpreter','latex','FontSize',LabelFontSize);
        ylabel('$$ \rm Out \it C_{\rm D}$$','Interpreter','latex','FontSize',LabelFontSize);

        %title(['CoV In vs CoV Out for ',CsoTest.TestBs(1).TestPlot(m).Tag,' Switch Off']);
        hold off;

        legend(h,LegendInfo,'Interpreter','latex','Position',LegendPosition);
        
        grid on;
        
        set(gca,'fontsize',LabelFontSize);
        
        FignameLocation=[FigLocation,FigName]; 
        saveas(f,FignameLocation,'epsc');
    end
    
end



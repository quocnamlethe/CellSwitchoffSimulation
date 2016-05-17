function [] = PlotTestPoints()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/TestData.mat', 'CsoTest');
    
    testNum = 5;
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    f = figure;
    set(f,'name','CN','numbertitle','off');
    
    for j = 1:9
        h = [];
        subplot(3,3,j);
        hold on;

        for k = 1:testNum
            plotdata = CsoTest.TestBs(k).TestPlot(j).CnData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            h = [h, plot(plotdata(:,1),plotdata(:,2),strcat('.',colours(k)))];
            plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        axis([0 1 0 1]);
        title(CsoTest.TestBs(1).TestPlot(j).Tag);
        hold off;
    end
    
    legend(h,'Min Dist','2nd Nearest','Max Num Nearest','Min Voronoi','Max Regularity');
    
    % Plot CV
    f = figure;
    set(f,'name','CV','numbertitle','off');
    
    for j = 1:9
        h = [];
        subplot(3,3,j);
        hold on;

        for k = 1:testNum
            plotdata = CsoTest.TestBs(k).TestPlot(j).CvData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            h = [h, plot(plotdata(:,1),plotdata(:,2),strcat('.',colours(k)))];
            plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        axis([0 1 0 1]);
        title(CsoTest.TestBs(1).TestPlot(j).Tag);
        hold off;
    end
    
    legend(h,'Min Dist','2nd Nearest','Max Num Nearest','Min Voronoi','Max Regularity');
    
    % Plot CD
    f = figure;
    set(f,'name','CD','numbertitle','off');
    
    for j = 1:9
        h = [];
        subplot(3,3,j);
        hold on;

        for k = 1:testNum
            plotdata = CsoTest.TestBs(k).TestPlot(j).CdData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            h = [h, plot(plotdata(:,1),plotdata(:,2),strcat('.',colours(k)))];
            plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        axis([0 1 0 1]);
        title(CsoTest.TestBs(1).TestPlot(j).Tag);
        hold off;
    end
    
    legend(h,'Min Dist','2nd Nearest','Max Num Nearest','Min Voronoi','Max Regularity');
    
end


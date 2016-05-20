function [] = PlotSOvsCovOut()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_SOvsCoVoutData.mat', 'CsoTest');
    
    testNum = 5;
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    f = figure;
    set(f,'name','Switch Off Percentage vs CoV Out','numbertitle','off');
    
    for j = 1:5
        h = [];
        subplot(2,3,j);
        hold on;

        for k = 1:testNum
            CdTemp = zeros(10,2);
            for m = 0:9
                CdData = CsoTest.TestBs(k).TestPlot(j).CdData;
                CdIndex = find(CdData(:,1) == 0.1*m);
                avgCdData = mean(CdData(CdIndex,2));
                CdTemp(m+1,:) = [0.1*m, avgCdData];
            end
            CsoTest.TestBs(k).TestPlot(j).CdData = CdTemp;
        
            plotdata = CsoTest.TestBs(k).TestPlot(j).CdData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            h = [h, plot(plotdata(:,1),plotdata(:,2),colours(k))];
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        axis([0 1 0 1]);
        title(CsoTest.TestBs(1).TestPlot(j).Tag);
        hold off;
    end
    
    legend(h,'Min Dist','2nd Nearest','Max Num Nearest','Min Voronoi','Max Regularity');
    
end


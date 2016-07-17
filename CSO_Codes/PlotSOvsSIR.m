function [] = PlotSOvsSIR()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_SOvsSIRData.mat', 'CsoTest');
    
    testNum = 5;
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    f = figure;
    set(f,'name','Switch Off Percentage vs SIR','numbertitle','off');
    
    for j = 1:5
        h = [];
        subplot(2,3,j);
        hold on;

        for k = 1:testNum
            SirTemp = zeros(10,2);
            for m = 0:9
                SirData = CsoTest.TestBs(k).TestPlot(j).SirData;
                SirIndex = find(SirData(:,1) == 0.1*m);
                avgSirData = mean(SirData(SirIndex,2));
                SirTemp(m+1,:) = [0.1*m, avgSirData];
            end
            CsoTest.TestBs(k).TestPlot(j).SirData = SirTemp;
        
            plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            h = [h, plot(plotdata(:,1),plotdata(:,2),colours(k))];
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        %axis([-50 50 -50 50]);
        xlabel('Switch Off Percentage');
        ylabel('SIR (dB)');
        title(strcat('Input CD: ', CsoTest.TestBs(1).TestPlot(j).Tag));
        hold off;
    end
    
    legend(h,'Greedy Deletion','Max Regularity','Random SO','Genie Aided','NeighborhoodSO');
    
end


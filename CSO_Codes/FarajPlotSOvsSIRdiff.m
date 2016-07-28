function [] = PlotSOvsSIRdiff()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_SOvsSIRdiffFarajData.mat', 'CsoTest');
    
    testNum = 5;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    f = figure;
    set(f,'name','Switch Off Percentage vs SIR difference','numbertitle','off');
    
    for j = 1:6
        h = [];
        subplot(2,3,j);
        hold on;

        for k = 1:testNum
            SirTemp = zeros(10,3);
            for m = 0:9
                SirData = CsoTest.TestBs(k).TestPlot(j).SirData;
                SirIndex = find(SirData(:,1) == 0.1*m);
                avgSirData = mean(SirData(SirIndex,2));
                avgSO = mean(SirData(SirIndex,3));
                SirTemp(m+1,:) = [0.1*m, avgSirData, avgSO];
            end
            CsoTest.TestBs(k).TestPlot(j).SirData = SirTemp;
        
            plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
            plotdata(plotdata(:,3) < 0,3) = 0;
            h = [h, plot(plotdata(:,3),plotdata(:,2),strcat('-',colours(k),markers(k)))];
            hold on;
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        %axis([-50 50 -50 50]);
        xlabel('Switch Off Percentage');
        ylabel('SIR difference (dB)');
        title(strcat('Input CD: ', CsoTest.TestBs(1).TestPlot(j).Tag));
        hold off;
    end
    
    legend(h,'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion');
    
end


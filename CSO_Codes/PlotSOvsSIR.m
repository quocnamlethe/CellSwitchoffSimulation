function [] = PlotSOvsSIR()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_SOvsSIRData2.mat', 'CsoTest');
    
    testNum = 5;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    f = figure;
    set(f,'name','Switch Off Percentage vs SIR','numbertitle','off');
    
    for j = 1:3
        h = [];
        subplot(2,2,j);
        hold on;

        for k = 1:testNum        
            plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
            plotdata(plotdata(1:19,3) < 0,3) = 0;
            h = [h, plot(plotdata(1:19,3),plotdata(1:19,2),strcat('-',colours(k),markers(k)))];
        end

        %axis([-50 50 -50 50]);
        xlabel('Switch Off Percentage');
        ylabel('SIR (dB)');
        title(strcat('Input CD: ', CsoTest.TestBs(1).TestPlot(j).Tag));
        hold off;
    end
    
    legend(h,'Greedy Deletion','Max Regularity','Random SO','Genie Aided','NeighborhoodSO');
    
end


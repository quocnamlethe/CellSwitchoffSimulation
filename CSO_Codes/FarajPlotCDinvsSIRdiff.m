function [] = PlotSOvsSIRdiff()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_CDinvsSIRdiffFarajData.mat', 'CsoTest');
    
    testNum = 5;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    f = figure;
    set(f,'name','Input CD vs SIR difference','numbertitle','off');
    
    for j = 1:4
        h = [];
        subplot(2,2,j);
        hold on;

        for k = 1:testNum  
            plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
            %plotdata(plotdata(:,3) < 0,3) = 0;
            h = [h, plot(plotdata(:,3),plotdata(:,2),strcat('-',colours(k),markers(k)))];
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        %axis([-50 50 -50 50]);
        xlabel('Input CD');
        ylabel('SIR difference (dB)');
        title(strcat('Switch Off Percentage: ', CsoTest.TestBs(1).TestPlot(j).Tag));
        hold off;
    end
    
    legend(h,'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion');
    
end


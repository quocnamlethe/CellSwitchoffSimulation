function [] = PlotSOvsSIRdiff()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_SOvsSIRdiffFarajData_a3_s6_sir95.mat', 'CsoTest');
    
    testNum = 5;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    
    
    PPPSIR = CsoTest.TestBs(1).TestPlot(6).SirData(1,2);
    
    for j = 1:6
        h = [];
        f = figure;
        set(f,'name',['Switch Off Percentage vs SIR difference with Input CD: ', CsoTest.TestBs(1).TestPlot(j).Tag],'numbertitle','off');
        %subplot(2,3,j);
        hold on;

        for k = 1:testNum
        
            plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
            plotdata(plotdata(1:10,3) < 0,3) = 0;
            h = [h, plot(plotdata(1:10,3),plotdata(1:10,2) - PPPSIR,strcat('-',colours(k),markers(k)))];
            hold on;
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end

        %axis([-50 50 -50 50]);
        xlabel('Switch Off Percentage');
        ylabel('SIR difference (dB)');
        %title(strcat('Input CD: ', CsoTest.TestBs(1).TestPlot(j).Tag));
        legend(h,'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion');
        hold off;
    end

end


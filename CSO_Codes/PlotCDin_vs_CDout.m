function [] = PlotSOvsCovOut()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_CDin_vs_CDoutData_1.mat', 'CsoTest');
    
    testNum = 4;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    for m = 1:4
        f = figure;
        set(f,'name',['CoV In vs CoV Out for ',CsoTest.TestBs(1).TestPlot(m).Tag,' Switch Off'],'numbertitle','off');

        h = [];
        hold on;

        for k = 1:testNum
            plotdata = CsoTest.TestBs(k).TestPlot(m).CdData;
            p = polyfit(plotdata(:,1),plotdata(:,2),1);
            h = [h, plot(plotdata(:,1),plotdata(:,2),strcat('-',colours(k),markers(k)))];
        end

        axis([0 1 0 1]);
        xlabel('Input CD');
        ylabel('Output CD');
        %title(['CoV In vs CoV Out for ',CsoTest.TestBs(1).TestPlot(m).Tag,' Switch Off']);
        hold off;

        legend(h,'Random','Semi-greedy deletion','Greedy deletion','Greedy construction');
    end
    
end


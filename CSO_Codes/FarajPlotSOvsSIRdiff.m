function [] = PlotSOvsSIRdiff()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    load('data/Test_SOvsSIRdiffFarajData_a4_s0_sir50.mat', 'CsoTest');
    
    algNum = 5;
    testPert = [0 0.129074508 0.278385168 0.450877783 0.728588577 2];
    percentSO = 0:0.05:0.9;
    
    ModelParameters = ModelParaSet();
    ModelParameters.lambda = 200e-6;
    ModelParameters.metric = 'CD';

    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    x = linspace(0,1);
    
    % Plot CN
    
    
    %PPPSIR = CsoTest.TestBs(1).TestPlot(6).SirData(1,2);
    PPPSIR = mean(cat(1,CsoTest.TestBs(1).RawData(19001:19100).SIR));
    TotalBs = zeros(19,1);
    for l = 1:19
        meanActive = mean(length(cat(1,CsoTest.TestBs(1).RawData(((l-1)*100+1):((l-1)*100+99)).ActiveBs)))/19;
        meanInactive = mean(length(cat(1,CsoTest.TestBs(1).RawData(((l-1)*100+1):((l-1)*100+99)).InactiveBs))/19);
        TotalBs(l) = meanActive+meanInactive;
    end
    
    for j = 1:6
        h = [];
        f = figure;

        
        %subplot(2,3,j);
        hold on;
        
        CDs = zeros(5,1);

        for k = 1:algNum
            
            rawIndex = cat(1,CsoTest.TestBs(k).RawData(:).Perturbation) == testPert(j);
            tempRaw = CsoTest.TestBs(k).RawData(rawIndex);
%             CD = zeros(length(tempRaw),1);
%             for m = 1:length(tempRaw)
%                 [~,~,CD(m)] = CoV_Metrics(tempRaw(m).ActiveBs, ModelParameters);
%             end
%             CDs(k) = mean(CD);
            
            meanSIR = zeros(19,2);
            for l = 1:19
                tempSIR = mean(cat(1,tempRaw(((l-1)*100+1):((l-1)*100+99)).SIR));
                meanActive = mean(length(cat(1,tempRaw(((l-1)*100+1):((l-1)*100+99)).ActiveBs)));
                %meanInactive = mean(length(cat(1,CsoTest.TestBs(k).RawData(((l-1)*100+1):((l-1)*100+99)).InactiveBs)));
                tempSO = mean((TotalBs(l)-meanActive)/TotalBs(l));
                meanSIR(l,:) = [tempSO tempSIR];
            end
%             plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
%             plotdata(plotdata(1:10,3) < 0,3) = 0;
            meanSIR(meanSIR(:,1) < 0,1) = 0;
            h = [h, plot(meanSIR(:,1),meanSIR(:,2) - PPPSIR,strcat('-',colours(k),markers(k)))];
            hold on;
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end
        
%         meanCD = mean(CDs);
%         if meanCD < 0.01
%             meanCD = 0;
%         end
        set(f,'name',['Switch Off Percentage vs SIR difference with Input CD: ', CsoTest.TestBs(1).TestPlot((j-1)*2+1).Tag],'numbertitle','off');

        %axis([-50 50 -50 50]);
        xlabel('Switch Off Percentage');
        ylabel('SIR difference (dB)');
        %title(strcat('Input CD: ', CsoTest.TestBs(1).TestPlot(j).Tag));
        legend(h,'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion');
        hold off;
    end

end


function [] = PlotSOvsSIRdiff()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    load('data/Test_SOvsSIRdiffFarajData_a3_s6_fixed.mat', 'CsoTest');
    
    LegendInfo = {'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion'};
    LegendPosition = [0.50 0.15 0.45 0.35];
    
    FigLocation = 'data\';
    
    algNum = 5;
    testPert = [0 0.129074508 0.278385168 0.450877783 0.728588577 2];
    percentSO = 0:0.05:0.9;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    Marker_Size = 8;
    Line_Width = 2;
    LabelFontSize = 18;
    percentile = 50;
    
    PPPIndex = cat(1,CsoTest.TestBs(1).RawData(:).Perturbation) == 2;
    PPPSIR = cat(1,CsoTest.TestBs(1).RawData(PPPIndex).SIR);
    PPPSIR = prctile(PPPSIR,percentile);
    
    TotalBs = zeros(length(testPert),1);
    
    for l = 1:length(testPert)
        PertIndex = round(cat(1,CsoTest.TestBs(1).RawData.Perturbation)*1e9) == round(testPert(l)*1e9);
        PertRaw = CsoTest.TestBs(1).RawData(PertIndex);
        SOIndex = round(cat(1,PertRaw.SwitchOff)*1e2) == 0;
        SORaw = PertRaw(SOIndex);
        meanActive = mean(length(cat(1,SORaw.ActiveBs)));
        meanInactive = mean(length(cat(1,SORaw.InactiveBs)));
        TotalBs(l) = meanActive+meanInactive;
    end
    
    for j = 1:length(testPert)
        h = [];
        f = figure;
        
        CDs = zeros(algNum,1);

        for k = 1:algNum
            
            rawIndex = round(cat(1,CsoTest.TestBs(k).RawData(:).Perturbation)*1e9) == round(testPert(j)*1e9);
            tempRaw = CsoTest.TestBs(k).RawData(rawIndex);

            CDs(k) = mean(cat(1,tempRaw(:).CDin));
            
            meanSIR = zeros(length(percentSO),2);
            for l = 1:length(percentSO)
                SOIndex = round(cat(1,tempRaw.SwitchOff)*1e2) == round(percentSO(l )*1e2);
                SORaw = tempRaw(SOIndex);
                allSIR = cat(1,SORaw(:).SIR);
                tempSIR = prctile(allSIR,percentile);
                meanActive = mean(length(cat(1,SORaw(:).ActiveBs)));
                tempSO = mean((TotalBs(j)-meanActive)/TotalBs(j));
                meanSIR(l,:) = [tempSO tempSIR];
            end
            plot(meanSIR(:,1),meanSIR(:,2) - PPPSIR,strcat('-',colours(k),markers(k)),'markersize',Marker_Size,'LineWidth',Line_Width);
            hold on;
        end
        
        hold off;
        
        meanCD = mean(CDs);
        if meanCD < 0.01
            meanCD = 0;
        end
        
        tempTag = num2str(meanCD);
        tempName = sprintf('Fig_%d_CD_%s%%_SIRDiff_a3_s6_sir95',j,tempTag);
        FigName=[tempName,'.eps'];
        
        set(f,'name',tempName,'numbertitle','off');
        
        set(f,'name',['Switch Off Percentage vs SIR difference with Input CD: ', num2str(mean(CDs))],'numbertitle','off');

        %axis([-50 50 -50 50]);
        xlabel('Switch Off Percentage');
        ylabel('$S_{g}(0.95)$ (dB)','Interpreter','latex','FontSize',LabelFontSize);
        set(gca,'fontsize',LabelFontSize);
        if j == 1
            legend(LegendInfo,'Interpreter','latex','Location','Best');
        end
        grid on;
    end

end


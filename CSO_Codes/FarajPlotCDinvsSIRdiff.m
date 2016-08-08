function [] = PlotSOvsSIRdiff()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    load('data/Test_SOvsSIRdiffFarajData_a4_s0.mat', 'CsoTest');
    
    LegendInfo = {'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion'};
    LegendPosition = [0.50 0.15 0.45 0.35];
    
    FigLocation = 'data\';
    
    algNum = 5;
    testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
    percentSO = [0.1 0.35 0.65 0.9];
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    Marker_Size = 8;
    Line_Width = 2;
    LabelFontSize = 18;
    percentile = 50;
    x = linspace(0,1);
    
    PPPIndex = cat(1,CsoTest.TestBs(1).RawData(:).Perturbation) == 2;
    PPPSIR = cat(1,CsoTest.TestBs(1).RawData(PPPIndex).SIR);
    PPPSIR = prctile(PPPSIR,percentile);
    
    for j = 1:length(percentSO)
        f = figure;
        
        tempTag = num2str(percentSO(j)*100);
        tempName = sprintf('Fig_%d_SO_%s%%_SIRDiff_a4_s0_sir95',j,tempTag);
        FigName=[tempName,'.eps'];
        
        set(f,'name',tempName,'numbertitle','off');
        
        CDs = zeros(algNum,1);

        for k = 1:algNum
            
            rawIndex = round(cat(1,CsoTest.TestBs(k).RawData(:).SwitchOff)*100) == round(percentSO(j)*100);
            tempRaw = CsoTest.TestBs(k).RawData(rawIndex);

            CDs(k) = mean(cat(1,tempRaw(:).CDin));
            
            meanSIR = zeros(length(testPert),2);
            for l = 1:length(testPert)
                pertIndex = round(cat(1,tempRaw.Perturbation)*1e9) == round(testPert(l)*1e9);
                pertRaw = tempRaw(pertIndex);
                allSIR = cat(1,pertRaw(:).SIR);
                tempSIR = prctile(allSIR,percentile);
                tempCDin = mean(cat(1,pertRaw(:).CDin));
                %tempSIR = mean(cat(1,tempRaw(((l-1)*100+1):((l-1)*100+99)).SIR));
                %meanActive = mean(length(cat(1,tempRaw(((l-1)*100+1):((l-1)*100+99)).ActiveBs)));
                %meanInactive = mean(length(cat(1,CsoTest.TestBs(k).RawData(((l-1)*100+1):((l-1)*100+99)).InactiveBs)));
                %tempSO = mean((TotalBs(l)-meanActive)/TotalBs(l));
                meanSIR(l,:) = [tempCDin tempSIR];
            end
%             plotdata = CsoTest.TestBs(k).TestPlot(j).SirData;
%             plotdata(plotdata(1:10,3) < 0,3) = 0;
            %meanSIR(meanSIR(:,1) < 0,1) = 0;
            plot(meanSIR(:,1),meanSIR(:,2) - PPPSIR,strcat('-',colours(k),markers(k)),'markersize',Marker_Size,'LineWidth',Line_Width);
            hold on;
            %plot(x,polyval(p,x),strcat('-',colours(k)));
        end
        hold off;

        %axis([-50 50 -50 50]);
        xlabel('$C_{\mathrm D}^{(\mathrm{in})}$','Interpreter','latex','FontSize',LabelFontSize);
        ylabel('$S_{g}(0.95)$ (dB)','Interpreter','latex','FontSize',LabelFontSize);
        set(gca,'fontsize',LabelFontSize);
        if j == 1
            legend(LegendInfo,'Interpreter','latex','Location','Best');
        end
        grid on;
        
        axis([0 1 0 4.5]);
        
        FignameLocation=[FigLocation,FigName]; 
        %saveas(f,FignameLocation,'epsc');
    end
    
end


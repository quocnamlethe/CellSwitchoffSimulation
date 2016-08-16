%function [] = PlotSOvsCovOut()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%     load('data/Test_CDin_vs_CDoutData_1.mat', 'CsoTest');
%     
%     LegendInfo = {'Random','Semi-greedy deletion','Greedy deletion','Greedy construction','$$ \rm Output \it C_{\rm D} = \rm Input \it C_{\rm D}$$','Genie-aided'};
%     LegendPosition = [0.6 0.2 0.3 0.3];
%     
%     FigLocation = 'data\';
%     
%     testNum = 4;
%     markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
%     colours = ['k' 'm' 'g' 'r' 'c' 'b' 'y'];
%     Marker_Size = 8;
%     Line_Width = 2;
%     LabelFontSize = 18;
%     x = linspace(0,1,11);
%     
%     for m = 1:4
%         f = figure;
%         set(f,'name',['CoV In vs CoV Out for ',CsoTest.TestBs(1).TestPlot(m).Tag,' Switch Off'],'numbertitle','off');
%         
%         tempTag = CsoTest.TestBs(1).TestPlot(m).Tag;
%         FigName=[sprintf('Fig_%d_SO_%s_CD',m,tempTag),'.eps']; 
% 
%         h = [];
%         hold on;
% 
%         for k = 1:testNum
%             plotdata = CsoTest.TestBs(k).TestPlot(m).CdData;
%             p = polyfit(plotdata(:,1),plotdata(:,2),1);
%             plot(plotdata(:,1),plotdata(:,2),strcat('-',colours(k),markers(k)),'markersize',Marker_Size,'LineWidth',Line_Width);
%         end
%         
%         plot(x,x,strcat('-',colours(testNum+1),markers(testNum+1)),'markersize',Marker_Size,'LineWidth',Line_Width);
%         plot(x,0,strcat('-',colours(testNum+2),markers(testNum+2)),'markersize',Marker_Size,'LineWidth',Line_Width);
%         
%         axis([0 1.05 -0.1 1.05]);
% %         xlabel('Input CD');
% %         ylabel('Output CD');
%         xlabel('$$ \rm Input \it C_{\rm D}$$','Interpreter','latex','FontSize',LabelFontSize);
%         ylabel('$$ \rm Out \it C_{\rm D}$$','Interpreter','latex','FontSize',LabelFontSize);
% 
%         %title(['CoV In vs CoV Out for ',CsoTest.TestBs(1).TestPlot(m).Tag,' Switch Off']);
%         hold off;
% 
%         legend(h,LegendInfo,'Interpreter','latex','Position',LegendPosition);
%         
%         grid on;
%         
%         set(gca,'fontsize',LabelFontSize);
%         
%         FignameLocation=[FigLocation,FigName]; 
%         saveas(f,FignameLocation,'epsc');
%     end

    LegendInfo = {'Random','Genie-aided','Greedy deletion','Greedy construction','Semi-greedy deletion','Neighborhood','Triangular Lattice Approximation'};
    LegendPosition = [0.50 0.15 0.45 0.35];
    
    FigLocation = 'data/SIRDiffvsCDin/';
    
    algNum = 7;
    testPert = [0 0.058940989 0.129074508 0.202142206 0.278385168 0.359938995 0.450877783 0.562342129 0.728588577 1.063361881 2];
    percentSO = 0:0.05:0.9;
    markers = ['*' 'o' '+' 'x' 's' 'd' '^'];
    colours = ['k' 'm' 'g' 'r' 'b' 'c' 'y'];
    Marker_Size = 8;
    Line_Width = 2;
    LabelFontSize = 18;
    percentile = 50;
    x = linspace(0,1);
    
    for j = 1:length(percentSO)
        f = figure;
        
        tempTag = num2str(percentSO(j)*100);
        tempName = sprintf('a4_s0_SO_%s_CDout',tempTag);
        FigName= tempName;
        
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
                tempCDout = mean(cat(1,pertRaw(:).CDout));
                tempCDin = mean(cat(1,pertRaw(:).CDin));
                meanSIR(l,:) = [tempCDin tempCDout];
            end
            plot(meanSIR(:,1),meanSIR(:,2),strcat('-',colours(k),markers(k)),'markersize',Marker_Size,'LineWidth',Line_Width);
            hold on;
        end
        hold off;

        %axis([-50 50 -50 50]);
        xlabel('$C_{\mathrm D}^{(\mathrm{in})}$','Interpreter','latex','FontSize',LabelFontSize);
        ylabel('$C_{\mathrm D}^{(\mathrm{out})}$','Interpreter','latex','FontSize',LabelFontSize);
        set(gca,'fontsize',LabelFontSize);
        if j == 1
            legend(LegendInfo,'Interpreter','latex','Location','Best');
        end
        grid on;
        
        axis([0 1 0 1]);
        
        FignameLocation=[FigLocation,FigName,'.eps']; 
        saveas(f,FignameLocation,'epsc');
        FignameLocation=[FigLocation,FigName,'.png'];
        saveas(f,FignameLocation,'png');
    end
    
%end



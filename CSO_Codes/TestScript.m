
ModelParameters = ModelParaSet();
ModelParameters.lambda = 100e-6;          
% ModelParameters.alpha_norm = 0.5;

CsoTest = CsoTestSet();
% CsoTest.ModelParameters = ModelParameters;

cnplotm1 = [];
cnplotm2 = [];
cnplotm3 = [];
cnplotm4 = [];

cvplotm1 = [];
cvplotm2 = [];
cvplotm3 = [];
cvplotm4 = [];

cdplotm1 = [];
cdplotm2 = [];
cdplotm3 = [];
cdplotm4 = [];

warning off;
for l = 0:10
    ModelParameters.alpha_norm = 0.1 * l;
    CsoTest.ModelParameters = ModelParameters;
    
    for j = 1:10 
        [Bs_Locations]= UT_LatticeBased('hexUni' , ModelParameters);

        CsoTest.ModelParameters = ModelParameters;
        CsoTest.InitialBs.ActiveBs = Bs_Locations;

        [CN, CV, CD] = CoV_Metrics(CsoTest.InitialBs.ActiveBs, ModelParameters);
        CsoTest.InitialBs.CN = CN;
        CsoTest.InitialBs.CV = CV;
        CsoTest.InitialBs.CD = CD;

        for k = 1:4
            CsoTest.TestBs(k).ActiveBs = Bs_Locations;
            CsoTest.TestBs(k).InactiveBs = [];
            CsoTest.TestBs(k).CN = CN;
            CsoTest.TestBs(k).CV = CV;
            CsoTest.TestBs(k).CD = CD;
        end

        CsoTest.TestBs(1) = MaxRegSo(CsoTest.TestBs(1),2/3,ModelParameters);
        CsoTest.TestBs(2) = MaxRegSo(CsoTest.TestBs(2),3/4,ModelParameters);
        CsoTest.TestBs(3) = MaxRegSo(CsoTest.TestBs(3),7/9,ModelParameters);
        CsoTest.TestBs(4) = MaxRegSo(CsoTest.TestBs(4),8/9,ModelParameters);

        for k = 1:4
            [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
            CsoTest.TestBs(k).CN = CN;
            CsoTest.TestBs(k).CV = CV;
            CsoTest.TestBs(k).CD = CD;
        end
        
        cnplotm1 = [cnplotm1 ; CsoTest.InitialBs.CN, CsoTest.TestBs(1).CN];
        cnplotm2 = [cnplotm2 ; CsoTest.InitialBs.CN, CsoTest.TestBs(2).CN];
        cnplotm3 = [cnplotm3 ; CsoTest.InitialBs.CN, CsoTest.TestBs(3).CN];
        cnplotm4 = [cnplotm4 ; CsoTest.InitialBs.CN, CsoTest.TestBs(4).CN];
        
        cvplotm1 = [cvplotm1 ; CsoTest.InitialBs.CV, CsoTest.TestBs(1).CV];
        cvplotm2 = [cvplotm2 ; CsoTest.InitialBs.CV, CsoTest.TestBs(2).CV];
        cvplotm3 = [cvplotm3 ; CsoTest.InitialBs.CV, CsoTest.TestBs(3).CV];
        cvplotm4 = [cvplotm4 ; CsoTest.InitialBs.CV, CsoTest.TestBs(4).CV];
        
        cdplotm1 = [cdplotm1 ; CsoTest.InitialBs.CD, CsoTest.TestBs(1).CD];
        cdplotm2 = [cdplotm2 ; CsoTest.InitialBs.CD, CsoTest.TestBs(2).CD];
        cdplotm3 = [cdplotm3 ; CsoTest.InitialBs.CD, CsoTest.TestBs(3).CD];
        cdplotm4 = [cdplotm4 ; CsoTest.InitialBs.CD, CsoTest.TestBs(4).CD];

%         save(strcat('data/testing',num2str(j),'.mat'), 'CsoTest');
    end

end

warning on;

figure(1);
x = linspace(0,1);

% CN
subplot(1,3,1);
p1 = polyfit(cnplotm1(:,1),cnplotm1(:,2),1);
plot(cnplotm1(:,1),cnplotm1(:,2),'.r');
hold on;

p2 = polyfit(cnplotm2(:,1),cnplotm2(:,2),1);
plot(cnplotm2(:,1),cnplotm2(:,2),'.b');
hold on;

p3 = polyfit(cnplotm3(:,1),cnplotm3(:,2),1);
plot(cnplotm3(:,1),cnplotm3(:,2),'.g');
hold on;

p4 = polyfit(cnplotm4(:,1),cnplotm4(:,2),1);
plot(cnplotm4(:,1),cnplotm4(:,2),'.m');
hold on;

plot(x,polyval(p1,x),'-r',x,polyval(p2,x),'-b',x,polyval(p3,x),'-g',x,polyval(p4,x),'-m');
hold on;

axis([0 1 0 1]);
title('CN');
legend('Random Minimum Distance SO','Three Nearest Neighbour SO','Maximum Being Nearest Neigbour SO','Minimum Distance and Second Nearest Neighbour SO');
hold off;

% CV
subplot(1,3,2);
p1 = polyfit(cvplotm1(:,1),cvplotm1(:,2),1);
plot(cvplotm1(:,1),cvplotm1(:,2),'.r');
hold on;

p2 = polyfit(cvplotm2(:,1),cvplotm2(:,2),1);
plot(cvplotm2(:,1),cvplotm2(:,2),'.b');
hold on;

p3 = polyfit(cvplotm3(:,1),cvplotm3(:,2),1);
plot(cvplotm3(:,1),cvplotm3(:,2),'.g');
hold on;

p4 = polyfit(cvplotm4(:,1),cvplotm4(:,2),1);
plot(cvplotm4(:,1),cvplotm4(:,2),'.m');
hold on;

plot(x,polyval(p1,x),'-r',x,polyval(p2,x),'-b',x,polyval(p3,x),'-g',x,polyval(p4,x),'-m');
hold on;

axis([0 1 0 1]);
title('CV');
legend('Random Minimum Distance SO','Three Nearest Neighbour SO','Maximum Being Nearest Neigbour SO','Minimum Distance and Second Nearest Neighbour SO');
hold off;

% CD
subplot(1,3,3);
p1 = polyfit(cdplotm1(:,1),cdplotm1(:,2),1);
plot(cdplotm1(:,1),cdplotm1(:,2),'.r');
hold on;

p2 = polyfit(cdplotm2(:,1),cdplotm2(:,2),1);
plot(cdplotm2(:,1),cdplotm2(:,2),'.b');
hold on;

p3 = polyfit(cdplotm3(:,1),cdplotm3(:,2),1);
plot(cdplotm3(:,1),cdplotm3(:,2),'.g');
hold on;

p4 = polyfit(cdplotm4(:,1),cdplotm4(:,2),1);
plot(cdplotm4(:,1),cdplotm4(:,2),'.m');
hold on;

plot(x,polyval(p1,x),'-r',x,polyval(p2,x),'-b',x,polyval(p3,x),'-g',x,polyval(p4,x),'-m');
hold on;

axis([0 1 0 1]);
title('CD');
legend('Random Minimum Distance SO','Three Nearest Neighbour SO','Maximum Being Nearest Neigbour SO','Minimum Distance and Second Nearest Neighbour SO');
hold off;

function varargout = guiTest1(varargin)
% GUITEST1 MATLAB code for guiTest1.fig
%      GUITEST1, by itself, creates a new GUITEST1 or raises the existing
%      singleton*.
%
%      H = GUITEST1 returns the handle to a new GUITEST1 or the handle to
%      the existing singleton*.
%
%      GUITEST1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITEST1.M with the given input arguments.
%
%      GUITEST1('Property','Value',...) creates a new GUITEST1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiTest1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiTest1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiTest1

% Last Modified by GUIDE v2.5 09-May-2016 10:36:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiTest1_OpeningFcn, ...
                   'gui_OutputFcn',  @guiTest1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before guiTest1 is made visible.
function guiTest1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiTest1 (see VARARGIN)

% Choose default command line output for guiTest1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global guiHandle;

guiHandle = handles;

CsoTest = CsoTestSet(4);

if exist('data', 'dir') == 0
    mkdir('data');
end

save('data/CsoTest.mat', 'CsoTest');

% UIWAIT makes guiTest1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiTest1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Updates the GUI
function updateGui()
% This function has no output args
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Bs_Locations   the locations of the base stations
% ModelParamters the model parameters

global guiHandle;
% 
% load('data/model_parameters.mat', 'ModelParameters');
% load('data/test1_base_stations.mat', 'test1_Bs_Locations');
% load('data/test2_base_stations.mat', 'test2_Bs_Locations');
% load('data/test3_base_stations.mat', 'test3_Bs_Locations');
% load('data/test4_base_stations.mat', 'test4_Bs_Locations');

load('data/CsoTest.mat', 'CsoTest');

ModelParameters = CsoTest.ModelParameters;

set(guiHandle.perturbation_slider, 'Value', ModelParameters.alpha_norm);
set(guiHandle.perturbation_value, 'String', ModelParameters.alpha_norm);

for k = 1:4
    if isempty(CsoTest.TestBs(k).ActiveBs)
        return;
    end
end

Tag = 'initial';
CN = CsoTest.InitialBs.CN;
CV = CsoTest.InitialBs.CV;
CD = CsoTest.InitialBs.CD;

cn_value_tag = strcat(Tag,'_cn_value');
cv_value_tag = strcat(Tag,'_cv_value');
cd_value_tag = strcat(Tag,'_cd_value');

set(guiHandle.(genvarname(cn_value_tag)),'String', sprintf('%.5f',CN));
set(guiHandle.(genvarname(cv_value_tag)),'String', sprintf('%.5f',CV));
set(guiHandle.(genvarname(cd_value_tag)),'String', sprintf('%.5f',CD));

for k = 1:2 % TODO: Change to 4
    Tag = CsoTest.TestBs(k).Tag;
    CN = CsoTest.TestBs(k).CN;
    CV = CsoTest.TestBs(k).CV;
    CD = CsoTest.TestBs(k).CD;

    cn_value_tag = strcat(Tag,'_cn_value');
    cv_value_tag = strcat(Tag,'_cv_value');
    cd_value_tag = strcat(Tag,'_cd_value');

    set(guiHandle.(genvarname(cn_value_tag)),'String', sprintf('%.5f',CN));
    set(guiHandle.(genvarname(cv_value_tag)),'String', sprintf('%.5f',CV));
    set(guiHandle.(genvarname(cd_value_tag)),'String', sprintf('%.5f',CD));

    xp = CsoTest.TestBs(k).ActiveBs(:,1);
    yp = CsoTest.TestBs(k).ActiveBs(:,2);
    
    if isempty(CsoTest.TestBs(k).InactiveBs)
        inactivex = [];
        inactivey = [];
    else
        inactivex = CsoTest.TestBs(k).InactiveBs(:,1);
        inactivey = CsoTest.TestBs(k).InactiveBs(:,2);
    end
    
    axes(guiHandle.(genvarname(strcat(Tag, '_axes'))));
    axesHandle = guiHandle.(genvarname(strcat(Tag, '_axes')));

%     hplot = plot(guiHandle.(genvarname(strcat(Tag, '_axes'))),xp,yp,'+b','linewidth',2);
%     set(hplot,'HitTest','off');
%     set(gcf,'WindowButtonDownFcn',@test1_axes_ButtonDownFcn);
%     set(hplot,'ButtonDownFcn',@test1_axes_ButtonDownFcn);
%     hold(axesHandle,'on');

    delaunay(xp,yp);
    DT=delaunayTriangulation(xp,yp);

    axes(axesHandle);
    triplot(DT,':g','linewidth',2)
    hold(axesHandle,'on'); 
    for j = 1:size(xp,1)
        DrawCellRevision2(CsoTest.TestBs(k).ActiveBs(j,:),8,'k',[0.7 0.7 0.7],'on');
    end
    box on
%     [vxp,vyp] = voronoi(xp,yp);
%     plot(axesHandle,xp,yp,'r+',vxp,vyp,'r-','linewidth',2)
    hold(axesHandle,'on');
    axis(axesHandle,[-550 550 -550 550]);
    % set(gca,'fontsize',14)
    ax=gca; 
    ax.XTick=0;
    ax.YTick=0;
    hold on
    
%     grey = [0.4,0.4,0.4,0.4];
%     hplot = plot(guiHandle.(genvarname(strcat(Tag, '_axes'))),inactivex,inactivey,'+','linewidth',2,'Color',grey);
    for j = 1:size(CsoTest.TestBs(k).InactiveBs,1)
        DrawCellRevision2(CsoTest.TestBs(k).InactiveBs(j,:),8,'k',[0.7 0.7 0.7],'off');
    end
    hold off
end

% --- Executes on mouse press over axes background.
function test1_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to test1_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    load('data/CsoTest.mat', 'CsoTest');
    
    ModelParameters = CsoTest.ModelParameters;
    
    ax = gca;
    panel = get(ax, 'Parent');
    
    panelTag = get(panel, 'Tag');
    
    Test = 0;
    
    for k = 1:4
        Tag = CsoTest.TestBs(k).Tag;
        if isequal(panelTag, strcat(Tag,'_panel'))
            Bs_Locations = [CsoTest.TestBs(k).ActiveBs ; CsoTest.TestBs(k).InactiveBs];
            activeNum = length(CsoTest.TestBs(k).ActiveBs);
            Test = k;
        end
    end
    
    if Test == 0 || isempty(Bs_Locations)
        return;
    end
    
    point = get(hObject, 'currentpoint');
    panelpos = get(panel, 'Position');
    
    posleft = ax.Position(1) + panelpos(1);
    posright = ax.Position(1) + ax.Position(3) + panelpos(1);
    posbot = ax.Position(2) + panelpos(2);
    postop = ax.Position(2) + ax.Position(4) + panelpos(2);
    
    if point(1) >= posleft && point(1) <= posright && point(2) >= posbot && point(2) <= postop
        win = ModelParameters.win;
        rangex = win(2) - win(1);
        rangey = win(4) - win(3);
        widthx = ax.Position(3);
        widthy = ax.Position(4);
        minx = win(1);
        miny = win(3);
        posx = (point(1) - ax.Position(1) - panelpos(1))*rangex/widthx + minx;
        posy = (point(2) - ax.Position(2) - panelpos(2))*rangey/widthy + miny;

        mindist = sqrt((Bs_Locations(1,1) - posx)^2 + (Bs_Locations(1,2) - posy)^2);
        mink = 1;
        for k = 1:length(Bs_Locations)
            if mindist > sqrt((Bs_Locations(k,1) - posx)^2 + (Bs_Locations(k,2) - posy)^2)
                mink = k;
                mindist = sqrt((Bs_Locations(k,1) - posx)^2 + (Bs_Locations(k,2) - posy)^2);
            end
        end
        if (mink <= activeNum)
            CsoTest.TestBs(Test).InactiveBs = [CsoTest.TestBs(Test).InactiveBs; Bs_Locations(mink,:)];
            CsoTest.TestBs(Test).ActiveBs(mink,:) = [];
        else
            CsoTest.TestBs(Test).ActiveBs = [CsoTest.TestBs(Test).ActiveBs; Bs_Locations(mink,:)];
            CsoTest.TestBs(Test).InactiveBs((mink - activeNum),:) = [];
        end
        
        [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(Test).ActiveBs, ModelParameters);
        CsoTest.TestBs(Test).CN = CN;
        CsoTest.TestBs(Test).CV = CV;
        CsoTest.TestBs(Test).CD = CD;

        save('data/CsoTest.mat', 'CsoTest');
        updateGui();
    end


% --- Executes on slider movement.
function perturbation_slider_Callback(hObject, eventdata, handles)
% hObject    handle to perturbation_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
perturbation = get(handles.perturbation_slider, 'Value');
set(handles.perturbation_value, 'String', perturbation);


% --- Executes during object creation, after setting all properties.
function perturbation_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to perturbation_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in generatebs.
function generatebs_Callback(hObject, eventdata, handles)
% hObject    handle to generatebs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    load('data/CsoTest.mat', 'CsoTest');

    perturbation = get(handles.perturbation_slider, 'Value');
    
    ModelParameters = ModelParaSet();
    ModelParameters.lambda = 100e-6;          
    ModelParameters.alpha_norm = perturbation;

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
        [CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(k).ActiveBs, ModelParameters);
        CsoTest.TestBs(k).CN = CN;
        CsoTest.TestBs(k).CV = CV;
        CsoTest.TestBs(k).CD = CD;
    end
    
    save('data/CsoTest.mat', 'CsoTest');
    
%     test1_Bs_Locations = Bs_Locations;
%     test2_Bs_Locations = Bs_Locations;
%     test3_Bs_Locations = Bs_Locations;
%     test4_Bs_Locations = Bs_Locations;

%     save('data/model_parameters.mat', 'ModelParameters');
%     save('data/initial_base_stations.mat', 'Bs_Locations');
%     save('data/test1_base_stations.mat', 'test1_Bs_Locations');
%     save('data/test2_base_stations.mat', 'test2_Bs_Locations');
%     save('data/test3_base_stations.mat', 'test3_Bs_Locations');
%     save('data/test4_base_stations.mat', 'test4_Bs_Locations');

    updateGui();

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over generatebs.
function generatebs_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to generatebs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global guiHandle;
    
    perturbation = get(guiHandle.perturbation_slider, 'Value');
    
    ModelParameters=ModelParaSet();
    ModelParameters.lambda=100e-6;          
    ModelParameters.alpha_norm=perturbation;

    [Bs_Locations]= UT_LatticeBased('hexUni' , ModelParameters);

    save('data/model_parameters.mat', 'ModelParameters');
    save('data/initial_base_stations.mat', 'Bs_Locations');

    updateGui();
    
    


% --- Executes on button press in saveplots.
function saveplots_Callback(hObject, eventdata, handles)
% hObject    handle to saveplots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('data/CsoTest.mat', 'CsoTest');
[FileName,PathName] = uiputfile('.mat');

save(strcat(PathName,FileName), 'CsoTest');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over saveplots.
function saveplots_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to saveplots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in loadplot.
function loadplot_Callback(hObject, eventdata, handles)
% hObject    handle to loadplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] = uigetfile('.mat');

if FileName ~= 0
    load(strcat(PathName,FileName), 'CsoTest');
    save('data/CsoTest.mat', 'CsoTest');
    updateGui();
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over loadplot.
function loadplot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to loadplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in test1_reset.
function test1_reset_Callback(hObject, eventdata, handles)
% hObject    handle to test1_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('data/CsoTest.mat', 'CsoTest');
CsoTest.TestBs(1).ActiveBs = CsoTest.InitialBs.ActiveBs;
CsoTest.TestBs(1).InactiveBs = [];
[CN, CV, CD] = CoV_Metrics(CsoTest.TestBs(1).ActiveBs, CsoTest.ModelParameters);
CsoTest.TestBs(1).CN = CN;
CsoTest.TestBs(1).CV = CV;
CsoTest.TestBs(1).CD = CD;
save('data/CsoTest.mat', 'CsoTest');
updateGui();

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over test1_reset.
function test1_reset_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to test1_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

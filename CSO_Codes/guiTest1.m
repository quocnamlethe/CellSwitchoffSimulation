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

% Last Modified by GUIDE v2.5 05-May-2016 11:55:19

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

warning off;
mkdir('data');
warning on;

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

load('data/model_parameters.mat', 'ModelParameters');
load('data/test1_base_stations.mat', 'test1_Bs_Locations');
load('data/test2_base_stations.mat', 'test2_Bs_Locations');
load('data/test3_base_stations.mat', 'test3_Bs_Locations');
load('data/test4_base_stations.mat', 'test4_Bs_Locations');

if isempty(test1_Bs_Locations)
    return;
end

[CN, CV, CD] = CoV_Metrics(test1_Bs_Locations, ModelParameters);

set(guiHandle.test1_cn_value,'String', CN);
set(guiHandle.test1_cv_value,'String', CV);
set(guiHandle.test1_cd_value,'String', CD);

xp = test1_Bs_Locations(:,1);
yp = test1_Bs_Locations(:,2);

axes(guiHandle.test1_axes);

hplot = plot(guiHandle.test1_axes,xp,yp,'+b','linewidth',2);
set(hplot,'HitTest','off');
set(gcf,'WindowButtonDownFcn',@test1_axes_ButtonDownFcn);
set(hplot,'ButtonDownFcn',@test1_axes_ButtonDownFcn);
hold on

delaunay(xp,yp);
DT=delaunayTriangulation(xp,yp);

triplot(DT,':g','linewidth',2)
hold on 
box on
[vxp,vyp] = voronoi(xp,yp);
plot(xp,yp,'r+',vxp,vyp,'r-','linewidth',2)
axis([-500 500 -500 500]);
% set(gca,'fontsize',14)
ax=gca; 
ax.XTick=0;
ax.YTick=0;
hold off

% --- Executes on mouse press over axes background.
function test1_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to test1_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    ax = gca;
    panel = get(ax, 'Parent');
    
    panelTag = get(panel, 'Tag');
    
    load('data/model_parameters.mat', 'ModelParameters');
    
    if isequal(panelTag, 'test1_panel')
        load('data/test1_base_stations.mat', 'test1_Bs_Locations');
    end
    
    point = get(hObject, 'currentpoint');
    panelpos = get(panel, 'Position');
    win = ModelParameters.win;
    rangex = win(2) - win(1);
    rangey = win(4) - win(3);
    widthx = ax.Position(3);
    widthy = ax.Position(4);
    minx = win(1);
    miny = win(3);
    posx = (point(1) - ax.Position(1) - panelpos(1))*rangex/widthx + minx;
    posy = (point(2) - ax.Position(2) - panelpos(2))*rangey/widthy + miny;
    
    mindist = sqrt((test1_Bs_Locations(1,1) - posx)^2 + (test1_Bs_Locations(1,2) - posy)^2);
    mink = 1;
    
    posleft = ax.Position(1) + panelpos(1);
    posright = ax.Position(1) + ax.Position(3) + panelpos(1);
    posbot = ax.Position(2) + panelpos(2);
    postop = ax.Position(2) + ax.Position(4) + panelpos(2);
    
    if point(1) >= posleft && point(1) <= posright && point(2) >= posbot && point(2) <= postop
        fprintf('Point the was pressed: %f, %f\n', posx, posy);
        for k = 1:length(test1_Bs_Locations)
            if mindist > sqrt((test1_Bs_Locations(k,1) - posx)^2 + (test1_Bs_Locations(k,2) - posy)^2)
                mink = k;
                mindist = sqrt((test1_Bs_Locations(k,1) - posx)^2 + (test1_Bs_Locations(k,2) - posy)^2);
            end
        end
        test1_Bs_Locations(mink,:) = [];

        save('data/test1_base_stations.mat', 'test1_Bs_Locations');
        updateGui();
    end


% --- Executes on slider movement.
function perturbation_slider_Callback(hObject, eventdata, handles)
% hObject    handle to perturbation_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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
    global guiHandle;
    
    perturbation = get(guiHandle.perturbation_slider, 'Value');
    
    ModelParameters=ModelParaSet();
    ModelParameters.lambda=100e-6;          
    ModelParameters.alpha_norm=perturbation;

    [Bs_Locations]= UT_LatticeBased('hexUni' , ModelParameters);
    test1_Bs_Locations = Bs_Locations;
    test2_Bs_Locations = Bs_Locations;
    test3_Bs_Locations = Bs_Locations;
    test4_Bs_Locations = Bs_Locations;

    save('data/model_parameters.mat', 'ModelParameters');
    save('data/initial_base_stations.mat', 'Bs_Locations');
    save('data/test1_base_stations.mat', 'test1_Bs_Locations');
    save('data/test2_base_stations.mat', 'test2_Bs_Locations');
    save('data/test3_base_stations.mat', 'test3_Bs_Locations');
    save('data/test4_base_stations.mat', 'test4_Bs_Locations');

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
    
    

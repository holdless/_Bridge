function varargout = eitisma(varargin)
% EITISMA MATLAB code for eitisma.fig
%      EITISMA, by itself, creates a new EITISMA or raises the existing
%      singleton*.
%
%      H = EITISMA returns the handle to a new EITISMA or the handle to
%      the existing singleton*.
%
%      EITISMA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EITISMA.M with the given input arguments.
%
%      EITISMA('Property','Value',...) creates a new EITISMA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eitisma_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eitisma_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eitisma

% Last Modified by GUIDE v2.5 24-Sep-2020 13:37:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eitisma_OpeningFcn, ...
                   'gui_OutputFcn',  @eitisma_OutputFcn, ...
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


% --- Executes just before eitisma is made visible.
function eitisma_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

handles = initUI(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eitisma wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = eitisma_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in radiobutton_topLayer.
function radiobutton_topLayer_Callback(hObject, eventdata, handles)

% --- Executes on button press in radiobutton_bottomLayer.
function radiobutton_bottomLayer_Callback(hObject, eventdata, handles)



% --- Executes on button press in pushbutton_addMeas.
function pushbutton_addMeas_Callback(hObject, eventdata, handles)
set(hObject, 'enable', 'off');
image = handles.data.rotatedImage;
boxAndPairAxes = handles.axes_rotatedImage;
if get(handles.radiobutton_topLayer,'value')
  handles.data.layerId = 1; % top layer
else
  handles.data.layerId = 2; % bottom layer
end
BOX_COLOR = {'green', 'red'};
EDGE_COLOR = {'red','green'};
CD_COLOR = {'red','green'};
POS_COLOR = {'yellow','cyan'};
layerId = handles.data.layerId;

textAxes = handles.data.axes.textAxes;
drawAxes = handles.data.axes.drawAxes;

handles.data.boxPairs{layerId} = handles.data.boxPairs{layerId} + 1;
boxPair = handles.data.boxPairs{layerId};

if get(handles.radiobutton_forBSE, 'value')
  algo = 'bse';
end
if get(handles.radiobutton_forSE, 'value')
  algo = 'se';
end
if get(handles.radiobutton_lineAlgo, 'value')
  algo = 'line';
end
if get(handles.radiobutton_spaceAlgo, 'value')
  algo = 'space';
end


detectMethod.isDarkHole = get(handles.checkbox_darkHole, 'value'); 
detectMethod.is2D = get(handles.checkbox_2D, 'value');
detectMethod.isMaxFiltered = get(handles.checkbox_filterMax, 'value');
detectMethod.smoothing = str2double(get(handles.edit_smoothing, 'string'));
detectMethod.mSize = str2double(get(handles.edit_mSize, 'string'));
measureArea.sumLines = str2double(get(handles.edit_sumLines, 'string'));
measureArea.measPoints = str2double(get(handles.edit_measPoints, 'string'));

detectMethod.threshold.max = str2double(get(handles.edit_smaxPercent, 'string'))/100;
detectMethod.threshold.min = str2double(get(handles.edit_sminPercent, 'string'))/100;
detectMethod.threshold.target = str2double(get(handles.edit_tPercent, 'string'))/100;

% 2020.9.21 hiroshi
detectMethod.method = get(handles.popupmenu_method, 'value');
detectMethod.differential = str2double(get(handles.edit_differential, 'string'));
detectMethod.BLStartPt = str2double(get(handles.edit_BLStartPt, 'string'));
detectMethod.BLArea = str2double(get(handles.edit_BLArea, 'string'));

isLeft = [1 0];

fovSize = 1000*str2double(get(handles.edit_fov, 'string'));
imageSize = size(image);
scale.x = fovSize/imageSize(2);
scale.y = fovSize/imageSize(1);

handles.data.fovSize = fovSize;



for box = 1:2
  measureArea.isLeft = isLeft(box);
  
  measureBox(box) = CMeasureBox();
  measureBox(box).getAxes(boxAndPairAxes);
  measureBox(box).setAxesProperties(handles.data.imageAxis);
  measureBox(box).setScale(scale.x);
  measureBox(box).setBox(BOX_COLOR{layerId});
  measureBox(box).getBoxImage(image);
  measureBox(box).drawBox();
  measureBox(box).setEdgeAlgo(algo, measureArea, detectMethod);    
  measureBox(box).findEdge(); %must
  measureBox(box).showCursor();
  
%   measureBox(box).computeLER(8);
  
  if detectMethod.is2D == 1
    break;
  end
  
  measureBox(box).setEdgeProperties(EDGE_COLOR{layerId});
  measureBox(box).showEdge(); %must
  measureBox(box).measureWhiteBand();
end

handles.data.measureBox{layerId}{boxPair} = measureBox;

measurePair = CMeasurePair();
measurePair.getAxes(boxAndPairAxes); %must
measurePair.setAxesProperties(handles.data.imageAxis);
if detectMethod.is2D == 0
  measurePair.updateMeasurement(measureBox(1).mEdgePos, measureBox(2).mEdgePos);%must
else
  measurePair.updateMeasurement_2D(measureBox(1).mHole);
end
measurePair.setColor(CD_COLOR{layerId}, POS_COLOR{layerId});
measurePair.setScale(scale.x);
measurePair.setInfo();%must
measurePair.showCenterCursor();%must

handles.data.measurePair{layerId}{boxPair} = measurePair;


measureFov = CMeasureFov();
measureFov.updateMeasurement(handles.data.measurePair);%must
measureFov.setColor(CD_COLOR, POS_COLOR);
measureFov.setScale(scale.x);
measureFov.setAxesProperties(handles.data.imageAxis);
measureFov.setInfo(textAxes); %must
measureFov.showCenterCursor(drawAxes); %must

handles.data.measureFov = measureFov;
    
set(gcf, 'WindowButtonDownFcn', {@MOUSE_CALLBACK,...
                                handles.data.measureBox,...
                                handles.data.boxPairs});

set(hObject, 'enable', 'on');
% Update handles structure
guidata(hObject, handles);    


function handles = executeRecipe(handles)
set(handles.pushbutton_addMeas, 'enable', 'off');
image = handles.data.rotatedImage;
boxAndPairAxes = handles.axes_rotatedImage;
boxPairs = handles.data.boxPairs;
measureBox = handles.data.measureBox;
measurePair = handles.data.measurePair;
measureFov = handles.data.measureFov;
textAxes = handles.data.axes.textAxes;
drawAxes = handles.data.axes.drawAxes;

for layer = 1:2
  for pair = 1:boxPairs{layer}
    for box = 1:size(measureBox{layer}{pair}, 2)
      measureBox{layer}{pair}(box).getAxes(boxAndPairAxes);
      measureBox{layer}{pair}(box).setAxesProperties(handles.data.imageAxis);
      measureBox{layer}{pair}(box).getBoxImage(image);
      measureBox{layer}{pair}(box).drawBox();
      measureBox{layer}{pair}(box).findEdge();
      measureBox{layer}{pair}(box).showCursor();
      
      if measureBox{layer}{pair}(box).mDetectMethod.is2D == 0
%         measureBox{layer}{pair}(box).showEdge();
        measureBox{layer}{pair}(box).measureWhiteBand();
      end
    end
    
    measurePair{layer}{pair}.getAxes(boxAndPairAxes); %must
    measurePair{layer}{pair}.setAxesProperties(handles.data.imageAxis);
    if measureBox{layer}{pair}(box).mDetectMethod.is2D == 0
      measurePair{layer}{pair}.updateMeasurement(measureBox{layer}{pair}(1).mEdgePos, measureBox{layer}{pair}(2).mEdgePos);%must
    else
      measurePair{layer}{pair}.updateMeasurement_2D(measureBox{layer}{pair}(box).mHole);%must
    end
    measurePair{layer}{pair}.setInfo();%must
%     measurePair{layer}{pair}.showCenterCursor();%must
  end
end

measureFov.updateMeasurement(measurePair);%must
measureFov.setAxesProperties(handles.data.imageAxis);
measureFov.setInfo(textAxes); %must
measureFov.showCenterCursor(drawAxes); %must


set(gcf, 'WindowButtonDownFcn', {@MOUSE_CALLBACK,...
                                handles.data.measureBox,...
                                boxPairs});

set(handles.pushbutton_addMeas, 'enable', 'on');

function handles = measurePitch(handles)
image = handles.data.rotatedImage;
boxAndPairAxes = handles.axes_rotatedImage;
if get(handles.radiobutton_topLayer,'value')
  handles.data.layerId = 1; % top layer
else
  handles.data.layerId = 2; % bottom layer
end
BOX_COLOR = {'green', 'red'};
EDGE_COLOR = {'red','green'};
POS_COLOR = {'yellow','cyan'};

if get(handles.radiobutton_forBSE, 'value')
  algo = 'bse';
end
if get(handles.radiobutton_forSE, 'value')
  algo = 'se';
end
if get(handles.radiobutton_lineAlgo, 'value')
  algo = 'line';
end
if get(handles.radiobutton_spaceAlgo, 'value')
  algo = 'space';
end

detectMethod.isDarkHole = get(handles.checkbox_darkHole, 'value'); 
detectMethod.is2D = get(handles.checkbox_2D, 'value');
detectMethod.isMaxFiltered = get(handles.checkbox_filterMax, 'value');
detectMethod.smoothing = str2double(get(handles.edit_smoothing, 'string'));
detectMethod.mSize = str2double(get(handles.edit_mSize, 'string'));
measureArea.sumLines = str2double(get(handles.edit_sumLines, 'string'));
measureArea.measPoints = str2double(get(handles.edit_measPoints, 'string'));

detectMethod.threshold.max = str2double(get(handles.edit_smaxPercent, 'string'))/100;
detectMethod.threshold.min = str2double(get(handles.edit_sminPercent, 'string'))/100;
detectMethod.threshold.target = str2double(get(handles.edit_tPercent, 'string'))/100;

% 2020.9.21 hiroshi
detectMethod.method = get(handles.popupmenu_method, 'value');
detectMethod.differential = str2double(get(handles.edit_differential, 'string'));
detectMethod.BLStartPt = str2double(get(handles.edit_BLStartPt, 'string'));
detectMethod.BLArea = str2double(get(handles.edit_BLArea, 'string'));

isLeft = [1 0 1 0];

nominalPitch = str2double(get(handles.edit_nominalPitch, 'string'));
repeatCnt = str2double(get(handles.edit_pitchRepeatCount, 'string'));
fovSize = 1000*str2double(get(handles.edit_fov, 'string'));
imageSize = size(image);
scale.x = fovSize/imageSize(2);
scale.y = fovSize/imageSize(1);

handles.data.fovSize = fovSize;

for box = 1:4
  measureArea.isLeft = isLeft(box);
  
  measureBox(box) = CMeasureBox();
  measureBox(box).getAxes(boxAndPairAxes); % must
  measureBox(box).setAxesProperties(handles.data.imageAxis);
  measureBox(box).setScale(scale.x);
  measureBox(box).setBox(BOX_COLOR{round(box/2)});
  measureBox(box).getBoxImage(image); % must
%   measureBox(box).drawBox(); %must
  measureBox(box).setEdgeAlgo(algo, measureArea, detectMethod);  
  measureBox(box).findEdge(); %must
  measureBox(box).showCursor();
  measureBox(box).setEdgeProperties(EDGE_COLOR{round(box/2)});
  measureBox(box).showEdge(); %must
  measureBox(box).measureWhiteBand();
end

measurePitch = CMeasurePitch();
measurePitch.getAxes(boxAndPairAxes); %must
measurePitch.setScale(scale.x);
measurePitch.updateMeasurement( measureBox(1).mEdgePos,...
                                measureBox(2).mEdgePos,...
                                measureBox(3).mEdgePos,...
                                measureBox(4).mEdgePos,...
                                repeatCnt);%must
measurePitch.setColor(POS_COLOR{1});
measurePitch.setInfo();%must
measurePitch.showCenter();%must

handles.data.pitch.nominal = nominalPitch;
handles.data.pitch.sem = measurePitch.mPitch;

set(handles.text_semPitch, 'string', num2str(measurePitch.mPitch));

ptichBoxes{1}{1} = measureBox;
pitchPairs{1} = 1;
set(gcf, 'WindowButtonDownFcn', {@MOUSE_CALLBACK,...
                                ptichBoxes,...
                                pitchPairs});


%///////// Mouse Callback Function ////////
function MOUSE_CALLBACK(obj, eventdata, measureBox, boxPairs)
% for measure box
location = get(gca, 'CurrentPoint');
xc = location(1,1);
yc = location(1,2);

for layer = 1:size(measureBox, 2)
  for boxPair = 1:boxPairs{layer}
    for k = 1:size(measureBox{layer}{boxPair}, 2)
      if xc >= measureBox{layer}{boxPair}(k).mRoiBox(1) &&...
          xc <= measureBox{layer}{boxPair}(k).mRoiBox(1)+measureBox{layer}{boxPair}(k).mRoiBox(3) &&...
          yc >= measureBox{layer}{boxPair}(k).mRoiBox(2) &&...
          yc <= measureBox{layer}{boxPair}(k).mRoiBox(2)+measureBox{layer}{boxPair}(k).mRoiBox(4)

        figure
        roiAxes = gca;
        measureBox{layer}{boxPair}(k).showRoiImage(roiAxes)
        measureBox{layer}{boxPair}(k).showProfile(roiAxes)
        
      end
    end
  end
end

% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
handles = initData(handles);
resetUI(handles);
resetAxes(handles);
handles = renderImage(handles);
setTitle(handles.data.fileName);
% Update handles structure
guidata(hObject, handles);

function radiobutton_x_Callback(hObject, eventdata, handles)
handles = initData(handles);
resetUI(handles);
handles = renderImage(handles);
guidata(hObject, handles);

function radiobutton_y_Callback(hObject, eventdata, handles)
handles = initData(handles);
resetUI(handles);
handles = renderImage(handles);
guidata(hObject, handles);

%%%%
function handles = initAxes(handles)
keyword = {'axes'};

if isfield(handles.data, keyword{1})
  resetAxes(handles);
  for i = 1:size(keyword,2)
    handles.data = rmfield(handles.data, keyword{i});
  end
end


if handles.radiobutton_y.Value == 1
  handles.data.rotatedImage = imrotate(handles.data.rawImage, 90);
else
  handles.data.rotatedImage = handles.data.rawImage;
end

% init the templated axes by loading image...
axes(handles.axes_rotatedImage)
cla;
imshow(handles.data.rotatedImage), hold on
axis image
handles.data.imageAxis = axis;

for layer = 1:2
  handles.data.axes.textAxes{layer} = copy(handles.axes_rotatedImage);
  handles.data.axes.textAxes{layer}.Parent = handles.axes_rotatedImage.Parent;
  axes(handles.data.axes.textAxes{layer})
  cla;
  
  handles.data.axes.drawAxes{layer} = copy(handles.axes_rotatedImage);
  handles.data.axes.drawAxes{layer}.Parent = handles.axes_rotatedImage.Parent;
  axes(handles.data.axes.drawAxes{layer})
  cla;
end

%%%%
function handles = initUI(handles)
set(handles.axes_rotatedImage, 'visible', 'off');
set(handles.pushbutton_reset, 'enable', 'off');

set(handles.pushbutton_addMeas, 'enable', 'off');
set(handles.radiobutton_x, 'enable', 'off');
set(handles.radiobutton_y, 'enable', 'off');
set(handles.radiobutton_forSE, 'enable', 'on');
set(handles.radiobutton_forBSE, 'enable', 'on');

set(handles.edit_nominalPitch, 'enable', 'on');
set(handles.edit_pitchRepeatCount, 'enable', 'on');
set(handles.pushbutton_calibratePitch, 'enable', 'off');


% temp setting for convenient
handles.data.imageDir = 'D:\_hiroshi\_data balabala';
handles.data.recipeDir = 'D:\_hiroshi\mExtractSemContours';

setTitle('');

%%%%
function handles = initData(handles)
keyword = {'measureBox', 'measurePair', 'measureFov'};

if isfield(handles.data, keyword{1})
  for i = 1:size(keyword,2)
    handles.data = rmfield(handles.data, keyword{i});
  end
end

handles.data.layerId = 1;
handles.data.boxPairs{1} = 0;
handles.data.boxPairs{2} = 0;
handles.data.measureBox{1} = [];
handles.data.measureBox{2} = [];
handles.data.measurePair{1} = [];
handles.data.measurePair{2} = [];
handles.data.measureFov = [];

% set(gcf, 'WindowButtonDownFcn', {@MOUSE_CALLBACK,...
%                                 handles.data.measureBox,...
%                                 handles.data.boxPairs});
      
%%%%
 function resetUI(handles)
setTitle('');
set(handles.pushbutton_reset, 'enable', 'on');
set(handles.pushbutton_addMeas, 'enable', 'on');
set(handles.radiobutton_x, 'enable', 'on');
set(handles.radiobutton_y, 'enable', 'on');
set(handles.radiobutton_forSE, 'enable', 'on');
set(handles.radiobutton_forBSE, 'enable', 'on');

set(handles.edit_nominalPitch, 'enable', 'on');
set(handles.edit_pitchRepeatCount, 'enable', 'on');
set(handles.pushbutton_calibratePitch, 'enable', 'on');


%%%%
function resetAxes(handles)
for layer = 1:2
  axes(handles.data.axes.textAxes{layer});
  cla
  handles.data.axes.textAxes{layer}.Visible = 'off';
  
  axes(handles.data.axes.drawAxes{layer});
  cla
  handles.data.axes.drawAxes{layer}.Visible = 'off';
end
% axes(handles.data.axes.boxAndPairImage);
% cla;
axes(handles.axes_rotatedImage)
cla;

%%%%
function handles = renderImage(handles)
if handles.radiobutton_y.Value == 1
  handles.data.rotatedImage = imrotate(handles.data.rawImage, 90);
else
  handles.data.rotatedImage = handles.data.rawImage;
end

axes(handles.axes_rotatedImage)
% axes(handles.data.axes.boxAndPairImage)
cla;
% imshow(handles.data.rotatedImage, 'InitialMagnification', 'fit'), hold on
imshow(handles.data.rotatedImage), hold on
axis image

%%%%
function setTitle(errorStr)
TimeShirushi = TimeTransform(clock);
TimeShirushi = [TimeShirushi(1:4) '/' TimeShirushi(5:6) '/' TimeShirushi(7:8)];
[tmp, cWeekday] = weekday(now);
TitleName = ['EitisMa -' TimeShirushi ' (' cWeekday ')  ' errorStr];
set(gcf, 'name', TitleName);

% --------------------------------------------------------------------
function loadImage_Callback(hObject, eventdata, handles)
[fileName, pathName, filterIndex] =...
  uigetfile([handles.data.imageDir '\*.*'],'Select the image file');

if filterIndex == 0
  setTitle('>>>ERROR: no file selected.');
  return
end

myPath = fullfile(pathName, fileName);
try
  image = imread(myPath);
catch
  setTitle('>>>ERROR: wrong file type.');
  return
end

try
  image = rgb2gray(image);
catch
  setTitle('>>>WARNING: already grayscale');
end

handles.data.rawImage = image;
handles.data.fileName = fileName;

handles = initData(handles);
resetUI(handles);
handles = initAxes(handles);
handles = renderImage(handles);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function recipe_Callback(hObject, eventdata, handles)

  %%%%
  function uiValues = getUiValue(handles)
    uiValues.isX = get(handles.radiobutton_x, 'Value');
    uiValues.isY = get(handles.radiobutton_y, 'Value');
    uiValues.measPoints = str2double(handles.edit_measPoints.String);
    uiValues.sumLines = str2double(handles.edit_sumLines.String);
    uiValues.method = handles.popupmenu_method.Value;
    uiValues.filterMax = handles.checkbox_filterMax.Value;
    uiValues.is2D = handles.checkbox_2D.Value;
    uiValues.isDarkHole = handles.checkbox_darkHole.Value;
    uiValues.isLine = handles.radiobutton_lineAlgo.Value;
    uiValues.isSpace = handles.radiobutton_spaceAlgo.Value;
    uiValues.isSE = handles.radiobutton_forSE.Value;
    uiValues.isBSE = handles.radiobutton_forBSE.Value;
    uiValues.tPercent = str2double(handles.edit_tPercent.String);
    uiValues.mSize = str2double(handles.edit_mSize.String);
    uiValues.smoothing = str2double(handles.edit_smoothing.String);
    uiValues.differential = str2double(handles.edit_differential.String);
    uiValues.BLStartPt = str2double(handles.edit_BLStartPt);
    uiValues.BLArea = str2double(handles.edit_BLArea);

    %%%%
  function setUiValue(handles, uiValues)
    handles.radiobutton_x.Value = uiValues.isX;
    handles.radiobutton_y.Value = uiValues.isY;
    handles.edit_measPoints.String = num2str(uiValues.measPoints);
    handles.edit_sumLines.String = num2str(uiValues.sumLines);
    handles.popupmenu_method.Value = uiValues.method;
    handles.checkbox_filterMax.Value = uiValues.filterMax;
    handles.checkbox_2D.Value = uiValues.is2D;
    handles.checkbox_darkHole.Value = uiValues.isDarkHole;
    handles.radiobutton_lineAlgo.Value = uiValues.isLine;
    handles.radiobutton_spaceAlgo.Value = uiValues.isSpace;
    handles.radiobutton_forSE.Value = uiValues.isSE;
    handles.radiobutton_forBSE.Value = uiValues.isBSE
    handles.edit_tPercent.String = num2str(uiValues.tPercent);
    handles.edit_mSize.String = num2str(uiValues.mSize);
    handles.edit_smoothing.String = num2str(uiValues.smoothing);
    handles.edit_differential.String = num2str(uiValues.differential);
    handles.edit_BLStartPt = num2str(uiValues.BLStartPt);
    handles.edit_BLArea = num2str(uiValues.BLArea);

% --------------------------------------------------------------------
function saveRecipe_Callback(hObject, eventdata, handles)
try
  % save UI setting
  uiValues = getUiValue(handles);

  measureBox = handles.data.measureBox;
  measurePair = handles.data.measurePair;
  measureFov = handles.data.measureFov;
  boxPairs = handles.data.boxPairs;
  fovSize = handles.data.fovSize;
  imageTemplate = handles.data.rotatedImage;
catch
  setTitle('|ERROR: Recipe is not ready to save');
  return
end

[file, path, filter] = uiputfile([handles.data.recipeDir '\recipe.rcpt'], 'Save file name');
if filter == 0
  setTitle('|WARNING: No folder selected.');
else
  save(fullfile(path,file), 'fovSize', 'uiValues', 'measureFov', 'measureBox', 'measurePair','boxPairs', 'imageTemplate');
end

% --------------------------------------------------------------------
function loadRecipe_Callback(hObject, eventdata, handles)
[file, path, filter] =...
  uigetfile([handles.data.recipeDir '\*.rcpt'],'Select the .rcpt file');

if filter == 0
  setTitle('>>>ERROR: no reipe file selected.');
  return
end

try
  filename = fullfile(path,file);
  matFilename = [filename(1:end-4) 'mat'];
  movefile(filename, matFilename);
  recipe = load(matFilename);
  movefile(matFilename, filename);
  
  handles = initData(handles);
  handles.data.measureFov = recipe.measureFov;
  handles.data.measureBox = recipe.measureBox;
  handles.data.measurePair = recipe.measurePair;
  handles.data.boxPairs = recipe.boxPairs;
  handles.data.measureFov = recipe.measureFov;
  handles.data.fovSize = recipe.fovSize;
  handles.data.imageTemplate = recipe.imageTemplate;

  % update UI
  resetUI(handles);
  setUiValue(handles, recipe.uiValues);
  set(handles.edit_fov, 'string', num2str(recipe.fovSize/1000));

  
  handles = renderImage(handles);
  
  handles = executeRecipe(handles);
  
  % Update handles structure
  guidata(hObject, handles);
catch
  setTitle('|ERROR: Incorrect file.')
  return
end

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
web('https://my2aphswaf/zh/web/mytsmc/people-finder?eid=changyht');

% --------------------------------------------------------------------
function preference_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function setImagePath_Callback(hObject, eventdata, handles)
handles = setPath(handles, 'image');
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function setRecipePath_Callback(hObject, eventdata, handles)
handles = setPath(handles, 'recipe');
% Update handles structure
guidata(hObject, handles);

%%%%
function handles = setPath(handles, op)
dir = uigetdir;
if dir == 0
  setTitle('>>>WARNING: no path selected');
else
  if strcmp(op, 'recipe')
    handles.data.recipeDir = dir;
  elseif strcmp(op, 'image')
    handles.data.imageDir = dir;
  end
end


function edit_fov_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_fov_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%
function pushbutton_calibratePitch_Callback(hObject, eventdata, handles)
set(hObject, 'enable', 'off');
handles = measurePitch(handles);
set(hObject, 'enable', 'on');
% Update handles structure
guidata(hObject, handles);


function edit_nominalPitch_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_nominalPitch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_pitchRepeatCount_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_pitchRepeatCount_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_smoothing_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_smoothing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_mSize_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_mSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_sumLines_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_sumLines_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_filterMax.
function checkbox_filterMax_Callback(hObject, eventdata, handles)


function edit_measPoints_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_measPoints_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_tPercent_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_tPercent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_smaxPercent_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_smaxPercent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_sminPercent_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_sminPercent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_differential_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_differential_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_BLStartPt_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_BLStartPt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_BLArea_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_BLArea_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_method.
function popupmenu_method_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_2D.
function checkbox_2D_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox_darkHole.
function checkbox_darkHole_Callback(hObject, eventdata, handles)

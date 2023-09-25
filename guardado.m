function varargout = guardado(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guardado_OpeningFcn, ...
                   'gui_OutputFcn',  @guardado_OutputFcn, ...
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


% --- Executes just before guardado is made visible.
function guardado_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guardado (see VARARGIN)

% Choose default command line output for guardado
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guardado wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guardado_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function nombre_Callback(hObject, eventdata, handles)
% hObject    handle to nombre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad;
global nombre;
nombre=get(hObject,'String');

% Hints: get(hObject,'String') returns contents of nombre as text
%        str2double(get(hObject,'String')) returns contents of nombre as a double


% --- Executes during object creation, after setting all properties.
function nombre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nombre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Exportar datos a archivo de excel.
function boton_guardar_Callback(hObject, eventdata, handles)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad
global nombre;
global irrad_total;
global EQE;
global Np;
global Ne;

volt_input=transpose(volt_input);
curr_input=transpose(curr_input);
lum_input=transpose(lum_input);
waveLength=transpose(waveLength);
intensidad=transpose(intensidad);
irrad_total=transpose(irrad_total);
EQE=transpose(EQE);
Np=transpose(Np);
Ne=transpose(Ne);

volt_input=double(volt_input);
 curr_input=double(curr_input);
 lum_input=double(lum_input);
 waveLength=double(waveLength);
 intensidad=double(intensidad);
 irrad_total=double(irrad_total);
 EQE=double(EQE);
 Np=double(Np);
 Ne=double(Ne);
 
volt_input=num2cell(volt_input);
curr_input=num2cell(curr_input);
lum_input=num2cell(lum_input);
irrad_total=num2cell(irrad_total);
EQE=num2cell(EQE);
Np =num2cell(Np);
Ne = num2cell(Ne);


T=table(volt_input,curr_input,lum_input,irrad_total,EQE,Np,Ne,'VariableNames',{'voltaje','corriente','luminancia','irradiancia','eficiencia','Np','Ne'});
filename=strcat(nombre,'.xlsx'); 
writetable(T,filename);
%xlswrite(strcat(nombre,'.xlsx'),curr_input);
% hObject    handle to boton_guardar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

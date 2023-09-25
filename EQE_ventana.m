function varargout = EQE_ventana(varargin)
% EQE_VENTANA MATLAB code for EQE_ventana.fig
%      EQE_VENTANA, by itself, creates a new EQE_VENTANA or raises the existing
%      singleton*.
%
%      H = EQE_VENTANA returns the handle to a new EQE_VENTANA or the handle to
%      the existing singleton*.
%
%      EQE_VENTANA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EQE_VENTANA.M with the given input arguments.
%
%      EQE_VENTANA('Property','Value',...) creates a new EQE_VENTANA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EQE_ventana_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EQE_ventana_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EQE_ventana

% Last Modified by GUIDE v2.5 13-Sep-2023 17:30:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EQE_ventana_OpeningFcn, ...
                   'gui_OutputFcn',  @EQE_ventana_OutputFcn, ...
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


% --- Executes just before EQE_ventana is made visible.
function EQE_ventana_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EQE_ventana (see VARARGIN)

% Choose default command line output for EQE_ventana
handles.output = hObject;

global Np;
global waveLength;
global curr_input;
global Ne;
global EQE;

axes(handles.axes1);
plot(curr_input, EQE, 'gs-');
xlabel('Voltaje (Volts)');
ylabel('Densidad de corriente (Amp / cm2)');
title('Característica J vs V');
grid on;





% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EQE_ventana wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EQE_ventana_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu.
function popupmenu_Callback(hObject, eventdata, handles)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad
global Np;
global Ne;
global EQE;

val = get(hObject,'Value');

if val == 1
    % Luminancia
    axes(handles.axes1);
    plot(curr_input, EQE, 'rs-');
    xlabel('J(A/m2)');
    ylabel('EQE');
    title('EQE vs J');
    grid on;
    
    % Eficiencia de corriente
    %axes(handles.axes2);
    %plot(curr_input, lum_input ./ curr_input);
    %xlabel('Densidad de Corriente (A/cm2)');
    %ylabel('L / J [cd/A]');
    %title('Eficiencia de corriente');
    %grid on;
    
elseif val == 2
    % Luminancia
    axes(handles.axes1);
    semilogy(curr_input, EQE,'b-o');
    xlabel('J(A/m2)');
    ylabel('EQE');
    title('EQE vs J');
    grid on;
end    


% --- Executes during object creation, after setting all properties.
function popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

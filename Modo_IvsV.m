function varargout = Modo_IvsV(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Modo_IvsV_OpeningFcn, ...
                   'gui_OutputFcn',  @Modo_IvsV_OutputFcn, ...
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

% --- Executes just before Modo_IvsV is made visible.
function Modo_IvsV_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Modo_IvsV
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Modo_IvsV wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Modo_IvsV_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Vo_Callback(hObject, eventdata, handles)
global vo;
vo = get(hObject,'String');
vo = str2double(vo);

% --- Executes during object creation, after setting all properties.
function Vo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtpaso_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function txtpaso_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Paso_Callback(hObject, eventdata, handles)
global paso
paso = get(hObject,'String');
paso = str2double(paso);

function Paso_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textvf_Callback(hObject, eventdata, handles)

function textvf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Vf_Callback(hObject, eventdata, handles)
global vf
vf = get(hObject,'String');
vf = str2double(vf);

% --- Executes during object creation, after setting all properties.
function Vf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Proporcionar el área del dispositivo
function edit9_Callback(hObject, eventdata, handles)
global area;
area = get(hObject, 'String');
area = str2double(area);

function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Boton_empezar.
function Boton_empezar_Callback(hObject, eventdata, handles)

%PRESIONAR EL BOTON EMPEZAR:
%--------------------------------

global GPIB;
global vo;
global vf;
global paso;
global volt_input2;
global curr_input2;
global ow;
global area;

% Magnitudes a calcular:
volt_input2 = [];
curr_input2 = [];

% Variable del loop:
k=0;
%--------
try
    for i = vo: paso: vf
        
        % Alimentación de voltaje.
        fprintf(GPIB,'++addr 13' );
        step=num2str(i);
        input = ':VOLT';
        fprintf(GPIB, strcat(input,32,step));
        
        % Medida de corriente con OWON
        fprintf(ow, 'MEAS1?');
        meas_curr = fscanf(ow);
        meas_curr = str2num(meas_curr);
        meas_curr = meas_curr / area;
        
        % Medida de voltaje con Keithley 2000
        fprintf(GPIB,'++addr 16');
        fprintf(GPIB, ':MEAS:VOLT?');
        meas_volt = fgetl(GPIB);
        meas_volt = str2num(meas_volt);
        
        
        % Iterador para guardar dato en arreglo.
        k = k + 1;
        
        % Asignación dato por dato.
        volt_input2(k) = meas_volt;
        curr_input2(k) = meas_curr;
        
       
        
        % Gráfica en 'tiempo real'.
        % En realidad se puede comunicar al handler con 'axes'
        % para graficar los datos deseados. Hay que tener en cuenta
        % el primer argumento de la función plot en este caso.
        % Graficar curva característica.
        axes(handles.axes1);
        plot(volt_input2, curr_input2, 'gs-');
        xlabel('Voltaje (V)');
        ylabel('Densidad de Corriente (A/cm2)');
        title('Característica I vs V');
        grid on;
        
        axes(handles.axes2);
        loglog(volt_input2, curr_input2,'rs-');
        xlabel('Voltaje (V)');
        ylabel('Densidad de corriente (A/cm2)');
        title('Característica I vs V escala log');
        grid on;
        
        drawnow; 
    end
     
     
     %---------------------------------------------------------------------
     % Finalización del bucle principal.
     meas_message = warndlg('Medición finalizada.');
     
     % Resetear fuente de voltaje.
     fprintf(GPIB, '++addr 13' );
     fprintf(GPIB, ':VOLT 0' );
catch 
    fclose(ow);
    delete(ow);
    fclose(GPIB); 
    delete(GPIB);
end

%Para luego poner una variable al presionar el seleccionar modo de
%corriente y voltaje para que asi pueda usar otros botones o no haya
%problemas con ventana1
% --- Executes on button press in boton_salir.
function boton_salir_Callback(hObject, eventdata, handles)
clc;
closereq();

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% _____                   _   _____ _      ___________ 
%|  _  |                 | | |  _  | |    |  ___|  _  \
%| | | |_   _  __ _ _ __ | |_| | | | |    | |__ | | | |
%| | | | | | |/ _` | '_ \| __| | | | |    |  __|| | | |
%\ \/' / |_| | (_| | | | | |_\ \_/ / |____| |___| |/ / 
% \_/\_\\__,_|\__,_|_| |_|\__|\___/\_____/\____/|___/
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% GRUPO DE FÍSICA APLICADA
% PROGRAMA PARA CARACTERIZACIÓN DE DISPOSITIVOS OLED
% 
% Recomendaciones generales:
% - Verificar que los drivers necesarios para la ejecución del programa estén 
% 	correctamente instalados en el ordenador (Drivers de equipos de medición, 
%	Prologix GPIB configurator y archivos de calibración necesarios).
% - Verificar que los archivos de calibración y de lectura tales como 
%	hojas de cálculo para la curva fotópica, archivo de calibración para el 
%	espectrómetro, estén en el MISMO directorio que contiene 'oled_meas.m'. 
% - Verificar que la versión instalada de MatLab cuente con el paquete
%	'Instrument Control Toolbox' (Muy importante).
% - Verificar que los puertos COM asignados automáticamente por Windows se 
%   correspondan con los que están señalados en la inicialización de conexiones.
% 	Modificar el argumento de las funciones serial() en caso de requerir 
% 	cambiar el puerto de comunicación (ÚNICAMENTE MODIFICAR ESTE CAMPO).
%	Para verificar qué puerto le corresponde a cada instrumento/conexión, 
% 	verificar el administrador de dispositivos de Windows.
% - Hacer uso del modo J vs V para una medición rápida y verificar que todo
% 	esté funcionando correctamente. 
%
% PASO 1   
% IMPORTANTE: ENCENDIDO DE APARATOS
% - Primero se debe encender la fuente de voltaje.
% - Después el multímetro keithley 2000.
% - Por último dispositivos USB (Bk precision, owon, aseq).
% - Ejecutar GPIB-CONFIGURATOR (ejecutable) antes de hacer uso del programa.
% - Identificar posibles malos contactos en caso de obtener mediciones 
%	incoherentes. También se deben apagar y volver a encender los equipos y 
% 	reiniciar el programa si se encuentran fallos a la hora de realizar la 
% 	medición.
%
% PASO 2
% USO DEL PROGRAMA:
% - En el modo principal, se debe ir a la pestaña de 'Spectra' y llenar los 
% 	campos requeridos para el funcionamiento del espectrómetro, tales como eL
% 	número de promedios y tiempo de exposición (e.g. 200 ms, 20 promedios, 
%	respectivamente).
% - Llenar los campos para el suministro de voltaje y el área del dispositivo.
% 	Tener en cuenta las unidades de medidas indicadas en la interfaz gráfica.
%	Parámetros de prueba (volt_inicial = 0.5, volt_final = 5, volt_paso = 0.5,
%  	area_dispositivo = 1).
% - Luego de llenar los campos, seguir el orden: 'Capturar', 'Ejecutar'. 
%   Usar el botón de 'Abortar' si desea terminar la operación. 'Salir'
% 	cerrará las conexiones existentes entre el ordenador y los DISPOSITIVOS
% 	USB y GPIB.
% - Es posible repetir la medición siempre que se desee, pero se debe recordar
% 	hacer el cambio de parámetros en caso de ser necesario.
% - Seleccionar el Modo J vs V (Característica) para realizar mediciones 
%	rápidas.
%
%-------------------------------------------------------------------------------
%------------------------------------------------------------------------------- 
% Código de inicialización para la interfaz gráfica (NO MODIFICAR).
function varargout = oled_meas(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oled_meas_OpeningFcn, ...
                   'gui_OutputFcn',  @oled_meas_OutputFcn, ...
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

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% Se ejecuta antes de que al ventana sea visible.
% Se deben inicializar las conexiones en este espacio.
function oled_meas_OpeningFcn(hObject, eventdata, handles, varargin)
clc

% Settings para la conexión de los dispositivos con GPIB.
% Se escoge el puerto que se esté usando (Windows lo asigna automáticamente),
% pero el número de puerto debe ser cambiado en caso de ser necesario.
global GPIB; % Variable 
GPIB = serial ( 'COM9' ) ; 

% Tipo de lectura (finalización de línea).
GPIB.Terminator = 'CR/LF' ;         

% Timeout (tiempo de chance para responder).
GPIB.Timeout = 0.5; 

% 'Abrir' conexión GPIB.
fopen(GPIB);

% Funciones propias del prologix.
fprintf(GPIB, '++eos 0');           
fprintf(GPIB, '++auto 1');
fprintf(GPIB, '++eoi 1');

% Direcciones GPIB: ++addr 13 -> fuente de voltaje,
% ++addr 22 -> PM2525, ++addr 16 -> Keithley2000
% Opciones de arranque para la fuente
fprintf(GPIB, '++addr 13' );
fprintf(GPIB, ':INST:STAT ON' );
fprintf(GPIB, ':VOLT 0' );

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% Dispositivo USB, conexión serial, OWON XDM1041.
% Settings iniciales de conexión, windows asigna automático puerto COM.
% Solo funciona con este baudrate.
% Usar rate=Fast para que de mejor el resultado y 50 mA de rango.
global ow;
ow = serial('COM11', 'BaudRate', 115200, 'Terminator', 'CR');
ow.DataBits = 8;
ow.StopBits = 1;
%set(ow, 'Tag', 'multi');

% Tiempo de respuesta
set(ow, 'Timeout', 0.1);

% 'abrir' conexión serial
fopen(ow);

% Settings iniciales
fprintf(ow, 'RATE F');
fprintf(ow, 'CONF:CURR:DC 50E-3');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Dispositivo USB, conexión serial, bk precision 2831e, consultar manual.
% Settings iniciales de conexión, windows asigna automático puerto COM
global s;
s = serial('com10', 'BaudRate', 9600, 'Terminator', 'LF');
s.DataBits = 8;
s.Parity = 'even';
s.StopBits = 1;
set(s, 'Tag', 'multi');

%Tiempo de respuesta
set(s, 'Timeout', 1.5);

%'abrir' conexión serial
fopen(s);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Configuración del espectrómetro.
global x1;
global norm_pot;
global norm;
global fondo1;
global waveLength;
global coeff;
global waveinterv;
global curva_fotopica;
global Long_min;
global Long_max;

coeff = 0.163;
fondo1 = zeros(3653,1);
x1 = textread('Y 2793.txt');                                                               
waveLength = x1(3:3655);
norm = x1(3656:7308);
norm_pot = x1(7310:10962);
norm_pot = transpose(norm_pot);                                                                       
norm_pot = double(norm_pot);
norm = transpose(norm);                                                                       
norm = double(norm);

waveinterv = [];
waveL = length(waveLength);


C= readtable('curva_fotopica.xlsx');
curva_fotopica = C(:,2);
curva_fotopica =table2array(curva_fotopica);

Long_min=3654-786;
Long_max=3654-2860;

for d=1:1:(waveL-1)
    waveinterv(d)= waveLength(d) - waveLength(d+1);
end     
waveinterv(waveL)=0.2;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Output línea de comandos.
handles.output = hObject;

% Actualizar handles structure
guidata(hObject, handles);

% UIWAIT hace que el programa espere por la interacción del ususario.
% uiwait(handles.figure1);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Outputs a la línea de comandos.
function varargout = oled_meas_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% ELEMENTOS GRÁFICOS
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% PANELES.
function paneL_jv_CreateFcn(hObject, eventdata, handles)
function panel_jlum_CreateFcn(hObject, eventdata, handles)


% Botones para cambiar de tab (oculta o muestra).
function button_tab1_Callback(hObject, eventdata, handles)
set(handles.paneL_jv,'visible','on');
set(handles.panel_jlum,'visible','off');
set(handles.spectra_panel,'visible','off');

function button_tab2_Callback(hObject, eventdata, handles)
set(handles.paneL_jv,'visible','off');
set(handles.panel_jlum,'visible','on');
set(handles.spectra_panel,'visible','off');

function button_tab3_Callback(hObject, eventdata, handles)
set(handles.paneL_jv,'visible','off');
set(handles.panel_jlum,'visible','off');
set(handles.spectra_panel,'visible','on');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_volt_ini_Callback(hObject, eventdata, handles)

function edit_volt_ini_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_volt_fin_Callback(hObject, eventdata, handles)

function edit_volt_fin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_volt_step_Callback(hObject, eventdata, handles)

function edit_volt_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_area_Callback(hObject, eventdata, handles)

function edit_area_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% establecer tiempo de exposicion(*100 para pasar a decenas de microsegundo)
function tiempo_Callback(hObject, eventdata, handles)
global numOfBlankScans;
global exposureTime;

numOfBlankScans=0;
exposureTime=get(hObject,'String');
exposureTime=str2double(exposureTime);
exposureTime=exposureTime*100;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function tiempo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%Definir la cantidad de mediciones de espectrometro
%--------------------------------------------------------------------------
function promedios_Callback(hObject, eventdata, handles)
% crear n promedios según lo defina el usuario.
global numOfScans;

numOfScans=get(hObject,'String');
numOfScans=str2double(numOfScans);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function promedios_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%luminacia mínima para sacar espectro
function Lum_minim_Callback(hObject, eventdata, handles)
global luminancia_min;
luminancia_min = get(hObject,'String');
luminancia_min = str2double(luminancia_min);

function Lum_minim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Tomar fondo con el aseq.
function botonTomarFondo_Callback(hObject, eventdata, handles)
global fondo;
global waveLength;
global numOfScans;
global numOfBlankScans;
global exposureTime;
global norm;
fondo = getSpectraASEQ(numOfScans,numOfBlankScans,exposureTime);
fondo = double(fondo);
fondo = fondo./norm;

% --------------------------------------------------------------------
function botonTomarFondo_CreateFcn(hObject, eventdata, handles)

% --------------------------------------------------------------------
function Modos_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function modo_ivsv_Callback(hObject, eventdata, handles)
Modo_IvsV

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Si se activa el checkbox, se quita el fondo.
function checkbox_quitarFondo_Callback(hObject, eventdata, handles)
global fondo;
global fondo1;
fondo1=fondo;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Captura los datos para su posterior uso
function button_capturar_Callback(hObject, eventdata, handles)
global volt_ini;
global volt_fin;
global volt_step;
global area;

volt_ini = str2double(get(handles.edit_volt_ini,'String'));
volt_fin = str2double(get(handles.edit_volt_fin,'String'));
volt_step = str2double(get(handles.edit_volt_step,'String'));
area = str2double(get(handles.edit_area,'String'));

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Ejecuta el proceso principal del programa. (loop principal)
function button_ejecutar_Callback(hObject, eventdata, handles)
% Característica.
global volt_ini;
global volt_fin;
global volt_step;
global area;
global GPIB;
global ow;
global s;
global kill;
kill=0;

% Espectro.
global fondo;
global fondo1;
global waveLength;
global numOfScans;
global numOfBlankScans;
global exposureTime;
global intensidad;
global irradiancia;
global norm;
global norm_pot;
global coeff;
global waveinterv;
global nofondo;
global luminancia_min;
global irrad_total;


%magnitudes a calcular:
global volt_input;
global curr_input;
global lum_input; 


%valores EQE:
global coef_Integral;
global curva_fotopica;
global Long_min;
global Long_max;
global Np;
global Ne;
global EQE;


% Variables propias del bucle.
k = 0;
alfa = 10;
statement1 = 0;
statement2 = 0;
statement3 = 0;
statement4 = 0;

% Se usan estas estructuras para graficar posteriormente.
volt_input = [];
curr_input = [];
lum_input = [];
irrad_total = [];
Np = [];
Ne = [];
EQE = [];

% Carga Placeholder para la gráfica.
% J vs V
axes(handles.axes1);

% Inicio del bucle.
try
    for i = volt_ini: volt_step: volt_fin
        
        % Abortar programa.
        if kill>0
            pause(3);
            fprintf(GPIB, '++addr 13' );
            fprintf(GPIB, ':VOLT 0' );
            break
        end
        
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
        
        % Medida de voltaje de luminancia con BK precision 2831E
        fprintf(s,':FETC?');
        meas_vlux = fscanf(s);
        meas_vlux = str2num(meas_vlux);
        meas_int = meas_vlux * alfa;
        
        % Cambios de escala para el luxómetro.
        if meas_int > 1.99
            if statement1 == 0
                statement1 = 1;
                alfa = 100;
                h = warndlg('Mover el luxómetro al nivel 2');
                pause(10)
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int = meas_vlux * alfa;
            else
                perro = 1;
            end
        else
            perro = 1;
        end
        
        if meas_int > 20
            if statement2 == 0
                statement2 = 1;
                h = warndlg('Mover el luxómetro al nivel 3');
                pause(10)
                alfa = 1000;
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int = meas_vlux * alfa;
            else
                perro = 1;
            end
        else
            perro = 1;
        end
        
        if meas_int > 200
            if statement3 == 0
                statement3 = 1;
                h = warndlg('Mover el luxómetro al nivel 4');
                pause(10)
                alfa = 10000;
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int = meas_vlux * alfa;
            else
                perro=1;
            end
        else
            perro = 1;
        end
        
        if meas_int > 2000
            if statement4 == 0
                statement4 = 1;
                h = warndlg('Mover el luxómetro al nivel 5');
                pause(10)
                alfa=100000;
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int=meas_vlux*alfa;
            else
                perro=1;
            end
        else
            perro=1;
        end
        
        % Iterador para guardar dato en arreglo.
        k = k + 1;
        
        % Asignación dato por dato.
        volt_input(k) = meas_volt;
        curr_input(k) = meas_curr;
        
        %Calcular la luminancia:eso es 100(factor por la geometria del tubo)
        %multiplicado por meas_int (PENDIENTE BUSCAR EL NOMBRE DE ESTA MAGNITUD)
        lum_input(k)  = meas_int * 100;
        
        %---------------------------------------------------------
        %condicional:
        %---------------------------------------------------------
        set(handles.lum_actual,'String',lum_input(k));
        if lum_input(k) < luminancia_min
            
            % NO tomar espectro si la luminancia no supoera al valor
            % mínimo
            %REVISAR VALOR ASIGNADO SI NO SE CUMPLE:
            intensidad = fondo1 - fondo1;
            irradiancia = intensidad;
            
            irrad_total(k)=-500;
            set(handles.textRta,'String','nA')
        else
            % Para el espectrómetro
            intensidad = getSpectraASEQ(numOfScans,numOfBlankScans,exposureTime);
            
            % BUg: el programa se congelaba al quitar el fondo. Sol:
            % Transformar el espectro obtenido a double.
            intensidad = double(intensidad);
            intensidad = intensidad ./ norm;
            intensidad = intensidad - fondo1;
            
            %Calcular la irradiancia:
            %multiplicar por los coeficientes de irradiancia (archivo de calib)
            %multiplicar por el tiempo de exposiciòn
            %el factor de 10^(7) es porque el programa lo pide en ms
            irradiancia = intensidad .* norm_pot;
            irradiancia = coeff * (exposureTime / 10000000) * intensidad;
            
            %Calcular la potencia por area total ( espectro visible):
            %ACLARACION:irradiancia es irradiancia espectral
            
            pot = irradiancia(891:2868);
            waveinterv2 = waveinterv(891:2868);
            waveinterv2 = transpose(waveinterv2);
            pot = pot .* waveinterv2;
            suma = sum(pot);
            irrad_total(k) = suma;
            set(handles.textRta,'String',suma);
            
            %calculo del EQE
            %Primero se calcula la integral de la irradiancia multiplicada
            %por curva fotopica para encontrar A.
            waveintervalo=transpose(waveinterv);
            aux_array = irradiancia(Long_max:Long_min).* curva_fotopica(Long_max:Long_min);
            coef_Integral = aux_array.*waveintervalo(Long_max:Long_min); 
            sum_coef_Integral = sum(coef_Integral);
            AA = (lum_input(k) / sum_coef_Integral);
            L_lambda= AA*aux_array;
            hc = 1.98644e-25; 
            integral_const = pi*AA/(683*hc);
            waveLe = transpose(waveLength);
            aux_np = irradiancia(Long_max:Long_min).*waveLe(Long_max:Long_min)*1e-9;
            %FALTAN LOS COEFICIENTES DE CALIBRACIÒN!!!!
            np = aux_np.*waveintervalo(Long_max:Long_min);
            Np(k) = integral_const*sum(np);
            C_e = 1.60217*1e-19;
            Ne(k) = curr_input(k)*area/C_e;
            EQE(k) =Np(k)/Ne(k);
            
        
        end
        
        % Gráfica en 'tiempo real'.
        % En realidad se puede comunicar al handler con 'axes'
        % para graficar los datos deseados. Hay que tener en cuenta
        % el primer argumento de la función plot en este caso.
        % Graficar curva característica.
        axes(handles.axes1);
        plot(volt_input, curr_input, 'gs-');
        xlabel('Voltaje (Volts)');
        ylabel('Densidad de corriente (Amp / cm2)');
        title('Característica J vs V');
        grid on;
        
        
        % Graficar espectro (tiempo real)
        axes(handles.axes7);
        plot(waveLength, intensidad);
        xlabel('Longitud de onda (nm)');
        ylabel('intensidad (cuentas)');
        title('espectro de medida final');
        grid on;
        
        % Graficar luminancia (tiempo real)
        axes(handles.axes8);
        plot(volt_input, lum_input, 'rs-');
        xlabel('Voltaje (Volts)');
        ylabel('luminancia (cd/m2)');
        title('luminancia vs V');
        drawnow; 
    end
     
     % Graficar LUEGO de terminar el proceso.
     % Luminancia.
     axes(handles.axes4);
     plot(lum_input, curr_input, 'rs-');
     xlabel('Voltaje Lum (Volts)');
     ylabel('Densidad de corriente (Amp / cm2)');
     title('Característica J vs VLum');
     grid on;
     
     % Espectro
     axes(handles.axes5);
     plot(waveLength, intensidad);
     xlabel('Longitud de onda (nm)');
     ylabel('intensidad (cuentas)');
     title('espectro de medida final');
     
     % Irradiancia absoluta:
     axes(handles.axes10);
     plot(waveLength, irradiancia);
     xlabel('Longitud de onda (nm)');
     ylabel('irradiancia (uW/cm^2 nm)');
     title('espectro de irradiancia de la medida final');
     
     %---------------------------------------------------------------------
     % Resetear fuente de voltaje.
     fprintf(GPIB, '++addr 13' );
     fprintf(GPIB, ':VOLT 0' );
     
     % Finalización del bucle principal.
     meas_message = warndlg('Medición finalizada.');
     
     %dlmwrite('volts.txt', volt_input);
     
     
catch 
    fclose(ow);
    delete(ow);
    fclose(s);
    delete(s);
    fclose(GPIB); 
    delete(GPIB);
end

% --- Llamar GUIDES ADICONALES.

% --- Executes during object creation, after setting all properties.
function text15_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in graficas_boton.
function graficas_boton_Callback(hObject, eventdata, handles)
oled_Ventana1;

% --------------------------------------------------------------------
function Archivo_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function exportar_datos_Callback(hObject, eventdata, handles)

guardado

% --- Executes on button press in boton_kill.
function boton_kill_Callback(hObject, eventdata, handles)
global kill;
pause(1);
kill=1;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Cierra el programa.
function button_term_Callback(hObject, eventdata, handles)
clc;
global GPIB;
global ow;
global s;
global kill;
fclose(ow);
delete(ow);
fclose(s);
delete(s);
fclose(GPIB); 
delete(GPIB);
closereq();


function eficienciaButton_Callback(hObject, eventdata, handles)
EQE_ventana();

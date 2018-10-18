function varargout = p(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @p_OpeningFcn, ...
                   'gui_OutputFcn',  @p_OutputFcn, ...
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

function p_OpeningFcn(hObject, eventdata, handles, varargin)
    global settings;
    handles.output = hObject;
    guidata(hObject, handles);
    settings = init();
    set(handles.slider3, 'value', settings.noise_power);
    set(handles.text4, 'string',sprintf('Noise strength : %.2f', settings.noise_power));
    
    set(handles.slider5, 'value', settings.color_fai);
    set(handles.text12, 'string',sprintf('Coloring factor : %.2f', settings.color_fai));
    
    set(handles.edit1, 'string',sprintf('%.2f', settings.SYS_NOI));
    set(handles.edit3, 'string',sprintf('%.2f', settings.OBS_NOI));
    
    set(handles.r1, 'value', settings.domain == 'T');
    set(handles.r2, 'value', settings.domain == 'F');
    
    set(handles.r3, 'value', settings.kf_method == 'S');
    set(handles.r4, 'value', settings.kf_method == 'C');
    
    build_once(handles, 1, 1);
function varargout = p_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;

function build_once(handles, generate, change_noi)
    global settings;
    
    if(generate ~= 0)
        settings = noi_gen(settings, change_noi);
    end
    
    [acno, xacno] = xcorr(settings.noi, 'unbiased');
    axes(handles.axes10);
    plot(xacno * settings.DeltaT, acno);
    box on;
    grid on;
    
    [acco, xacco] = xcorr(settings.cno, 'unbiased');
    axes(handles.axes11);
    plot(xacco * settings.DeltaT, acco);
    box on;
    grid on;
    
    if settings.domain == 'T'
        [Xn, Zn, Pn] = KF(settings.nobs, settings);
        [Xc, Zc, Pc] = KF(settings.cobs, settings);
        
        axes(handles.axes1);
        plot(settings.noi);
        axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes2);
        plot(settings.cno);
%         axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes3);
        plot(settings.nobs);
        axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes4);
        plot(settings.cobs);
%         axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes5);
        plot(Zn);
        axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes6);
        plot(Zc);
        axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes7);
        plot(Zn-settings.carr);
        axis(settings.figure_axis);
        box on;
        grid on;

        axes(handles.axes8);
        plot(Zc-settings.carr);
        axis(settings.figure_axis);
        box on;
        grid on;

        set(handles.text2, 'string',sprintf('RMS : %.3f', rms(Zn-settings.carr)));
        set(handles.text3, 'string',sprintf('RMS : %.3f', rms(Zc-settings.carr)));

        axes(handles.axes9);
        plot(settings.carr);
        axis(settings.figure_axis);
        box on;
        grid on;
    elseif(settings.domain == 'F')
        N = settings.sequence_length;
        
        pnoi  = 10*log10(abs(fft(settings.noi).^2)/N);
        fnoi  = (0:length(pnoi)-1)/length(pnoi);
        pcno  = 10*log10(abs(fft(settings.cno).^2)/N);
        fcno  = (0:length(pcno)-1)/length(pcno);
        pcarr = 10*log10(abs(fft(settings.carr).^2)/N);
        fcarr = (0:length(pcarr)-1)/length(pcarr);       
        pnobs = 10*log10(abs(fft(settings.nobs).^2)/N);
        fnobs = (0:length(pnobs)-1)/length(pnobs);           
        pcobs = 10*log10(abs(fft(settings.cobs).^2)/N);
        fcobs = (0:length(pcobs)-1)/length(pcobs);    
        
        [Xn, Zn, Pn] = KF(settings.nobs, settings);
        [Xc, Zc, Pc] = KF(settings.cobs, settings);
        
        pzn = 10*log10(abs(fft(Zn).^2)/N);
        fzn = (0:length(Zn)-1)/length(Zn);
        
        pzc = 10*log10(abs(fft(Zc).^2)/N);
        fzc = (0:length(Zc)-1)/length(Zc);
        
        axes(handles.axes1);
        plot(fnoi, pnoi);
        box on;
        grid on;

        axes(handles.axes2);
        plot(fcno, pcno);
        box on;
        grid on;

        axes(handles.axes3);
        plot(fnobs, pnobs);
        box on;
        grid on;

        axes(handles.axes4);
        plot(fcobs, pcobs);
        box on;
        grid on;   

        axes(handles.axes5);
        plot(pzn);
        box on;
        grid on;

        axes(handles.axes6);
        plot(pzc);
        box on;
        grid on;

        axes(handles.axes7);
        plot(fzn, pzn-pcarr);
        box on;
        grid on;

        axes(handles.axes8);
        plot(fzc, pzc-pcarr);
        box on;
        grid on;

        
        set(handles.text2, 'string',sprintf('RMS : %.3f', rms(pzn-pcarr)));
        set(handles.text3, 'string',sprintf('RMS : %.3f', rms(pzc-pcarr)));

        axes(handles.axes9);
        plot(fcarr, pcarr);
        box on;
        grid on;        
    end

function pushbutton1_Callback(hObject, eventdata, handles)
    build_once(handles, 1, 1);

function slider1_Callback(hObject, eventdata, handles)

function slider1_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


function text2_CreateFcn(hObject, eventdata, handles)


function text3_CreateFcn(hObject, eventdata, handles)
function slider3_Callback(hObject, eventdata, handles)
    global settings;
    set(handles.text4, 'string',sprintf('Noise strength : %.2f', ...
        get(hObject, 'value')));
    settings.noise_power = get(hObject, 'value');
    build_once(handles, 1, 1);

function slider3_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


function slider5_Callback(hObject, eventdata, handles)
     global settings;
    set(handles.text12, 'string',sprintf('Coloring factor : %.2f', ...
        get(hObject, 'value')));
    settings.color_fai = get(hObject, 'value');
    build_once(handles, 2, 0);  
function slider5_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
    global settings;
    if ~isempty(str2num(get(hObject, 'string')))
        set(handles.text17, 'string', '¡Ì');
        settings.SYS_NOI = str2num(get(hObject, 'string'));
        build_once(handles, 0, 0);
    else
        set(handles.text17, 'string', '¡Á');
    end
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
    global settings;
    if ~isempty(str2num(get(hObject, 'string')))
        set(handles.text18, 'string', '¡Ì');
        settings.OBS_NOI = str2num(get(hObject, 'string'));
        build_once(handles, 0, 0);
    else
        set(handles.text18, 'string', '¡Á');
    end
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton2_Callback(hObject, eventdata, handles)


function r1_Callback(hObject, eventdata, handles)
    global settings;
    if settings.domain == 'F'
        settings.domain = 'T';
        set(handles.r2, 'value', 0);
        build_once(handles, 0, 0);
    end
function r2_Callback(hObject, eventdata, handles)
    global settings;
    if settings.domain == 'T'
        settings.domain = 'F';
        set(handles.r1, 'value', 0);
        build_once(handles, 0, 0);
    end


function r3_Callback(hObject, eventdata, handles)
    global settings;
    if settings.kf_method == 'C'
        settings.kf_method = 'S';
        set(handles.r4, 'value', 0);
        build_once(handles, 0, 0);
    end
function r4_Callback(hObject, eventdata, handles)
    global settings;
    if settings.kf_method == 'S'
        settings.kf_method = 'C';
        set(handles.r3, 'value', 0);
        build_once(handles, 0, 0);
    end

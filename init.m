function [settings] = init()
    settings = {};
    %% for signal
    settings.sequence_length = 1000;
    settings.true_omega = 2;
    settings.true_fai0  = 0;
    settings.DeltaT  = 0.1;
    
    %% for noises
    settings.noise_power = 0.05;
    settings.color_fai   = 0.5;
    
    %% for KF
    settings.SYS_NOI = 0.1;
    settings.OBS_NOI = 1;
    
    %% for GUI
    settings.figure_axis = [0, settings.sequence_length, -2, 2];
    
    %% signal buffers
    settings.noi  = zeros();
    settings.cno  = zeros();
    settings.carr = zeros();
    settings.nobs = zeros();
    settings.cobs = zeros();
    
    %% display flag
    settings.domain= 'T';
    settings.kf_method = 'S';
end


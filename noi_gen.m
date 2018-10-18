function [settings] = noi_gen(settings, change_noi)
    power_scale = sqrt(settings.noise_power);
    if change_noi == 1
        settings.noi = (randn(settings.sequence_length, 1)) * power_scale;
    end
    settings.cno = settings.noi;
    power_scale = sqrt(1 / (settings.color_fai + 1));
    for i = 2 : settings.sequence_length
        settings.cno(i) = (settings.color_fai * settings.cno(i-1) + settings.noi(i-1));
    end
    
    for i = 2 : settings.sequence_length
        settings.cno(i) = settings.cno(i) * power_scale;
    end
    
    time_last = (settings.sequence_length - 1) * settings.DeltaT;
    settings.carr = sin(settings.true_omega * (0 : settings.DeltaT : time_last) + settings.true_fai0)';
    settings.nobs = settings.carr + settings.noi;
    settings.cobs = settings.carr + settings.cno;
end


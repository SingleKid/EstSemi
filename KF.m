function [ Xh, Zh, Px] = KF(obs, settings)
    
    
    X = [settings.true_omega; settings.true_fai0];  % [w, fai]
    P = [settings.OBS_NOI,0;0,settings.OBS_NOI];
    F = [1,0;settings.DeltaT,1];
    Q = eye(2) * settings.SYS_NOI;
    R = settings.OBS_NOI;
    I = eye(2);
    
    epoch_num = size(obs,1);
    
    Xh = zeros(epoch_num, 2);
    Zh = zeros(epoch_num, 1);
    Px = zeros(epoch_num, 4);
    
    if settings.kf_method == 'C'
         Fn = settings.color_fai;
         Hb = [0, cos(X(2))];
         Zb = obs(1);
    end
    
    for i = 2 : epoch_num
        if settings.kf_method == 'S'
            % prediction
            X = F * X;
            P = F * P * F' + Q;
        end
        % observation
        Z  = obs(i);
        
        H  = [0, cos(X(2))];
        Zp = sin(X(2));
        
        if settings.kf_method == 'C'
            H = (H * F - Fn * Hb);
            R = H * Q * H' + settings.OBS_NOI;
            Z = Z - Fn * Zb;
            
            Xp = F * X;
            Zp = sin(Xp(2)) - Fn * sin(X(2)); %H* X; 
            
            Hb = [0, cos(X(2))];
            Zb = obs(i);
        end
        
        % updating
        K = P * H' * inv(H * P * H' + R);
        X = X + K * (Z - Zp);
        P = (I - K * H) * P;
        
        if settings.kf_method == 'C'
            % prediction
            X = F * X;
            P = F * P * F' + Q;            
        end
        
        Xh(i,:) = X;
        Zh(i)   = sin(X(2));
        Px(i,:) = [P(1,1), P(1,2),P(2,1),P(2,2)];
        

    end
end


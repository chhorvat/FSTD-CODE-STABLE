%% Reset_global_variables
% This code handles the resetting of counting variables (like the number of
% internal timesteps) that must be reset at each large-scale timestep. It
% also resets matrices which are used each timestep
% Timestep Markers
OPTS.dt_sub =OPTS.dt;
OPTS.dt_temp = OPTS.dt_sub;
OPTS.numSC = 0;

%% Reset the calculation of gamma_ridge/raft

if MECH.DO
    
    MECH.gamma_raft = calc_gamma_raft_FD(FSTD.Hmid,FSTD.meshHmid,MECH.H_raft);
    MECH.gamma_ridge = 1 -  MECH.gamma_raft;
    
end

%% Re-set concentration, etc

% Reset the open water and concentration
FSTD.conc = sum_FSTD(FSTD.psi,FSTD.one,0); 
FSTD.openwater = 1 - FSTD.conc;

FSTD.NumberDist = FSTD.psi./(pi*FSTD.meshR.^2);

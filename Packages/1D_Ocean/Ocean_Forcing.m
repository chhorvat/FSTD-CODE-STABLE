% Ocean_Forcing
% At each timestep this code calculates the tendencies from the ocean. 

% This generally matters when ADVECT.DO = 1
% This means that ice is advected by the ocean
% currents. Therefore we calculate what the advective velocities in the ice
% are, induced by the ocean currents that we prescribe, using a very simple
% rheology. 


if ADVECT.DO
    
    % Ocean is prescribed with two velocities, OCEAN.Uvel and OCEAN.Vvel,
    % where Uvel is positive from the pack to the open water, and Vvel is
    % positive perpendicular to Uvel.
    
    % We calculate the thickness of the ice that is entering the field from
    % the FSTD used in ADVECT (ADVECT.FSTD_in) as well as the mean ice
    % concentration. 
    
    ADVECT.Hmean_in = integrate_FD(ADVECT.FSTD_in,[FSTD.H FSTD.H_max_i],1);
    ADVECT.conc_in = sum(ADVECT.FSTD_in(:)); 

    % The coefficient which relates the straining by the ocean velocities
    % to the straining by the ice is set here. 
    
    % It has three components:    
    ADVECT.oc_to_ic = OPTS.ociccoeff * ... % A linear coefficient
        (OPTS.H_0/FSTD.Hmean) * ... % A function which becomes small as the thickness becomes small. 
        ( 1 - exp(-(1 + OPTS.ocicbeta - sum(FSTD.psi(:)))/OPTS.ocicdelta)); 
    % And a coefficient which goes to zero as the ice concentration approaches 
    % A quantitity equal to 1 + OPTS.ocicbeta. Since FSTD.conc cannot
    % exceed 1, this means we will still have some exchange when the
    % concentration is equal to one, with coefficient (1 -
    % e^(-beta/delta)).
    
    % Since there is a velocity at both the pack edge and the open water
    % edge, we have to calculate how the pack edge ice velocity is
    % diminished using the same calculation. This is the coefficient that
    % reduces the ocean velocity for the ice that exists in the pack.    
    ADVECT.in_oc_to_ic = OPTS.ociccoeff ...
        * (OPTS.H_0/ADVECT.Hmean_in) ...
        * ( 1 - exp(-(1 + OPTS.ocicbeta - ADVECT.conc_in)/OPTS.ocicdelta));
    
    if MECH.DO
       
        OCEAN.v2 = 0; % OCEAN.Vvel(2,FSTD.i) * ADVECT.oc_to_ic;
        
        error('Need to figure out why i did this')
        
        
    else
        % This is the velocity in the domain. 
        OCEAN.v = OCEAN.Uvel(FSTD.i) * ADVECT.oc_to_ic;
    
    end
    
    % This is the velocity at the pack-domain edge
    OCEAN.vpack = OCEAN.Uvel(1,FSTD.i) * ADVECT.in_oc_to_ic;
    
    
    
else
    
    % We can just specify an ocean strain rate invariant, if we don't want
    % to use the advective code. This means we need to specify this.
    % Typically if we don't have advection on we can set this to zero, but
    % this must be done at initialization. 
    
    if ~isfield(OCEAN,'StrainInvar') 
        error('No advection but also no prescribed strain invariants. This is bad!')
    end
    
end
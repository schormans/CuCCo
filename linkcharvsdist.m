function [gainout,effout,zlinkout,zreflout,effmax] = linkcharvsdist(coil1,coil2,dists,config,Zout,freq,C1,C2)
%LINKCHARVSDIST Gives key link characteristics vs distance
%   dists can be a vector, everything else should be single values. C1 and
%   C2 are included as options to allow resonance tweaking if desired.


M = zeros(1,length(dists));
k = zeros(1,length(dists));
gainout = zeros(1,length(dists));
effout = zeros(1,length(dists));
zlinkout = zeros(1,length(dists));
zreflout = zeros(1,length(dists));

for a=1:length(dists)
    [M(a),k(a)] = mutualIdeal(coil1,coil2,dists(a));
end

for a=1:length(dists)
    zlinkout(a) = zlink(config,coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zout,C1,C2);
    zreflout(a) = zrefl(config,coil2.coilZ,M(a),2*pi*freq,Zout,C2);
    gainout(a) = gain(config,coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zout,C1,C2,zlinkout(a));
    effout(a) = linkeff(config,gainout(a),zlinkout(a),Zout);
end


effmax = etamax(k,coil1.Q,coil2.Q);


end


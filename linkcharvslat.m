function [gainout,effout,zlinkout,zreflout,effmax] = linkcharvslat(coil1,coil2,dist,lats,config,Zout,freq,C1,C2)
%LINKCHARVSDIST Gives key link characteristics vs lateral spacing
%   lats can be a vector, everything else should be single values. C1 and
%   C2 are included as options to allow resonance tweaking if desired.
%   Otherwise coil1.C and coil2.C should be entered.


M = zeros(1,length(lats));
k = zeros(1,length(lats));
gainout = zeros(1,length(lats));
effout = zeros(1,length(lats));
zlinkout = zeros(1,length(lats));
zreflout = zeros(1,length(lats));

for a=1:length(lats)
    [M(a),k(a)] = mutualLat(coil1,coil2,dist,lats(a));
end

for a=1:length(lats)
    zlinkout(a) = zlink(config,coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zout,C1,C2);
    zreflout(a) = zrefl(config,coil2.coilZ,M(a),2*pi*freq,Zout,C2);
    gainout(a) = gain(config,coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zout,C1,C2,zlinkout(a));
    effout(a) = linkeff(config,gainout(a),zlinkout(a),Zout);
end


effmax = etamax(k,coil1.Q,coil2.Q);


end


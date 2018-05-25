%Cochlear Implant Example

%sweep to find best wire diameter for geometry

wirediams = linspace(0.1e-3,2e-3,100);

Qfactors = zeros(1,100);
Rsvals = zeros(1,100);
turns = zeros(1,100);

for a=1:100

%wirediam = 0.5e-3;
wirediam = wirediams(a);
pitch = 1*wirediam;
freq = 6.78e6;
radius = 10e-3;
lengthlimit = 5e-3;

coil = SolWireCoil(round(lengthlimit/(pitch)),wirediam/2,pitch,radius,freq,0,0.05);

Qfactors(a) = coil.Q;
Rsvals(a) = coil.Rs;
turns(a) = coil.n;
end
%{
figure
subplot(2,1,1)
plot(wirediams*1e3,Qfactors)
grid on
yyaxis right
plot(wirediams*1e3,Rsvals.*(Qfactors.^2))
set(gca,'YScale','log')


subplot(2,1,2)
stairs(wirediams*1e3,turns)
grid on
%}

%set single diams

diam = 0.6e-3;

%%{

coil1 = SolWireCoil(round(lengthlimit/(diam)),diam/2,diam,radius,freq,0,0.05);

coil2 = SolWireCoil(round(lengthlimit/(diam)),diam/2,diam,radius,freq,0,0.05);
%}
%{
coil1 = SolWireCoil(round(lengthlimit/(diam)),diam/2,diam,radius,freq,0,1);

coil2 = SolWireCoil(round(lengthlimit/(diam)),diam/2,diam,radius,freq,0,1);
%}
res = 100;
dists = linspace(3e-3,50e-3,res);

M = zeros(1,res);
k = zeros(1,res);
Zlink = zeros(1,res);
vgain = zeros(1,res);
Zrefl = zeros(1,res);

Zload = 2113;

C1 = (1./(2*pi*6.78e6*sqrt(coil1.L)))^2;
C2 = (1./(2*pi*6.78e6*sqrt(coil2.L)))^2;


for a=1:res
    [M(a),k(a)] = mutualIdeal(coil1,coil2,dists(a));
    Zlink(a) = zlink('SP',coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zload,C1,C2);
    vgain(a) = (gain('SP',coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zload,C1,C2,transpose(Zlink(:,a))));
    Zrefl(a) = zrefl('SP',coil2.coilZ,M(a),2*pi*freq,Zload,C2);
end

vin = sqrt((40e-3*real(Zload))./(abs(vgain).^2));

powerout = ((((abs(vin).^2).*(abs(vgain).^2)))./real(Zload));

%For SS and SP link
i1 = vin./Zlink;

%Old eff calcs had some errors
%{
eff1 = ((abs(i1).^2).*real(Zrefl).*real(Zlink))./(vin.^2);
eff2 = (abs(vin.*vgain).^2)./((abs(i1).^2).*real(Zload).*real(Zrefl));
%}


efflink = (abs(vgain).^2).*((abs(Zlink).^2.*real(Zload))./((abs(Zload).^2.*real(Zlink))));

figure
yyaxis left
plot(dists*1e3,efflink);
grid on
yyaxis right
plot(dists*1e3,vin);

diam = 0.5e-3;
%{
coil1 = SolWireCoil(round(lengthlimit/(diam)),diam/2,diam,radius,freq,0,0.05);

coil2 = SolWireCoil(round(lengthlimit/(diam)),diam/2,diam,radius,freq,0,0.05);
%}
coil1 = SolWireCoil(coil1.n,diam/2,diam*1.2,coil1.r,freq,0,0.05);

coil2 = SolWireCoil(coil1.n,diam/2,diam*1.2,coil1.r,freq,0,0.05);

res = 100;
dists = linspace(3e-3,50e-3,res);

M = zeros(1,res);
k = zeros(1,res);
Zlink = zeros(1,res);
vgain = zeros(1,res);
Zrefl = zeros(1,res);

Zload = 2113;

C1 = (1./(2*pi*6.78e6*sqrt(coil1.L)))^2;
C2 = (1./(2*pi*6.78e6*sqrt(coil2.L)))^2;

%sub measured vals
%{
C1 = 280e-12;
C2 = 280e-12;
%}


for a=1:res
    [M(a),k(a)] = mutualIdeal(coil1,coil2,dists(a));
    Zlink(a) = zlink('SP',coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zload,C1,C2);
    vgain(a) = (gain('SP',coil1.coilZ,coil2.coilZ,M(a),2*pi*freq,Zload,C1,C2,transpose(Zlink(:,a))));
    Zrefl(a) = zrefl('SP',coil2.coilZ,M(a),2*pi*freq,Zload,C2);
end

vin = sqrt((40e-3*real(Zload))./(abs(vgain).^2));

powerout = ((((abs(vin).^2).*(abs(vgain).^2)))./real(Zload));


efflink = linkeff('SP',vgain,Zlink,Zload);



hold on
yyaxis left
plot(dists*1e3,efflink);
grid on
yyaxis right
plot(dists*1e3,vin); 


%{
%find required Vin for 40mW Pout

reqdvin = sqrt((40e-3*real(Zload))./(abs(vgain).^2));

figure
plot(dists,reqdvin);
grid on
%}
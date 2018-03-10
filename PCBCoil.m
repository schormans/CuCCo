classdef PCBCoil
    %PCBCOIL Class to contain necessary data and functions for a single
    %printed circuit board based coil
    %   The properties include geometric properties (diameters, fill
    %   factor, spacings etc) as well as derived/electromagnetic properties
    %   (inductance, series resistance, Q factor). These properties are
    %   generated on instantiation of the coil by the constructor. COIL IS
    %   CURRENTLY ASSUMED TO BE SQUARE SPIRAL TYPE
    
    properties
        %Geometric properties
        dout;
        din;
        fillfact;
        w;
        s;
        n;
        %Derived properties
        L;
        Rs;
        Q;
        C;
        CP;
        coilZ;
        fSRF;
        %Frequency
        f;
    end
    
    methods
        %Constructor
        function coilobj = PCBCoil(dout,fillfact,s,w,f,CP,shape,sourceres)
            coilobj.dout = dout;
            coilobj.fillfact = fillfact;
            coilobj.s = s;
            coilobj.w = w;
            coilobj.f = f;
            %Now complete geometry
            %Currently based on stuffing as many turns as possible in the
            %given outer diameter for a given fill factor. din may be
            %larger than desired, since the turns are determined by floor
            %instead of ceil
            coilobj.din = (dout-fillfact*dout)/(fillfact+1);
            disp(coilobj.din)
            coilobj.n = floor(((dout-coilobj.din)/2)/(w+s));
            %din should be recalculated as it may have changed due to
            %rounding.
            coilobj.din = dout-(w*coilobj.n + s*(coilobj.n - 1));
            disp(coilobj.din)
            
            %Now generate derived values
            
            %Free space permeability
            mu0 = (4*pi)*1e-7;
            %Average diameter
            davg = 0.5*(coilobj.din+dout);
            %Spiral inductance formulae
            
            switch shape
                case 'square'
                    coilobj.L = (1.27*(mu0*coilobj.n^2*davg)/2)*(log(2.07/fillfact)+0.18*fillfact+0.13*fillfact^2);
                case 'circ'
                    coilobj.L = ((mu0*coilobj.n^2*davg)/2)*(log(2.46/fillfact)+0.2*fillfact^2);
                case 'hex'
                    coilobj.L = (1.09*(mu0*coilobj.n^2*davg)/2)*(log(2.23/fillfact)+0.17*fillfact^2);
                case 'oct'
                    coilobj.L = (1.07*(mu0*coilobj.n^2*davg)/2)*(log(2.29/fillfact)+0.19*fillfact^2);
            end
            
            
            
            %Conductivity and thickness
            %resist = 17e-9;
            sigma = 58.5e6; %Conductivity of Cu = 58.5e6 S/m
            thk = 35e-6;
            
            %skin depth
            delta = 1./((pi.*f*mu0*sigma).^(1/2));
            
            
            
            %Square length formula
            
            %Ideally need to add conductor length and gap length calcs for
            %different shapes to improve accuracy
            len = 4*coilobj.n*(dout-coilobj.n*s-coilobj.n*w+s)-s;
            
            %DC res
            %Rdc = (resist*len)/(w*thk);
            Rdc = (len)/(w*thk*sigma);
            
            omega = 2*pi*f;
            
            %Taking skin effect into account
            %muc = 1;

            %delta = sqrt((resist)./(pi*muc*mu0*f));

            Rskin = Rdc*thk./(delta.*(1-exp(-thk./delta)));
            
            %assume sheet res for 1oz copper 0.5mOhm/square
            %Rsheet = 1/(sigma*thk);
            %this approx works best for silicon integrated spirals, highly
            %dependent on Rsheet. Adjust this parameter to get best approx
            %for Q behaviour. Ideally needs an improved approx. here.
            Rsheet = 5e-3;
            omegacrit = (3.1/mu0)*((s+w)/(w^2))*Rsheet;
            Rprox = 0.1*Rdc*((omega./omegacrit).^2);
            
            coilobj.Rs = Rskin + Rprox + sourceres;
            
            %Q factor
            
            %gap length from Jow2007
            lg = -4*coilobj.n*(-dout+coilobj.n*(s+w)+w)-w;
            
            
            
            %apply CP prediction from Jow2009. This is much less accurate
            %than the solenoid prediction, and will usually under-estimate
            %by a significant margin.
            if (CP==0)
                coilobj.CP = (0.9*1 + 0.1*4.4)*8.85e-12*(thk/s)*lg;
            else
                coilobj.CP = CP;
            end
            %coilobj.Q = (omega*coilobj.L - omega*(coilobj.Rs^2 + omega^2*coilobj.L^2)*coilobj.CP)/coilobj.Rs;
            coilobj.coilZ = 1./(1./(1j*omega*coilobj.L + coilobj.Rs) + 1j*omega*coilobj.CP);
            coilobj.Q = imag(coilobj.coilZ)./real(coilobj.coilZ);
            
            %calculate self-res freq from the predicted CP or user-supplied
            %CP value
            coilobj.fSRF = 1/(2*pi*sqrt(coilobj.L*coilobj.CP));
            
            %ResCap
            coilobj.C = (1./(omega*sqrt(coilobj.L))).^2;
        end
    end
    
end


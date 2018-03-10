%Simpler function for ideal mutual inductance determination, not
%vectorizable only single value dist is currently supported, loop this
%function for a vector of dists

function [M,k] = mutualIdeal(coil1,coil2,dist)

    %coil1 and coil2 are coil type objects, dist is the distance from edge
    %to edge between the two coils
    
    %first check both coils are the same type
    if (~(strcmp(class(coil1),class(coil2))))
        printf('Error in coupling calc, non-identical coil types\n')
        return
    end
    
    mu0 = (4*pi)*1e-7;
    
switch class(coil1)
    
    case 'SolWireCoil'
    
    %determine distance from centre of coil1 turn 1 to centre of coil2 turn 1
    d121 = coil1.p*(coil1.n-1) + dist + coil1.r0 + coil2.r0;
    
    %create distance array for distances between each turn of each coil
    dists = zeros(coil1.n,coil2.n);
    
    %fill dists array
    for a=1:coil1.n
        for b=1:coil2.n
            dists(a,b) = d121 + (coil2.p*(b-1) - coil1.p*(a-1));
        end
    end
    
    %determining kconst and M here makes the assumption that the radii in
    %the coils are identical (i.e. coils are solenoids) a modified method
    %is needed for pancakes and multi-layer solenoids
    
    
    kconst = sqrt((4*coil1.r.*coil2.r)./(((coil1.r + coil2.r).^2) + dists.^2));
    
    
    
    [K,E] = ellipke(kconst.^2);
    
    
    M = sum(sum(mu0*sqrt(coil1.r*coil2.r).*((2./kconst -kconst).*K - (2./kconst).*E)));
    k = M./sqrt(coil1.L*coil2.L);
    
    case 'PCBCoil'
        
    %Similar calcs for flat pcb coils, need radius arrays instead of
    %distance array
    
    rads1 = zeros(1,coil1.n);
    rads2 = zeros(1,coil2.n);
    
    %fill radius arrays
    
    for a=1:coil1.n
        rads1(a) = ((coil1.dout-coil1.w)/2)-(a-1)*(coil2.w+coil2.s);
    end
    for a=1:coil2.n
        rads2(a) = ((coil2.dout-coil2.w)/2)-(a-1)*(coil2.w+coil2.s);
    end
        
    kconst = zeros(length(rads1),length(rads2));
    
    for a=1:length(rads1)
        for b=1:length(rads2)
            kconst(a,b) = sqrt((4*rads1(a).*rads2(b))./(((rads1(a) + rads2(b)).^2) + dist^2));        
        end
    end
    
    
    [K,E] = ellipke(kconst.^2);
    M = sum(sum(mu0*sqrt(rads1(a)*rads2(b)).*((2./kconst -kconst).*K - (2./kconst).*E)));
    k = M./sqrt(coil1.L*coil2.L);
    
    otherwise
        fprintf('unknown coil type, please check your input\n')
end

end
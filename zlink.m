function [ zlinkval ] = zlink(config,ZL1,ZL2,M,omega,Zout,C1,C2)
%ZLINK determines Zlink based on input params
%   config should be a string, either SS, SP, PS, PP. Other params are self
%   explanatory

switch config
    case 'SS'
        %
        zlinkval = ZL1 + 1./(1j*omega*C1) + ((omega.*M).^2)./(ZL2 + 1./(1j*omega*C2) + Zout);
    case 'SP'
        %
        zlinkval = ZL1 + 1./(1j*omega*C1) + ((omega.*M).^2)./(ZL2 + 1./((1j*omega*C2) + 1./Zout));
    case 'PS'
        %
        zlinkval = 1./(1j*omega*C1 + 1./(ZL1 + ((omega.*M).^2)./(ZL2 + 1./(1j*omega*C2) + Zout)));
    case 'PP'
        %
        zlinkval = 1./(1j*omega*C1 + 1./(ZL1 + ((omega.*M).^2)./(ZL2 + 1./((1j*omega*C2) + 1./Zout))));
    otherwise
        fprintf('invalid config, must be SS, SP, PS, or PP\n');
end

end


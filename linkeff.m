function [ effout ] = linkeff(config,linkgain,Zlink,Zout)
%linkeff Calculate link efficiency
%   config should be a string, either SS, SP, PS, PP. Other params are
%   self-explanatory.

switch config
    
    case 'SS'
        effout = ((abs(linkgain).^2).*real(Zlink))./(real(Zout));
    case 'SP'
        effout = ((abs(linkgain).^2).*real(Zlink))./(real(Zout));
    case 'PS'
        effout = (abs(linkgain).^2)./(real(Zlink).*real(Zout));
    case 'PP'
        effout = (abs(linkgain).^2)./(real(Zlink).*real(Zout));
    otherwise
        fprintf('invalid config, must be SS, SP, PS, or PP\n');
end    
    
end


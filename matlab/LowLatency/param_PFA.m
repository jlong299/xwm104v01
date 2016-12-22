function [ Nf,Nf_PFA,p,q,tw_ROM_sel,tw_ROM_addr_step ] = param_PFA( N )
%PARAM_PFA Summary of this function goes here
%   Detailed explanation goes here

NumOfFactors_max = 6;
%-------- parameters ------------
%                CTA (Cooley-Tukey algorithm )
Nf = ones(1,NumOfFactors_max);   % factorize N
% e.g. If N=1200  = 4*4*5*5*3 = N1*N2*N3*N4*N5
%      Nf(1)=4,  Nf(2)=4,  Nf(3)=5,  Nf(4)=5, Nf(5)=3, Nf(6)=1   ( Nf(1) represents N1 ...)
%      First must be 4,  the last must be 3  (for latency reduction)
%------------------------------
%Nf(1) = 4;  % N1 : Fixed =4 !!!
%            % N_last : Fixed =3 !!!
%----------------------------------

%----------------------------------------------------------------------------------
%                   PFA (Prime factor algorithm)
% Example:
%   for DFT size N = N1*N2*N3       N1=2^a, N2=5^b, N3=3^c
Nf_PFA = zeros(1,3);  % PFA factorized, Nf_PFA(1),Nf_PFA(2),Nf_PFA(3) are relatively prime

p = zeros(1,3);
q = zeros(1,3);
tw_ROM_sel = zeros(1,6);
tw_ROM_addr_step = zeros(1,6);

switch N
	case 60
		Nf = [4,5,3,1,1,1];
		Nf_PFA = [4,5,3];
		p = [4,5,7];
		q = [1,2,1];
		tw_ROM_sel = [1,2,3,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0]; 
	case 240
		Nf = [4,4,5,3,1,1];
		Nf_PFA = [16,5,3];
		p = [1,29,27];
		q = [1,3,1];
		tw_ROM_sel = [1,1,2,3,0,0];
		tw_ROM_addr_step = [16,0,0,0,0,0]; 
	case 1200
		Nf = [4,4,5,5,3,1];
		Nf_PFA = [16,25,3];
		p = [61,25,267];
		q = [13,13,2];
		tw_ROM_sel = [1,1,2,2,3,0];
		tw_ROM_addr_step = [16,0,1,0,0,0];  % 256/16  25/25  
	otherwise
		Nf = [4,3,1,1,1,1];
		Nf_PFA = [4,3,1];
		p = [1,1,1];
		q = [1,1,1];
		tw_ROM_sel = [0,0,0,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0]; 
end

end


function [ Nf,Nf_PFA,p,q,tw_ROM_sel,tw_ROM_addr_step,tw_ROM_exp_ceil,tw_ROM_exp_time ] = param_PFA( N )
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
tw_ROM_exp_ceil = zeros(1,6);
tw_ROM_exp_time = zeros(1,6);

switch N
	case 12
		Nf = [4,3,1,1,1,1];
		Nf_PFA = [4,3,1];
		p = [1,3,1];
		q = [1,2,1];
		tw_ROM_sel = [1,3,0,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0]; % 
		tw_ROM_exp_ceil = [1,1,1,1,1,1];  % 
		tw_ROM_exp_time = [1,1,1,1,1,1];  %
	case 24
		Nf = [4,2,3,1,1,1];
		Nf_PFA = [8,3,1];
		p = [2,3,1];
		q = [5,1,1];
		tw_ROM_sel = [1,1,3,0,0,0];
		tw_ROM_addr_step = [32,0,0,0,0,0]; % 256/8  
		tw_ROM_exp_ceil = [2,1,1,1,1,1];  % 2
		tw_ROM_exp_time = [3,1,1,1,1,1];  % 5*5*3   3
	case 36
		Nf = [4,3,3,1,1,1];
		Nf_PFA = [4,9,1];
		p = [7,1,1];
		q = [3,2,1];
		tw_ROM_sel = [1,3,3,0,0,0];
		tw_ROM_addr_step = [0,27,0,0,0,0]; % 243/9
		tw_ROM_exp_ceil = [1,3,1,1,1,1];  % 3 
		tw_ROM_exp_time = [1,1,1,1,1,1];  % 
	case 48
		Nf = [4,4,3,1,1,1];
		Nf_PFA = [16,3,1];
		p = [1,11,1];
		q = [5,2,1];
		tw_ROM_sel = [1,1,3,0,0,0];
		tw_ROM_addr_step = [16,0,0,0,0,0]; % 256/16  
		tw_ROM_exp_ceil = [4,1,1,1,1,1];  % 4 
		tw_ROM_exp_time = [3,1,1,1,1,1];  % 3
	case 60
		Nf = [4,5,3,1,1,1];
		Nf_PFA = [4,5,3];
		p = [4,5,7];
		q = [1,2,1];
		tw_ROM_sel = [1,2,3,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0];
		tw_ROM_exp_ceil = [1,1,1,1,1,1];  %  
		tw_ROM_exp_time = [1,1,1,1,1,1];  %  
	case 72
		Nf = [4,2,3,3,1,1];
		Nf_PFA = [8,9,1];
		p = [8,1,1];
		q = [7,1,1];
		tw_ROM_sel = [1,1,3,3,0,0];
		tw_ROM_addr_step = [32,0,27,0,0,0]; % 256/8 243/9
		tw_ROM_exp_ceil = [2,1,3,1,1,1];  % 2   3 
		tw_ROM_exp_time = [9,1,1,1,1,1];  % 3*3
	case 96
		Nf = [4,4,2,3,1,1];
		Nf_PFA = [32,3,1];
		p = [2,11,1];
		q = [21,1,1];
		tw_ROM_sel = [1,1,1,3,0,0];
		tw_ROM_addr_step = [8,32,0,0,0,0]; % 256/32  256/8 
		tw_ROM_exp_ceil = [8,2,1,1,1,1]; 
		tw_ROM_exp_time = [3,3,1,1,1,1];  
	case 108
		Nf = [4,3,3,3,1,1];
		Nf_PFA = [4,27,1];
		p = [7,3,1];
		q = [1,20,1];
		tw_ROM_sel = [1,3,3,3,0,0];
		tw_ROM_addr_step = [0,9,27,0,0,0]; %
		tw_ROM_exp_ceil = [1,9,3,1,1,1];  % 
		tw_ROM_exp_time = [1,1,1,1,1,1];  %   
	case 120
		Nf = [4,2,5,3,1,1];
		Nf_PFA = [8,5,3];
		p = [2,5,27];
		q = [1,1,2];
		tw_ROM_sel = [1,1,2,3,0,0];
		tw_ROM_addr_step = [32,0,0,0,0,0]; %
		tw_ROM_exp_ceil = [2,1,1,1,1,1];  % 
		tw_ROM_exp_time = [15,1,1,1,1,1];  %   
	case 144
		Nf = [4,4,3,3,1,1];
		Nf_PFA = [16,9,1];
		p = [4,9,1];
		q = [7,5,1];
		tw_ROM_sel = [1,1,3,3,0,0];
		tw_ROM_addr_step = [16,0,27,0,0,0]; %
		tw_ROM_exp_ceil = [4,1,3,1,1,1];  % 
		tw_ROM_exp_time = [9,1,1,1,1,1];  %   
	case 180
		Nf = [4,5,3,3,1,1];
		Nf_PFA = [4,5,9];
		p = [34,29,9];
		q = [3,4,4];
		tw_ROM_sel = [1,2,3,3,0,0];
		tw_ROM_addr_step = [0,0,27,0,0,0]; %
		tw_ROM_exp_ceil = [1,1,3,1,1,1];  % 
		tw_ROM_exp_time = [1,1,1,1,1,1];  %   
	case 192
		Nf = [4,4,4,3,1,1];
		Nf_PFA = [64,3,1];
		p = [1,43,1];
		q = [21,2,1];
		tw_ROM_sel = [1,1,1,3,0,0];
		tw_ROM_addr_step = [4,16,0,0,0,0]; %
		tw_ROM_exp_ceil = [16,4,1,1,1,1];  % 
		tw_ROM_exp_time = [3,3,1,1,1,1];  %   
	case 216
		Nf = [4,2,3,3,3,1];
		Nf_PFA = [8,27,1];
		p = [17,3,1];
		q = [5,10,1];
		tw_ROM_sel = [1,1,3,3,3,0];
		tw_ROM_addr_step = [32,0,9,27,0,0]; %
		tw_ROM_exp_ceil = [2,1,9,3,1,1];  % 
		tw_ROM_exp_time = [27,1,1,1,1,1];  %   
	case 240
		Nf = [4,4,5,3,1,1];
		Nf_PFA = [16,5,3];
		p = [1,29,27];
		q = [1,3,1];
		tw_ROM_sel = [1,1,2,3,0,0];
		tw_ROM_addr_step = [16,0,0,0,0,0]; 
		tw_ROM_exp_ceil = [4,1,1,1,1,1];  % 4 
		tw_ROM_exp_time = [15,1,3,1,1,1];  % 5*3   3
	case 288
		Nf = [4,4,2,3,3,1];
		Nf_PFA = [32,9,1];
		p = [2,25,1];
		q = [7,7,1];
		tw_ROM_sel = [1,1,1,3,3,0];
		tw_ROM_addr_step = [8,32,0,27,0,0]; %
		tw_ROM_exp_ceil = [8,2,1,3,1,1];  % 
		tw_ROM_exp_time = [9,9,1,1,1,1];  %   
	case 300
		Nf = [4,5,5,3,1,1];
		Nf_PFA = [4,25,3];
		p = [19,1,67];
		q = [1,2,2];
		tw_ROM_sel = [1,2,2,3,0,0];
		tw_ROM_addr_step = [0,1,0,0,0,0]; %
		tw_ROM_exp_ceil = [1,5,1,1,1,1];  % 
		tw_ROM_exp_time = [1,3,1,1,1,1];  %   
	case 324
		Nf = [4,3,3,3,3,1];
		Nf_PFA = [4,81,1];
		p = [61,1,1];
		q = [3,20,1];
		tw_ROM_sel = [1,3,3,3,3,0];
		tw_ROM_addr_step = [0,3,9,27,0,0]; %
		tw_ROM_exp_ceil = [1,27,9,3,1,1];  % 
		tw_ROM_exp_time = [1,1,1,1,1,1];  %   
	case 360
		Nf = [4,2,5,3,3,1];
		Nf_PFA = [8,5,9];
		p = [17,29,9];
		q = [3,2,2];
		tw_ROM_sel = [1,1,2,3,3,0];
		tw_ROM_addr_step = [32,0,0,27,0,0]; %
		tw_ROM_exp_ceil = [2,1,1,3,1,1];  % 
		tw_ROM_exp_time = [45,1,1,1,1,1];  %   
	case 384
		Nf = [4,4,4,2,3,1];
		Nf_PFA = [128,3,1];
		p = [2,43,1];
		q = [85,1,1];
		tw_ROM_sel = [1,1,1,1,3,0];
		tw_ROM_addr_step = [2,8,32,0,0,0]; %
		tw_ROM_exp_ceil = [32,8,2,1,1,1];  % 
		tw_ROM_exp_time = [3,3,3,1,1,1];  %   
	case 432
		Nf = [4,4,3,3,3,1];
		Nf_PFA = [16,27,1];
		p = [22,3,1];
		q = [13,5,1];
		tw_ROM_sel = [1,1,3,3,3,0];
		tw_ROM_addr_step = [16,0,9,27,0,0]; %
		tw_ROM_exp_ceil = [4,1,9,3,1,1];  % 
		tw_ROM_exp_time = [27,1,1,1,1,1];  %   
	case 480
		Nf = [4,4,2,5,3,1];
		Nf_PFA = [32,5,3];
		p = [8,77,107];
		q = [17,4,2];
		tw_ROM_sel = [1,1,1,2,3,0];
		tw_ROM_addr_step = [8,32,0,0,0,0]; %
		tw_ROM_exp_ceil = [8,2,1,1,1,1];  % 
		tw_ROM_exp_time = [15,15,1,1,1,1];  %   
	case 540
		Nf = [4,5,3,3,3,1];
		Nf_PFA = [4,5,27];
		p = [34,65,3];
		q = [1,3,4];
		tw_ROM_sel = [1,2,3,3,3,0];
		tw_ROM_addr_step = [0,0,9,27,0,0]; %
		tw_ROM_exp_ceil = [1,1,9,3,1,1];  % 
		tw_ROM_exp_time = [1,1,1,1,1,1];  %   
	case 576
		Nf = [4,4,4,3,3,1];
		Nf_PFA = [64,9,1];
		p = [1,57,1];
		q = [7,8,1];
		tw_ROM_sel = [1,1,1,3,3,0];
		tw_ROM_addr_step = [4,16,0,27,0,0]; %
		tw_ROM_exp_ceil = [16,4,1,3,1,1];  % 
		tw_ROM_exp_time = [9,9,1,1,1,1];  %   
	case 600
		Nf = [4,2,5,5,3,1];
		Nf_PFA = [8,25,3];
		p = [47,1,67];
		q = [5,1,1];
		tw_ROM_sel = [1,1,2,2,3,0];
		tw_ROM_addr_step = [32,0,1,0,0,0]; %
		tw_ROM_exp_ceil = [2,1,5,1,1,1];  % 
		tw_ROM_exp_time = [75,1,3,1,1,1];  %   
	case 648
		Nf = [4,2,3,3,3,3];
		Nf_PFA = [8,81,1];
		p = [71,1,1];
		q = [7,10,1];
		tw_ROM_sel = [1,1,3,3,3,3];
		tw_ROM_addr_step = [32,0,3,9,27,0]; %
		tw_ROM_exp_ceil = [2,1,27,9,3,1];  % 
		tw_ROM_exp_time = [81,1,1,1,1,1];  %   
	case 720
		Nf = [4,4,5,3,3,1];
		Nf_PFA = [16,5,9];
		p = [31,29,9];
		q = [11,1,1];
		tw_ROM_sel = [1,1,2,3,3,0];
		tw_ROM_addr_step = [16,0,0,27,0,0]; %
		tw_ROM_exp_ceil = [4,1,1,3,1,1];  % 
		tw_ROM_exp_time = [45,1,1,1,1,1];  %   
	case 768
		Nf = [4,4,4,4,3,1];
		Nf_PFA = [256,3,1];
		p = [1,171,1];
		q = [85,2,1];
		tw_ROM_sel = [1,1,1,1,3,0];
		tw_ROM_addr_step = [1,4,16,0,0,0]; % 256/256 256/64 256/16
		tw_ROM_exp_ceil = [64,16,4,1,1,1];  % 4*4*4   4*4  4  
		tw_ROM_exp_time = [3,3,3,1,1,1];  % 3   
	case 864
		Nf = [4,4,2,3,3,3];
		Nf_PFA = [32,27,1];
		p = [11,19,1];
		q = [13,16,1];
		tw_ROM_sel = [1,1,1,3,3,3];
		tw_ROM_addr_step = [8,32,0,9,27,0]; % 256/32  256/8   243/27  243/9
		tw_ROM_exp_ceil = [8,2,1,9,3,1];  % 4*2   2    3*3   3 
		tw_ROM_exp_time = [27,27,1,1,1,1];  % 27, 27
	case 900
		Nf = [4,5,5,3,3,1];
		Nf_PFA = [4,25,9];
		p = [169,13,89];
		q = [3,9,8];
		tw_ROM_sel = [1,2,2,3,3,0];
		tw_ROM_addr_step = [0,1,0,27,0,0]; % 25/25   243/9
		tw_ROM_exp_ceil = [1,5,1,3,1,1];  % 5  3 
		tw_ROM_exp_time = [1,9,1,1,1,1];  % 3*3
	case 960
		Nf = [4,4,4,5,3,1];
		Nf_PFA = [64,5,3];
		p = [4,77,107];
		q = [17,2,1];
		tw_ROM_sel = [1,1,1,2,3,0];
		tw_ROM_addr_step = [4,16,64,0,0,0]; % 256/64 256/16 256/4
		tw_ROM_exp_ceil = [16,4,1,1,1,1];  % 4*4  4 
		tw_ROM_exp_time = [15,15,1,1,1,1];  % 5*3
	case 972
		Nf = [4,3,3,3,3,3];
		Nf_PFA = [4,243,1];
		p = [61,3,1];
		q = [243,4,1];
		tw_ROM_sel = [1,3,3,3,3,3];
		tw_ROM_addr_step = [0,1,3,9,27,0]; % 243/243 243/81 243/27 243/9
		tw_ROM_exp_ceil = [1,81,27,9,3,1];  % 3*3*3*3 3*3*3 3*3 3 
		tw_ROM_exp_time = [1,1,1,1,1,1];  % 3*3 
	case 1080
		Nf = [4,2,5,3,3,3];
		Nf_PFA = [8,5,27];
		p = [17,173,3];
		q = [1,4,2];
		tw_ROM_sel = [1,1,2,3,3,3];
		tw_ROM_addr_step = [32,0,0,9,27,0]; % 256/8  243/27  243/9
		tw_ROM_exp_ceil = [2,1,1,9,3,1];  % 2  3*3  3 
		tw_ROM_exp_time = [135,1,1,1,1,1];  % 5*3*3*3
	case 1152
		Nf = [4,4,4,2,3,3];
		Nf_PFA = [128,9,1];
		p = [5,57,1];
		q = [71,4,1];
		tw_ROM_sel = [1,1,1,1,3,3];
		tw_ROM_addr_step = [2,8,32,0,27,0]; % 256/128 256/32 256/8 243/9
		tw_ROM_exp_ceil = [32,8,2,1,3,1];  % 4*4*2   4*2  2  3 
		tw_ROM_exp_time = [9,9,9,1,1,1];  % 3*3   
	case 1200
		Nf = [4,4,5,5,3,1];
		Nf_PFA = [16,25,3];
		p = [61,25,267];
		q = [13,13,2];
		tw_ROM_sel = [1,1,2,2,3,0];
		tw_ROM_addr_step = [16,0,1,0,0,0]; % 256/16  25/25
		tw_ROM_exp_ceil = [4,1,5,1,1,1];  % 4   5 
		tw_ROM_exp_time = [75,1,3,1,1,1];  % 5*5*3   3

	case 1296
		Nf = [4,4,3,3,3,3];
		Nf_PFA = [16,81];
		p = [0,0,0];
		q = [0,0,0];
		tw_ROM_sel = [0,0,0,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0]; % 256/16  25/25
		tw_ROM_exp_ceil = [0,0,0,0,0,0];  % 4   5 
		tw_ROM_exp_time = [0,0,0,0,0,0];  % 5*5*3   3
    case 1536
		Nf = [4,4,4,4,2,3];
		Nf_PFA = [512,3];
		p = [0,0,0];
		q = [0,0,0];
		tw_ROM_sel = [0,0,0,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0]; % 256/16  25/25
		tw_ROM_exp_ceil = [0,0,0,0,0,0];  % 4   5 
		tw_ROM_exp_time = [0,0,0,0,0,0];  % 5*5*3   3
	otherwise
		Nf = [4,3,1,1,1,1];
		Nf_PFA = [4,3,1];
		p = [1,1,1];
		q = [1,1,1];
		tw_ROM_sel = [0,0,0,0,0,0];
		tw_ROM_addr_step = [0,0,0,0,0,0]; 
end

end


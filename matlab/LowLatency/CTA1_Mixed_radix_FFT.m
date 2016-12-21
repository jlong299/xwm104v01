clear 
%-------------------------------------------------------------
% Author : Jiang Long
%                CTA (Cooley-Tukey algorithm )
% Example:
%  For DFT size N = N1*N2*N3  
%
%    n= (N2*N3*n1 + n2~) mod N ,  n1,k1 = 0,1,...,N1-1
%    k= (k1 + N1*k2~) mod N,      n2~,k2~ = 0,1,...,N2*N3-1    (1)
%
%    n2~= (N3*n2 + n3) mod N2*N3,  n2,k2 = 0,1,...,N2-1
%    k2~= (k2 + N2*k3) mod N2*N3,  n3,k3 = 0,1,...,N3-1        (2)
%
%  From (1) and (2) , we get (3)
%     n= (N2*N3*n1 + N3*n2 + n3) mod N,
%     k= (k1 + N1*k2 + N1*N2*k3) mod N,          (3)
%
%  There are 2 RAMs for ping-pong operation, each RAM is divided into 5 banks, each bank size : N_max/4
%  Bank selection:
%     (n1+n2+n3) mod 5
%  Address in bank
%     N3*n2 + n3
%  
%  Bufferfly Computation:
%     Twiddle generation 
%        (1) first stage :  (tw_N)^(n2~*k1) ,  tw_N = exp(-1i*2*pi/N);
%        (2) second stage : (tw_N)^(n3*k2) ,   tw_N = exp(-1i*2*pi/(N2*N3));
%        (3) last stage :   1
%  
%  Notice:
%     N1 and N_last are fixed,  N1=4, N_last=3  (for latency reduction)
%-------------------------------------------------------------
N_max = 1200;  % for N_max = 1536, the RAM bank size should increase to 1536/4
NumOfBanks = 5; % total 5 RAM banks

NumOfFactors_max = 6; % 6 factors at most


%-----------------------------------------
%-------- Loop  from 12 to 1200 ----------
%-----------------------------------------
Nf_temp = zeros(1,NumOfFactors_max-2);
NumOfLen = 0;

%  Loop  from  12*1  to  12*100
for m_len = 1:100   % The end of loop body is at the end of this file
    % factorize  N 
    [Nf_temp, err] = factor_2345(m_len);
    if err==1   % m_len can not be factorized to 2,3,4,5
        continue;
    end

    NumOfLen = NumOfLen+1;    % total 34 different lengths   12, 24, 36, ..., 1152, 1200
%-------- parameters ------------
Nf = ones(1,NumOfFactors_max);   % factorize N
% e.g. If N=1200  = 4*4*5*5*3 = N1*N2*N3*N4*N5
%      Nf(1)=4,  Nf(2)=4,  Nf(3)=5,  Nf(4)=5, Nf(5)=3, Nf(6)=1   ( Nf(1) represents N1 ...)
%      First must be 4,  the last must be 3  (for latency reduction)
%------------------------------
Nf(1) = 4;  % N1 : Fixed =4 !!!
%------------------------------
% Nf(2) = 4;
% Nf(3) = 2;
% Nf(4) = 5;
% Nf(5) = 3;
% Nf(6) = 2;
t = 2;
while (t < NumOfFactors_max)
    if Nf_temp(t-1) > 0
        Nf(t) = Nf_temp(t-1);
        t = t+1;
    else
        break;
    end
end
%----------------------------------
Nf(t) = 3;  % N_last : Fixed =3 !!!
%----------------------------------
t=0;

%  obtain Num of Factors
NumOfFactors = 0;
for m = 1:NumOfFactors_max
    if (Nf(m)>1)
        NumOfFactors = NumOfFactors + 1;
    end
end
%  obtain  N
N = Nf(1)*Nf(2)*Nf(3)*Nf(4)*Nf(5)*Nf(6);

%  obtain ena
ena = zeros(1,NumOfFactors_max);
for m = 1:NumOfFactors_max
    if Nf(m)==1
        ena(m) = 0;
    else
        ena(m) = 1;
    end
end
% e.g. If N=1200  = 4*4*5*5*3,  NumOfFactors=5,  ena=[1,1,1,1,1,0]

% ------------ coeff used to gen address in each bank -----------
%   addr_in_bank = coeff_bank(2)*n(2)+coeff_bank(3)*n(3)+coeff_bank(4)*n(4)+coeff_bank(5)*n(5)+coeff_bank(6)*n(6);
% ------------ change them to one case , not checked yet --------------
coeff_bank = zeros(1,NumOfFactors_max);

coeff_bank(2) = Nf(3)*Nf(4)*Nf(5)*Nf(6);
coeff_bank(3) = Nf(4)*Nf(5)*Nf(6);
coeff_bank(4) = Nf(5)*Nf(6);
coeff_bank(5) = Nf(6);
coeff_bank(6) = 1;

%------------- gen test source data -------------------
x_real=round((2*rand(1,N)-1)*8192);
x_imag=round((2*rand(1,N)-1)*8192);

x = x_real + 1j*x_imag;
% x = [0:1:59];
% x = x.';

FX = fft(x);

%-----------  2 RAMs ping-pong,  each RAM divided into 5 banks ----------
%-----------  currently each bank size is N_max/4  
RAM_0 = zeros(N_max/4,NumOfBanks);  % 5 banks
RAM_1 = zeros(N_max/4,NumOfBanks);  % 5 banks
current_RAM = 0;
RAM_read = zeros(N_max/4,NumOfBanks);  % 5 banks
RAM_write = zeros(N_max/4,NumOfBanks);  % 5 banks

%------------ n1, n2, n3, n4, n5, n6 ---------------------
%------------ n1 range 0,1,...,N1-1    n2 range 0,1,...,N2-1   .....
n = zeros(1,NumOfFactors_max);

carry_in = zeros(1,NumOfFactors_max);
carry_in(NumOfFactors_max) = 1;
carry_out = zeros(1,NumOfFactors_max);

addr_in_bank = 0;
%----------- PART  1  ----------------------------
%----------- I/O input data to RAM ---------------
%----------- code considering RTL structure ------
for t=0:N-1

    % bank selection
    switch_bank = mod( sum(n), NumOfBanks);
    % address in bank
    addr_in_bank = coeff_bank(2)*n(2)+coeff_bank(3)*n(3)+coeff_bank(4)*n(4)+coeff_bank(5)*n(5)+coeff_bank(6)*n(6);
    RAM_0( addr_in_bank +1, switch_bank +1 ) = x(t +1);

    % Accumulator  0 to N-1
    %-------------------------------------------------------
    % when t==0      n1=0, n2=0, ..., n6=0
    % when t==N6-1   n1=0, n2=0, ..., n6=N6-1
    % when t==N6     n1=0, n2=0, ..., n5=1, n6=0
    %  ...
    % when t==N-1    n1=N1-1, n2=N2-1, ..., n5=N5-1, n6=N6-1
    for m = 0: NumOfFactors_max-1
        carry_out_last = 1;

        if ( ena(NumOfFactors_max-m) == 0 )
            carry_out(NumOfFactors_max-m) = 1;
        else
            if ( carry_in(NumOfFactors_max-m) == 1)
                if ( n(NumOfFactors_max-m) == Nf(NumOfFactors_max-m)-1 )
                    carry_out(NumOfFactors_max-m) = 1;
                    n(NumOfFactors_max-m) = 0;
                else
                    carry_out(NumOfFactors_max-m) = 0;
                    n(NumOfFactors_max-m)  = n(NumOfFactors_max-m) + 1;
                end
            else
                n(NumOfFactors_max-m) = n(NumOfFactors_max-m);
                carry_out(NumOfFactors_max-m) = 0;
            end
        end
        if (m < NumOfFactors_max-1)
            carry_in(NumOfFactors_max-m-1) = carry_out_last * carry_out(NumOfFactors_max-m);
            carry_out_last = carry_in(NumOfFactors_max-m-1); 
        end
    end
end

%----------- PART  2  ----------------------------
%----------- computation stages ------------------
%----------- num of stages is NumOfFactors -------
n=zeros(1,NumOfFactors_max);
read_bank_index = zeros(NumOfBanks,1);
read_data_index = zeros(NumOfBanks,1);
fft_tw_out = zeros(NumOfBanks,1);
Nf_stage = Nf;
is_last_stage = 0;
tw_N = exp(-1i*2*pi/N);
tw_N_exp = 0;
%---------------------------------
for m=1:NumOfFactors

    if (current_RAM==0)
        RAM_read = RAM_0;
    else
        RAM_read = RAM_1;
    end

    Nf_stage = Nf;
    Nf_stage(m) = 1;

    if (m==NumOfFactors)
        is_last_stage = 1;
    else
        is_last_stage = 0;
    end

    for t_n1 = 0:Nf_stage(1) -1
        for t_n2 = 0:Nf_stage(2) -1
            for t_n3 = 0:Nf_stage(3) -1
                for t_n4 = 0:Nf_stage(4) -1
                    for t_n5 = 0:Nf_stage(5) -1
                        for t_n6 = 0:Nf_stage(6) -1
                            % bank selection
                            read_bank_index(1) = mod(t_n1+t_n2+t_n3+t_n4+t_n5+t_n6, NumOfBanks);
                            for t = 2:NumOfBanks
                                read_bank_index(t) = mod(read_bank_index(1) + t-1, NumOfBanks);
                            end
                            % read data from each bank
                            for t = 1:NumOfBanks
                                if (t <= Nf(m))
                                addr_in_bank = coeff_bank(2)*t_n2+coeff_bank(3)*t_n3+coeff_bank(4)*t_n4+coeff_bank(5)*t_n5+coeff_bank(6)*t_n6;
                                read_data_index(t) = RAM_read(coeff_bank(m)*(t-1)+addr_in_bank +1, read_bank_index(t) +1);
                                else
                                read_data_index(t) = 0;
                                end
                            end
                            % radix-factor fft and twiddle
                            switch m
                            case 1
                            tw_N_exp = Nf(6)*Nf(5)*Nf(4)*Nf(3)*t_n2+Nf(6)*Nf(5)*Nf(4)*t_n3+Nf(6)*Nf(5)*t_n4+Nf(6)*t_n5+t_n6;
                            case 2
                            tw_N_exp = Nf(6)*Nf(5)*Nf(4)*t_n3+Nf(6)*Nf(5)*t_n4+Nf(6)*t_n5+t_n6;
                            case 3
                            tw_N_exp = Nf(6)*Nf(5)*t_n4+Nf(6)*t_n5+t_n6;
                            case 4
                            tw_N_exp = Nf(6)*t_n5+t_n6;
                            case 5
                            tw_N_exp = t_n6;
                            case 6
                            tw_N_exp = 0;
                            otherwise
                            tw_N_exp = 0;
                            end
                            fft_tw_out = fft_tw(read_data_index, Nf(m), tw_N, tw_N_exp, is_last_stage );
                            % write data to each bank of another RAM
                            for t = 1:NumOfBanks
                                if (t <= Nf(m))
                                addr_in_bank = coeff_bank(2)*t_n2+coeff_bank(3)*t_n3+coeff_bank(4)*t_n4+coeff_bank(5)*t_n5+coeff_bank(6)*t_n6;
                                RAM_write(coeff_bank(m)*(t-1)+addr_in_bank +1, read_bank_index(t) +1) = fft_tw_out(t);
                                end
                            end
                        end
                    end
                end
            end
        end
    end 

    % update twiddle base
    tw_N = (tw_N)^(Nf(m));

    if (current_RAM==0)
        RAM_1 = RAM_write;
        current_RAM = 1;
    else
        RAM_0 = RAM_write;
        current_RAM = 0;
    end

end

%----------- PART  3  (Inverse sequence of PART 1)----------------------------
%----------- I/O output --------------------------
%----------- code considering RTL structure ------
Fout = zeros(N,1);
k = zeros(1,NumOfFactors_max);
carry_in = zeros(1,NumOfFactors_max);
carry_in(1) = 1;
carry_out = zeros(1,NumOfFactors_max);

for t=0:N-1

    switch_bank = mod( sum(k), NumOfBanks);
    
    addr_in_bank = coeff_bank(2)*k(2)+coeff_bank(3)*k(3)+coeff_bank(4)*k(4)+coeff_bank(5)*k(5)+coeff_bank(6)*k(6);
    if (current_RAM==0)
        Fout(t +1) = RAM_0( addr_in_bank +1, switch_bank +1 );
    else
        Fout(t +1) = RAM_1( addr_in_bank +1, switch_bank +1 );
    end

    for m = 0: NumOfFactors_max-1
        carry_out_last = 1;

        if ( ena(m+1) == 0 )
            k(m+1) = 0;
        else
            if ( carry_in(m+1) == 1)
                if ( k(m+1) == Nf(m+1)-1 )
                    carry_out(m+1) = 1;
                    k(m+1) = 0;
                else
                    carry_out(m+1) = 0;
                    k(m+1)  = k(m+1) + 1;
                end
            else
                k(m+1) = k(m+1);
                carry_out(m+1) = 0;
            end
        end
        if (m < NumOfFactors_max-1)
            carry_in(m+2) = carry_out_last * carry_out(m+1);
            carry_out_last = carry_in(m+1); 
        end
    end

end

% result
N
max(abs(Fout-FX.'))
size(RAM_read)
size(RAM_write)

end
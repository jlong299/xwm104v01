clear 
% 2017.1.25 Changed to CTA algorithm
%--------------------------------------------------
% Combined PFA & CTA algorithm
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
%  (why N_max/4 ?  because the first factor 4 is fixed)
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
%
%----------------------------------------------------------------------------------
%                   PFA (Prime factor algorithm)
% Example:
%   for DFT size N = N1*N2*N3       N1=2^a, N2=5^b, N3=3^c
%
%     n= (N2*N3*n1 + A1*n2~) mod N   n1,k1 = 0,1,...,N1-1
%     k= (B1*k1 + N1*k2~) mod N      n2~,k2~ = 0,1,...,N2*N3-1     (11)
%
%     n2~= (N3*n2 + A2*n3) mod N2*N3,  n2,k2 = 0,1,...,N2-1
%     k2~= (B2*k2 + N2*k3) mod N2*N3,  n3,k3 = 0,1,...,N3-1        (12)
%
%     In the case of CTA, A1=B1=A2=B2=1
%     In the case of PFA:
%        p1*N1 = q1*N2*N3 + 1
%        p2*N2 = q2*N1*N3 + 1
%        p3*N3 = q3*N1*N2 + 1           (13)
%
%   Then we get (14) (15) from  (11) (12) (13) 
%     n = (N2*N3*n1 + p1*N1*N3*n2 + p1*p2*N2*N3*n3) mod N    (14)
%     k = (p2*p3*N2*N3*k1 + p3*N1*N3*k2 + N1*N2*k3) mod N    (15)
%
%-------------------------------------------------------------
N_max = 1200;  % for N_max = 1536, the RAM bank size should increase to 1536/7
NumOfBanks = 7; % total 7 RAM banks

NumOfFactors_max = 6; % 6 factors at most


%-----------------------------------------
%-------- Loop  from 12 to 1200 ----------
%-----------------------------------------
Nf_temp = zeros(1,NumOfFactors_max-2);
NumOfLen = 0;

%  Loop  from  12*1  to  12*100
for m_len = 100:100   % The end of loop body is at the end of this file
    % factorize  N 
    [Nf_temp, err] = factor_2345(m_len);
    if err==1   % m_len can not be factorized to 2,3,4,5
        continue;
    end

    NumOfLen = NumOfLen+1;    % total 34 different lengths   12, 24, 36, ..., 1152, 1200

% %-------- parameters ------------
[ Nf,Nf_PFA,p,q,tw_ROM_sel,tw_ROM_addr_step,tw_ROM_exp_ceil,tw_ROM_exp_time ] = param_PFA( 12*m_len );
% Only Nf is useful in CTA !!

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

%------------- gen test source data -------------------
x_real=round((2*rand(1,N)-1)*2048);
x_imag=round((2*rand(1,N)-1)*2048);

x = x_real + 1j*x_imag;
% x = [0:1:1199];
% x = x + x*(1i);

outf = fopen('../../modelsim/dft_src.dat','w');
for k = 1 : length(x_real)
    fprintf(outf , '%d %d\n' , real(x(k)), imag(x(k)));
end
fclose(outf);

FX = fft(x);

%-----------  2 RAMs ping-pong,  each RAM divided into 7 banks ----------
RAM_0 = zeros(ceil(N_max/NumOfBanks),NumOfBanks);  % 7 banks
RAM_1 = zeros(ceil(N_max/NumOfBanks),NumOfBanks);  % 7 banks
current_RAM = 0;
RAM_read = zeros(ceil(N_max/NumOfBanks),NumOfBanks);  % 7 banks
RAM_write = zeros(ceil(N_max/NumOfBanks),NumOfBanks);  % 7 banks

% %------------  PFA I/O input mapping ------------------------------
% for n1=0:Nf_PFA(1)-1
%     for n2=0:Nf_PFA(2)-1
%         for n3=0:Nf_PFA(3)-1
%             x_PFAmap(Nf_PFA(2)*Nf_PFA(3)*n1+Nf_PFA(3)*n2+n3 +1) = x(mod(Nf_PFA(2)*Nf_PFA(3)*n1+p(1)*Nf_PFA(1)*Nf_PFA(3)*n2+p(1)*p(2)*Nf_PFA(1)*Nf_PFA(2)*n3, N) +1);
%         end
%     end
% end

%------------ n1, n2, n3, n4, n5, n6 ---------------------
%------------ n1 range 0,1,...,N1-1    n2 range 0,1,...,N2-1   .....
n = zeros(1,NumOfFactors_max);

addr_in_bank = 0;
%----------- PART  1  ----------------------------
%----------- I/O input data to RAM ---------------
%----------- code considering RTL structure ------
for t=0:N-1

    % bank selection
    switch_bank = mod( t, NumOfBanks );
    % address in bank
    addr_in_bank = (t-switch_bank)/NumOfBanks;

    RAM_0( addr_in_bank +1, switch_bank +1 ) = x(t +1);

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
tw_N_exp = 0;

sum_addr_coeff = zeros(1,NumOfFactors_max);
fft_out_reg = zeros(1200,1);
%---------------------------------
for m=1:NumOfFactors
    fft_out_reg  = zeros(1200,1);
    
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

    cnt_debug = 0;

    for t_n1 = 0:Nf_stage(1) -1
        for t_n2 = 0:Nf_stage(2) -1
            for t_n3 = 0:Nf_stage(3) -1
                for t_n4 = 0:Nf_stage(4) -1
                    for t_n5 = 0:Nf_stage(5) -1
                        for t_n6 = 0:Nf_stage(6) -1
                            % bank selection
                            sum_addr_coeff(1) = Nf(2)*Nf(3)*Nf(4)*Nf(5)*Nf(6);
                            sum_addr_coeff(2) = Nf(3)*Nf(4)*Nf(5)*Nf(6);
                            sum_addr_coeff(3) = Nf(4)*Nf(5)*Nf(6);
                            sum_addr_coeff(4) = Nf(5)*Nf(6);
                            sum_addr_coeff(5) = Nf(6);
                            sum_addr_coeff(6) = 1;
                            sum_addr = sum( [t_n1,t_n2,t_n3,t_n4,t_n5,t_n6].*sum_addr_coeff);

                            for t = 1:NumOfBanks
                                read_bank_index(t) = mod(sum_addr + sum_addr_coeff(m)*(t-1), NumOfBanks);
                            end
                            % read data from each bank
                            for t = 1:NumOfBanks
                                if (t <= Nf(m))
                                addr_in_bank = floor((sum_addr + sum_addr_coeff(m)*(t-1)) / NumOfBanks);
                                read_data_index(t) = RAM_read(addr_in_bank +1, read_bank_index(t) +1);
                                else
                                read_data_index(t) = 0;
                                end
                            end

                            if (m==1)
                                tw_base = N;
                            else
                                tw_base = sum_addr_coeff(m-1);
                            end

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

                            for t = 1:5
                                tw_coeff(t) = exp(-1i*2*pi* (t-1)*(tw_N_exp)/tw_base);
                            end
                                
                            fft_tw_out = fft_tw2(read_data_index(1:5), Nf(m), tw_coeff, is_last_stage );
                            %fft_tw_out = read_data_index(1:5);
                            fft_out_int32 = int32(fft_tw_out);
                        
                            cnt_debug = cnt_debug+1;
                            if ( (cnt_debug<=2 || cnt_debug >= 399) && m==5 )
                                cnt_debug = cnt_debug;
                            end
                            
                            fft_out_reg(cnt_debug*5-4 : cnt_debug*5,1) = fft_out_int32(1:5);
                            fft_out_reg = int32(fft_out_reg);
                            
                            % write data to each bank of another RAM
                            for t = 1:NumOfBanks
                                if (t <= Nf(m))
                                addr_in_bank = floor((sum_addr + sum_addr_coeff(m)*(t-1)) / NumOfBanks);
                                RAM_write(addr_in_bank +1, read_bank_index(t) +1) = fft_tw_out(t);
                                end
                            end
                        end
                    end
                end
            end
        end
    end 

    % update twiddle base
    %tw_N = (tw_N)^(Nf(m));

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

    % switch_bank = mod( sum(k), NumOfBanks);
    
    % addr_in_bank = coeff_bank(2)*k(2)+coeff_bank(3)*k(3)+coeff_bank(4)*k(4)+coeff_bank(5)*k(5)+coeff_bank(6)*k(6);

    % % bank selection
    % switch_bank = mod( t, NumOfBanks );
    % % address in bank
    % addr_in_bank = (t-switch_bank)/NumOfBanks;

    sum_addr_coeff(1) = Nf(2)*Nf(3)*Nf(4)*Nf(5)*Nf(6);
    sum_addr_coeff(2) = Nf(3)*Nf(4)*Nf(5)*Nf(6);
    sum_addr_coeff(3) = Nf(4)*Nf(5)*Nf(6);
    sum_addr_coeff(4) = Nf(5)*Nf(6);
    sum_addr_coeff(5) = Nf(6);
    sum_addr_coeff(6) = 1;
    sum_addr = sum( [k(1),k(2),k(3),k(4),k(5),k(6)].*sum_addr_coeff);

    switch_bank = mod( sum_addr, NumOfBanks );
    addr_in_bank = (sum_addr-switch_bank)/NumOfBanks;
    
    if (current_RAM==0)
        Fout(t +1) = RAM_0( addr_in_bank +1, switch_bank +1 );
    else
        Fout(t +1) = RAM_1( addr_in_bank +1, switch_bank +1 );
    end


    %--------  Inverse sequence --------------
    %  k1, k2, k3, k4, k5, k6
    %  0,  0,  0,  0,  0,  0
    %  1,  0,  0,  0,  0,  0
    %  2,  0,  0,  0,  0,  0
    %  ....
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

%------------  PFA I/O output mapping ------------------------------
% Fout_PFAmap = zeros(N,1);

% for k1=0:Nf_PFA(1)-1
%     for k2=0:Nf_PFA(2)-1
%         for k3=0:Nf_PFA(3)-1
%             % Fout_PFAmap(mod(p(2)*p(3)*Nf_PFA(2)*Nf_PFA(3)*k1 + p(3)*Nf_PFA(1)*Nf_PFA(3)*k2 + Nf_PFA(1)*Nf_PFA(2)*k3 , N) +1) = Fout(Nf_PFA(2)*Nf_PFA(3)*k1+Nf_PFA(3)*k2+k3 +1);
%             Fout_PFAmap(mod(p(2)*p(3)*Nf_PFA(2)*Nf_PFA(3)*k1 + p(3)*Nf_PFA(1)*Nf_PFA(3)*k2 + Nf_PFA(1)*Nf_PFA(2)*k3 , N) +1) = Fout(Nf_PFA(1)*Nf_PFA(2)*k3+Nf_PFA(1)*k2+k1 +1);
%         end
%     end
% end

% result
N
% max(abs(Fout-FX.'))
max(abs(Fout-FX.'))
% size(RAM_read)
% size(RAM_write)

end
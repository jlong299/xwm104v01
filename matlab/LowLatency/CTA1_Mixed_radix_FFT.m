clear 
%----------------------------------
N_max = 1200;
NumOfBanks = 5;

% NumOfFactors = 6;   
NumOfFactors_max = 6;

%-----------------------------------------
%-------- Loop  from 12 to 1200 ----------
%-----------------------------------------
Nf_temp = zeros(1,NumOfFactors_max-2);
NumOfLen = 0;
for m_len = 1:100   % The end of loop body is at the end of this file
    % factorize  N 
    [Nf_temp, err] = factor_2345(m_len);
    if err==1
        continue;
    end

    NumOfLen = NumOfLen+1;
%-------- parameters ------------
Nf = ones(1,NumOfFactors_max);   % factorize N
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
Nf(t) = 3;
t=0;

NumOfFactors = 0;
for m = 1:NumOfFactors_max
    if (Nf(m)>1)
        NumOfFactors = NumOfFactors + 1;
    end
end

N = Nf(1)*Nf(2)*Nf(3)*Nf(4)*Nf(5)*Nf(6);

ena = zeros(1,NumOfFactors_max);
for m = 1:NumOfFactors_max
    if Nf(m)==1
        ena(m) = 0;
    else
        ena(m) = 1;
    end
end

coeff_bank = zeros(1,NumOfFactors_max);
switch NumOfFactors
    case 2
        coeff_bank(2) = 1;
    case 3
        coeff_bank(2) = Nf(3);
        coeff_bank(3) = 1;
    case 4
        coeff_bank(2) = Nf(3)*Nf(4);
        coeff_bank(3) = Nf(4);
        coeff_bank(4) = 1;
    case 5
        coeff_bank(2) = Nf(3)*Nf(4)*Nf(5);
        coeff_bank(3) = Nf(4)*Nf(5);
        coeff_bank(4) = Nf(5);
        coeff_bank(5) = 1;
    case 6
        coeff_bank(2) = Nf(3)*Nf(4)*Nf(5)*Nf(6);
        coeff_bank(3) = Nf(4)*Nf(5)*Nf(6);
        coeff_bank(4) = Nf(5)*Nf(6);
        coeff_bank(5) = Nf(6);
        coeff_bank(6) = 1;
    otherwise
        coeff_bank(2) = 1;
end

%--------------------------------
x_real=round((2*rand(1,N)-1)*8192);
x_imag=round((2*rand(1,N)-1)*8192);

x = x_real + 1j*x_imag;
% x = [0:1:59];
% x = x.';

FX = fft(x);

RAM_0 = zeros(N_max/4,NumOfBanks);  % 5 banks
RAM_1 = zeros(N_max/4,NumOfBanks);  % 5 banks
current_RAM = 0;
RAM_read = zeros(N_max/4,NumOfBanks);  % 5 banks
RAM_write = zeros(N_max/4,NumOfBanks);  % 5 banks
%---------------------------------
n = zeros(1,NumOfFactors_max);

carry_in = zeros(1,NumOfFactors_max);
carry_in(NumOfFactors_max) = 1;
carry_out = zeros(1,NumOfFactors_max);

addr_in_bank = 0;
%----------- I/O input data to RAM ---------------
for t=0:N-1

    switch_bank = mod( sum(n), NumOfBanks);
    % RAM_0( Nf(2)*n(1)+n(2) +1, switch_bank +1 ) = x(m +1);
    addr_in_bank = coeff_bank(2)*n(2)+coeff_bank(3)*n(3)+coeff_bank(4)*n(4)+coeff_bank(5)*n(5)+coeff_bank(6)*n(6);
    RAM_0( addr_in_bank +1, switch_bank +1 ) = x(t +1);

    % Accumulator  0 to N-1
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

%----------------------------------
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

    tw_N = (tw_N)^(Nf(m));

    if (current_RAM==0)
        RAM_1 = RAM_write;
        current_RAM = 1;
    else
        RAM_0 = RAM_write;
        current_RAM = 0;
    end

end

%--------- I/O output ---------------
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
% N
% max(abs(Fout-FX.'))
size(RAM_read)
size(RAM_write)

end
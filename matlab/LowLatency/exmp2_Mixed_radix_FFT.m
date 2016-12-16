clear 
%----------------------------------
N_max = 1200;
NumOfBanks = 5;

NumOfFactors = 3;   % Time of iterations
NumOfFactors_max = 6;
%-------- parameters ------------
Nf = zeros(1,NumOfFactors_max);   % factorize N
Nf(1) = 5;
Nf(2) = 3;
Nf(3) = 4;
Nf(4) = 1;
Nf(5) = 1;
Nf(6) = 1;

N = Nf(1)*Nf(2)*Nf(3)*Nf(4)*Nf(5)*Nf(6);
%--------------------------------
x_real=round((2*rand(1,N)-1)*8192);
x_imag=round((2*rand(1,N)-1)*8192);

x = x_real + 1j*x_imag;
% x = [0:1:59];
% x = x.';

FX = fft(x);

RAM_0 = zeros(N_max/NumOfBanks,NumOfBanks);  % 5 banks
RAM_1 = zeros(N_max/NumOfBanks,NumOfBanks);  % 5 banks
current_RAM = 0;
RAM_read = zeros(N_max/NumOfBanks,NumOfBanks);  % 5 banks
RAM_write = zeros(N_max/NumOfBanks,NumOfBanks);  % 5 banks
%---------------------------------
n = zeros(1,NumOfFactors_max);
n(1) = 0;   % 0,1,...,Nf(1)-1
n(2) = 0;   % 0,1,...,Nf(2)-1
n(3) = 0;   % 0,1,...,Nf(3)-1
n(4) = 0;   % 0,1,...,Nf(4)-1
n(5) = 0;   % 0,1,...,Nf(5)-1
n(6) = 0;   % 0,1,...,Nf(6)-1

k = zeros(1,NumOfFactors_max);
%----------- I/O input data to RAM ---------------
for m=0:N-1

    switch_bank = mod( sum(n), NumOfBanks);
    RAM_0( Nf(2)*n(1)+n(2) +1, switch_bank +1 ) = x(m +1);

    % Accumulator  0 to N-1
    if ( n(3) == Nf(3)-1 ) && ( n(2) == Nf(2)-1 ) 
        n(1) = n(1) + 1;
        n(2) = 0;
        n(3) = 0;
    elseif ( n(3) == Nf(3)-1 )
        n(2) = n(2) + 1;
        n(3) = 0;
    else
        n(3) = n(3) + 1;
    end
end

%----------------------------------
n=zeros(1,NumOfFactors_max);
read_bank_index = zeros(NumOfBanks,1);
read_data_index = zeros(NumOfBanks,1);
fft_tw_out = zeros(NumOfBanks,1);
%---------------------------------
for m=1:NumOfFactors

    if (current_RAM==0)
        RAM_read = RAM_0;
    else
        RAM_read = RAM_1;
    end

    if m==1
        tw_N = exp(-j*2*pi/N);
    for t_n2=0:Nf(2)-1
        for t_n3=0:Nf(3)-1
            n(2) = t_n2;
            n(3) = t_n3;

            % bank selection
            read_bank_index(1) = mod(0+n(3)+n(2), NumOfBanks);
            for t = 2:NumOfBanks
                read_bank_index(t) = mod(read_bank_index(1) + t-1, NumOfBanks);
            end
            % read data from each bank
            for t = 1:NumOfBanks
                read_data_index(t) = RAM_read((t-1)*Nf(2)+n(2) +1 , read_bank_index(t) +1);
            end
            % radix-factor fft and twiddle
            fft_tw_out = fft_tw(read_data_index, Nf(m), tw_N, n(2)*Nf(3)+n(3), 0 );
            % write data to each bank of another RAM
            for t = 1:NumOfBanks
                RAM_write((t-1)*Nf(2)+n(2) +1 , read_bank_index(t) +1) = fft_tw_out(t);
            end
        end
    end
    end

    if m==2
        tw_N = exp(-j*2*pi/Nf(2)/Nf(3));
    for t_k1=0:Nf(1)-1
        for t_n3=0:Nf(3)-1
            k(1) = t_k1;
            n(3) = t_n3;

            % bank selection
            read_bank_index(1) = mod(0+n(3)+k(1), NumOfBanks);
            for t = 2:NumOfBanks
                read_bank_index(t) = mod(read_bank_index(1) + t-1, NumOfBanks);
            end
            % read data from each bank
            for t = 1:NumOfBanks
                read_data_index(t) = RAM_read(k(1)*Nf(2)+(t-1) +1, read_bank_index(t) +1);
            end
            % radix-factor fft and twiddle
            fft_tw_out = fft_tw(read_data_index, Nf(m), tw_N, n(3), 0 );
            % write data to each bank of another RAM
            for t = 1:NumOfBanks
                RAM_write(k(1)*Nf(2)+(t-1) +1, read_bank_index(t) +1) = fft_tw_out(t);
            end
        end
    end
    end

    if m==3
            tw_N = exp(-j*2*pi/Nf(3));
    for t_k1=0:Nf(1)-1
        for t_k2=0:Nf(2)-1
            k(1) = t_k1;
            k(2) = t_k2;

            % bank selection
            read_bank_index(1) = mod(0+k(2)+k(1), NumOfBanks);
            for t = 2:NumOfBanks
                read_bank_index(t) = mod(read_bank_index(1) + t-1, NumOfBanks);
            end
            % read data from each bank
            for t = 1:NumOfBanks
                read_data_index(t) = RAM_read(k(1)*Nf(2)+k(2) +1, read_bank_index(t) +1);
            end
            % radix-factor fft and twiddle
            fft_tw_out = fft_tw(read_data_index, Nf(m), tw_N, 1, 1 );
            % write data to each bank of another RAM
            for t = 1:NumOfBanks
                RAM_write(k(1)*Nf(2)+k(2) +1, read_bank_index(t) +1) = fft_tw_out(t);
            end
        end
    end
    end


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
for m=0:N-1

    switch_bank = mod( sum(k), NumOfBanks);

    if (current_RAM==0)
        Fout(m +1) = RAM_0( Nf(2)*k(1)+k(2) +1, switch_bank +1 );
    else
        Fout(m +1) = RAM_1( Nf(2)*k(1)+k(2) +1, switch_bank +1 );
    end

    % Accumulator  0 to N-1
    if ( k(1) == Nf(1)-1 ) && ( k(2) == Nf(2)-1 ) 
        k(3) = k(3) + 1;
        k(2) = 0;
        k(1) = 0;
    elseif ( k(1) == Nf(1)-1 )
        k(2) = k(2) + 1;
        k(1) = 0;
    else
        k(1) = k(1) + 1;
    end
end

% result
max(abs(Fout-FX.'))





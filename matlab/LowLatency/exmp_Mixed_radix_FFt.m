clear 
%----------------------------------
N_max = 1200;
NumOfBanks = 5;

N = 3*4*5;
NumOfFactors = 3;   % Time of iterations
NumOfFactors_max = 6;
%-------- parameters ------------
Nf = zeros(1,NumOfFactors_max);   % factorize N
Nf(1) = 3;
Nf(2) = 4;
Nf(3) = 5;
Nf(4) = 1;
Nf(5) = 1;
Nf(6) = 1;
%--------------------------------
% x_real=round((2*rand(1,N)-1)*8192);
% x_imag=round((2*rand(1,N)-1)*8192);

% x = x_real + 1j*x_imag;
x = [0:1:59];

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

%----------- I/O input data to RAM ---------------
for k=0:N-1

    switch_bank = mod( sum(n), NumOfBanks);
    RAM_0( Nf(2)*n(1)+n(2) +1, switch_bank +1 ) = x(k +1);

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

%---------------------------------
for k=1:NumOfFactors

    if (current_RAM==0)
        RAM_read = RAM_0;
    else
        RAM_read = RAM_1;
    end

    for m = 


    end


    if (current_RAM==0)
        RAM_1 = RAM_write;
        current_RAM = 1;
    else
        RAM_0 = RAM_write;
        current_RAM = 0;
    end


end




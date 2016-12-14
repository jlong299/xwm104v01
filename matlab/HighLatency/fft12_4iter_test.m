clear 
N = 2*3*4*5;
sum_debug=0;

x_real=round((2*rand(1,N)-1)*8192);
x_imag=round((2*rand(1,N)-1)*8192);

x = x_real + 1j*x_imag;

FX = fft(x);

RAM_in = zeros(N,1);
RAM_out = zeros(N,1);

%% radix2,3,4,5 matrix
rdx3 = zeros(5,5);
rdx3(1,1) = 1;
rdx3(2,1) = 1;
rdx3(3,1) = 1;
rdx3(1,2) = 1;
rdx3(1,3) = 1;
rdx3(2,2) = exp(-j*2*pi/3);
rdx3(3,3) = exp(-j*2*pi/3);
rdx3(3,2) = exp(-j*4*pi/3);
rdx3(2,3) = exp(-j*4*pi/3);

W5 = exp(-j*2*pi/5);
rdx5 = zeros(5,5);
rdx5(:,1) = ones(5,1);
rdx5(:,2) = [W5^0;W5^1;W5^2;W5^3;W5^4];
rdx5(:,3) = rdx5(:,2).^2;
rdx5(:,4) = rdx5(:,2).^3;
rdx5(:,5) = rdx5(:,2).^4;

W4 = exp(-j*2*pi/4);
rdx4 = zeros(5,5);
rdx4(:,1) = [ones(4,1);0];
rdx4(:,2) = [W4^0;W4^1;W4^2;W4^3;0];
rdx4(:,3) = rdx4(:,2).^2;
rdx4(:,4) = rdx4(:,2).^3;

W2 = exp(-j*2*pi/2);
rdx2 = zeros(5,5);
rdx2(:,1) = [ones(2,1);0;0;0];
rdx2(:,2) = [W2^0;W2^1;0;0;0];

%% 0st iteration
%-------- parameters ------------
W = exp(-j*2*pi/N);

sector_size1 = N;
sector1 = 1;
sector_size2 = 60;
sector2 = 2;
sector_size3 = 20;
sector3 = 6;
sector_size4 = 5;
sector4 = 24;

factor1 = 2;
factor2 = 3;
factor3 = 4;
factor4 = 5;

team1 = 3*4*5;
team2 = 4*5;  % N/factor1
team3 = 5;
team4 = 1;  
%--------------------------------

RAM_in = x.';
%sum(RAM_in)

for p = 1:sector1

for k=1:team1

    twdl = zeros(5,1);

    for m=1:factor1
        rd_RAM = RAM_in( k-1 + team1*(m-1) +1);
        twdl(1) = twdl(1) + rd_RAM * rdx2(m,1);
        twdl(2) = twdl(2) + rd_RAM * rdx2(m,2);
        twdl(3) = twdl(3) + rd_RAM * rdx2(m,3);
        twdl(4) = twdl(4) + rd_RAM * rdx2(m,4);
        twdl(5) = twdl(5) + rd_RAM * rdx2(m,5);
    end

    % coefficients read from ROM
    coeff(1) = W^(0*(k-1));
    coeff(2) = W^(1*(k-1));
    coeff(3) = 0;
    coeff(4) = 0;
    coeff(5) = 0;

    % factor1 & team1
    % 1
    wr_RAM = twdl(1)*coeff(1);
    RAM_out( team1*0 + (k-1) +1) = wr_RAM;
    % factor1    
    wr_RAM = twdl(2)*coeff(2);
    RAM_out( team1*1 + (k-1) +1) = wr_RAM;

end

end

%% 1st iteration
%-------- parameters ------------
W = exp(-j*2*pi/team1);

% cycle shift
sector_size_t = sector_size1;
sector_t = sector1;
sector_size1 = sector_size2;
sector1 = sector2;
sector_size2 = sector_size3;
sector2 = sector3;
sector_size3 = sector_size4;
sector3 = sector4;
sector_size4 = sector_size_t;
sector4 = sector_t;

% cycle shift
factor_t = factor1;
factor1 = factor2;
factor2 = factor3;
factor3 = factor4;
factor4 = factor_t;

% cycle shift
team_t = team1;
team1 = team2;
team2 = team3;
team3 = team4;
team4 = team_t;
%--------------------------------

RAM_in = RAM_out;
%sum(RAM_in)

for p = 1:sector1

for k=1:team1

    twdl = zeros(5,1);

    for m=1:factor1
        rd_RAM = RAM_in( k-1 + team1*(m-1) + (p-1)*sector_size1 +1);
        twdl(1) = twdl(1) + rd_RAM * rdx3(m,1);
        twdl(2) = twdl(2) + rd_RAM * rdx3(m,2);
        twdl(3) = twdl(3) + rd_RAM * rdx3(m,3);
        twdl(4) = twdl(4) + rd_RAM * rdx3(m,4);
        twdl(5) = twdl(5) + rd_RAM * rdx3(m,5);
    end

    % coefficients read from ROM
    coeff(1) = W^(0*(k-1));
    coeff(2) = W^(1*(k-1));
    coeff(3) = W^(2*(k-1));
    coeff(4) = 0;
    coeff(5) = 0;

    % factor1 & team1
    % 1
        wr_RAM = twdl(1)*coeff(1);
        RAM_out( team1*0 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 2    
        wr_RAM = twdl(2)*coeff(2);
        RAM_out( team1*1 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 3   
        wr_RAM = twdl(3)*coeff(3);
        RAM_out( team1*2 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
    %sum_debug = sum_debug + twdl(1);

end

end

%% 2nd iteration
%-------- parameters ------------
W = exp(-j*2*pi/team1);

% cycle shift
sector_size_t = sector_size1;
sector_t = sector1;
sector_size1 = sector_size2;
sector1 = sector2;
sector_size2 = sector_size3;
sector2 = sector3;
sector_size3 = sector_size4;
sector3 = sector4;
sector_size4 = sector_size_t;
sector4 = sector_t;

% cycle shift
factor_t = factor1;
factor1 = factor2;
factor2 = factor3;
factor3 = factor4;
factor4 = factor_t;

% cycle shift
team_t = team1;
team1 = team2;
team2 = team3;
team3 = team4;
team4 = team_t;
%--------------------------------

RAM_in = RAM_out;

for p = 1:sector1

    for k=1:team1

        twdl = zeros(5,1);

        % factor1 = 4 now

        for m=1:factor1
            rd_RAM = RAM_in( k-1 + team1*(m-1) + (p-1)*sector_size1 +1);
            twdl(1) = twdl(1) + rd_RAM * rdx4(m,1);
            twdl(2) = twdl(2) + rd_RAM * rdx4(m,2);
            twdl(3) = twdl(3) + rd_RAM * rdx4(m,3);
            twdl(4) = twdl(4) + rd_RAM * rdx4(m,4);
            twdl(5) = twdl(5) + rd_RAM * rdx4(m,5);
        end

        % coefficients read from ROM
        coeff(1) = W^(0*(k-1));
        coeff(2) = W^(1*(k-1));
        coeff(3) = W^(2*(k-1));
        coeff(4) = W^(3*(k-1));
        coeff(5) = 0;

        % factor1 & team1
        % 1
        wr_RAM = twdl(1)*coeff(1);
        RAM_out( team1*0 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 2    
        wr_RAM = twdl(2)*coeff(2);
        RAM_out( team1*1 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 3   
        wr_RAM = twdl(3)*coeff(3);
        RAM_out( team1*2 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % factor1    
        wr_RAM = twdl(4)*coeff(4);
        RAM_out( team1*3 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;

        %sum_debug = sum_debug + twdl(1);

    end

end

%% 3rd iteration
%-------- parameters ------------
W = exp(-j*2*pi/team1);

% cycle shift
sector_size_t = sector_size1;
sector_t = sector1;
sector_size1 = sector_size2;
sector1 = sector2;
sector_size2 = sector_size3;
sector2 = sector3;
sector_size3 = sector_size4;
sector3 = sector4;
sector_size4 = sector_size_t;
sector4 = sector_t;

% cycle shift
factor_t = factor1;
factor1 = factor2;
factor2 = factor3;
factor3 = factor4;
factor4 = factor_t;

% cycle shift
team_t = team1;
team1 = team2;
team2 = team3;
team3 = team4;
team4 = team_t;
%--------------------------------

RAM_in = RAM_out;

for p = 1:sector1

    for k=1:team1

        twdl = zeros(5,1);

        % factor1 = 5 now

        for m=1:factor1
            rd_RAM = RAM_in( k-1 + team1*(m-1) + (p-1)*sector_size1 +1);
            twdl(1) = twdl(1) + rd_RAM * rdx5(m,1);
            twdl(2) = twdl(2) + rd_RAM * rdx5(m,2);
            twdl(3) = twdl(3) + rd_RAM * rdx5(m,3);
            twdl(4) = twdl(4) + rd_RAM * rdx5(m,4);
            twdl(5) = twdl(5) + rd_RAM * rdx5(m,5);
        end

        % The last iteration
        coeff(1) = 1;
        coeff(2) = 1;
        coeff(3) = 1;
        coeff(4) = 1;
        coeff(5) = 1;

        % factor1 & team1
        % 1
        wr_RAM = twdl(1)*coeff(1);
        RAM_out( team1*0 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 2    
        wr_RAM = twdl(2)*coeff(2);
        RAM_out( team1*1 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 3    
        wr_RAM = twdl(3)*coeff(3);
        RAM_out( team1*2 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % 4    
        wr_RAM = twdl(4)*coeff(4);
        RAM_out( team1*3 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;
        % factor1    
        wr_RAM = twdl(5)*coeff(5);
        RAM_out( team1*4 + (k-1) + (p-1)*sector_size1 +1) = wr_RAM;

        %sum_debug = sum_debug + twdl(1);

    end

end

RAM_out1 = RAM_out;
RAM_out2 = RAM_out;

%% 1st inverse address iteration
%----------  parameters -----------
% inverse cycle shift
sector_size_t = sector_size1;
sector_t = sector1;
sector_size1 = sector_size4;
sector1 = sector4;
sector_size4 = sector_size3;
sector4 = sector3;
sector_size3 = sector_size2;
sector3 = sector2;
sector_size2 = sector_size_t;
sector2 = sector_t;

% inverse cycle shift
factor_t = factor1;
factor1 = factor4;
factor4 = factor3;
factor3 = factor2;
factor2 = factor_t;

% inverse cycle shift
team_t = team1;
team1 = team4;
team4 = team3;
team3 = team2;
team2 = team_t;
%--------------------------------
inc = 1;

for p = 1:sector1

    for m = 1:factor1

        for k = 1:team1

            RAM_out2( sector_size1*(p-1) + m-1 + factor1*(k-1) +1) = RAM_out1( inc );
            inc = inc+1;

        end
    end
end

RAM_out1 = RAM_out2;

%% 2nd inverse address iteration
%----------  parameters -----------
% inverse cycle shift
sector_size_t = sector_size1;
sector_t = sector1;
sector_size1 = sector_size4;
sector1 = sector4;
sector_size4 = sector_size3;
sector4 = sector3;
sector_size3 = sector_size2;
sector3 = sector2;
sector_size2 = sector_size_t;
sector2 = sector_t;

% inverse cycle shift
factor_t = factor1;
factor1 = factor4;
factor4 = factor3;
factor3 = factor2;
factor2 = factor_t;

% inverse cycle shift
team_t = team1;
team1 = team4;
team4 = team3;
team3 = team2;
team2 = team_t;
%--------------------------------
inc = 1;

for p = 1:sector1

    for m = 1:factor1

        for k = 1:team1

            RAM_out2( sector_size1*(p-1) + m-1 + factor1*(k-1) +1) = RAM_out1( inc );
            inc = inc+1;

        end
    end
end

RAM_out1 = RAM_out2;

%% 3rd inverse address iteration
%----------  parameters -----------
% inverse cycle shift
sector_size_t = sector_size1;
sector_t = sector1;
sector_size1 = sector_size4;
sector1 = sector4;
sector_size4 = sector_size3;
sector4 = sector3;
sector_size3 = sector_size2;
sector3 = sector2;
sector_size2 = sector_size_t;
sector2 = sector_t;

% inverse cycle shift
factor_t = factor1;
factor1 = factor4;
factor4 = factor3;
factor3 = factor2;
factor2 = factor_t;

% inverse cycle shift
team_t = team1;
team1 = team4;
team4 = team3;
team3 = team2;
team2 = team_t;
%--------------------------------
inc = 1;

for p = 1:sector1

    for m = 1:factor1

        for k = 1:team1

            RAM_out2( sector_size1*(p-1) + m-1 + factor1*(k-1) +1) = RAM_out1( inc );
            inc = inc+1;

        end
    end
end

RAM_out1 = RAM_out2;




RAM_out(1)
FX(1)
max(imag(RAM_out))
max(imag(FX))

RAM_out1(1:N)-FX.'


clear 
N = 3*5;
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


%% 1st iteration
W15 = exp(-j*2*pi/N);

RAM_in = x.';
sum(RAM_in)
for k=1:5
    twdl = zeros(5,1);
    for m=1:3
        rd_RAM = RAM_in( k-1 + 5*(m-1) +1);
        twdl(1) = twdl(1) + rd_RAM * rdx3(m,1);
        twdl(2) = twdl(2) + rd_RAM * rdx3(m,2);
        twdl(3) = twdl(3) + rd_RAM * rdx3(m,3);
        twdl(4) = twdl(4) + rd_RAM * rdx3(m,4);
        twdl(5) = twdl(5) + rd_RAM * rdx3(m,5);
    end
    coeff(1) = W15^(0*(k-1));
    coeff(2) = W15^(1*(k-1));
    coeff(3) = W15^(2*(k-1));
    coeff(4) = 0;
    coeff(5) = 0;
    wr_RAM = twdl(1)*coeff(1);
    RAM_out( 5*0 + (k-1) +1) = wr_RAM;    
    wr_RAM = twdl(2)*coeff(2);
    RAM_out( 5*1 + (k-1) +1) = wr_RAM;    
    wr_RAM = twdl(3)*coeff(3);
    RAM_out( 5*2 + (k-1) +1) = wr_RAM;
    sum_debug = sum_debug + twdl(1);
end
sum_debug
%% 2nd iteration
RAM_in = RAM_out;

part_size = 5;
part = 3;

for k=1:part
    twdl = zeros(5,1);
    for m=1:part_size
        rd_RAM = RAM_in( (k-1)*part_size + m-1 +1);
        twdl(1) = twdl(1) + rd_RAM * rdx5(m,1);
        twdl(2) = twdl(2) + rd_RAM * rdx5(m,2);
        twdl(3) = twdl(3) + rd_RAM * rdx5(m,3);
        twdl(4) = twdl(4) + rd_RAM * rdx5(m,4);
        twdl(5) = twdl(5) + rd_RAM * rdx5(m,5);
    end
    %twdl = fft(RAM_in( part_size*(k-1)+1 : part_size*(k-1)+5 ));
    coeff(1) = 1;
    coeff(2) = 1;
    coeff(3) = 1;
    coeff(4) = 1;
    coeff(5) = 1;
    wr_RAM = twdl(1)*coeff(1);
    RAM_out( 3*0 + (k-1) +1) = wr_RAM;    
    wr_RAM = twdl(2)*coeff(2);
    RAM_out( 3*1 + (k-1) +1) = wr_RAM;    
    wr_RAM = twdl(3)*coeff(3);
    RAM_out( 3*2 + (k-1) +1) = wr_RAM;
    wr_RAM = twdl(4)*coeff(4);
    RAM_out( 3*3 + (k-1) +1) = wr_RAM;
    wr_RAM = twdl(5)*coeff(5);
    RAM_out( 3*4 + (k-1) +1) = wr_RAM;
end
RAM_out(1)
RAM_out-FX.'


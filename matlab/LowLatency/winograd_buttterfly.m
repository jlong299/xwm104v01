% winograd butterfly

%% ------------- Radix-3 ---------------
N = 3;
x_real=round((2*rand(1,N)-1)*64);
x_imag=round((2*rand(1,N)-1)*64);
x = x_real + 1j*x_imag;
FX = fft(x);
% pipeline
p = zeros(3,3);

%  1st pipeline
p(1,1) = x(1);
p(1,2) = x(2) + x(3);
p(1,3) = -x(2) + x(3);
%  2nd pipeline
p(2,1) = p(1,1) + p(1,2);
p(2,2) = p(1,1) - 1/2*p(1,2);
p(2,3) = p(1,3) * (1j*0.866);
%  3rd pipeline
p(3,1) = p(2,1);
p(3,2) = p(2,2) + p(2,3);
p(3,3) = p(2,2) - p(2,3);

%max(abs(FX - p(3,:)))

%% ------------- Radix-5 ---------------
N = 5;
x_real=round((2*rand(1,N)-1)*1);
x_imag=round((2*rand(1,N)-1)*1);
x = x_real + 1j*x_imag;
FX = fft(x);

% pipeline
p = zeros(3,6);
pm = zeros(1,N);
%  1st pipeline
p(1,1) = x(1);
pm(2)  = x(2) + x(5);
pm(3)  = x(3) + x(4);
pm(4)  = x(2) - x(5);
pm(5)  = x(3) - x(4);

p(1,2) = pm(2) + pm(3);
p(1,3) = pm(2) - pm(3);
p(1,4) = pm(4);
p(1,5) = pm(5);
p(1,6) = pm(4) + pm(5);

%  2nd pipeline
p(2,1) = p(1,1) + p(1,2);
p(2,2) = p(1,1) - 1/4*p(1,2);
p(2,3) = p(1,3) * 0.559;
p(2,4) = p(1,4) * (-1j*1.539);
p(2,5) = p(1,5) * (-1j*0.363);
p(2,6) = p(1,6) * (1j*0.951);

%  3rd pipeline
p(3,1) = p(2,1);
pm(2)  = p(2,2) + p(2,3);
pm(3)  = p(2,5) + p(2,6);
pm(4)  = p(2,2) - p(2,3);
pm(5)  = p(2,4) + p(2,6);

p(3,5) = pm(2) + pm(3);
p(3,2) = pm(2) - pm(3);
p(3,3) = pm(4) + pm(5);
p(3,4) = pm(4) - pm(5);

mse = mean(mean( (abs(FX - p(3,1:5))).^2 ));
t = mse/ mean(mean((abs(FX)).^2))

 
 
 
 % pipeline
p = zeros(3,6);
pm = zeros(1,N);
%  1st pipeline
p(1,1) = x(1);
pm(2)  = x(2) + x(5);
pm(3)  = x(3) + x(4);
pm(4)  = x(2) - x(5);
pm(5)  = x(3) - x(4);

p(1,2) = pm(2) + pm(3);
p(1,3) = pm(2) - pm(3);
p(1,4) = pm(4);
p(1,5) = pm(5);
p(1,6) = pm(4) + pm(5);

%  2nd pipeline
p(2,1) = p(1,1) + p(1,2);
p(2,2) = p(1,1) - 1/4*p(1,2);
p(2,3) = p(1,3) * 0.559;
p(2,4) = p(1,4) * (-1j*1.5388);
p(2,5) = p(1,5) * (-1j*0.3632);
p(2,6) = p(1,6) * (1j*0.951);

%  3rd pipeline
p(3,1) = p(2,1);
pm(2)  = p(2,2) + p(2,3);
pm(3)  = p(2,5) + p(2,6);
pm(4)  = p(2,2) - p(2,3);
pm(5)  = p(2,4) + p(2,6);

p(3,5) = pm(2) + pm(3);
p(3,2) = pm(2) - pm(3);
p(3,3) = pm(4) + pm(5);
p(3,4) = pm(4) - pm(5);

%  max(abs(FX - p(3,1:5)))
mse = mean(mean( (abs(FX - p(3,1:5))).^2 ));
t = mse/ mean(mean((abs(FX)).^2))

clear;
close all;

% F24 = zeros(24,1);
% F24(3) = 1;
% F24 = 1:24;
F24 = randn(1,24);
F24 = F24;
x24 = ifft(F24);
figure;
plot(real(x24),'-or');
hold on;

F32 = [F24,zeros(1,8)];
x32 = ifft(F32);
% figure;
plot(real(x32),'-*b');

F24_2 = fft( [x24(1:12),zeros(1,12)] );
F32_2 = fft( [x32(1:16),zeros(1,16)] );

figure;
plot(real(F24_2),'r');
hold on;
plot(real(F32_2),'b');
real(F24_2-F32_2(1:24))

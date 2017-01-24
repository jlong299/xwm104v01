% Pls run Copy_of_PFACTA1_Mixed_radix_FFT first

% %% Compare with FPGA simulation result
% outf = fopen('../../modelsim/rdx2345_result.dat','r');
%     FPGA_out = fscanf(outf , '%d %d', [2 Inf]);
% fclose(outf);
% len_FPGA_out = length(FPGA_out(1,:));
% 
% x_debug_rsh = reshape(x_debug(:,1:1480),1,len_FPGA_out);
% 
% x_debug_t = [real(x_debug_rsh); imag(x_debug_rsh)];
% 
% %max(abs(FPGA_out - x_debug_t))
% max(max(abs(FPGA_out - x_debug_t)))


%% Compare with FPGA simulation result
outf = fopen('../../modelsim/top_result.dat','r');
    FPGA_out = fscanf(outf , '%d %d', [2 Inf]);
fclose(outf);
len_FPGA_out = length(FPGA_out(1,:));
repeat_times = floor(len_FPGA_out/N);

x_debug_rsh = FX;
x_debug_t = [real(x_debug_rsh); imag(x_debug_rsh)];
x_debug_repeat = zeros(2, repeat_times*N);

for kk=1:repeat_times
    x_debug_repeat(:, (N*(kk-1)+1):(N*kk)) = x_debug_t;
end

%max(abs(FPGA_out - x_debug_t))
max(max(abs(FPGA_out - x_debug_repeat)))
mse = mean(mean( (abs(FPGA_out - x_debug_repeat)).^2 ));
mse/ mean(mean((abs(x_debug_repeat)).^2))
 
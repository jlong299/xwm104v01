clear;
outf = fopen('../../modelsim/top_result_p4.dat','r');

outf_m = fopen('../../modelsim/matlab_result.dat','r');

new_frame = 1;
frame_len = 0;
total_frames = 0;
mse_too_big = 0;
while ~feof(outf_m)
	if new_frame==1
		frame_len = fscanf(outf_m, '%d \n', [1 1] );
		new_frame = 0;
	end

    	FPGA_out = fscanf(outf , '%d %d \n', [2 frame_len]);
    	matlab_out = fscanf(outf_m , '%d %d \n', [2 frame_len]);

    	mse = mean(mean( (abs(FPGA_out - matlab_out)).^2 ));
%         mean(mean((abs(matlab_out)).^2))
    	t1 = mse/ mean(mean((abs(matlab_out)).^2));
        if t1>0.00001  
            mse_too_big = 1;
        end
        
        frame_len 
        t1

        new_frame = 1;
        total_frames = total_frames + 1;
end
total_frames
mse_too_big
fclose(outf);
fclose(outf_m);
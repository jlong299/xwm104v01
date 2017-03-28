clc;
clear;

N=34;

param = zeros(N,12);

row = 0;
k = 0;

for m_len = 1:100   % The end of loop body is at the end of this file
    % factorize  N 
    [Nf_temp, err] = factor_2345(m_len);
    if err==1   % m_len can not be factorized to 2,3,4,5
        continue;
    end

    row = row+1;

	switch (m_len*12)
		case 12
			Nf = [4,3,1,1,1,1];
		case 24
			Nf = [4,2,3,1,1,1];
		case 36
			Nf = [4,3,3,1,1,1];
		case 48
			Nf = [4,4,3,1,1,1];
		case 60
			Nf = [4,5,3,1,1,1];
		case 72
			Nf = [4,2,3,3,1,1];
		case 96
			Nf = [4,4,2,3,1,1];
		case 108
			Nf = [4,3,3,3,1,1];
		case 120
			Nf = [4,2,5,3,1,1];
		case 144
			Nf = [4,4,3,3,1,1];
		case 180
			Nf = [4,5,3,3,1,1];
		case 192
			Nf = [4,4,4,3,1,1];
		case 216
			Nf = [4,2,3,3,3,1];
		case 240
			Nf = [4,4,5,3,1,1];
		case 288
			Nf = [4,4,2,3,3,1];
		case 300
			Nf = [4,5,5,3,1,1];
		case 324
			Nf = [4,3,3,3,3,1];
		case 360
			Nf = [4,2,5,3,3,1];
		case 384
			Nf = [4,4,4,2,3,1];
		case 432
			Nf = [4,4,3,3,3,1];
		case 480
			Nf = [4,4,2,5,3,1];
		case 540
			Nf = [4,5,3,3,3,1];
		case 576
			Nf = [4,4,4,3,3,1];
		case 600
			Nf = [4,2,5,5,3,1];
		case 648
			Nf = [4,2,3,3,3,3];
		case 720
			Nf = [4,4,5,3,3,1];
		case 768
			Nf = [4,4,4,4,3,1];
		case 864
			Nf = [4,4,2,3,3,3];
		case 900
			Nf = [4,5,5,3,3,1];
		case 960
			Nf = [4,4,4,5,3,1];
		case 972
			Nf = [4,3,3,3,3,3];
		case 1080
			Nf = [4,2,5,3,3,3];
		case 1152
			Nf = [4,4,4,2,3,3];
		case 1200
			Nf = [4,4,5,5,3,1];
		otherwise
			Nf = [4,3,1,1,1,1];
		end

	%----- Nf [1:5] ------------
	param(row,2:6) = Nf(2:6);

	%----- NumOfFactors, stage_of_rdx2,  factor_5 --------
	param(row,1) = 1; % NumOfFactors
	param(row,11) = 7; % stage_of_rdx2
	param(row,12) = 0; % factor_5

	for k = 2:6
		if Nf(k)==2
			param(row,11) = k-1;
		end

		if Nf(k)==5
			param(row,12) = 1;
		end

		if Nf(k)==1
			break;
		else
			param(row,1) = param(row,1) + 1;
		end
	end

	%----- twdl_demontr[0] ----
	param(row,8) = Nf(1)*Nf(2)*Nf(3)*Nf(4)*Nf(5)*Nf(6);

	%----- dftpts_div_base ----
	if param(row,12) == 1
		param(row,7) = param(row,8)/15;
	else
		param(row,7) = param(row,8)/3;
	end

	%----- quotient[0] -------
	param(row,9) = floor((2^20) / param(row,8));

	%----- remainder[0]
	param(row,10) = 2^20 - param(row,9)*param(row,8);

end





% %% Gen mif
depth = 34;
width = 64; 

filename = strcat('mif_InitROM.mif');   
fid=fopen(filename,'w');
fprintf(fid,'WIDTH=%d;\nDEPTH=%d;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n\nCONTENT BEGIN\n',width,depth*2);

param_comb_part0 = 0; % Low 36 bits
param_comb_part1 = 0; % High 42 bits
for i=1:depth
	param_comb_part0 = param(i,12) + param(i,11)*2^1 + param(i,10)*2^4  ...
	                 + param(i,9)*2^16 ;
	param_comb_part1 = param(i,8) + param(i,7)*2^12 + param(i,6)*2^24  ...
	                 + param(i,5)*2^27 + param(i,4)*2^30 ...
	                 + param(i,3)*2^33 + param(i,2)*2^36 + param(i,1)*2^39 ;

    fprintf(fid,'%d:%d;\n',2*i-2, int64(param_comb_part1));
    fprintf(fid,'%d:%d;\n',2*i-1, int64(param_comb_part0));
end
fprintf(fid,'END;\n');
fclose(fid);
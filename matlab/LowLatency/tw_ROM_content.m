clear;

% N = 256;
% ROM_content_f =exp(-1i*2*pi*[0:N-1]/N);
% ROM_content = round(ROM_content_f * 2^16);
% 
% outf = fopen('tw_ROM_fake.dat','w');
% for k = 1 : N
%     if ( real(ROM_content(k)) >= 0 )
%     	fprintf(outf , 'assign mem2_r[%d] = 18''d%d;\n' ,k-1, real(ROM_content(k)));
%     else
%     	fprintf(outf , 'assign mem2_r[%d] = -18''d%d;\n' ,k-1, -real(ROM_content(k)));
%     end
%     if ( imag(ROM_content(k)) >= 0 )
%     	fprintf(outf , 'assign mem2_i[%d] = 18''d%d;\n' ,k-1, imag(ROM_content(k)));
%     else
%     	fprintf(outf , 'assign mem2_i[%d] = -18''d%d;\n' ,k-1, -imag(ROM_content(k)));
%     end
% end
% fclose(outf);

% N = 25;
% ROM_content_f =exp(-1i*2*pi*[0:N-1]/N);
% ROM_content = round(ROM_content_f * 2^16);
% 
% outf = fopen('tw_ROM_fake.dat','w');
% for k = 1 : N
%     if ( real(ROM_content(k)) >= 0 )
%     	fprintf(outf , 'assign mem5_r[%d] = 18''d%d;\n' ,k-1, real(ROM_content(k)));
%     else
%     	fprintf(outf , 'assign mem5_r[%d] = -18''d%d;\n' ,k-1, -real(ROM_content(k)));
%     end
%     if ( imag(ROM_content(k)) >= 0 )
%     	fprintf(outf , 'assign mem5_i[%d] = 18''d%d;\n' ,k-1, imag(ROM_content(k)));
%     else
%     	fprintf(outf , 'assign mem5_i[%d] = -18''d%d;\n' ,k-1, -imag(ROM_content(k)));
%     end
% end
% fclose(outf);

N = 243;
ROM_content_f =exp(-1i*2*pi*[0:N-1]/N);
ROM_content = round(ROM_content_f * 2^16);

outf = fopen('tw_ROM_fake.dat','w');
for k = 1 : N
    if ( real(ROM_content(k)) >= 0 )
    	fprintf(outf , 'assign mem3_r[%d] = 18''d%d;\n' ,k-1, real(ROM_content(k)));
    else
    	fprintf(outf , 'assign mem3_r[%d] = -18''d%d;\n' ,k-1, -real(ROM_content(k)));
    end
    if ( imag(ROM_content(k)) >= 0 )
    	fprintf(outf , 'assign mem3_i[%d] = 18''d%d;\n' ,k-1, imag(ROM_content(k)));
    else
    	fprintf(outf , 'assign mem3_i[%d] = -18''d%d;\n' ,k-1, -imag(ROM_content(k)));
    end
end
fclose(outf);
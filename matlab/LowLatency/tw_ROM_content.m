clear;
N = 256;
ROM_content_f =exp(-1i*2*pi*[0:N-1]/N);
ROM_content = round(ROM_content_f * 2^17);

outf = fopen('tw_ROM_fake.dat','w');
for k = 1 : N
    if ( real(ROM_content(k)) >= 0 )
    	fprintf(outf , 'assign mem4_r[%d] = 18''d%d;\n' ,k-1, real(ROM_content(k)));
    else
    	fprintf(outf , 'assign mem4_r[%d] = -18''d%d;\n' ,k-1, -real(ROM_content(k)));
    end
    if ( imag(ROM_content(k)) >= 0 )
    	fprintf(outf , 'assign mem4_i[%d] = 18''d%d;\n' ,k-1, imag(ROM_content(k)));
    else
    	fprintf(outf , 'assign mem4_i[%d] = -18''d%d;\n' ,k-1, -imag(ROM_content(k)));
    end
end
fclose(outf);
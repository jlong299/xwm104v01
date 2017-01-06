% breakpoint  line 173 :   n=zeros(1,NumOfFactors_max);
for ii = 0:59
	hit = 0;
	for kk_x = 1:7
		for kk_y = 1:9
			if  RAM_0(kk_y, kk_x) == ii 
				hit = 1;
				[kk_y-1, kk_x-1]
				break;
			end
			if hit==1
				break;
			end
		end
	end
end
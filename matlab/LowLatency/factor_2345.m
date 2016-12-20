function [ Nf_temp,err ] = factor_2345( N )
%FACTOR Summary of this function goes here
%   Detailed explanation goes here
F = factor(N);
Nf_temp = zeros(1,4);
err = 0;
k = 1;
last_factor_is_2 = 0;


for m = 1:length(F)
    if (F(m)>5) || (F(m)<2)
        err = 1;
        break;
    else
        if F(m) ~= 2
        	if last_factor_is_2 == 1
            	Nf_temp(k) = 2;
            	k = k+1;
                last_factor_is_2 = 0;
            end
        	Nf_temp(k) = F(m);
        	k = k+1;
        else
        	if last_factor_is_2 == 1
        		Nf_temp(k) = 4;
        		k = k+1;
        		last_factor_is_2 = 0;
        	else
        		last_factor_is_2 = 1;
        		if (m==length(F))
        			Nf_temp(k) = 2;
        		end
        	end
        end
    end
end


if N==1
    err = 0;
end

end


function [ y ] = fft_tw( x, radix, tw_coeff, is_last_stage, InverseFFT)
%FFT_TW Summary of this function goes here
%   Detailed explanation goes here

f = zeros(length(x),1);

if (InverseFFT == 1)
	switch radix
	case 5
		f = 5*ifft(x,5);
	case 4
		% f(1:4) = fft(x(1:4));
		f(1:4) = 4*ifft(x(1:4));
		f(5) = 0;
	case 3
		% f(1:3) = fft(x(1:3));
		f(1:3) = 3*ifft(x(1:3));
		f(4) = 0;
		f(5) = 0;
	case 2
		f(1:2) = 2*ifft(x(1:2));
		f(3) = 0;
		f(4) = 0;
		f(5) = 0;
	otherwise
		f(1:2) = 2*ifft(x(1:2));
		f(3) = 0;
		f(4) = 0;
		f(5) = 0;
	end

else
	switch radix
		case 5
			f = fft(x,5);
		case 4
			% f(1:4) = fft(x(1:4));
			f(1:4) = ifft(x(1:4));
			f(5) = 0;
		case 3
			% f(1:3) = fft(x(1:3));
			f(1:3) = ifft(x(1:3));
			f(4) = 0;
			f(5) = 0;
		case 2
			f(1:2) = fft(x(1:2));
			f(3) = 0;
			f(4) = 0;
			f(5) = 0;
		otherwise
			f(1:2) = fft(x(1:2));
			f(3) = 0;
			f(4) = 0;
			f(5) = 0;
	end
end


if is_last_stage==1
	 y = f;
else
	switch radix
		case 5
			y = f.* [tw_coeff(0+1);tw_coeff(1+1);tw_coeff(2+1);tw_coeff(3+1);tw_coeff(4+1);];
		case 4
			y = f.* [tw_coeff(0+1);tw_coeff(1+1);tw_coeff(2+1);tw_coeff(3+1);0;];
		case 3
			y = f.* [tw_coeff(0+1);tw_coeff(1+1);tw_coeff(2+1);0;0;];
		case 2
			y = f.* [tw_coeff(0+1);tw_coeff(1+1);0;0;0;];
		otherwise
			y = f.* [tw_coeff(0+1);tw_coeff(1+1);0;0;0;];
	end
end

end


function [ y ] = fft_tw_CTA3( x, radix, tw_coeff, is_first_stage)
%FFT_TW Summary of this function goes here
%   Detailed explanation goes here

f = zeros(length(x),1);
y = zeros(length(x),1);

if is_first_stage==1
	 f = x;
else
	switch radix
		case 5
			f = x.* [tw_coeff(0+1);tw_coeff(1+1);tw_coeff(2+1);tw_coeff(3+1);tw_coeff(4+1);];
		case 4
			f = x.* [tw_coeff(0+1);tw_coeff(1+1);tw_coeff(2+1);tw_coeff(3+1);0;];
		case 3
			f = x.* [tw_coeff(0+1);tw_coeff(1+1);tw_coeff(2+1);0;0;];
		case 2
			f = x.* [tw_coeff(0+1);tw_coeff(1+1);0;0;0;];
		otherwise
			f = x.* [tw_coeff(0+1);tw_coeff(1+1);0;0;0;];
	end
end

switch radix
	case 5
		y = fft(f,5);
	case 4
		y(1:4) = fft(f(1:4));
		y(5) = 0;
	case 3
		y(1:3) = fft(f(1:3));
		y(4) = 0;
		y(5) = 0;
	case 2
		y(1:2) = fft(f(1:2));
		y(3) = 0;
		y(4) = 0;
		y(5) = 0;
	otherwise
		y(1:2) = fft(f(1:2));
		y(3) = 0;
		y(4) = 0;
		y(5) = 0;
end


end


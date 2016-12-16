function [ y ] = fft_tw( x, radix, tw )
%FFT_TW Summary of this function goes here
%   Detailed explanation goes here

f = zeros(length(x),1);

switch radix
	case 5
		f = fft(x,5);
		% twiddle
		y = f.*tw;
	case 4
		f(1:4) = fft(x(1:4));
		f(5) = 0;
		% twiddle
		y = f.*tw;
	case 3
		f(1:3) = fft(x(1:3));
		f(4) = 0;
		f(5) = 0;
		% twiddle
		y = f.*tw;
	case 2
		f(1:2) = fft(x(1:2));
		f(3) = 0;
		f(4) = 0;
		f(5) = 0;
		% twiddle
		y = f.*tw;
	otherwise
		f(1:2) = fft(x(1:2));
		f(3) = 0;
		f(4) = 0;
		f(5) = 0;
		% twiddle
		y = f.*tw;
end

end


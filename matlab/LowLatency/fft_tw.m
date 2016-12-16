function [ y ] = fft_tw( x, radix, tw, n2, is_last_stage)
%FFT_TW Summary of this function goes here
%   Detailed explanation goes here

f = zeros(length(x),1);

switch radix
	case 5
		f = fft(x,5);
	case 4
		f(1:4) = fft(x(1:4));
		f(5) = 0;
	case 3
		f(1:3) = fft(x(1:3));
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

if is_last_stage==1
	 y = f;
else
	switch radix
		case 5
			y = f.* [tw^(n2*0);tw^(n2*1);tw^(n2*2);tw^(n2*3);tw^(n2*4);];
		case 4
			y = f.* [tw^(n2*0);tw^(n2*1);tw^(n2*2);tw^(n2*3);0;];
		case 3
			y = f.* [tw^(n2*0);tw^(n2*1);tw^(n2*2);0;0;];
		case 2
			y = f.* [tw^(n2*0);tw^(n2*1);0;0;0;];
		otherwise
			y = f.* [tw^(n2*0);tw^(n2*1);0;0;0;];
	end
end

end


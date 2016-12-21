function [ p,q,stage_PFA ] = param_PFA( N )
%PARAM_PFA Summary of this function goes here
%   Detailed explanation goes here

p = zeros(1,3);
q = zeros(1,3);
stage_PFA = zeros(1,3);

switch N
	case 60
		p(1) = 4;
		p(2) = 5;
		p(3) = 7;
		q(1) = 1;
		q(2) = 2;
		q(3) = 1;
	case 240
		p(1) = 1;
		p(2) = 29;
		p(3) = 27;
		q(1) = 1;
		q(2) = 3;
		q(3) = 1;
	otherwise
		p(1) = 0;
		p(2) = 0;
		p(3) = 0;
		q(1) = 0;
		q(2) = 0;
		q(3) = 0;
end

end


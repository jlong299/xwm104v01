% PFA
N = 60;
N1 = 3;
N2 = 4;
N3 = 5;
addr = zeros(N,1);

p1 = 7;
p2 = 4;
p3 = 5;
q1 = 1;
q2 = 1;
q3 = 2;

for n1=0:N1-1
	for n2=0:N2-1
		for n3=0:N3-1
			addr(N2*N3*n1+N3*n2+n3 +1) = mod(N2*N3*n1+p1*N1*N3*n2+p1*p2*N1*N2*n3, N);
		end
	end
end

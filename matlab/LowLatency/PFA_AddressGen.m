clear

%% PFA  prime factor algorithm
N = 60;
N1 = 3;
N2 = 4;
N3 = 5;
addr_compute_1 = zeros(N,1);
addr_IOdata = zeros(N,1);

p1 = 7;
p2 = 4;
p3 = 5;
q1 = 1;
q2 = 1;
q3 = 2;

for n1=0:N1-1
	for n2=0:N2-1
		for n3=0:N3-1
			addr_compute_1(N2*N3*n1+N3*n2+n3 +1) = mod(N2*N3*n1+p1*N1*N3*n2+p1*p2*N1*N2*n3, N);
		end
	end
end

addr_compute_2 = zeros(N,1);

n1 = 0;
n2 = 0;
n3 = 0;
n1p = 0;   % n1'   n1 prime
n2p = 0;
r_p = N2 - q2*N1; % r'  r prime
q_p = N1 - q1; % q'  q prime
n2t = 0;  		% n2~  n2 tilde
for k=0:N-1
	
	% n2 = (n2' + r'*n3) mod N2   r' = N2 - r    r==q2*N1?
	n2 = mod(n2p + r_p*n3, N2);
	
	% n2~   tilde
	n2t = mod(N3*n2p + n3, N2*N3);

	% n1 = (n1' + q'*n2~) mod N1   q' = N1 - q    q==q1?
	n1 = mod(n1p + q_p*n2t, N1);
    
	addr_compute_2(N2*N3*n1+N3*n2+n3 +1) = k; % N2*N3*n1p+N3*n2p+n3
  
	if (n3 == N3-1) && (n2p == N2-1)
		n3 = 0;
		n2p = 0;
		n1p = n1p + 1;
	elseif (n3 == N3-1)
		n3 = 0;
		n2p = n2p + 1;
	else
		n3 = n3 + 1;
	end

end

max(addr_compute_2 - addr_compute_1)	
min(addr_compute_2 - addr_compute_1)	

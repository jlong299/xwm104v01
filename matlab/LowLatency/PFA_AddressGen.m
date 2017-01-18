clear

%% PFA  prime factor algorithm
N = 1200;
N1 = 16;
N2 = 25;
N3 = 3;
addr_compute_1 = zeros(N,1);
addr_IOdata = zeros(N,1);

p1 = 61;
p2 = 25;
p3 = 267;
q1 = 13;
q2 = 13;
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
% r_p = N2 - q2*N1; % r'  r prime
% q_p = N1 - q1; % q'  q prime
q_p = 3;
r_p = 17;
n2t = 0;  		% n2~  n2 tilde
ttt = zeros(N,1);
ttt2 = zeros(N,3);
for k=0:N-1
	
	% n2 = (n2' + r'*n3) mod N2   r' = N2 - r    r==q2*N1?
	n2 = mod(n2p + r_p*n3, N2);
	
	% n2~   tilde
	n2t = mod(N3*n2p + n3, N2*N3);

	% n1 = (n1' + q'*n2~) mod N1   q' = N1 - q    q==q1?
	n1 = mod(n1p + q_p*n2t, N1);
    
	addr_compute_2(N2*N3*n1+N3*n2+n3 +1) = k; % N2*N3*n1p+N3*n2p+n3
        
    ttt(k+1)=   N2*N3*n1+N3*n2+n3 ;
    ttt2(k+1,:) = [n1,n2,n3];
  
    %[n1,n2,n3]
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





%% Output PfA seq gen
addr_compute_1 = zeros(N,1);
addr_IOdata = zeros(N,1);

for k1=0:N1-1
	for k2=0:N2-1
		for k3=0:N3-1
			addr_compute_1(N2*N3*k1+N3*k2+k3 +1) = mod(p2*p3*N2*N3*k1+p3*N1*N3*k2+N1*N2*k3, N);
		end
	end
end

addr_compute_2 = zeros(N,1);

k1 = 0;
k2 = 0;
k3 = 0;
k2p = 0;   % k2'   k2 prime
k3p = 0;
k2s = 0;   % k2*

ttt = zeros(N,1);
ttt2 = zeros(N,3);
for m=0:N-1
	% k2 = (k2' - q2*N3*k1) mod N2
	k2 = mod(k2p + (N2*N3-q2*N3)*k1 , N2 );

	% k2* = (N1*k2' + k1) mod N3
	k2s = mod(N1*k2p + k1, N3);

	% k3 = (k3' - q3*(k2*)) mod N3
	k3 = mod(k3p + (N3-q3)*k2s, N3);
    
	addr_compute_2(N2*N3*k1+N3*k2+k3 +1) = m;
        
    ttt(m+1)=   N2*N3*k1+N3*k2+k3 ;
    ttt2(m+1,:) = [k1,k2,k3];
  
    %[k1,k2,k3]
	if (k1 == N1-1) && (k2p == N2-1)
		k1 = 0;
		k2p = 0;
		k3p = k3p + 1;
	elseif (k1 == N1-1)
		k1 = 0;
		k2p = k2p + 1;
	else
		k1 = k1 + 1;
    end
end

max(addr_compute_2 - addr_compute_1)	
min(addr_compute_2 - addr_compute_1)	
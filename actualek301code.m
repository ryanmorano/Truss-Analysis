clear
clc
%the file 'ek301.mat' contains the variables C, Sx, Sy, X, Y, L; we used a
%.mat file for convenience
load ek301trusstheoretical.mat

%joints = r
%members = c
[r, c]=size(C);

%Error checking for C
if c ~= 2*r - 3
   disp('You''re Fired')
end

loadoftruss=L(find(L~=0));


Cx=zeros(r,c);
Cy=zeros(r,c);
mymagsum=zeros(1,r);
uncertainty=zeros(1,r);
strength=zeros(1,r);
for i=1:c
    mycol=C(:,i);
    myvar1=find(mycol==1);
    first=myvar1(1);
    last=myvar1(2);
    mymag=sqrt((X(last)-X(first))^2 + ((Y(last)-Y(first))^2));
    mymagsum(i)=mymag;
    strength(i)=358.65/(mymag)^1.4542;
    uncertainty(i)=248.2708/mymag^2.45;
    Cx(first, i)=(X(last)-X(first))/mymag;
    Cy(first, i)=(Y(last)-Y(first))/mymag;
    Cx(last, i)=-Cx(first,i);
    Cy(last, i)=-Cy(first, i);
end

mymagsum = sum(mymagsum);

A=[Cx,Sx ; Cy, Sy];

L1 = zeros(length(L),1);
Lfinal = [L1;L];
T=A^(-1)*Lfinal;

%buckle ratio
buckleratio=zeros(1, c);
for i=1:r
    if T(i)<0
       buckleratio(i)=-T(i)/strength(i);
    end
end
memberbuckle=find(max(buckleratio));


%find max load
maxload=(sum(L)*strength(memberbuckle))/(-T(memberbuckle));

%cost cannot exceed $350 (joints are $10 and every cm of straw is $1)
mycost=r*10+mymagsum;
 
%Theoretical load to cost ratio
format bank
loadtocostratio=maxload./mycost;


%outputs

fprintf('%s\n', date)
fprintf('EK 301, Section A2, Group 2\n')
fprintf('Load: %d N\n', loadoftruss)
fprintf('Member forces in Newtons\n')
for i = 1:c
    if sign(T(i))== -1
        fprintf('M%d: %.3f (C)\n', i, abs(T(i)))
        fprintf('M%d uncertainty error: %d\n',i, uncertainty(i))
    else
        fprintf('M%d: %.3f (T)\n', i, abs(T(i)))
    end
end
fprintf('Reaction forces in Newtons\n')
fprintf('Sx1: 0.0\n')
fprintf('Sy1: %d\n' , T(c+2))
fprintf('Sy2: %d\n' , T(c+3))
fprintf('Cost of truss: %d\n', mycost)
fprintf('Theoretical max load to cost ratio in N/$: %d\n', loadtocostratio)


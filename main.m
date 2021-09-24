%% This is sample code for ECE 506 project 1
%% Start from Part II
clear all; close all;
f=2.4e9;
c=3e8;

% coordinate of transmitter and receiver
xt=25;
yt=10;

xr=1:0.1:49;
yr=5;

% path length of 7 paths
d1=sqrt((xt-xr).^2+(yt-yr)^2);
d2=sqrt((100-xt-xr).^2+(yt-yr)^2);
d3=sqrt((xt-xr).^2+(yt+yr)^2);
d4=sqrt((xt+xr).^2+(yt-yr)^2);
d5=sqrt((xt-xr).^2+(40-yt-yr)^2);
d6=sqrt((xt-xr).^2+(yt-yr)^2+9);
d7=sqrt((xt-xr).^2+(yt-yr)^2+49);
d=[d1;d2;d3;d4;d5;d6;d7];

% phase
phi1=2*pi*f*d1./c;
phi2=2*pi*f*d2./c+pi;
phi3=2*pi*f*d3./c+pi;
phi4=2*pi*f*d4./c+pi;
phi5=2*pi*f*d5./c+pi;
phi6=2*pi*f*d6./c+pi;
phi7=2*pi*f*d7./c+pi;

% delay
t1=d1./c.*1e9;
t2=d2./c.*1e9;
t3=d3./c.*1e9;
t4=d4./c.*1e9;
t5=d5./c.*1e9;
t6=d6./c.*1e9;
t7=d7./c.*1e9;

% amplitude
a0=sqrt(c./((4.*pi.*f).^2));
a1=a0./d1.*exp(1i.*phi1);
a2=0.7.*a0./d2.*exp(1i.*phi2);
a3=0.7.*a0./d3.*exp(1i.*phi3);
a4=0.7.*a0./d4.*exp(1i.*phi4);
a5=0.7.*a0./d5.*exp(1i.*phi5);
a6=0.7.*a0./d6.*exp(1i.*phi6);
a7=0.7.*a0./d7.*exp(1i.*phi7);

% Total Power (Narrowband & Wideband)
a_na=abs(a1+a2+a3+a4+a5+a6+a7); % narrow
a_wi=abs(a1)+abs(a2)+abs(a3)+abs(a4)+abs(a5)+abs(a6)+abs(a7); % wide band
figure(1)
subplot(2,1,1)
plot(xr,10*log10(a_na),'LineWidth',2);
grid on
xlabel('Location of Receiver[m]')
ylabel('Received Power[dBm]')
title('Multipath Fading in Narrowband & Wideband')
subplot(2,1,2)
plot(xr,10*log10(a_wi),'LineWidth',2);
grid on
xlabel('Location of Receiver[m]')
ylabel('Received Power[dBm]')

% Doppler Spectrum Using RT Results
figure(2)
w=-pi:pi/1000:pi;
X=zeros(1,length(w));
l1=length(a_na);
for i=1:length(w)
    for j=1:l1
    X(i)=X(i)+a_na(j).*exp(-1i*w(i)*j); % Discrete Time Fourier Transform
    end
end
plot(w,10*log10(abs(X).^2));
grid on
axis([-pi pi -125 -80])
title('Doppler Spectrum')
ylabel('Applitude[dB]');
xlabel('Frequency')

% Impulse Response of Multipath
figure(3)
index1=find(xr==30); % find index when receiver is at(25.9)
t_imp=[t1(index1) t2(index1) t3(index1) t4(index1) t5(index1) t6(index1) t7(index1)];
a_imp=abs([a1(index1) a2(index1) a3(index1) a4(index1) a5(index1) a6(index1) a7(index1)]);
stem(t_imp,a_imp);
grid on
title('Inpulse Response')
xlabel('Time Delay[ns]')
ylabel('Received Power[W]')

% inverse Fourier Transform
% coordinate of transmitter and receiver
f2=5.1e9:25e3:5.3e9;
l2=length(f2);

d_f=d(:,index1)';
l3=length(d_f);

phi_f=zeros(l2,l3);
phi_f(:,1)=(2*pi*f2'*d_f(1)./c);
phi_f(:,2:l3)=(2*pi*f2'*d_f(2:l3)./c+pi);

a_f=zeros(l2,l3);
a0_f=sqrt(c./((4.*pi.*f2').^2));
a_f(:,1)=a0_f./d_f(1).*exp(1i.*phi_f(:,1));
a_f(:,2:7)=0.7.*repmat(a0_f,[1,l3-1]).*exp(1i.*phi_f(:,2:l3))./repmat(d_f(2:l3),[l2,1]);
a_sum=abs(sum(a_f,2));
a_dB=10*log10(abs(sum(a_f,2)));
figure(4)
subplot(2,1,1)
plot(f2,a_dB,'LineWidth',2);
grid on
title('Frequency Response and Inverse Fourier Transform')
xlabel('Frequecy[Hz]')
ylabel('Received Power[dBm]')
x=zeros(1,80);
for i=1:1:80
    for j=1:1:l2
        x(i)=x(i)+(1/l2*a_sum(j)*exp(2*pi*1i*(j-1)*i/l2));
    end
end
subplot(2,1,2)
plot(abs(x),'-*');
grid on
xlabel('Samples')
% % ylabel('Magnitude')

% Narrowband Power vs Distance in meters
figure(5)
subplot(1,1,1)
plot(a_na,'LineWidth',2);
xlabel('NB Power[dBm]')
ylabel('Distance[m]')
grid on
title ('Narrowband Power vs Distance')
plot(d1,'LineWidth',2);
hold on
plot(d2,'LineWidth',2);
hold on
plot(d3,'LineWidth', 2);
hold on
plot(d4,'LineWidth', 2);
hold on
plot(d5,'LineWidth', 2);
hold on
plot(d6,'LineWidth', 2);
hold on
plot(d7,'LineWidth', 2);
hold off

% Path Loss Model for Enviornment 

%Calculate received power
% Vr = (a1*(exp(j*phi1)./d1)+a2*(exp(j*phi2)./d2)+a3*(exp(j*phi3)./d3)+a4*(exp(j*phi4)./d4)+a5*(exp(j*phi5)./d5)+a6*(exp(j*phi6)./d6)+a7*(exp(j*phi7)./d7));
% Pr_dB_r = 10*log10(P0*abs(Vr.^2))

% Transmitted/Recieved
% total_t_pwr = a1 + a2 + a3 + a4 + a5 + a6 + a7;
% pwr = total_t_pwr/a_na;

% Narrowband Power vs Distance in meters
figure(6)
subplot(1,1,1)
plot(a1,'LineWidth',2);
hold on
plot(a2,'LineWidth',2);
hold on
plot(a3,'LineWidth', 2);
hold on
plot(a4,'LineWidth', 2);
hold on
plot(a5,'LineWidth', 2);
hold on
plot(a6,'LineWidth', 2);
hold on
plot(a7,'LineWidth', 2);
hold off
xlabel('NB Power[dBm]')
ylabel('Shadow Fading')
grid on

r1 = round(d1)
r2 = round(d2)
r3 = round(d3)
r4 = round(d4)
r5 = round(d5)
r6 = round(d6)
r7 = round(d7)

m1=max(r1(1,:));
m2=max(r2(1,:)); 
m3=max(r3(1,:)); 
m4=max(r4(1,:)); 
m5=max(r5(1,:)); 
m6=max(r6(1,:)); 
m7=max(r7(1,:)); 

e1=estimate(m1);
e2=estimate(m2);
e3=estimate(m3);
e4=estimate(m4);
e5=estimate(m5);
e6=estimate(m6);
e7=estimate(m7);

title ('Power and Shadow Fading')
subplot(1,1,1)
grid on
plot(e1,'LineWidth',2);
hold on
plot(e2,'LineWidth', 2);
hold on
plot(e3,'LineWidth', 2);
hold on
plot(e4,'LineWidth', 2);
hold on
plot(e5,'LineWidth', 2);
hold on
plot(e6,'LineWidth', 2);
hold on
plot(e7,'LineWidth', 2);
hold off

% Estimates recieved from http://fcmcvlab.iitkgp.ac.in/Exp2/Theory/expt2-theory.pdf

function est = estimate(e)
        if e < 5
            est = 5
        end
        if e > 5 
            if e < 10
                est = 10
            end
        end
        if e > 10 
            if e < 30
                est = 30
            end
        end
        if e > 30
            if e < 50
                est = 41
            end
        end
        if e > 50
                est = 71
        end
end





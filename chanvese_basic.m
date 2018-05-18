%% chan-vese ver.2
% ���� �����ִ� ��� gauss-seidel�� �̿��� ���α׷��Դϴ�. ���� ���� �Ͽ� ver1���� ������ �� ���� �� �����ϴ�
% (���� iteration�� max(E1,E2)�� �� ���� �� Ů�ϴ�)
%% ���� ����
clear all; clc;
lam1=1;
lam2=1;
mu=0.5;
nu=0;
p=1;

h=1;
dt=1000; % �̰�쿡�� �ð��� ���� ũ�� ��Ƶ� �� �����ϴ� �� �����ϴ�.


I0=imread('test2.jpg'); % import image
I1=rgb2gray(I0); % RGB image�� 3�����̶� 2�������� ����
I=im2double(I1)*5; % uint8 �� double�� �ٲߴϴ�

N=size(I);
% image size detect
x=-round(N(1)/2)+1:h:floor(N(1)/2); 
y=-round(N(2)/2)+1:h:floor(N(2)/2);

Nx=N(1);
Ny=N(2);
phi=zeros(Nx,Ny);
[X,Y]=meshgrid(y,x);
%% phi ����
for i=1:Nx
    for j=1:Ny
        phi(i,j)=(x(i)^2+y(j)^2)^0.5-60; % �������� ���̰� 20�� ��
    end
end

%% chan-vese algorithm
t=0;
while(t<2000)  
    t=t+dt;   
    
    H=phi(:,:)>=0;
    
    c1=sum(sum(I.*H))/sum(sum(H));
    c2=sum(sum(I.*(1-H)))/sum(sum(1-H));
    
    phi=horzcat(phi(:,2),phi,phi(:,Ny-1));
    phi=vertcat(phi(2,:),phi,phi(Nx-1,:));
    
    delta=zeros(Nx, Ny);
    delta=(h/pi)./(h^2+phi(2:Nx+1,2:Ny+1).^2);
    
    gradphi=zeros(Nx, Ny);
    gradphi=((phi(3:Nx+2,2:Ny+1)-phi(1:Nx,2:Ny+1)).^2+(phi(2:Nx+1,3:Ny+2)-phi(2:Nx+1,1:Ny)).^2).^0.5/(2*h);
    
    L= sum(sum(delta.*gradphi));
    
    for i=2:Nx+1
        for j=2:Ny+1
            C1=1/(((phi(i+1,j)-phi(i,j))^2+((phi(i,j+1)-phi(i,j-1))^2)/4)^0.5+0.001);
            C2=1/(((phi(i,j)-phi(i-1,j))^2+((phi(i-1,j+1)-phi(i-1,j-1))^2)/4)^0.5+0.001);
            C3=1/((((phi(i+1,j)-phi(i-1,j)).^2)./4+(phi(i,j+1)-phi(i,j)).^2)^0.5+0.001);
            C4=1/((((phi(i+1,j-1)-phi(i-1,j-1))^2)/4+(phi(i,j)-phi(i,j-1))^2)^0.5+0.001);
            F1=(dt*mu*p*L^(p-1)*delta(i-1,j-1)*C1)/(h+dt*mu*p*L^(p-1)*delta(i-1,j-1)*(C1+C2+C3+C4));
            F2=(dt*mu*p*L^(p-1)*delta(i-1,j-1)*C2)/(h+dt*mu*p*L^(p-1)*delta(i-1,j-1)*(C1+C2+C3+C4));
            F3=(dt*mu*p*L^(p-1)*delta(i-1,j-1)*C3)/(h+dt*mu*p*L^(p-1)*delta(i-1,j-1)*(C1+C2+C3+C4));
            F4=(dt*mu*p*L^(p-1)*delta(i-1,j-1)*C4)/(h+dt*mu*p*L^(p-1)*delta(i-1,j-1)*(C1+C2+C3+C4));
            F=h/(h+dt*mu*p*L^(p-1)*delta(i-1,j-1)*(C1+C2+C3+C4));
            P=phi(i,j)-dt*delta(i-1,j-1)*(nu+lam1*(I(i-1,j-1)-c1)^2-lam2*(I(i-1,j-1)-c2)^2);
            phi(i,j)=F1*phi(i+1,j)+F2*phi(i-1,j)+F3*phi(i,j+1)+F4*phi(i,j-1)+F*P;        
        end
    end
    phi=phi(2:Nx+1,2:Ny+1);
    %surf(X,Y,phi);
    image(y,x,I0);
    hold on;
    contour(X,Y,-phi,[0,0],'r'); % phi�� zero level set�� �׷��ݴϴ�.
    %text(80,80,num2str(t));
    %pause(0.01);
    drawnow;
end
% error ���
R1=I>0.5;
R2=phi<0;
R1only=R1-R2;
R2only=R2-R1;
E1=size(R1only(R1only>0),1)/size(R1(R1>0),1);
E2=size(R2only(R2only>0),1)/size(R2(R2>0),1);
disp(['max(E1,E2) = ', num2str(max(E1, E2))]);
disp(['min(E1,E2) = ', num2str(min(E1, E2))]);

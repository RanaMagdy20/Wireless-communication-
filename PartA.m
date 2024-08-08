%% Parameters and inputs and total no of users formula:


S = 340;
f = 900;                  %MHz
Au=0.025;
h_BS = 20;
h_MS = 1.5;
sens = -95;                 %dBm
n = 4;                      %path loss exponent

% input
GOS = input('enter the GOS: ');
city_area = input('enter the city area(in km^2): ');
userdensity = input('enter the user density per km^2: ');
SIRmin = input('enter the min SIR in db: ');
sector_method = input('enter  sectorization method in angles: ');            

% Total users
Total_users=userdensity*city_area;

%% SIR & sectorization to get N:

% Convert SIR from dB to ratio
SIR = 10^(SIRmin / 10);
%% Sectorization

i = 0;                           %initialize interference parameter based on sector size
if sector_method == 360          % omni-directional 360deg     
    i = 6;    
    sectors=1;
elseif sector_method == 120      % 120deg sectorization      
    i =2;  
     sectors=3;
elseif sector_method ==60        %60deg sectorization  
    i =1;  
     sectors=6;
end


%% Cluster size:

%N=(1/3)*(((i*SIR)^(1/n))+1)^2;

N=(1/3)*((i*SIR)^(2/n));                   %Cluster size (not valid) 
N_valid = calc_cluster_size(N);            %valid cluster size

%% ErlangB returns A per sector gien GOS & C:

K=floor(S/N_valid);    %no of channels per cell
C=floor(K/sectors);    %C is no of channels in the minimum range we work on cell or sector 

syms k A
A=max(real(vpasolve(((A^C/factorial(C))/(symsum(A^k/factorial(k),k,0,C))) == GOS, A)));

%% No of cells, traffic intensity:

%traffic intensity per sector
traffic_sector=double(A);   

%traffic intensity per cell
traffic_cell=traffic_sector*sectors;
users_sector=traffic_sector/Au;
n_cells=ceil(Total_users/(users_sector*sectors)); %total no of users

%% Cell radius:

%cell area:
cell_area=city_area/n_cells;
radius = sqrt(cell_area * ( 2 / (3 * sqrt(3)) ));

%% display results:

fprintf('The number of cells are= %d cells\n ', n_cells)
fprintf('The cell radius is= %.5f Km\n ', radius)
fprintf('The traffic per sector is= %.5f Erlang\n ', traffic_sector)
fprintf('The traffic per cell is= %.5f Erlang\n ', traffic_cell)
fprintf('The cluster size is= %d cells per cluster\n ', N_valid)
%% Hata model:

% using Hata model for medium urban city to calculate the path loss
a = 3.2*(log10(11.75*h_MS))^2 - 4.97;   %constant used for urban cities only
Path_Loss = 69.55 + 26.16*log10(f) - 13.82* log10(h_BS) - a + (44.9 - 6.55*log10(h_BS))*log10(radius); % path loss in dB

%% Base station transmitted power

P_BS=sens+Path_Loss;         % Transmitted power (dBm)
fprintf('power transmitted_BS is %.5f dBm\n ', P_BS)
%% MS received power in dBm

d=radius/100:0.001*radius:radius;  %Distance
PL = 69.55 + 26.16*log10(f) - 13.82* log10(h_BS) - a + (44.9 - 6.55*log10(h_BS))*log10(d);  %Path loss
P_MS = P_BS - PL;
%% Plotting

figure
plot(d, P_MS);
grid on
title('Received power (dBm) vs distance (Km) ')
xlabel(' distance (Km) ')
ylabel('Received power (dBm)')
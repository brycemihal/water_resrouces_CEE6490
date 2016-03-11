%% ILO 4 Calculations with hedging
% Bryce Mihalevich
clear; clc;
%% Data
fDir = '/Users/bryce/Google Drive/My Docs/USU Documents/Spring 2016/CEE 6490/Assignments/ILO_4/';
fName = 'flowData.csv';
fid = fopen(strcat(fDir,fName));
c = textscan(fid,'%f %f %f %f %f','Delimiter', ',','HeaderLines' ,1);
fclose(fid);
% Read in Bear River data
BR = c{2};
% Read in Little Bear River data
LBR = c{3};
% parse years
years = c{1};
% excel totals
totals = c{4};
% excel releases
release = c{5};

%% Constants
% Reservoir Capacity
Ct = 51342;
% Flood Pool (12 months)
F = [0 0 0 15000 15000 15000 0 0 0 0 0 0];
% Demand (12 months)
Dt =  [1277 787 298 2544 34448 45953 50966 47807 35537 16691 4576 1561];
ADt = sum(Dt);
% Monthly Evaporation Rate
E = [0.00 0.00 0.02 0.13 0.22 0.36 0.43 0.39 0.20 0.05 0.00 0.00];
% Shortage Costs (starts in jan)
a = [2.5 2.5 2.5 2.5 4.5 4.5 1.3 1.3 1.3 4.5 2.5 2.5];
b = [1.2 1.2 1.2 1.2 1.3 1.3 1.7 1.7 1.7 1.3 1.2 1.2];

%% Calculations with hedging
% Minimum Storage
minSt = [0:100:900 1000:1000:50000];
for z = 1:length(minSt)
    %% initial conditions
    % minimum storage for iteration
    DSt = minSt(z);
    % Effective Capacity for iteration
    CtEff = (Ct-DSt)-F;
    % initial Storage
    St = 0;
    j = 1;
    R1=0;R2=0;R3=0;R4=0;R5=0;
    % loop for each year
    for i = 1:length(years)

        % loop months (start in feb)
        k = j+1;
        if k == 13
            k = 1;
        end
        % Reservoir Surface Area
        SA = -1*10^-6*St^2+0.1666*St+378.81;
        % Losses
        Mt = SA * E(j);

        % Available water (Bear River) with hedging
        AWt = BR(i)-Mt+St-DSt;

        % Conditions 
        if (AWt + LBR(i)) < Dt(j)
            R1 = AWt;
        elseif LBR(i) > Dt(j) && AWt < CtEff(k)
            R2 = 0;
        elseif LBR(i) > Dt(j) && AWt > CtEff(k)
            R3 = AWt - CtEff(k);
        elseif LBR(i) < Dt(j) && (AWt+LBR(i)) > Dt(j) && AWt+LBR(i)-Dt(j)<CtEff(k)
            R4 = Dt(j) - LBR(i);
        elseif LBR(i) < Dt(j) && (AWt+LBR(i)) > Dt(j) && AWt+LBR(i)-Dt(j)>CtEff(k)
            R5 = AWt - CtEff(k);
        end    

        % check
        num = 0;
        test = [R1 R2 R3 R4 R5];
        for n = 1:length(test)
            if test(n) > 0
                num = num+1;
            elseif num == 2
                error('to many releases');
            end
        end
        % Reservoir Release
        Rt(i) = sum(test); %R1+R2+R3+R4+R5;
        % Current Storage
        St = AWt - Rt(i)+DSt;
        % Total Flow to Cutler
        Q(i) = Rt(i) + LBR(i);

        % Loop months (start in jan)
        j = j+1;
        if j == 13;
            j = 1;
        end


        R1=0;R2=0;R3=0;R4=0;R5=0;
    end

    %% Performance metrics
    j = 1;

    % loop for methrics
    for i = 1:12:length(years)
        % Firm yield
        FY(j) = min(Q(i:i+11));

        % Reliability
        sat_time(j) = sum(Q(i:i+11) >= Dt(1:12));
        Annual_Reli(j) = (sat_time(j)/12)*100;

        % Resilience
        yearFlows = Q(i:i+11);
        for n = 2:length(yearFlows)
            if yearFlows(n-1) < Dt(n-1) && yearFlows(n) >=Dt(n)
                recovery(n) = 1;
                Annual_Resil(j) = sum(recovery)/(12-sat_time(j))*100;
            end
        end
        clear recovery

        % Vulnerability and Shortage Costs y = a*x^b
        AQ(j) = sum(yearFlows);
        if AQ(j) < ADt
            ADiff(j) = AQ(j) - ADt;
        end

        for n = 1:length(yearFlows)
            if yearFlows(n) < Dt(n)
                flow_diff(n) = abs(yearFlows(n) - Dt(n));
                Annual_Vuln(j) = sum(flow_diff)/(12-sat_time(j));
                SC(n) = a(n)*flow_diff(n)^b(n);
                Annual_SC(j) = sum(SC);
            end
        end
        clear SC
        clear flow_diff   
        j = j+1;
    end

    % Firm Yield
    FY(z) = min(FY);

    % Total Reliability
    T_Reli(z) = (sum(Annual_Reli == 100)/length(Annual_Reli))*100;

    % Total Resilience
    for i = 2:length(Annual_Resil)
        if Annual_Resil(i-1) ~= 0 && Annual_Resil(i) == 0
            recovery(i) = 1;
            T_Resil(z) = (sum(recovery)+1)/(length(Annual_Reli)-sum(Annual_Reli == 100))*100;
        end
    end

    % Total Vulnerability and Shortage Costs y = a*x^b
    T_Vuln(z) = sum(Annual_Vuln)/(length(Annual_Reli)-sum(Annual_Reli == 100));
    T_SC(z) = sum(Annual_SC);

end
%% save data
filename = 'ILO4_hedging_output.txt';
fid = fopen(filename, 'w');
fprintf(fid,'%s,%s,%s,%s\n','Total Reliability','Total Resilience','Total Vulnerability','Total Shortage Cost');
fclose(fid);

fid = fopen(filename, 'w');
for i = 1:length(T_Reli)
    fprintf(fid,'%f,%f,%f,%f,%f\n',minSt(i),T_Reli(i),T_Resil(i),T_Vuln(i),T_SC(i));
end
fclose(fid);



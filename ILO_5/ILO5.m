%% ILO5
%% Bryce Mihalevich
% Preformance metrics calculations
clear; clc;
%% Read in files
fDir = '/Users/bryce/Google Drive/My Docs/USU Documents/Spring 2016/CEE 6490/Assignments/ILO_5/WEAPResults/';
cd(fDir)
fName_S1 = 'Reference_UnmetDemand.csv';
fName_S2 = 'Scenario2_p10_UnmetDemand.csv';
fName_S3 = 'Secnario3_Res_UnmetDemand.csv';

fid = fopen(strcat(fDir,fName_S1));
c = textscan(fid,'%s %f %f %f','Delimiter',',','HeaderLines',1);
fclose(fid);
DateTime = c{1};
S1_BRCC = c{2};
S1_BRMBR = c{3};
S1_CVN = c{4};

fid = fopen(strcat(fDir,fName_S2));
c = textscan(fid,'%s %f %f %f','Delimiter',',','HeaderLines',1);
fclose(fid);
S2_BRCC = c{2};
S2_BRMBR = c{3};
S2_CVN = c{4};

fid = fopen(strcat(fDir,fName_S3));
c = textscan(fid,'%s %f %f %f','Delimiter',',','HeaderLines',1);
fclose(fid); 
S3_BRCC = c{2};
S3_BRMBR = c{3};
S3_CVN = c{4};

WEAP_label = {'S1_BRCC','S2_BRCC','S3_BRCC','S1_BRMBR','S2_BRMBR','S3_BRMBR','S1_CVN','S2_CVN','S3_CVN'};
WEAP_Results = [S1_BRCC S2_BRCC S3_BRCC S1_BRMBR S2_BRMBR S3_BRMBR S1_CVN S2_CVN S3_CVN];

%% Performance Metrics
% loop through WEAP results

for i = 1:length(WEAP_Results(1,:))
    %% Reliability
    Reli(i) = (sum(WEAP_Results(:,i) == 0)/length(WEAP_Results(:,1)))*100;

    %% Resilience
    for n = 2:length(WEAP_Results(:,1))
        if WEAP_Results(n-1,i) ~= 0 && WEAP_Results(n,i) == 0
            recovery(n) = 1;
        end
    end
    Resil(i) = sum(recovery)/(length(DateTime)-sum(WEAP_Results(:,i) == 0))*100;
    clear recovery

    %% Vulnerability 
    Vuln(i) = sum(WEAP_Results(:,i))/(length(DateTime)-sum(WEAP_Results(:,i) == 0));
end


%% Save results to output file
filename = 'ILO5_Output.txt';
fid = fopen(strcat(fDir,filename),'w');
fprintf(fid,'%s,%s,%s,%s\n','WEAP Run','Reliability','Resilience','Vulnerability');
fclose(fid);

fid = fopen(strcat(fDir,filename),'a');
for i = 1:length(Vuln)
    fprintf(fid,'%s,%f,%f,%f\n',char(WEAP_label(i)),Reli(i),Resil(i),Vuln(i));
end
fclose(fid);

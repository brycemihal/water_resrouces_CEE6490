%% ILO5
%% Bryce Mihalevich
% Preformance metrics calculations
clear; clc;
%% Read in files
fDir = '/Users/bryce/Google Drive/My Docs/USU Documents/Spring 2016/CEE 6490/Assignments/ILO_5/WEAPResults/';
cd(fDir)
fName_S1 = 'Reference_UnmetDemand2.csv';
fName_S2 = 'Scenario2_p10_UnmetDemand2.csv';
fName_S3 = 'Secnario3_Res_UnmetDemand2.csv';

fid = fopen(strcat(fDir,fName_S1));
c = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f','Delimiter',',','HeaderLines',1);
fclose(fid);
% DateTime = c{1};
S1_BRCC = c{1};
S1_BRMBR = c{2};
S1_BECMI = c{3};
S1_CVA = c{4};
S1_CVN = c{5};
S1_DJ = c{6};
S1_NBECA = c{7};
S1_SCE = c{8};
S1_SCN = c{9};
S1_WF = c{10};
S1_WBP = c{11};

fid = fopen(strcat(fDir,fName_S2));
c = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f','Delimiter',',','HeaderLines',1);
fclose(fid);
S2_BRCC = c{1};
S2_BRMBR = c{2};
S2_BECMI = c{3};
S2_CVA = c{4};
S2_CVN = c{5};
S2_DJ = c{6};
S2_NBECA = c{7};
S2_SCE = c{8};
S2_SCN = c{9};
S2_WF = c{10};
S2_WBP = c{11};

fid = fopen(strcat(fDir,fName_S3));
c = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f','Delimiter',',','HeaderLines',1);
fclose(fid); 
S3_BRCC = c{1};
S3_BRMBR = c{2};
S3_BECMI = c{3};
S3_CVA = c{4};
S3_CVN = c{5};
S3_DJ = c{6};
S3_NBECA = c{7};
S3_SCE = c{8};
S3_SCN = c{9};
S3_WF = c{10};
S3_WBP = c{11};

WEAP_label = {'S1_BRCC','S2_BRCC','S3_BRCC',...
    'S1_BRMBR','S2_BRMBR','S3_BRMBR',...
    'S1_BECMI','S2_BECMI','S3_BECMI',...
    'S1_CVA','S2_CVA','S3_CVA',...
    'S1_CVN','S2_CVN','S3_CVN',...
    'S1_NBECA','S2_NBECA','S3_NBECA',...
    'S1_SCE','S2_SCE','S3_SCE' ,...
    'S1_SCN','S2_SCN','S3_SCN',...
    'S1_WF','S2_WF','S3_WF',...
    'S1_WBP','S2_WBP','S3_WBP'};
WEAP_Results = [S1_BRCC S2_BRCC S3_BRCC ... 
    S1_BRMBR S2_BRMBR S3_BRMBR ...
    S1_BECMI S2_BECMI S3_BECMI ...
    S1_CVA S2_CVA S3_CVA ...
    S1_CVN S2_CVN S3_CVN ...
    S1_NBECA S2_NBECA S3_NBECA ...
    S1_SCE S2_SCE S3_SCE ...
    S1_SCN S2_SCN S3_SCN ...
    S1_WF S2_WF S3_WF...
    S1_WBP S2_WBP S3_WBP];

%% Performance Metrics
% loop through WEAP results

for i = 1:length(WEAP_Results(1,:))
    %% Reliability
    Reli(i) = (sum(WEAP_Results(:,i) == 0)/length(WEAP_Results(:,1)))*100;

    %% Resilience
    for n = 2:length(WEAP_Results(:,1))
        if WEAP_Results(n-1,i) ~= 0 && WEAP_Results(n,i) == 0
            recovery(n) = 1;
            Resil(i) = sum(recovery)/(length(WEAP_Results(:,i))-sum(WEAP_Results(:,i) == 0))*100;
        end
    end
    clear recovery

    %% Vulnerability 
    Vuln(i) = sum(WEAP_Results(:,i))/(length(WEAP_Results(:,i))-sum(WEAP_Results(:,i) == 0));
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

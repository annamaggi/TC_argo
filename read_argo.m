clear all;
close all;


%%% argo data all

dataDir = '../data/IMOS_Argo/';

files = dir([dataDir,'*.nc']);

row = 1;

for d=1:length(files)
    
    time = datetime(1950,01,01)+days(ncread([dataDir,files(d).name],'JULD'));
    %time = timeAdjust(time,[1950,1,1],'d');
    temp = ncread([dataDir,files(d).name],'TEMP_ADJUSTED');
    tempqc = ncread([dataDir,files(d).name],'PROFILE_TEMP_QC');
    pres = ncread([dataDir,files(d).name],'PRES_ADJUSTED');
    lat = ncread([dataDir,files(d).name],'LATITUDE');
    lon = ncread([dataDir,files(d).name],'LONGITUDE');
    direction = ncread([dataDir,files(d).name],'DIRECTION');
    
    for i=1:length(time)
        if tempqc(i)~='A'
            continue
        end
        
        z = gsw_z_from_p(pres(:,i),lat(i));
        
        argoData(row).time = time(i);
        argoData(row).temp = temp(:,i);
        argoData(row).tempqc = tempqc(i);
        argoData(row).z = z;
        argoData(row).lat = lat(i);
        argoData(row).lon = lon(i);
        argoData(row).direction = direction(i);
        
        row = row+1;
    end
end
%argofields = fieldnames(argoData);

save argoall20.mat argoData 

load bom_cyclones20y.mat

%% mask near tc

load argoall20.mat 

days_before = days(10);
days_after = days(5);
boxsize = 1;

maskArgo = false(1,length(argoData));
tclist20.argo = false(size(tclist20,1),size(argoData,2));

for i=1:size(tclist20.NAME,1)
    
    %%%----mask time------------------
    lattc=tclist20.LAT(i);
    lontc=tclist20.LON(i);
    masklon = [argoData.lon]>=lontc-boxsize & [argoData.lon]<=lontc+boxsize;
    masklat = [argoData.lat]>=lattc-boxsize & [argoData.lat]<=lattc+boxsize;
    maskspace = masklon&masklat;
    
    timetc=tclist20.TM(i);
    masktime = timetc-[argoData.time]<=days_before & [argoData.time]-timetc<=days_after;
    maskbefore = [argoData.time]<timetc;
    maskafter = [argoData.time]>=timetc;
    
    if any(maskspace&masktime&maskbefore) && any(maskspace&masktime&maskafter)
        maski = masktime&maskspace;
        maskArgo = maskArgo | maski;

        tclist20.argo(i,:) = maski;
    end
end

argoData = argoData(maskArgo);

%% filter tclist20
filteredMask = tclist20.argo(:,maskArgo);
tclist20.argo = filteredMask;
tclist20 = tclist20(any(tclist20.argo,2),:);
 save argoandtc.mat argoData tclist20




 
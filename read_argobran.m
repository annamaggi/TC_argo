clear all;
close all;

%%%%%--------file with argo profiles corresponding to cyclones-------------
load argoandtc.mat

boxsize=0.5;

%%%-----load bran grid--------------------
urlnarelle='http://dapds00.nci.org.au/thredds/dodsC/gb6/BRAN/BRAN_2016/OFAM/ocean_temp_2013_01.nc';

lonbran=ncread(urlnarelle, 'xt_ocean');
latbran=ncread(urlnarelle, 'yt_ocean');
zbran=ncread(urlnarelle, 'st_ocean');


for i= 1:length(argoData)
    
    %%%---------points around argo location-----------
    masklon = lonbran>=argoData(i).lon-boxsize & lonbran<=argoData(i).lon+boxsize;
    masklat = latbran>=argoData(i).lat-boxsize & latbran<=argoData(i).lat+boxsize;
    
    [startlon,countlon]=mask2startcount(masklon);
    [startlat,countlat]=mask2startcount(masklat);
    
    
    %%%%----date of argo profile-------------
    giorno=argoData(i).time.Day;
    mese=argoData(i).time.Month;
    anno=argoData(i).time.Year;
    
    
    %%%%%------------link to corresponding bran------------
    url=sprintf('http://dapds00.nci.org.au/thredds/dodsC/gb6/BRAN/BRAN_2016/OFAM/ocean_temp_%d_%02d.nc',anno,mese);
    
    data_loaded = false;
    while ~data_loaded
        try
            temp_bran_day=ncread(url,'temp',[startlon,startlat,1,giorno],[countlon,countlat,inf,1]);  %leggi zona giorno e all dpeths
            lonbran_day=ncread(url,'xt_ocean',[startlon],[countlon]);
            latbran_day=ncread(url,'yt_ocean',[startlat],[countlat]);
            data_loaded=true;
            
        catch e
            fprintf('Error on %d %d %d,retrying\n',anno,mese,giorno);
        end
    end
    
    
    %%%%%%------look for nearest bran location--------
    int_temp_day=nan(size(zbran));
    
    for z=1:size(zbran)
        int_temp_day(z)=interp2(lonbran_day,latbran_day,temp_bran_day(:,:,z)',argoData(i).lon, argoData(i).lat,'nearest');
        
    end
    
    %%%-----add corresponding bran profile to each argo one----------
    argoData(i).brantemp=int_temp_day;
    
     
end

save argoandbran.mat argoData zbran


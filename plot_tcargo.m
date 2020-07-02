clear all;
close all;

load bom_cyclones20y.mat;

fulltc=tclist20;

load argoandtc.mat;
load argoandbran.mat;

for nome=unique(tclist20.NAME)'
    
    maskname=strcmp(tclist20.NAME,nome); 
    
    tcname=tclist20(maskname,:);
    
    masknamefull=strcmp(fulltc.NAME,nome); 
    
    full=fulltc(masknamefull,:);
    
    
    maskargo=any(tcname.argo,1);
    argoname=argoData(maskargo);
    
    
    f=figure('Position',get(0,'Screensize'));
    subplot(1,3,1);
    hold on;
    
    m_proj('Equidistant Cylindrical','lon',[105,130],'lat',[-25,-10]) %same for all tc
    m_gshhs_h('patch',[0.5 0.5 0.5]);
    m_grid('fontsize',10);
    set(gca, 'FontSize', 16);
    
    m_track(full.LON,full.LAT,'linewidth',1.5,'b');
    
    for riga=1:size(argoname,2)
    m_plot(argoname(riga).lon,argoname(riga).lat,'^','MarkerSize',12,'LineWidth',3);
    end
    
    subplot(1,3,2);
    
    hold on;
    
    for riga=1:size(argoname,2)
        plot(argoname(riga).temp,-argoname(riga).z, 'Linewidth',2,'DisplayName',datestr(argoname(riga).time));
    end
    
    ylim([0 500]);
    xlim([5 30]);
    axis ij;
    box on;
    set(gca, 'FontSize', 16);
    
     subplot(1,3,3);
    
    hold on;
    
    for riga=1:size(argoname,2)
        plot(argoname(riga).brantemp,zbran, 'Linewidth',2,'DisplayName',datestr(argoname(riga).time));
    end
    
    ylim([0 500]);
    xlim([5 30]);
    axis ij;
    box on;
    set(gca, 'FontSize', 16);
    legend('Location','southeast');
    
    sgtitle(nome,'fontsize',20);
      
    filefig=sprintf('Argo%s.png', nome{:});
    saveas(gcf,filefig);
    
    close all;
end

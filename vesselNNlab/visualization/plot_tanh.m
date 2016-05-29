function plot_tanh()

    x = -5:0.01:5; 
    grayC = [.4 .4 .4];
    dark = [.2 .2 .2];
    
    close all
    figure('Color', 'w')
        plot(x,tanh(x),'Color', dark, 'LineWidth', 4)
            set(gca, 'FontSize', 8, 'XColor', grayC, 'YColor', grayC);
            
    path = '/home/petteri/Dropbox/Drafts_w_Biblio/vesselNN_lyx/figures/schematics';

    dpi = 150;
    aa = 2; % anti-alias level
    export_fig(fullfile(path, 'tanh.png'), ['-r', num2str(dpi)], ['-a', num2str(aa)])
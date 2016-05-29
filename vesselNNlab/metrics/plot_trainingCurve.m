function plot_trainingCurve(folder, fileName)

    if nargin == 0
        % folder / fileName
        folder = '/home/petteri/znnData/experiments/VD2D3D_tanh';
        fileName = 'net_statistics_current.h5';
        VD2D_range = [1 60000];
        VD2D3D_range = [60001 60001];
    end
    
    
    
    %% Import
    
        fileIn = fullfile(folder,fileName);
        info = h5info(fileIn);

        % note, no error checking, we assume that there is data
        test.it = h5read(fileIn,'/test/it');
        test.cls = h5read(fileIn,'/test/cls');
        test.err = h5read(fileIn,'/test/err');

        train.it = h5read(fileIn,'/train/it');
        train.cls = h5read(fileIn,'/train/cls');
        train.err = h5read(fileIn,'/train/err');
        
    %% Split the data into VD2D and VD2D3D parts
    
        testTrainRation = length(train.it) / length(test.it);
        [testSplit, ~, ~] = split_training_toVD2D_and_VD2D3D(test, 'test', VD2D_range, VD2D3D_range, testTrainRation);
        [trainSplit, range.VD2D, range.VD2D3D] = split_training_toVD2D_and_VD2D3D(train, 'train', VD2D_range, VD2D3D_range, testTrainRation);

    %% smooth the training data

        fieldNames = fieldnames(trainSplit);
        for i = 1 : length(fieldNames)

            % downsample first
            multipFactor = 5; % the larger, better the resolution
            noOfPoints = multipFactor*length(test.it);
            firstIteration = range.(fieldNames{i})(1);
            lastIteration = double(trainSplit.(fieldNames{i}).it(end));            
                        
            xi = linspace(firstIteration, lastIteration, noOfPoints);
            trainS.(fieldNames{i}).it = xi;
            
            yi_err = interp1(double(trainSplit.(fieldNames{i}).it), ...
                                double(trainSplit.(fieldNames{i}).err), ...
                                xi);
            
            yi_cls = interp1(double(trainSplit.(fieldNames{i}).it), ...
                                double(trainSplit.(fieldNames{i}).cls), ...
                                xi);
            
            % and then smooth, otherwise might take quite long      
            tic
            trainS.(fieldNames{i}).err = smooth(xi, yi_err, 0.1, 'rloess');            
            trainS.(fieldNames{i}).cls = smooth(xi, yi_cls, 0.1, 'rloess');
            toc
            
        end
    
    
    %% FIGURE
    
        close all
        
        for j = 1 : length(fieldNames)
        
            fig = figure('Color', 'w', 'Name', fieldNames{j});
                scrsz = get(0,'ScreenSize'); % get screen size for plotting
                set(fig,  'Position', [0.05*scrsz(3) (0.6-((j-1)*0.55))*scrsz(4) 0.60*scrsz(3) 0.35*scrsz(4)])

            rows = 1; cols = 2;
            i = 0;



            % ERR
            i = i+1; sp(i) = subplot(rows, cols, i);
                p(i,1:3) = plot(trainSplit.(fieldNames{j}).it, trainSplit.(fieldNames{j}).err, 'o', ...
                                testSplit.(fieldNames{j}).it, testSplit.(fieldNames{j}).err, ...
                                trainS.(fieldNames{j}).it, trainS.(fieldNames{j}).err); 
                
                tit(i) = title('ERR');
                lab(i,1) = xlabel('Iteration');
                lab(i,2) = ylabel('Error');            
                leg(i) = legend('Train', 'Test', 'Train Smooth'); legend('boxoff');
                            
                xlim([min(trainSplit.(fieldNames{j}).it) max(trainSplit.(fieldNames{j}).it)])
                
            % CLS
           i = i+1; sp(i) = subplot(rows, cols, i);
                p(i,1:3) = plot(trainSplit.(fieldNames{j}).it, trainSplit.(fieldNames{j}).cls, 'o', ...
                                testSplit.(fieldNames{j}).it, testSplit.(fieldNames{j}).cls, ...
                                trainS.(fieldNames{j}).it, trainS.(fieldNames{j}).cls); 
                            
                tit(i) = title('CLS');
                lab(i,1) = xlabel('Iteration');
                lab(i,2) = ylabel('cost');
                leg(i) = legend('Train', 'Test', 'Train Smooth'); legend('boxoff');
                
                xlim([min(trainSplit.(fieldNames{j}).it) max(trainSplit.(fieldNames{j}).it)])
                
            % STYLE
            set(sp, 'FontSize', 7, 'XColor', [.1 .1 .1], 'YColor', [.1 .1 .1])
            set(p(:,1), 'MarkerFaceColor',[0.960 0.976 0.992],...
                        'MarkerSize',2,...
                        'Marker','o',...
                        'LineStyle','none',...
                        'MarkerEdgeColor',[0.90 0.90 0.90], 'Color', 'w');
            set(p(:,2:3), 'LineWidth', 2)
            set(p(:,3), 'Color', 'k', 'LineWidth', 3)
            
            set(leg, 'FontSize', 7)
            
            folderOut = fullfile('..', 'screencaps');
            export_fig(fullfile(folderOut, ['trainingTest_zStat_', fieldNames{j}, '.png']), '-r300', '-a11')

        end



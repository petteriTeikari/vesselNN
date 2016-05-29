function [region, u] = segment_asetsWrapper3D(img, vessel, edges, region, ...
                                         maxLevelSetIterations, tau, w1, w2, w3, pars, ...
                                         regWeight1, regWeight2, regWeight3, ...
                                         secondPass, sliceIndex, visualize3D, visualizeON, fileOutBase, options)
                                     
    %% Tutorial 02: Time-implicit level set segmentation
    %  Martin Rajchl, Imperial College London, 2015
    %
    %   [1] Rajchl, M.; Baxter, JSH.; Bae, E.; Tai, X-C.; Fenster, A.; 
    %       Peters, TM.; Yuan, J.;
    %       Variational Time-Implicit Multiphase Level-Sets: A Fast Convex 
    %       Optimization-Based Solution
    %       EMMCVPR, 2015.
    %
    %   [2] Ukwatta, E.; Yuan, J.; Rajchl, M.; Qiu, W.; Tessier, D; Fenster, A.
    %       3D Carotid Multi-Region MRI Segmentation by Globally Optimal 
    %       Evolution of Coupled Surfaces
    %       IEEE Transactions on Medical Imaging, 2013
    
    % include max-flow solver
    % addpath(fullfile('..', '..', '3rdParty', 'asetsMatlabLevelSets', 'maxflow'));
    % addpath(fullfile('..', '..', '3rdParty', 'asetsMatlabLevelSets', 'lib'));
    
    maxIter = pars(4);
    errorBound = pars(5);
    regWeight = regWeight1;
    
    %% 1) LOAD IMAGE
    
        % done in the main

    %% 2. Normalize the image intensity to [0,1]:
    img = single(img);
    img_n = (img - min(img(:))) / (max(img(:)) - min(img(:)));


        
    %% visualize initial region    
    fig = figure('Color', 'w');        
        
        scrsz = get(0,'ScreenSize'); % get screen size for plotting
        if visualizeON
            % [ptchIn, ptchIn2, sp, imH, tit, asets_initPlot3D(fig, scrsz, region, sliceIndex, img_n)
            
            if ~visualize3D

                set(fig,  'Position', [0.01*scrsz(3) 0.175*scrsz(4) 0.8*scrsz(3) 0.8*scrsz(4)])
                rows = 4; cols = 4;
                i = 1;
                subplot(rows,cols,i); imshow(img_n(:,:,sliceIndex),[]);
                hold on; contour(region(:,:,sliceIndex),'r'); hold off;
                title('Initial region');
                drawnow

                ind = i;

            else       

                set(fig,  'Position', [0.01*scrsz(3) 0.275*scrsz(4) 0.8*scrsz(3) 0.7*scrsz(4)])
                rows = 4; cols = 6;

                % create a mesh from input
                debugPlot = false;
                isoValue = 0.1; % relative to max
                downSampleFactor = [1 1]; % [xy z] downsample to get less vertices/faces
                physicalScaling = [1 1 8]; % physical units of FOV
                
                [F,V] = reconstruct_marchingCubes_wrapper(img, 2.5*isoValue, downSampleFactor, physicalScaling, debugPlot);
                [F2,V2] = reconstruct_marchingCubes_wrapper(region, isoValue, downSampleFactor, physicalScaling, debugPlot);

                i = 1; width = 2;
                sp(i) = subplot(rows,cols,[i i+1 i+cols i+1+cols]);

                    az = -20; el = 60;
                    xLims = get(gca, 'XLim'); yLims = get(gca, 'YLim'); zLims = get(gca, 'ZLim'); 

                    
                    ptchIn2 = patch('Faces',F2,'Vertices', V2, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'blue', 'FaceAlpha', 0.1);
                
                    hold on
                                
                    ptchIn = patch('Faces',F,'Vertices', V, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'red', 'FaceAlpha', 0.2);
                    
                    hold off

                    az = -20; el = 60;
                    view(az,el);
                    daspect([1,1,0.05*size(img,3)/10]); axis tight
                    % xlabel('X'); ylabel('Y'); zlabel('Z')
                    tit(i) = title('Input Stack (+init contour)');
                    camlight 
                    lighting gouraud
                    axis off
                    drawnow
                    

                    imH(i) = 0; % no handle

                i = i+1; ind = i + (width-1);
                sp(i) = subplot(rows,cols,ind);

                    MaxIP_in = max(img_n, [], 3);     
                    maxIP_limits = [min(MaxIP_in(:)) max(MaxIP_in(:))];
                     
                    if maxIP_limits(1) == maxIP_limits(2)
                       maxIP_limits = [0 1];
                    end
                    imH(i) = imshow(MaxIP_in, 'DisplayRange', maxIP_limits); tit(i) = title('MaxIP Input');


                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    MinIP_in = min(img_n, [], 3);                
                    minIP_limits = [min(MinIP_in(:)) max(MinIP_in(:))];
                    imH(i) = imshow(MinIP_in, 'DisplayRange', maxIP_limits); tit(i) = title('MinIP Input');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Cs');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Ct');


                % "Line Change"
                i = i+1; ind = width + ind + (width-1);
                sp(i) = subplot(rows,cols,ind);            

                    imH(i) = imshow(ones(size(MinIP_in)),[]); tit(i) = title('Intensity inside');
                    axis off

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);            

                    imH(i) = imshow(ones(size(MinIP_in)),[]); tit(i) = title('Intensity outside');
                    axis off

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Speed inside');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    imH(i) = imshow(ones(size(MinIP_in)), 'DisplayRange', maxIP_limits); tit(i) = title('Speed outside');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,[ind ind+1 ind+cols ind+1+cols]);

                    ptchIn3 = patch('Faces',F2,'Vertices', V2, ...            
                                    'edgecolor', 'none', ...
                                    'facecolor', 'blue', 'FaceAlpha', 0.1);
                                
                    view(az,el);
                    daspect([1,1,0.05*size(img,3)/10]); axis tight
                    %xlabel('X'); ylabel('Y'); zlabel('Z')
                    tit(i) = title('Contour Init');
                    camlight 
                    lighting gouraud
                    xlim([1 size(img,1)]); ylim([1 size(img,2)]); zlim([1 size(img,3)]);
                    axis off
                    set(gca, 'XLim', xLims, 'YLim', yLims, 'Zlim', zLims);
                    drawnow


                    imH(i) = 0; % no handle

            end
            iStatic = i;
            indStatic = ind;
        else
            iStatic = 1;
            indStatic = 1;
        end

    %% 4. Construct an s-t graph:
    [sx, sy, sz] = size(img_n);

    Cs = zeros(sx,sy,sz);
    Ct = zeros(sx,sy,sz);

    % allocate alpha(x), the regularization weight at each node x
    alpha = zeros(sx,sy,sz);
    
    img_n_orig = img_n;
    
    for t=1:maxLevelSetIterations

        disp(['iter: ', num2str(t)])        
        i = iStatic;
        ind = indStatic;
        
        %% 6. Compute a speed data term based on the current region    
        d_speed_inside = bwdist(region == 1,'Euclidean');
        d_speed_outside = bwdist(region == 0,'Euclidean');

        % Added the vesselness term (M. Rajchl, pers.comm.)
        thresholdIntensity = 0.5; % graythresh(img_n(:));

        m_vesselness_inside = mean(mean(mean(vessel(region > thresholdIntensity))));
        m_vesselness_outside = mean(mean(mean(vessel(region <= thresholdIntensity))));

        d_vesselness_inside = abs(vessel - m_vesselness_inside);
        d_vesselness_outside = abs(vessel - m_vesselness_outside);
        
        % 7. Compute a intensity data term (PT: quick fix) 
        m_int_inside = mean(mean(mean(img_n(region > thresholdIntensity))));
        m_int_outside =  mean(mean(mean(img_n(region <= thresholdIntensity))));
        
        d_int_inside = abs(img_n - m_int_inside);
        d_int_outside = abs(img_n - m_int_outside);           
       
        %% 8. Compute speed data term as in Tutorial 01:
        d_speed_inside = ((1-region).*d_speed_inside)./tau;
        d_speed_outside = (region.*d_speed_outside)./tau;
        
        % 7. Weight the contribution of both costs and assign them as source 
        % and sink capacities Cs, Ct in the graph     
        
        Cs = w1.*d_int_outside + w2.*d_speed_outside + w3.*d_vesselness_inside;
        Ct = w1.*d_int_inside + w2.*d_speed_inside + w3.*d_vesselness_outside;
        
        % Assign a regularization weight (equivalent to pairwise terms) for each
        % node x. Here we employ a constant regularization weight alpha. The higher
        % alpha is, the more smoothness penalty is assigned.
            % regWeight = 0.05;
            % alpha = absNormVessels.^2 .* regWeight .* ones(sx,sy,sz);
            % alpha = regWeight .* ones(sx,sy,sz);
        
        % use weighed alpha rather than a constant (M. Racjhl, pers.comm.)
        alpha = regWeight1 + regWeight2 .* exp(-regWeight3 .* edges);        
        
        % clear border
        keepMask = zeros(size(alpha)); keepMask(3:sx-2, 3:sy-2,:) = 1;
        alpha(~keepMask) = max(alpha(:));

        % 7. Call the binary max flow optimizer with Cs, Ct, alpha and pars to obtain
        % the continuous labelling function u, the convergence over iterations
        % (conv), the number of iterations (numIt) and the run time (time);
        [u, conv, numIt, time] = asetsBinaryMF3D(Cs, Ct, alpha, pars);

        % 8. Threshold the continuous labelling function u to obtain a discrete
        % segmentation result
        region = u > 0.5;

        
        %% Visualize the costs (2D)
        if visualizeON
            tic
            if ~visualize3D
                i = i+1; subplot(rows,cols,i); loglog(conv, 'Color', [0 .7 1]); title(['convergence(',num2str(t),')']); axis square;
                    text(0.5*maxIter, 10*errorBound, ['no of iter = ', num2str(numIt)], 'HorizontalAlignment', 'right');
                    xlim([0 maxIter]); ylim([errorBound 0.001])
                    text(0.5*maxIter, 2*errorBound, ['time/iter = ', num2str(time,3), 's'], 'HorizontalAlignment', 'right');

                i = i+1; subplot(rows,cols,i); imshow(d_int_inside(:,:,sliceIndex), []); title(['Intensity IN']);
                i = i+1; subplot(rows,cols,i); imshow(d_int_outside(:,:,sliceIndex), []); title(['Intensity OUT']);
                i = i+1; subplot(rows,cols,i); imshow(d_speed_inside(:,:,sliceIndex), []); title(['Speed IN']);
                i = i+1; subplot(rows,cols,i); imshow(d_speed_outside(:,:,sliceIndex), []); title(['Speed OUT']);
                i = i+1; subplot(rows,cols,i); imshow(Ct(:,:,sliceIndex), []); title(['Ct']);
                i = i+1; subplot(rows,cols,i); imshow(Cs(:,:,sliceIndex), []); title(['Cs']);
                % i = i+1; subplot(rows,cols,i); imshow(u, []); title(['u, \tau = ']);            

                i = i+1; subplot(rows,cols,[i i+1 i+cols i+cols+1]); imshow(Cs(:,:,sliceIndex)-Ct(:,:,sliceIndex),[]); title(['Cs-Ct (w1=', num2str(w1), ', w2=', num2str(w2), ')']);
                i = i+2; subplot(rows,cols,[i i+1 i+cols i+cols+1]); imshow(img(:,:,sliceIndex),[]); title(['r(',num2str(t),'), \alpha = ', num2str(regWeight), ', \tau =', num2str(tau)]); hold on; contour(region(:,:,sliceIndex),'r'); hold off;

                drawnow();

            else
                
                % update 3D Contour
                % [F3,V3] = reconstruct_marchingCubes_wrapper(region, isoValue, downSampleFactor, physicalScaling, debugPlot);
                % set(ptchIn3,'Faces', [], 'Vertices', []) % not sure if really needed, test later
                % set(ptchIn3,'Faces', F3, 'Vertices', V3)

                cMultiplier = pars(6);
                stepSize = pars(7);
                
                titStr = sprintf('%s\n%s\n%s', ['\tau=', num2str(tau), ', ', ...
                                 'w1=', num2str(w1), ', ', ...
                                 'w2=', num2str(w2), ', ', ...
                                 'w3=', num2str(w3)], ...
                                 ['regW1=', num2str(regWeight1), ', ', ...
                                  'regW2=', num2str(regWeight2), ', ', ...
                                  'regW3=', num2str(regWeight3), ', '], ...
                                 ['c= ', num2str(cMultiplier), ', ', ...
                                  'stepSize= ', num2str(stepSize), ', ', ...
                                  'iter= ', num2str(t)]);
               
                set(tit(i), 'String', titStr, 'FontSize', 8)

                % Update Cs
                
                    MIP_Cs = max(Cs, [], 3);                    
                    axes(sp(i-6))                   
                        
                        imshow(MIP_Cs, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-6) = title('Cs');
                
                % Update Ct
                    MIP_Ct = max(Ct, [], 3); 

                    axes(sp(i-5))
                        imshow(MIP_Ct, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-5) = title('Ct');
                
                % Update Intensity Inside
                    MIP_intIn = max(d_int_inside, [], 3);
                    %[min(MIP_intIn(:)) max(MIP_intIn(:))];
    
                    axes(sp(i-4))
                        imshow(MIP_intIn, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-4) = title('Intensity inside');

                % Update Intensity Outside
                    MIP_intOut = max(d_int_outside, [], 3);

                    axes(sp(i-3))
                        imshow(MIP_intOut, 'DisplayRange', [0 1])
                        % set(imH(i-2), 'CData', MIP_int)
                        tit(i-3) = title('Intensity outside');
                      
                % Update Speed d_speed_inside(d_speed_inside < 0) = 0;Inside
                    MIP_speedIn = max(d_speed_inside, [], 3);
                    % speedLimits = [min(MIP_speedIn(:)) max(MIP_speedIn(:)) min(MIP_intOut(:)) max(MIP_intOut(:))]

                    axes(sp(i-2))
                        imshow(MIP_speedIn, []) % 'DisplayRange', [-1 1]/tau)                
                        % set(imH(i-1), 'CData', MIP_speed)
                        tit(i-2) = title('Speed inside');
                        
                % Update Speed Outside
                    MIP_speedOut = max(d_speed_outside, [], 3);
                    %[min(MIP_speedOut(:)) max(MIP_speedOut(:))];      

                    axes(sp(i-1))
                        imshow(MIP_speedOut, []) % 'DisplayRange', [0 1])                
                        % set(imH(i-1), 'CData', MIP_speed)
                        tit(i-1) = title('Speed outside');

                % Convergence
                i = i+1; ind = ind + 1 + (width-1);
                sp(i) = subplot(rows,cols,ind); 
                % note! loglogd_speed_inside(d_speed_inside < 0) = 0;() destroys alpha from patches
                iterVec = (1:1:length(conv))';
                plot(log10(iterVec), log10(conv), 'Color', [0 .7 1]); title(['convergence(',num2str(t),')']); axis square;                    
                    maxIter = pars(4);
                    errorBound = pars(5);
                    text(0.5*maxIter, 10*errorBound, ['no of iter = ', num2str(numIt)], 'HorizontalAlignment', 'right');
                    xlim([0 log10(maxIter)]); ylim(log10([errorBound 0.1]))
                    text(0.5*maxIter, 2*errorBound, ['time/iter = ', num2str(time,3), 's'], 'HorizontalAlignment', 'right');

                     
                % Cs-Ct
                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);
             
                    [F4,V4] = reconstruct_marchingCubes_wrapper((Cs-Ct), isoValue, downSampleFactor, physicalScaling, debugPlot);
                    if t == 1
                        ptchIn4 = patch('Faces',F4,'Vertices', V4, ...            
                                        'edgecolor', 'none', ...
                                        'facecolor', 'k', 'FaceAlpha', 0.1);
                        view(az,el);
                        daspect([1,1,0.05*size(img,3)/10]); axis tight
                        %xlabel('X'); ylabel('Y'); zlabel('Z')
                        tit(i) = title('Cs-Ct');
                        camlight 
                        lighting gouraud
                        xlim([1 size(img,1)]); ylim([1 size(img,2)]); zlim([1 size(img,3)]);
                        set(gca, 'XLim', xLims, 'YLim', yLims, 'Zlim', zLims);
                        set(gca, 'FontSize', 6)
                    else
                        set(ptchIn3,'Faces', F4, 'Vertices', V4)
                    end

                    
                % Cs-Ct (MIP)
                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);
                    
                    % view(az,el);
                    % imH(i) = imshow(MIP_Cs - MIP_Ct, 'DisplayRange', [0 1]); tit(i) = title('MIP (Cs-Ct)');                

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    alphaMIP = max(alpha, [], 3);
                    imH(i) = imshow(alphaMIP, 'DisplayRange', [min(alpha(:)) max(alpha(:))]); tit(i) = title('Alpha');  
                    %colorbar % ('peer', gca, [0.9 0.3366 0.006 0.138]);

                % "LINE CHANGE"
                i = i+1; ind = width + ind + (width-1);
                subplot(rows,cols,ind);

                    img_outFgMax = img_n_orig;
                    img_outFgMax(~region) = 0;
                    MaxIP_fg_out = max(img_outFgMax, [], 3);
                    imH(i) = imshow(MaxIP_fg_out, 'DisplayRange', maxIP_limits); tit(i) = title('MaxIP fg out');

                i = i+1; ind = ind + 1;
                subplot(rows,cols,ind);

                    img_outBgMax = img_n_orig;
                    img_outBgMax(region) = 0;
                    MaxIP_bg_out = max(img_outBgMax, [], 3);
                    imH(i) = imshow(MaxIP_bg_out, 'DisplayRange', maxIP_limits); tit(i) = title('MaxIP bg out');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    MIP_vesselIn = max(d_vesselness_inside, [], 3);
                    imH(i) = imshow(MIP_vesselIn); tit(i) = title(' '); tit(i) = title('Vessel Inside');

                i = i+1; ind = ind + 1;
                sp(i) = subplot(rows,cols,ind);

                    MIP_vesselOut = max(d_vesselness_outside, [], 3);
                    imH(i) = imshow(MIP_vesselOut); tit(i) = title(' '); tit(i) = title('Vessel Outside');   

                drawnow();       

            end

            if t < 10
                index = ['0', num2str(t)];
            else
                index = num2str(t);
            end

            timePlotUpdate2 = toc;
            disp(['  iter: ', num2str(t), ', plot update took: ', num2str(timePlotUpdate2,3), ' seconds'])
            
            % export to disk the figure
            fileOut = fullfile('..', 'imagesOutTemp', 'asetsLevelSets', [fileOutBase, '_', num2str(index), '.png']);
            
            % export_fig(fileOut, '-r200', '-a2')
        
        end % end visualizeON
        
    end
    
    
function asets_initPlot3D(region, sliceIndex, img_n)


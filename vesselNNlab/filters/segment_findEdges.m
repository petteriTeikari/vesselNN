function edges = segment_findEdges(img, visualizeON)
        
    [gx, gy] = gradient(img);
    gradMag = sqrt(gx.^2 + gy.^2);

    % smoothed_image = imgaussfilt(img,4);
    myfilter = fspecial('gaussian',[3 3], 0.5);
    smoothed_image = imfilter(img, myfilter, 'replicate');

    [gx, gy] = gradient(smoothed_image);
    gradMag_smooth = sqrt(gx.^2 + gy.^2);        

    edges = gradMag_smooth;

    if visualizeON

        regWeight1 = 0.01;
        regWeight2 = 0.04;
        regWeight3 = 0.08;
        alpha = regWeight1 + regWeight2 .* exp(-regWeight3 .* edges);

        rows = 2;
        cols = 3;
        subplot(rows,cols,1); imshow(img, []); title('OOF')
        subplot(rows,cols,2); imshow(smoothed_image, []); title('OOF Smooth')            
        subplot(rows,cols,3); imshow(alpha, []); title('Alpha')

        subplot(rows,cols,4); imshow(gradMag, []); title('GradMag')            
        subplot(rows,cols,5); imshow(gradMag_smooth, []); title('GradMag Smooth')
        subplot(rows,cols,6); imshow(abs(gradMag - gradMag_smooth), []); title('abs(GradMag-GradMagSmooth)')

        drawnow
        pause(1.0)

    end
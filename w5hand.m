function w5hand()
    % 打开一幅图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
        img_gray = rgb2gray(img); % 将图像转换为灰度图以简化处理
    else
        error('没有选择文件');
    end

    % 显示原始图像
    figure;
    subplot(2,3,1); imshow(img_gray); title('原始图像');

    % 定义滤波器
    roberts_x = [-1 0; 0 1];
    roberts_y = [0 -1; 1 0];
    prewitt_x = [-1 0 1; -1 0 1; -1 0 1];
    prewitt_y = [-1 -1 -1; 0 0 0; 1 1 1];
    sobel_x = [-1 0 1; -2 0 2; -1 0 1];
    sobel_y = [-1 -2 -1; 0 0 0; 1 2 1];
    
    % 使用 Robert 算子进行边缘检测
    roberts_edges = apply_edge_detector(img_gray, roberts_x, roberts_y);
    subplot(2,3,2); imshow(roberts_edges); title('Robert 算子');

    % 使用 Prewitt 算子进行边缘检测
    prewitt_edges = apply_edge_detector(img_gray, prewitt_x, prewitt_y);
    subplot(2,3,3); imshow(prewitt_edges); title('Prewitt 算子');

    % 使用 Sobel 算子进行边缘检测
    sobel_edges = apply_edge_detector(img_gray, sobel_x, sobel_y);
    subplot(2,3,4); imshow(sobel_edges); title('Sobel 算子');

    % 使用 Laplacian of Gaussian (LoG) 进行边缘检测
    log_kernel = fspecial('log', [7 7], 2); % 创建LoG核
    laplacian_edges = imfilter(double(img_gray), log_kernel, 'replicate') > 0;
    subplot(2,3,5); imshow(laplacian_edges); title('Laplacian of Gaussian (LoG)');

    % 使用 Canny 算子进行边缘检测（作为额外的对比）
    canny_edges = edge(img_gray, 'canny'); % 保留Canny算子使用自带函数
    subplot(2,3,6); imshow(canny_edges); title('Canny 算子');
end

function edges = apply_edge_detector(img, filter_x, filter_y)
    % 应用边缘检测算子
    Gx = imfilter(double(img), filter_x, 'replicate');
    Gy = imfilter(double(img), filter_y, 'replicate');
    
    % 计算梯度幅度
    magnitude = sqrt(Gx.^2 + Gy.^2);
    
    % 二值化处理（简单阈值化）
    threshold = graythresh(magnitude);
    edges = imbinarize(magnitude, threshold);
end
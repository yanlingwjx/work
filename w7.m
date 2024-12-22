function extract_features_from_image()
    % 1. 加载图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 2. 预处理：将图像转换为灰度图像
    gray_img = rgb2gray(img);

    % 3. 自适应阈值分割
    adapthist_eq = adapthisteq(gray_img);
    bw_img = imbinarize(adapthist_eq);

    % 4. 形态学操作：开运算和闭运算
    se = strel('disk', 5); % 定义圆形结构元素，半径为5
    bw_opened = imopen(bw_img, se); % 开运算
    bw_closed = imclose(bw_opened, se); % 闭运算

    % 5. 边界检测（可选）
    edges = edge(double(bw_closed), 'canny'); % 使用Canny算子检测边缘

    % 6. 提取连通组件
    cc = bwconncomp(bw_closed);
    stats = regionprops(cc, 'Area', 'Centroid', 'Eccentricity');
    areas = [stats.Area];
    [~, idx] = max(areas); % 找出面积最大的连通区域
    mask = false(size(bw_closed));
    mask(cc.PixelIdxList{idx}) = true; % 创建掩膜以显示最大连通区域

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,2); imshow(gray_img, []); title('灰度图像');
    subplot(2,3,3); imshow(bw_img); title('二值化图像');
    subplot(2,3,4); imshow(bw_closed); title('清理后的二值图像');
    subplot(2,3,5); imshow(edges); title('边缘检测结果');
    subplot(2,3,6); imshow(label2rgb(mask, @jet, [.7 .7 .7])); title('提取的目标');

    % 8. 特征提取：LBP 和 HOG

    % LBP 特征提取 (无可视化)
    lbpFeaturesOriginal = extractLBPFeatures(gray_img, 'NumNeighbors', 8, 'Radius', 1); % 原始灰度图像的LBP特征
    lbpFeaturesTarget = extractLBPFeatures(uint8(mask .* double(gray_img)), 'NumNeighbors', 8, 'Radius', 1); % 提取目标的LBP特征

    % HOG 特征提取及可视化
    [hogFeaturesOriginal, hogVisualizationOriginal] = extractHOGFeatures(img, 'CellSize', [8 8]); % 原始图像的HOG特征
    [hogFeaturesTarget, hogVisualizationTarget] = extractHOGFeatures(uint8(mask .* double(img)), 'CellSize', [8 8]); % 提取目标的HOG特征

    % 可视化HOG特征
    figure;
    subplot(1,2,1);
    hold on;
    imshow(img); % 显示原始图像作为背景
    hold on;
    plot(hogVisualizationOriginal); % 在原始图像上叠加HOG特征图
    title('原始图像的HOG特征');
    
    subplot(1,2,2);
    hold on;
    imshow(uint8(mask .* double(img))); % 显示提取目标作为背景
    hold on;
    plot(hogVisualizationTarget); % 在提取目标上叠加HOG特征图
    title('提取目标的HOG特征');

    % 如果需要保存结果，可以取消下面这行的注释
    % imwrite(uint8(mask .* 255), fullfile(pathname, 'extracted_target.png'));

    % 9. 保存特征向量到文件（可选）
    save(fullfile(pathname, 'features.mat'), 'lbpFeaturesOriginal', 'lbpFeaturesTarget', 'hogFeaturesOriginal', 'hogFeaturesTarget', 'mask');
end
function extract_target_from_image()
    % 1. 加载图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 2. 预处理：将图像转换为灰度图像
    gray_img = rgb2gray(img);

    % 3. 应用全局阈值分割
    level = graythresh(gray_img); % 使用Otsu's 方法自动选择阈值
    bw_img = imbinarize(gray_img, level);

    % 4. 形态学操作：开运算以清理噪声
    se = strel('disk', 5); % 定义圆形结构元素，半径为5
    bw_cleaned = imopen(bw_img, se); % 执行开运算，先腐蚀后膨胀

    % 5. 边界检测（可选）
    edges = edge(double(bw_cleaned), 'canny'); % 使用Canny算子检测边缘

    % 6. 提取连通组件
    cc = bwconncomp(bw_cleaned);
    stats = regionprops(cc, 'Area', 'Centroid');
    areas = [stats.Area];
    [max_area, idx] = max(areas); % 找出面积最大的连通区域
    mask = false(size(bw_cleaned));
    mask(cc.PixelIdxList{idx}) = true; % 创建掩膜以显示最大连通区域

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,2); imshow(gray_img, []); title('灰度图像');
    subplot(2,3,3); imshow(bw_img); title('二值化图像');
    subplot(2,3,4); imshow(bw_cleaned); title('清理后的二值图像');
    subplot(2,3,5); imshow(edges); title('边缘检测结果');
    subplot(2,3,6); imshow(label2rgb(mask, @jet, [.7 .7 .7])); title('提取的目标');

    % 如果需要保存结果，可以取消下面这行的注释
    % imwrite(uint8(mask .* 255), fullfile(pathname, 'extracted_target.png'));
end
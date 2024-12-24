function w6()
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

    % 5. 边界检测
    edges = edge(double(bw_closed), 'canny'); % 使用Canny算子检测边缘
    
    % 创建掩膜：首先填充边缘内的区域，然后反转掩膜以提取目标
    filledEdges = imfill(edges, 'holes');
    mask = ~filledEdges; % 反转掩膜以选择目标而不是背景

    % 将掩膜应用到原始彩色图像上，提取目标
    targetFromMask = img;
    targetFromMask(repmat(~mask, [1, 1, size(img, 3)]) == 0) = 0; % 将背景设置为黑色

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,2); imshow(gray_img, []); title('灰度图像');
    subplot(2,3,3); imshow(bw_img); title('二值化图像');
    subplot(2,3,4); imshow(bw_closed); title('清理后的二值图像');
    subplot(2,3,5); imshow(edges); title('边缘检测结果');
    subplot(2,3,6); imshow(targetFromMask); title('从背景中提取的目标');

    % 如果需要保存结果，可以取消下面这行的注释
    % imwrite(targetFromMask, fullfile(pathname, 'extracted_target.png'));
end
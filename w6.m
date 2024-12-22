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

    % 3. 自适应阈值分割
    adapthist_eq = adapthisteq(gray_img);
    bw_img = imbinarize(adapthist_eq);

    % 4. 形态学操作：开运算和闭运算
    se = strel('disk', 5); % 定义圆形结构元素，半径为5
    bw_opened = imopen(bw_img, se); % 开运算
    bw_closed = imclose(bw_opened, se); % 闭运算

    % 5. 边界检测（可选）
    edges = edge(double(bw_closed), 'canny'); % 使用Canny算子检测边缘

    % 6. 用户交互式选择目标区域
    figure;
    imshow(img);
    title('请在图像中选择目标区域');
    roi = imrect();
    wait(roi); % 等待用户完成选择

    % 获取用户选择的矩形位置
    if ismethod(roi, 'getPosition') % 检查是否支持getPosition方法
        roiPosition = round(roi.getPosition());
    else
        error('无法获取ROI位置');
    end

    % 检查用户是否取消了选择或选择了无效区域
    if isempty(roiPosition) || any(roiPosition <= 0) || ...
       (roiPosition(1)+roiPosition(3) > size(gray_img, 2)) || ...
       (roiPosition(2)+roiPosition(4) > size(gray_img, 1))
        error('选择的区域无效或为空');
    end

    % 提取用户选择的目标区域
    targetRegion = imcrop(gray_img, roiPosition);

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,2); imshow(gray_img, []); title('灰度图像');
    subplot(2,3,3); imshow(bw_img); title('二值化图像');
    subplot(2,3,4); imshow(bw_closed); title('清理后的二值图像');
    subplot(2,3,5); imshow(edges); title('边缘检测结果');
    subplot(2,3,6); imshow(targetRegion); title('用户选择的目标区域');

    % 如果需要保存结果，可以取消下面这行的注释
    % imwrite(uint8(mask .* 255), fullfile(pathname, 'extracted_target.png'));
end
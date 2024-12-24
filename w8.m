function w8()
    % 1. 加载图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 2. 用户交互式选择目标区域
    figure;
    imshow(img);
    title('请在图像中选择目标区域');
    roi = imrect(); % 创建矩形ROI选择工具
    wait(roi); % 等待用户完成选择

    % 获取用户选择的矩形位置
    if ismethod(roi, 'getPosition') % 检查是否支持getPosition方法
        roiPosition = round(roi.getPosition());
    else
        error('无法获取ROI位置');
    end

    % 检查用户是否取消了选择或选择了无效区域
    if isempty(roiPosition) || any(roiPosition <= 0) || ...
       (roiPosition(1)+roiPosition(3) > size(img, 2)) || ...
       (roiPosition(2)+roiPosition(4) > size(img, 1))
        error('选择的区域无效或为空');
    end

    % 提取用户选择的目标区域
    targetRegion = imcrop(img, roiPosition);

    % 3. 可视化结果
    figure;
    subplot(1,2,1); imshow(img); title('原始图像');
    subplot(1,2,2); imshow(targetRegion); title('用户选择的目标区域');

    % 如果需要保存结果，可以取消下面这行的注释
    % imwrite(targetRegion, fullfile(pathname, 'extracted_target.png'));
end
function transform_image()
    % 打开一幅图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 显示原始图像
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');

    % 缩放图像
    scale_factor = 0.75; % 缩小为原来的75%
    resized_img = imresize(img, scale_factor);
    subplot(2,3,2); imshow(resized_img); title(['缩放比例: ', num2str(scale_factor)]);

    scale_factor = 1.5; % 放大1.5倍
    resized_img_large = imresize(img, scale_factor);
    subplot(2,3,3); imshow(resized_img_large); title(['缩放比例: ', num2str(scale_factor)]);

    % 旋转图像
    rotation_angle = 45; % 逆时针旋转45度
    rotated_img = imrotate(img, rotation_angle, 'crop');
    subplot(2,3,4); imshow(rotated_img); title(['旋转角度: ', num2str(rotation_angle), '度']);

    rotation_angle = -30; % 顺时针旋转30度
    rotated_img_anticlock = imrotate(img, rotation_angle, 'loose');
    subplot(2,3,5); imshow(rotated_img_anticlock); title(['旋转角度: ', num2str(rotation_angle), '度']);

    % 结合缩放和旋转
    combined_transformed_img = imrotate(imresize(img, 0.75), 45, 'loose');
    subplot(2,3,6); imshow(combined_transformed_img); title('缩放与旋转结合');
end
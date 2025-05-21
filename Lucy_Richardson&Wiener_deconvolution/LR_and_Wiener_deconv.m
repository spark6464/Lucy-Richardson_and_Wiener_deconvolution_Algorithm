%% 调用generate_speckle产生散斑图
speckle_intensity = generate_speckle('N', 2048, 'W', 20, 'S', 2, 'D',128);
% 'N':二维数组大小;'W':圆形平滑滤波器直径;'S':% 相位乘法因子(产生2pi);'D':光阑直径

% 绘制散斑图像
figure;
set(gcf, 'Position', [100, 100, 550, 550]);
imagesc(speckle_intensity);
colormap([zeros(256, 1), linspace(0, 1, 256)', zeros(256, 1)]);
caxis([0, 0.5]);
axis off;
% colorbar;

% ========================
% 添加 400 px 的标尺
scale_px = 400;                          % 标尺长度：400像素
x0 = 200;                                % 起点横坐标
y0 = size(speckle_intensity,1) - 200;    % 起点纵坐标（靠近下边）

% 绘制白色线段
line([x0, x0 + scale_px], [y0, y0], 'Color', 'w', 'LineWidth', 4);

% 添加注释文字
text(x0 + scale_px/2, y0 - 120, '400 pixels', ...
    'Color', 'w', 'FontSize', 30, 'HorizontalAlignment', 'center');

%% 调用createMask生成数字板/双缝/三缝图案
% 生成矩形双缝/三缝
% 竖直双缝（左右排列）名称：'double_slit_vertical'
% 水平双缝（上下排列）名称：'double_slit_horizontal'
% 竖直三缝（左右排列）名称：'triple_slit_vertical'
% 水平三缝（上下排列）名称：'triple_slit_horizontal'
% params.width = 30;  % 单个竖孔的宽度
% params.height = 200;  % 竖孔的高度
% params.gap = 60;  % 竖孔间距
% binaryImg = createMask('triple_slit_vertical', [512, 512], params);

% 生成数字板
params.text='7'; % 选择数字
params.fontSize=200; % 设置数字大小
binaryImg = createMask('digit', [512, 512], params);


% 画出binaryImg
figure;imshow(binaryImg); %一个512x512的逻辑数组(0,1)

% ============ 添加像素标尺 ============
scale_px = 100;  % 标尺长度：100 像素
x0 = 50;         % 标尺起始横坐标
y0 = size(binaryImg,1) - 50;  % 标尺纵坐标（放在下边缘）

% 画标尺线段
line([x0 x0 + scale_px], [y0 y0], 'Color','w', 'LineWidth', 3);

% 添加文字说明
text(x0 + scale_px/2, y0 - 40, '100 pixels', ...
     'Color','w', 'HorizontalAlignment','center', 'FontSize', 30);


%% 计算卷积得到散斑模糊图像
blurred_speckle = conv2(speckle_intensity, double(binaryImg), 'same');


% % 计算傅里叶变换
% I_fft = fft2(speckle_intensity);
% binaryImg_fft = fft2(binaryImg, 2048, 2048); % 直接填充到2048x2048大小
% % 频域相乘（卷积定理）
% blurred_speckle = abs(fftshift(ifft2(I_fft .* binaryImg_fft)));
% %归一化结果
% blurred_speckle = blurred_speckle / max(blurred_speckle(:));


% 绘制卷积后的散斑图像
figure;
imagesc(blurred_speckle);
colormap([zeros(256, 1), linspace(0, 1, 256)', zeros(256, 1)]);
axis off;


% ========================
% 添加 400 px 的标尺
scale_px = 400;                          % 标尺长度：400像素
x0 = 200;                                % 起点横坐标
y0 = size(speckle_intensity,1) - 200;    % 起点纵坐标（靠近下边）

% 绘制白色线段
line([x0, x0 + scale_px], [y0, y0], 'Color', 'w', 'LineWidth', 4);

% 添加注释文字
text(x0 + scale_px/2, y0 - 120, '400 pixels', ...
    'Color', 'w', 'FontSize', 30, 'HorizontalAlignment', 'center');


%% 反卷积恢复图像（Lucy-Richardson 反卷积）
%计时开始
tic;

num_iterations = 40; % 迭代次数
recovered_img = deconvlucy(blurred_speckle, speckle_intensity, num_iterations);
% % 确保 recovered_img 和 ground_truth 具有相同尺寸
recovered_img = imresize(recovered_img, size(binaryImg));

%计时结束
elapsed_time = toc;
fprintf('Lucy-Richardson 反卷积用时: %.4f 秒\n', elapsed_time);

% 绘制恢复后的图像
figure;
imagesc(recovered_img);
colormap(gray);
axis off;

% ========================
% 添加 400 px 的标尺
scale_px = 400;                          % 标尺长度：400像素
x0 = 200;                                % 起点横坐标
y0 = size(speckle_intensity,1) - 200;    % 起点纵坐标（靠近下边）

% 绘制白色线段
line([x0, x0 + scale_px], [y0, y0], 'Color', 'w', 'LineWidth', 4);

% 添加注释文字
text(x0 + scale_px/2, y0 - 120, '400 pixels', ...
    'Color', 'w', 'FontSize', 30, 'HorizontalAlignment', 'center');


%% 评估反卷积质量
% 归一化到 [0,1] 范围
recovered_img = double(recovered_img);
binaryImg = double(binaryImg);

recovered_img = (recovered_img - min(recovered_img(:))) / (max(recovered_img(:)) - min(recovered_img(:)));
binaryImg = (binaryImg - min(binaryImg(:))) / (max(binaryImg(:)) - min(binaryImg(:)));

% 计算评估指标
mse_value = immse(recovered_img, binaryImg);
psnr_value = psnr(recovered_img, binaryImg);
ssim_value = ssim(recovered_img, binaryImg);

% 输出评估结果
fprintf('MSE: %.4f\n', mse_value);
fprintf('PSNR: %.2f dB\n', psnr_value);
fprintf('SSIM: %.4f\n', ssim_value);


%% Wiener反卷积恢复
% 使用Wiener滤波进行反卷积
noise_var =0.01;  % 假设噪声方差为 0.01
signal_var = 1;    % 假设信号方差为 1

recovered_img = wiener_deconvolution(blurred_speckle, speckle_intensity, noise_var, signal_var);

recovered_img = imresize(recovered_img, size(binaryImg));
% 显示恢复后的图像
figure;
imagesc(recovered_img);
colormap(gray);
axis off;
% colorbar;
% ========================
% 添加 400 px 的标尺
scale_px = 400;                          % 标尺长度：400像素
x0 = 200;                                % 起点横坐标
y0 = size(speckle_intensity,1) - 200;    % 起点纵坐标（靠近下边）

% 绘制白色线段
line([x0, x0 + scale_px], [y0, y0], 'Color', 'w', 'LineWidth', 4);

% 添加注释文字
text(x0 + scale_px/2, y0 - 120, '400 pixels', ...
    'Color', 'w', 'FontSize', 30, 'HorizontalAlignment', 'center');

%% 评估反卷积质量
% 归一化到 [0,1] 范围
recovered_img = double(recovered_img);
binaryImg = double(binaryImg);

recovered_img = (recovered_img - min(recovered_img(:))) / (max(recovered_img(:)) - min(recovered_img(:)));
binaryImg = (binaryImg - min(binaryImg(:))) / (max(binaryImg(:)) - min(binaryImg(:)));

% 计算评估指标
mse_value = immse(recovered_img, binaryImg);
psnr_value = psnr(recovered_img, binaryImg);
ssim_value = ssim(recovered_img, binaryImg);

% 输出评估结果
fprintf('MSE: %.4f\n', mse_value);
fprintf('PSNR: %.2f dB\n', psnr_value);
fprintf('SSIM: %.4f\n', ssim_value);

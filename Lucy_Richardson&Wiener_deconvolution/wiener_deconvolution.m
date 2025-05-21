function recovered_img = wiener_deconvolution(blurred_speckle, PSF, noise_variance, signal_variance)
    % Wiener 反卷积
    % blurred_image - 模糊图像（包含噪声）
    % PSF - 点扩散函数（Speckle Intensity）
    % noise_variance - 噪声方差
    % signal_variance - 信号方差

    % 获取图像的尺寸（假设 blurred_image 和 PSF 尺寸相同）
    [M, N] = size(blurred_speckle);

    % 计算 PSF 的傅里叶变换
    PSF_FFT = fftshift(fft2(PSF));  % PSF 的傅里叶变换（尺寸与 blurred_image 相同）
    blurred_FFT = fftshift(fft2(blurred_speckle));  % 模糊图像的傅里叶变换（尺寸与 PSF 相同）

    % 计算 Wiener 滤波器
    H_conj = conj(PSF_FFT);  % PSF 的共轭
    PSF_power = abs(PSF_FFT).^2;  % PSF 的功率谱
    noise_to_signal_ratio = noise_variance / signal_variance;  % 噪声与信号的比率
    Wiener_filter = H_conj ./ (PSF_power + noise_to_signal_ratio);

    % 使用 Wiener 滤波器进行图像恢复
    deconvolved_FFT = Wiener_filter .* blurred_FFT;
    
    % 计算反变换恢复图像
    recovered_img = fftshift(ifft2(deconvolved_FFT));
    
    % 只取实部（去除可能的小虚部）
    recovered_img = real(recovered_img);

    % 恢复的图像强度归一化
    recovered_img = abs(recovered_img) / max(abs(recovered_img(:)));
end

# Lucy-Richardson_and_Wiener_deconvolution_algorithm

## 文件基本信息说明：

本文件夹包含4份文件：
(1)generate_speckle：产生散斑图案，已封装，可以在最后两个m文件中调用，调用方式以及输入参数均有说明；

(2)createMask：创建数字板、双条纹/三条纹图案，调用方式和输入参数均在后面两个m文件中注释说明；

(3)wiener_deconvolution：Wiener反卷积算法，已经封住好，可以在LR_and_Wiener_deconv文件中调用；

(4) LR_and_Wiener_deconv：包括Lucy-Rochardson反卷积、Wiener反卷积的代码，运行时，分节运行，首先是生产散斑图，数字板，然后反卷积，此外包含三种图像恢复评价指标，即MSE、PSNR、SSIM。

## 运行方式说明：

可直接运行LR_and_Wiener_deconv，设置了分节符，建议分节运行，以方便观察每一步运行得到的图像结果。


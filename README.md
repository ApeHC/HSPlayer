# HSPlayer

> HSPlayer是对IJKMediaPlayer的封装, 支持基础的视频播放功能, 包括

- [x] 横/竖屏切换
- [x] 视频进度条管理
- [x] https地址的视频播放
- [x] ...

*为了方便大家使用,IJKMediaPlayer已经打包成framework,且支持了https的视频播放 (下载地址:)*

### 注意事项

1. 横竖屏旋转需要打开 Landscape Left和Landscape Right , 否则无法旋转屏幕
2. HSPlayer使用了Masonry布局, 因此项目需要导入Masonry
3. 使用IJKMediaPlayer需要添加以下依赖库
   * AudioToolbox.framework
   * AVFoundation.framework
   * CoreGraphics.framework
   * CoreMedia.framework
   * CoreVideo.framework
   * libbz2.tbd
   * libc++.tbd
   * libz.tbd
   * MediaPlayer.framework
   * MobileCoreServices.framework
   * OpenGLES.framework
   * QuartzCore.framework
   * UIKit.framework
   * VideoToolbox.framework

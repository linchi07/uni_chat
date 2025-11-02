/*
 * Copyright (C) 2023-2025 moluopro. All rights reserved.
 * Github: https://github.com/moluopro
 */

library webview_all;

export 'src/webview/webview.dart';

//为什么不直接按照插件的方式加载这个包呢？
//就是直接用插件版本的话是：opaque is not implemented on macOS的
//但是他的Github版本是完全没问题的，就很离谱，估计是作者忘记更新了

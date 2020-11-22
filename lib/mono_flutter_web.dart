// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A web implementation of the MonoFlutter plugin.
class MonoFlutterWeb {
  static final _iframeElementMap = Map<Key, html.IFrameElement>();

  static void setup(String src, Key key, {num width, num height}) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(src, (int viewId) {
      if (_iframeElementMap[key] == null) {
        _iframeElementMap[key] = html.IFrameElement();
      }
      final element = _iframeElementMap[key]..style.border = '0';
      // ..allowFullscreen = widget.webAllowFullScreen
      // ..height = height.toInt().toString()
      // ..width = width.toInt().toString();
      // if (src != null) {
      //   String _src = src;
      //   if (widget.isMarkdown) {
      //     _src = "data:text/html;charset=utf-8," +
      //         Uri.encodeComponent(EasyWebViewImpl.md2Html(src));
      //   }
      //   if (widget.isHtml) {
      //     _src = "data:text/html;charset=utf-8," +
      //         Uri.encodeComponent(EasyWebViewImpl.wrapHtml(src));
      //   }
      element..src = src;
      // }
      return element;
    });
  }

 
}

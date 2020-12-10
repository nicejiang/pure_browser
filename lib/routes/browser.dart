import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purebrowser/widgets/NavigationController.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Browser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new __BrowserState();
}

class __BrowserState extends State<Browser> {
  final String _initUrl = 'https://www.baidu.com';
  String _url;
  bool _progressOffState = true;
  FocusNode _inputUrlFocusNode = new FocusNode();
  TextEditingController _urlController = new TextEditingController();
  final Completer<WebViewController> _webController =
      Completer<WebViewController>();
  int _secondTime = 0;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void _onUpdate(DragUpdateDetails details) {
    print("_onUpdate:x:${details.delta.dx}, y:${details.delta.dy}");
  }

  void _onEnd(DragEndDetails details) {
    print("_onEnd:${details.velocity}");
  }

  void _onStart(DragStartDetails details) {
    print("_onStart:${details.globalPosition}");
  }

  @override
  void dispose() {
    super.dispose();
    _urlController.dispose();
    _inputUrlFocusNode.dispose();
  }

  void _updateTitle(String url) {
    setState(() {
      _url = url;
    });
  }

  void _changeProgressOffState(bool state) {
    setState(() {
      _progressOffState = state;
    });
  }

  void _loadUrl(String url, WebViewController controller) {
    //清空输入内容
    _urlController.clear();
    _inputUrlFocusNode.unfocus();
    controller.loadUrl(url);
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          //去掉返回按钮
          automaticallyImplyLeading: false,
          title: urlSendWidget(_webController.future),
          backgroundColor: Colors.white,
        ),
        body: Builder(builder: (BuildContext context) {
          return Column(
            children: [
              Offstage(
                offstage: _progressOffState,
                child: LinearProgressIndicator(
                  minHeight: 2.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.blue[200]),
                ),
              ),
              //child自适应高度
              Expanded(
                child: WebView(
                    initialUrl: _initUrl,
                    onWebViewCreated: (WebViewController webViewController) {
                      _webController.complete(webViewController);
                    },
                    javascriptChannels: <JavascriptChannel>[
                      _toasterJavascriptChannel(context),
                    ].toSet(),
                    gestureNavigationEnabled: true,
                    javascriptMode: JavascriptMode.unrestricted,
                    navigationDelegate: (NavigationRequest request) {
                      if (request.url.startsWith('https://') ||
                          request.url.startsWith('http://')) {
                        print('blocking navigation to $request}');
                        return NavigationDecision.navigate;
                      }
                      print('allowing navigation to $request');
                      return NavigationDecision.prevent;
                    },
                    onPageStarted: (url) {
                      _updateTitle(url);
                      _changeProgressOffState(false);
                    },
                    onPageFinished: (url) {
                      _changeProgressOffState(true);
                    }),
              )
            ],
          );
        }),
        bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            shape: CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
            child: NavigationController(_webController.future)),
        floatingActionButton: FloatingActionButton(
            //悬浮按钮
            child: Icon(Icons.menu),
            backgroundColor: Colors.blue[200],
            onPressed: () {}),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
      // ignore: missing_return
      onWillPop: () {
        if (_secondTime != 0 && DateTime.now().millisecondsSinceEpoch - _secondTime < 2000) {
          exit(0);
        } else {
          Fluttertoast.showToast(
              msg: "再按一次退出",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[100],
              textColor: Colors.white,
              fontSize: 16.0);
          _secondTime = DateTime.now().millisecondsSinceEpoch;
        }
      },
    );
  }

  Widget urlSendWidget(Future<WebViewController> future) {
    return FutureBuilder<WebViewController>(
        future: future,
        builder:
            (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
          final bool webViewReady =
              snapshot.connectionState == ConnectionState.done;
          final WebViewController controller = snapshot.data;
          return Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                flex: 8,
                child: TextField(
                  focusNode: _inputUrlFocusNode,
                  autofocus: false,
                  controller: _urlController,
                  decoration:
                      InputDecoration(hintText: _url, border: InputBorder.none),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue[200],
                  ),
                  onPressed: !webViewReady
                      ? null
                      : () async => _loadUrl(_urlController.text, controller),
                ),
              ),
            ],
          );
        });
  }
}

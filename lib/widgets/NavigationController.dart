import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationController extends StatefulWidget {
  const NavigationController(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  State<StatefulWidget> createState() => _ControlState();
}

class _ControlState extends State<NavigationController> {


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget._webViewControllerFuture,
        builder:
            (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
          final bool webViewReady =
              snapshot.connectionState == ConnectionState.done;
          final WebViewController controller = snapshot.data;
          return Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Colors.blue[200],
                ),
                onPressed: !webViewReady ? null : () async {
                        if (await controller.canGoBack()) {
                          await controller.goBack();
                        }
                      },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_outlined,
                    color: Colors.blue[200]),
                onPressed: !webViewReady ? null : () async {
                        if (await controller.canGoForward()) {
                          await controller.goForward();
                        }
                      },
              ),
              SizedBox(), //中间位置空出
              SizedBox(), //中间位置空出
              SizedBox(), //中间位置空出
              SizedBox(), //中间位置空出
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue[200]),
                onPressed: !webViewReady ? null : () {controller.reload();},
              ),
              SizedBox(), //中间位置空出
              SizedBox(), //中间位置空出
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
          );
        });
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.url, required this.title});

  final String title;
  final String url;

  @override
  createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  late ScrollController _scrollViewController;
  bool _showAppbar = true;
  bool isScrollingDown = false;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  bool _canGoBack = false;
  bool _canGoForward = false;

  void updateButtonState() async {
    if (webViewController == null) return;

    final canGoBack = await webViewController!.canGoBack();
    final canGoForward = await webViewController!.canGoForward();

    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(),
      onRefresh: () async {
        updateButtonState();

        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    _scrollViewController = ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          setState(() {
            isScrollingDown = true;
            _showAppbar = false;
          });
        }
      }

      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          setState(() {
            isScrollingDown = false;
            _showAppbar = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      onWillPop: () async {
        if (webViewController == null) {
          return true;
        }
        final canGoBackWebPage = await webViewController!.canGoBack();
        if (canGoBackWebPage) {
          webViewController!.goBack();
          return false;
        }

        return true;
      },
      child: SafeArea(
          child: Column(children: <Widget>[
        AnimatedContainer(
          height: _showAppbar ? 56.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(widget.url,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  updateButtonState();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT,
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    if (await canLaunchUrl(Uri.parse(url))) {
                      // Launch the App
                      await launchUrl(
                        Uri.parse(url),
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  updateButtonState();
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  updateButtonState();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                  onPressed: _canGoBack
                      ? () async {
                          if (await webViewController!.canGoBack()) {
                            webViewController!.goBack();
                          }
                        }
                      : null,
                  child: const Icon(Icons.chevron_left)),
            ),
            Expanded(
              child: MaterialButton(
                  onPressed: _canGoForward
                      ? () async {
                          if (await webViewController!.canGoForward()) {
                            webViewController!.goForward();
                          }
                        }
                      : null,
                  child: const Icon(Icons.chevron_right)),
            ),
            Expanded(
              child: MaterialButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () {
                    webViewController?.reload();
                  }),
            ),
            Expanded(
              child: MaterialButton(
                  child: const Icon(Icons.share),
                  onPressed: () {
                    Share.share(widget.url, subject: widget.title);
                  }),
            ),
            Expanded(
              child: MaterialButton(
                  child: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse(widget.url),
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch ${widget.url}');
                    }
                  }),
            ),
          ],
        )
      ])),
    ));
  }
}

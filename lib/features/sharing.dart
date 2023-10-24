void init() {
  _intentDataStreamSubscription = FlutterSharingIntent.instance
      .getMediaStream()
      .listen((List<SharedFile> value) {
    setState(() {
      list = value;
    });
    print("Shared: getMedia Stream ${value.map((f) => f.value).join(",")}");
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });

  // For sharing images coming from outside the app while the app is closed
  FlutterSharingIntent.instance
      .getInitialSharing()
      .then((List<SharedFile> value) {
    print("Shared: getInitialMedia ${value.map((f) => f.value).join(",")}");
    setState(() {
      list = value;
    });
  });
}

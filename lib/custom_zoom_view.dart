import 'dart:async';
import 'package:custom_zoom_sdk/custom_zoom_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


typedef void ZoomViewCreatedCallback(ZoomViewController controller);

class CustomZoomView extends StatefulWidget {
  const CustomZoomView({
    Key? key,
    this.zoomOptions,
     this.meetingOptions,
    this.onViewCreated,
  }) : super(key: key);

  final ZoomViewCreatedCallback? onViewCreated;
  final CustomZoomOptions? zoomOptions;
  final CustomZoomMeetingOptions? meetingOptions;

  @override
  State<StatefulWidget> createState() => _CustomZoomViewState();
}

class _CustomZoomViewState extends State<CustomZoomView> {
  @override
  void initState() {
    print("platformView:- $defaultTargetPlatform");
    print("platformView:- ");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print("platformView:- $defaultTargetPlatform");
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'custom_zoom_sdk',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'custom_zoom_sdk',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the custom_zoom_sdk plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onViewCreated == null) {
      return;
    }

    var controller = new ZoomViewController._(id);
    widget.onViewCreated!(controller);
  }
}

class ZoomViewController {
  ZoomViewController._(int id)
      : _methodChannel =
            new MethodChannel('custom_zoom_sdk'),
        _zoomStatusEventChannel =
            new EventChannel("custom_zoom_event");

  final MethodChannel _methodChannel;
  final EventChannel _zoomStatusEventChannel;

  Future<dynamic> initZoom(CustomZoomOptions options) async {

    var optionMap = new Map<String, String?>();
    optionMap.putIfAbsent("appKey", () => options.appKey);
    optionMap.putIfAbsent("appSecret", () => options.appSecret);
    optionMap.putIfAbsent("domain", () => options.domain);

    return _methodChannel.invokeMethod('init', optionMap);
  }

  Future<dynamic> startMeeting(CustomZoomMeetingOptions options) async {
    var optionMap = new Map<String, String?>();
    optionMap.putIfAbsent("userId", () => options.userId);
    optionMap.putIfAbsent("displayName", () => options.displayName);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("meetingPassword", () => options.meetingPassword);
    optionMap.putIfAbsent("zoomToken", () => options.zoomToken);
    optionMap.putIfAbsent("zoomAccessToken", () => options.zoomAccessToken);
    optionMap.putIfAbsent("disableDialIn", () => options.disableDialIn);
    optionMap.putIfAbsent("disableDrive", () => options.disableDrive);
    optionMap.putIfAbsent("disableInvite", () => options.disableInvite);
    optionMap.putIfAbsent("disableShare", () => options.disableShare);
    optionMap.putIfAbsent("noDisconnectAudio", () => options.noDisconnectAudio);
    optionMap.putIfAbsent("noAudio", () => options.noAudio);

    return _methodChannel.invokeMethod('start', optionMap);
  }

  Future<dynamic> joinMeeting(CustomZoomMeetingOptions options) async {
    var optionMap = new Map<String, String?>();
    optionMap.putIfAbsent("userId", () => options.userId);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("meetingPassword", () => options.meetingPassword);
    optionMap.putIfAbsent("disableDialIn", () => options.disableDialIn);
    optionMap.putIfAbsent("disableDrive", () => options.disableDrive);
    optionMap.putIfAbsent("disableInvite", () => options.disableInvite);
    optionMap.putIfAbsent("disableShare", () => options.disableShare);
    optionMap.putIfAbsent("noDisconnectAudio", () => options.noDisconnectAudio);
    optionMap.putIfAbsent("noAudio", () => options.noAudio);

    return _methodChannel.invokeMethod('join', optionMap);
  }

  Future<dynamic> meetingStatus(String meetingId) async {

    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("meetingId", () => meetingId);

    return _methodChannel.invokeMethod('meeting_status', optionMap);
  }

  Stream<dynamic> get zoomStatusEvents {
    return _zoomStatusEventChannel.receiveBroadcastStream();
  }
}

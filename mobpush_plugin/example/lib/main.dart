import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mobpush_plugin/mobpush_plugin.dart';
import 'package:mobpush_plugin/mobpush_custom_message.dart';
import 'package:mobpush_plugin/mobpush_notify_message.dart';
import 'package:mobpush_plugin_example/app_notify_page.dart';
import 'package:mobpush_plugin_example/click_container.dart';
import 'package:mobpush_plugin_example/local_notify_page.dart';
import 'package:mobpush_plugin_example/notify_page.dart';
import 'package:mobpush_plugin_example/other_api_page.dart';
import 'package:mobpush_plugin_example/timing_notify_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {
  String _sdkVersion = 'Unknown';
  String _registrationId = 'Unknown';

  @override
  void initState() {
    super.initState();

    initPlatformState();

    if (Platform.isIOS) {
      MobpushPlugin.setCustomNotification();
      MobpushPlugin.setAPNsForProduction(false);
    }
    MobpushPlugin.addPushReceiver(_onEvent, _onError);
  }

  void _onEvent(Object event) {
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent:' + event);
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent:' + json.encode(event));
    setState(() {
      Map<String, dynamic> eventMap = json.decode(event);
      /*
       action: 0:自定义消息 1:APNs&本地通知消息 2:点击消息或其他消息
      */
      int action = eventMap['action'];
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent action: ' + action.toString());
      switch (action) {
        case 0:
        Object result = eventMap['result'];
        String resultStr = json.encode(result);
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 0:' + resultStr);
        if (resultStr.length > 0) {
          MobPushCustomMessage message = new MobPushCustomMessage.fromJson(json.decode(json.encode(result)));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(message.content),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            }
          );
        }
        break;
        case 1:
        Object result = eventMap['result'];
        String resultStr = json.encode(result);
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 1:' + resultStr);
        if (resultStr.length > 0) {
          MobPushNotifyMessage message = new MobPushNotifyMessage.fromJson(json.decode(resultStr));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Text('通知'),
                content: Text(message.content.length > 0 ? message.content : 'content'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            }
          );
        }
        break;
        case 2:
        Object result = eventMap['result'];
        String resultStr = json.encode(result);
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 2:' + resultStr);
        if (resultStr.length > 0) {
          MobPushNotifyMessage message = new MobPushNotifyMessage.fromJson(json.decode(resultStr));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(message.title.length > 0 ? message.title : 'title'),
                content: Text(message.content.length > 0 ? message.content : 'content'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            }
          );
        }
        break;
        default:
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent: Unknown Action - $action');
        break;
      }
    });
  }

  void _onError(Object event) {
    setState(() {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onError:' + event.toString());
    });
  }

  void _onAppNotifyPageTap() {
    setState(() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new AppNotifyPage())
      );
    });
  }

  void _onNotifyPageTap() {
    setState(() {
      Navigator.push(
        context, 
        new MaterialPageRoute(builder: (context) => new NotifyPage())
      );
    });
  }

  void _onTimingNotifyPageTap() {
    setState(() {
      Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new TimingNotifyPage())
      );
    });
  }

  void _onLocalNotifyPageTap() {
    setState(() {
      Navigator.push(
        context, 
        new MaterialPageRoute(builder: (context) => new LocalNotifyPage())
      );
    });
  }

  void _onOtherAPITap() {
    setState(() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new OtherApiPage())
      );
    });
  }

  
  Future<void> initPlatformState() async {
    String sdkVersion;
    
    try {
      sdkVersion = await MobpushPlugin.getSDKVersion();
    } on PlatformException {
      sdkVersion = 'Failed to get platform version.';
    }
    try {
      MobpushPlugin.getRegistrationId().then((String registrationId) {
        print(registrationId);
        setState(() {
          _registrationId = registrationId;
          print('------>#### registrationId: ' + _registrationId);
        });
      });
    } on PlatformException {
      _registrationId = 'Failed to get registrationId.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sdkVersion = sdkVersion;
    });
  }

  // 复制到剪切板
  void _onCopyButtonClicked() {
    // 写入剪切板
    Clipboard.setData(ClipboardData(text: _registrationId));
    // 验证是否写入成功
    Clipboard.getData(Clipboard.kTextPlain).then( (data) {
      String text = data.text;
      print('------>#### copyed registrationId: $text');
      if (text == _registrationId) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("恭喜🎉"),
              content: Container(
                margin: EdgeInsets.only(top: 10, bottom: 30),
                child: Text(
                  '复制成功！'
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
        );
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MobPushPlugin Demo'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ClickContainer(
                      content: 'App内推送',
                      res: 'assets/images/ic_item_app_nitify.png',
                      left: 15.0,
                      top: 15.0,
                      right: 7.5,
                      bottom: 7.5,
                      onTap: _onAppNotifyPageTap,
                    ),
                  ),
                  Expanded(
                    child: ClickContainer(
                      content: '通知',
                      res: 'assets/images/ic_item_notify.png',
                      left: 7.5,
                      top: 15.0,
                      right: 15.0,
                      bottom: 7.5,
                      onTap: _onNotifyPageTap,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ClickContainer(
                      content: '定时推送',
                      res: 'assets/images/ic_item_timing.png',
                      left: 15.0,
                      top: 7.5,
                      right: 7.5,
                      bottom: 7.5,
                      onTap: _onTimingNotifyPageTap,
                    ),
                  ),
                  Expanded(
                    child: ClickContainer(
                      content: '本地通知',
                      res: 'assets/images/ic_item_local.png',
                      left: 7.5,
                      top: 7.5,
                      right: 15.0,
                      bottom: 7.5,
                      onTap: _onLocalNotifyPageTap,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ClickContainer(
                      content: '其他API接口',
                      res: 'assets/images/ic_item_media.png',
                      left: 15.0,
                      top: 7.5,
                      right: 15.0,
                      bottom: 7.5,
                      onTap: _onOtherAPITap,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'SDK Version: $_sdkVersion\nRegistrationId: $_registrationId',
                    style: TextStyle(fontSize: 12),
                  ),
                  RaisedButton(
                    child: Text('复制'),
                    onPressed: _onCopyButtonClicked,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

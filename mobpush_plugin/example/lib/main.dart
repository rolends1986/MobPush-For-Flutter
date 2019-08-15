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
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent:' + json.encode(event));
    setState(() {
      Map<String, dynamic> eventMap = json.decode(json.encode(event));
      /*
       action: 0:自定义消息 1:APNs&本地通知消息 2:点击消息或其他消息 3:操作标签(operation:0-获取 1-设置 2-删除 3-清空) 
               4:操作别名(operation:0-获取 1-设置 2-删除) 5:绑定手机号 6:客户端发起推送
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
        case 2:
        String result = eventMap['result'];
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 2:' + result);
        if (result.length > 0) {
          MobPushNotifyMessage message = new MobPushNotifyMessage.fromJson(json.decode(result));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(message.title),
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
        case 3:
        int operation = eventMap['operation'];
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 3:' + 'operation:' + operation.toString());
        int errorCode = eventMap['errorCode'];
        if (errorCode != 0) {
          String errorDesc = eventMap['errorDesc'];
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 3:' + 'operation:' + operation.toString() + 'errorCode:' + errorCode.toString() + 'errorDesc:' + errorDesc);
        } else {
          if (operation == 0) {
            // 获取tags
            if (eventMap.containsKey('tags')) {
              String tagsStr = eventMap['tags'];
              List<String> tagsList = [];
              if (tagsStr.length > 0) {
                tagsList = tagsStr.split(',');
              }
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 3:getTags Success -> Tags: $tagsStr tagsList: $tagsList");
            }
          } else if(operation == 1) {
            print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 3: setTags Success!');
          } else if (operation == 2) {
            print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 3: deleteTags Success!');
          } else if (operation ==3) {
            print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 3: cleanTags Success!');
          }
        }
        break;
        case 4:
        int operation = eventMap['operation'];
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 4:' + 'operation:' + operation.toString());
        int errorCode = eventMap['errorCode'];
        if (errorCode != 0) {
          String errorDesc = eventMap['errorDesc'];
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 4:' + 'operation:' + operation.toString() + 'errorCode:' + errorCode.toString() + 'errorDesc:' + errorDesc);
        } else {
          if (operation == 0) {
            // 获取alias
            String alias = eventMap['alias'];
            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 4:getAlias Success -> Alias: $alias");
          } else if(operation == 1) {
            print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 4: setAlias Success!');
          } else if (operation == 2) {
            print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 4: deleteAlias Success!');
          }
        }
        break;
        case 5:
        int errorCode = eventMap['errorCode'];
        if (errorCode != 0) {
          String errorDesc = eventMap['errorDesc'];
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 5:' + 'errorCode:' + errorCode.toString() + 'errorDesc:' + errorDesc);
        } else {
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 5: bindPhoneNum Success!');
        }
        break;
        case 6:
        int errorCode = eventMap['errorCode'];
        if (errorCode != 0) {
          String errorDesc = eventMap['errorDesc'];
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 6:' + 'errorCode:' + errorCode.toString() + 'errorDesc:' + errorDesc);
        } else {
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>onEvent 6: sendMessage Success!');
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String sdkVersion;
    String registrationId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      sdkVersion = await MobpushPlugin.getSDKVersion();
    } on PlatformException {
      sdkVersion = 'Failed to get platform version.';
    }
    try {
      registrationId = await MobpushPlugin.getRegistrationId();
      print('------>#### registrationId: ' + registrationId);
    } on PlatformException {
      registrationId = 'Failed to get registrationId.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sdkVersion = sdkVersion;
      _registrationId = registrationId;
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
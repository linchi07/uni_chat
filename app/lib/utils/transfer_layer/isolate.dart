import 'dart:isolate';

import 'package:entao_jsonrpc/entao_jsonrpc.dart';

/// 管理一个isolate（只负责管理不负责发送和接收信息）
/// 应该重写这个基类的onSpawn方法,来绑定不同的服务
/// manger应该是唯一的singleton，挂在主线程上，而其他线程可以持有messenger
class IsolateManager {
  //这两个port只是管理isolate用，不参与rpc
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  late Isolate _isolate;
  bool _isSpawned = false;
  //因为他的listen是分开的，啥时候dart能出一个await new message 这种东西就更好的
  //我只能接收之后放在cache。
  SendPort? _messengerSendPortCache;
  IsolateManager.internal();

  Future<void> init() async {
    if (_isSpawned) return;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_entryPoint, _receivePort);
    _sendPort = await _receivePort.first;
    _receivePort.listen((data) {
      if (data is SendPort) {
        _messengerSendPortCache = data;
      }
    });
    _isSpawned = true;
  }

  void _entryPoint(ReceivePort port) {
    var rp = ReceivePort();
    var sp = port.sendPort;
    sp.send(rp.sendPort);
    var rpcs = RpcServer();
    onSpawn(rpcs);
    List<SendPort> sendPorts = [];
    List<ReceivePort> receivePorts = [];
    //这里监听，如果有新的data就代表是一个messenger创建请求，创建一个新的receive port绑定好消息实例之后发送一个sendport。
    // 这两个list是因为我不知道对于一个listen函数，如果只是函数内临时变量，他会不会导致gc销毁？
    rp.listen((sendPort) {
      if (sendPort == null || sendPort is! SendPort) return;
      sendPorts.add(sendPort);
      receivePorts.add(ReceivePort());
      receivePorts.last.listen((data) {
        sendPort.send(rpcs.onRecvText(data));
      });
      sendPorts.last.send(receivePorts.last.sendPort);
    });
  }

  ///获取目标isolate的一个sendPort，
  ///简单来讲，创建一个messenger的流程是->自己isolate先创建好rcvPort，然后把sendPort发送到主线程的isolate manager，
  ///然后主线程的isolate manager会返回一个目标isolate sendPort，然后用这个sendPort去构建Messenger来通讯
  ///（很绕，主要是dart他只能在线程中传递senport，rcvport必须在isolate自己这里创建，当然也理解）
  Future<SendPort> getSendPort(SendPort sp) async {
    _messengerSendPortCache = null;
    //发送，那边也会回复
    _sendPort.send(sp);
    //这里自旋等待
    while (_messengerSendPortCache == null) {
      await Future.delayed(Duration(milliseconds: 1));
    }
    var s = _messengerSendPortCache!;
    _messengerSendPortCache = null;
    return s;
  }

  /// 当创建一个isolate的时候，应该调用这个方法，来初始化服务类，以及绑定server的方法
  void onSpawn(RpcServer server) {}

  void kill() {
    _isolate.kill();
    _receivePort.close();
    _isSpawned = false;
  }
}

class IsolateMessenger {
  late final SendPort _sendPort;
  late final ReceivePort _receivePort;
  late final RpcClient _rpcClient;
  IsolateMessenger(ReceivePort receivePort, SendPort sendPort) {
    _receivePort = receivePort;
    _sendPort = sendPort;
    _rpcClient = RpcClient();
    _receivePort.listen((data) {
      _rpcClient.onRecvText(data);
    });
  }

  Future<Object?> send(
    String method, {
    Map<String, dynamic>? map,
    List<dynamic>? list,
  }) async {
    return await _rpcClient.request(
      (str) {
        _sendPort.send(str);
        return true;
      },
      method,
      map: map,
      list: list,
    );
  }
}

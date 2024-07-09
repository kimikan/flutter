
import 'dart:async';
import 'dart:io';

import 'package:web_socket_client/web_socket_client.dart' as ws;
class OtaCommand {
  String command;
  String fileName;
  int fileLen;
  String md5;
  String time;

  OtaCommand(this.command, this.fileName, this.fileLen, this.md5, this.time);

  Map toJson() {
    return {
      'command': command,
      'file_name': fileName,
      'len': fileLen,
      'md5': md5,
      'time': time,
    };
  }

  @override
  String toString() {
    return '''{"command":"$command", "file_name":"$fileName", "len":$fileLen, "md5":"$md5", "time":"$time"}''';
  }
}

class OtaConnection {
  final OtaCommand _command;
  final String _server;

  ws.WebSocket? _socket;
  String? _taskId;

  OtaConnection(this._command, this._server, {this.onEnd, this.onLog});

  Function? onEnd;
  Function(String)? onLog;

  log(String str) {
    if(onLog != null) {
      onLog!(str);
    }
  }

  init() async {
    var url = Uri.parse(_server);
    const backoff = ws.ConstantBackoff(Duration(seconds: 5));
    _socket = ws.WebSocket(url, backoff: backoff);
    _socket?.connection.listen((event) {
      log("connection changed to: $event");
    });

    await _socket?.connection.firstWhere((state) => state is ws.Connected);
    _socket?.send(_command.toString());
    log("start to upgrade");

    _socket?.messages.listen((event) {
      log("response received: $event");
      var str = event.toString();
      if (str.startsWith("result:")) {
        if (str.contains("success") || str.contains("fail")) {
          stop();
        }
      } else if(str.startsWith("taskid:")) {
        //_taskId = await _socket?.messages.first;
        log("task id $str received");

        var file = File(_command.fileName);
        file.openRead().listen((event) {
          _socket?.send(event);
        });
        log("file upload successfully");
      }
    });
  }

  Timer? _timer;

  start() async {
    if(_socket == null) {
      try {
        init().catchError((e){
          log(e.toString());
          stop();
        });
      } catch (e) {
        log(e.toString());
        stop();
      }
    }

    if(_timer == null) {
      const Duration duration = Duration(seconds: 5);
      _timer = Timer.periodic(duration, (timer) {
        //do periodic
        if(_taskId != null) {
          if(_socket?.connection.state is ws.Connected) {
            _socket?.send("get_result");
          }
        } //end if
      });
    } //end if
  }

  stop() async {
    _timer?.cancel();
    _socket?.close();
    _timer = null;
    _socket = null;

    if(onEnd != null) {
      onEnd!();
    }
    log("stopped");
  }
}

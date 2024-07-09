import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knife/models/ota.dart';
import 'package:knife/pages/helper.dart';
import 'package:web_socket_client/web_socket_client.dart' as ws;

import '../layout.dart';

class OTAPage extends StatelessWidget {
  const OTAPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'OtaTool',
      body: MainTool(),
    );
  }
}

class MainTool extends StatefulWidget {
  const MainTool({Key? key}) : super(key: key);

  @override
  State<MainTool> createState() => _MainToolState();
}

class _MainToolState extends State<MainTool> {
  ValueNotifier<String> fileName = ValueNotifier("");
  ValueNotifier<String> md5Value = ValueNotifier("");
  ValueNotifier<int> fileLen = ValueNotifier(0);

  ValueNotifier<bool> isRunning = ValueNotifier(false);

  BuildContext? _context;

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          "Photolysis",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  _selectFile() async {
    var r = await FilePicker.platform.pickFiles(allowMultiple: false);
    md5Value.value = "";
    fileName.value = "";

    if (r != null && r.files.isNotEmpty) {
      var path = r?.files.single?.path;
      if (path != null) {
        File file = File(path);
        fileLen.value = file.lengthSync();
        //var hash = md5.convert().toString();
        var digest = await md5.bind(file.openRead()).first;
        md5Value.value = digest.toString();
        fileName.value = file.path;
        //showInfoDialog(_context, "x","dd");
      } else {
        showInfoDialog(_context, "err", "invalid selected file");
      }
    } else {
      //showInfoDialog(_context, "err", "invalid selected");
    }
  }

  final TextEditingController _controller =
      TextEditingController(text: "ws://172.18.18.11:8765");

  Widget _buildTable(context) {
    return Center(
      child: Table(
        border: TableBorder.all(
          style: BorderStyle.solid,
          width: 2,
        ),
        columnWidths: const {
          0: FixedColumnWidth(350),
          2: IntrinsicColumnWidth(flex: 2),
        },
        children: [
          TableRow(
              decoration: const BoxDecoration(color: Colors.grey),
              children: [
                const SizedBox(
                  height: 33,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "server: ",
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'ws://',
                    ),
                  ),
                ),
              ]),
          TableRow(children: [
            SizedBox(
              height: 33,
              child: TextButton(
                  onPressed: () async {
                    await _selectFile();
                  },
                  child: const Text(
                    "select file: ",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  )),
            ),
            ValueListenableBuilder(
              valueListenable: fileName,
              builder: (context, s, child) {
                return Text(s);
              },
            ),
          ]),
          TableRow(
              decoration: const BoxDecoration(color: Colors.white),
              children: [
                const SizedBox(height: 33, child: Center(child: Text("md5: "))),
                ValueListenableBuilder(
                  valueListenable: md5Value,
                  builder: (context, s, child) {
                    return Text(s);
                  },
                ),
              ]),
          TableRow(
              decoration: const BoxDecoration(color: Colors.white),
              children: [
                const SizedBox(
                    height: 33, child: Center(child: Text("file len: "))),
                ValueListenableBuilder(
                  valueListenable: fileLen,
                  builder: (context, s, child) {
                    return Text(s.toString());
                  },
                ),
              ]),
        ],
      ),
    );
  }

  Widget _buildStartButton(context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1.0, 15, 8.0, 10),
        child: TextButton(
            onPressed: () async {
              //await _selectFile();
              if (isRunning.value) {
                return;
              }
              await _upgrade();
            },
            child: const Text(
              "push me to start upgrade ",
              style: TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline,
              ),
            )),
      ),
    );
  }

  OtaConnection? _ota;

  _upgrade() async {
    if (fileLen.value <= 0 || md5Value.value.isEmpty) {
      showInfoDialog(_context, "err", "selected upgrade img first");
      return;
    }
    var ota = OtaCommand("upgrade", fileName.value, fileLen.value,
        md5Value.value, DateTime.now().toString());
    isRunning.value = true;
    _ota ??= OtaConnection(ota, _controller.value.text, onEnd: () {
      isRunning.value = false;
    }, onLog: (log) {
      _addResult(log);
    });
    await _ota?.start();
  }

  final List<String> _strings = List.generate(0, (index) => "value of $index");
  final ValueNotifier<bool> _updateResult = ValueNotifier(false);

  _addResult(String result) {
    _strings.insert(0, "${DateTime.now().toString()}   $result");
    _updateResult.value = !_updateResult.value;
  }

  _clearResult() {
    _strings.clear();
    _updateResult.value = !_updateResult.value;
  }

  _buildResultView(context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ValueListenableBuilder(
            valueListenable: _updateResult,
            builder: (context, _b, child) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _strings.length,
                  itemBuilder: (context, i) {
                    return Text(_strings[i]);
                  });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildHeader(context),
          _buildTable(context),
          ValueListenableBuilder(
            valueListenable: isRunning,
            builder: (context, b, child) {
              if (!b) {
                return _buildStartButton(context);
              }
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(1.0, 15, 8.0, 10),
                      child: TextButton(
                          onPressed: () async {
                            _ota?.stop();
                          },
                          child: const Text(
                            "cancel upgrade ",
                            style: TextStyle(
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                            ),
                          )),
                    ),
                  ),
                ],
              );
            },
          ),
          _buildResultView(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _ota?.stop();
  }
}

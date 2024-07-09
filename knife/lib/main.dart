import 'package:flutter/material.dart';
import 'package:knife/layout.dart';
import 'package:knife/pages/OtaTool.dart';
import 'package:knife/pages/drawer_content.dart';
import 'package:side_bar_custom/side_bar_custom.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolbox',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      /*
      home: AdaptiveLayout(pages: const <String, Widget>{
        "OTATool": OTAPage(),
        "Other Page": SecondPage(),
      },),  */
      home: Scaffold(
        body: SideBar(
          config: SideBarConfig(iconSize: 40),
          items: [
            SideBarItem(text: "Home", icon: Icons.home, tooltipText: "home"),
            SideBarItem(text: "OTA", icon: Icons.adb, tooltipText: "a tool for ota upgrade"),
            SideBarItem(text: "Add new tool", icon: Icons.add, tooltipText: "add panel"),
          ],
          children: const [
            Center(
              child: Text("Dashboard"),
            ),
            Center(
              child: OTAPage(),
            ),
            Center(
              child: Text("Add ...."),
            )
          ],
        ),
      ),
    );
  }
}


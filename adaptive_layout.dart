import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:split_view/split_view.dart';

const _pages = <String, Widget>{
  'First Page': FirstPage(),
  'Second Page': SecondPage(),
};

class AdaptiveLayout extends StatelessWidget {
  AdaptiveLayout({Key? key, this.pages = _pages}) : super(key: key) {
    selectedPageName = ValueNotifier(_pages.keys.first);
  }

  static const double breakWidth = 600;
  static const double defaultWidth = 340;

  final Map<String, Widget> pages;

  late final ValueNotifier<String?>
      selectedPageName; // = ValueNotifier(pages.keys.first);

  void onPressed(context, String? value) {
    selectedPageName.value = value;
    //selectedPageName.notifyListeners();
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var menuWidget = ValueListenableBuilder(
      builder: (context, String? value, child) {
        return AppMenu(
          selectedPageName: value,
          pages: pages,
          onPressed: (page) => onPressed(context, page),
        );
      },
      valueListenable: selectedPageName,
    );

    var bodyWidget = ValueListenableBuilder(
        valueListenable: selectedPageName,
        builder: (context, String? value, child) {
          return pages[value] ?? const Text('wrong page');
        });

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= breakWidth) {
        return Scaffold(
          body: _buildBodyWithSplitView(menuWidget, bodyWidget),
        );
      } //end if

      return Scaffold(
        body: bodyWidget,
        drawer: SizedBox(
          width: defaultWidth,
          child: Drawer(
            child: menuWidget,
          ),
        ),
      );
    });
  }

  Widget _buildBodyWithFixView(Widget menuWidget, Widget bodyWidget) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: menuWidget,
        ),
        SizedBox(
          width: 4,
          child: Container(
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: bodyWidget,
          flex: 4,
        ),
      ],
    );
  }

  Widget _buildBodyWithSplitView(menuWidget, bodyWidget) {
    return SplitView(
      gripSize: 3,
      controller: SplitViewController(
          weights: [0.2, 0.8], limits: [WeightLimit(min: 0.2), WeightLimit(min: 0.2)]),
      viewMode: SplitViewMode.Horizontal,
      indicator: const SplitIndicator(
        viewMode: SplitViewMode.Horizontal,
      ),
      activeIndicator: const SplitIndicator(
        viewMode: SplitViewMode.Horizontal,
        isActive: true,
      ),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: defaultWidth),
          child: menuWidget,
        ),
        bodyWidget
      ],
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({Key? key, this.title, this.body}) : super(key: key);

  final String? title;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final ancestorScaffold = Scaffold.maybeOf(context);
    final hasDrawer = ancestorScaffold != null && ancestorScaffold.hasDrawer;
    return Scaffold(
        appBar: AppBar(
            title: Text(title ?? ''),
            leading: hasDrawer
                ? IconButton(
                    onPressed: (hasDrawer
                        ? () => ancestorScaffold.openDrawer()
                        : null),
                    icon: const Icon(Icons.menu))
                : null),
        body: body);
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SimplePage(title: 'first', body: Text('first page'));
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SimplePage(title: 'second', body: Text('second page'));
  }
}

class AppMenu extends StatelessWidget {
  const AppMenu(
      {Key? key, required this.pages, this.onPressed, this.selectedPageName})
      : super(key: key);

  final Function(String?)? onPressed;

  final String? selectedPageName;

  final Map<String, Widget> pages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: ListView(
        children: [
          for (var pageName in pages.keys)
            PageListTile(
              selectedPageName: selectedPageName,
              pageName: pageName,
              onPressed: onPressed,
            ),
        ],
      ),
    );
  }
}

class PageListTile extends StatelessWidget {
  const PageListTile(
      {Key? key, required this.pageName, this.selectedPageName, this.onPressed})
      : super(key: key);

  final String pageName;
  final String? selectedPageName;

  final Function(String?)? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selectedPageName == pageName,
      //selectedTileColor: Colors.lightBlue,
      leading: Opacity(
        opacity: selectedPageName == pageName ? 1.0 : 0.0,
        child: const Icon(Icons.check),
      ),
      title: Text(pageName),
      onTap: () {
        if (onPressed != null) {
          onPressed!(pageName);
        }
      },
    );
  }
}

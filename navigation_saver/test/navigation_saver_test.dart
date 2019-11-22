import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_saver/navigation_saver.dart';

void main() {
  testWidgets(
    'initially we restore nothing',
    (WidgetTester tester) async {
      // Setup in memory navigation saver
      Iterable<RouteSettings> savedRoutes = <RouteSettings>[];
      final NavigationSaver navigationSaver = NavigationSaver(
        (Iterable<RouteSettings> activeRoutes) async {
          savedRoutes = activeRoutes;
        },
        () async => savedRoutes,
      );

      // Build our app and trigger a frame.
      await tester.pumpWidget(_MyApp(navigationSaver));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    },
  );

  testWidgets(
    'if we push new widget then it is pushed',
    (WidgetTester tester) async {
      // Setup in memory navigation saver
      Iterable<RouteSettings> savedRoutes = <RouteSettings>[];
      final NavigationSaver navigationSaver = NavigationSaver(
        (Iterable<RouteSettings> activeRoutes) async {
          savedRoutes = activeRoutes;
        },
        () async => savedRoutes,
      );

      // Build our app and trigger a frame.
      await tester.pumpWidget(_MyApp(navigationSaver));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'if we push new widget and restore it - same widgets are visible',
    (WidgetTester tester) async {
      // Setup in memory navigation saver
      Iterable<RouteSettings> savedRoutes = <RouteSettings>[];
      final NavigationSaver navigationSaver = NavigationSaver(
        (Iterable<RouteSettings> activeRoutes) async {
          savedRoutes = activeRoutes;
        },
        () async => savedRoutes,
      );

      // Build our app and trigger a frame.
      final _MyApp myApp = _MyApp(navigationSaver);
      await tester.pumpWidget(myApp);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);

      // Restore current navigation stack. Because it calls with an existing stack - nothing should change
      await navigationSaver.restorePreviousRoutes(myApp._latestContext);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter still incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'if we push new widget, lock saving, kill back stack - it is restored',
    (WidgetTester tester) async {
      // Setup in memory navigation saver
      bool saveRoutes = true;
      Iterable<RouteSettings> savedRoutes = <RouteSettings>[];
      final NavigationSaver navigationSaver = NavigationSaver(
        (Iterable<RouteSettings> activeRoutes) async {
          if (saveRoutes) {
            savedRoutes = activeRoutes;
          }
        },
        () async => savedRoutes,
      );

      // Build our app and trigger a frame.
      final _MyApp myApp = _MyApp(navigationSaver);
      await tester.pumpWidget(myApp);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);

      // Disable stack saving logic. So we freeze it with 2 widgets inside
      saveRoutes = false;

      // Drop one widget
      Navigator.of(myApp._latestContext).pop();
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Restore old widget tree
      await navigationSaver.restorePreviousRoutes(myApp._latestContext);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Verify that our counter still incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    },
  );
}

// ignore: must_be_immutable
class _MyApp extends StatelessWidget {
  _MyApp(this._navigationSaver);

  final NavigationSaver _navigationSaver;
  BuildContext _latestContext;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: NavigationSaver.restoreRouteName,
      onGenerateRoute: (RouteSettings routeSettings) => _navigationSaver.onGenerateRoute(
        routeSettings,
        (
          RouteSettings settings, {
          NextPageInfo nextPageInfo,
        }) =>
            MaterialPageRoute(
          builder: (BuildContext context) {
            _latestContext = _latestContext ?? context;
            final int currentDeepIndex = (settings.arguments as int) ?? 0;
            return Scaffold(
              body: Column(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/next',
                      arguments: currentDeepIndex + 1,
                    ),
                    icon: Icon(Icons.add),
                  ),
                  Text(currentDeepIndex.toString()),
                ],
              ),
            );
          },
          settings: routeSettings,
        ),
      ),
      navigatorObservers: [_navigationSaver],
    );
  }
}

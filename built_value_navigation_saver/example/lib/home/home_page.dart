import 'package:example/home/home_page_arguments.dart';
import 'package:flutter/material.dart';
import 'package:navigation_saver/navigation_saver.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    @required this.initialCounter,
    this.nextPageInfo,
  }) : super(key: key);

  final int initialCounter;
  final NextPageInfo nextPageInfo;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _counter = widget.initialCounter;

    if (null != widget.nextPageInfo) {
      switch (widget.nextPageInfo.routeName) {
        case '/next':
          awaitNextPageResult(widget.nextPageInfo.resultFuture);
          break;
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text('Flutter Demo Home Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.display1,
              ),
              RaisedButton(
                onPressed: () async {
                  awaitNextPageResult(
                    await Navigator.of(context).pushNamed(
                      "/next",
                      arguments: MyHomePageArguments((b) => b..deepIndex = _counter * 100),
                    ),
                  );
                },
                child: Text('navigate next'),
              ),
              if (Navigator.of(context).canPop())
                RaisedButton(
                  onPressed: () => Navigator.of(context).pop(_counter),
                  child: Text('navigate back'),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      );

  void awaitNextPageResult(Future resultFuture) async {
    final result = await resultFuture;
    if (null == result) return;

    _key.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.toString())));
  }
}

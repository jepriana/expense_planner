import './widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './models/transaction.dart';
import './widgets/new_transaction.dart';
import 'package:uuid/uuid.dart';
import './widgets/chart.dart';
import 'dart:io';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.amberAccent,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              button: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var _uuid = Uuid();

  final List<Transaction> _userTransactions = [];
  /*
    Transaction(
        id: Uuid().v1(),
        title: 'New Phone',
        amount: 299.99,
        date: DateTime.now()),
    Transaction(
        id: Uuid().v1(),
        title: 'Cheetos Snack',
        amount: 0.99,
        date: DateTime.now()),
    Transaction(
      id: Uuid().v1(),
      title: 'New Laptop',
      amount: 1499.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: Uuid().v1(),
      title: 'New Bag',
      amount: 49.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: Uuid().v1(),
      title: 'Pertalite Gas',
      amount: 1.49,
      date: DateTime.now(),
    ),
    Transaction(
      id: Uuid().v1(),
      title: 'Topup E-Money',
      amount: 10,
      date: DateTime.now(),
    ),
    Transaction(
      id: Uuid().v1(),
      title: 'New Udemy Course',
      amount: 0.99,
      date: DateTime.now(),
    ),
  ];*/

  bool _showChart = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifeCicle(AppLifecycleState state) {
    print(state);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  List<Transaction> get _recentTransaction {
    return _userTransactions.where((trx) {
      return trx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String trxTitle, double trxAmount, DateTime trxDate) {
    final newTrx = Transaction(
      id: _uuid.v1(),
      title: trxTitle,
      amount: trxAmount,
      date: trxDate,
    );

    setState(() {
      _userTransactions.add(newTrx);
    });
  }

  void _deleteTransaction(String trxID) {
    setState(() {
      _userTransactions.removeWhere((trx) => trx.id == trxID);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () {
                    _startAddNewTransaction(context);
                  },
                ),
              ],
            ),
          )
        : AppBar(
            title: Text('Personal Expenses'),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.add,
                ),
                onPressed: () {
                  _startAddNewTransaction(context);
                },
              ),
            ],
          );

    final trxlistWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.75,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show chart',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Switch.adaptive(
                    activeColor: Theme.of(context).accentColor,
                    value: _showChart,
                    onChanged: (value) {
                      setState(() {
                        _showChart = value;
                      });
                    },
                  ),
                ],
              ),
            if (!isLandscape)
              Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.25,
                child: Chart(_recentTransaction),
              ),
            if (!isLandscape) trxlistWidget,
            if (isLandscape)
              _showChart
                  ? Container(
                      height: (mediaQuery.size.height -
                              appBar.preferredSize.height -
                              mediaQuery.padding.top) *
                          0.75,
                      child: Chart(_recentTransaction),
                    )
                  : trxlistWidget,
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () {
                      _startAddNewTransaction(context);
                    },
                    child: Icon(
                      Icons.add,
                    ),
                  ),
          );
  }
}

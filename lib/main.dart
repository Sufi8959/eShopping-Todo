import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/themes.dart';
import 'package:shopping_list_app/models/appstate.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';
//import 'package:shopping_list_app/models/appstate.dart';
import 'package:shopping_list_app/redux/reducers.dart';
import 'package:flutter_redux/flutter_redux.dart';
// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';

void main() async {
  final store = Store<Appstate>(reducerTheme,
      initialState: Appstate(theme: AppTheme.light));
  runApp(
    MyApp(store: store),
  );
}

class MyApp extends StatelessWidget {
  final Store<Appstate> store;
  const MyApp({super.key, required this.store});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: StoreConnector<Appstate, ThemeData>(
        converter: (Store<Appstate> store) {
          return store.state.theme == AppTheme.light ? lightTheme : darkTheme;
        },
        builder: (BuildContext context, ThemeData theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const GroceryList(),
          );
        },
      ),
    );
  }
}

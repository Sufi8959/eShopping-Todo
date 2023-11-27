import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/appstate.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'dart:convert';
import 'package:shopping_list_app/redux/actions.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _newGroceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('shoppinglistapp-3914a-default-rtdb.firebaseio.com',
        'Shopping-List-App.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Something went wrong. Please try again later.';
        });
        print(response);
      }
      print(response.body);
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catitem) => catitem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _newGroceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
      });
      print(e.toString());
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _newGroceryItems.add(newItem);
    });
  }

  void _removeItems(GroceryItem item) async {
    final index = _newGroceryItems.indexOf(item);
    setState(() {
      _newGroceryItems.remove(item);
    });
    final url = Uri.https('shoppinglistapp-3914a-default-rtdb.firebaseio.com',
        'Shopping-List-App/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _newGroceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //  print('Build called');
    Widget content = const Center(
      child: Text('No items yet'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_newGroceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _newGroceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _removeItems(_newGroceryItems[index]);
          },
          key: ValueKey(_newGroceryItems[index].id),
          child: ListTile(
            title: Text(_newGroceryItems[index].name),
            leading: Container(
              width: 25,
              height: 25,
              color: _newGroceryItems[index].category.color,
            ),
            trailing: Text(_newGroceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grocery List',
        ),
      ),
      body: content,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  _addItem();
                },
                tooltip: "Add Item",
                child: const Icon(Icons.add),
              ),
              const SizedBox(
                width: 20,
              ),
              FloatingActionButton(
                onPressed: () {
                  StoreProvider.of<Appstate>(context).dispatch(
                    ToggleThemeAction(),
                  );
                },
                tooltip: 'Toggle',
                child: const Icon(Icons.brightness_2_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

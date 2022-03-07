import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todo {
  String? name;
  bool? checked;
  Todo({required this.name, required this.checked});

  Todo.fromMap(Map map) {
    this.name = map['name'];
    this.checked = map['checked'];
  }
  Map toMap() {
    return {
      'name': this.name,
      'checked': this.checked,
    };
  }
}

class TodoItem extends StatelessWidget {
  TodoItem({
    required this.todo,
    required this.onTodoChanged,
  }) : super(key: ObjectKey(todo));

  final Todo todo;
  final onTodoChanged;
//Function
  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return TextStyle(
      color: Colors.yellow,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: CircleAvatar(
        child: Text(todo.name![0]),
      ),
      title: Text(todo.name!, style: _getTextStyle(todo.checked!)),
    );
  }
}

//Widget
class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => new _TodoListState();
}

// Widget
class _TodoListState extends State<TodoList> {
  final TextEditingController _textFieldController = TextEditingController();
  List<Todo> _todos = <Todo>[];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  initState() {
    super.initState();
    initPage();
  }

  initPage() async {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('My To-Do List'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _displayDialog("deleteList");
              },
              child: Icon(
                Icons.delete_forever,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      //Conditioning
      body: _todos.length != 0
          ? ListView(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              children: _todos.map((Todo todo) {
                return TodoItem(
                  todo: todo,
                  onTodoChanged: _handleTodoChange,
                );
              }).toList(),
            )
          : Center(
              child: Text("Nothing to show"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog("addItem"),
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

//Function
  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.checked = !todo.checked!;
    });
    saveData();
  }

//Function
  void _addTodoItem(String? name) {
    if (name == "") {
      final snackBar = SnackBar(
        content: const Text('To-Do Item is empty'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        _todos.add(Todo(name: name, checked: false));
      });

      saveData();
    }

    _textFieldController.clear();
  }

  saveData() async {
    SharedPreferences prefs = await _prefs;
    List<String> spList =
        _todos.map((item) => json.encode(item.toMap())).toList();
    await prefs.setStringList('list', spList);
  }

  loadData() async {
    SharedPreferences prefs = await _prefs;
    List<String>? spList = prefs.getStringList('list');
    if (spList == null) {
      setState(() {
        _todos = [];
      });
      return;
    } else {
      setState(() {
        _todos = spList.map((item) => Todo.fromMap(json.decode(item))).toList();
      });
    }
  }

  deleteData() async {
    SharedPreferences prefs = await _prefs;
    List<String>? spList = prefs.getStringList('list');
    if (spList == null) {
      final snackBar = SnackBar(
        content: const Text('Nothing to be deleted'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else
      SharedPreferences prefs = await _prefs;
    await prefs.remove('list');
    initPage();
  }

//Function
  Future<void> _displayDialog(String dialog) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return dialog == "addItem"
            ? AlertDialog(
                title: const Text('Add a new To Do item'),
                content: TextField(
                  controller: _textFieldController,
                  decoration:
                      const InputDecoration(hintText: 'Type your new To Do'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addTodoItem(_textFieldController.text);
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: const Text('Are you sure to delete list ?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteData();
                    },
                  ),
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // _addTodoItem(_textFieldController.text);
                    },
                  ),
                ],
              );
      },
    );
  }
}

//Main widget
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.blueGrey),
      title: 'Todo list',
      home: new TodoList(),
    );
  }
}

void main() => runApp(new TodoApp());

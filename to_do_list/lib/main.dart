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

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

// Widget
class _TodoListState extends State<TodoList> {
  final TextEditingController _textFieldController = TextEditingController();
  List<Todo> _todos = <Todo>[];

  @override
  // ignore: must_call_super
  initState() {
    initApp();
  }

  initApp() async {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('My To-Do List'),
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
          : Text("Nothing to show"),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

//Function
  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.checked = !todo.checked!;
    });
  }

//Function
  void _addTodoItem(String? name) {
    print("name " + name.toString());
    if (name == "") {
      final snackBar = SnackBar(
        content: const Text('Insert To Do Item Properly'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
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
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> spList =
        _todos.map((item) => json.encode(item.toMap())).toList();
    print(spList);
    await _prefs.setStringList('list', spList);
  }

  loadData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String>? spList = _prefs.getStringList('list');
    if (spList == null) {
    } else {
      setState(() {
        _todos = spList.map((item) => Todo.fromMap(json.decode(item))).toList();
      });
    }
  }

//Function
  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new To Do item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your new To Do'),
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
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.blueGrey),
      title: 'Todo list',
      home: new TodoList(),
    );
  }
}

void main() => runApp(new TodoApp());

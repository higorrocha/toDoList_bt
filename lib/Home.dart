import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listTodo = [];
  Map<String, dynamic> _lastTaskRemoved = Map();
  TextEditingController _controllerTask = TextEditingController();

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  _saveTask() {
    String textWritten = _controllerTask.text;

    Map<String, dynamic> task = Map();
    task["Title"] = textWritten;
    task["done"] = false;

    setState(() {
      _listTodo.add(task);
    });
    _saveFile();
    _controllerTask.text = "";
  }

  _saveFile() async {

    var file = await _getFile();

    String data = json.encode(_listTodo);
    file.writeAsString(data);
  }

  _readFile() async {
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch(e){
      return "";
    }
  }

  @override
  void initState(){
    super.initState();

    _readFile().then((data){
      setState(() {
        _listTodo = json.decode(data);
      });
    });
  }

  Widget createItemList(context, index){

    final item = _listTodo[index]["Title"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          _lastTaskRemoved = _listTodo[index];

          _listTodo.removeAt(index);
          _saveFile();

          //snackbar
          final snackbar = SnackBar(
            //backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            content: Text("Task removed!"),
            action: SnackBarAction(
                label: "Undo",
                onPressed: (){

                  setState(() {
                    _listTodo.insert(index, _lastTaskRemoved);
                  });
                  _saveFile();

                }
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text( _listTodo[index]['Title'] ),
          value: _listTodo[index]['realizada'],
          onChanged: (valueChanged){

            setState(() {
              _listTodo[index]['realizada'] = valueChanged;
            });

            _saveFile();

          },
        )
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do List"),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Add Tasks"),
                  content: TextField(
                    controller: _controllerTask,
                    decoration: InputDecoration(
                      labelText: "Type your task"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel")
                    ),
                    TextButton(
                        onPressed: (){
                          _saveTask();
                          Navigator.pop(context);
                        },
                        child: Text("Save")
                    )
                  ],
                );
              }
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _listTodo.length,
                itemBuilder: createItemList
            ),
          )
        ],
      ),
    );
  }
}

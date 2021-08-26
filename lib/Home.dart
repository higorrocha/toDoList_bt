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

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  _saveFile() async {

    var file = await _getFile();

    Map<String, dynamic> task = Map();
    task["Title"] = "Go to the market";
    task["done"] = false;
    _listTodo.add(task);

    String data = json.encode(_listTodo);
    file.writeAsString(data);
  }

  _readFile() async {
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch(e){
      return null;
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
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text( _listTodo[index]["Title"] ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}

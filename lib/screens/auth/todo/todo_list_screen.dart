import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:case_codeway/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TodoListScreen extends StatelessWidget {
  final TodoController _todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My TODOs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed('/createTodo'), // TODO oluşturma ekranına geçiş
          ),
        ],
      ),
      body: Obx(() {
        if (_todoController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_todoController.todoList.isEmpty) {
          return Center(child: Text('No TODOs available'));
        }

        return ListView.builder(
          itemCount: _todoController.todoList.length,
          itemBuilder: (context, index) {
            TodoModel todo = _todoController.todoList[index];
            return ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.note),
              trailing: Text('Priority: ${todo.priority}'),
              onTap: () {
                // TODO: Tap ile detay ekranına yönlendir
              },
            );
          },
        );
      }),
    );
  }
}
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
  Get.toNamed('/updateTodo', arguments: todo); // Güncelleme ekranına yönlendirme
},

                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Kullanıcıdan silme işlemi için onay alalım
                      bool confirmed = await Get.defaultDialog(
                        title: "Delete TODO",
                        middleText: "Are you sure you want to delete this TODO?",
                        textCancel: "Cancel",
                        textConfirm: "Delete",
                        confirmTextColor: Colors.white,
                        onConfirm: () => Get.back(result: true),
                        onCancel: () => Get.back(result: false),
                      );
                      if (confirmed) {
                        await _todoController.deleteTodo(todo.id); // Silme işlemi
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                // Detay ekranına veya başka bir işlem ekranına yönlendirme yapılabilir
              },
            );
          },
        );
      }),
    );
  }
}

import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:case_codeway/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için intl paketi

class TodoListScreen extends StatelessWidget {
  final TodoController _todoController = Get.put(TodoController());

  // Önceliğe göre renk döndüren bir fonksiyon
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green; // Low
      case 2:
        return Colors.yellow; // Medium
      case 3:
        return Colors.red; // High
      default:
        return Colors.grey;
    }
  }

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

            // Tarih ve saat formatlama
            String formattedDate = DateFormat('yyyy-MM-dd').format(todo.dueDate);
            String formattedTime = DateFormat('HH:mm').format(todo.dueDate);

            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar( // Priority'ye göre renkli yuvarlak
                    backgroundColor: getPriorityColor(todo.priority),
                    radius: 12, // Yuvarlağın boyutu
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seçilen tarih ve saat birlikte gösteriliyor
                      Text(
                        'Due Date: $formattedDate ${formattedTime != '00:00' ? 'at $formattedTime' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12, // Tarih ve saatin boyutunu küçülttük
                        ),
                      ),
                      SizedBox(height: 5),
                      // Başlık (Title)
                      Text(
                        todo.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 5),
                      // Not (Note)
                      Text(
                        todo.note,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  // Eğer TODO'ya dosya eklenmişse, simge gösterelim
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (todo.attachmentUrl != null && todo.attachmentUrl!.isNotEmpty)
                        Icon(Icons.attach_file, color: Colors.blue), // Dosya simgesi
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Get.toNamed('/updateTodo', arguments: todo); // TODO güncelleme ekranına yönlendirme
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
                ),
                Divider(color: Colors.grey), // Her TODO'nun altına gri çizgi ekliyoruz
              ],
            );
          },
        );
      }),
    );
  }
}

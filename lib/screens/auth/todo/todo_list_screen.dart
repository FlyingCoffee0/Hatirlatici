import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:case_codeway/models/todo_model.dart';
import 'package:case_codeway/screens/auth/todo_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoController _todoController = Get.put(TodoController());

  @override
  void initState() {
    super.initState();
    
    _todoController.fetchTodos(); // İlk başlatma sırasında görevleri al
  }

  // Önceliğe göre renk döndüren bir fonksiyon
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green; // Low
      case 2:
        return Colors.orangeAccent; // Medium
      case 3:
        return Colors.redAccent; // High
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8A56AC),
        title: Text(
          'My TODOs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Arama butonu
          IconButton(
            icon: Icon(Icons.search, size: 28),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(_todoController),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, size: 28),
            onPressed: () => Get.toNamed('/createTodo'), // TODO oluşturma ekranına geçiş
          ),
        ],
      ),
      body: Obx(() {
        if (_todoController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Eğer arama yapılmıyorsa varsayılan listeyi göster
        var todoList = _todoController.filteredTodoList.isEmpty &&
                _todoController.searchQuery.isEmpty
            ? _todoController.todoList
            : _todoController.filteredTodoList;

        if (todoList.isEmpty) {
          return Center(
            child: Text(
              'No TODOs available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        // Tarih ve önceliğe göre sıralama
        todoList.sort((a, b) {
          // Tarihe göre sıralama (en yakın tarih ilk sırada)
          int dateComparison = a.dueDate.compareTo(b.dueDate);

          // Eğer tarihler aynı ise, önceliğe göre sıralama (High -> Low)
          if (dateComparison == 0) {
            return b.priority.compareTo(a.priority); // Yüksek öncelik önce
          }
          return dateComparison; // Tarihe göre sıralama
        });

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            TodoModel todo = todoList[index];

            // Tarih ve saat formatlama
            String formattedDate = DateFormat('dd-MM-yyyy').format(todo.dueDate);
            String formattedTime = DateFormat('HH:mm').format(todo.dueDate);

            return Column(
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: CircleAvatar( 
                      backgroundColor: getPriorityColor(todo.priority),
                      radius: 16,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seçilen tarih ve saat birlikte gösteriliyor
                        Text(
                          '$formattedDate ${formattedTime != '00:00' ? 'at $formattedTime' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A56AC), 
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Başlık (Title)
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Not (Note)
                        Text(
                          todo.note,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Eğer TODO'ya dosya eklenmişse, simge gösterme
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (todo.attachmentUrl != null && todo.attachmentUrl!.isNotEmpty)
                          Icon(Icons.attach_file, color: Color(0xFF8A56AC)),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Get.toNamed('/updateTodo', arguments: todo); // TODO güncelleme ekranına yönlendirme
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Kullanıcıdan silme işlemi için onay alma
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
                              await _todoController.deleteTodo(todo.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          },
        );
      }),
    );
  }
}

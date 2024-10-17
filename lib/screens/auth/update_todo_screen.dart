import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:case_codeway/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateTodoScreen extends StatelessWidget {
  final TodoController _todoController = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    final TodoModel todo = Get.arguments;

    // Mevcut verilerle input alanlarını dolduruyoruz
    _todoController.titleController.text = todo.title;
    _todoController.noteController.text = todo.note;
    _todoController.priority(todo.priority);
    _todoController.selectedDueDate.value = todo.dueDate; // Mevcut teslim tarihi

    return Scaffold(
      appBar: AppBar(
        title: Text('Update TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _todoController.titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _todoController.noteController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
            Obx(() {
              return DropdownButton<int>(
                value: _todoController.priority.value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _todoController.setPriority(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(value: 1, child: Text('Low Priority')),
                  DropdownMenuItem(value: 2, child: Text('Medium Priority')),
                  DropdownMenuItem(value: 3, child: Text('High Priority')),
                ],
              );
            }),
            SizedBox(height: 20),

            // Takvim butonu ve seçilen tarihi gösterme
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      _todoController.selectedDueDate.value != null
                          ? 'Selected Date: ${_todoController.selectedDueDate.value!.toLocal()}'.split(' ')[0]
                          : 'No Date Chosen',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _todoController.selectedDueDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _todoController.setDueDate(pickedDate); // Seçilen tarihi ayarla
                      }
                    },
                    child: Text('Pick a Date'),
                  ),
                ],
              );
            }),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                String todoId = todo.id;
                await _todoController.updateTodo(todoId); // Güncelleme işlemini başlat
              },
              child: Text('Update TODO'),
            ),
          ],
        ),
      ),
    );
  }
}

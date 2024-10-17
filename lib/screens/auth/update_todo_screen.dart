import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:case_codeway/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için intl paketi

class UpdateTodoScreen extends StatelessWidget {
  final TodoController _todoController = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    final TodoModel todo = Get.arguments;

    // Mevcut verilerle input alanlarını dolduruyoruz
    _todoController.titleController.text = todo.title;
    _todoController.noteController.text = todo.note;
    _todoController.priority(todo.priority);
    _todoController.selectedDueDate.value = todo.dueDate;
    _todoController.selectedTime.value = TimeOfDay.fromDateTime(todo.dueDate); // Mevcut saat bilgisi
    _todoController.categoryController.text = todo.category; // Category alanını dolduruyoruz
    _todoController.tagsController.text = todo.tags.join(", "); // Tags alanını virgülle ayırıyoruz

    return Scaffold(
      appBar: AppBar(
        title: Text('Update TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              TextField(
                controller: _todoController.categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _todoController.tagsController,
                decoration: InputDecoration(labelText: 'Tags (comma separated)'),
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

              // Takvim seçimi
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        _todoController.selectedDueDate.value != null
                            ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_todoController.selectedDueDate.value!)}'
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
                          _todoController.setDueDate(pickedDate);
                        }
                      },
                      child: Text('Pick a Date'),
                    ),
                  ],
                );
              }),

              SizedBox(height: 20),

              // Saat seçimi için Switch ve TimePicker
              Obx(() {
                return Row(
                  children: [
                    Text('Select Time:'),
                    Switch(
                      value: _todoController.isTimePickerEnabled.value,
                      onChanged: (newValue) {
                        _todoController.toggleTimePicker(newValue);
                      },
                    ),
                  ],
                );
              }),

              Obx(() {
                if (_todoController.isTimePickerEnabled.value) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _todoController.selectedTime.value != null
                                  ? 'Selected Time: ${_todoController.selectedTime.value!.format(context)}'
                                  : 'No Time Chosen',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: _todoController.selectedTime.value ?? TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                _todoController.setTime(pickedTime);
                              }
                            },
                            child: Text('Pick a Time'),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Container(); // Eğer switch kapalıysa boş widget döndürüyoruz
                }
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
      ),
    );
  }
}

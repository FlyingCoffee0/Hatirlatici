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
    _todoController.categoryController.text = todo.category;
    _todoController.tagsController.text = todo.tags.join(", ");
    _todoController.attachmentPath.value = todo.attachmentUrl ?? ""; // Mevcut dosya yolu

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8A56AC), // Soft purple color
        title: Text('Update TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık (Title) TextField
              TextField(
                controller: _todoController.titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              SizedBox(height: 20),

              // Not (Note) TextField
              TextField(
                controller: _todoController.noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              SizedBox(height: 20),

              // Kategori (Category) TextField
              TextField(
                controller: _todoController.categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              SizedBox(height: 20),

              // Etiketler (Tags) TextField
              TextField(
                controller: _todoController.tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              SizedBox(height: 20),

              // Öncelik (Priority) Dropdown
              Obx(() {
                return DropdownButtonFormField<int>(
                  value: _todoController.priority.value,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _todoController.setPriority(newValue);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text('Low Priority')),
                    DropdownMenuItem(value: 2, child: Text('Medium Priority')),
                    DropdownMenuItem(value: 3, child: Text('High Priority')),
                  ],
                );
              }),
              SizedBox(height: 20),

              // Takvim seçimi (Due Date)
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        _todoController.selectedDueDate.value != null
                            ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_todoController.selectedDueDate.value!)}'
                            : 'No Date Chosen',
                        style: TextStyle(fontSize: 16, color: Colors.black),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8A56AC), // Soft purple color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text('Pick a Date'),
                    ),
                  ],
                );
              }),
              SizedBox(height: 20),

              // Saat seçimi (Time Picker)
              Obx(() {
                return Row(
                  children: [
                    Text('Select Time:', style: TextStyle(fontSize: 16, color: Colors.black)),
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
                              style: TextStyle(fontSize: 16, color: Colors.black),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8A56AC), // Soft purple color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: Text('Pick a Time'),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
              SizedBox(height: 20),

              // Dosya seçimi butonu (Attachment)
              ElevatedButton(
                onPressed: () async {
                  await _todoController.pickFile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text('Pick an Attachment', style: TextStyle(color: Colors.white)),
              ),

              // Mevcut dosya yolunu göstermek için
              Obx(() {
                return _todoController.attachmentPath.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Selected File: ${_todoController.attachmentPath.value}',
                            style: TextStyle(fontSize: 14, color: Colors.black)),
                      )
                    : Container();
              }),
              SizedBox(height: 20),

              // Güncelle butonu
              ElevatedButton(
                onPressed: () async {
                  String todoId = todo.id;
                  await _todoController.updateTodo(todoId); // Güncelleme işlemini başlat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8A56AC), // Soft purple color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  minimumSize: Size(double.infinity, 50), // Full-width button
                ),
                child: Text(
                  'Update TODO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için intl paketi

class CreateTodoScreen extends StatelessWidget {
  final TodoController _todoController = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    // Yeni bir TODO oluştururken alanları temizle
    _todoController.clearFormFields();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8A56AC), // Soft purple color
        title: Text('Create New TODO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                        initialDate: DateTime.now(),
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
                              initialTime: TimeOfDay.now(),
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

            // Create TODO Button
            Obx(() {
              return ElevatedButton(
                onPressed: _todoController.isLoading.value
                    ? null
                    : () async {
                        await _todoController.createTodo();
                        Get.offAllNamed('/todoList'); // Tüm geçmiş sayfaları kapatıp My TODOs ekranına git
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8A56AC), // Soft purple color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  minimumSize: Size(double.infinity, 50), // Full-width button
                ),
                child: _todoController.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create TODO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

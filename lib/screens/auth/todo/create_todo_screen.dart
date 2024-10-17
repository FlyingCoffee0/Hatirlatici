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
        title: Text('Create New TODO'),
      ),
      body: SingleChildScrollView(
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
                        initialDate: DateTime.now(),
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
                              initialTime: TimeOfDay.now(),
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

            // Dosya seçimi butonu
            ElevatedButton(
              onPressed: () async {
                await _todoController.pickFile();
              },
              child: Text('Pick an Attachment'),
            ),

            SizedBox(height: 20),

            // "Create TODO" butonu (asenkron işlemleri bekleyip birden fazla tıklamayı engelliyoruz)
            Obx(() {
              return ElevatedButton(
                onPressed: _todoController.isLoading.value
                    ? null // Eğer işlem devam ediyorsa butonu devre dışı bırak
                    : () async {
                        await _todoController.createTodo(); // Yeni TODO oluştur
                        // TODO oluşturulduktan sonra My TODOs listesine yönlendir
                        Get.offAllNamed('/myTodos'); // Tüm geçmiş sayfaları kapatıp My TODOs ekranına git
                      },
                child: _todoController.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white) // İşlem sürüyorsa loading göster
                    : Text('Create TODO'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CreateTodoScreen extends StatelessWidget {
  final TodoController _todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _todoController.titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _todoController.noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _todoController.priority.value,
                onChanged: (value) {
                  if (value != null) {
                    _todoController.setPriority(value);
                  }
                },
                items: [
                  DropdownMenuItem(child: Text('Low Priority'), value: 1),
                  DropdownMenuItem(child: Text('Medium Priority'), value: 2),
                  DropdownMenuItem(child: Text('High Priority'), value: 3),
                ],
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _todoController.categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _todoController.tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _todoController.pickFile(),
                child: Text('Select Attachment'),
              ),
              Obx(() => _todoController.attachmentPath.isNotEmpty
                  ? Text('Selected: ${_todoController.attachmentPath.value}')
                  : SizedBox.shrink()),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _todoController.createTodo();
                },
                child: Text('Create TODO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:case_codeway/controllers/todo_controller.dart';
import 'package:case_codeway/models/todo_model.dart';

class TodoSearchDelegate extends SearchDelegate {
  final TodoController _todoController;

  TodoSearchDelegate(this._todoController);

  @override
  List<Widget> buildActions(BuildContext context) {
    // Arama çubuğunun sağındaki eylemler (clear butonu)
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Arama çubuğunu temizle
          _todoController.updateSearchQuery(''); // Arama sorgusunu sıfırla
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Arama çubuğunun solundaki geri butonu
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Arama ekranını kapat
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Arama sonuçlarını göster
    _todoController.updateSearchQuery(query); // Arama sorgusunu güncelle

    return Obx(() {
      var filteredList = _todoController.filteredTodoList;

      if (filteredList.isEmpty) {
        return Center(child: Text('No TODOs found.'));
      }

      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          TodoModel todo = filteredList[index];

          return ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.note),
            onTap: () {
              Get.toNamed('/updateTodo', arguments: todo);
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Arama önerilerini göster
    _todoController.updateSearchQuery(query); // Arama sorgusunu güncelle

    return Obx(() {
      var filteredList = _todoController.filteredTodoList;

      if (filteredList.isEmpty) {
        return Center(child: Text('No TODOs found.'));
      }

      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          TodoModel todo = filteredList[index];

          return ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.note),
            onTap: () {
              Get.toNamed('/updateTodo', arguments: todo);
            },
          );
        },
      );
    });
  }
}

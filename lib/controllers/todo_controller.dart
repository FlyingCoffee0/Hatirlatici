import 'package:get/get.dart';
import '../models/todo_model.dart';
import '../services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TodoController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  var todoList = <TodoModel>[].obs; // TODO'ları listelemek için observable list
  var isLoading = false.obs; // Yüklenme durumunu izlemek için observable boolean

  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController();
  final tagsController = TextEditingController();
  var priority = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos(); // Uygulama açıldığında TODO'ları getirir
  }

  // TODO'ları Firestore'dan getir
  Future<void> fetchTodos() async {
    isLoading(true);
    try {
      String userId = "currentUser"; // Firebase'den gerçek user ID'yi al
      var todos = await _firestoreService.getTodos(userId);
      todoList.assignAll(todos); // Gelen verileri todoList'e atıyoruz
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Yeni TODO ekleme fonksiyonu
  Future<void> createTodo() async {
    try {
      String userId = "currentUser"; // Firebase'den gerçek user ID'yi al
      List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();
      
      TodoModel newTodo = TodoModel(
        id: '',
        title: titleController.text.trim(),
        note: noteController.text.trim(),
        priority: priority.value,
        dueDate: DateTime.now(),
        category: categoryController.text.trim(),
        tags: tags,
        attachmentUrl: null, 
      );

      await _firestoreService.addTodo(userId, newTodo);
      fetchTodos(); // TODO ekledikten sonra listeyi güncelle
      Get.back();
      Get.snackbar('Success', 'TODO created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Kullanıcı öncelik seçimini güncelleme
  void setPriority(int value) {
    priority(value);
  }
}
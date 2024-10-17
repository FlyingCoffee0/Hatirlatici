import 'dart:io';
import 'package:case_codeway/services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/todo_model.dart';
import '../services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TodoController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var todoList = <TodoModel>[].obs;
  var isLoading = false.obs;

  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController();
  final tagsController = TextEditingController();
  var priority = 1.obs;
  var attachmentPath = ''.obs; // Dosya yolu

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

Future<void> fetchTodos() async {
  isLoading(true);
  try {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';  // Doğru kullanıcı kimliğini alıyoruz
    var todos = await _firestoreService.getTodos(userId);
    todoList.assignAll(todos);
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading(false);
  }
}

  // Dosya seçme fonksiyonu
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      attachmentPath(result.files.single.path!);
      Get.snackbar('Success', 'File selected');
    } else {
      Get.snackbar('Error', 'No file selected');
    }
  }

  // Dosyayı Firebase Storage'a yükleme
  Future<String?> uploadFile() async {
    if (attachmentPath.isNotEmpty) {
      try {
        File file = File(attachmentPath.value);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = _storage.ref().child('attachments/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        Get.snackbar('Error', 'File upload failed: $e');
        return null;
      }
    }
    return null;
  }

Future<void> createTodo() async {
    try {
      isLoading(true);
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      String? attachmentUrl = await uploadFile();
      List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();

      DateTime dueDate = DateTime.now().add(Duration(days: 1)); // Örnek teslim tarihi

      TodoModel newTodo = TodoModel(
        id: '',
        title: titleController.text.trim(),
        note: noteController.text.trim(),
        priority: priority.value,
        dueDate: dueDate,
        category: categoryController.text.trim(),
        tags: tags,
        attachmentUrl: attachmentUrl,
      );

      await _firestoreService.addTodo(userId, newTodo);

      // Bildirim ayarlama
      NotificationService().scheduleNotification(
          newTodo.hashCode, // unique ID
          'TODO Reminder',
          'Your TODO ${newTodo.title} is due tomorrow',
          dueDate.subtract(Duration(days: 1)) // Bir gün önce
      );
      NotificationService().scheduleNotification(
          newTodo.hashCode + 1,
          'TODO Reminder',
          'Your TODO ${newTodo.title} is due in 5 minutes',
          dueDate.subtract(Duration(minutes: 5)) // Beş dakika önce
      );

      fetchTodos();
      Get.back();
      Get.snackbar('Success', 'TODO created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }


  // Kullanıcı öncelik seçimini güncelleme
  void setPriority(int value) {
    priority(value);
  }
}
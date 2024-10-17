import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // Local storage için gerekli
import '../models/todo_model.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart'; // Dosya adları için

class TodoController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  var todoList = <TodoModel>[].obs;
  var isLoading = false.obs;

  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController(); // Category alanı geri eklendi
  final tagsController = TextEditingController(); // Tags alanı geri eklendi
  var priority = 1.obs;
  var attachmentPath = ''.obs;
  var selectedDueDate = Rxn<DateTime>(); // Takvimde seçilen tarih için observable
  var selectedTime = Rxn<TimeOfDay>(); // Saat seçimi için observable
  var isTimePickerEnabled = false.obs; // Saat seçici etkin mi?

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  // Dosya seçme fonksiyonu
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      attachmentPath(filePath);
      Get.snackbar('Success', 'File selected: $filePath');
    } else {
      Get.snackbar('Error', 'No file selected');
    }
  }

  // Dosyayı yerel depolamaya kopyalama işlemi
  Future<String?> saveFileLocally() async {
    if (attachmentPath.isNotEmpty) {
      try {
        File file = File(attachmentPath.value);
        final directory = await getApplicationDocumentsDirectory();
        final fileName = basename(file.path);
        final localPath = '${directory.path}/$fileName';

        File savedFile = await file.copy(localPath); // Dosyayı kopyala
        return savedFile.path; // Yolu geri döndür
      } catch (e) {
        Get.snackbar('Error', 'File saving failed: $e');
        return null;
      }
    }
    return null;
  }

  // TODO silme fonksiyonu
  Future<void> deleteTodo(String todoId) async {
    try {
      isLoading(true);
      await _firestoreService.deleteTodo(todoId);
      fetchTodos(); // Silme sonrası verileri güncelle
      Get.snackbar('Success', 'TODO deleted successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete TODO: $e');
    } finally {
      isLoading(false);
    }
  }

  // TODO güncelleme fonksiyonu
  Future<void> updateTodo(String todoId) async {
    try {
      isLoading(true);
      String? savedFilePath = await saveFileLocally(); // Eğer dosya seçilmişse kaydet

      DateTime dueDate = selectedDueDate.value ?? DateTime.now().add(Duration(days: 1)); // Seçilen tarih veya varsayılan değer

      // Eğer saat seçilmişse, tarihi ve saati birleştir
      if (selectedTime.value != null) {
        dueDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );
      }

      List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();

      TodoModel updatedTodo = TodoModel(
        id: todoId,
        title: titleController.text.trim(),
        note: noteController.text.trim(),
        priority: priority.value,
        dueDate: dueDate, // Seçilen teslim tarihi
        category: categoryController.text.trim(), // Category eklendi
        tags: tags, // Tags eklendi
        attachmentUrl: savedFilePath ?? attachmentPath.value, // Dosya yolu
      );

      await _firestoreService.updateTodo(todoId, updatedTodo);
      fetchTodos(); // Güncel TODO listesini al
      Get.back();
      Get.snackbar('Success', 'TODO updated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update TODO: $e');
    } finally {
      isLoading(false);
    }
  }

  // Yeni TODO oluşturma fonksiyonu
  Future<void> createTodo() async {
    try {
      isLoading(true);
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      String? savedFilePath = await saveFileLocally(); // Dosya kaydetme işlemi

      DateTime dueDate = selectedDueDate.value ?? DateTime.now().add(Duration(days: 1)); // Seçilen tarih veya varsayılan

      if (selectedTime.value != null) {
        dueDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );
      }

      List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();

      TodoModel newTodo = TodoModel(
        id: '',
        title: titleController.text.trim(),
        note: noteController.text.trim(),
        priority: priority.value,
        dueDate: dueDate,  // Seçilen teslim tarihi
        category: categoryController.text.trim(), // Category eklendi
        tags: tags, // Tags eklendi
        attachmentUrl: savedFilePath, // Kaydedilen dosya yolu
      );

      await _firestoreService.addTodo(userId, newTodo); // Firestore'a ekleme

      fetchTodos(); // Verileri yenile
      Get.back();
      Get.snackbar('Success', 'TODO created successfully!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Firestore'dan TODO'ları çekme
  Future<void> fetchTodos() async {
    isLoading(true);
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      var todos = await _firestoreService.getTodos(userId);
      todoList.assignAll(todos);
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

  // Takvimden gelen tarihi ayarlamak için fonksiyon
  void setDueDate(DateTime date) {
    selectedDueDate.value = date;
  }

  // Saat seçimi için fonksiyon
  void setTime(TimeOfDay time) {
    selectedTime.value = time;
  }

  // Saat seçici switch'i aç/kapat
  void toggleTimePicker(bool isEnabled) {
    isTimePickerEnabled.value = isEnabled;
    if (!isEnabled) {
      selectedTime.value = null; // Eğer kapatılırsa saati sıfırla
    }
  }
}
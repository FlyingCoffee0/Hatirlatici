import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/todo_model.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart'; 
import 'package:firebase_storage/firebase_storage.dart'; 

class TodoController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  var todoList = <TodoModel>[].obs;
  var filteredTodoList = <TodoModel>[].obs; // Arama sonucu filtrelenmiş liste
  var isLoading = false.obs;
  var searchQuery = ''.obs; // Arama sorgusu için observable

  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController(); 
  final tagsController = TextEditingController(); 
  var priority = 1.obs;
  var attachmentPath = ''.obs;
  var selectedDueDate = Rxn<DateTime>(); // Takvimde seçilen tarih için observable
  var selectedTime = Rxn<TimeOfDay>(); // Saat seçimi için observable

  // Tüm input alanlarını sıfırlama (Temizleme)
  void clearFormFields() {
    titleController.clear();
    noteController.clear();
    categoryController.clear();
    tagsController.clear();
    selectedDueDate.value = null;
    selectedTime.value = null;
    attachmentPath.value = '';
    priority.value = 1; // Varsayılan öncelik
  }

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
    debounce(searchQuery, (_) => filterTodos(), time: Duration(milliseconds: 300)); // Arama sorgusu her değiştiğinde filtreleme işlemi
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

  // Dosyayı Firestore Storage'a yükleme ve URL'yi alma işlemi
  Future<String?> uploadFileToStorage(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = basename(filePath); // Dosya ismini alıyorum
      Reference storageRef = FirebaseStorage.instance.ref().child('attachments/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);

      // Yükleme işlemi tamamlandığında URL'yi alıyorum
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload file: $e');
      return null;
    }
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
  if (isLoading.value) return; // Eğer işlem devam ediyorsa, tekrar başlatma
  
  try {
    isLoading(true); // Yükleniyor durumu başlatıldı

    // Dosya seçildiyse önce Firestore Storage'a yükleyip URL'yi alıyoruz
    String? attachmentUrl;
    if (attachmentPath.isNotEmpty) {
      attachmentUrl = await uploadFileToStorage(attachmentPath.value);
    }

    DateTime dueDate = selectedDueDate.value ?? DateTime.now().add(Duration(days: 1)); // Seçilen tarih veya varsayılan değer

    // Eğer saat seçilmediyse varsayılan olarak 23:59 ayarlanır
    if (selectedTime.value != null) {
      dueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );
    } else {
      dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59); // Varsayılan saat 23:59
    }

    List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();

    TodoModel updatedTodo = TodoModel(
      id: todoId,
      title: titleController.text.trim(),
      note: noteController.text.trim(),
      priority: priority.value,
      dueDate: dueDate,
      category: categoryController.text.trim(),
      tags: tags,
      attachmentUrl: attachmentUrl ?? attachmentPath.value, // Dosya yolu
    );

    await _firestoreService.updateTodo(todoId, updatedTodo);
    
    fetchTodos(); // Güncel TODO listesini al
    Get.back(); // Bekleme ekranını kapat
    
    Get.snackbar(
      'Success', 
      'TODO updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );

  } catch (e) {
    Get.snackbar(
      'Error', 
      'Failed to update TODO: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  } finally {
    isLoading(false); // İşlem tamamlandığında yüklenme durumunu kapat
  }
}

  // Yeni TODO oluşturma fonksiyonu
  Future<void> createTodo() async {
    try {
      isLoading(true);
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

      DateTime dueDate = selectedDueDate.value ?? DateTime.now().add(Duration(days: 1)); // Seçilen tarih veya varsayılan

      // Eğer saat seçilmediyse varsayılan olarak 23:59 ayarlanır
      if (selectedTime.value != null) {
        dueDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );
      } else {
        dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59); // Varsayılan saat 23:59
      }

      // Dosya yüklemesi varsa önce dosyayı yükleyelim
      String? attachmentUrl;
      if (attachmentPath.isNotEmpty) {
        attachmentUrl = await uploadFileToStorage(attachmentPath.value);
      }

      List<String> tags = tagsController.text.split(',').map((e) => e.trim()).toList();

      TodoModel newTodo = TodoModel(
        id: '',
        title: titleController.text.trim(),
        note: noteController.text.trim(),
        priority: priority.value,
        dueDate: dueDate,
        category: categoryController.text.trim(), 
        tags: tags, 
        attachmentUrl: attachmentUrl, // Dosya URL'sini Firestore'a kaydediyoruz
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

  // Firestore'dan TODO'ları çekme ve zamanı geçmiş TODO'ları silme
  Future<void> fetchTodos() async {
    isLoading(true);
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

      // TODO'ları Firestore'dan alıyoruz
      var todos = await _firestoreService.getTodos(userId);

      // Zamanı geçmiş TODO'ları kontrol edip silme işlemi
      for (var todo in todos) {
        if (todo.dueDate.isBefore(DateTime.now())) {
          await _firestoreService.deleteTodo(todo.id); 
        }
      }

      // Zamanı geçmemiş TODO'ları listeye ekliyoruz
      todoList.assignAll(todos.where((todo) => todo.dueDate.isAfter(DateTime.now())).toList());

      filterTodos(); // Arama sorgusuna göre filtrele

    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Arama sorgusuna göre TODO'ları filtreleme fonksiyonu
  void filterTodos() {
    if (searchQuery.isEmpty) {
      filteredTodoList.assignAll(todoList); // Arama yoksa tüm TODO'ları göster
    } else {
      filteredTodoList.assignAll(
        todoList.where((todo) =>
          todo.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          todo.note.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          todo.category.toLowerCase().contains(searchQuery.value.toLowerCase())
        ).toList(),
      );
    }
  }

  // Arama sorgusunu güncelleme
  void updateSearchQuery(String query) {
    searchQuery.value = query;
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
}

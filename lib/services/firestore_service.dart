import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcıya ait TODO'ları Firestore'dan almak
  Future<List<TodoModel>> getTodos(String userId) async {
    var snapshot = await _db
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .get();

    return snapshot.docs
        .map((doc) => TodoModel.fromJson(doc.data(), doc.id))
        .toList();
  }

 // Kullanıcıya ait TODO'yu Firestore'a eklemek
  Future<void> addTodo(String userId, TodoModel todo) async {
    await _db.collection('todos').add({
      ...todo.toJson(),
      'userId': userId, // Kullanıcı ID'sini de ekliyoruz
    });
  }


  // TODO güncellemek
  Future<void> updateTodo(String todoId, TodoModel todo) async {
    await _db.collection('todos').doc(todoId).update(todo.toJson());
  }

  // TODO silmek
  Future<void> deleteTodo(String todoId) async {
    await _db.collection('todos').doc(todoId).delete();
  }

}
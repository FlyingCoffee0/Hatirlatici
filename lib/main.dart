import 'package:case_codeway/screens/auth/sign_up_screen.dart';
import 'package:case_codeway/screens/auth/todo/create_todo_screen.dart';
import 'package:case_codeway/screens/auth/todo/todo_list_screen.dart';
import 'package:case_codeway/screens/auth/update_todo_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/sign_in_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Ya da SafetyNet
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TODO App',
      initialRoute: '/signIn',
      getPages: [
        GetPage(name: '/signIn', page: () => SignInScreen()),
        GetPage(name: '/signUp', page: () => SignUpScreen()), // Sign-up screen
        GetPage(name: '/todoList', page: () => TodoListScreen()),
        GetPage(name: '/createTodo', page: () => CreateTodoScreen()), // TODO list screen
        GetPage(
  name: '/updateTodo',
  page: () => UpdateTodoScreen(),
),

      ],
    );
  }
}

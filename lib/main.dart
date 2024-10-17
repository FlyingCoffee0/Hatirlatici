import 'package:case_codeway/screens/auth/sign_up_screen.dart';
import 'package:case_codeway/screens/auth/todo/create_todo_screen.dart';
import 'package:case_codeway/screens/auth/todo/todo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/sign_in_screen.dart';


void main() {
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
      ],
    );
  }
}

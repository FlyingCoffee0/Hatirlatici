import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Exact Alarm izni istemek için fonksiyon
  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      // Eğer izin verilmemişse, izni istemeyi deneme
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) {
        print("Exact Alarm permission granted.");
      } else {
        print("Exact Alarm permission denied.");
      }
    } else {
      print("Exact Alarm permission already granted.");
    }
  }
}

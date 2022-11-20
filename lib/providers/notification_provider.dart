import 'package:ecom_user_08/db/db_helper.dart';
import 'package:ecom_user_08/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  Future<void> addNotification(NotificationModel notificationModel) {
    return DbHelper.addNotification(notificationModel);
  }

  /*getUserInfo() {
    DbHelper.getUserInfo(AuthService.currentUser!.uid).listen((snapshot) {
      if (snapshot.exists) {
        userModel = UserModel.fromMap(snapshot.data()!);
        notifyListeners();
      }
    });
  }
*/

}

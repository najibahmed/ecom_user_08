import 'package:ecom_user_08/models/order_model.dart';

class OrderItem {
  OrderModel orderModel;
  bool isExpanded;

  OrderItem({
    required this.orderModel,
    this.isExpanded = false,
  });
}

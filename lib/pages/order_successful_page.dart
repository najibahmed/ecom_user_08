import 'package:flutter/material.dart';

class OrderSuccessfulPage extends StatelessWidget {
  static const String routeName = '/successful';
  const OrderSuccessfulPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.done,
              size: 150,
              color: Colors.green,
            ),
            const Text('Your order has been placed.')
          ],
        ),
      ),
    );
  }
}

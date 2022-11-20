import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/cart_page.dart';
import '../providers/cart_provider.dart';

class CartBubbleView extends StatelessWidget {
  const CartBubbleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, CartPage.routeName),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.shopping_cart,
              size: 30,
            ),
            Positioned(
              left: -5,
              top: -5,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: FittedBox(
                  child: Consumer<CartProvider>(
                    builder: (context, provider, child) =>
                        Text('${provider.cartList.length}'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

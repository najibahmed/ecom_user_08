import 'package:ecom_user_08/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../customwidgets/cart_item_view.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  static const String routeName = '/cart';
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.cartList.length,
                itemBuilder: (context, index) {
                  final cartModel = provider.cartList[index];
                  return CartItemView(
                    cartModel: cartModel,
                    provider: provider,
                  );
                },
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      'SUB TOTAL: $currencySymbol${provider.getCartSubTotal()}',
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    OutlinedButton(
                      onPressed: provider.totalItemsInCart == 0
                          ? null
                          : () {
                              Navigator.pushNamed(
                                  context, CheckoutPage.routeName);
                            },
                      child: const Text('CHEKCOUT'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

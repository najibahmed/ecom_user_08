import 'package:ecom_user_08/auth/authservice.dart';
import 'package:ecom_user_08/db/db_helper.dart';
import 'package:ecom_user_08/models/product_model.dart';
import 'package:ecom_user_08/utils/helper_functions.dart';
import 'package:flutter/material.dart';

import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartModel> cartList = [];

  num priceWithQuantity(CartModel cartModel) =>
      cartModel.salePrice * cartModel.quantity;

  int get totalItemsInCart => cartList.length;

  bool isProductInCart(String pid) {
    bool tag = false;
    for (final cartModel in cartList) {
      if (cartModel.productId == pid) {
        tag = true;
        break;
      }
    }
    return tag;
  }

  Future<void> addToCart(ProductModel productModel) {
    final cartModel = CartModel(
      productId: productModel.productId!,
      categoryId: productModel.category.categoryId!,
      productName: productModel.productName,
      productImageUrl: productModel.thumbnailImageUrl,
      salePrice: num.parse(calculatePriceAfterDiscount(
          productModel.salePrice, productModel.productDiscount)),
    );
    return DbHelper.addToCart(AuthService.currentUser!.uid, cartModel);
  }

  Future<void> removeFromCart(String s) {
    return DbHelper.removeFromCart(AuthService.currentUser!.uid, s);
  }

  void getAllCartItems() {
    DbHelper.getAllCartItems(AuthService.currentUser!.uid).listen((snapshot) {
      cartList = List.generate(snapshot.docs.length,
          (index) => CartModel.fromMap(snapshot.docs[index].data()));
      notifyListeners();
    });
  }

  void increaseQuantity(CartModel cartModel) {
    cartModel.quantity += 1;
    DbHelper.updateCartQuantity(AuthService.currentUser!.uid, cartModel);
  }

  void decreaseQuantity(CartModel cartModel) {
    if (cartModel.quantity > 1) {
      cartModel.quantity -= 1;
      DbHelper.updateCartQuantity(AuthService.currentUser!.uid, cartModel);
    }
  }

  num getCartSubTotal() {
    num total = 0;
    for (final cartModel in cartList) {
      total += priceWithQuantity(cartModel);
    }
    return total;
  }

  Future<void> clearCart() {
    return DbHelper.clearCartItems(AuthService.currentUser!.uid, cartList);
  }
}

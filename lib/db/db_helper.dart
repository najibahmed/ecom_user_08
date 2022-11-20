import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_user_08/models/cart_model.dart';
import 'package:ecom_user_08/models/comment_model.dart';
import 'package:ecom_user_08/models/notification_model.dart';
import 'package:ecom_user_08/models/order_model.dart';
import 'package:ecom_user_08/models/rating_model.dart';
import 'package:ecom_user_08/models/user_model.dart';

import '../models/category_model.dart';
import '../models/order_constant_model.dart';
import '../models/product_model.dart';

class DbHelper {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> doesUserExist(String uid) async {
    final snapshot = await _db.collection(collectionUser).doc(uid).get();
    return snapshot.exists;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getRatingsByProduct(
          String pid) =>
      _db
          .collection(collectionProduct)
          .doc(pid)
          .collection(collectionRating)
          .get();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
          String uid) =>
      _db.collection(collectionUser).doc(uid).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCartItems(
          String uid) =>
      _db
          .collection(collectionUser)
          .doc(uid)
          .collection(collectionCart)
          .snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getOrderConstants() =>
      _db
          .collection(collectionOrderConstant)
          .doc(documentOrderConstant)
          .snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllOrdersByUser(
          String uid) =>
      _db
          .collection(collectionOrder)
          .where(orderFieldUserId, isEqualTo: uid)
          .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCategories() =>
      _db.collection(collectionCategory).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProducts() =>
      _db.collection(collectionProduct).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProductsByCategory(
          CategoryModel categoryModel) =>
      _db
          .collection(collectionProduct)
          .where('$productFieldCategory.$categoryFieldId',
              isEqualTo: categoryModel.categoryId)
          .snapshots();

  static Future<void> addUser(UserModel userModel) {
    return _db
        .collection(collectionUser)
        .doc(userModel.userId)
        .set(userModel.toMap());
  }

  static Future<void> updateUserProfileField(
      String uid, Map<String, dynamic> map) {
    return _db.collection(collectionUser).doc(uid).update(map);
  }

  static Future<void> updateProductField(String pid, Map<String, dynamic> map) {
    return _db.collection(collectionProduct).doc(pid).update(map);
  }

  static Future<void> addRating(RatingModel ratingModel) async {
    final ratDoc = _db
        .collection(collectionProduct)
        .doc(ratingModel.productId)
        .collection(collectionRating)
        .doc(ratingModel.userModel.userId);
    return ratDoc.set(ratingModel.toMap());
  }

  static Future<void> addComment(CommentModel commentModel) {
    return _db
        .collection(collectionProduct)
        .doc(commentModel.productId)
        .collection(collectionComment)
        .doc(commentModel.commentId)
        .set(commentModel.toMap());
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllCommentsByProduct(
      String s) {
    return _db
        .collection(collectionProduct)
        .doc(s)
        .collection(collectionComment)
        .where(commentFieldApproved, isEqualTo: true)
        .get();
  }

  static Future<void> addToCart(String uid, CartModel cartModel) {
    return _db
        .collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(cartModel.productId)
        .set(cartModel.toMap());
  }

  static Future<void> removeFromCart(String uid, String s) {
    return _db
        .collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(s)
        .delete();
  }

  static Future<void> updateCartQuantity(String uid, CartModel cartModel) {
    return _db
        .collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(cartModel.productId)
        .set(cartModel.toMap());
  }

  static Future<void> saveOrder(OrderModel orderModel) async {
    final wb = _db.batch();
    final orderDoc = _db.collection(collectionOrder).doc(orderModel.orderId);
    wb.set(orderDoc, orderModel.toMap());
    for (final cartModel in orderModel.productDetails) {
      final productSnapshot = await _db
          .collection(collectionProduct)
          .doc(cartModel.productId)
          .get();
      final categorySnapshot = await _db
          .collection(collectionCategory)
          .doc(cartModel.categoryId)
          .get();
      final prevProductStock = productSnapshot.data()![productFieldStock];
      final prevCategoryProductCount =
          categorySnapshot.data()![categoryFieldProductCount];
      final proDoc = _db.collection(collectionProduct).doc(cartModel.productId);
      final catDoc =
          _db.collection(collectionCategory).doc(cartModel.categoryId);
      wb.update(
          proDoc, {productFieldStock: (prevProductStock - cartModel.quantity)});
      wb.update(catDoc, {
        categoryFieldProductCount:
            (prevCategoryProductCount - cartModel.quantity)
      });
    }
    return wb.commit();
  }

  static Future<void> clearCartItems(String uid, List<CartModel> cartList) {
    final wb = _db.batch();
    for (final cartModel in cartList) {
      final doc = _db
          .collection(collectionUser)
          .doc(uid)
          .collection(collectionCart)
          .doc(cartModel.productId);
      wb.delete(doc);
    }
    return wb.commit();
  }

  static Future<void> addNotification(NotificationModel notificationModel) {
    return _db
        .collection(collectionNotification)
        .doc(notificationModel.id)
        .set(notificationModel.toMap());
  }
}

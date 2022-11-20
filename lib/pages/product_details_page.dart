import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_user_08/auth/authservice.dart';
import 'package:ecom_user_08/models/comment_model.dart';
import 'package:ecom_user_08/providers/cart_provider.dart';
import 'package:ecom_user_08/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../models/notification_model.dart';
import '../models/product_model.dart';
import '../providers/notification_provider.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class ProductDetailsPage extends StatefulWidget {
  static const String routeName = '/productdetails';

  const ProductDetailsPage({Key? key}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late ProductModel productModel;
  late ProductProvider productProvider;
  String displayUrl = '';
  double userRating = 0.0;
  final txtController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    productModel = ModalRoute.of(context)!.settings.arguments as ProductModel;
    displayUrl = productModel.thumbnailImageUrl;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productModel.productName),
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
            width: double.infinity,
            height: 200,
            imageUrl: displayUrl,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      displayUrl = productModel.thumbnailImageUrl;
                    });
                  },
                  child: Card(
                    child: CachedNetworkImage(
                      width: 60,
                      height: 60,
                      imageUrl: productModel.thumbnailImageUrl,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                ...productModel.additionalImages.map((url) {
                  if (url.isEmpty) {
                    return const SizedBox();
                  }
                  return InkWell(
                    onTap: () {
                      setState(() {
                        displayUrl = url;
                      });
                    },
                    child: Card(
                      child: CachedNetworkImage(
                        width: 60,
                        height: 60,
                        imageUrl: url,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.favorite),
                    label: Text('ADD TO FAVORITE'),
                  ),
                ),
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (context, provider, child) {
                      final isInCart =
                          provider.isProductInCart(productModel.productId!);
                      return OutlinedButton.icon(
                        onPressed: () {
                          if (isInCart) {
                            provider.removeFromCart(productModel.productId!);
                          } else {
                            provider.addToCart(productModel);
                          }
                        },
                        icon: Icon(isInCart
                            ? Icons.remove_shopping_cart
                            : Icons.shopping_cart),
                        label:
                            Text(isInCart ? 'REMOVE FROM CART' : 'ADD TO CART'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(productModel.productName),
            subtitle: Text(productModel.category.categoryName),
          ),
          ListTile(
            title: Text(
                'Sale Price: $currencySymbol${calculatePriceAfterDiscount(productModel.salePrice, productModel.productDiscount)}'),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text('Rate this product'),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RatingBar.builder(
                      initialRating: 0.0,
                      minRating: 0.0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        userRating = rating;
                      },
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      if (AuthService.currentUser!.isAnonymous) {
                        showMsg(context, 'Please sign in to rate this product');
                        return;
                      }
                      EasyLoading.show(status: 'Please wait');
                      await productProvider.addRating(productModel.productId!,
                          userRating, context.read<UserProvider>().userModel!);
                      EasyLoading.dismiss();
                      showMsg(context, 'Thanks for your rating');
                    },
                    child: const Text('SUBMIT'),
                  )
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text('Add your Comment'),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      maxLines: 3,
                      controller: txtController,
                      focusNode: focusNode,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      if (txtController.text.isEmpty) {
                        showMsg(context, 'Please provide a comment');
                        return;
                      }
                      if (AuthService.currentUser!.isAnonymous) {
                        showMsg(
                            context, 'Please sign in to comment this product');
                        return;
                      }
                      EasyLoading.show(status: 'Please wait');
                      final commentModel = CommentModel(
                        commentId:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        userModel: context.read<UserProvider>().userModel!,
                        productId: productModel.productId!,
                        comment: txtController.text,
                        date: getFormattedDate(DateTime.now(),
                            pattern: 'dd/MM/yyyy hh:mm:s a'),
                      );
                      await productProvider.addComment(commentModel);

                      showMsg(context,
                          'Thanks for your comment. Your comment is waiting for Admin approval.');
                      final notificationModel = NotificationModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: NotificationType.comment,
                        message:
                            'Product ${productModel.productName} has a new comment which is waiting for your approval',
                        commentModel: commentModel,
                      );
                      await Provider.of<NotificationProvider>(context,
                              listen: false)
                          .addNotification(notificationModel);
                      EasyLoading.dismiss();
                      focusNode.unfocus();
                    },
                    child: const Text('SUBMIT'),
                  )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('All Comments'),
          ),
          FutureBuilder<List<CommentModel>>(
            future: productProvider
                .getAllCommentsByProduct(productModel.productId!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final commentList = snapshot.data!;
                if (commentList.isEmpty) {
                  return const Center(
                    child: Text('No comments found'),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: commentList
                          .map((comment) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(comment.userModel.displayName ??
                                        comment.userModel.email),
                                    subtitle: Text(comment.date),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 8),
                                    child: Text(comment.comment),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  );
                }
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Failed to load comments'),
                );
              }
              return const Center(
                child: Text('Loading comments...'),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }
}

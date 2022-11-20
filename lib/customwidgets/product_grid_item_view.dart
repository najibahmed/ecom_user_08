import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_user_08/models/product_model.dart';
import 'package:ecom_user_08/utils/constants.dart';
import 'package:ecom_user_08/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/product_details_page.dart';

class ProductGridItemView extends StatelessWidget {
  final ProductModel productModel;

  const ProductGridItemView({Key? key, required this.productModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, ProductDetailsPage.routeName,
          arguments: productModel),
      child: Card(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: productModel.thumbnailImageUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Text(
                  productModel.productName,
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey),
                ),
                if (productModel.productDiscount > 0)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RichText(
                      text: TextSpan(
                          text:
                              '$currencySymbol${calculatePriceAfterDiscount(productModel.salePrice, productModel.productDiscount)}',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          children: [
                            TextSpan(
                                text:
                                    ' $currencySymbol${productModel.salePrice}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough)),
                          ]),
                    ),
                  ),
                if (productModel.productDiscount == 0)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '$currencySymbol${productModel.salePrice}',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(productModel.avgRating.toStringAsFixed(1)),
                      const SizedBox(
                        width: 5,
                      ),
                      RatingBar.builder(
                        initialRating: productModel.avgRating.toDouble(),
                        minRating: 0.0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        ignoreGestures: true,
                        itemSize: 20,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 0.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
            if (productModel.productDiscount > 0)
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${productModel.productDiscount}% OFF',
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

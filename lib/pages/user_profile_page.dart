import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_user_08/models/address_model.dart';
import 'package:ecom_user_08/models/user_model.dart';
import 'package:ecom_user_08/pages/otp_verification_page.dart';
import 'package:ecom_user_08/utils/widget_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class UserProfilePage extends StatelessWidget {
  static const String routeName = '/profile';

  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('My Profile'),
      ),
      body: userProvider.userModel == null
          ? const Center(
              child: Text('Failed to load user data'),
            )
          : ListView(
              children: [
                _headerSection(context, userProvider),
                ListTile(
                  leading: const Icon(Icons.call),
                  title: Text(userProvider.userModel!.phone ?? 'Not set yet'),
                  trailing: IconButton(
                    onPressed: () {
                      showSingleTextInputDialog(
                        context: context,
                        title: 'Mobile Number',
                        onSubmit: (value) {
                          print('input: $value');
                          Navigator.pushNamed(
                              context, OtpVerificationPage.routeName,
                              arguments: value);
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(userProvider.userModel!.age ?? 'Not set yet'),
                  subtitle: const Text('Date of Birth'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(userProvider.userModel!.gender ?? 'Not set yet'),
                  subtitle: const Text('Gender'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(
                      userProvider.userModel!.addressModel?.addressLine1 ??
                          'Not set yet'),
                  subtitle: const Text('Address Line 1'),
                  trailing: IconButton(
                    onPressed: () {
                      showSingleTextInputDialog(
                        context: context,
                        title: 'Address Line 1',
                        onSubmit: (value) {
                          userProvider.updateUserProfileField(
                            '$userFieldAddressModel.$addressFieldAddressLine1',
                            value,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(
                      userProvider.userModel!.addressModel?.addressLine2 ??
                          'Not set yet'),
                  subtitle: const Text('Address Line 2'),
                  trailing: IconButton(
                    onPressed: () {
                      showSingleTextInputDialog(
                        context: context,
                        title: 'Address Line 2',
                        onSubmit: (value) {
                          userProvider.updateUserProfileField(
                            '$userFieldAddressModel.$addressFieldAddressLine2',
                            value,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(userProvider.userModel!.addressModel?.city ??
                      'Not set yet'),
                  subtitle: const Text('City'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(userProvider.userModel!.addressModel?.zipcode ??
                      'Not set yet'),
                  subtitle: const Text('Zip Code'),
                  trailing: IconButton(
                    onPressed: () {
                      showSingleTextInputDialog(
                        context: context,
                        title: 'Zip Code',
                        onSubmit: (value) {
                          userProvider.updateUserProfileField(
                            '$userFieldAddressModel.$addressFieldZipcode',
                            value,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
    );
  }

  Container _headerSection(BuildContext context, UserProvider userProvider) {
    return Container(
      height: 150,
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
            elevation: 5,
            child: userProvider.userModel!.imageUrl == null
                ? const Icon(
                    Icons.person,
                    size: 90,
                    color: Colors.grey,
                  )
                : Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        width: 90,
                        height: 90,
                        imageUrl: userProvider.userModel!.imageUrl!,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProvider.userModel!.displayName ?? 'No Display Name',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white),
              ),
              Text(
                userProvider.userModel!.email,
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

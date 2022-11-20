import 'package:ecom_user_08/auth/authservice.dart';
import 'package:ecom_user_08/pages/login_page.dart';
import 'package:flutter/material.dart';

import '../pages/launcher_page.dart';
import '../pages/order_page.dart';
import '../pages/user_profile_page.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            height: 150,
          ),
          if (!AuthService.currentUser!.isAnonymous)
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, UserProfilePage.routeName);
              },
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
            ),
          if (!AuthService.currentUser!.isAnonymous)
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.shopping_cart),
              title: const Text('My Cart'),
            ),
          if (!AuthService.currentUser!.isAnonymous)
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, OrderPage.routeName);
              },
              leading: const Icon(Icons.monetization_on),
              title: const Text('My Orders'),
            ),
          if (AuthService.currentUser!.isAnonymous)
            ListTile(
              onTap: () {
                Navigator.pushReplacementNamed(context, LoginPage.routeName);
              },
              leading: const Icon(Icons.person),
              title: const Text('Login/Register'),
            ),
          ListTile(
            onTap: () {
              AuthService.logout().then((value) =>
                  Navigator.pushReplacementNamed(
                      context, LauncherPage.routeName));
            },
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

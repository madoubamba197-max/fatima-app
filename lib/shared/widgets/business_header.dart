import 'package:flutter/material.dart';

import '../../core/current_business.dart';
import '../../config/business_config.dart';
import '../../pages/admin/admin_login_page.dart';
import '../../core/app_storage/application_manager.dart';

class BusinessHeader extends StatefulWidget {
  const BusinessHeader({super.key});

  @override
  State<BusinessHeader> createState() => _BusinessHeaderState();
}

class _BusinessHeaderState extends State<BusinessHeader> {
  int logoTapCount = 0;

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: BusinessConfig.primaryColor,

        borderRadius: const BorderRadius.only(

          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),

        ),

      ),

      child: Column(

        children: [

          GestureDetector(

  onLongPress: () {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => const AdminLoginPage(),

      ),

    );

  },

  child: const CircleAvatar(

    radius: 45,

    child: Icon(

      Icons.store,

      size: 50,

    ),

  ),

),

          const SizedBox(height: 15),

          Text(

            CurrentBusiness.app?.name ??
                BusinessConfig.name,

            style: const TextStyle(

              fontSize: 26,

              fontWeight: FontWeight.bold,

              color: Colors.white,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            CurrentBusiness.app?.slogan ?? BusinessConfig.slogan,

            style: const TextStyle(

              fontSize: 16,

              color: Colors.white70,

            ),

          ),

        ],

      ),

    );

  }
}
import 'package:flutter/material.dart';
import 'business_modules.dart';

class BusinessCreation {

  final String name;
  final String slogan;
  final String phone;
  final String whatsapp;
  final String address;
  final String currency;
  final Color color;

  final BusinessModules modules;


  const BusinessCreation({

    required this.name,
    required this.slogan,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.currency,
    required this.color,

    required this.modules,

  });

}
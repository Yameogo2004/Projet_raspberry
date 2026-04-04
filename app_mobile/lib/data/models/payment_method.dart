import 'package:flutter/material.dart';
enum PaymentMethodType {
  card,
  cash,
  appMoney,
}

class PaymentMethod {
  final PaymentMethodType type;
  final String name;
  final IconData icon;
  final String color;

  PaymentMethod({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<PaymentMethod> getMethods() {
    return [
      PaymentMethod(
        type: PaymentMethodType.card,
        name: 'Carte bancaire',
        icon: Icons.credit_card,
        color: '#1E3A5F',
      ),
      PaymentMethod(
        type: PaymentMethodType.cash,
        name: 'Espèces',
        icon: Icons.money,
        color: '#2E7D32',
      ),
      PaymentMethod(
        type: PaymentMethodType.appMoney,
        name: 'App Money',
        icon: Icons.phone_android,
        color: '#F5A623',
      ),
    ];
  }
}

class CardPayment {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;

  CardPayment({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
  });

  String get maskedCardNumber {
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'card_holder_name': cardHolderName,
    };
  }
}

class AppMoneyPayment {
  final String provider;
  final String phoneNumber;

  AppMoneyPayment({
    required this.provider,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'phone_number': phoneNumber,
    };
  }
}
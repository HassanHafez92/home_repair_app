// File: lib/models/payment_method_model.dart
// Purpose: Data model for payment methods (cards).

import 'package:flutter/material.dart';

enum CardType { visa, mastercard, amex, discover, unknown }

class PaymentMethod {
  final String id;
  final CardType cardType;
  final String last4Digits;
  final String expiryDate; // Format: MM/YY
  final String cardHolderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardType,
    required this.last4Digits,
    required this.expiryDate,
    required this.cardHolderName,
    this.isDefault = false,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardType': cardType.name,
      'last4Digits': last4Digits,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'isDefault': isDefault,
    };
  }

  // Create from Firestore JSON
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      cardType: CardType.values.firstWhere(
        (e) => e.name == json['cardType'],
        orElse: () => CardType.unknown,
      ),
      last4Digits: json['last4Digits'] as String,
      expiryDate: json['expiryDate'] as String,
      cardHolderName: json['cardHolderName'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  // Create a copy with modified fields
  PaymentMethod copyWith({
    String? id,
    CardType? cardType,
    String? last4Digits,
    String? expiryDate,
    String? cardHolderName,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      last4Digits: last4Digits ?? this.last4Digits,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Get masked card number
  String get maskedCardNumber {
    return '**** **** **** $last4Digits';
  }

  // Detect card type from card number
  static CardType detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');

    if (cleaned.startsWith('4')) {
      return CardType.visa;
    } else if (cleaned.startsWith(RegExp(r'5[1-5]'))) {
      return CardType.mastercard;
    } else if (cleaned.startsWith(RegExp(r'3[47]'))) {
      return CardType.amex;
    } else if (cleaned.startsWith('6011') ||
        cleaned.startsWith(RegExp(r'65'))) {
      return CardType.discover;
    }

    return CardType.unknown;
  }

  // Get icon for card type
  IconData getIcon() {
    switch (cardType) {
      case CardType.visa:
        return Icons.credit_card; // In a real app, use FontAwesomeIcons.ccVisa
      case CardType.mastercard:
        return Icons
            .credit_card; // In a real app, use FontAwesomeIcons.ccMastercard
      case CardType.amex:
        return Icons.credit_card; // In a real app, use FontAwesomeIcons.ccAmex
      case CardType.discover:
        return Icons
            .credit_card; // In a real app, use FontAwesomeIcons.ccDiscover
      default:
        return Icons.credit_card;
    }
  }
}

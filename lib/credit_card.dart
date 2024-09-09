import 'dart:convert';

/// Represents a credit card model with essential information.
///
/// This class encapsulates the details of a credit card, including the card number,
/// expiration date (month and year), and the cardholder's name.
class CreditCardModel {
  /// The credit card number.
  String number;

  /// The expiration month of the credit card.
  String expirationMonth;

  /// The expiration year of the credit card.
  String expirationYear;

  /// The name of the credit card holder.
  String holderName;

  /// Constructs a [CreditCardModel] with the required parameters.
  ///
  /// [number]: The credit card number.
  /// [expirationMonth]: The month of expiration.
  /// [expirationYear]: The year of expiration.
  /// [holderName]: The name of the cardholder.
  CreditCardModel({
    required this.number,
    required this.expirationMonth,
    required this.expirationYear,
    required this.holderName,
  });

  /// Creates a [CreditCardModel] from a JSON string.
  ///
  /// [source]: A JSON-encoded string containing credit card information.
  factory CreditCardModel.fromJson(String source) =>
      CreditCardModel.fromMap(json.decode(source));

  /// Creates a [CreditCardModel] from a map of key-value pairs.
  ///
  /// [map]: A map containing credit card information.
  factory CreditCardModel.fromMap(Map<String, dynamic> map) {
    return CreditCardModel(
      number: map['number'] ?? '',
      expirationMonth: map['expirationMonth'] ?? '',
      expirationYear: map['expirationYear'] ?? '',
      holderName: map['holderName'] ?? '',
    );
  }

  /// Returns the expiry date in the format 'MM/YYYY'.
  String get expiryDate => '$expirationMonth/$expirationYear';

  /// Generates a hash code for the [CreditCardModel].
  @override
  int get hashCode {
    return number.hashCode ^
        expirationMonth.hashCode ^
        expirationYear.hashCode ^
        holderName.hashCode;
  }

  /// Checks if the credit card information is valid.
  ///
  /// Returns true if all required fields are non-empty.
  bool get isValide =>
      number.isNotEmpty &&
      expirationMonth.isNotEmpty &&
      expirationYear.isNotEmpty;

  /// Compares this [CreditCardModel] with another object for equality.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreditCardModel &&
        other.number == number &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.holderName == holderName;
  }

  /// Creates a copy of this [CreditCardModel] with the given fields replaced with new values.
  ///
  /// Returns a new [CreditCardModel] instance with updated fields.
  CreditCardModel copyWith({
    String? number,
    String? expirationMonth,
    String? expirationYear,
    String? holderName,
  }) {
    return CreditCardModel(
      number: number ?? this.number,
      expirationMonth: expirationMonth ?? this.expirationMonth,
      expirationYear: expirationYear ?? this.expirationYear,
      holderName: holderName ?? this.holderName,
    );
  }

  /// Converts this [CreditCardModel] to a JSON string.
  String toJson() => json.encode(toMap());

  /// Converts this [CreditCardModel] to a map of key-value pairs.
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'number': number});
    result.addAll({'expirationMonth': expirationMonth});
    result.addAll({'expirationYear': expirationYear});
    result.addAll({'holderName': holderName});

    return result;
  }

  /// Returns a string representation of this [CreditCardModel].
  @override
  String toString() {
    return 'CreditCardModel(number: $number, expirationMonth: $expirationMonth, expirationYear: $expirationYear, holderName: $holderName)';
  }
}

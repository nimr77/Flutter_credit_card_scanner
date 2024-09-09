import 'dart:convert';

class CreditCardModel {
  String number;
  String expirationMonth;
  String expirationYear;
  // String cvv;
  String holderName;

  CreditCardModel({
    required this.number,
    required this.expirationMonth,
    required this.expirationYear,
    required this.holderName,
  });

  factory CreditCardModel.fromJson(String source) =>
      CreditCardModel.fromMap(json.decode(source));

  factory CreditCardModel.fromMap(Map<String, dynamic> map) {
    return CreditCardModel(
      number: map['number'] ?? '',
      expirationMonth: map['expirationMonth'] ?? '',
      expirationYear: map['expirationYear'] ?? '',
      holderName: map['holderName'] ?? '',
    );
  }

  String get expiryDate => '$expirationMonth/$expirationYear';

  @override
  int get hashCode {
    return number.hashCode ^
        expirationMonth.hashCode ^
        expirationYear.hashCode ^
        holderName.hashCode;
  }

  bool get isValide =>
      number.isNotEmpty &&
      expirationMonth.isNotEmpty &&
      expirationYear.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreditCardModel &&
        other.number == number &&
        other.expirationMonth == expirationMonth &&
        other.expirationYear == expirationYear &&
        other.holderName == holderName;
  }

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

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'number': number});
    result.addAll({'expirationMonth': expirationMonth});
    result.addAll({'expirationYear': expirationYear});
    result.addAll({'holderName': holderName});

    return result;
  }

  @override
  String toString() {
    return 'CreditCardModel(number: $number, expirationMonth: $expirationMonth, expirationYear: $expirationYear, holderName: $holderName)';
  }
}

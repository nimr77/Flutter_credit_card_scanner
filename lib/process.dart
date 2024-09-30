import 'credit_card.dart';

/// A class that processes strings to extract credit card information.
class ProccessCreditCard {
  /// The extracted credit card number.
  String cardNumber = '';

  /// The extracted cardholder name.
  String cardName = '';

  /// The extracted card expiration month.
  String cardExpirationMonth = '';

  /// The extracted card expiration year.
  String cardExpirationYear = '';

  /// Whether to check for a credit card number.
  bool checkCreditCardNumber;

  /// Whether to check for a cardholder name.
  bool checkCreditCardName;

  /// Whether to check for a credit card expiry date.
  bool checkCreditCardExpiryDate;

  /// The extracted credit card information.
  CreditCardModel? creditCardModel;

  /// A list of 4-digit number strings, used to assemble the card number.
  final numberTextList = <String>[];

  /// Creates a new instance of [ProccessCreditCard].
  ///
  /// The [checkCreditCardNumber], [checkCreditCardName], and [checkCreditCardExpiryDate] parameters
  /// determine whether the processor should attempt to extract those pieces of information.
  ProccessCreditCard({
    this.cardNumber = "",
    this.cardName = "",
    this.cardExpirationMonth = "",
    this.cardExpirationYear = "",
    required this.checkCreditCardNumber,
    required this.checkCreditCardName,
    required this.checkCreditCardExpiryDate,
  });

  /// Returns the full expiry date in MM/YYYY format.
  String get fullExpiryDate => '$cardExpirationMonth/$cardExpirationYear';

  /// Returns a [CreditCardModel] if all required information has been extracted.
  ///
  /// Whether a piece of information is required is determined by the
  /// [checkCreditCardNumber], [checkCreditCardName], and [checkCreditCardExpiryDate] parameters.
  CreditCardModel? getCreditCardModel() {
    if ((cardNumber.isNotEmpty || !checkCreditCardNumber) &&
        (cardName.isNotEmpty || !checkCreditCardName) &&
        ((cardExpirationYear.isNotEmpty && cardExpirationMonth.isNotEmpty) ||
            !checkCreditCardExpiryDate)) {
      creditCardModel = CreditCardModel(
        number: cardNumber,
        expirationMonth: cardExpirationMonth,
        expirationYear: cardExpirationYear,
        holderName: cardName,
      );
      return creditCardModel;
    }
    return null;
  }

  /// Attempts to extract the expiry date from the given text.
  ///
  /// Returns the extracted expiry date in MM/YY format, or null if no date is found.
  String? processDate(String text) {
    if (text.contains(RegExp(r'\/')) &&
        text.length > 4 &&
        text.length < 10 &&
        checkCreditCardExpiryDate) {
      if (text.contains('/')) {
        String cardExpirationMonthT = text.split('/').first;
        String cardExpirationYearT = text.split('/').last;

        if (cardExpirationMonthT.length == 1) {
          cardExpirationMonthT = '0$cardExpirationMonth';
        }

        if (cardExpirationYearT.length == 2 &&
            cardExpirationMonthT.length == 2) {
          if (int.tryParse(cardExpirationYearT) != null &&
              int.tryParse(cardExpirationMonthT) != null) {
            cardExpirationMonth = cardExpirationMonthT;
            cardExpirationYear = cardExpirationYearT;
          }
        }
      }
    }

    return fullExpiryDate.length > 4 ? fullExpiryDate : null;
  }

  /// Attempts to extract the cardholder name from the given text.
  ///
  /// Returns the extracted cardholder name, or null if no name is found.
  String? processName(String text) {
    if (text.contains(RegExp(r'[a-zA-Z]'))) {
      final hasSpace = text.contains(' ');
      final hasNumber = text.contains(RegExp(r'[0-9]'));
      if (hasSpace) {
        final lines = text.split('\n');
        final validLines =
            lines.where((line) => line.trim().isNotEmpty && line.contains(' '));

        if (validLines.isNotEmpty) {
          if (hasNumber) {
            cardName = validLines.firstWhere(
              (line) => !line.contains(RegExp(r'[0-9]')),
              orElse: () => '',
            );
          } else {
            cardName = validLines.first;
          }
        }
      }
    }
    return cardName.isEmpty ? null : cardName;
  }

  /// Attempts to extract the credit card number from the given text.
  ///
  /// Returns the extracted credit card number, or null if no number is found.
  String? processNumber(String v) {
    // remove all non-numeric characters from the input text and keep the numbers
    final text = v.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.contains(RegExp(r'[0-9]')) && checkCreditCardNumber) {
      if (text.contains(' ') &&
          int.tryParse(text.replaceAll(" ", "")) != null &&
          text.split(" ").length == 4 &&
          text.split(" ").every((element) => element.length == 4) &&
          text.length > 8) {
        cardNumber = text;
      }
      if (v.length == 4 && int.tryParse(v) != null) {
        numberTextList.add(v);
        if (numberTextList.length == 4) {
          cardNumber = numberTextList.join(' ');

          numberTextList.clear();

          return cardNumber;
        }
      }

      if (text.length >= 16 && int.tryParse(text) != null) {
        numberTextList.clear();

        cardNumber = text;
      }
    }
    return cardNumber.isEmpty ? null : cardNumber;
  }

  /// Processes the given text to extract credit card information.
  ///
  /// Returns a [CreditCardModel] containing the extracted information, or null if
  /// not all required information is found.
  CreditCardModel? processString(String text) {
    // Check for expiration date
    processDate(text);

    // Check for card number
    processNumber(text);

    // Check for cardholder's name
    processName(text);

    return getCreditCardModel();
  }
}

import 'credit_card.dart';

class ProccessCreditCard {
  String cardNumber = '';

  String cardName = '';

  String cardExpirationMonth = '';

  String cardExpirationYear = '';

  bool checkCreditCardNumber;
  bool checkCreditCardName;
  bool checkCreditCardExpiryDate;

  CreditCardModel? creditCardModel;

  final numberTextList = <String>[];

  ProccessCreditCard({
    this.cardNumber = "",
    this.cardName = "",
    this.cardExpirationMonth = "",
    this.cardExpirationYear = "",
    required this.checkCreditCardNumber,
    required this.checkCreditCardName,
    required this.checkCreditCardExpiryDate,
  });

  String get fullExpiryDate => '$cardExpirationMonth/$cardExpirationYear';

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

  String? processName(String text) {
    if (text.contains(RegExp(r'[a-zA-Z]'))) {
      final hasSpace = text.contains(' ');
      final hasNumber = text.contains(RegExp(r'[0-9]'));
      if (hasSpace) {
        if (text.contains('\n') && hasNumber) {
          final lines = text.split('\n');

          if (lines.isNotEmpty &&
              lines.any((element) =>
                  element.contains(' ') &&
                  !element.contains(RegExp(r'[0-9]')))) {
            cardName = lines.firstWhere((element) =>
                element.contains(' ') && !element.contains(RegExp(r'[0-9]')));
          }
        } else {
          if (!hasNumber) {
            final hasEndOfLine = text.contains(RegExp(r'\n'));
            if (hasEndOfLine) {
              final lines = text.split('\n');

              if (lines.isNotEmpty &&
                  lines.any((element) => element.contains(' '))) {
                cardName = lines.firstWhere((element) => element.contains(' '));
              }
            }
          }
        }
      }
    }
    return cardName.isEmpty ? null : cardName;
  }

  String? processNumber(String text) {
    if (text.contains(RegExp(r'[0-9]')) && checkCreditCardNumber) {
      if (text.contains(' ') &&
          int.tryParse(text.replaceAll(" ", "")) != null &&
          text.split(" ").length == 4 &&
          text.split(" ").every((element) => element.length == 4) &&
          text.length > 8) {
        cardNumber = text;
      }
      if (text.length == 4 && int.tryParse(text) != null) {
        numberTextList.add(text);
        if (numberTextList.length == 4) {
          cardNumber = numberTextList.join(' ');

          numberTextList.clear();

          return cardNumber;
        }
      }
    }
    return null;
  }

  // Process each text block to identify card information
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

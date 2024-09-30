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

  ProccessCreditCard({
    this.cardNumber = "",
    this.cardName = "",
    this.cardExpirationMonth = "",
    this.cardExpirationYear = "",
    required this.checkCreditCardNumber,
    required this.checkCreditCardName,
    required this.checkCreditCardExpiryDate,
  });

  // Process each text block to identify card information
  CreditCardModel? processString(String text) {
    // Check for expiration date
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

    // Check for card number
    if (text.contains(RegExp(r'[0-9]')) &&
        text.length > 8 &&
        checkCreditCardNumber) {
      if (text.contains(' ') &&
          int.tryParse(text.replaceAll(" ", "")) != null &&
          text.split(" ").length == 4 &&
          text.split(" ").every((element) => element.length == 4)) {
        cardNumber = text;
      }
    }

    // Check for cardholder's name
    if (text.contains(RegExp(r'[a-zA-Z]')) && text.contains(' ')) {
      final hasNumber = text.contains(RegExp(r'[0-9]'));

      if (text.contains('\n') && hasNumber) {
        final lines = text.split('\n');

        if (lines.isNotEmpty &&
            lines.any((element) =>
                element.contains(' ') && !element.contains(RegExp(r'[0-9]')))) {
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
          cardName = text;
        }
      }
    }

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
}

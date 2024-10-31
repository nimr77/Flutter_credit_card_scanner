import 'package:credit_card_validator/credit_card_validator.dart';

import 'credit_card.dart';
import 'helpers.dart';

String removeNonDigitsKeepSpaces(String text) {
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    final char = text[i];
    if (char.contains(RegExp(r'[0-9 ]'))) {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

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

  /// use Luhn algorithm to check if the number is valid
  final bool useLuhnValidation;

  /// The extracted credit card information.
  final _ccValidator = CreditCardValidator();

  /// Creates a new instance of [ProccessCreditCard].
  ///
  /// The [checkCreditCardNumber], [checkCreditCardName], and [checkCreditCardExpiryDate] parameters
  /// determine whether the processor should attempt to extract those pieces of information.
  ProccessCreditCard({
    this.cardNumber = "",
    this.cardName = "",
    this.cardExpirationMonth = "",
    this.cardExpirationYear = "",
    this.useLuhnValidation = true,
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
    final t = CreditCardModel(
      number: checkCreditCardNumber ? cardNumber : "",
      holderName: checkCreditCardName ? cardName : "",
      expirationMonth: checkCreditCardExpiryDate ? cardExpirationMonth : "",
      expirationYear: checkCreditCardExpiryDate ? cardExpirationYear : "",
    );

    if (t.number.isEmpty && checkCreditCardNumber) {
      return null;
    }

    if (t.expiryDate.isEmpty && checkCreditCardExpiryDate) {
      return null;
    }

    if (t.holderName.isEmpty && checkCreditCardName) {
      return null;
    }

    creditCardModel = t;

    return creditCardModel;
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
        final fullText = '$cardExpirationMonthT/$cardExpirationYearT';

        final x = _ccValidator.validateExpDate(fullText);
        if (x.isValid) {
          final pdate = parseDate(fullText);

          if (pdate.length >= 2) {
            cardExpirationMonth = pdate[0];
            cardExpirationYear = pdate[1];
          }
          return fullExpiryDate;
        }

        // if (cardExpirationYearT.length == 2 &&
        //     cardExpirationMonthT.length == 2) {
        //   if (int.tryParse(cardExpirationYearT) != null &&
        //       int.tryParse(cardExpirationMonthT) != null) {
        //     cardExpirationMonth = cardExpirationMonthT;
        //     cardExpirationYear = cardExpirationYearT;
        //   }
        // }
      }
    }

    return fullExpiryDate.length > 4 ? fullExpiryDate : null;
  }

  /// Attempts to extract the cardholder name from the given text.
  ///
  /// Returns the extracted cardholder name, or null if no name is found.
  String? processName(String text) {
    if (!checkCreditCardName) {
      return null;
    }

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
  String? processNumber(String number) {
    if (!checkCreditCardNumber) {
      return null;
    }

    if (number.contains("L")) {
      number = number.replaceAll("L", "1");
    }

    final v = _ccValidator.validateCCNum(number,
        ignoreLuhnValidation: !useLuhnValidation);

    if (v.isValid) {
      cardNumber = number;

      return cardNumber;
    }
    return null;

    // // remove all non-numeric characters from the input text and keep the numbers
    // final text = removeNonDigitsKeepSpaces(v);

    // if (text.contains(RegExp(r'[0-9]')) && checkCreditCardNumber) {
    //   if (text.contains(' ') &&
    //       int.tryParse(text.replaceAll(" ", "")) != null &&
    //       text.split(" ").length == 4 &&
    //       text.split(" ").every((element) => element.length == 4) &&
    //       text.length > 8) {
    //     cardNumber = text;
    //     numberTextList.clear();
    //   }

    //   if (!onlySpaces) {
    //     if (v.length == 4 && int.tryParse(v) != null) {
    //       numberTextList.add(v);
    //       if (numberTextList.length == 4) {
    //         cardNumber = numberTextList.join(' ');

    //         numberTextList.clear();

    //         return cardNumber;
    //       }
    //     }

    //     if (text.length >= 16 && int.tryParse(text) != null) {
    //       numberTextList.clear();

    //       cardNumber = text;
    //     }
    //   }
    // }
    // return cardNumber.isEmpty ? null : cardNumber;
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

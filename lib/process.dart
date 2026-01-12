import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:credit_card_validator/validation_results.dart';

import 'credit_card.dart';
import 'helpers.dart';

String removeNonDigits(String text) {
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    final char = text[i];
    if (char.contains(RegExp(r'[0-9]'))) {
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

  /// The validation results for the card number.
  CCNumValidationResults? _v;

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

    t.creditCardNumberValidationResults = _v;

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
        // remove everything that is not a digit and not /

        String cardExpirationMonthT = removeNonDigits(text.split('/').first);
        String cardExpirationYearT = removeNonDigits(text.split('/').last);

        if (cardExpirationMonthT.length == 1) {
          cardExpirationMonthT = '0$cardExpirationMonth';
        }

        if (cardExpirationYearT.length >= 4) {
          cardExpirationYearT = cardExpirationYearT.substring(2);
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

    if (text.contains(RegExp(r'[a-zA-Z\.]'))) {
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
  /// Supports both single-line full card numbers and multi-line card numbers
  /// where each line contains digit groups (typically 4 digits, but can be 1-4
  /// for cards with non-standard lengths like 17-digit Maestro cards).
  String? processNumber(String text) {
    if (!checkCreditCardNumber) {
      return null;
    }

    // Fix common OCR error: L misread as 1
    text = text.replaceAll("L", "1");

    // Strip trailing OCR artifacts that start with a letter (e.g., "5127 8810 3138 2740 N1" → "5127 8810 3138 2740")
    // The regex matches: space(s) + letter + any alphanumeric chars at end of string
    final cleanedText = text.replaceAll(RegExp(r'\s+[a-zA-Z][a-zA-Z0-9]*$'), '').trim();

    // Try direct validation first (single line with full number)
    final v = _ccValidator.validateCCNum(cleanedText, ignoreLuhnValidation: !useLuhnValidation);

    if (v.isValid) {
      cardNumber = cleanedText;
      _v = v;
      numberTextList.clear();
      return cardNumber;
    }

    // Check for digit groups (multi-line card number support)
    // Support groups of 1-4 digits for cards with varying lengths (e.g., 17-digit cards)
    final digitsOnly = removeNonDigits(text);

    // Skip if text contains letters (likely OCR artifact like "N1", not a card number group)
    if (text.contains(RegExp(r'[a-zA-Z]'))) {
      return null;
    }

    if (digitsOnly.isNotEmpty && digitsOnly.length <= 4) {
      numberTextList.add(digitsOnly);

      // Try to form a card number with current groups (supports 4-5 groups for 16-19 digit cards)
      if (numberTextList.length >= 4 && numberTextList.length <= 5) {
        final combined = numberTextList.join();
        final validation = _ccValidator.validateCCNum(combined, ignoreLuhnValidation: !useLuhnValidation);

        if (validation.isValid) {
          cardNumber = combined;
          _v = validation;
          numberTextList.clear();
          return cardNumber;
        } else if (numberTextList.length == 5) {
          // If 5 groups didn't work, remove oldest and keep trying
          numberTextList.removeAt(0);
        }
      }
    } else if (digitsOnly.length > 4) {
      // Reset accumulator if we see a line with more than 4 digits
      numberTextList.clear();
    }

    return null;
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

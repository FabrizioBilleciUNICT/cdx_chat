import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CdxChatLocalizations
/// returned by `CdxChatLocalizations.of(context)`.
///
/// Applications need to include `CdxChatLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CdxChatLocalizations.localizationsDelegates,
///   supportedLocales: CdxChatLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CdxChatLocalizations.supportedLocales
/// property.
abstract class CdxChatLocalizations {
  CdxChatLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CdxChatLocalizations? of(BuildContext context) {
    return Localizations.of<CdxChatLocalizations>(
      context,
      CdxChatLocalizations,
    );
  }

  static const LocalizationsDelegate<CdxChatLocalizations> delegate =
      _CdxChatLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Title for chat section
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Placeholder text for message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_a_message;

  /// Button text to send a message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Label showing who you are replying to
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replying_to;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for delete message dialog
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get delete_message;

  /// Confirmation question for deleting a message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get q_delete_message;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Block user action label
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get block_user;

  /// Unblock user action label
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get unblock_user;

  /// Confirmation question for blocking a user
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get q_block_user;

  /// Confirmation question for unblocking a user
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user?'**
  String get q_unblock_user;

  /// Error message when message is empty
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get message_empty;

  /// Error message when message is too long
  ///
  /// In en, this message translates to:
  /// **'Message cannot exceed {maxLength} characters'**
  String message_too_long(int maxLength);

  /// Error message when message has too many lines
  ///
  /// In en, this message translates to:
  /// **'Message cannot exceed {maxLines} lines'**
  String message_too_many_lines(int maxLines);

  /// Message shown when there are no messages
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get no_messages;

  /// Error message when messages fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get error_loading_messages;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Text shown for deleted messages
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get message_deleted;

  /// Error message when sending a message fails
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get error_sending_message;

  /// Label for today's date in date separator
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for yesterday's date in date separator
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;
}

class _CdxChatLocalizationsDelegate
    extends LocalizationsDelegate<CdxChatLocalizations> {
  const _CdxChatLocalizationsDelegate();

  @override
  Future<CdxChatLocalizations> load(Locale locale) {
    return SynchronousFuture<CdxChatLocalizations>(
      lookupCdxChatLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_CdxChatLocalizationsDelegate old) => false;
}

CdxChatLocalizations lookupCdxChatLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CdxChatLocalizationsEn();
    case 'it':
      return CdxChatLocalizationsIt();
  }

  throw FlutterError(
    'CdxChatLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class CdxChatLocalizationsIt extends CdxChatLocalizations {
  CdxChatLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get chat => 'Chat';

  @override
  String get type_a_message => 'Scrivi un messaggio...';

  @override
  String get send => 'Invia';

  @override
  String get replying_to => 'Rispondi a';

  @override
  String get delete => 'Elimina';

  @override
  String get delete_message => 'Elimina messaggio';

  @override
  String get q_delete_message =>
      'Sei sicuro di voler eliminare questo messaggio?';

  @override
  String get confirm => 'Conferma';

  @override
  String get cancel => 'Annulla';

  @override
  String get block_user => 'Blocca utente';

  @override
  String get unblock_user => 'Sblocca utente';

  @override
  String get q_block_user => 'Sei sicuro di voler bloccare questo utente?';

  @override
  String get q_unblock_user => 'Sei sicuro di voler sbloccare questo utente?';

  @override
  String get message_empty => 'Il messaggio non può essere vuoto';

  @override
  String message_too_long(int maxLength) {
    return 'Il messaggio non può superare $maxLength caratteri';
  }

  @override
  String message_too_many_lines(int maxLines) {
    return 'Il messaggio non può superare $maxLines righe';
  }

  @override
  String get no_messages => 'Nessun messaggio';

  @override
  String get error_loading_messages => 'Errore nel caricamento dei messaggi';

  @override
  String get retry => 'Riprova';

  @override
  String get message_deleted => 'Messaggio eliminato';

  @override
  String get error_sending_message => 'Errore nell\'invio del messaggio';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';
}

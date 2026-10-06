// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class CdxChatLocalizationsEs extends CdxChatLocalizations {
  CdxChatLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get chat => 'Chat';

  @override
  String get type_a_message => 'Escribe un mensaje...';

  @override
  String get send => 'Enviar';

  @override
  String get replying_to => 'Respondiendo a';

  @override
  String get delete => 'Eliminar';

  @override
  String get delete_message => 'Eliminar mensaje';

  @override
  String get q_delete_message => '¿Seguro que quieres eliminar este mensaje?';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get block_user => 'Bloquear usuario';

  @override
  String get unblock_user => 'Desbloquear usuario';

  @override
  String get q_block_user => '¿Seguro que quieres bloquear a este usuario?';

  @override
  String get q_unblock_user =>
      '¿Seguro que quieres desbloquear a este usuario?';

  @override
  String get message_empty => 'El mensaje no puede estar vacío';

  @override
  String message_too_long(int maxLength) {
    return 'El mensaje no puede superar $maxLength caracteres';
  }

  @override
  String message_too_many_lines(int maxLines) {
    return 'El mensaje no puede superar $maxLines líneas';
  }

  @override
  String get no_messages => 'No hay mensajes';

  @override
  String get error_loading_messages => 'Error al cargar los mensajes';

  @override
  String get retry => 'Reintentar';

  @override
  String get message_deleted => 'Mensaje eliminado';

  @override
  String get error_sending_message => 'Error al enviar el mensaje';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get report => 'Reportar';

  @override
  String get reply => 'Responder';

  @override
  String get q_report_message => '¿Por qué reportas este mensaje?';

  @override
  String get q_report_user => '¿Quieres reportar o bloquear a este usuario?';

  @override
  String get report_user => 'Reportar usuario';

  @override
  String get report_done => 'Reporte enviado correctamente';

  @override
  String get next => 'Siguiente';

  @override
  String get end => 'Enviar';
}

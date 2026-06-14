// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Vista Previa Polydeck';

  @override
  String get cardFront => 'Frente de la Carta';

  @override
  String get cardBack => 'Reverso de la Carta';

  @override
  String get flipRed => 'Voltear Rojo';

  @override
  String get flipYellow => 'Voltear Amarillo';

  @override
  String get flipGreen => 'Voltear Verde';

  @override
  String get reflip => 'Voltear de Nuevo';

  @override
  String get newCard => 'Nueva Carta';

  @override
  String cardCount(Object index, Object total) {
    return 'Carta $index / $total';
  }

  @override
  String get analysis => 'Análisis';

  @override
  String get analysisResults => 'Resultados del Análisis:';

  @override
  String previousDeck(Object deckName) {
    return 'Deck Anterior: $deckName';
  }

  @override
  String get startNewDeck => 'Iniciar Nuevo Deck';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Carta $index: $color';
  }

  @override
  String get decks => 'Decks';

  @override
  String get deckPage => 'Página del Deck';

  @override
  String get a1Deck => 'Deck A1';

  @override
  String deck(Object index) {
    return 'Deck $index';
  }

  @override
  String get question => 'Pregunta';

  @override
  String get nextQuestion => 'Pregunta Siguiente';

  @override
  String get finishExam => 'Finalizar Examen';

  @override
  String get exam => 'Examen';

  @override
  String get testResult => 'Resultado del Examen';

  @override
  String get recommendation => 'Deck Recomendado';

  @override
  String get score => 'Puntuación';

  @override
  String get red => 'Rojo';

  @override
  String get yellow => 'Amarillo';

  @override
  String get green => 'Verde';

  @override
  String get grey => 'Gris';

  @override
  String get instructionsTitle => 'Instrucciones';

  @override
  String get instructionsContent =>
      'Deslizar a la Izquierda: Marcar como Rojo (Difícil)\nDeslizar hacia Abajo: Marcar como Amarillo (Medio)\nDeslizar a la Derecha: Marcar como Verde (Fácil)\n\nToca \'Voltear de Nuevo\' para intentar la carta nuevamente.';

  @override
  String get result => 'Resultado';

  @override
  String get reviewAnswers => 'Revisar Respuestas';

  @override
  String get restartExam => 'Reiniciar Examen';

  @override
  String get help => 'Ayuda';

  @override
  String get confirmRestart =>
      '¿Estás seguro de que deseas reiniciar el examen?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get correct => 'Correcto';

  @override
  String get incorrect => 'Incorrecto';

  @override
  String get unanswered => 'Sin Respuesta';

  @override
  String get review => 'Revisar';

  @override
  String totalQuestions(Object total) {
    return 'Total de Preguntas: $total';
  }

  @override
  String get answered => 'Respondido';

  @override
  String unansweredCount(Object count) {
    return 'Sin Respuesta: $count';
  }

  @override
  String get resultTitle => 'Resultados del Examen';

  @override
  String get pass => '¡Felicidades! Has aprobado el examen.';

  @override
  String get fail => 'No has aprobado el examen. ¡Mejor suerte la próxima vez!';

  @override
  String percentage(Object percentage) {
    return 'Tu Puntaje: $percentage%';
  }

  @override
  String get backToDeck => 'Volver al Deck';

  @override
  String get backToHome => 'Volver al Inicio';

  @override
  String get yourAnswer => 'Tu Respuesta';

  @override
  String get correctAnswer => 'Respuesta Correcta';

  @override
  String get recommendedDeck => 'Deck Recomendado';

  @override
  String get yourScore => 'Puntaje';

  @override
  String get settings => 'Configuraciones';

  @override
  String get settingsContent => 'Aquí puedes ajustar tus preferencias.';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get choosePage => 'Elegir Página';

  @override
  String get goExam => 'Ir al Examen';

  @override
  String get selectLevel => 'Seleccionar Niveles';

  @override
  String get confirmLevels => 'Confirmar';

  @override
  String get firstTimeTitle => 'Seleccionar Idiomas';

  @override
  String get firstTimeContent =>
      'Por favor, selecciona tu lengua materna y lengua objetivo.';

  @override
  String get close => 'Cerrar';

  @override
  String get weeklyProgress => 'Progreso Semanal';

  @override
  String get monthlyProgress => 'Progreso Mensual';

  @override
  String get chartWeekly => 'Gráfico Semanal';

  @override
  String get chartMonthly => 'Gráfico Mensual';

  @override
  String get progression => 'Tu Progresión';

  @override
  String get progress => 'Progreso';

  @override
  String get changeLang => 'Cambiar Idioma';

  @override
  String get examIconTooltip => 'Tomar un Examen';

  @override
  String get combinedDeck => 'Deck Combinado';

  @override
  String get newDeck => 'Nuevo Deck';

  @override
  String get levelsSelected => 'Niveles Seleccionados';

  @override
  String get proceed => 'Proceder';

  @override
  String get targetLanguage => 'Lengua Objetivo';

  @override
  String get motherLanguage => 'Lengua Materna';

  @override
  String get firstTimePromptTitle => '¡Bienvenido!';

  @override
  String get firstTimePromptContent =>
      'Por favor, selecciona tu lengua materna y lengua objetivo.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get saveFailed => 'Falló al guardar las configuraciones';

  @override
  String get selectLanguages => 'Por favor, selecciona las lenguas.';

  @override
  String get decksPage => 'Decks Page';

  @override
  String get again => 'Otra vez';

  @override
  String get hard => 'Difícil';

  @override
  String get good => 'Bien';

  @override
  String get easy => 'Fácil';

  @override
  String get srsSettings => 'Ajustes SRS';

  @override
  String get dailyLimits => 'Límites diarios';

  @override
  String get globalSettings => 'Ajustes globales';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get loading => 'Cargando...';

  @override
  String get maxNewPerDay => 'Máx. nuevas por día';

  @override
  String get maxReviewsPerDay => 'Máx. repasos por día';

  @override
  String get enableFuzz => 'Activar variación aleatoria';

  @override
  String get fuzzDescription => 'Añade variación aleatoria a los intervalos';

  @override
  String get requestRetention => 'Retención deseada';

  @override
  String get resetAllSrsProgress => 'Restablecer todo el progreso SRS';

  @override
  String get resetSrsDescription =>
      'Restablece todas las tarjetas al estado Nuevo. El historial de repasos se conserva en el registro.';

  @override
  String get resetSrsStateTitle => '¿Restablecer estado SRS?';

  @override
  String get resetSrsConfirmation =>
      'Esto marcará todas las tarjetas como Nuevas. El historial de repasos se conservará. ¿Continuar?';

  @override
  String get reset => 'Restablecer';

  @override
  String get cancel => 'Cancelar';

  @override
  String get srsStateReset => 'El estado SRS ha sido restablecido.';

  @override
  String level(Object level) {
    return 'Nivel $level';
  }

  @override
  String newReviewsPerDay(Object newCount, Object reviewCount) {
    return '$newCount nuevas / $reviewCount repasos por día';
  }

  @override
  String newCount(Object newCount, Object maxNew) {
    return '$newCount / $maxNew nuevas';
  }

  @override
  String reviewCount(Object reviewCount, Object maxReviews) {
    return '$reviewCount / $maxReviews repasos';
  }
}

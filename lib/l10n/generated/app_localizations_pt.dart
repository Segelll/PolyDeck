// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Pré-visualização Polydeck';

  @override
  String get cardFront => 'Frente do Cartão';

  @override
  String get cardBack => 'Verso do Cartão';

  @override
  String get flipRed => 'Virar Vermelho';

  @override
  String get flipYellow => 'Virar Amarelo';

  @override
  String get flipGreen => 'Virar Verde';

  @override
  String get reflip => 'Virar Novamente';

  @override
  String get newCard => 'Novo Cartão';

  @override
  String cardCount(Object index, Object total) {
    return 'Cartão $index / $total';
  }

  @override
  String get analysis => 'Análise';

  @override
  String get analysisResults => 'Resultados da Análise:';

  @override
  String previousDeck(Object deckName) {
    return 'Deck Anterior: $deckName';
  }

  @override
  String get startNewDeck => 'Iniciar Novo Deck';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Cartão $index: $color';
  }

  @override
  String get decks => 'Decks';

  @override
  String get deckPage => 'Página do Deck';

  @override
  String get a1Deck => 'Deck A1';

  @override
  String deck(Object index) {
    return 'Deck $index';
  }

  @override
  String get question => 'Pergunta';

  @override
  String get nextQuestion => 'Próxima Pergunta';

  @override
  String get finishExam => 'Finalizar Exame';

  @override
  String get exam => 'Exame';

  @override
  String get testResult => 'Resultado do Exame';

  @override
  String get recommendation => 'Deck Recomendado';

  @override
  String get score => 'Pontuação';

  @override
  String get red => 'Vermelho';

  @override
  String get yellow => 'Amarelo';

  @override
  String get green => 'Verde';

  @override
  String get grey => 'Cinza';

  @override
  String get instructionsTitle => 'Instruções';

  @override
  String get instructionsContent =>
      'Deslize para a Esquerda: Marcar como Vermelho (Difícil)\nDeslize para Baixo: Marcar como Amarelo (Médio)\nDeslize para a Direita: Marcar como Verde (Fácil)\n\nToque em \'Virar Novamente\' para tentar o cartão novamente.';

  @override
  String get result => 'Resultado';

  @override
  String get reviewAnswers => 'Revisar Respostas';

  @override
  String get restartExam => 'Reiniciar Exame';

  @override
  String get help => 'Ajuda';

  @override
  String get confirmRestart => 'Tem certeza de que deseja reiniciar o exame?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get correct => 'Correto';

  @override
  String get incorrect => 'Incorreto';

  @override
  String get unanswered => 'Sem Resposta';

  @override
  String get review => 'Revisar';

  @override
  String totalQuestions(Object total) {
    return 'Total de Perguntas: $total';
  }

  @override
  String get answered => 'Respondido';

  @override
  String unansweredCount(Object count) {
    return 'Sem Resposta: $count';
  }

  @override
  String get resultTitle => 'Resultados do Exame';

  @override
  String get pass => 'Parabéns! Você passou no exame.';

  @override
  String get fail => 'Você não passou no exame. Melhor sorte na próxima vez!';

  @override
  String percentage(Object percentage) {
    return 'Sua Pontuação: $percentage%';
  }

  @override
  String get backToDeck => 'Voltar para o Deck';

  @override
  String get backToHome => 'Voltar para a Início';

  @override
  String get yourAnswer => 'Sua Resposta';

  @override
  String get correctAnswer => 'Resposta Correta';

  @override
  String get recommendedDeck => 'Deck Recomendado';

  @override
  String get yourScore => 'Pontuação';

  @override
  String get settings => 'Configurações';

  @override
  String get settingsContent => 'Aqui você pode ajustar suas preferências.';

  @override
  String get logout => 'Sair';

  @override
  String get choosePage => 'Escolher Página';

  @override
  String get goExam => 'Ir para o Exame';

  @override
  String get selectLevel => 'Selecionar Níveis';

  @override
  String get confirmLevels => 'Confirmar';

  @override
  String get firstTimeTitle => 'Selecionar Idiomas';

  @override
  String get firstTimeContent =>
      'Por favor, selecione sua língua materna e língua alvo.';

  @override
  String get close => 'Fechar';

  @override
  String get weeklyProgress => 'Progresso Semanal';

  @override
  String get monthlyProgress => 'Progresso Mensal';

  @override
  String get chartWeekly => 'Gráfico Semanal';

  @override
  String get chartMonthly => 'Gráfico Mensal';

  @override
  String get progression => 'Sua Progressão';

  @override
  String get progress => 'Progresso';

  @override
  String get changeLang => 'Mudar Idioma';

  @override
  String get examIconTooltip => 'Fazer um Exame';

  @override
  String get combinedDeck => 'Deck Combinado';

  @override
  String get newDeck => 'Novo Deck';

  @override
  String get levelsSelected => 'Níveis Selecionados';

  @override
  String get proceed => 'Prosseguir';

  @override
  String get targetLanguage => 'Língua Alvo';

  @override
  String get motherLanguage => 'Língua Materna';

  @override
  String get firstTimePromptTitle => 'Bem-vindo!';

  @override
  String get firstTimePromptContent =>
      'Por favor, selecione sua língua materna e língua alvo.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get saveFailed => 'Falha ao salvar as configurações';

  @override
  String get selectLanguages => 'Por favor, selecione as línguas.';

  @override
  String get decksPage => 'Página do Deck';

  @override
  String get again => 'De novo';

  @override
  String get hard => 'Difícil';

  @override
  String get good => 'Bom';

  @override
  String get easy => 'Fácil';

  @override
  String get srsSettings => 'Configurações SRS';

  @override
  String get dailyLimits => 'Limites diários';

  @override
  String get globalSettings => 'Configurações globais';

  @override
  String get dangerZone => 'Zona de perigo';

  @override
  String get loading => 'Carregando...';

  @override
  String get maxNewPerDay => 'Máx. novas por dia';

  @override
  String get maxReviewsPerDay => 'Máx. revisões por dia';

  @override
  String get enableFuzz => 'Ativar variação aleatória';

  @override
  String get fuzzDescription => 'Adiciona variação aleatória aos intervalos';

  @override
  String get requestRetention => 'Retenção desejada';

  @override
  String get resetAllSrsProgress => 'Redefinir todo o progresso SRS';

  @override
  String get resetSrsDescription =>
      'Redefine todas as cartas para o estado Novo. O histórico de revisões é preservado no registro.';

  @override
  String get resetSrsStateTitle => 'Redefinir estado SRS?';

  @override
  String get resetSrsConfirmation =>
      'Isso marcará todas as cartas como Novas. Seu histórico de revisões será mantido. Continuar?';

  @override
  String get reset => 'Redefinir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get srsStateReset => 'O estado SRS foi redefinido.';

  @override
  String level(Object level) {
    return 'Nível $level';
  }

  @override
  String newReviewsPerDay(Object newCount, Object reviewCount) {
    return '$newCount novas / $reviewCount revisões por dia';
  }

  @override
  String newCount(Object newCount, Object maxNew) {
    return '$newCount / $maxNew novas';
  }

  @override
  String reviewCount(Object reviewCount, Object maxReviews) {
    return '$reviewCount / $maxReviews revisões';
  }
}

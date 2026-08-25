/// Tempo relativo em PT-BR para feeds ('agora', 'há 5 min', 'há 2 h',
/// 'há 3 d'). Função pura: [now] pode ser injetado em testes.
///
/// Datas nulas ou no futuro (relógio dessincronizado) caem em 'agora';
/// datas com mais de 30 dias caem para data absoluta curta (dd/MM/yyyy).
String formatRelativeTime(DateTime? dateTime, {DateTime? now}) {
  if (dateTime == null) return 'agora';

  final DateTime reference = now ?? DateTime.now();
  final Duration difference = reference.difference(dateTime);

  if (difference.inSeconds < 60) return 'agora';
  if (difference.inMinutes < 60) return 'há ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'há ${difference.inHours} h';
  if (difference.inDays < 30) return 'há ${difference.inDays} d';

  final String day = dateTime.day.toString().padLeft(2, '0');
  final String month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year}';
}

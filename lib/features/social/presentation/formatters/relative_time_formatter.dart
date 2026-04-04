class RelativeTimeFormatter {
  const RelativeTimeFormatter();

  String formatEnglish(DateTime dateTime, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final difference = current.difference(dateTime);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}


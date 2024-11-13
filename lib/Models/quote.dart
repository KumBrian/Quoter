class Quote {
  final String author;
  final String quote;
  bool isLiked = false;

  Quote({required this.author, required this.quote});

  factory Quote.fromJson(List json) {
    return Quote(
      quote: json[0]['quote'],
      author: json[0]['author'],
    );
  }
}

class Quote {
  final String author;
  final String quote;
  bool isLiked = false;

  Quote({
    required this.author,
    required this.quote,
    required this.isLiked,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote &&
          runtimeType == other.runtimeType &&
          author == other.author &&
          quote == other.quote &&
          isLiked == other.isLiked);

  @override
  int get hashCode => author.hashCode ^ quote.hashCode ^ isLiked.hashCode;

  @override
  String toString() {
    return 'Quote{'
        ' author: $author,'
        ' quote: $quote,'
        ' isLiked: $isLiked,'
        '}';
  }

  Quote copyWith({
    String? author,
    String? quote,
    bool? isLiked,
  }) {
    return Quote(
      author: author ?? this.author,
      quote: quote ?? this.quote,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'quote': quote,
      'isLiked': isLiked,
    };
  }

  factory Quote.fromJson(List quote, int index) {
    return Quote(
      author: quote[index]['author'],
      quote: quote[index]['quote'],
      isLiked: false,
    );
  }
}

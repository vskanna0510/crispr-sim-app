// RAG chat API response model.

class RagChatResponse {
  final String answer;
  final List<String> sources;

  RagChatResponse({required this.answer, required this.sources});

  factory RagChatResponse.fromJson(Map<String, dynamic> j) => RagChatResponse(
        answer: j['answer'] as String,
        sources: (j['sources'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

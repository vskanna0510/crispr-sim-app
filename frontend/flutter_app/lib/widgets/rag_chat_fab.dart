// Global floating help: opens a bottom-sheet RAG chat tied to the backend /chat/rag.

import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

/// Wraps the whole app below the navigator; shows a chat FAB bottom-right.
class GlobalRagChatLayer extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalRagChatLayer({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        child,
        _ChatFab(navigatorKey: navigatorKey),
      ],
    );
  }
}

class _ChatFab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const _ChatFab({required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: FloatingActionButton.extended(
            heroTag: 'rag_chat_fab',
            onPressed: _openSheet,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Help'),
          ),
        ),
      ),
    );
  }

  void _openSheet() {
    final navContext = navigatorKey.currentContext;
    if (navContext == null) return;
    showModalBottomSheet<void>(
      context: navContext,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadius)),
      ),
      builder: (ctx) => const _RagChatSheet(),
    );
  }
}

class _ChatBubble {
  final bool isUser;
  final String text;
  _ChatBubble({required this.isUser, required this.text});
}

class _RagChatSheet extends StatefulWidget {
  const _RagChatSheet();

  @override
  State<_RagChatSheet> createState() => _RagChatSheetState();
}

class _RagChatSheetState extends State<_RagChatSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _api = ApiService();
  bool _busy = false;
  final List<_ChatBubble> _msgs = [
    _ChatBubble(
      isUser: false,
      text:
          'Hi! I am the CRISPR-Sim assistant. Ask about DNA, RNA, protein, PAM sites, '
          'NHEJ, HDR, frameshifts, or how to use each app screen.',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty || _busy) return;
    setState(() {
      _msgs.add(_ChatBubble(isUser: true, text: q));
      _ctrl.clear();
      _busy = true;
    });
    _scrollToEnd();

    try {
      final RagChatResponse r = await _api.ragChat(q);
      if (!mounted) return;
      setState(() {
        var text = r.answer;
        if (r.sources.isNotEmpty) {
          text += '\n\n—\nSources: ${r.sources.join(', ')}';
        }
        _msgs.add(_ChatBubble(isUser: false, text: text));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _msgs.add(
          _ChatBubble(
            isUser: false,
            text:
                'Could not reach the help server. Check your internet and that '
                'the API is running ($kBaseUrl).\n$e',
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final h = MediaQuery.sizeOf(context).height * 0.72;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(kPadMd, 0, kPadMd, kPadSm),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.biotech_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: kPadSm),
                  Expanded(
                    child: Text(
                      'CRISPR-Sim guide',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (_busy)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(kPadMd),
                itemCount: _msgs.length,
                itemBuilder: (context, i) {
                  final m = _msgs[i];
                  return Align(
                    alignment:
                        m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: kPadSm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: kPadMd,
                        vertical: kPadSm,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.86,
                      ),
                      decoration: BoxDecoration(
                        color: m.isUser
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(kRadius),
                      ),
                      child: SelectableText(
                        m.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: m.isUser
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kPadMd, 0, kPadMd, kPadMd),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask about the app, DNA/RNA/protein…',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: kPadSm),
                  FilledButton(
                    onPressed: _busy ? null : _send,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    child: const Icon(Icons.send_rounded, size: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

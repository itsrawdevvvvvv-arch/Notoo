import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Renders image embeds inside notes — stickers, photos and attached images —
/// from bundled assets or local files.
class NotooImageEmbedBuilder extends EmbedBuilder {
  const NotooImageEmbedBuilder();

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
    BuildContext context,
    Embed node,
    bool readOnly,
    QuillEditorConfig config,
  ) {
    final src = (node.value.data ?? '').toString();
    Widget child;
    if (src.startsWith('assets/')) {
      child = Image.asset(src, fit: BoxFit.contain);
    } else if (src.startsWith('http')) {
      child = Image.network(src, fit: BoxFit.contain);
    } else {
      child = Image.file(File(src), fit: BoxFit.contain);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: child,
    );
  }
}

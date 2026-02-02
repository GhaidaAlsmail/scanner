// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class RichTextWidget extends ConsumerWidget {
  const RichTextWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var controller = ref.watch(richTextProvider);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // QuillSimpleToolbar(
            //   controller: controller,
            //   configurations: const QuillSimpleToolbarConfigurations(
            //     showLink: false,
            //     showSubscript: false,
            //     showListCheck: false,
            //     showClipboardCopy: false,
            //     showClipboardCut: false,
            //     showClipboardPaste: false,
            //     showSearchButton: false,
            //     showCodeBlock: false,
            //     showHeaderStyle: false,
            //   ),
            // ),
            // Expanded(
            //   child: QuillEditor.basic(
            //     controller: controller,
            //     configurations: const QuillEditorConfigurations(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

var richTextProvider = StateProvider((ref) => QuillController.basic());

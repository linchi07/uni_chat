import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlankPositionPopUpMenu extends ConsumerWidget {
  final void Function() close;
  const BlankPositionPopUpMenu({super.key, required this.close});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200.0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(1, 1), // changes position of shadow
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add'),
              onTap: () {
                ref.read(editorControllerInstance).createNewBlock();
                close();
              },
            )
          ],
        ),
      ),
    );
  }
}

class OnBlockPopUpMenu extends ConsumerWidget {
  final void Function() close;
  final int bid;
  const OnBlockPopUpMenu({super.key, required this.close, required this.bid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200.0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(1, 1), // changes position of shadow
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('克隆'),
              onTap: () {
                ref.read(editorControllerInstance).createNewBlock();
                close();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除'),
              onTap: () {
                ref.read(editorControllerInstance).deleteBlock(bid);
                close();
              },
            ),
          ],
        ),
      ),
    );
  }
}

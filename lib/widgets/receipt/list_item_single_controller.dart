import 'package:flutter/material.dart';

class ListControllerGroup {
  List<ListController> controllers;
  ListControllerGroup([List<ListController>? controllerList])
      : controllers = controllerList ?? [];
}

class ListController {
  bool opened = false;
  Function? onOpen;
  Function? onClose;
  final ListControllerGroup group;
  ListController(this.group);

  void close() {
    opened = false;
    onClose?.call();
  }

  void open() {
    group.controllers
        .where((controller) => controller != this && controller.opened)
        .forEach((controller) {
      controller.close();
      debugPrint('Other controller closed');
    });
    debugPrint('Controller opened');
    opened = true;
    onOpen?.call();
  }
}

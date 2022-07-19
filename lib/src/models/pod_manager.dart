import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';

class PodManager {
  late Command<bool, bool> setShowSidePanelStateCommand;

  PodManager() {
    // Command expects a bool value when executed and sets it as its own value
    setShowSidePanelStateCommand = Command.createSync<bool, bool>((b) => b, false);
  }
}

void registerPodManager() {
  GetIt.I.registerSingleton<PodManager>(PodManager());
}

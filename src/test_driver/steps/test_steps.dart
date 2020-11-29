import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

class CheckGivenWidgets extends Given2WithWorld<String,String,FlutterWorld> {
  @override
  Future<void> executeStep(String input1, String input2) async {
    final textInput = find.byValueKey(input1);
    final button = find.byValueKey(input2);
    await FlutterDriverUtils.isPresent(world.driver, textInput);
    await FlutterDriverUtils.isPresent(world.driver, button);
  }
  @override
  RegExp get pattern => RegExp(r"I have {string} and {string}");
}

class ClickJoinSessionButton extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String joinBtn) async {
    final joinFinder = find.byValueKey(joinBtn);
    final inputField = find.byValueKey("sessionIdField");
    final speakerButton = find.byValueKey("speakerBtn");
    await FlutterDriverUtils.tap(world.driver, speakerButton);
    await FlutterDriverUtils.tap(world.driver, inputField);
    await world.driver.enterText('conferencing101');
    await FlutterDriverUtils.tap(world.driver, joinFinder);
  }
  @override
  RegExp get pattern => RegExp(r"I tap the {string}");
}

class CheckSessionPage extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String sessionPage) async {
    final page = find.byValueKey(sessionPage);
    await FlutterDriverUtils.isPresent(world.driver, page);
  }
  @override
  RegExp get pattern => RegExp(r"I should have {string} on screen");
}

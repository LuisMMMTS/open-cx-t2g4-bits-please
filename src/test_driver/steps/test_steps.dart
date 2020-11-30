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

class WriteQuestion extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String question) async {
    // Set up
    final joinFinder = find.byValueKey("joinBtnAttendee");
    final inputField = find.byValueKey("sessionIdFieldAttendee");
    final attendeeButton = find.byValueKey("attendeeBtn");
    await FlutterDriverUtils.tap(world.driver, attendeeButton);
    await FlutterDriverUtils.tap(world.driver, inputField);
    await world.driver.enterText('conferencing101');
    await FlutterDriverUtils.tap(world.driver, joinFinder);

    // Write Question
    final questionField = find.byValueKey("questionField");
    await FlutterDriverUtils.tap(world.driver, questionField);
    await world.driver.enterText(question);
  }
  @override
  RegExp get pattern => RegExp(r"When I write the question {string}");
}

class ClickSubmitButton extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String submitBtn) async {
    final submitButton = find.byValueKey(submitBtn);
    await FlutterDriverUtils.tap(world.driver, submitButton);
  }
  @override
  RegExp get pattern => RegExp(r"And I press the {string}");
}

class CheckQuestion extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String question) async {
    await world.driver.waitFor(find.text(question));
  }
  @override
  RegExp get pattern => RegExp(r"Then The server must put my question {string} on the queue");
}


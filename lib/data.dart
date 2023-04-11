import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'data.g.dart';

@collection
class TaskEntity {
  Id id = Isar.autoIncrement;
  String name = '';
  bool isCompletd = false;
  
  @enumerated
  Prority prority = Prority.medium;
}

enum Prority { low, medium, high }

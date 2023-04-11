import 'package:flutter_database/data.dart';
import 'package:isar/isar.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> saveTask(TaskEntity task) async {
    Isar isar = await db;
    TaskEntity? task0 =
        await isar.taskEntitys.filter().nameEqualTo(task.name).findFirst();

    if (task0 == null) {
      await isar.writeTxn(() => isar.taskEntitys.put(task));
    } else {
      task0
        ..name = task.name
        ..isCompletd = task.isCompletd
        ..prority = task.prority
        ..id = task0.id;

      await isar.writeTxn(() => isar.taskEntitys.put(task0));
    }
  }

  Future<void> deleteAllTasks() async {
    final isar = await db;

    await isar.writeTxn(() async {
      isar.taskEntitys.clear();
    });
  }

  Future<void> changeCompletd(int id) async {
    final Isar isar = await db;
    final TaskEntity? task = await isar.taskEntitys.get(id);

    task!.isCompletd = !task.isCompletd;
    await isar.writeTxn(() async {
      await isar.taskEntitys.put(task);
    });
  }

  Future<void> deleteTask(int id) async {
    final Isar isar = await db;

    await isar.writeTxn(() async {
      await isar.taskEntitys.delete(id);
    });
  }

  Future<void> editTask(int id, TaskEntity task) async {
    final Isar isar = await db;
    task.id = id;
    await isar.writeTxn(() async {
      await isar.taskEntitys.put(task);
    });
  }

  Stream<List<TaskEntity>> getAllTask({String? search}) async* {
    final Isar isar = await db;
    final query = isar.taskEntitys
        .where()
        .filter()
        .nameContains(search ?? '', caseSensitive: true);

    yield* query.watch(fireImmediately: true);
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([TaskEntitySchema], inspector: true);
    }
    return Future.value(Isar.getInstance());
  }
}

import 'package:objectbox/objectbox.dart';

@Entity()
class GlobalVariable {
  @Id()
  int id = 0;

  @Unique()
  late String name;

  late double value;

  GlobalVariable({
    this.id = 0,
    required this.name,
    required this.value,
  });
}
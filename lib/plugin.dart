



import 'package:flutter_riverpod/flutter_riverpod.dart';


final greetingProvider = StateProvider<String>((ref) => 'hello world');

////////Provider=======
final helloprov = Provider<String>((ref) {
  return 'hello world';
});

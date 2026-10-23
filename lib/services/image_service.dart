import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final picker = ImagePicker();
  static Future<String?> pickPrescriptionImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 88, maxWidth: 1800);
    if (file == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'prescriptions'));
    if (!folder.existsSync()) folder.createSync(recursive: true);
    final target = p.join(folder.path, 'prescription_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}');
    await File(file.path).copy(target);
    return target;
  }
}

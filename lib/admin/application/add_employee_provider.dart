import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

final addEmployeeFormProvider = Provider.autoDispose<FormGroup>((ref) {
  return fb.group({
    'name': FormControl<String>(validators: [Validators.required]),
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
    'city': FormControl<String>(validators: [Validators.required]),
  });
});

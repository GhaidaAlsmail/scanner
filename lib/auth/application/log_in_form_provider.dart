import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

final logInFormProvider = Provider.autoDispose((ref) {
  return FormGroup({
    "username": FormControl<String>(validators: [Validators.required]),
    "password": FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
  });
});

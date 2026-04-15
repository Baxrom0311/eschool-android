import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/forms_api.dart';
import '../../data/models/form_model.dart';
import 'auth_provider.dart';

final formsApiProvider = Provider<FormsApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FormsApi(dioClient);
});

// ─── Forms List ───

class FormsListState {
  final bool isLoading;
  final String? error;
  final List<DynamicFormModel> forms;

  const FormsListState({this.isLoading = false, this.error, this.forms = const []});
}

class FormsListNotifier extends StateNotifier<FormsListState> {
  final FormsApi _api;

  FormsListNotifier(this._api) : super(const FormsListState());

  Future<void> loadForms() async {
    state = const FormsListState(isLoading: true);
    try {
      final forms = await _api.getForms();
      state = FormsListState(forms: forms);
    } catch (e) {
      state = FormsListState(error: e.toString());
    }
  }
}

final formsListProvider =
    StateNotifierProvider.autoDispose<FormsListNotifier, FormsListState>(
  (ref) {
    final api = ref.watch(formsApiProvider);
    return FormsListNotifier(api);
  },
);

// ─── Form Detail + Submit ───

class FormDetailState {
  final bool isLoading;
  final String? error;
  final FormDetailModel? form;
  final bool isSubmitting;
  final bool submitted;

  const FormDetailState({
    this.isLoading = false,
    this.error,
    this.form,
    this.isSubmitting = false,
    this.submitted = false,
  });
}

class FormDetailNotifier extends StateNotifier<FormDetailState> {
  final FormsApi _api;

  FormDetailNotifier(this._api) : super(const FormDetailState());

  Future<void> loadForm(int formId) async {
    state = const FormDetailState(isLoading: true);
    try {
      final form = await _api.getFormDetail(formId);
      state = FormDetailState(form: form);
    } catch (e) {
      state = FormDetailState(error: e.toString());
    }
  }

  Future<bool> submitForm(int formId, List<String> answers) async {
    state = FormDetailState(form: state.form, isSubmitting: true);
    try {
      await _api.submitForm(formId, answers);
      state = FormDetailState(form: state.form, submitted: true);
      return true;
    } catch (e) {
      state = FormDetailState(form: state.form, error: e.toString());
      return false;
    }
  }
}

final formDetailProvider =
    StateNotifierProvider.autoDispose<FormDetailNotifier, FormDetailState>(
  (ref) {
    final api = ref.watch(formsApiProvider);
    return FormDetailNotifier(api);
  },
);

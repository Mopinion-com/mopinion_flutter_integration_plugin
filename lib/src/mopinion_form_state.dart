extension MopinionFormStateExtension on String {
  MopinionFormState toMopinionFormState() => switch (this) {
        "Loading" => MopinionFormState.loading,
        "NotLoading" => MopinionFormState.notLoading,
        "FormOpened" => MopinionFormState.formOpened,
        "FormSent" => MopinionFormState.formSent,
        "FormCanceled" => MopinionFormState.formCanceled,
        "FormClosed" => MopinionFormState.formClosed,
        "Error" => MopinionFormState.error,
        "HasNotBeenShown" => MopinionFormState.hasNotBeenShown,
        _ => MopinionFormState.unknown,
      };
}

enum MopinionFormState {
  loading,
  notLoading,
  formOpened,
  formSent,
  formCanceled,
  formClosed,
  error,
  hasNotBeenShown,
  unknown,
}

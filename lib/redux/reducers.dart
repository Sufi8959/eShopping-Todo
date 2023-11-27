import 'package:shopping_list_app/models/appstate.dart';
import 'package:shopping_list_app/redux/actions.dart';

Appstate reducerTheme(Appstate state, dynamic action) {
  if (action is ToggleThemeAction) {
    return Appstate(
        theme: state.theme == AppTheme.light ? AppTheme.dark : AppTheme.light);
  }
  return state;
}

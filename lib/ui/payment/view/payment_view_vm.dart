import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoiceninja_flutter/redux/client/client_actions.dart';
import 'package:invoiceninja_flutter/redux/invoice/invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/payment/payment_selectors.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/redux/payment/payment_actions.dart';
import 'package:invoiceninja_flutter/data/models/payment_model.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/ui/payment/view/payment_view.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';

class PaymentViewScreen extends StatelessWidget {
  static const String route = '/payment/view';

  const PaymentViewScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PaymentViewVM>(
      converter: (Store<AppState> store) {
        return PaymentViewVM.fromStore(store);
      },
      builder: (context, vm) {
        return PaymentView(
          viewModel: vm,
        );
      },
    );
  }
}

class PaymentViewVM {
  final PaymentEntity payment;
  final CompanyEntity company;
  final Function(BuildContext, EntityAction) onActionSelected;
  final Function(BuildContext) onEditPressed;
  final Function(BuildContext) onTapInvoice;
  final Function(BuildContext) onTapClient;
  final bool isSaving;
  final bool isLoading;
  final bool isDirty;

  PaymentViewVM({
    @required this.payment,
    @required this.company,
    @required this.onActionSelected,
    @required this.onEditPressed,
    @required this.onTapClient,
    @required this.onTapInvoice,
    @required this.isSaving,
    @required this.isLoading,
    @required this.isDirty,
  });

  factory PaymentViewVM.fromStore(Store<AppState> store) {
    final state = store.state;
    final payment = state.paymentState.map[state.paymentUIState.selectedId];
    final client = paymentClientSelector(payment.id, state);

    return PaymentViewVM(
        company: state.selectedCompany,
        isSaving: state.isSaving,
        isDirty: payment.isNew,
        isLoading: state.isLoading,
        payment: payment,
        onEditPressed: (BuildContext context) {
          store.dispatch(EditPayment(payment: payment, context: context));
        },
        onTapClient: (context) =>
            store.dispatch(ViewClient(clientId: client.id, context: context)),
        onTapInvoice: (context) => store.dispatch(
            ViewInvoice(invoiceId: payment.invoiceId, context: context)),
        onActionSelected: (BuildContext context, EntityAction action) {
          final localization = AppLocalization.of(context);
          switch (action) {
            case EntityAction.email:
              store.dispatch(EmailPaymentRequest(
                  popCompleter(
                      context, localization.emailedPayment),
                  payment));
              break;
            case EntityAction.archive:
              store.dispatch(ArchivePaymentRequest(
                  popCompleter(context, localization.archivedClient),
                  payment.id));
              break;
            case EntityAction.delete:
              store.dispatch(DeletePaymentRequest(
                  popCompleter(context, localization.deletedClient),
                  payment.id));
              break;
            case EntityAction.restore:
              store.dispatch(RestorePaymentRequest(
                  snackBarCompleter(context, localization.restoredClient),
                  payment.id));
              break;
          }
        });
  }
}

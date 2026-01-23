import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';
import 'quick_invoice_clients.dart';

class QuickInvoiceSelectClientPage extends StatefulWidget {
  final Function(Client?)? onClientSelected;

  const QuickInvoiceSelectClientPage({super.key, this.onClientSelected});

  @override
  State<QuickInvoiceSelectClientPage> createState() => _QuickInvoiceSelectClientPageState();
}

class _QuickInvoiceSelectClientPageState extends State<QuickInvoiceSelectClientPage> {
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await AppDatabase.instance.getAllClients();
    setState(() => _clients = clients);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Select Client'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .push(CupertinoPageRoute(builder: (_) => const QuickInvoiceAddClientPage()))
                .then((_) => _loadClients());
          },
          child: Icon(CupertinoIcons.plus_circle_fill, color: ColorStyles.primary, size: 28.r),
        ),
      ),
      child: SafeArea(
        child: _clients.isEmpty
            ? Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      color: ColorStyles.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.person_2_fill, size: 60.r, color: ColorStyles.primary),
                  ),
                  SizedBox(height: 24.r),
                  Text('No clients yet', style: TextStyles.title3Emphasized),
                  SizedBox(height: 8.r),
                  Text('Add your first client', style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
                  SizedBox(height: 32.r),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(CupertinoPageRoute(builder: (_) => const QuickInvoiceAddClientPage()))
                          .then((_) => _loadClients());
                    },
                    child: Container(
                      width: 200.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: ColorStyles.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text('Add Client', style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white)),
                      ),
                    ),
                  ),
                ],
              ),
            )
            : ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.r),
                    decoration: BoxDecoration(
                      color: ColorStyles.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.all(16.r),
                      onPressed: () {
                        widget.onClientSelected?.call(client);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(color: ColorStyles.primary, shape: BoxShape.circle),
                            child: ClipOval(
                              child: client.image != null
                                  ? Image.memory(client.image!, width: 40.r, height: 40.r, fit: BoxFit.cover)
                                  : Center(
                                      child: Text(
                                        client.name.isNotEmpty ? client.name.substring(0, 1).toUpperCase() : 'C',
                                        style: TextStyles.footnoteEmphasized.copyWith(color: ColorStyles.white),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: 12.r),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(client.name, style: TextStyles.bodyEmphasized, maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (client.phoneNumber.isNotEmpty) ...[
                                  SizedBox(height: 4.r),
                                  Text(
                                    client.phoneNumber,
                                    style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(CupertinoIcons.chevron_right, color: ColorStyles.secondary, size: 18.r),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

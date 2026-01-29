import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/database.dart';
import '../../../../style/quick_invoice_style.dart';
import '../../../services/premium_limits.dart';
import '../../premium/quick_invoice_main_paywall.page.dart';

class QuickInvoiceClientsTab extends StatefulWidget {
  const QuickInvoiceClientsTab({super.key});

  @override
  State<QuickInvoiceClientsTab> createState() => _QuickInvoiceClientsTabState();
}

class _QuickInvoiceClientsTabState extends State<QuickInvoiceClientsTab> {
  List<Client> _clients = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await AppDatabase.instance.getAllClients();
    if (mounted) setState(() => _clients = clients);
  }

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    return _clients
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.email.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _showClientInfo(Client client) {
    showCupertinoSheet(
      context: context,
      builder: (_) => _ClientInfoPage(client: client, onChanged: _loadClients),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      child: Column(
        children: [
          Container(
            color: QuickInvoiceColorStyles.white,
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.r),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Clients', style: QuickInvoiceTextStyles.largeTitleEmphasized),
                    if (_clients.isNotEmpty)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context, rootNavigator: true)
                              .push(
                                CupertinoPageRoute(
                                  builder: (_) => const QuickInvoiceAddClientPage(),
                                ),
                              )
                              .then((_) => _loadClients());
                        },
                        child: Icon(
                          CupertinoIcons.plus_circle_fill,
                          color: QuickInvoiceColorStyles.primary,
                          size: 28.r,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.r),
                CupertinoSearchTextField(
                  placeholder: 'Search clients...',
                  style: QuickInvoiceTextStyles.bodyRegular,
                  placeholderStyle: QuickInvoiceTextStyles.bodyRegular.copyWith(
                    color: QuickInvoiceColorStyles.labelsTertiary,
                  ),
                  backgroundColor: QuickInvoiceColorStyles.fillsTertiary,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _filteredClients.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120.r,
                            height: 120.r,
                            decoration: BoxDecoration(
                              color: QuickInvoiceColorStyles.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.person_2_fill,
                              size: 60.r,
                              color: QuickInvoiceColorStyles.primary,
                            ),
                          ),
                          SizedBox(height: 24.r),
                          Text('No clients yet', style: QuickInvoiceTextStyles.title3Emphasized),
                          SizedBox(height: 8.r),
                          Text(
                            'Add your first client',
                            style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                              color: QuickInvoiceColorStyles.secondary,
                            ),
                          ),
                          SizedBox(height: 20.r),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context, rootNavigator: true)
                                  .push(
                                    CupertinoPageRoute(
                                      builder: (_) => const QuickInvoiceAddClientPage(),
                                    ),
                                  )
                                  .then((_) => _loadClients());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 12.r),
                              decoration: BoxDecoration(
                                color: QuickInvoiceColorStyles.primary,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Add Client',
                                style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: _filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = _filteredClients[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.r),
                          decoration: BoxDecoration(
                            color: QuickInvoiceColorStyles.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.all(16.r),
                            onPressed: () => _showClientInfo(client),
                            child: Row(
                              children: [
                                _ClientAvatar(imageData: client.image, name: client.name, size: 40),
                                SizedBox(width: 12.r),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: QuickInvoiceTextStyles.bodyEmphasized,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (client.phoneNumber.isNotEmpty)
                                        Text(
                                          client.phoneNumber,
                                          style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                                            color: QuickInvoiceColorStyles.secondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  color: QuickInvoiceColorStyles.secondary,
                                  size: 16.r,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  final Uint8List? imageData;
  final String name;
  final double size;

  const _ClientAvatar({required this.imageData, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(color: QuickInvoiceColorStyles.primary, shape: BoxShape.circle),
      child: ClipOval(
        child:
            imageData != null
                ? Image.memory(imageData!, width: size.r, height: size.r, fit: BoxFit.cover)
                : Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: QuickInvoiceTextStyles.footnoteEmphasized.copyWith(color: QuickInvoiceColorStyles.white),
                  ),
                ),
      ),
    );
  }
}

class QuickInvoiceAddClientPage extends StatefulWidget {
  const QuickInvoiceAddClientPage({super.key});

  @override
  State<QuickInvoiceAddClientPage> createState() => _QuickInvoiceAddClientPageState();
}

class _QuickInvoiceAddClientPageState extends State<QuickInvoiceAddClientPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  Uint8List? _imageData;
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder:
          (_) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: Text('Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: Text('Gallery'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageData = bytes);
    }
  }

  Future<void> _saveClient() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }

    if (!await PremiumLimits.canAddClient()) {
      if (mounted) {
        Navigator.pop(context);
        QuickInvoiceMainPaywallPage.show(context);
      }
      return;
    }

    final client = ClientsCompanion(
      id: Value(const Uuid().v4()),
      name: Value(name),
      email: Value(_emailController.text.trim()),
      phoneNumber: Value(_phoneController.text.trim()),
      address: Value(_addressController.text.trim()),
      image: Value(_imageData),
    );

    await AppDatabase.instance.insertClient(client);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: QuickInvoiceTextStyles.bodyRegular.copyWith(color: QuickInvoiceColorStyles.primary)),
        ),
        middle: Text('New Client'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            _saveClient();
          },
          child: Text(
            'Save',
            style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.primary),
          ),
        ),
        backgroundColor: QuickInvoiceColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: QuickInvoiceColorStyles.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child:
                        _imageData != null
                            ? Image.memory(
                              _imageData!,
                              width: 80.r,
                              height: 80.r,
                              fit: BoxFit.cover,
                            )
                            : Icon(
                              CupertinoIcons.camera_fill,
                              color: QuickInvoiceColorStyles.primary,
                              size: 32.r,
                            ),
                  ),
                ),
              ),
              SizedBox(height: 24.r),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildTextField('Name', 'Client name', _nameController, hasError: _nameError),
                    SizedBox(height: 16.r),
                    _buildTextField('Email', 'client@email.com', _emailController),
                    SizedBox(height: 16.r),
                    _buildTextField('Phone', '+1 234 567 890', _phoneController),
                    SizedBox(height: 16.r),
                    _buildTextField('Address', 'Client address', _addressController),
                  ],
                ),
              ),
              SizedBox(height: 24.r),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _saveClient();
                },
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: QuickInvoiceColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Save Client',
                      style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller, {
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
            color: hasError ? QuickInvoiceColorStyles.pink : QuickInvoiceColorStyles.secondary,
          ),
        ),
        SizedBox(height: 8.r),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: EdgeInsets.all(12.r),
          onChanged: (_) {
            if (hasError) setState(() => _nameError = false);
          },
          decoration: BoxDecoration(
            color: QuickInvoiceColorStyles.fillsTertiary,
            borderRadius: BorderRadius.circular(8.r),
            border: hasError ? Border.all(color: QuickInvoiceColorStyles.pink) : null,
          ),
        ),
      ],
    );
  }
}

class _ClientInfoPage extends StatefulWidget {
  final Client client;
  final VoidCallback onChanged;

  const _ClientInfoPage({required this.client, required this.onChanged});

  @override
  State<_ClientInfoPage> createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<_ClientInfoPage> {
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final invoices = await AppDatabase.instance.getInvoicesByClientId(widget.client.id);
    if (mounted) setState(() => _invoices = invoices);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: QuickInvoiceColorStyles.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Client'),
        backgroundColor: QuickInvoiceColorStyles.white,
        transitionBetweenRoutes: false,
        automaticBackgroundVisibility: false,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.xmark, size: 20.r, color: QuickInvoiceColorStyles.secondary),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              SizedBox(height: 16.r),
              _ClientAvatar(imageData: widget.client.image, name: widget.client.name, size: 80),
              SizedBox(height: 16.r),
              Text(
                widget.client.name,
                style: QuickInvoiceTextStyles.title3Emphasized,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.r),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: QuickInvoiceColorStyles.bgSecondary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    if (widget.client.email.isNotEmpty) ...[
                      _infoRow('Email', widget.client.email),
                      Divider(color: QuickInvoiceColorStyles.separator, height: 24.r),
                    ],
                    if (widget.client.phoneNumber.isNotEmpty) ...[
                      _infoRow('Phone', widget.client.phoneNumber),
                      if (widget.client.address.isNotEmpty)
                        Divider(color: QuickInvoiceColorStyles.separator, height: 24.r),
                    ],
                    if (widget.client.address.isNotEmpty)
                      _infoRow('Address', widget.client.address),
                  ],
                ),
              ),
              if (_invoices.isNotEmpty) ...[
                SizedBox(height: 24.r),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Invoices', style: QuickInvoiceTextStyles.bodyEmphasized),
                ),
                SizedBox(height: 12.r),
                ..._invoices.map(
                  (invoice) => Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 8.r),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: QuickInvoiceColorStyles.bgSecondary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${invoice.invoiceNumber}',
                                style: QuickInvoiceTextStyles.bodyEmphasized,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.r),
                              Text(
                                invoice.status[0].toUpperCase() + invoice.status.substring(1),
                                style: QuickInvoiceTextStyles.footnoteRegular.copyWith(
                                  color: QuickInvoiceColorStyles.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: QuickInvoiceTextStyles.bodyEmphasized,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.r),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final confirm = await showCupertinoDialog<bool>(
                    context: context,
                    builder:
                        (_) => CupertinoAlertDialog(
                          title: Text('Delete Client'),
                          content: Text('Are you sure you want to delete this client?'),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: Text('Delete'),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    await AppDatabase.instance.deleteClient(widget.client.id);
                    widget.onChanged();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: QuickInvoiceColorStyles.pink,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Delete Client',
                      style: QuickInvoiceTextStyles.bodyEmphasized.copyWith(color: QuickInvoiceColorStyles.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: QuickInvoiceTextStyles.bodyRegular.copyWith(color: QuickInvoiceColorStyles.secondary)),
        SizedBox(width: 16.r),
        Expanded(
          child: Text(
            value,
            style: QuickInvoiceTextStyles.bodyRegular,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

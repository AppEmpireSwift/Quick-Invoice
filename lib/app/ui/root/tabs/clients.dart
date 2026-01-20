import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/database.dart';
import '../../../../style/style.dart';

class ClientsTab extends StatefulWidget {
  const ClientsTab({super.key});

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  List<Client> _clients = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await AppDatabase.instance.getAllClients();
    setState(() => _clients = clients);
  }

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    return _clients.where((c) => 
      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      child: Column(
        children: [
          Container(
            color: ColorStyles.white,
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.r),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Clients', style: TextStyles.largeTitleEmphasized),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context, rootNavigator: true)
                            .push(CupertinoPageRoute(builder: (_) => const AddClientPage()))
                            .then((_) => _loadClients());
                      },
                      child: Icon(CupertinoIcons.plus_circle_fill, color: ColorStyles.primary, size: 28.r),
                    ),
                  ],
                ),
                SizedBox(height: 16.r),
                CupertinoSearchTextField(
                  placeholder: 'Search clients...',
                  style: TextStyles.bodyRegular,
                  placeholderStyle: TextStyles.bodyRegular.copyWith(color: ColorStyles.labelsTertiary),
                  backgroundColor: ColorStyles.fillsTertiary,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredClients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          color: ColorStyles.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.all(16.r),
                          onPressed: () {},
                          child: Row(
                            children: [
                              Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(color: ColorStyles.primary, shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                                    style: TextStyles.footnoteEmphasized.copyWith(color: ColorStyles.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.r),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(client.name, style: TextStyles.bodyEmphasized),
                                    if (client.phoneNumber.isNotEmpty)
                                      Text(client.phoneNumber, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
                                  ],
                                ),
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

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (_nameController.text.isEmpty) return;
    
    final client = ClientsCompanion(
      id: Value(const Uuid().v4()),
      name: Value(_nameController.text),
      email: Value(_emailController.text),
      phoneNumber: Value(_phoneController.text),
      address: Value(_addressController.text),
    );
    
    await AppDatabase.instance.insertClient(client);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ColorStyles.bgSecondary,
      navigationBar: CupertinoNavigationBar(
        middle: Text('New Client'),
        backgroundColor: ColorStyles.white,
        automaticBackgroundVisibility: false,
        transitionBetweenRoutes: false,
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: ColorStyles.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildTextField('Name', 'Client name', _nameController),
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
                    color: ColorStyles.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text('Save Client', style: TextStyles.bodyEmphasized.copyWith(color: ColorStyles.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.footnoteRegular.copyWith(color: ColorStyles.secondary)),
        SizedBox(height: 8.r),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: ColorStyles.fillsTertiary,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }
}

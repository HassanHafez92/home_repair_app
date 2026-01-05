import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_event.dart';
import '../../blocs/service/service_state.dart';
import 'package:home_repair_app/services/firestore_service.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/design_tokens.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(const ServiceLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutral100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context),
        backgroundColor: DesignTokens.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state.status == ServiceStatus.loading && state.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ServiceStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: DesignTokens.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${state.errorMessage}'),
                ],
              ),
            );
          }

          final services = state.services;

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      size: 40,
                      color: DesignTokens.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services found',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeMD,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                      color: DesignTokens.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a service to get started',
                    style: TextStyle(color: DesignTokens.neutral500),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceCard(
                service: service,
                onEdit: () => _showEditServiceDialog(context, service),
                onDelete: () => _deleteService(context, service.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    _showServiceDialog(context, null);
  }

  void _showEditServiceDialog(BuildContext context, ServiceEntity service) {
    _showServiceDialog(context, service);
  }

  void _showServiceDialog(BuildContext context, ServiceEntity? service) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name);
    final descController = TextEditingController(text: service?.description);
    final priceController = TextEditingController(
      text: service?.avgPrice.toString(),
    );
    final categoryController = TextEditingController(text: service?.category);
    final iconUrlController = TextEditingController(
      text: service?.iconUrl ?? 'https://via.placeholder.com/150',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                isEditing ? Icons.edit : Icons.add_circle_outline,
                color: DesignTokens.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isEditing ? 'Edit Service' : 'Add New Service',
              style: TextStyle(fontWeight: DesignTokens.fontWeightBold),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Service Name',
                  hint: 'e.g. AC Repair',
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  hint: 'Service description...',
                  controller: descController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Base Price (EGP)',
                  hint: '0.0',
                  controller: priceController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Category',
                  hint: 'e.g. Cooling',
                  controller: categoryController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Icon URL',
                  hint: 'https://...',
                  controller: iconUrlController,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: DesignTokens.neutral600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Name and Price are required'),
                    backgroundColor: DesignTokens.error,
                  ),
                );
                return;
              }

              final price = double.tryParse(priceController.text) ?? 0.0;
              final firestoreService = context.read<FirestoreService>();

              final newService = ServiceEntity(
                id: isEditing ? service.id : firestoreService.generateId(),
                name: nameController.text,
                description: descController.text,
                category: categoryController.text,
                avgPrice: price,
                minPrice: price * 0.8,
                maxPrice: price * 1.2,
                visitFee: 50.0,
                avgCompletionTimeMinutes: 60,
                iconUrl: iconUrlController.text,
                isActive: true,
                createdAt: isEditing ? service.createdAt : DateTime.now(),
              );

              if (isEditing) {
                context.read<ServiceBloc>().add(
                  ServiceUpdateRequested(newService),
                );
              } else {
                context.read<ServiceBloc>().add(
                  ServiceAddRequested(newService),
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing ? 'Service updated' : 'Service created',
                  ),
                  backgroundColor: DesignTokens.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
            ),
            child: Text(isEditing ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(BuildContext context, String serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiceBloc>().add(ServiceDeleteRequested(serviceId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Service deleted')));
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: DesignTokens.shadowSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(color: DesignTokens.neutral200),
            child: Image.network(
              service.iconUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image,
                    color: DesignTokens.neutral400,
                    size: 32,
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: TextStyle(
                            fontWeight: DesignTokens.fontWeightBold,
                            fontSize: DesignTokens.fontSizeSM,
                            color: DesignTokens.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: service.isActive
                              ? DesignTokens.accentGreen.withValues(alpha: 0.1)
                              : DesignTokens.neutral200,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                        ),
                        child: Text(
                          service.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: service.isActive
                                ? DesignTokens.accentGreen
                                : DesignTokens.neutral500,
                            fontWeight: DesignTokens.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.avgPrice.toInt()} EGP',
                    style: TextStyle(
                      color: DesignTokens.primaryBlue,
                      fontWeight: DesignTokens.fontWeightBold,
                      fontSize: DesignTokens.fontSizeSM,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSizeXS,
                        color: DesignTokens.neutral500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceSM,
              vertical: DesignTokens.spaceXS,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: DesignTokens.neutral200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: DesignTokens.primaryBlue,
                    size: 20,
                  ),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: DesignTokens.error,
                    size: 20,
                  ),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

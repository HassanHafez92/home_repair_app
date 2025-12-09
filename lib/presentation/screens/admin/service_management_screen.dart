import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/service/service_bloc.dart';
import '../../blocs/service/service_event.dart';
import '../../blocs/service/service_state.dart';
import 'package:home_repair_app/services/firestore_service.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../../widgets/custom_text_field.dart';

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context),
        label: const Text('Add Service'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state.status == ServiceStatus.loading && state.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ServiceStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          final services = state.services;

          if (services.isEmpty) {
            return const Center(child: Text('No services found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Image.network(
                        service.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service.avgPrice.toInt()} EGP',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditServiceDialog(context, service);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteService(context, service.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
        title: Text(isEditing ? 'Edit Service' : 'Add New Service'),
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
                  label: 'Base Price',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Price are required')),
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
                    isEditing
                        ? 'Service update requested'
                        : 'Service creation requested',
                  ),
                ),
              );
            },
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
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiceBloc>().add(ServiceDeleteRequested(serviceId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deletion requested')),
      );
    }
  }
}

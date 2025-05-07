// lib/pages/employee_list_page.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kothayhisab/data/models/employee_model.dart';
import 'package:kothayhisab/data/api/services/employee_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/toast_notification.dart';

class EmployeeListPage extends StatefulWidget {
  final String shopId;

  const EmployeeListPage({Key? key, required this.shopId}) : super(key: key);

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  bool isLoading = true;
  List<Employee> employees = [];

  // Role translation map
  final Map<String, String> _roleTranslations = {
    'employee': 'কর্মচারী',
    'owner': 'মালিক',
  };

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    // Check if widget is still mounted before setting state
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await EmployeeService.getEmployees(widget.shopId);

      // Check if widget is still mounted before setting state
      if (!mounted) return;

      setState(() {
        isLoading = false;
        if (result['success']) {
          employees = result['data'];
          // Sort employees so that owners appear first
          _sortEmployees();
        } else {
          ToastNotification.error('${result['message']}');
        }
      });
    } catch (e) {
      // Check if widget is still mounted before setting state
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      ToastNotification.error('Error: $e');
    }
  }

  // Sort employees by role, with owners first
  void _sortEmployees() {
    employees.sort((a, b) {
      // Give priority to "owner" role
      if (a.shopMemberRole.toLowerCase() == 'owner' &&
          b.shopMemberRole.toLowerCase() != 'owner') {
        return -1;
      } else if (a.shopMemberRole.toLowerCase() != 'owner' &&
          b.shopMemberRole.toLowerCase() == 'owner') {
        return 1;
      }
      // If both are owners or both are not owners, sort by name
      return a.name.compareTo(b.name);
    });
  }

  // Get the Bengali translation for a role
  String _getTranslatedRole(String role) {
    final lowerRole = role.toLowerCase();
    return _roleTranslations[lowerRole] ?? role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('কর্মচারী'), // "Employee" in Bengali
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/shop-details/add-employees',
                  arguments: {'shopId': widget.shopId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 115, 173),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'কর্মচারী যোগ করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : employees.isEmpty
                    ? const Center(
                      child: Text(
                        'কোনো কর্মচারী পাওয়া যায়নি',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        final isOwner =
                            employee.shopMemberRole.toLowerCase() == 'owner';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF005596),
                              child: Text(
                                employee.name.isNotEmpty
                                    ? employee.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              employee.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(employee.mobileNumber),
                                Text(
                                  // Display translated role instead of English
                                  _getTranslatedRole(employee.shopMemberRole),
                                  style: TextStyle(
                                    color: _getRoleColor(
                                      employee.shopMemberRole,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            // Only show delete icon if the employee is not an owner
                            trailing:
                                isOwner
                                    ? null
                                    : InkWell(
                                      onTap: () {
                                        // _confirmDeleteEmployee(employee);
                                        _deleteEmployee(
                                          employee.userId.toString(),
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'employee':
        return Colors.green;
      case 'owner':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 1. First, update the _confirmDeleteEmployee method to add more safety
  void _confirmDeleteEmployee(Employee employee) {
    print("Showing confirmation dialog for employee ID: ${employee.userId}");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('অপসারণ নিশ্চিত করুন'),
          content: Text(
            'আপনি কি নিশ্চিত যে আপনি ${employee.name} কে অপসারণ করতে চান?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('hello world');
                Navigator.of(dialogContext).pop();
              },
              child: const Text('বাতিল'),
            ),
            TextButton(
              onPressed: () {
                print(
                  "Delete button clicked in dialog for employee ID: ${employee.userId}",
                );
                // Close the dialog first

                // Ensure we're passing a string for the employee ID
                final employeeIdStr = employee.userId.toString();
                print(
                  "Preparing to delete employee with ID string: $employeeIdStr",
                );

                // Small delay to ensure dialog is fully dismissed
                _deleteEmployee(employeeIdStr);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('অপসারণ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 2. Now update the _deleteEmployee method with safer error handling
  Future<void> _deleteEmployee(String employeeId) async {
    print("Starting _deleteEmployee for ID: $employeeId");

    // Validate employeeId is not empty
    if (employeeId.trim().isEmpty) {
      print("Error: Employee ID is empty");
      ToastNotification.error('Invalid employee ID');
      return;
    }

    try {
      // Update UI to show loading
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      } else {
        print("Widget not mounted during setState in _deleteEmployee");
        return;
      }

      print(
        'Attempting to delete employee with ID: $employeeId from shop: ${widget.shopId}',
      );

      // Call the service
      final result = await EmployeeService.deleteEmployee(
        widget.shopId,
        employeeId,
      );

      print('Delete employee result: $result');

      // Update UI after getting the result
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (result['success'] == true) {
          ToastNotification.success('কর্মচারীকে সফলভাবে বাতিল করা হয়েছে!');
          // Refresh the employee list
          await fetchEmployees();
        } else {
          ToastNotification.error(
            result['message'] ?? 'Failed to remove employee',
          );
        }
      } else {
        print("Widget not mounted after delete operation");
      }
    } catch (e) {
      print('Exception during delete: $e');
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ToastNotification.error('Error: $e');
      }
    }
  }
}

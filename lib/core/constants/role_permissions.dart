enum UserRole { admin, manager, salesperson }

class RolePermissions {
  static const Map<String, List<String>> permissions = {
    'admin': [
      'manage_users',
      'generate_reports',
      'create_lead',
      'assign_lead',
      'add_customer',
      'edit_customer',
      'search',
      'track_pipeline',
      'create_task',
      'create_meeting',
      'view_calendar',
      'view_dashboard',
      'login',
    ],
    'manager': [
      'generate_reports',
      'create_lead',
      'assign_lead',
      'add_customer',
      'edit_customer',
      'search',
      'track_pipeline',
      'create_task',
      'create_meeting',
      'view_calendar',
      'view_dashboard',
      'login',
    ],
    'salesperson': [
      'add_customer',
      'edit_customer',
      'search',
      'track_pipeline',
      'create_task',
      'create_meeting',
      'view_calendar',
      'view_dashboard',
      'login',
    ],
  };

  static bool hasPermission(String role, String permission) {
    return permissions[role]?.contains(permission) ?? false;
  }

  static List<String> getRolePermissions(String role) {
    return permissions[role] ?? [];
  }

  static String getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'salesperson':
        return 'Sales Person';
      default:
        return role;
    }
  }

  // User Creation Permissions
  static List<String> getCreatableRoles(String creatorRole) {
    switch (creatorRole) {
      case 'admin':
        return ['admin', 'manager', 'salesperson'];
      case 'manager':
        return ['salesperson'];
      default:
        return [];
    }
  }

  // Check if user can create another user
  static bool canCreateUser(String creatorRole) {
    return getCreatableRoles(creatorRole).isNotEmpty;
  }

  // Check if user can edit another user
  static bool canEditUser(
    String currentUserRole,
    String currentUserId,
    String targetUserId,
    String targetUserCreatedBy,
    String targetUserReportingManager,
  ) {
    // Can always edit own profile
    if (currentUserId == targetUserId) return true;

    // Admin can edit anyone except default admin
    if (currentUserRole == 'admin') return true;

    // Manager can edit salespeople they manage (reporting_manager = current user)
    if (currentUserRole == 'manager' &&
        targetUserReportingManager == currentUserId)
      return true;

    return false;
  }

  // Check if user can delete another user
  static bool canDeleteUser(
    String currentUserRole,
    String currentUserId,
    String targetUserId,
    String targetUserEmail,
  ) {
    // Can't delete self (except through explicit self-delete for salesperson)
    if (currentUserId == targetUserId) return false;

    // Can't delete default admin
    if (targetUserEmail == 'nasim@gmail.com') return false;

    // Admin can delete anyone
    if (currentUserRole == 'admin') return true;

    return false;
  }

  // Check if a user is on another user's team (for manager-salesperson relationship)
  static bool isTeamMember(
    String currentUserRole,
    String currentUserId,
    String targetUserId,
    String? targetUserReportingManager,
  ) {
    // Only managers have team members
    if (currentUserRole != 'manager') return false;

    // Check if target user reports to current user
    return targetUserReportingManager == currentUserId;
  }

  // Get salesperson's manager
  static String? getManagerForSalesperson(String? reportingManager) {
    return reportingManager;
  }

  // Check if user can change email (default admin can't)
  static bool canChangeEmail(String email) {
    return email != 'nasim@gmail.com';
  }
}

# Sales Manager

Sales Manager is a professional CRM and sales operations application built with Flutter and Supabase. It is designed to streamline lead management, customer lifecycle tracking, proposal generation, meeting coordination, and administrative oversight through a role-based access model.

## Summary

This project delivers a modern mobile-first experience with a clean architecture and modular feature set. Key capabilities include:

- Secure authentication with role-based access control
- Lead pipeline management, stage tracking, and funnel visualization
- Customer database management with ownership and visibility rules
- Proposal creation, editing, and tracking
- Meeting scheduling and calendar integration
- Dashboard analytics and report generation
- Notification center and real-time updates
- Admin and manager user management workflows
- Offline-friendly caching and connectivity awareness

## Technology Stack

- Flutter
- Dart
- Supabase (Auth, Database, Storage)
- Provider for state management
- `sqflite` for local data persistence
- `shared_preferences` for local cache
- `connectivity_plus` for network state
- `http`, `intl`, `uuid`, `file_picker`, `fl_chart`

## Architecture

The application follows a feature-driven structure with core shared services.

- `lib/main.dart` — application entrypoint, provider composition, auth gate
- `lib/core/` — shared theme, constants, models, services
- `lib/features/` — feature modules grouped by domain

### Core Services

- `AuthService` — authentication, session handling, Supabase auth integration
- `SupabaseService` — centralized Supabase client and reusable database access
- `SyncService` — connectivity monitoring and local caching support

## Application Features

### Authentication
- Email/password login
- Password recovery workflow
- Automatic auth gating for protected views

### Role-Based Access
- `admin` — complete application and user management
- `manager` — team supervision, lead assignment, reporting
- `salesperson` — direct lead management and customer interaction

### Leads
- Create, update, and delete leads
- Track pipeline stage progress
- Role-based visibility for leads and assignments
- Automatic conversion of won opportunities

### Customers
- Add and maintain customer records
- Role-specific visibility and ownership rules
- Customer lifecycle support tied to leads

### Proposals & Meetings
- Proposal creation and editing flows
- Meeting scheduling and modification
- Integration with lead and customer workflows

### Dashboard & Reporting
- Visual lead activity charts
- Lead-stage distribution views
- Notification center and quick access actions
- Report overview screens

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.9.2`
- A configured Supabase project
- Platform-specific tooling for iOS, Android, macOS, or web

### Install Dependencies

```bash
flutter pub get
```

### Supabase Configuration

Update `lib/core/constants/app_constants.dart` with your Supabase environment values:

- `supabaseUrl`
- `supabaseKey`

Confirm the required database tables exist in Supabase:

- `users`
- `leads`
- `proposals`
- `customers`
- `meetings`
- `notifications`
- `deals`

> For production deployments, avoid committing Supabase keys to source control. Use environment variables or secure runtime configuration.

### Launch the Application

```bash
flutter run
```

Or run on a specific device:

```bash
flutter run -d ios
flutter run -d android
flutter run -d macos
flutter run -d web
```

## Repository Layout

- `lib/core/` — shared theme, constants, models, services
- `lib/features/auth/` — authentication screens and providers
- `lib/features/dashboard/` — dashboard, notifications, and analytics
- `lib/features/leads/` — leads, proposals, and meetings
- `lib/features/customers/` — customer management
- `lib/features/calendar/` — calendar screen and provider
- `lib/features/reports/` — reporting screens and provider
- `lib/features/admin/` — admin and user management interfaces

## Development Notes

- Uses `provider` and `ChangeNotifier` for application state
- Dashboard charts are implemented using `fl_chart`
- `SyncService` supports local caching and connectivity-aware behavior

## Contribution Guidelines

1. Fork the repository.
2. Create a topic branch for your changes.
3. Open a pull request describing the improvements.

## License

This repository does not include a license. Add a license file if you intend to publish or distribute this project.

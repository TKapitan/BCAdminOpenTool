# BC Admin Open Tool

The BC Admin Open Tool is a solution designed to streamline the management of Business Central environments and tenants using the Business Central Admin Center API. This tool offers a range of functionalities that allow experienced Business Central developers and consultants to efficiently manage their environments, update settings, and scheduled updates.

With the **Managed BC Administration Apps** page, users can register and manage their Business Central Administration Apps by inputting essential details like Client ID, Name, and Client Secret. The **Managed BC Tenants** page enables users to manage their tenants, including actions to create or update tenants and environments, test connections, and view environments associated with each tenant. The **Managed BC Environments** page provides detailed information about each environment, including update settings and scheduled updates, ensuring that users have all the necessary data at their fingertips.

The tool also includes the **Available Update Timezones** page, which lists all available time zones for scheduling updates, and the **Admin Center API Setup** page, where users can configure API settings and optimize the process by enabling or disabling specific endpoints.

## Why Open Source and Not Available Through AppSource

**The BC Admin Open Tool is offered as an open-source solution rather than being available through AppSource due to security and visibility concerns. As partners, we recognize the importance of maintaining full control over access tokens and ensuring that sensitive data is handled securely. By providing an open-source solution, we allow everyone to review the code before installing it in their own environments. This transparency provides high confidence that the data is secure and that your customers are safe. Open-source solutions offer the peace of mind that comes with knowing exactly how your data is being managed and that there are no hidden processes or vulnerabilities.**

## Index

- [Managed BC Administration Apps](#managed-bc-administration-apps)
  - [Client ID](#client-id)
  - [Name](#name)
  - [Client Secret](#client-secret)
- [Managed BC Tenants](#managed-bc-tenants)
  - [Create/Update Tenants & Environment](#createupdate-tenants--environment)
  - [Create/Update Environments](#createupdate-environments)
  - [Test Connection](#test-connection)
  - [Environments](#environments)
- [Managed BC Environments](#managed-bc-environments)
  - [Update Settings](#update-settings)
  - [Scheduled Updates](#scheduled-updates)
  - [Update Environments](#update-environments)
  - [Change Update Date](#change-update-date)
  - [Change Update Settings](#change-update-settings)
- [Available Update Timezones](#available-update-timezones)
  - [Get Available Timezones](#get-available-timezones)
- [Admin Center API Setup](#admin-center-api-setup)
  - [Additional Endpoints](#additional-endpoints)
  - [Disableable Endpoints](#disableable-endpoints)

# Managed BC Administration Apps

This page is designed to help you manage your Business Central Administration Apps using the Business Central Admin Center API. Here, you can input essential details like the Client ID, Name, and Client Secret for your apps.

### Client ID
The **Client ID** is a field where you enter the ID of the Entra App registered to access the Business Central Admin API. This ID can belong to either a single tenant or a multi-tenant app. The Client ID is essentially your app's unique identifier, allowing it to communicate with the Business Central Admin API.

### Name
The **Name** specifies the name of your app.

### Client Secret
The **Client Secret** is the key that allows your app to access the Business Central Admin API. Once you store this value, it can't be retrieved again, so make sure to keep a copy of it in a secure place when you first enter it. For security reasons, the Client Secret is stored in Isolated Storage (with scope **Company** that ensure that the secret can be obtained only by this app and only in the company where it's configured), ensuring that it remains protected from unauthorized access.

# Managed BC Tenants

This page allows you to manage your Business Central tenants. You can input details such as Tenant ID, Name, Group Code, and Client ID for each tenant.

### Tenant ID
The **Tenant ID** is the ID of the tenant you want to connect to. This is a unique identifier for each tenant within Microsoft stack.

### Name
The **Name** field is a custom value where you can specify the name of the tenant. This is manually entered and can be anything that helps you identify the tenant.

### Group Code
The **Group Code** field allows you to group tenants into multiple groups. Users can be configured (in user setup) to see by default only the selected group. Note that this is not a security feature; users can remove the filter if needed.

### Client ID
The **Client ID** is the ID of the existing app (created in the Managed BC Administration Apps page). This app must have access to the specified Tenant ID to ensure proper connectivity and functionality.

## Actions

### Create/Update Tenants & Environment
This is the most powerful action on the **Managed BC Tenants** page. It downloads all tenants for all registered apps and all environments for all registered tenants. If a tenant or environment does not exist, it is created; otherwise, it is updated. 

**Important Limitation**: Every app must have at least one environment registered manually for this action to be able to download all other environments.

### Create/Update Environments
This action allows you to create or update all environments for selected tenants. You can select multiple tenants, and the action will ensure that all environments for those tenants are either created or updated as needed.

### Environments
This action opens a list of environments that belong to the selected tenant. It allows you to view and manage all environments associated with the specified Tenant ID.

### Test Connection
This action verifies that the combination of Tenant ID and Client ID works correctly. It ensures that the specified Tenant ID can be accessed using the provided Client ID.

# Managed BC Environments

This page allows you to manage the environments associated with your Business Central tenants. It includes fields for the environment name, tenant name, and various other details obtained from multiple API endpoints.

### Name
The **Name** field displays the name of the environment as retrieved from the API.

### Tenant Name
The **Tenant Name** field shows the name of the associated tenant, as specified in the Managed BC Tenants page.

### Additional Fields
The additional fields on the **Managed BC Environments** page provide comprehensive information about each environment. These fields are obtained from multiple API endpoints and include details about the environment, update settings, and scheduled updates. Here are some of the key fields:

#### Environment Information
- **Type**: The type of environment (e.g., Sandbox, Production).
- **Name**: The unique name of the environment within an application family.
- **Country Code**: The country or region where the environment is deployed.
- **Tenant ID**: The ID of the Microsoft Entra tenant that owns the environment.
- **Application Version**: The version of the environment's application.
- **Status**: The current status of the environment (e.g., NotReady, Removing, Preparing, Active).
- **Location Name**: The Azure location where the environment's data is stored.
- **Platform Version**: The version of the environment's Business Central platform.
- **Ring Name**: The name of the environment's logical ring group (e.g., Prod, Preview).
- **App Insights Key**: The environment's key for Azure Application Insights.
- **Soft Deleted On**: The time at which the environment was soft deleted.
- **Hard Delete Pending On**: The time at which the environment will be permanently deleted.
- **Delete Reason**: The reason why the environment was deleted.
- **AppSource Apps Update Cadence**: The cadence at which installed AppSource Apps are automatically updated with environment updates.

#### Update Settings
- **Preferred Start Time**: Start of environment update window in 24h format (HH:mm).
- **Preferred End Time**: End of environment update window in 24h format (HH:mm).
- **Time Zone ID**: Windows time zone identifier.
- **Preferred Start Time UTC**: Start of an environment's update window, expressed as a UTC timestamp.
- **Preferred End Time UTC**: End of an environment's update window, expressed as a UTC timestamp.

#### Scheduled Updates
- **Update Target Version**: The version of the application that the environment will update to.
- **Can Tenant Select Date**: Indicates if a new update date can be selected.
- **Did Tenant Select Date**: Indicates if the tenant has selected the current date for the update.
- **Earliest Selectable Upgrade Date**: Specifies the earliest date that can be chosen for the update.
- **Latest Selectable Upgrade Date**: Specifies the latest date that can be chosen for the update.
- **Upgrade Date**: The currently selected scheduled date of the update.
- **Update Status**: The current status of the environment's update (e.g., "Scheduled" or "Running").
- **Ignore Upgrade Window**: Indicates if the environment's update window will be ignored.
- **Update Is Active**: Indicates if the update is activated and is scheduled to occur.

**Note**: Some of the fields on this page are hidden by default, and some fields are available only on the Managed BC Environment Card.

**Note**: The list is filtered by default to hide soft deleted environments.

**Note**: Based on the user setup, the list may be filtered to show only environments from one group.

## Actions

### Update Environments
This action updates the selected environments. It retrieves the latest values from the API and updates the corresponding Business Central records to ensure they reflect the most current information and settings.

### Change Update Date
This action allows you to change the scheduled update date for selected environments. You can specify a new update date and indicate whether the update should ignore the update window.

**Note**: The update date must be in the future and must be within the allowed period for the environment.

### Change Update Settings
This action allows you to change the preferred start time, end time, and time zone for the selected environments. All values must be specified. The time zone must be selected from the available time zones (which will be described later).

# Available Update Timezones

This page contains a list of available time zones. The records on this page should not be changed manually.

## Actions

### Get Available Timezones
This action updates the page by deleting all existing records and recreating them from the API. It ensures that the list of time zones is always up to date with the latest information.

# Admin Center API Setup

This setup page allows you to configure the Admin Center API settings. 

**Note**: Do not change the URL and scopes unless you are familiar with the consequences.

## Additional Endpoints
You can enable or disable additional endpoints that are run automatically when the list of environments is updated. This can be used to optimize the process if you don't need some of the endpoints. For example, if you do not plan to change update settings, there is no reason to download information from this endpoint.

### Disableable Endpoints
- **Get Scheduled Update**
- **Get Update Settings**

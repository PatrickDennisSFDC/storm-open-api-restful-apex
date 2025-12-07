# Nora Agent Configuration

## Overview

The **Nora** agent is an Agentforce Employee Agent (InternalCopilot) configured for **Makana Health**. This document describes the current configuration and how to work with it in this project.

## Agent Details

- **Label**: Nora
- **Type**: InternalCopilot (Employee Agent)
- **Company**: Makana Health
- **Role**: "You are an Agentforce Employee Agent"
- **Description**: "An assistive AI agent that can help you manage your CRM data, log meetings, set tasks, and feed you with industry insights and knowledge about your business."
- **Tone**: Casual
- **Template**: EmployeeCopilot__AgentforceEmployeeAgent

## Current Configuration

### Bot Metadata
- **File**: `force-app/main/default/bots/Nora/Nora.bot-meta.xml`
- **Agent Type**: AgentforceEmployeeAgent
- **ML Domain**: Hank
- **Session Timeout**: 0 (no timeout)
- **Rich Content**: Enabled
- **Log Private Conversation Data**: Enabled

### Bot Version (v1)
- **File**: `force-app/main/default/bots/Nora/v1.botVersion-meta.xml`
- **Entry Dialog**: Welcome
- **Planner**: Nora (GenAI Planner)
- **Citations**: Disabled
- **Small Talk**: Disabled
- **Knowledge Actions**: Disabled

### Context Variables

The agent has several conversation variables configured:

1. **ContactId** - MessagingEndUser ContactId (not included in prompt)
2. **EndUserId** - MessagingEndUser Id (included in prompt)
3. **EndUserLanguage** - MessagingSession EndUserLanguage (not included in prompt)
4. **RoutableId** - MessagingSession Id (included in prompt)
5. **VoiceCallId** - VoiceCall Id (included in prompt)
6. **CRM_Context** - System metadata context (included in prompt, internal)
7. **currentAppName** - Salesforce Application Name (included in prompt, external)
8. **currentObjectApiName** - Current Salesforce object API name (included in prompt, external)
9. **currentPageType** - Type of Salesforce Page (included in prompt, external)
10. **currentRecordId** - ID of record on user's screen (included in prompt, external)
11. **VerifiedCustomerId** - Verified customer ID (not included in prompt, internal)

### Dialogs

1. **Welcome** - Entry dialog with greeting message
2. **Error_Handling** - Error message dialog
3. **Transfer_To_Agent** - Transfer to human agent dialog

## Working with the Agent

### Retrieving the Agent

The agent has been retrieved to this project:
```bash
sf project retrieve start --metadata Bot:Nora --target-org storm-org
```

### Deploying the Agent

To deploy changes back to the org:
```bash
sf project deploy start --source-dir force-app/main/default/bots --target-org storm-org
```

### Previewing the Agent

To interact with the agent via CLI (requires client app configuration):
```bash
sf agent preview --api-name Nora --target-org storm-org --client-app <client-app-name>
```

**Note**: You must first create a linked client app using:
```bash
sf org login web --client-app <app-name> --target-org storm-org
```

### Activating/Deactivating

```bash
# Activate the agent
sf agent activate --api-name Nora --target-org storm-org

# Deactivate the agent
sf agent deactivate --api-name Nora --target-org storm-org
```

## Integrating with Consolidated Action Classes

The agent can be configured to use the consolidated CRUD action classes in this repository:

- `AFAccountAction` - Account management
- `AFContactAction` - Contact operations
- `AFOpportunityAction` - Sales pipeline
- `AFCaseAction` - Case management
- `AFTaskAction` - Task management
- `AFMeetingAction` - Custom Meeting object
- `AFCustomerOrderAction` - Order management

### Next Steps for Configuration

1. **In Salesforce Setup UI**:
   - Navigate to Setup → Agentforce Studio → Agents → Nora
   - Go to the Topics tab
   - Create or edit topics to use the consolidated action classes
   - Add actions that reference the Apex invocable methods

2. **Topics to Consider**:
   - Account Management (using `AFAccountAction`)
   - Contact Management (using `AFContactAction`)
   - Opportunity Management (using `AFOpportunityAction`)
   - Case Management (using `AFCaseAction`)
   - Task Management (using `AFTaskAction`)
   - Meeting Logging (using `AFMeetingAction`)
   - Order Management (using `AFCustomerOrderAction`)

3. **Action Configuration**:
   - Each topic can have multiple actions
   - Actions should reference the invocable methods from the consolidated classes
   - The agent will intelligently infer operations (create, read, update, delete, find) based on user intent

## Notes

- Topics and Actions are currently configured in the Salesforce UI and may not be retrievable via Metadata API yet
- The agent uses a GenAI Planner named "Nora" for intelligent conversation routing
- The agent has context variables that provide rich context about the user's current Salesforce session
- The `CRM_Context` variable can be populated with system metadata to help the agent understand available objects and fields

## Related Files

- `force-app/main/default/bots/Nora/Nora.bot-meta.xml` - Main bot definition
- `force-app/main/default/bots/Nora/v1.botVersion-meta.xml` - Bot version configuration
- `README.md` - Repository overview and action class documentation
- `AGENT_CONTEXT.md` - AI agent context for understanding the project
- `AGENT_RULES.md` - Quick reference rules for AI agents


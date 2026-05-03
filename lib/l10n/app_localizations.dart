import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FuzzyBoard'**
  String get appTitle;

  /// No description provided for @dataTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataTabLabel;

  /// No description provided for @pagesTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pagesTabLabel;

  /// No description provided for @toggleThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleThemeLabel;

  /// No description provided for @gotItButton.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotItButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @viewAllButton.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllButton;

  /// No description provided for @viewTasksAction.
  ///
  /// In en, this message translates to:
  /// **'View Tasks'**
  String get viewTasksAction;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @adminViewButton.
  ///
  /// In en, this message translates to:
  /// **'Admin View'**
  String get adminViewButton;

  /// No description provided for @userViewButton.
  ///
  /// In en, this message translates to:
  /// **'User View'**
  String get userViewButton;

  /// No description provided for @welcomeBanner.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! 👋'**
  String get welcomeBanner;

  /// No description provided for @workflowRunningSmooth.
  ///
  /// In en, this message translates to:
  /// **'Your workflow engine is running smoothly.'**
  String get workflowRunningSmooth;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @totalTasksCard.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get totalTasksCard;

  /// No description provided for @todayChange.
  ///
  /// In en, this message translates to:
  /// **'+2 today'**
  String get todayChange;

  /// No description provided for @activeWorkflowsCard.
  ///
  /// In en, this message translates to:
  /// **'Active Workflows'**
  String get activeWorkflowsCard;

  /// No description provided for @totalWorkflows.
  ///
  /// In en, this message translates to:
  /// **'of {total} total'**
  String totalWorkflows(int total);

  /// No description provided for @pluginsCard.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get pluginsCard;

  /// No description provided for @installedLabel.
  ///
  /// In en, this message translates to:
  /// **'installed'**
  String get installedLabel;

  /// No description provided for @runsTodayCard.
  ///
  /// In en, this message translates to:
  /// **'Runs Today'**
  String get runsTodayCard;

  /// No description provided for @upChangePercent.
  ///
  /// In en, this message translates to:
  /// **'↑ 12%'**
  String get upChangePercent;

  /// No description provided for @taskStatusChart.
  ///
  /// In en, this message translates to:
  /// **'Task Status'**
  String get taskStatusChart;

  /// No description provided for @runsLastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Runs (Last 7 days)'**
  String get runsLastSevenDays;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityTitle;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @newTaskButton.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTaskButton;

  /// No description provided for @searchTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks…'**
  String get searchTasksHint;

  /// No description provided for @allChip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allChip;

  /// No description provided for @noTasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasksEmpty;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// No description provided for @newTaskDialog.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTaskDialog;

  /// No description provided for @editTaskDialog.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskDialog;

  /// No description provided for @taskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get taskNameLabel;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskNameHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What does this task do?'**
  String get descriptionHint;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'email, crm, api'**
  String get tagsHint;

  /// No description provided for @assigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assigneeLabel;

  /// No description provided for @assigneeHint.
  ///
  /// In en, this message translates to:
  /// **'username or email'**
  String get assigneeHint;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @setDateButton.
  ///
  /// In en, this message translates to:
  /// **'Set date'**
  String get setDateButton;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @overdueFormat.
  ///
  /// In en, this message translates to:
  /// **'Overdue {count}d'**
  String overdueFormat(int count);

  /// No description provided for @dueInFormat.
  ///
  /// In en, this message translates to:
  /// **'Due in {count}d'**
  String dueInFormat(int count);

  /// No description provided for @workflowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get workflowsTitle;

  /// No description provided for @newWorkflowButton.
  ///
  /// In en, this message translates to:
  /// **'New Workflow'**
  String get newWorkflowButton;

  /// No description provided for @noWorkflowsYet.
  ///
  /// In en, this message translates to:
  /// **'No workflows yet'**
  String get noWorkflowsYet;

  /// No description provided for @createFirstWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Create your first workflow to get started.'**
  String get createFirstWorkflow;

  /// No description provided for @editCanvasButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Canvas'**
  String get editCanvasButton;

  /// No description provided for @deleteWorkflowConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Workflow?'**
  String get deleteWorkflowConfirm;

  /// No description provided for @deleteWorkflowMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteWorkflowMessage(String name);

  /// No description provided for @runsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} runs'**
  String runsCount(int count);

  /// No description provided for @nodesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} nodes'**
  String nodesCount(int count);

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @inactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// No description provided for @canvasWorkflowGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Workflow Builder Guide'**
  String get canvasWorkflowGuideTitle;

  /// No description provided for @addingNodesSection.
  ///
  /// In en, this message translates to:
  /// **'Adding Nodes'**
  String get addingNodesSection;

  /// No description provided for @addingNodesBody.
  ///
  /// In en, this message translates to:
  /// **'Click any node type in the left palette to place it on the canvas.'**
  String get addingNodesBody;

  /// No description provided for @movingNodesSection.
  ///
  /// In en, this message translates to:
  /// **'Moving Nodes'**
  String get movingNodesSection;

  /// No description provided for @movingNodesBody.
  ///
  /// In en, this message translates to:
  /// **'Drag a node to reposition it anywhere on the canvas.'**
  String get movingNodesBody;

  /// No description provided for @connectingNodesSection.
  ///
  /// In en, this message translates to:
  /// **'Connecting Nodes'**
  String get connectingNodesSection;

  /// No description provided for @connectingNodesBody.
  ///
  /// In en, this message translates to:
  /// **'Click the 🔗 icon on a node to enter connect mode, then click the target node to draw an arrow. Press ESC or tap the × chip in the toolbar to cancel.'**
  String get connectingNodesBody;

  /// No description provided for @configuringNodesSection.
  ///
  /// In en, this message translates to:
  /// **'Configuring Nodes'**
  String get configuringNodesSection;

  /// No description provided for @configuringNodesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a node to open its config panel on the right. You can rename it, and delete any of its connections there.'**
  String get configuringNodesBody;

  /// No description provided for @deletingSection.
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get deletingSection;

  /// No description provided for @deletingBody.
  ///
  /// In en, this message translates to:
  /// **'Use the 🗑 icon on a node to remove it and all its connections. To remove a single connection, open the source node config panel.'**
  String get deletingBody;

  /// No description provided for @undoRedoSection.
  ///
  /// In en, this message translates to:
  /// **'Undo / Redo'**
  String get undoRedoSection;

  /// No description provided for @undoRedoBody.
  ///
  /// In en, this message translates to:
  /// **'Up to 30 undo steps are stored. Use the toolbar arrows to step back and forward.'**
  String get undoRedoBody;

  /// No description provided for @exportImportSection.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get exportImportSection;

  /// No description provided for @exportImportBody.
  ///
  /// In en, this message translates to:
  /// **'Export copies the workflow as JSON to your clipboard. Import lets you paste JSON to restore a workflow.'**
  String get exportImportBody;

  /// No description provided for @canvasExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get canvasExportButton;

  /// No description provided for @canvasImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get canvasImportButton;

  /// No description provided for @canvasSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get canvasSaveButton;

  /// No description provided for @canvasSelectTargetNode.
  ///
  /// In en, this message translates to:
  /// **'Click target node — ESC to cancel'**
  String get canvasSelectTargetNode;

  /// No description provided for @canvasTapToConnect.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get canvasTapToConnect;

  /// No description provided for @canvasClickToConnect.
  ///
  /// In en, this message translates to:
  /// **'Click any node to connect — ESC to cancel'**
  String get canvasClickToConnect;

  /// No description provided for @canvasConnectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Connect to another node'**
  String get canvasConnectTooltip;

  /// No description provided for @canvasDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete node'**
  String get canvasDeleteTooltip;

  /// No description provided for @canvasConfigureNode.
  ///
  /// In en, this message translates to:
  /// **'Configure Node'**
  String get canvasConfigureNode;

  /// No description provided for @canvasNodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get canvasNodeLabel;

  /// No description provided for @canvasNodeLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Node label'**
  String get canvasNodeLabelHint;

  /// No description provided for @canvasNodeType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get canvasNodeType;

  /// No description provided for @canvasNodeId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get canvasNodeId;

  /// No description provided for @canvasConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get canvasConnections;

  /// No description provided for @canvasOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get canvasOutgoing;

  /// No description provided for @canvasIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get canvasIncoming;

  /// No description provided for @canvasWorkflowJsonCopied.
  ///
  /// In en, this message translates to:
  /// **'Workflow JSON copied to clipboard!'**
  String get canvasWorkflowJsonCopied;

  /// No description provided for @canvasImportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Workflow JSON'**
  String get canvasImportJsonTitle;

  /// No description provided for @canvasImportJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Paste workflow JSON here...'**
  String get canvasImportJsonHint;

  /// No description provided for @canvasWorkflowImported.
  ///
  /// In en, this message translates to:
  /// **'Workflow imported!'**
  String get canvasWorkflowImported;

  /// No description provided for @canvasImportError.
  ///
  /// In en, this message translates to:
  /// **'Import error: {error}'**
  String canvasImportError(String error);

  /// No description provided for @canvasHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get canvasHelpTooltip;

  /// No description provided for @canvasNodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get canvasNodesLabel;

  /// No description provided for @nodeTriggerDesc.
  ///
  /// In en, this message translates to:
  /// **'Starts the workflow (e.g. on event)'**
  String get nodeTriggerDesc;

  /// No description provided for @nodeActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Runs an action (e.g. send email)'**
  String get nodeActionDesc;

  /// No description provided for @nodeConditionDesc.
  ///
  /// In en, this message translates to:
  /// **'Branch on true/false'**
  String get nodeConditionDesc;

  /// No description provided for @nodeDelayDesc.
  ///
  /// In en, this message translates to:
  /// **'Wait a specified time'**
  String get nodeDelayDesc;

  /// No description provided for @nodeScriptDesc.
  ///
  /// In en, this message translates to:
  /// **'Run a Lua/SQL script'**
  String get nodeScriptDesc;

  /// No description provided for @nodeEndDesc.
  ///
  /// In en, this message translates to:
  /// **'Marks the workflow end'**
  String get nodeEndDesc;

  /// No description provided for @newTriggerNode.
  ///
  /// In en, this message translates to:
  /// **'New Trigger'**
  String get newTriggerNode;

  /// No description provided for @newActionNode.
  ///
  /// In en, this message translates to:
  /// **'New Action'**
  String get newActionNode;

  /// No description provided for @conditionNode.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionNode;

  /// No description provided for @delayNode.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delayNode;

  /// No description provided for @scriptNode.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get scriptNode;

  /// No description provided for @endNode.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endNode;

  /// No description provided for @pluginsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get pluginsTitle;

  /// No description provided for @installedPluginsHeader.
  ///
  /// In en, this message translates to:
  /// **'Installed Plugins'**
  String get installedPluginsHeader;

  /// No description provided for @noPluginsInstalled.
  ///
  /// In en, this message translates to:
  /// **'No plugins installed'**
  String get noPluginsInstalled;

  /// No description provided for @noPluginsInstalledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visit the Marketplace to install plugins.'**
  String get noPluginsInstalledSubtitle;

  /// No description provided for @pluginStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get pluginStatusActive;

  /// No description provided for @pluginStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get pluginStatusInactive;

  /// No description provided for @pluginStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get pluginStatusError;

  /// No description provided for @marketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplaceTitle;

  /// No description provided for @searchPluginsHint.
  ///
  /// In en, this message translates to:
  /// **'Search plugins…'**
  String get searchPluginsHint;

  /// No description provided for @noPluginsFound.
  ///
  /// In en, this message translates to:
  /// **'No plugins found'**
  String get noPluginsFound;

  /// No description provided for @pluginMarketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Plugin Marketplace'**
  String get pluginMarketplaceTitle;

  /// No description provided for @pluginMarketplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extend your workflow engine with community plugins.'**
  String get pluginMarketplaceSubtitle;

  /// No description provided for @installedBadge.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installedBadge;

  /// No description provided for @installButton.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get installButton;

  /// No description provided for @allCategoriesFilter.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategoriesFilter;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeSection.
  ///
  /// In en, this message translates to:
  /// **'🎨 Theme'**
  String get themeSection;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize the look and feel'**
  String get themeSubtitle;

  /// No description provided for @colorModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Color Mode'**
  String get colorModeLabel;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @accentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColorLabel;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'✨ Appearance'**
  String get appearanceSection;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visual preferences'**
  String get appearanceSubtitle;

  /// No description provided for @showAvatarToggle.
  ///
  /// In en, this message translates to:
  /// **'Show avatar mascot'**
  String get showAvatarToggle;

  /// No description provided for @showAvatarDesc.
  ///
  /// In en, this message translates to:
  /// **'Display the floating avatar on desktop'**
  String get showAvatarDesc;

  /// No description provided for @reducedMotionToggle.
  ///
  /// In en, this message translates to:
  /// **'Reduced motion'**
  String get reducedMotionToggle;

  /// No description provided for @reducedMotionDesc.
  ///
  /// In en, this message translates to:
  /// **'Minimize animations throughout the app'**
  String get reducedMotionDesc;

  /// No description provided for @compactSidebarToggle.
  ///
  /// In en, this message translates to:
  /// **'Compact sidebar'**
  String get compactSidebarToggle;

  /// No description provided for @compactSidebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Use icon-only sidebar on medium screens'**
  String get compactSidebarDesc;

  /// No description provided for @engineSection.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Engine'**
  String get engineSection;

  /// No description provided for @engineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workflow engine settings'**
  String get engineSubtitle;

  /// No description provided for @devModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode'**
  String get devModeToggle;

  /// No description provided for @devModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable advanced dev tools and logs'**
  String get devModeDesc;

  /// No description provided for @autoSaveToggle.
  ///
  /// In en, this message translates to:
  /// **'Auto-save workflows'**
  String get autoSaveToggle;

  /// No description provided for @autoSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically save on every change'**
  String get autoSaveDesc;

  /// No description provided for @verboseLoggingToggle.
  ///
  /// In en, this message translates to:
  /// **'Verbose logging'**
  String get verboseLoggingToggle;

  /// No description provided for @verboseLoggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Log detailed execution traces'**
  String get verboseLoggingDesc;

  /// No description provided for @aboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'ℹ️ About FuzzyBoard'**
  String get aboutSectionTitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @versionValue.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionValue;

  /// No description provided for @engineLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engineLabel;

  /// No description provided for @engineValue.
  ///
  /// In en, this message translates to:
  /// **'FuzzyFlow v0.9'**
  String get engineValue;

  /// No description provided for @flutterLabel.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get flutterLabel;

  /// No description provided for @flutterValue.
  ///
  /// In en, this message translates to:
  /// **'3.27+'**
  String get flutterValue;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'FuzzyBoard is an open workflow engine dashboard built with Flutter.'**
  String get aboutDescription;

  /// No description provided for @pickColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickColorTitle;

  /// No description provided for @mediaLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Library'**
  String get mediaLibraryTitle;

  /// No description provided for @uploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadButton;

  /// No description provided for @noMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'No media files yet'**
  String get noMediaFiles;

  /// No description provided for @mediaDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get mediaDetailsTitle;

  /// No description provided for @deleteFileButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteFileButton;

  /// No description provided for @contentTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Types'**
  String get contentTypesTitle;

  /// No description provided for @newTypeButton.
  ///
  /// In en, this message translates to:
  /// **'New Type'**
  String get newTypeButton;

  /// No description provided for @noContentTypes.
  ///
  /// In en, this message translates to:
  /// **'No content types yet. Create your first schema.'**
  String get noContentTypes;

  /// No description provided for @deleteContentTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Content Type'**
  String get deleteContentTypeTitle;

  /// No description provided for @deleteContentTypeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? All entries will also be deleted.'**
  String deleteContentTypeConfirm(String name);

  /// No description provided for @editContentTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Content Type'**
  String get editContentTypeTitle;

  /// No description provided for @newContentTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'New Content Type'**
  String get newContentTypeTitle;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Blog Post'**
  String get displayNameHint;

  /// No description provided for @apiIdLabel.
  ///
  /// In en, this message translates to:
  /// **'API ID'**
  String get apiIdLabel;

  /// No description provided for @apiIdHint.
  ///
  /// In en, this message translates to:
  /// **'blog-post'**
  String get apiIdHint;

  /// No description provided for @fieldsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get fieldsLabel;

  /// No description provided for @addFieldButton.
  ///
  /// In en, this message translates to:
  /// **'Add Field'**
  String get addFieldButton;

  /// No description provided for @pagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pagesTitle;

  /// No description provided for @newPageButton.
  ///
  /// In en, this message translates to:
  /// **'New Page'**
  String get newPageButton;

  /// No description provided for @noPages.
  ///
  /// In en, this message translates to:
  /// **'No pages yet'**
  String get noPages;

  /// No description provided for @editPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Page'**
  String get editPageTitle;

  /// No description provided for @newPageTitle.
  ///
  /// In en, this message translates to:
  /// **'New Page'**
  String get newPageTitle;

  /// No description provided for @pageTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get pageTitleLabel;

  /// No description provided for @pageTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Page title'**
  String get pageTitleHint;

  /// No description provided for @slugLabel.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get slugLabel;

  /// No description provided for @slugHint.
  ///
  /// In en, this message translates to:
  /// **'/my-page'**
  String get slugHint;

  /// No description provided for @templateLabel.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templateLabel;

  /// No description provided for @seoTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'SEO Title'**
  String get seoTitleLabel;

  /// No description provided for @seoTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Browser tab title'**
  String get seoTitleHint;

  /// No description provided for @seoDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'SEO Description'**
  String get seoDescriptionLabel;

  /// No description provided for @seoDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Meta description'**
  String get seoDescriptionHint;

  /// No description provided for @publishedStatus.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedStatus;

  /// No description provided for @draftStatus.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftStatus;

  /// No description provided for @scheduledStatus.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledStatus;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @newCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategoryButton;

  /// No description provided for @noCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesEmpty;

  /// No description provided for @categoryEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String categoryEntriesCount(int count);

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategoryTitle;

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get categoryNameHint;

  /// No description provided for @categorySlugLabel.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get categorySlugLabel;

  /// No description provided for @categorySlugHint.
  ///
  /// In en, this message translates to:
  /// **'tutorials'**
  String get categorySlugHint;

  /// No description provided for @categoryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColorLabel;

  /// No description provided for @contentEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Entries'**
  String get contentEntriesTitle;

  /// No description provided for @newEntryButton.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntryButton;

  /// No description provided for @searchEntriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search entries…'**
  String get searchEntriesHint;

  /// No description provided for @noEntriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesEmpty;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntryTitle;

  /// No description provided for @newEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New {typeName}'**
  String newEntryTitle(String typeName);

  /// No description provided for @entryTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get entryTitleLabel;

  /// No description provided for @entryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Entry title'**
  String get entryTitleHint;

  /// No description provided for @cmsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'CMS Overview'**
  String get cmsOverviewTitle;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @newEntryAction.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntryAction;

  /// No description provided for @uploadMediaAction.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get uploadMediaAction;

  /// No description provided for @managePagesAction.
  ///
  /// In en, this message translates to:
  /// **'Manage Pages'**
  String get managePagesAction;

  /// No description provided for @categoriesAction.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesAction;

  /// No description provided for @contentTypesAction.
  ///
  /// In en, this message translates to:
  /// **'Content Types'**
  String get contentTypesAction;

  /// No description provided for @recentEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Entries'**
  String get recentEntriesTitle;

  /// No description provided for @totalEntriesStats.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get totalEntriesStats;

  /// No description provided for @publishedStats.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishedStats;

  /// No description provided for @draftsStats.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftsStats;

  /// No description provided for @mediaFilesStats.
  ///
  /// In en, this message translates to:
  /// **'Media Files'**
  String get mediaFilesStats;

  /// No description provided for @pagesStats.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pagesStats;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @pageBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Page Builder'**
  String get pageBuilderTitle;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @paletteLabel.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get paletteLabel;

  /// No description provided for @textPaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textPaletteItem;

  /// No description provided for @buttonPaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get buttonPaletteItem;

  /// No description provided for @imagePaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imagePaletteItem;

  /// No description provided for @cardPaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardPaletteItem;

  /// No description provided for @rowPaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get rowPaletteItem;

  /// No description provided for @columnPaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get columnPaletteItem;

  /// No description provided for @dividerPaletteItem.
  ///
  /// In en, this message translates to:
  /// **'Divider'**
  String get dividerPaletteItem;

  /// No description provided for @dragWidgetsHere.
  ///
  /// In en, this message translates to:
  /// **'Drag widgets here'**
  String get dragWidgetsHere;

  /// No description provided for @selectWidgetProperty.
  ///
  /// In en, this message translates to:
  /// **'Select a widget\nto edit its properties'**
  String get selectWidgetProperty;

  /// No description provided for @propertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @labelLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelLabel;

  /// No description provided for @voiceModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Mode'**
  String get voiceModeTitle;

  /// No description provided for @listeningStatus.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listeningStatus;

  /// No description provided for @tapToSpeakPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeakPrompt;

  /// No description provided for @startListeningPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start Listening'**
  String get startListeningPrompt;

  /// No description provided for @fuzzyAIListening.
  ///
  /// In en, this message translates to:
  /// **'FuzzyAI is hearing you'**
  String get fuzzyAIListening;

  /// No description provided for @recentCommandsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Commands'**
  String get recentCommandsTitle;

  /// No description provided for @sqlBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'SQL Visual Builder'**
  String get sqlBuilderTitle;

  /// No description provided for @copySqlButton.
  ///
  /// In en, this message translates to:
  /// **'Copy SQL'**
  String get copySqlButton;

  /// No description provided for @saveAsTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Save as Task'**
  String get saveAsTaskButton;

  /// No description provided for @sqlCopiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'SQL copied to clipboard!'**
  String get sqlCopiedSnackbar;

  /// No description provided for @fromTableSection.
  ///
  /// In en, this message translates to:
  /// **'📋 FROM Table'**
  String get fromTableSection;

  /// No description provided for @selectColumnsSection.
  ///
  /// In en, this message translates to:
  /// **'📌 SELECT Columns'**
  String get selectColumnsSection;

  /// No description provided for @allColumnsSelected.
  ///
  /// In en, this message translates to:
  /// **'All columns selected (*)'**
  String get allColumnsSelected;

  /// No description provided for @whereClausesSection.
  ///
  /// In en, this message translates to:
  /// **'🔍 WHERE Clauses'**
  String get whereClausesSection;

  /// No description provided for @orderBySection.
  ///
  /// In en, this message translates to:
  /// **'⬇️ ORDER BY'**
  String get orderBySection;

  /// No description provided for @chooseColumnDropdown.
  ///
  /// In en, this message translates to:
  /// **'Choose column'**
  String get chooseColumnDropdown;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @limitSection.
  ///
  /// In en, this message translates to:
  /// **'🔢 LIMIT'**
  String get limitSection;

  /// No description provided for @noLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimitLabel;

  /// No description provided for @limitRowsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String limitRowsLabel(int count);

  /// No description provided for @generatedSqlLabel.
  ///
  /// In en, this message translates to:
  /// **'Generated SQL'**
  String get generatedSqlLabel;

  /// No description provided for @previewBadge.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get previewBadge;

  /// No description provided for @saveTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Save SQL as Task'**
  String get saveTaskTitle;

  /// No description provided for @saveTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Give this SQL query a name. It will be added to your Tasks as a To-Do item.'**
  String get saveTaskMessage;

  /// No description provided for @taskNameInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskNameInputLabel;

  /// No description provided for @sqlTaskNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Get active users'**
  String get sqlTaskNamePlaceholder;

  /// No description provided for @createTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTaskButton;

  /// No description provided for @taskCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Task \"{name}\" created!'**
  String taskCreatedSnackbar(String name);

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'FuzzyAI'**
  String get chatTitle;

  /// No description provided for @clearChatButton.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChatButton;

  /// No description provided for @clearChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChatTooltip;

  /// No description provided for @messageFuzzyAI.
  ///
  /// In en, this message translates to:
  /// **'Message FuzzyAI…'**
  String get messageFuzzyAI;

  /// No description provided for @fuzzyAITyping.
  ///
  /// In en, this message translates to:
  /// **'FuzzyAI is typing…'**
  String get fuzzyAITyping;

  /// No description provided for @copiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copiedSnackbar;

  /// No description provided for @devModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dev Mode'**
  String get devModeTitle;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeBadge;

  /// No description provided for @enableDevMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Dev Mode'**
  String get enableDevMode;

  /// No description provided for @disableDevMode.
  ///
  /// In en, this message translates to:
  /// **'Disable Dev Mode'**
  String get disableDevMode;

  /// No description provided for @logsTab.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsTab;

  /// No description provided for @stateTab.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateTab;

  /// No description provided for @testsTab.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get testsTab;

  /// No description provided for @clearLogsButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLogsButton;

  /// No description provided for @logEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String logEntriesCount(int count);

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @tasksStateCard.
  ///
  /// In en, this message translates to:
  /// **'Tasks State'**
  String get tasksStateCard;

  /// No description provided for @workflowsStateCard.
  ///
  /// In en, this message translates to:
  /// **'Workflows State'**
  String get workflowsStateCard;

  /// No description provided for @pluginsStateCard.
  ///
  /// In en, this message translates to:
  /// **'Plugins State'**
  String get pluginsStateCard;

  /// No description provided for @runAllTests.
  ///
  /// In en, this message translates to:
  /// **'Run All Tests'**
  String get runAllTests;

  /// No description provided for @runningTests.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get runningTests;

  /// No description provided for @testsPassed.
  ///
  /// In en, this message translates to:
  /// **'{passed}/{total} passed'**
  String testsPassed(int passed, int total);

  /// No description provided for @luaExpressionBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Lua Expression Builder'**
  String get luaExpressionBuilderTitle;

  /// No description provided for @luaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build boolean logic visually'**
  String get luaSubtitle;

  /// No description provided for @luaDescription.
  ///
  /// In en, this message translates to:
  /// **'Compose boolean expressions using AND, OR, NOT and comparison operators. The result is valid Lua code you can paste into your workflow scripts.'**
  String get luaDescription;

  /// No description provided for @luaCopyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get luaCopyButton;

  /// No description provided for @luaSaveAsTask.
  ///
  /// In en, this message translates to:
  /// **'Save as Task'**
  String get luaSaveAsTask;

  /// No description provided for @luaCopiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Lua expression copied!'**
  String get luaCopiedSnackbar;

  /// No description provided for @luaTabBuilder.
  ///
  /// In en, this message translates to:
  /// **'Builder'**
  String get luaTabBuilder;

  /// No description provided for @luaTabCode.
  ///
  /// In en, this message translates to:
  /// **'Lua Code'**
  String get luaTabCode;

  /// No description provided for @saveLuaTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Lua Expression as Task'**
  String get saveLuaTaskTitle;

  /// No description provided for @saveLuaTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Give this Lua expression a name. It will be added to your Tasks as a To-Do item.'**
  String get saveLuaTaskMessage;

  /// No description provided for @luaTaskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get luaTaskNameLabel;

  /// No description provided for @luaTaskNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Check user status condition'**
  String get luaTaskNameHint;

  /// No description provided for @luaGeneratedCode.
  ///
  /// In en, this message translates to:
  /// **'Generated Lua'**
  String get luaGeneratedCode;

  /// No description provided for @luaLiveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get luaLiveBadge;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks, workflows & plugins…'**
  String get searchHint;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @searchTasksSection.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get searchTasksSection;

  /// No description provided for @searchWorkflowsSection.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get searchWorkflowsSection;

  /// No description provided for @searchPluginsSection.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get searchPluginsSection;

  /// No description provided for @searchCmsEntriesSection.
  ///
  /// In en, this message translates to:
  /// **'CMS Entries'**
  String get searchCmsEntriesSection;

  /// No description provided for @searchCmsPagesSection.
  ///
  /// In en, this message translates to:
  /// **'CMS Pages'**
  String get searchCmsPagesSection;

  /// No description provided for @sidebarDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get sidebarDashboard;

  /// No description provided for @sidebarTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get sidebarTasks;

  /// No description provided for @sidebarWorkflows.
  ///
  /// In en, this message translates to:
  /// **'Workflows'**
  String get sidebarWorkflows;

  /// No description provided for @sidebarPlugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get sidebarPlugins;

  /// No description provided for @sidebarMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get sidebarMarketplace;

  /// No description provided for @sidebarSqlBuilder.
  ///
  /// In en, this message translates to:
  /// **'SQL Builder'**
  String get sidebarSqlBuilder;

  /// No description provided for @sidebarLuaBuilder.
  ///
  /// In en, this message translates to:
  /// **'Lua Builder'**
  String get sidebarLuaBuilder;

  /// No description provided for @sidebarSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sidebarSearch;

  /// No description provided for @sidebarAiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get sidebarAiChat;

  /// No description provided for @sidebarVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get sidebarVoice;

  /// No description provided for @sidebarDevMode.
  ///
  /// In en, this message translates to:
  /// **'Dev Mode'**
  String get sidebarDevMode;

  /// No description provided for @sidebarSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sidebarSettings;

  /// No description provided for @sidebarPageBuilder.
  ///
  /// In en, this message translates to:
  /// **'Page Builder'**
  String get sidebarPageBuilder;

  /// No description provided for @sidebarCms.
  ///
  /// In en, this message translates to:
  /// **'CMS'**
  String get sidebarCms;

  /// No description provided for @sidebarCmsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get sidebarCmsOverview;

  /// No description provided for @sidebarContentTypes.
  ///
  /// In en, this message translates to:
  /// **'Content Types'**
  String get sidebarContentTypes;

  /// No description provided for @sidebarEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get sidebarEntries;

  /// No description provided for @sidebarMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get sidebarMedia;

  /// No description provided for @sidebarPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get sidebarPages;

  /// No description provided for @sidebarCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get sidebarCategories;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your workspace'**
  String get loginSubtitle;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginCredentialsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get loginCredentialsHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signupSubtitle;

  /// No description provided for @signupGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get signupGetStarted;

  /// No description provided for @signupWorkspaceHint.
  ///
  /// In en, this message translates to:
  /// **'Create your FuzzyBoard workspace'**
  String get signupWorkspaceHint;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Jane Doe'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @hasAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccountPrompt;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @configTitle.
  ///
  /// In en, this message translates to:
  /// **'System Configuration'**
  String get configTitle;

  /// No description provided for @configAppNode.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get configAppNode;

  /// No description provided for @configSelectNode.
  ///
  /// In en, this message translates to:
  /// **'Select a node'**
  String get configSelectNode;

  /// No description provided for @configSelectNodeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any node to view\nand edit its configuration'**
  String get configSelectNodeHint;

  /// No description provided for @configAppSaved.
  ///
  /// In en, this message translates to:
  /// **'App config saved'**
  String get configAppSaved;

  /// No description provided for @configAppConfiguration.
  ///
  /// In en, this message translates to:
  /// **'App Configuration'**
  String get configAppConfiguration;

  /// No description provided for @configGlobalSettings.
  ///
  /// In en, this message translates to:
  /// **'Global application settings'**
  String get configGlobalSettings;

  /// No description provided for @configMaxConcurrency.
  ///
  /// In en, this message translates to:
  /// **'Max Concurrency'**
  String get configMaxConcurrency;

  /// No description provided for @configMaxConcurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'10'**
  String get configMaxConcurrencyHint;

  /// No description provided for @configApiBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'API Base URL'**
  String get configApiBaseUrl;

  /// No description provided for @configTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get configTimezone;

  /// No description provided for @configTimezoneHint.
  ///
  /// In en, this message translates to:
  /// **'UTC'**
  String get configTimezoneHint;

  /// No description provided for @configSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get configSaveChanges;

  /// No description provided for @configLogLevel.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get configLogLevel;

  /// No description provided for @configWorkerSaved.
  ///
  /// In en, this message translates to:
  /// **'Worker saved'**
  String get configWorkerSaved;

  /// No description provided for @configWorkerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get configWorkerName;

  /// No description provided for @configWorkerConcurrency.
  ///
  /// In en, this message translates to:
  /// **'Concurrency'**
  String get configWorkerConcurrency;

  /// No description provided for @configWorkerMaxRetries.
  ///
  /// In en, this message translates to:
  /// **'Max Retries'**
  String get configWorkerMaxRetries;

  /// No description provided for @configWorkerTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get configWorkerTimeout;

  /// No description provided for @configWorkerEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get configWorkerEndpoint;

  /// No description provided for @configWorkerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get configWorkerStop;

  /// No description provided for @configWorkerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get configWorkerStart;

  /// No description provided for @configPluginNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not Installed'**
  String get configPluginNotInstalled;

  /// No description provided for @configPluginAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get configPluginAuthor;

  /// No description provided for @configPluginRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get configPluginRating;

  /// No description provided for @configPluginDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get configPluginDownloads;

  /// No description provided for @configPluginDownloadsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} installs'**
  String configPluginDownloadsValue(String count);

  /// No description provided for @configPluginUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get configPluginUninstall;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

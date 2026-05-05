import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FuzzyBoard';

  @override
  String get dataTabLabel => 'Data';

  @override
  String get pagesTabLabel => 'Pages';

  @override
  String get toggleThemeLabel => 'Toggle Theme';

  @override
  String get gotItButton => 'Got it!';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get createButton => 'Create';

  @override
  String get saveButton => 'Save';

  @override
  String get updateButton => 'Update';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get removeButton => 'Remove';

  @override
  String get doneButton => 'Done';

  @override
  String get importButton => 'Import';

  @override
  String get viewAllButton => 'View all';

  @override
  String get viewTasksAction => 'View Tasks';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get adminViewButton => 'Admin View';

  @override
  String get userViewButton => 'User View';

  @override
  String get welcomeBanner => 'Welcome back! 👋';

  @override
  String get workflowRunningSmooth => 'Your workflow engine is running smoothly.';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get totalTasksCard => 'Total Tasks';

  @override
  String get todayChange => '+2 today';

  @override
  String get activeWorkflowsCard => 'Active Workflows';

  @override
  String totalWorkflows(int total) {
    return 'of $total total';
  }

  @override
  String get pluginsCard => 'Plugins';

  @override
  String get installedLabel => 'installed';

  @override
  String get runsTodayCard => 'Runs Today';

  @override
  String get upChangePercent => '↑ 12%';

  @override
  String get taskStatusChart => 'Task Status';

  @override
  String get runsLastSevenDays => 'Runs (Last 7 days)';

  @override
  String get recentActivityTitle => 'Recent Activity';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get newTaskButton => 'New Task';

  @override
  String get searchTasksHint => 'Search tasks…';

  @override
  String get allChip => 'All';

  @override
  String get noTasksEmpty => 'No tasks';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get newTaskDialog => 'New Task';

  @override
  String get editTaskDialog => 'Edit Task';

  @override
  String get taskNameLabel => 'Name';

  @override
  String get taskNameHint => 'Task name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'What does this task do?';

  @override
  String get statusLabel => 'Status';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'email, crm, api';

  @override
  String get assigneeLabel => 'Assignee';

  @override
  String get assigneeHint => 'username or email';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get setDateButton => 'Set date';

  @override
  String get changeButton => 'Change';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String overdueFormat(int count) {
    return 'Overdue ${count}d';
  }

  @override
  String dueInFormat(int count) {
    return 'Due in ${count}d';
  }

  @override
  String get workflowsTitle => 'Workflows';

  @override
  String get newWorkflowButton => 'New Workflow';

  @override
  String get noWorkflowsYet => 'No workflows yet';

  @override
  String get createFirstWorkflow => 'Create your first workflow to get started.';

  @override
  String get viewWorkflowButton => 'View';

  @override
  String get editCanvasButton => 'Edit Canvas';

  @override
  String get deleteWorkflowConfirm => 'Delete Workflow?';

  @override
  String deleteWorkflowMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String runsCount(int count) {
    return '$count runs';
  }

  @override
  String nodesCount(int count) {
    return '$count nodes';
  }

  @override
  String get activeStatus => 'Active';

  @override
  String get inactiveStatus => 'Inactive';

  @override
  String get runningStatus => 'Running';

  @override
  String get canvasWorkflowGuideTitle => 'Workflow Builder Guide';

  @override
  String get addingNodesSection => 'Adding Nodes';

  @override
  String get addingNodesBody => 'Click any node type in the left palette to place it on the canvas.';

  @override
  String get movingNodesSection => 'Moving Nodes';

  @override
  String get movingNodesBody => 'Drag a node to reposition it anywhere on the canvas.';

  @override
  String get connectingNodesSection => 'Connecting Nodes';

  @override
  String get connectingNodesBody => 'Click the 🔗 icon on a node to enter connect mode, then click the target node to draw an arrow. Press ESC or tap the × chip in the toolbar to cancel.';

  @override
  String get configuringNodesSection => 'Configuring Nodes';

  @override
  String get configuringNodesBody => 'Tap a node to open its config panel on the right. You can rename it, and delete any of its connections there.';

  @override
  String get deletingSection => 'Deleting';

  @override
  String get deletingBody => 'Use the 🗑 icon on a node to remove it and all its connections. To remove a single connection, open the source node config panel.';

  @override
  String get undoRedoSection => 'Undo / Redo';

  @override
  String get undoRedoBody => 'Up to 30 undo steps are stored. Use the toolbar arrows to step back and forward.';

  @override
  String get exportImportSection => 'Export / Import';

  @override
  String get exportImportBody => 'Export copies the workflow as JSON to your clipboard. Import lets you paste JSON to restore a workflow.';

  @override
  String get canvasExportButton => 'Export';

  @override
  String get canvasImportButton => 'Import';

  @override
  String get canvasSaveButton => 'Save';

  @override
  String get canvasSelectTargetNode => 'Click target node — ESC to cancel';

  @override
  String get canvasTapToConnect => 'Tap to connect';

  @override
  String get canvasClickToConnect => 'Click any node to connect — ESC to cancel';

  @override
  String get canvasConnectTooltip => 'Connect to another node';

  @override
  String get canvasDeleteTooltip => 'Delete node';

  @override
  String get canvasConfigureNode => 'Configure Node';

  @override
  String get canvasNodeLabel => 'Label';

  @override
  String get canvasNodeLabelHint => 'Node label';

  @override
  String get canvasNodeType => 'Type';

  @override
  String get canvasNodeId => 'ID';

  @override
  String get canvasConnections => 'Connections';

  @override
  String get canvasOutgoing => 'Outgoing';

  @override
  String get canvasIncoming => 'Incoming';

  @override
  String get canvasWorkflowJsonCopied => 'Workflow JSON copied to clipboard!';

  @override
  String get canvasImportJsonTitle => 'Import Workflow JSON';

  @override
  String get canvasImportJsonHint => 'Paste workflow JSON here...';

  @override
  String get canvasWorkflowImported => 'Workflow imported!';

  @override
  String canvasImportError(String error) {
    return 'Import error: $error';
  }

  @override
  String get canvasHelpTooltip => 'How to use';

  @override
  String get canvasNodesLabel => 'Nodes';

  @override
  String get nodeTriggerDesc => 'Starts the workflow (e.g. on event)';

  @override
  String get nodeActionDesc => 'Runs an action (e.g. send email)';

  @override
  String get nodeConditionDesc => 'Branch on true/false';

  @override
  String get nodeDelayDesc => 'Wait a specified time';

  @override
  String get nodeScriptDesc => 'Run a Lua/SQL script';

  @override
  String get nodeEndDesc => 'Marks the workflow end';

  @override
  String get newTriggerNode => 'New Trigger';

  @override
  String get newActionNode => 'New Action';

  @override
  String get conditionNode => 'Condition';

  @override
  String get delayNode => 'Delay';

  @override
  String get scriptNode => 'Script';

  @override
  String get endNode => 'End';

  @override
  String get pluginsTitle => 'Plugins';

  @override
  String get installedPluginsHeader => 'Installed Plugins';

  @override
  String get noPluginsInstalled => 'No plugins installed';

  @override
  String get noPluginsInstalledSubtitle => 'Visit the Marketplace to install plugins.';

  @override
  String get pluginStatusActive => 'Active';

  @override
  String get pluginStatusInactive => 'Inactive';

  @override
  String get pluginStatusError => 'Error';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get searchPluginsHint => 'Search plugins…';

  @override
  String get noPluginsFound => 'No plugins found';

  @override
  String get pluginMarketplaceTitle => 'Plugin Marketplace';

  @override
  String get pluginMarketplaceSubtitle => 'Extend your workflow engine with community plugins.';

  @override
  String get installedBadge => 'Installed';

  @override
  String get installButton => 'Install';

  @override
  String get allCategoriesFilter => 'All Categories';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeSection => '🎨 Theme';

  @override
  String get themeSubtitle => 'Customize the look and feel';

  @override
  String get colorModeLabel => 'Color Mode';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get accentColorLabel => 'Accent Color';

  @override
  String get appearanceSection => '✨ Appearance';

  @override
  String get appearanceSubtitle => 'Visual preferences';

  @override
  String get showAvatarToggle => 'Show avatar mascot';

  @override
  String get showAvatarDesc => 'Display the floating avatar on desktop';

  @override
  String get reducedMotionToggle => 'Reduced motion';

  @override
  String get reducedMotionDesc => 'Minimize animations throughout the app';

  @override
  String get compactSidebarToggle => 'Compact sidebar';

  @override
  String get compactSidebarDesc => 'Use icon-only sidebar on medium screens';

  @override
  String get engineSection => '⚙️ Engine';

  @override
  String get engineSubtitle => 'Workflow engine settings';

  @override
  String get devModeToggle => 'Developer Mode';

  @override
  String get devModeDesc => 'Enable advanced dev tools and logs';

  @override
  String get autoSaveToggle => 'Auto-save workflows';

  @override
  String get autoSaveDesc => 'Automatically save on every change';

  @override
  String get verboseLoggingToggle => 'Verbose logging';

  @override
  String get verboseLoggingDesc => 'Log detailed execution traces';

  @override
  String get aboutSectionTitle => 'ℹ️ About FuzzyBoard';

  @override
  String get versionLabel => 'Version';

  @override
  String get versionValue => '1.0.0';

  @override
  String get engineLabel => 'Engine';

  @override
  String get engineValue => 'FuzzyFlow v0.9';

  @override
  String get flutterLabel => 'Flutter';

  @override
  String get flutterValue => '3.27+';

  @override
  String get aboutDescription => 'FuzzyBoard is an open workflow engine dashboard built with Flutter.';

  @override
  String get pickColorTitle => 'Pick a color';

  @override
  String get mediaLibraryTitle => 'Media Library';

  @override
  String get uploadButton => 'Upload';

  @override
  String get noMediaFiles => 'No media files yet';

  @override
  String get mediaDetailsTitle => 'Details';

  @override
  String get deleteFileButton => 'Delete';

  @override
  String get contentTypesTitle => 'Content Types';

  @override
  String get newTypeButton => 'New Type';

  @override
  String get noContentTypes => 'No content types yet. Create your first schema.';

  @override
  String get deleteContentTypeTitle => 'Delete Content Type';

  @override
  String deleteContentTypeConfirm(String name) {
    return 'Delete \"$name\"? All entries will also be deleted.';
  }

  @override
  String get editContentTypeTitle => 'Edit Content Type';

  @override
  String get newContentTypeTitle => 'New Content Type';

  @override
  String get displayNameLabel => 'Display Name';

  @override
  String get displayNameHint => 'Blog Post';

  @override
  String get apiIdLabel => 'API ID';

  @override
  String get apiIdHint => 'blog-post';

  @override
  String get fieldsLabel => 'Fields';

  @override
  String get addFieldButton => 'Add Field';

  @override
  String get pagesTitle => 'Pages';

  @override
  String get newPageButton => 'New Page';

  @override
  String get noPages => 'No pages yet';

  @override
  String get editPageTitle => 'Edit Page';

  @override
  String get newPageTitle => 'New Page';

  @override
  String get pageTitleLabel => 'Title';

  @override
  String get pageTitleHint => 'Page title';

  @override
  String get slugLabel => 'Slug';

  @override
  String get slugHint => '/my-page';

  @override
  String get templateLabel => 'Template';

  @override
  String get seoTitleLabel => 'SEO Title';

  @override
  String get seoTitleHint => 'Browser tab title';

  @override
  String get seoDescriptionLabel => 'SEO Description';

  @override
  String get seoDescriptionHint => 'Meta description';

  @override
  String get publishedStatus => 'Published';

  @override
  String get draftStatus => 'Draft';

  @override
  String get scheduledStatus => 'Scheduled';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get newCategoryButton => 'New Category';

  @override
  String get noCategoriesEmpty => 'No categories yet';

  @override
  String categoryEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get newCategoryTitle => 'New Category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameHint => 'Tutorials';

  @override
  String get categorySlugLabel => 'Slug';

  @override
  String get categorySlugHint => 'tutorials';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get contentEntriesTitle => 'Content Entries';

  @override
  String get newEntryButton => 'New Entry';

  @override
  String get searchEntriesHint => 'Search entries…';

  @override
  String get noEntriesEmpty => 'No entries yet';

  @override
  String get editEntryTitle => 'Edit Entry';

  @override
  String newEntryTitle(String typeName) {
    return 'New $typeName';
  }

  @override
  String get entryTitleLabel => 'Title';

  @override
  String get entryTitleHint => 'Entry title';

  @override
  String get cmsOverviewTitle => 'CMS Overview';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get newEntryAction => 'New Entry';

  @override
  String get uploadMediaAction => 'Upload Media';

  @override
  String get managePagesAction => 'Manage Pages';

  @override
  String get categoriesAction => 'Categories';

  @override
  String get contentTypesAction => 'Content Types';

  @override
  String get recentEntriesTitle => 'Recent Entries';

  @override
  String get totalEntriesStats => 'Total Entries';

  @override
  String get publishedStats => 'Published';

  @override
  String get draftsStats => 'Drafts';

  @override
  String get mediaFilesStats => 'Media Files';

  @override
  String get pagesStats => 'Pages';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get pageBuilderTitle => 'Page Builder';

  @override
  String get clearButton => 'Clear';

  @override
  String get paletteLabel => 'Palette';

  @override
  String get textPaletteItem => 'Text';

  @override
  String get buttonPaletteItem => 'Button';

  @override
  String get imagePaletteItem => 'Image';

  @override
  String get cardPaletteItem => 'Card';

  @override
  String get rowPaletteItem => 'Row';

  @override
  String get columnPaletteItem => 'Column';

  @override
  String get dividerPaletteItem => 'Divider';

  @override
  String get dragWidgetsHere => 'Drag widgets here';

  @override
  String get selectWidgetProperty => 'Select a widget\nto edit its properties';

  @override
  String get propertiesLabel => 'Properties';

  @override
  String get typeLabel => 'Type';

  @override
  String get labelLabel => 'Label';

  @override
  String get voiceModeTitle => 'Voice Mode';

  @override
  String get listeningStatus => 'Listening…';

  @override
  String get tapToSpeakPrompt => 'Tap to speak';

  @override
  String get startListeningPrompt => 'Start Listening';

  @override
  String get fuzzyAIListening => 'FuzzyAI is hearing you';

  @override
  String get recentCommandsTitle => 'Recent Commands';

  @override
  String get sqlBuilderTitle => 'SQL Visual Builder';

  @override
  String get copySqlButton => 'Copy SQL';

  @override
  String get saveAsTaskButton => 'Save as Task';

  @override
  String get sqlCopiedSnackbar => 'SQL copied to clipboard!';

  @override
  String get fromTableSection => '📋 FROM Table';

  @override
  String get selectColumnsSection => '📌 SELECT Columns';

  @override
  String get allColumnsSelected => 'All columns selected (*)';

  @override
  String get whereClausesSection => '🔍 WHERE Clauses';

  @override
  String get orderBySection => '⬇️ ORDER BY';

  @override
  String get chooseColumnDropdown => 'Choose column';

  @override
  String get noneOption => 'None';

  @override
  String get limitSection => '🔢 LIMIT';

  @override
  String get noLimitLabel => 'No limit';

  @override
  String limitRowsLabel(int count) {
    return '$count rows';
  }

  @override
  String get generatedSqlLabel => 'Generated SQL';

  @override
  String get previewBadge => 'PREVIEW';

  @override
  String get saveTaskTitle => 'Save SQL as Task';

  @override
  String get saveTaskMessage => 'Give this SQL query a name. It will be added to your Tasks as a To-Do item.';

  @override
  String get taskNameInputLabel => 'Task Name';

  @override
  String get sqlTaskNamePlaceholder => 'e.g. Get active users';

  @override
  String get createTaskButton => 'Create Task';

  @override
  String taskCreatedSnackbar(String name) {
    return 'Task \"$name\" created!';
  }

  @override
  String get chatTitle => 'FuzzyAI';

  @override
  String get clearChatButton => 'Clear chat';

  @override
  String get clearChatTooltip => 'Clear chat';

  @override
  String get messageFuzzyAI => 'Message FuzzyAI…';

  @override
  String get fuzzyAITyping => 'FuzzyAI is typing…';

  @override
  String get copiedSnackbar => 'Copied!';

  @override
  String get devModeTitle => 'Dev Mode';

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String get enableDevMode => 'Enable Dev Mode';

  @override
  String get disableDevMode => 'Disable Dev Mode';

  @override
  String get logsTab => 'Logs';

  @override
  String get stateTab => 'State';

  @override
  String get testsTab => 'Tests';

  @override
  String get extensionsTab => 'Extensions';

  @override
  String get clearLogsButton => 'Clear';

  @override
  String logEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get tasksStateCard => 'Tasks State';

  @override
  String get workflowsStateCard => 'Workflows State';

  @override
  String get pluginsStateCard => 'Plugins State';

  @override
  String get runAllTests => 'Run All Tests';

  @override
  String get runningTests => 'Running...';

  @override
  String testsPassed(int passed, int total) {
    return '$passed/$total passed';
  }

  @override
  String get extensionsEmpty => 'No extensions registered';

  @override
  String get extensionsEmptyHint => 'Call ExtensionRegistry.register() to add an extension.';

  @override
  String extensionRoutesSection(int count) => 'Routes ($count)';

  @override
  String extensionNavItemsSection(int count) => 'Nav items ($count)';

  @override
  String extensionPaletteItemsSection(int count) => 'Palette items ($count)';

  @override
  String extensionZonesSection(int count) => 'Zone contributions ($count)';

  @override
  String get luaExpressionBuilderTitle => 'Lua Expression Builder';

  @override
  String get luaSubtitle => 'Build boolean logic visually';

  @override
  String get luaDescription => 'Compose boolean expressions using AND, OR, NOT and comparison operators. The result is valid Lua code you can paste into your workflow scripts.';

  @override
  String get luaCopyButton => 'Copy';

  @override
  String get luaSaveAsTask => 'Save as Task';

  @override
  String get luaCopiedSnackbar => 'Lua expression copied!';

  @override
  String get luaTabBuilder => 'Builder';

  @override
  String get luaTabCode => 'Lua Code';

  @override
  String get saveLuaTaskTitle => 'Save Lua Expression as Task';

  @override
  String get saveLuaTaskMessage => 'Give this Lua expression a name. It will be added to your Tasks as a To-Do item.';

  @override
  String get luaTaskNameLabel => 'Task Name';

  @override
  String get luaTaskNameHint => 'e.g. Check user status condition';

  @override
  String get luaGeneratedCode => 'Generated Lua';

  @override
  String get luaLiveBadge => 'LIVE';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search tasks, workflows & plugins…';

  @override
  String noSearchResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchTasksSection => 'Tasks';

  @override
  String get searchWorkflowsSection => 'Workflows';

  @override
  String get searchPluginsSection => 'Plugins';

  @override
  String get searchCmsEntriesSection => 'CMS Entries';

  @override
  String get searchCmsPagesSection => 'CMS Pages';

  @override
  String get sidebarDashboard => 'Dashboard';

  @override
  String get sidebarTasks => 'Tasks';

  @override
  String get sidebarWorkflows => 'Workflows';

  @override
  String get sidebarPlugins => 'Plugins';

  @override
  String get sidebarMarketplace => 'Marketplace';

  @override
  String get sidebarSqlBuilder => 'SQL Builder';

  @override
  String get sidebarLuaBuilder => 'Lua Builder';

  @override
  String get sidebarSearch => 'Search';

  @override
  String get sidebarAiChat => 'AI Chat';

  @override
  String get sidebarVoice => 'Voice';

  @override
  String get sidebarDevMode => 'Dev Mode';

  @override
  String get sidebarSettings => 'Settings';

  @override
  String get sidebarPageBuilder => 'Page Builder';

  @override
  String get sidebarCms => 'CMS';

  @override
  String get sidebarCmsOverview => 'Overview';

  @override
  String get sidebarContentTypes => 'Content Types';

  @override
  String get sidebarEntries => 'Entries';

  @override
  String get sidebarMedia => 'Media';

  @override
  String get sidebarPages => 'Pages';

  @override
  String get sidebarCategories => 'Categories';

  @override
  String get loginSubtitle => 'Sign in to your workspace';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginCredentialsHint => 'Enter your credentials to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get signInButton => 'Sign In';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get signupSubtitle => 'Create your account';

  @override
  String get signupGetStarted => 'Get started';

  @override
  String get signupWorkspaceHint => 'Create your FuzzyBoard workspace';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Jane Doe';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get hasAccountPrompt => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String get configTitle => 'System Configuration';

  @override
  String get configAppNode => 'App';

  @override
  String get configSelectNode => 'Select a node';

  @override
  String get configSelectNodeHint => 'Tap any node to view\nand edit its configuration';

  @override
  String get configAppSaved => 'App config saved';

  @override
  String get configAppConfiguration => 'App Configuration';

  @override
  String get configGlobalSettings => 'Global application settings';

  @override
  String get configMaxConcurrency => 'Max Concurrency';

  @override
  String get configMaxConcurrencyHint => '10';

  @override
  String get configApiBaseUrl => 'API Base URL';

  @override
  String get configTimezone => 'Timezone';

  @override
  String get configTimezoneHint => 'UTC';

  @override
  String get configSaveChanges => 'Save Changes';

  @override
  String get configLogLevel => 'Log Level';

  @override
  String get configWorkerSaved => 'Worker saved';

  @override
  String get configWorkerName => 'Name';

  @override
  String get configWorkerConcurrency => 'Concurrency';

  @override
  String get configWorkerMaxRetries => 'Max Retries';

  @override
  String get configWorkerTimeout => 'Timeout (seconds)';

  @override
  String get configWorkerEndpoint => 'Endpoint';

  @override
  String get configWorkerStop => 'Stop';

  @override
  String get configWorkerStart => 'Start';

  @override
  String get configPluginNotInstalled => 'Not Installed';

  @override
  String get configPluginAuthor => 'Author';

  @override
  String get configPluginRating => 'Rating';

  @override
  String get configPluginDownloads => 'Downloads';

  @override
  String configPluginDownloadsValue(String count) {
    return '$count installs';
  }

  @override
  String get configPluginUninstall => 'Uninstall';
}

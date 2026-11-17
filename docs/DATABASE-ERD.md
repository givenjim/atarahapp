# Database ER diagram

Generated from `apps/backend/prisma/schema` by `pnpm --filter @atarah/backend db:erd` (98 tables). Do not edit by hand.
`users.id` also references `auth.users.id` in Supabase Auth (a foreign key created in SQL, not shown here).

```mermaid
erDiagram
  roles {
    String id PK
    RoleKey key UK
    String name
    String description
    Boolean isStaff
    DateTime createdAt
    DateTime updatedAt
  }
  permissions {
    String id PK
    String key UK
    String description
    Boolean isMemberDefault
    DateTime createdAt
    DateTime updatedAt
  }
  role_permissions {
    String roleId
    String permissionId
    DateTime createdAt
  }
  user_roles {
    String id PK
    String userId
    String roleId
    String grantedById
    DateTime grantedAt
    DateTime revokedAt
    DateTime createdAt
    DateTime updatedAt
  }
  profile_field_visibility {
    String userId
    ProfileField field
    Visibility visibility
    DateTime updatedAt
  }
  two_step_settings {
    String userId PK
    Boolean enabled
    DateTime enabledAt
    DateTime updatedAt
  }
  contact_change_requests {
    String id PK
    String userId
    ContactChangeKind kind
    String oldValue
    String newValue
    DateTime requestedAt
    DateTime completedAt
  }
  data_export_requests {
    String id PK
    String userId
    PrivacyRequestStatus status
    String fileMediaId
    DateTime requestedAt
    DateTime readyAt
    DateTime expiresAt
    String error
  }
  account_deletion_requests {
    String id PK
    String userId
    DeletionRequestStatus status
    DateTime requestedAt
    DateTime purgeAfter
    DateTime cancelledAt
    DateTime purgedAt
  }
  help_articles {
    String id PK
    String slug UK
    String title
    String summary
    Json body
    Int sortOrder
    Boolean published
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  faq_entries {
    String id PK
    String question
    String answer
    Int sortOrder
    Boolean published
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  notification_broadcasts {
    String id PK
    String title
    String body
    String deepLink
    NotificationCategory category
    BroadcastTarget target
    String targetValue
    DateTime scheduledAt
    BroadcastStatus status
    Int recipientCount
    DateTime sentAt
    String createdById
    DateTime createdAt
    DateTime updatedAt
  }
  analytics_events {
    String id
    DateTime occurredAt
    String name
    String actorHash
    Json props
  }
  analytics_daily_counts {
    DateTime date
    String name
    Int events
    Int actors
    DateTime updatedAt
  }
  posts {
    String id PK
    String authorId
    PostType type
    String body
    PostAudience audience
    String groupId
    PostStatus status
    Int reactionCount
    Int replyCount
    Boolean isStaffAnnouncement
    DateTime editedAt
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
    DateTime deletedAt
  }
  post_media {
    String id PK
    String postId
    String mediaAssetId
    Int sortOrder
    DateTime createdAt
  }
  post_links {
    String id PK
    String postId UK
    String url
    String title
    String description
    String image
    String siteName
    DateTime fetchedAt
    DateTime createdAt
    DateTime updatedAt
  }
  post_attachments {
    String id PK
    String postId
    String opportunityId
    DateTime createdAt
  }
  comments {
    String id PK
    String postId
    String authorId
    String parentCommentId
    String body
    PostStatus status
    DateTime editedAt
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
    DateTime deletedAt
  }
  reactions {
    String id PK
    String postId
    String userId
    DateTime createdAt
  }
  groups {
    String id PK
    String slug UK
    GroupType type
    String name
    String description
    String coverMediaId
    String disciplineId
    String countyId
    Boolean isOfficial
    GroupVisibility visibility
    Int memberCount
    String createdById
    DateTime archivedAt
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  group_memberships {
    String id PK
    String groupId
    String userId
    GroupRole role
    DateTime createdAt
    DateTime updatedAt
  }
  group_pins {
    String id PK
    String groupId
    String postId
    String pinnedById
    DateTime createdAt
  }
  blocks {
    String id PK
    String blockerId
    String blockedId
    DateTime createdAt
  }
  mutes {
    String id PK
    String userId
    MuteTargetType targetType
    String targetId
    DateTime createdAt
  }
  reports {
    String id PK
    String reporterId
    ReportTargetType targetType
    String targetId
    ReportReason reason
    String note
    ReportStatus status
    String caseId
    DateTime notifiedAt
    DateTime createdAt
    DateTime updatedAt
  }
  moderation_cases {
    String id PK
    ReportTargetType targetType
    String targetId
    String targetAuthorId
    ReportStatus status
    ModerationPriority priority
    String assigneeId
    Int reportCount
    ReportReason topReason
    DateTime resolvedAt
    DateTime alertedAt
    DateTime createdAt
    DateTime updatedAt
  }
  moderation_actions {
    String id PK
    String caseId
    ModerationAction action
    String reason
    String actorId
    ReportTargetType targetType
    String targetId
    DateTime createdAt
  }
  community_restrictions {
    String id PK
    String userId
    String reason
    String restrictedById
    DateTime expiresAt
    DateTime liftedAt
    DateTime createdAt
  }
  articles {
    String id PK
    String slug UK
    String title
    String summary
    Json body
    String heroMediaId
    String authorName
    ContentSource source
    String sourceLabel
    Int readMinutes
    ArticleStatus status
    DateTime publishedAt
    String tags
    String createdById
    String updatedById
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  saved_items {
    String id PK
    String userId
    SavedItemType type
    String targetId
    String collection
    DateTime createdAt
  }
  recent_searches {
    String id PK
    String userId
    String query
    String normalized
    DateTime usedAt
  }
  home_config {
    String id PK
    String featuredArticleId
    String updatedById
    DateTime updatedAt
  }
  creative_verifications {
    String profileId PK
    VerificationStatus status
    DateTime verifiedAt
    DateTime createdAt
    DateTime updatedAt
  }
  creative_profiles {
    String id PK
    String userId UK
    String handle UK
    String displayName
    String headline
    String bio
    String primaryDisciplineId
    String countryId
    String countyId
    String town
    Visibility locationVisibility
    String avatarMediaId
    OnboardingStep onboardingStep
    DateTime onboardingCompletedAt
    Int completionPercent
    Boolean openToCommissions
    Boolean contactShowEmail
    Boolean contactShowPhone
    Boolean contactForConnections
    Boolean acceptConnections
    DateTime createdAt
    DateTime updatedAt
  }
  creative_disciplines {
    String profileId
    String disciplineId
    Boolean isPrimary
    DateTime createdAt
  }
  creative_specialisations {
    String profileId
    String specialisationId
    DateTime createdAt
  }
  creative_skills {
    String profileId
    String skillId
    SkillLevel level
    SkillSource source
    DateTime createdAt
  }
  creative_interests {
    String profileId
    String interestId
    DateTime createdAt
  }
  creative_development_areas {
    String profileId
    String developmentAreaId
    DateTime createdAt
  }
  specialisation_suggestions {
    String id PK
    String userId
    String disciplineId
    String name
    SuggestionStatus status
    String specialisationId
    String resolvedById
    String resolutionNote
    DateTime resolvedAt
    DateTime createdAt
    DateTime updatedAt
  }
  creative_passports {
    String id PK
    String profileId UK
    String passportNumber UK
    String countyCode
    Int sequence
    DateTime createdAt
    DateTime updatedAt
  }
  passport_counters {
    String countyCode PK
    Int lastValue
    DateTime updatedAt
  }
  profile_section_visibility {
    String profileId
    ProfileSection section
    Visibility visibility
    DateTime updatedAt
  }
  profile_links {
    String id PK
    String profileId
    String label
    String url
    Int sortOrder
    DateTime createdAt
    DateTime updatedAt
  }
  connections {
    String id PK
    String requesterId
    String addresseeId
    ConnectionStatus status
    DateTime respondedAt
    DateTime createdAt
    DateTime updatedAt
  }
  users {
    String id PK
    String email UK
    String phone UK
    DateTime emailVerifiedAt
    DateTime phoneVerifiedAt
    String fullName
    AccountStatus status
    String statusReason
    DateTime statusChangedAt
    DateTime suspendedUntil
    DateTime lastLoginAt
    Boolean isDemo
    DateTime deletedAt
    DateTime createdAt
    DateTime updatedAt
  }
  member_preferences {
    String id PK
    String userId UK
    Appearance appearance
    String locale
    String timeZone
    Boolean marketingOptIn
    DateTime createdAt
    DateTime updatedAt
  }
  consent_records {
    String id PK
    String userId
    LegalDocumentType documentType
    String version
    DateTime acceptedAt
    String ip
    String source
    DateTime createdAt
    DateTime updatedAt
  }
  legal_documents {
    String id PK
    LegalDocumentType type
    String version
    String title
    String body
    PublicationStatus status
    DateTime effectiveAt
    DateTime createdAt
    DateTime updatedAt
  }
  user_devices {
    String id PK
    String userId
    String deviceHash
    String name
    DevicePlatform platform
    String lastSessionId
    DateTime lastSeenAt
    DateTime verifiedAt
    DateTime createdAt
    DateTime updatedAt
  }
  learning_contents {
    String id PK
    String slug UK
    LearningContentType type
    String title
    String summary
    String categoryId
    SkillLevel level
    Int durationMinutes
    ContentSource source
    ContentDelivery delivery
    String providerName
    String instructorUserId
    String externalUrl
    String embedUrl
    String coverMediaId
    LearningAccess access
    PublicationStatus status
    DateTime publishedAt
    Boolean featured
    Json whatYouLearn
    String whoItsFor
    LinkStatus linkStatus
    DateTime lastCheckedAt
    String createdById
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  learning_content_disciplines {
    String contentId
    String disciplineId
    DateTime createdAt
  }
  learning_content_skills {
    String contentId
    String skillId
    DateTime createdAt
  }
  courses {
    String contentId PK
    Int lessonCount
    Int totalMinutes
    Boolean sequential
  }
  lessons {
    String id PK
    String courseId
    Int sequence
    String title
    Int durationMinutes
    String videoMediaId
    String embedUrl
    Json body
    String practicePrompt
    String practiceSkillId
    DateTime createdAt
    DateTime updatedAt
  }
  enrolments {
    String id PK
    String userId
    String courseId
    DateTime enrolledAt
    DateTime completedAt
  }
  lesson_progress {
    String id PK
    String userId
    String lessonId
    LessonProgressStatus status
    Int lastPositionSeconds
    DateTime completedAt
    DateTime createdAt
    DateTime updatedAt
  }
  content_progress {
    String id PK
    String userId
    String contentId
    LessonProgressStatus status
    DateTime startedAt
    DateTime completedAt
    DateTime updatedAt
  }
  learning_activity_daily {
    String userId
    DateTime date
    Int minutes
  }
  certificates {
    String id PK
    String userId
    String courseId
    String certificateNumber UK
    DateTime issuedAt
    String achievementId
  }
  learning_progress_overrides {
    String id PK
    String userId
    String courseId
    String lessonId
    String action
    String reason
    String actorId
    DateTime createdAt
  }
  media_assets {
    String id PK
    String ownerId
    MediaKind kind
    StorageBucket bucket
    String objectKey
    String mimeType
    BigInt sizeBytes
    MediaStatus status
    Int width
    Int height
    Int durationSeconds
    Json variants
    String checksum
    String rejectionReason
    DateTime deletedAt
    DateTime createdAt
    DateTime updatedAt
  }
  notifications {
    String id PK
    String userId
    NotificationCategory category
    String title
    String body
    String type
    String deepLink
    Json data
    DateTime readAt
    DateTime createdAt
    DateTime updatedAt
  }
  notification_preferences {
    String id PK
    String userId
    NotificationCategory category
    Boolean pushEnabled
    Boolean emailEnabled
    DateTime createdAt
    DateTime updatedAt
  }
  device_tokens {
    String id PK
    String userId
    String token UK
    DevicePlatform platform
    String appVersion
    DateTime lastSeenAt
    DateTime revokedAt
    DateTime createdAt
    DateTime updatedAt
  }
  notification_dispatches {
    String id PK
    String dedupeKey UK
    String userId
    String channel
    DateTime createdAt
    DateTime updatedAt
  }
  membership_plans {
    String id PK
    MembershipPlanKey key UK
    String name
    String description
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  entitlements {
    String id PK
    EntitlementKey key UK
    String description
    DateTime createdAt
    DateTime updatedAt
  }
  membership_entitlements {
    String planId
    String entitlementId
    DateTime createdAt
  }
  memberships {
    String id PK
    String userId
    String planId
    MembershipSource source
    MembershipStatus status
    DateTime startsAt
    DateTime currentPeriodEnd
    DateTime cancelledAt
    String grantedById
    String note
    Int version
    DateTime createdAt
    DateTime updatedAt
  }
  opportunity_providers {
    String id PK
    String name
    OpportunityProviderType type
    String logoMediaId
    String website
    VerificationStatus verificationStatus
    String ownerUserId
    Int opportunitiesCount
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  opportunities {
    String id PK
    String providerId
    String slug UK
    OpportunityType type
    String title
    String summary
    String about
    Json requirements
    Json benefits
    BigInt valueMinMinor
    BigInt valueMaxMinor
    String valueCurrency
    String valueText
    DateTime deadlineAt
    String countryId
    String countyId
    WorkMode workMode
    ApplicationMethod applicationMethod
    String applicationUrl
    String applicationEmail
    String applicationDomain
    OpportunityTrust trust
    OpportunityStatus status
    DateTime featuredUntil
    Boolean isPublic
    String sourceUrl
    DateTime importedAt
    DateTime lastCheckedAt
    LinkStatus linkStatus
    DateTime publishedAt
    String createdById
    Boolean isDemo
    DateTime createdAt
    DateTime updatedAt
  }
  opportunity_disciplines {
    String opportunityId
    String disciplineId
    DateTime createdAt
  }
  opportunity_requirement_rules {
    String id PK
    String opportunityId
    OpportunityRuleType ruleType
    Json params
    String label
    Boolean isBlocking
    Int sortOrder
    DateTime createdAt
    DateTime updatedAt
  }
  opportunity_trackings {
    String id PK
    String userId
    String opportunityId
    OpportunityTrackingStatus status
    DateTime savedAt
    DateTime appliedAt
    DateTime completedAt
    OpportunityOutcome outcome
    Json checklist
    String notes
    DateTime createdAt
    DateTime updatedAt
  }
  external_link_checks {
    String id PK
    String opportunityId
    String url
    DateTime checkedAt
    Int httpStatus
    LinkStatus result
    String error
  }
  projects {
    String id PK
    String profileId
    String title
    String role
    String client
    DateTime projectDate
    ProjectCategory category
    String disciplineId
    String description
    String outcome
    Boolean featured
    PublicationStatus status
    Visibility visibility
    DateTime publishedAt
    DateTime hiddenAt
    String hiddenReason
    String hiddenById
    DateTime deletedAt
    DateTime createdAt
    DateTime updatedAt
  }
  project_media {
    String projectId
    String mediaId
    Int sortOrder
    String caption
    DateTime createdAt
  }
  project_skills {
    String projectId
    String skillId
  }
  project_links {
    String id PK
    String projectId
    String label
    String url
    Int sortOrder
    DateTime createdAt
  }
  project_collaborators {
    String id PK
    String projectId
    String userId
    String name
    String role
    CollaboratorStatus status
    DateTime createdAt
    DateTime updatedAt
  }
  experiences {
    String id PK
    String profileId
    String title
    String organisation
    String location
    DateTime startDate
    DateTime endDate
    Boolean current
    String description
    DateTime createdAt
    DateTime updatedAt
  }
  achievements {
    String id PK
    String profileId
    AchievementType type
    String title
    String issuer
    DateTime achievedOn
    String description
    String url
    AchievementSource source
    DateTime createdAt
    DateTime updatedAt
  }
  profile_services {
    String id PK
    String profileId
    String title
    String description
    PricingType priceType
    Int priceMin
    Int priceMax
    String currency
    ProfileServiceStatus status
    Int sortOrder
    DateTime createdAt
    DateTime updatedAt
  }
  audit_logs {
    String id PK
    String actorId
    AuditActorType actorType
    String action
    String entityType
    String entityId
    Json before
    Json after
    String ip
    String requestId
    DateTime createdAt
  }
  platform_settings {
    String id PK
    String key UK
    Json value
    String description
    String updatedById
    DateTime createdAt
    DateTime updatedAt
  }
  feature_flags {
    String id PK
    String key UK
    String description
    Boolean enabled
    Int phase
    String updatedById
    DateTime createdAt
    DateTime updatedAt
  }
  countries {
    String id PK
    String isoCode UK
    String name
    String callingCode
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  counties {
    String id PK
    String countryId
    String code
    String name
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  towns {
    String id PK
    String countyId
    String name
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  disciplines {
    String id PK
    String slug UK
    String name
    String icon
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  specialisations {
    String id PK
    String disciplineId
    String slug
    String name
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  skills {
    String id PK
    String slug UK
    String name
    String disciplineId
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  interests {
    String id PK
    String slug UK
    String name
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  development_areas {
    String id PK
    String slug UK
    String name
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  learning_categories {
    String id PK
    String slug UK
    String name
    LearningCategoryGroup group
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  marketplace_categories {
    String id PK
    String slug UK
    String name
    String icon
    String tone
    Int sortOrder
    Boolean isActive
    DateTime createdAt
    DateTime updatedAt
  }
  roles ||--o{ role_permissions : "role"
  permissions ||--o{ role_permissions : "permission"
  users ||--o{ user_roles : "user"
  roles ||--o{ user_roles : "role"
  users |o--o{ user_roles : "grantedBy"
  users ||--o{ profile_field_visibility : "user"
  users ||--o{ two_step_settings : "user"
  users ||--o{ contact_change_requests : "user"
  users ||--o{ data_export_requests : "user"
  media_assets |o--o{ data_export_requests : "fileMedia"
  users |o--o{ notification_broadcasts : "createdBy"
  users ||--o{ posts : "author"
  groups |o--o{ posts : "group"
  posts ||--o{ post_media : "post"
  media_assets ||--o{ post_media : "mediaAsset"
  posts ||--o{ post_links : "post"
  posts ||--o{ post_attachments : "post"
  opportunities |o--o{ post_attachments : "opportunity"
  posts ||--o{ comments : "post"
  users ||--o{ comments : "author"
  comments |o--o{ comments : "parent"
  posts ||--o{ reactions : "post"
  users ||--o{ reactions : "user"
  media_assets |o--o{ groups : "coverMedia"
  disciplines |o--o{ groups : "discipline"
  counties |o--o{ groups : "county"
  users |o--o{ groups : "createdBy"
  groups ||--o{ group_memberships : "group"
  users ||--o{ group_memberships : "user"
  groups ||--o{ group_pins : "group"
  posts ||--o{ group_pins : "post"
  users |o--o{ group_pins : "pinnedBy"
  users ||--o{ blocks : "blocker"
  users ||--o{ blocks : "blocked"
  users ||--o{ mutes : "user"
  users ||--o{ reports : "reporter"
  moderation_cases |o--o{ reports : "case"
  users |o--o{ moderation_cases : "assignee"
  moderation_cases ||--o{ moderation_actions : "case"
  users ||--o{ community_restrictions : "user"
  media_assets |o--o{ articles : "heroMedia"
  users ||--o{ articles : "createdBy"
  users |o--o{ articles : "updatedBy"
  users ||--o{ saved_items : "user"
  users ||--o{ recent_searches : "user"
  articles |o--o{ home_config : "featuredArticle"
  users |o--o{ home_config : "updatedBy"
  creative_profiles ||--o{ creative_verifications : "profile"
  users ||--o{ creative_profiles : "user"
  disciplines |o--o{ creative_profiles : "primaryDiscipline"
  countries |o--o{ creative_profiles : "country"
  counties |o--o{ creative_profiles : "county"
  media_assets |o--o{ creative_profiles : "avatarMedia"
  creative_profiles ||--o{ creative_disciplines : "profile"
  disciplines ||--o{ creative_disciplines : "discipline"
  creative_profiles ||--o{ creative_specialisations : "profile"
  specialisations ||--o{ creative_specialisations : "specialisation"
  creative_profiles ||--o{ creative_skills : "profile"
  skills ||--o{ creative_skills : "skill"
  creative_profiles ||--o{ creative_interests : "profile"
  interests ||--o{ creative_interests : "interest"
  creative_profiles ||--o{ creative_development_areas : "profile"
  development_areas ||--o{ creative_development_areas : "developmentArea"
  users ||--o{ specialisation_suggestions : "user"
  users |o--o{ specialisation_suggestions : "resolvedBy"
  disciplines ||--o{ specialisation_suggestions : "discipline"
  specialisations |o--o{ specialisation_suggestions : "specialisation"
  creative_profiles ||--o{ creative_passports : "profile"
  creative_profiles ||--o{ profile_section_visibility : "profile"
  creative_profiles ||--o{ profile_links : "profile"
  users ||--o{ connections : "requester"
  users ||--o{ connections : "addressee"
  users ||--o{ member_preferences : "user"
  users ||--o{ consent_records : "user"
  users ||--o{ user_devices : "user"
  learning_categories ||--o{ learning_contents : "category"
  users |o--o{ learning_contents : "instructor"
  media_assets |o--o{ learning_contents : "coverMedia"
  users |o--o{ learning_contents : "createdBy"
  learning_contents ||--o{ learning_content_disciplines : "content"
  disciplines ||--o{ learning_content_disciplines : "discipline"
  learning_contents ||--o{ learning_content_skills : "content"
  skills ||--o{ learning_content_skills : "skill"
  learning_contents ||--o{ courses : "content"
  courses ||--o{ lessons : "course"
  media_assets |o--o{ lessons : "videoMedia"
  skills |o--o{ lessons : "practiceSkill"
  users ||--o{ enrolments : "user"
  courses ||--o{ enrolments : "course"
  users ||--o{ lesson_progress : "user"
  lessons ||--o{ lesson_progress : "lesson"
  users ||--o{ content_progress : "user"
  learning_contents ||--o{ content_progress : "content"
  users ||--o{ learning_activity_daily : "user"
  users ||--o{ certificates : "user"
  courses ||--o{ certificates : "course"
  achievements |o--o{ certificates : "achievement"
  users |o--o{ media_assets : "owner"
  users ||--o{ notifications : "user"
  users ||--o{ notification_preferences : "user"
  users ||--o{ device_tokens : "user"
  membership_plans ||--o{ membership_entitlements : "plan"
  entitlements ||--o{ membership_entitlements : "entitlement"
  users ||--o{ memberships : "user"
  membership_plans ||--o{ memberships : "plan"
  media_assets |o--o{ opportunity_providers : "logoMedia"
  users |o--o{ opportunity_providers : "owner"
  opportunity_providers ||--o{ opportunities : "provider"
  countries |o--o{ opportunities : "country"
  counties |o--o{ opportunities : "county"
  users |o--o{ opportunities : "createdBy"
  opportunities ||--o{ opportunity_disciplines : "opportunity"
  disciplines ||--o{ opportunity_disciplines : "discipline"
  opportunities ||--o{ opportunity_requirement_rules : "opportunity"
  users ||--o{ opportunity_trackings : "user"
  opportunities ||--o{ opportunity_trackings : "opportunity"
  opportunities ||--o{ external_link_checks : "opportunity"
  creative_profiles ||--o{ projects : "profile"
  disciplines |o--o{ projects : "discipline"
  projects ||--o{ project_media : "project"
  media_assets ||--o{ project_media : "media"
  projects ||--o{ project_skills : "project"
  skills ||--o{ project_skills : "skill"
  projects ||--o{ project_links : "project"
  projects ||--o{ project_collaborators : "project"
  users |o--o{ project_collaborators : "user"
  creative_profiles ||--o{ experiences : "profile"
  creative_profiles ||--o{ achievements : "profile"
  creative_profiles ||--o{ profile_services : "profile"
  countries ||--o{ counties : "country"
  counties ||--o{ towns : "county"
  disciplines ||--o{ specialisations : "discipline"
  disciplines |o--o{ skills : "discipline"
```

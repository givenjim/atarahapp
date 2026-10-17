# Atarah — Domain vocabulary and entities

Source of truth for names and values: `docs/MASTER_PROMPT.md` §6. The Prisma schema (`apps/backend/prisma/schema/`) implements it; the enum values below are the exact values stored in PostgreSQL (verified by `test/database.int-spec.ts`).

**Naming rule (DEC-014).** Where the prompt's enum name collides with an entity of the same name, the Prisma enum gets a `Key` suffix: `RoleKey`, `MembershipPlanKey`, `EntitlementKey`. Values are unchanged.

## 1. Authorisation model

Effective access = **account status + roles + membership/entitlements + verification + ownership + visibility + platform policy (feature flags)**, evaluated on the backend on every request. Never a single `user.role`.

| Concept                | Stored as                                                                         | Notes                                                                                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Account status         | `User.status` (`AccountStatus`)                                                   | Can the person use Atarah at all.                                                                                                                             |
| Roles                  | `UserRole` rows (`RoleKey`), additive, `revokedAt` keeps history                  | Every ACTIVE account is implicitly a member; that is **not** a role.                                                                                          |
| Permissions            | `Permission` (`resource.action`), `RolePermission`; `isMemberDefault` for members | Capabilities, not screens.                                                                                                                                    |
| Membership             | `Membership` → `MembershipPlan` (`FREE`, `PRO`)                                   | One live (ACTIVE/PAST_DUE) membership per user (partial unique index).                                                                                        |
| Entitlements           | `MembershipEntitlement` (plan → entitlement)                                      | `MENTORSHIP_BOOKING`, `CREATIVE_VERIFICATION`, `SKILL_VERIFICATION`, `REDUCED_MARKETPLACE_FEES`, `PREMIUM_CONTENT`. Premium and Verified are **never** roles. |
| Verification           | `VerificationStatus` on cases (P2-M6)                                             | Attribute of an identity, skill, mentor, seller or provider.                                                                                                  |
| Ownership / visibility | per resource; `Visibility` = `PUBLIC` / `MEMBERS` / `PRIVATE`                     | Field-level filtering happens in the service layer before data leaves the API.                                                                                |

Role capabilities (seeded; §6.1 applied over the Roles & Permissions Matrix):

| Role                 | Staff | Highlights                                                                                                                                       |
| -------------------- | :---: | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| MENTOR               |   –   | Own mentor profile, availability, session types, booking requests.                                                                               |
| SELLER               |   –   | Create and manage own listings, answer enquiries.                                                                                                |
| OPPORTUNITY_PROVIDER |   –   | Submit and manage own opportunities (cannot set trust badges).                                                                                   |
| INSTRUCTOR           |   –   | Manage assigned learning content.                                                                                                                |
| MODERATOR            |   ✓   | Reports and community content only. No payments, roles, memberships or private account data.                                                     |
| CONTENT_ADMIN        |   ✓   | Articles, learning, help, legal, categories, media, creative economy, taxonomy. **Not** opportunities or verification decisions.                 |
| PLATFORM_ADMIN       |   ✓   | Users, memberships, opportunities and their verification, mentors, sellers, verification cases, marketplace, settings. **Not** `payment.manage`. |
| SUPER_ADMIN          |   ✓   | Every permission, including roles, permissions, admin accounts, security, emergency controls, `payment.manage`.                                  |

Rules: nobody can grant themselves a role, verify their own skill or verify their own opportunity. Admin accounts require TOTP and re-authentication for sensitive actions (P0-M5).

## 2. Baseline entities (P0-M4)

| Entity                                                                 | Module                | Table                                                                        | Key relationships and rules                                                                                            |
| ---------------------------------------------------------------------- | --------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `User`                                                                 | identity              | `users`                                                                      | `email` (citext, unique) and/or `phone` (E.164, unique); CHECK at least one. `status`, `isDemo`, `deletedAt`.          |
| `Credential`                                                           | identity              | `credentials`                                                                | 1:1 User. Argon2id hash only.                                                                                          |
| `Session`                                                              | identity              | `sessions`                                                                   | Refresh-token generations; `familyId` groups a rotation chain; powers "Active sessions".                               |
| `VerificationCode`                                                     | identity              | `verification_codes`                                                         | Hashed one-time codes by `CodePurpose`/`CodeChannel`; `attempts`, `consumedAt`.                                        |
| `ConsentRecord`                                                        | identity              | `consent_records`                                                            | Document type + version + timestamp (Data Protection Act).                                                             |
| `LegalDocument`                                                        | identity              | `legal_documents`                                                            | `(type, version)` unique. Placeholders are DRAFT and titled "DRAFT — pending legal review".                            |
| `Role`, `Permission`, `RolePermission`, `UserRole`                     | access                | `roles`, `permissions`, `role_permissions`, `user_roles`                     | `RolePermission` composite PK; deleting a role in use is blocked (`Restrict`).                                         |
| `MembershipPlan`, `Entitlement`, `MembershipEntitlement`, `Membership` | membership            | `membership_plans`, `entitlements`, `membership_entitlements`, `memberships` | Price lives in `PlatformSetting` (`membership.pro.price_minor`). `Membership.version` for optimistic concurrency.      |
| `Country` → `County` → `Town`                                          | creative-economy      | `countries`, `counties`, `towns`                                             | County `code` is 3 upper-case letters, unique per country, used in `ATR-{CODE}-{seq}`. Never hard-code Kenya in logic. |
| `Discipline`, `Specialisation`, `Skill`, `Interest`, `DevelopmentArea` | creative              | `disciplines`, `specialisations`, `skills`, `interests`, `development_areas` | Slug-keyed; admin-managed after seed. `Skill.disciplineId` null = general skill.                                       |
| `LearningCategory`, `MarketplaceCategory`                              | content / marketplace | `learning_categories`, `marketplace_categories`                              | Seeded now; content, courses and listings reference them from P1-M8 and P2-M3.                                         |
| `MediaAsset`                                                           | media                 | `media_assets`                                                               | `(bucket, objectKey)` unique; buckets `PUBLIC`/`PRIVATE`/`EVIDENCE`; `status` lifecycle; variants JSON.                |
| `Notification`, `NotificationPreference`, `DeviceToken`                | notifications         | `notifications`, `notification_preferences`, `device_tokens`                 | Preferences unique per `(userId, category)`; absence means default (on).                                               |
| `PlatformSetting`, `FeatureFlag`                                       | admin                 | `platform_settings`, `feature_flags`                                         | Settings: JSON values, cached. Flags: kebab-case keys, `phase` recorded.                                               |
| `AuditLog`                                                             | audit                 | `audit_logs`                                                                 | **Append-only**: trigger rejects UPDATE/DELETE/TRUNCATE. No `updatedAt` by design.                                     |

Conventions: UUID keys; `createdAt`/`updatedAt` everywhere (except `audit_logs`); lifecycles are enums; money is integer minor units + ISO-4217 code; times are UTC, displayed in the user's time zone (default `Africa/Nairobi`, "EAT").

## 3. Canonical vocabulary

All enums below exist in the database now (`enums.prisma`, `identity.prisma`, `media-notifications.prisma`).

### 6.1 Accounts, roles, membership

- `AccountStatus`: PENDING_VERIFICATION, ACTIVE, SUSPENDED, DEACTIVATED, DELETED
- `RoleKey`: MENTOR, SELLER, OPPORTUNITY_PROVIDER, INSTRUCTOR, MODERATOR, CONTENT_ADMIN, PLATFORM_ADMIN, SUPER_ADMIN
- `MembershipPlanKey`: FREE ("Free"), PRO ("Atarah Pro") — price **KES 1,200 / month** from settings
- `MembershipSource`: PAID, SCHOLARSHIP, ADMIN_GRANT, PARTNER
- `MembershipStatus`: ACTIVE, PAST_DUE, CANCELLED (active until period end), EXPIRED
- `EntitlementKey`: MENTORSHIP_BOOKING, CREATIVE_VERIFICATION, SKILL_VERIFICATION, REDUCED_MARKETPLACE_FEES, PREMIUM_CONTENT

### 6.2 Identity and visibility

- `Visibility`: PUBLIC ("Public"), MEMBERS ("Members only"), PRIVATE ("Private"). **Defaults for new accounts:** identity, bio, portfolio, skills `PUBLIC`; experience and location `MEMBERS`; contact details `PRIVATE`; activity `PRIVATE`.
- `PublicationStatus`: DRAFT, IN_REVIEW, PUBLISHED, ARCHIVED
- `SkillLevel`: BEGINNER, INTERMEDIATE, ADVANCED, EXPERT (4-segment bar 1–4)
- `SkillSource`: SELF_DECLARED, LEARNING, VERIFIED
- `VerificationStatus`: NOT_SUBMITTED, SUBMITTED ("Application submitted"), UNDER_REVIEW ("Under review"), VERIFIED, REJECTED, EXPIRED, REVOKED. A skill with no case shows "Self-declared"; SUBMITTED and UNDER_REVIEW both show "Under review".
- `GrowthStrength`: EARLY, GROWING, ACTIVE, STRONG
- `CreativeDocumentFormat`: CV, BIO, EPK, DECK

### 6.3 Opportunities

- `OpportunityType`: GRANT, FUNDING, JOB, INTERNSHIP, GIG, COMPETITION, FESTIVAL, PARTNERSHIP, FELLOWSHIP, RESIDENCY, PROGRAMME
- `OpportunityTrust`: VERIFIED ("Verified by Atarah"), SOURCE_CONFIRMED ("Source confirmed"), EXTERNAL_SOURCE ("External source")
- `OpportunityStatus`: DRAFT, PENDING_REVIEW, PUBLISHED, CLOSED, EXPIRED, ARCHIVED, REMOVED
- `ApplicationMethod`: EXTERNAL_WEBSITE, EMAIL, IN_APP (reserved)
- `OpportunityTrackingStatus`: SAVED, IN_PROGRESS, APPLIED, COMPLETED
- `OpportunityOutcome`: AWARDED, NOT_SELECTED, WITHDRAWN, UNKNOWN
- "Closing soon": deadline within 14 days and not applied/completed. Urgency: ≤ 7 days pink, 8–14 days orange.

### 6.4 Learning and content

- `ContentSource`: ATARAH, PARTNER, EXTERNAL · `ContentDelivery`: NATIVE, EMBEDDED, EXTERNAL_LINK
- `LearningContentType`: COURSE, TUTORIAL, TOOLKIT, WEBINAR, MASTERCLASS, ARTICLE
- `LearningCategoryGroup`: CREATIVE, BUSINESS, PROFESSIONAL
- `LessonProgressStatus`: NOT_STARTED, IN_PROGRESS, COMPLETED ("locked" is computed, never stored)

### 6.5 Community

- `PostType`: UPDATE, QUESTION, DISCUSSION, COLLABORATION, ANNOUNCEMENT (staff only)
- `PostAudience`: PUBLIC, MEMBERS, CONNECTIONS, GROUP · `GroupType`: DISCIPLINE, LOCATION, INTEREST, PROGRAMME
- `ConnectionStatus`: PENDING, ACCEPTED, DECLINED, REMOVED (blocking is a separate `Block` record)
- `ReportReason`: INAPPROPRIATE, HARASSMENT, SCAM, MISLEADING, IMPERSONATION, IP_INFRINGEMENT, OTHER
- `ReportStatus`: SUBMITTED, IN_REVIEW, RESOLVED, DISMISSED, ESCALATED
- `ModerationAction`: NO_ACTION, WARN_USER, HIDE_CONTENT, REMOVE_CONTENT, RESTORE_CONTENT, RESTRICT_ACCOUNT, SUSPEND_ACCOUNT, ESCALATE

### 6.6 Marketplace and mentorship

- `ListingType`: SERVICE, PRODUCT · `PricingType`: FIXED, RANGE, ON_REQUEST
- `ListingStatus`: DRAFT, UNDER_REVIEW, PUBLISHED, REJECTED, SUSPENDED, ARCHIVED
- `ProfileServiceStatus`: PROFILE_ONLY, ON_MARKETPLACE · `EnquiryStatus`: NEW, REPLIED, CLOSED
- `MentorSessionFormat`: VIDEO_CALL (MVP), IN_PERSON (later)
- `BookingStatus`: PENDING_PAYMENT, CONFIRMED, COMPLETED, CANCELLED_BY_MENTEE, CANCELLED_BY_MENTOR, DECLINED_BY_MENTOR, NO_SHOW, PAYMENT_FAILED
- **Booking rule:** a session in a published slot is confirmed automatically once payment is verified. The mentor's Accept acknowledges it; Decline cancels with an automatic full refund. Mentee cancellation: free up to 24 h before, 50 % refunded after (settings, not code).

### 6.7 Payments and notifications

- `PaymentMethod`: MPESA, CARD · `PaymentPurpose`: MEMBERSHIP, MENTORSHIP, VERIFICATION, OTHER
- `PaymentStatus`: INITIATED, PENDING, SUCCEEDED, FAILED, CANCELLED, REFUNDED, PARTIALLY_REFUNDED — only verified provider confirmation moves a payment to SUCCEEDED.
- `NotificationCategory`: OPPORTUNITIES, MENTORSHIP, COMMUNITY, LEARNING, PROFILE, MARKETPLACE, SYSTEM (payments, membership, security and account notices are SYSTEM)

### Infrastructure enums (baseline schema)

`SessionClient` (ANDROID, IOS, WEB, ADMIN) · `CodeChannel` (EMAIL, SMS) · `CodePurpose` (REGISTRATION, PASSWORD_RESET, TWO_STEP, CHANGE_EMAIL, CHANGE_PHONE) · `LegalDocumentType` (TERMS, PRIVACY, COMMUNITY_GUIDELINES, PAYMENTS_REFUNDS, SELLER_TERMS, MENTOR_TERMS) · `MediaKind` · `StorageBucket` (PUBLIC, PRIVATE, EVIDENCE) · `MediaStatus` · `DevicePlatform` · `AuditActorType` (USER, ADMIN, SYSTEM).

## 4. Taxonomies (seeded, admin-managed afterwards)

- **Disciplines (12) and icons:** Music `music`, Acting `drama`, Dance `person-standing`, Writing `pen-line`, Fashion `shirt`, Visual Art `palette`, Photography `camera`, Film / Video `clapperboard`, Design `pen-tool`, Animation `aperture`, Production `sliders-vertical`, Entrepreneur `lightbulb`.
- **Specialisations (54)**, **skills (8)**, **interests (6)**, **areas to develop (5):** exactly the lists in the prototype (`AtarahEntry.dc.html`). Skills are general until admins add discipline-specific ones.
- **Learning categories (15):** Creative (7), Business (4), Professional (4). **Marketplace categories (8)** with icon and design-token tone.
- **Locations:** Country → County/Region → Town. Kenya and all 47 counties seeded; towns are admin-managed.
- **Creative Passport ID:** `ATR-{COUNTY CODE}-{zero-padded sequence}`, generated once at onboarding completion, never changed (e.g. `ATR-NBI-0042`). The prototype's `ATR-NBO-0042` is a sample inconsistency (section 6.8).

## 5. Entities added by later milestones

| Milestone | Entities                                                                                                                                                                                                                         |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| P0-M5     | Admin TOTP secrets and recovery codes, idempotency keys                                                                                                                                                                          |
| P1-M2     | `CreativeProfile`, `CreativeDiscipline`, `CreativeSpecialisation`, `CreativeSkill`, `CreativeInterest`, `CreativeDevelopmentArea`, `SpecialisationSuggestion`, `CreativePassport` (+ profile completion weights documented here) |
| P1-M3     | `ProfileSectionVisibility`, `ProfileLink`, `Connection` (+ growth formulas documented here)                                                                                                                                      |
| P1-M4     | `Project`, `ProjectMedia`, `ProjectSkill`, `ProjectCollaborator`, `Experience`, `Achievement`, `ProfileService`                                                                                                                  |
| P1-M5     | `Article`, search documents, `RecentSearch`                                                                                                                                                                                      |
| P1-M6     | `Post`, `Comment`, `Reaction`, `Group`, `GroupMembership`, `Block`, `Mute`, `Report`, `ModerationCase`, `ModerationActionLog`                                                                                                    |
| P1-M7     | `OpportunityProvider`, `Opportunity`, `OpportunityRequirementRule`, `OpportunityTracking`, `ExternalLinkCheck`                                                                                                                   |
| P1-M8     | `LearningContent`, `Course`, `Lesson`, `Enrolment`, `LessonProgress`, `ContentProgress`, `Certificate`                                                                                                                           |
| P1-M9     | `SavedItem`, `HelpArticle`, `FaqEntry`, `DataExportRequest`, `AccountDeletionRequest`, `TwoStepSetting`                                                                                                                          |
| P2        | `Payment`, `PaymentEvent`, `Refund`, `Transaction`, `Payout`; seller, listing, enquiry; mentor, session type, availability, booking, feedback; `VerificationCase` family; CV/EPK share links                                     |
| P3        | `AiInteraction`, `CreativeOrganisation`, `CountyEcosystemStat`, `RisingTalentPick`                                                                                                                                               |

## 6. Profile completion weights (P1-M2)

One engine (`apps/backend/src/creative/completion.ts`) scores every profile; the result is cached in `creative_profiles.completionPercent` and returned with the list of what is missing. Weights add up to 100 (a unit test guards that).

| Item             | Weight | Done when                                            |
| ---------------- | -----: | ---------------------------------------------------- |
| Profile photo    |     15 | an avatar is attached                                |
| First project    |     15 | at least one project (P1-M4; counts as 0 until then) |
| Short bio        |     10 | at least 20 characters                               |
| Discipline       |     10 | a primary discipline is set                          |
| Specialisation   |     10 | at least one                                         |
| Skills           |     10 | at least three                                       |
| Location         |     10 | a county is set                                      |
| Experience       |     10 | at least one (P1-M4; counts as 0 until then)         |
| Headline         |      5 | not blank (edited from P1-M3)                        |
| Verified contact |      5 | email or phone verified                              |

The "next" list is the three heaviest missing items. Interests and areas to develop are collected but do not score (they improve recommendations, not credibility).

## 7. Entities added in P1-M2

| Entity                                                                                                         | Table                        | Notes                                                                                                                                     |
| -------------------------------------------------------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `CreativeProfile`                                                                                              | `creative_profiles`          | 1:1 User. `handle` citext unique, CHECK `^[a-z0-9_]{3,30}$`. `onboardingStep`, `onboardingCompletedAt`, `completionPercent` (CHECK 0-100) |
| `CreativeDiscipline`, `CreativeSpecialisation`, `CreativeSkill`, `CreativeInterest`, `CreativeDevelopmentArea` | `creative_*`                 | Composite keys. `CreativeDiscipline` has one primary per member (partial unique index). `CreativeSkill.level` null until rated (P1-M3)    |
| `SpecialisationSuggestion`                                                                                     | `specialisation_suggestions` | `PENDING`, `APPROVED`, `MERGED`, `REJECTED`; resolver, note, resulting specialisation                                                     |
| `CreativePassport`                                                                                             | `creative_passports`         | 1:1 profile. `passportNumber` unique, `(countyCode, sequence)` unique. Never changes                                                      |
| `PassportCounter`                                                                                              | `passport_counters`          | Last sequence issued per county code, incremented atomically                                                                              |

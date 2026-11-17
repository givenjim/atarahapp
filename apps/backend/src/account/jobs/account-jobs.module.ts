import { Module } from '@nestjs/common';
import { BroadcastsService } from '../../broadcasts/broadcasts.service';
import { SessionService } from '../../identity/session.service';
import { SavedCleanupService } from '../../saved/saved-cleanup.service';
import { AccountService } from '../account.service';
import { DeletionService } from '../deletion.service';
import { ExportService } from '../export.service';
import { AccountJobsService } from './account-jobs.service';

/**
 * Worker-side logic for P1-M11 jobs. Provides the services directly (they need only the database, storage, Supabase
 * admin and notifications) instead of importing the API modules with their controllers.
 */
@Module({
  providers: [
    SessionService,
    BroadcastsService,
    ExportService,
    DeletionService,
    AccountService,
    SavedCleanupService,
    AccountJobsService,
  ],
  exports: [AccountJobsService],
})
export class AccountJobsModule {}

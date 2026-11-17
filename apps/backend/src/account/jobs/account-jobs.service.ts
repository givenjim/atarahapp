import { Injectable } from '@nestjs/common';
import { BroadcastsService } from '../../broadcasts/broadcasts.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { SavedCleanupService } from '../../saved/saved-cleanup.service';
import { AccountService } from '../account.service';
import { DeletionService } from '../deletion.service';
import { ExportService } from '../export.service';

/** The scheduled work of the account, notification and saved modules. Runs in the worker; tests call it directly. */
@Injectable()
export class AccountJobsService {
  constructor(
    private readonly broadcasts: BroadcastsService,
    private readonly exports: ExportService,
    private readonly deletion: DeletionService,
    private readonly account: AccountService,
    private readonly saved: SavedCleanupService,
    private readonly notifications: NotificationsService,
  ) {}

  /** Every minute: staff broadcasts that are due. */
  dispatchBroadcasts(now = new Date()) {
    return this.broadcasts.dispatchDue(now);
  }

  /** Build one export (queued by the API). */
  buildExport(requestId: string, now = new Date()) {
    return this.exports.build(requestId, now);
  }

  /** Every 10 minutes: re-queue lost export jobs and expire links older than 7 days. */
  async exportSweep(now = new Date()) {
    const [requeued, expired] = await Promise.all([
      this.exports.requeueStuck(now),
      this.exports.expireOld(now),
    ]);
    return { requeued, expired };
  }

  /** Daily: delete the accounts whose 30-day grace period ended. */
  purgeAccounts(now = new Date()) {
    return this.deletion.purgeDue(now);
  }

  /** Nightly. */
  async cleanSaved() {
    return { removed: await this.saved.cleanup() };
  }

  /** Daily: notifications older than 180 days. */
  async notificationRetention(now = new Date()) {
    return { removed: await this.notifications.purgeOld(now) };
  }

  /** Every 15 minutes: finish email and phone changes that were confirmed outside the app. */
  async reconcileContacts() {
    return { completed: await this.account.reconcileAll() };
  }
}

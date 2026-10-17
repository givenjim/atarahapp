/** Every BullMQ queue in the platform. Feature modules add processors for the queues they own. */
export const QUEUE_NAMES = [
  'system',
  'notifications',
  'media',
  'payments',
  'analytics',
  'maintenance',
] as const;

export type QueueName = (typeof QUEUE_NAMES)[number];

/** Default retry policy for jobs: exponential backoff, failed jobs retained for the admin failed-jobs view. */
export const DEFAULT_JOB_OPTIONS = {
  attempts: 5,
  backoff: { type: 'exponential' as const, delay: 2_000 },
  removeOnComplete: { age: 3_600, count: 1_000 },
  removeOnFail: { age: 14 * 24 * 3_600 },
};

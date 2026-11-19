import { Injectable } from '@nestjs/common';
import { type BusyInterval } from './availability';

/**
 * What the availability service needs to know about bookings, without knowing the booking table (P2-M5 owns it).
 * P2-M5 implements this (held and confirmed bookings of a mentor within the window) and registers it with
 * `MentorshipHooks.registerBusySlots(...)` from its `onModuleInit`. Until then no provider is registered and a mentor
 * is busy only where their exceptions and weekly ranges say so.
 */
export interface MentorBusySlotsProvider {
  /** Intervals during which the mentor cannot take a new booking (active holds and confirmed sessions). */
  busySlots(mentorId: string, from: Date, to: Date): Promise<BusyInterval[]>;
}

/** A booking-request row as the mentor tools list shows it (P2-M5 fills it). */
export interface BookingRequestSummary {
  id: string;
  menteeName: string;
  sessionName: string;
  startsAt: string;
  endsAt: string;
  status: string;
}

export interface MentorBookingRequestsProvider {
  list(
    mentorUserId: string,
    page: { page: number; limit: number },
  ): Promise<{ items: BookingRequestSummary[]; total: number }>;
}

export interface NextSessionSummary {
  bookingId: string;
  mentorName: string;
  sessionName: string;
  startsAt: string;
}

export interface MentorNextSessionProvider {
  nextSession(userId: string): Promise<NextSessionSummary | null>;
}

/** The seams P2-M5 plugs into. Nothing here reads the booking table. */
@Injectable()
export class MentorshipHooks {
  private readonly busy: MentorBusySlotsProvider[] = [];
  private requests: MentorBookingRequestsProvider | null = null;
  private next: MentorNextSessionProvider | null = null;

  registerBusySlots(p: MentorBusySlotsProvider): void {
    this.busy.push(p);
  }
  registerBookingRequests(p: MentorBookingRequestsProvider): void {
    this.requests = p;
  }
  registerNextSession(p: MentorNextSessionProvider): void {
    this.next = p;
  }

  async busySlots(mentorId: string, from: Date, to: Date): Promise<BusyInterval[]> {
    const all = await Promise.all(this.busy.map((p) => p.busySlots(mentorId, from, to)));
    return all.flat();
  }

  async bookingRequests(mentorUserId: string, page: { page: number; limit: number }) {
    return this.requests ? this.requests.list(mentorUserId, page) : { items: [], total: 0 };
  }

  async nextSession(userId: string): Promise<NextSessionSummary | null> {
    return this.next ? this.next.nextSession(userId) : null;
  }
}

import { Global, Module } from '@nestjs/common';
import { DomainEventBus } from './domain-events';
import { ParticipationService } from './participation.service';

/** Shared by the creative (connections), discover and community modules: the event bus and the participation rules. */
@Global()
@Module({
  providers: [DomainEventBus, ParticipationService],
  exports: [DomainEventBus, ParticipationService],
})
export class CommunityCoreModule {}

import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { MediaModule } from '../media/media.module';
import { EnquiriesService } from './enquiries.service';
import { MarketplaceAdminController } from './marketplace-admin.controller';
import { MarketplaceAdminService } from './marketplace-admin.service';
import { MarketplaceSupportService } from './marketplace-support.service';
import { MarketplaceViewsService } from './marketplace-views.service';
import { MarketplaceController } from './marketplace.controller';
import { MarketplaceService } from './marketplace.service';
import { MyMarketplaceController } from './my-marketplace.controller';
import { SellerListingsService } from './seller-listings.service';

/**
 * Marketplace foundation (P2-M3): sellers, listings, requests ("enquiries") and reviews, plus staff operations.
 * There is no checkout, escrow or payout here (Master Prompt section 4.2): buyer and seller agree details and
 * payment directly.
 */
@Module({
  imports: [AdminModule, MediaModule],
  controllers: [MarketplaceController, MyMarketplaceController, MarketplaceAdminController],
  providers: [
    MarketplaceViewsService,
    MarketplaceSupportService,
    MarketplaceService,
    SellerListingsService,
    EnquiriesService,
    MarketplaceAdminService,
  ],
  exports: [
    MarketplaceService,
    MarketplaceViewsService,
    SellerListingsService,
    MarketplaceSupportService,
  ],
})
export class MarketplaceModule {}

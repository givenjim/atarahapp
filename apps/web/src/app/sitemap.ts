import type { MetadataRoute } from 'next';
import { siteUrl } from '@/lib/site';

/** Scaffold: public profile, opportunity, event and course pages are added to this list as they ship (P3-M4). */
export default function sitemap(): MetadataRoute.Sitemap {
  return [{ url: siteUrl(), changeFrequency: 'monthly', priority: 1 }];
}

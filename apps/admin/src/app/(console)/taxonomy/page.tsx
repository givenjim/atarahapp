import { redirect } from 'next/navigation';

export default function TaxonomyIndex(): never {
  redirect('/taxonomy/disciplines');
}

# Atarah design prototype

`design/prototype/` is the unzipped **Atarah mobile app design** (85 screens in 12 groups). It is the visual and behavioural source of truth for the mobile app (Master Prompt §4.3). It is **reference only — never ship it, never import from it.**

## Opening it

The prototype loads fonts and icons from the network, so serve it over HTTP rather than opening the file directly:

```bash
cd design/prototype
npx --yes serve -l 5500 .
# then open http://localhost:5500/Atarah%20Mobile%20App.dc.html
```

`Atarah Mobile App.dc.html` is the router: a phone frame with a screen list on the left (tap to jump). Use its **Viewer** switches to see free/premium, creative/mentor/seller and offline variants.

## What is where

| File                        | Screens                                                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `Atarah Mobile App.dc.html` | Router, screen list, `NO_TABS` list (screens that hide the tab bar)                                                      |
| `AtarahEntry.dc.html`       | splash, welcome, signup, signin, verify, forgot, reset, onboarding (`ob_*`)                                              |
| `AtarahDiscover.dc.html`    | home, explore, search, filters, economy, county, article                                                                 |
| `AtarahCommunity.dc.html`   | community, post, compose, groups, group, creatives, creative                                                             |
| `AtarahOpps.dc.html`        | opps, opp_list, opp, opp_ai, opp_leave, opp_saved                                                                        |
| `AtarahLearn.dc.html`       | labs, lab_cat, course, lesson, my_learning                                                                               |
| `AtarahMarket.dc.html`      | market, market_browse, listing, seller, listing_new, my_listings                                                         |
| `AtarahMentor.dc.html`      | mentorship, mentors, mentor, book, pay_summary, pay, pay_done, my_mentorship, mentor_tools                               |
| `AtarahIdentity.dc.html`    | profile, passport, portfolio, project, project_new, skills, experience, achievements, services, cv, verification, ai_bio |
| `AtarahAccount.dc.html`     | activity, notifications, saved, applications, settings screens, system states                                            |
| `assets/`                   | Sample imagery (demo only)                                                                                               |
| `uploads/`                  | Original specification documents (written under the product's earlier working name; read every occurrence as Atarah)     |

Each screen file has markup plus a `<script type="text/x-dc">` block whose sample data shows the **data shape** the screen needs.

## What to ignore

- **`_ds/modernist-…/`** — an unused design-system bundle (red, square corners, Archivo font). It contradicts the real design. The real tokens are the inline styles in the screen files and are captured in Master Prompt §8 (and, from P0-M6, `packages/design-tokens/tokens.json`).
- `support.js` (prototype runtime) and `icons.js` (Lucide renderer) are not app code.
- Sample people (Nia Wairimu, Amani Otieno, Zuri Mwangi, Kiptoo Langat, Wanjiku Njeri) are illustrative; they may appear only in clearly labelled `dev` demo seed data.

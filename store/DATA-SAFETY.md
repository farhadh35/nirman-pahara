# Play Data safety form — the answers

Fill the form in Play Console → App content → Data safety with these. Every
answer follows from the code; where an answer would be a judgement call, the
reason is given.

## Does your app collect or share any of the required user data types?

**Yes** — but only through the advertising SDK. Nothing the user records is
collected by us.

## Location

- **Approximate location**: Not collected by us.
- **Precise location**: **Collected, not shared.**
  - Purpose: **App functionality** — stamped onto an inspection photograph so a
    report can say where a defect was seen.
  - Is it processed ephemerally? **No** — it is stored with the photograph.
  - Is collection optional? **Yes.** Refusing the permission still lets the
    photograph be taken; the report then states that the location was not
    recorded.
  - Note in the form: the data stays on the device and is not transmitted to
    the developer.

## Photos and videos

- **Photos**: **Collected, not shared.**
  - Purpose: **App functionality** — evidence attached to an inspection.
  - Stored in the app's private directory, not the shared gallery.
  - Not transmitted to the developer. Shared only if the user taps share.

## Files and docs

- **Files and docs**: **Not collected.** The app reads only the single file the
  user selects in the system file picker, in memory, to parse a rate schedule.
  It is not retained or transmitted.

## Device or other identifiers

- **Collected and shared** — by the advertising SDK, for **Advertising or
  marketing** and **Analytics**. Declare according to the ad network's own
  published data-safety guidance for the SDK version you ship.

## Personal info, financial info, health, messages, contacts, calendar

**Not collected.** The app has no account system and no server.

## Security practices

- **Is data encrypted in transit?** The app itself transmits no user data. Ad
  SDK traffic is over HTTPS.
- **Can users request data deletion?** **Yes** — everything is on the device;
  deleting an inspection or uninstalling removes it. There is no server copy to
  request deletion from.

## Sensitive permissions to justify elsewhere in Console

- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` — foreground only, at photo
  capture. No background location. No location declaration form is required
  because background access is not requested.
- `CAMERA` is not declared in the manifest; the camera is reached through the
  system camera app via an intent.

## Ads declaration

Under **App content → Ads**, answer **Yes, my app contains ads**.

## Content rating

Answer the questionnaire as a **Reference / Education** utility: no violence, no
sexual content, no gambling, no user-generated content shared between users, no
in-app purchases.

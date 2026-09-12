# Play Data safety form — the answers

**For version 2.0.0 (versionCode 4).**

Fill the form in Play Console → App content → Data safety with these. Every
answer follows from the code, and the decisive fact is checkable in one command:

```bash
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```

The release APK declares `ACCESS_COARSE_LOCATION` and `INTERNET`. There is no
server, no account, no analytics and — in this version — no advertising SDK.

**Two changes at 2.0.4 weakened one claim and tightened another, and both
matter when answering the form.**

`ACCESS_FINE_LOCATION` is gone. It had been declared since 2.0.0 and never
used: the one call site asks for `LocationAccuracy.medium`, which coarse
satisfies. The geolocator plugin still declares it, so the app manifest removes
it explicitly.

`INTERNET` is now declared, and it was not before. That is a real reduction in
what can be proved. The old claim was that the app **could not** transmit,
because Android would not permit it — a property of the binary, checkable by
anyone with `aapt2`. The claim now is that it **does not**: no HTTP client is
shipped, none is called, and the update check reaches Play services by IPC
rather than a socket. `test/update_check_test.dart` fails if a network client
enters the dependency list or `lib/`.

Nothing collects or sends anything today, so every answer below is unchanged.
But the permission is declared ahead of a feature rather than alongside one, so
whoever adds that feature must revisit this file and the Play form **in the
same change**, not after it.

> **This file previously described a build with ads in it.** It answered "Yes"
> to collection, declared device identifiers as collected and shared by an
> advertising SDK, and told you to declare ads. None of that is true of what
> ships: there is no ad SDK in `pubspec.yaml` or the manifest. Those answers
> would have been false statements to Google about the uploaded binary. What
> to change when ads do ship is at the bottom.

## Does your app collect or share any of the required user data types?

**No.**

Play defines *collection* as data transmitted off the device. Photographs,
coordinates and inspection notes are written to the app's private storage and
stay there. The app has no network permission, so none of it can leave except
when the user themselves taps share and picks an app to send it to — which
Play's own guidance treats as the user acting, not the app collecting.

Answering "Yes" here because the app *records* things would be the common
mistake, and it misrepresents the app in the direction of sounding worse than it
is.

## If the form still asks per type

- **Location** — not collected. Precise location is read at the moment a
  photograph is taken and stored beside it on the device. Refusing the
  permission still lets the photograph be taken; the report then states that
  the location was not recorded, rather than leaving a silent gap.
- **Photos** — not collected. Written to the app's private directory, not the
  shared gallery.
- **Files and docs** — not collected. One file is read from the system picker,
  parsed in memory to check a rate schedule, and not retained.
- **Device or other identifiers** — not collected. Nothing generates or reads
  one.
- **Personal info, financial info, health, messages, contacts, calendar** —
  not collected. There is no account system and no server.

## Security practices

- **Is data encrypted in transit?** Not applicable — the app transmits no user
  data. It holds `INTERNET` since 2.0.4, but ships no network client and calls
  none; the only thing that reaches Play services does so by IPC. If the form
  will not accept "not applicable", the honest answer is that no user data is
  transmitted.
- **Can users request data deletion?** **Yes.** Everything is on the device.
  Deleting an inspection removes it; uninstalling removes all of it. There is no
  server copy for anyone to request deletion from, including us.

## Sensitive permissions, justified

- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` — **foreground only**, read
  at the moment a photograph is captured, so a finding can say where it was
  seen. No background access is requested, so the background-location
  declaration form does not apply.
- `CAMERA` is **not** declared. The camera is reached through the system camera
  app by intent, so the app never holds the permission.

## Ads declaration

**No, my app does not contain ads.** There is no ad SDK in the build. See
`docs/AD_POLICY.md` for why the funding model is constrained, and what would
have to be true before any ad shipped.

## Content rating

Answer the questionnaire as a **Reference / Education** utility: no violence, no
sexual content, no gambling, no in-app purchases, and no user-generated content
shared between users — reports go only where the user sends them.

## What changes when ads ship

Do all of this in the same release that first contains an SDK, not before:

1. Collection answer becomes **Yes**.
2. **Device or other identifiers** — collected and shared, for *Advertising or
   marketing* and *Analytics*, declared to match the ad network's own published
   data-safety guidance for the exact SDK version shipped.
3. Ads declaration becomes **Yes**.
4. Encryption in transit becomes **Yes** — ad traffic over HTTPS.
5. Category blocking configured first, per `docs/AD_POLICY.md`: no cement,
   steel, brick, tile, paint, contractor or developer advertising, because the
   app exists to tell someone whether those things are sound.

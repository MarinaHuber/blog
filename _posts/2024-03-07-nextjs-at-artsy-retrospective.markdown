---
layout: epic
title: "All things localization"
subtitle: "(On iOS and Second Thoughts)"
date: 2024-03-07
categories: []
author: []
---

Where to begin! Where to begin...

Localisation is something that occurs in every project I encounter.   
I found that having a list of useful tips that cover most aspect of localisation is essential, 
so that is why I created this post and is in progress.
There is a slight distinction between internationalization and localization:
Internationalization — the process of making your app able to adapt to different languages, regions, and cultures.
Localization — the process of translating your app into multiple languages.
So, in total it depends on context, and namely on the following elements:
* 		user gender
* 		singular and plural in the text
* 		platforms: Web, Android, iOS
* 		the project for which the translation is being done.

<!-- more -->

### The Problem & App Store:

In Apple ecosystem if the developer needs to modify any content of the language file, 
the changes needs to be updated in the project and the app needs re-submission.
 Also have you been in that situation where you have pushed a spelling mistake 
 to the App Store? `( ◍•ᴗ•◍)`
🤟🏽 There are at least three ways of translating you app.
1 . Custom solution with web service that contains JSON file with translation for all platforms needed.
2. Dynamically translating it with third party services like Crowdin, Azure Translator, Applanga, BartyCrouch list is long.
3. Importing/exporting .string files into Xcode project manually
-exporting Localization Catalog .xcloc containing good old XLIFF file

Solution 1:
Custom web service with JSON downloaded on the app launch.
* 		Create small service- in the app you can request the language the device needs and listen to any changes that might occur (simple Firebase DB or any custom robust server with .json file there)
* 		During the launch wait until you have received a response from web service before you display anything to the user.
* 		Or, if you do not want to rely on the devices connection, then you can preinstall the dictionary by adding the .json file to the bundles resources and preload on app startup.
This can be pretty straight forward. An this is example how your .json file can be formatted. https://simplelocalize.io/docs/file-formats/single-language-json/
Managing the translation into dictionary of strings and reusing it with string extention:
```public class LocalizationService {
   
   static var localisation: [String: Any]?

   class func getString(with key: String) -> String {

      let missingError = UIDevice.isProduction ? "": String(format: "Missing string for key: %@", key)
      guard let localisation = shared.localisation as NSDictionary? else { return missingError }      
      let localisedString = localisation.value(forKeyPath: key) as? String
      return localisedString ?? missingError
   }
}```

```public extension String {
   var localised: String {
      return LocalizationService.getStringForKey(with: self)
   }
   }
   ```

Note: this is a starting point code reference
Solution 2:
Third party solution and their tradeoffs.
* 		BartyCrouch, Open source project
brew uninstall bartycrouch
Using BartyCrouch and running a few commands from the command line what can even be automated, 
using a build script within your project.
Pros:
in order to keep your Storyboards/XIBs Strings files updated over time
2. make sure your Localizable.strings files stay updated with newly added keys in code 
using NSLocalizedString and show warnings for duplicate keys or empty values
3. use the machine translation feature of Microsoft Translator Text API via translate
4. let BartyCrouch translate it to all supported languages in a single line & 
without ever leaving the code.
Important : Localization Workflow via transform- of BartyCrouch formatted localized Strings 
are not supported by this automatic feature.
Transform from NSLocalizedString or BartyCrouch.translate doesn’t support the new LocalizedStringKey type yet. 
Not ready to be used in SwiftUI fully (more in this issue)
Steps for BartyCrouch translate:
* 		Set up Azure (the GLOBAL configuration is the option that takes (location) of all near by servers is fastest)
* 		Run the update script in the Compile Sources -
Had some issue here as I am getting success in translation but no output. I posted on Github BartyCrouch OSS
NOTE:❗️Troubleshooting BartyCrouch error: no file found Library not loaded:libSwiftSyntax.dylib
* 		Translate feature: LiveDemo

2. Crowdin
I heard a lot of folks in iOS community using this service which is cloud-based localization platform for continuous software localization projects.
With Crowdin you have the option to work with freelance translators and volunteers but also aspecialized software localization company.
Up to 60,000 hosted words it is free of charge.

3. Applanga
Same as Crowdin but much better CI and automation delivery for native platforms.
Basic sunscription starts from 49$month.
Solution 3:
Static localization. No need to use key-based translations:
NSLocalizedString(“Text”, value: “Hello World”, comment: “Main label”)
→ From iOS15 there is no need to use key-based translations 💯 💯
Localisation got better from WWDC 2022
String(localised: “Text”, defaultValue: “Text”, comment: “This is Text”)

There are omitted details of course, and there were things we needed to figure
out (such as auth, via `next-auth`, and passing runtime ENV secrets to our
Dockerized container), but in any case this gave us a lot of confidence to start
discussing what it might take to seriously consider rebuilding our internal
tools app. A few meetings later it was decided, and our platform team agreed to
take it (with loose backup support from a couple other engineers). And a few
short month's later much of the core functionality was complete, executed by a
team working amidst unfamiliar terrain.

That's the definition of success, and the measure. With our internal tools app
complete it was natural to start looking around for other opportunities -- but
first, a quick detour.

### Enter: Workflow (aka, The `app` default)

U
sually we will start with english as the base language as default, then slowly adding more language support on top of it. Before using any tools we need to prepare our app for DEFAULT language.
By default, a base language will be provided by Xcode, i.e, english. This base language will act as a fallback language if any localizable content is not found. In my test project since I am not using localized STORYBOARDS DefaultLocalizable.string file is the default English language that must contain all the text of the app for fallback.
* 		Create Localizable.string file
* 		Always wrap user-facing strings with (iOS13&14) NSLocalizedString or (from iOS 15+) String(localized:)
* 		Create IBDesignables to add storyboards UI to code
* 		Created swift script called LocalizationScript.swift that takes all Localizable.strings and creates enum from it (this script reads Localizable.sting file and can not distinguish comments from text to translate)
Few tips from session @Apple Localization Lab:
Create Localizable.string file
Always wrap user-facing strings with (iOS13&14) NSLocalizedString or
From iOS 15+ String(localized:)
Create IBDesignables to add storyboards UI to code
Note: Will detect the App language:
NSLocalizedString() → short for Bundle.main.localizedString()
Exporting for localization in SwiftUI
New Xcode project build settings Use Compiler to Extract Swift Strings
Once active, before exporting strings for localization, Xcode will build all project targets and use the compiler type information to extract LocalizedStringKeys from your SwiftUI code
In Xcode 13+ .xcloc a.k.a. Xcode Localization Catalogs can be opened directly in Xcode with the new Localization Catalog Editor 🤙🏽
Needs to be set to YES if project uses SwiftUI for Exporting all targets in Catalog
This is the file it will expose into: en.xclocc
You can use comments for easier translation all and more here
Spanish & English language got a new custom Markdown
The main purpose of Automatic Grammar Agreement however, to make the translation of plural and gendered texts
so far better to use stringdict
All edge cases:
Localization of dynamic text
Check the current running application language, if it is Spanish than show the Spanish text, else show the English one.
In case the strings are coming from the internet server:
Bundle.main.preferredLocatizations.first
Plural and Gender Support
using .stringdict
String.localizedStringWithFormat(formatString, count)
If you try to translate English phrases word-for-word into Spanish or German, they will make no sense. For this reason, you may need to create more than one version of each string and write instructions about which variant should be used.
Gender and personalisation:
Using date, currencies and number formatters
More
Dates
Unicode.org for TEMPLATES → http://www.unicode.org/reports/tr35/tr35-31/tr35.html
use templates : more make data user-friendly
dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first ?? “en”)
or use the current locale of the app it is the same result
dateFormatter.locale = .current
Dynamic Dates
coming from translated server
let allServerLanguages = [”en”, “es”, “de”, “it”]
let language = Bundle.preferredLocalizations(from: allServerLanguages).first

```
- app/
---- layout.tsx
---- page.tsx
- app/artist
---- layout.tsx
---- page.tsx
---- middleware.tsx
```

And so on. "Global" SSR data could be fetched right there in `layout` or `page`
and shared with its subtree; and likewise, for sub-sub-tree's we could do the
same in each individual app `layout` or `page` component.

Additionally, with React Server Components, we would no longer need to use many
Next.js-specific APIs. To fetch data on the server, you simply `await` a promise
and pass it right to your component as props. Next's already minimal API
footprint would diminish even further, and it became possible to glean a vision
of "just vanilla JS" all the way down, and within that vision the possibility of
true simplicity.

Little did we know, it wouldn't take much to turn this beautiful vision into
something of a dilemma, but that part of the story comes a bit later.

### Expanding Next.js at Artsy

Coming off of our success with the internal tools app rebuild, we wanted more.
And we didn't need to look far: right around the corner was a ~10 year old
external CMS app that our partners use to manage their inventory.

We decided the path forward was Next, and like our internal tools app rebuild,
for the most part it has been a success. We again went with the `pages` router
(as the new `app` router wasn't yet released) and so far there's been minimal
confusion from the team. And buisness-wise, its been refreshing to defer
framework design decisions, lib upgrades and more to Next, versus having to
maintain [all of these things in-house](https://github.com/artsy/force).

It's also worth mentioning that there _have_ been a few significant challenges
involved (such as setting up performant SSR patterns for using Relay, our
GraphQL client -- thats another blog post), but on the whole Next has served our
needs well. Team performance was unlocked, and we've been able to quickly get to
building and rebuilding CMS pages in this new application. And our engineers
have loved working in it.

### Back to Next 13

In the meantime, Next 13 was released. Imagine our excitement! Just as this new
app is spinning up we receive a little gift from the stars. Carlos and I are the
first ones to bite; lets see what migrating our work over to the new framework
might look like, what kind of effort.

From the start, it was immediately obvious that the Next.js team released an
alpha-quality (or less) product, marked as `stable`. Not a `beta`, not an `RC`
to peruse and experiment with, but rather an

```bash
npm install next
```

package that comes with an application scaffold generator that suggests using
the `app` router over `pages` -- marked as _"Recommended"_. In other words,
highly polished. And what's the first thing one experiences?
[Hot Reloading is broken](https://www.google.com/search?q=next+13+hot+reloading+broken+site:github.com&sca_esv=b6c25dbec4ffd71b&sa=X&ved=2ahUKEwjlmtTR_eKEAxW4CjQIHTqPAJYQrQIoBHoECBgQBQ&biw=1512&bih=829&dpr=2#ip=1).

And what's the next thing? Styles are broken. It turns out that RSC (React
Server Components) doesn't fully support pre-existing CSS-in-JS patterns. Or
rather,
[they do, kind of](https://nextjs.org/docs/app/building-your-application/styling/css-in-js#styled-components),
but they can only be used inside `use client` components (which, in Next.js,
actually means a server-side rendered component environment that's _separate
from_ a RSC rendered "server-only" environment -- aka the old pages router
model). And we certainly weren't about to throw out our Design System component
library [Palette](https://github.com/artsy/palette), which has been nothing but
a runaway success (and a
[highly portable one](https://github.com/artsy/palette-mobile) at that).

With this limitation, our ability to use React Server Components had been
severely hampered. Excluding the root-most level of our component tree, we were
now required to prepend `use client` on the top of every component, lest we
receive ambiguous errors about rendering a client component (which used to be
server-side render safe) on the "RSC server".

Things can be taught, however. So lets proceed from the assumption that through
some kind of tooling / linting layer, `use client` is added to every new
component. It _should_ behave at that point just like the old Next and now we
get the best of both worlds. Nope: turns out that even with the CSS-in-JS setup
instructions described in the the next docs above, we still run into issues.
There are bugs.

(These are the two main red flags, but there are many others as well.)

At this point, we wisely back out. It's only `next@13.0.0`, and what they're
doing here is to a certain extent revolutionary. It's a new way of thinking
about React, yet an old way of thinking about page rendering. It's like... PHP,
or so they say. RSC is _interesting_, there's something to it. Lets give them
the benefit of the doubt and return to things in a few months, after a few
`minor` version bumps; there are, after all, countless eyes on the project.

### Many Months Later

We run `npx create-next-app@latest` (this is around the time they release
`13.4`) and then add these two components inside the newly-created vanilla
project:

```tsx
// app/HelloClient.tsx
'use client'

export const HelloClient = () => {
  return <div>Does this hot reload</div>
}

// app/layout.tsx
import { HelloClient } from './HelloClient'

export default Layout() {
  return <HelloClient />
}
```

Everything renders. And then

```tsx
export const HelloClient = () => {
  return <div>Does this hot reload... nope :(</div>
}
```

In the most basic project setup, the most obvious Next.js selling point --
Developer Experience -- failed to deliver. Vercel is really forcing us to
question things. But we're flexible, and we like to investigate at Artsy, so
even though this definitely-required feature doesn't quite work, maybe it will
once we're done with our migration spike, and maybe we can still take advantage
of everything else that RSC has to offer.

So again, we start refactoring the project. Stuff from the `pages` directory
starts getting copied over to `app`. We update configuration. We setup styling
(it seems to work better). Things are _almost_ there. But then the obscure
framework errors start to arrive, and CSS still doesn't quite work: it turns out
that refactoring across RSC-`use client` boundaries is harder than one thought.
I.e., if any piece of "client" (remember, 'use client' actually means SSR-safe)
code _anywhere in the dependency tree_ happens to intersect an RSC boundary, the
whole thing will fail. And this includes any use of React's `createContext` --
because React Contexts aren't supported. Given an app of any reasonable size,
you're likely to rely on a context somewhere, as contexts are so critical within
the react hooks model of behavior. Said contexts might come from within your
app, and if not there they'll certainly come from a 3rd party library.

One would expect the errors to be helpful in tracking this down -- Next.js is
all about DX -- but no. Confusion reigns.

We're experts though, and we eventually _do_ find the source of the violation,
and we make sure to create a "safety wrapper" around the offender so that it
doesn't happen again. But it does happens again -- and again, any time any piece
of any complexity is added in the new RSC-intersected route. It's rather
unavoidable. And each time solvable, but at a great cost to the developer.
Thankfully we know what we're doing!

Another trivial yet annoying issue (thankfully fixed with some custom eslint
config) is accidentally importing the `useRouter` hook from the `app` router
location, or `redirect`, or any number of other new `app` router features,
because all of these things don't work in `pages`, and will error out. The
errors here are slightly less opaque, but what if you're a backend dev who knows
nothing about any of this? Googling "useRouter next" now yields two sets of
docs. Figure it out.

<div style="text-align: center;">
  <img src="https://miro.medium.com/v2/resize:fit:1400/0*Sce5egkhwWpCeqF0.jpg" width="600" />
</div>

At this point, we make a judgement call: this simply isn't going to work at
Artsy. We're here to empower folks and unlock productivity. Remember the team of
DevOps engineers on Platform who rebuilt a CMS in record time? In the new Next
13 model, that would be unfathomable, impossible even. Paper cuts would kill
motivation, and dishearten the already skeptical. And the front end already has
a bad rap, for good reason: historically, everything that seems like it should
be easy is hard and confusing for those who aren't experts. And everything is
always changing. And the tooling is always breaking. And everybody always has a
bright new idea, one that will finally end this madness for good.

A certain amount of sadness is appropriate here, because Next's `pages` router
was very, very close to being the silver bullet for web applications that we've
all been looking for. Even though the `pages` router has its flaws, it showed us
that it's possible to get something out the door very quickly with little prior
knowledge of Front End development. This is no small thing. Next 13's fatal
error is that its destiny, being coupled to RSC, now requires experts. And by
'expert' I mean: those with many years of experience dealing with JavaScript's
whims, its complex eco-system, its changeover, as well as its problems. In
short, folks who have become numb to it all. This is no way to work.
[Thankfully the community is finally responding](https://www.reddit.com/r/nextjs/comments/1abd6wm/hitler_tried_rsc_and_next_14/).

### A Quick Note on Performance

It's worth remembering that Next 12 was industry-leading in terms of performance
and pioneered many innovative solutions. Let me say it again: Next's pages
router IS fast. Next 13 combined with RSC _is_ faster, but at what point does an
obsession with performance start negating other crucial factors? What's good for
the 90%? And what's required for the other 10%? Most companies just need
something that's fast enough -- and easy enough -- to _move_ fast. And not much
more.

### Back At Artsy...

With all of this in mind, and with the uncertainty around long-term support for
Next.js `pages` (amongst other things), we recently decided to hit pause on
future development in our new external CMS app rebuild. Weighing a few different
factors (many entirely unrelated to Next), including a team reorg that allowed
us to look more closely (and fix) the DX in our old external CMS app, we took a
step back and recognized that our needs are actually quite minimal:

- Instant hot reloading
- Fast, SPA-like UX performance
- Simple, convention-based file organization

With these things covered, the "web framework" layer looks something like the
following, minus a few underlying router lib details:

```tsx

const Router = createRouter({
  history: 'browser',
  routes: [
    {
      path: '/foo',
      getComponent: React.lazy(() => import('./Foo'));
    },
    {
      path: '/bar',
      getComponent: React.lazy(() => import('./Bar'));
    }
  ]
})
```

We're now required to manage our compiler config, but
[that layer](https://github.com/shakacode/shakapacker) isn't too complicated
once its setup, and it works great. (If you're using something like `Vite`, it
could be even simpler.)

### Final Thoughts

Next 13 and React Server Components are very intriguing; it's a new model of
thinking that folks are still trying to work out. Like other revolutionary
technologies released by Meta, sometimes it takes a few years to catch on, and
maybe RSC is firmly in that bucket. Vercel, however, would do well to remember
Next's original fundamental insight -- that all good things follow from
developer experience. Improvements there tend to improve things everywhere.

In addition to fixing some of the obvious rough edges in the new `app` router,
it would be helpful if Next could provide an official response to
[the question of long-term Pages support](https://github.com/vercel/next.js/discussions/56655).
There's been quite a backlash in the community against Next 13, and that should
give all developers pause. It'd also be great to get word on whether there will
be any further development on the pages router -- perhaps some of the features
from the new `app` router can be migrated to `pages` as well? -- or if the pages
router is officially deprecated and locked. All of this is currently ambiguous.

Another area where Next could improve is their willingness to ship buggy
features, and to rely on patched versions of React in order to achieve certain
ends. Even though Vercel employs many members of the React Core team, by
releasing Next versions that rely on patched and augmented `canary` builds of
React, Vercel is effectively compromising some of React's integrity, and forcing
their hand. Once a neo-React feature is added to Next, it makes it hard to say
no; Next has captured too much of the market-share.

All of this calls for sobriety and hesitation on the part of developers working
with -- and building companies on top of -- Vercel's products. Next is Open
Source, yes, but it's also a wildcard. Artsy has had some real success with
Next, but sometimes that's just not enough to avoid hitting pause, and looking
at the bigger picture. Inclusivity should always win.

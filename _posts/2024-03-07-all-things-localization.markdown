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

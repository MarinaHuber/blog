---
layout: epic
title: "Avoid typos when publishing localized app to App Store"
subtitle: "(On Apple and Second Thoughts)"
date: 2024-06-19
categories: [iOS, Localization, Apple]
author: marina
---
Where to begin! Where to begin for Dummies...

Localization is something that occurs in every project I encounter. Implementing localization can be a bit bothersome for developers, 
but it can make users feel respected and cared for.
I found that having a list of useful tips that cover most aspect of localization is nice to have, 
especially as it goes through regular Apple API updates.
So I created this post as my memory of legacy and current state of possible best practices in localization.
There is a slight distinction between internationalization and localization:\
Internationalization — the process of making your app able to adapt to different languages, regions, and cultures.\
Localization — the process of translating your app into multiple languages.
So, in total it depends on context, and namely on this elements:
* 		Singular and plural in the text
* 		User gender (or consensus declaration)
* 		Platforms: Web, Android, iOS
* 		Project objective for which the translation is being done.

<!-- more -->

#### The Problem & App Store:

In Apple ecosystem if the developer needs to modify any content of the language file, 
the changes needs to be updated in the project and the app needs re-submission.
 Also have you been in that situation where you have pushed a spelling mistake 
 to the App Store? `( ◍•ᴗ•◍)`
There are at least few ways you can help yourself, here are few solution and their tradeoffs.
The main tradeoff being dependency needs to be flexible and easily **removable** anytime down the product timeline.

1 . Custom solution on the fly with web service that contains JSON file with translation for "all" platforms needed.

2 . Dynamical translations (on the fly) with third party services like Crowdin, Azure Translator, Applanga, BartyCrouch.

3 . Importing/exporting String Catalog or legacy .string file into Xcode project manually

### Solution 1:
Custom web service with JSON downloaded on the app launch.
* 		Create small service - in the app you can request the language the device needs and listen to any changes that might occur (simple Firebase DB* or any custom robust server with .json file there)
* 		During the launch wait until you have received a response from web service before you display anything to the user.
* 		Or, if you do not want to rely on the devices connection, then you can preinstall the dictionary by adding the .json file to the bundles resources and preload on app startup.
This can be pretty straight forward. An this is example how your .json file can be [formatted](https://simplelocalize.io/docs/file-formats/single-language-json/).

Managing the translation into dictionary of strings and reusing it with string extension:

```tsx
public class LocalizationService {
   static var localisation: [String: Any]?

   class func getString(with key: String) -> String {
      let missingError = UIDevice.isProduction ? "": String(format: "Missing string for key: %@", key)
      guard let localisation = shared.localisation as NSDictionary? else { return missingError }      
      let localisedString = localisation.value(forKeyPath: key) as? String

      return localisedString ?? missingError
   }
}
```

```tsx
public extension String {
   var localised: String {
      return LocalizationService.getStringForKey(with: self)
     }
   }
```

Note: this is a starting point for pseudo code reference. With my small internal service for localization
complete it was natural to start looking around for other opportunities -->

#### Solution 2:
Third party solution and their tradeoffs:

2.1   BartyCrouch, Open source project run in Terminal + Homebrew*
```bash
$ brew install bartycrouch
```

Using BartyCrouch and running a few commands can be nice start.
Also using a build script within your project is good to keep your Storyboards/XIBs Strings files updated over time.

* Make sure your Localizable.strings files stay updated with newly added keys in code 
using NSLocalizedString and show warnings for duplicate keys or empty values
* Use the machine translation feature of Microsoft Translator Text API* via translate
* Let BartyCrouch translate it to all supported languages in a single line & 
without ever leaving the code.

Important : Localization Workflow via `transform-` feature formatted localized Strings 
are not supported by this automatic feature.
Transform from NSLocalizedString or BartyCrouch.translate doesn’t support the new `LocalizedStringKey` type yet. 
Not ready to be used in SwiftUI fully (more in this issue)
Steps for BartyCrouch translate:
* 		Set up Azure (the GLOBAL configuration was the best option)
* 		Run the script in the Compile Sources - Xcode

Translate example: 🏁[LiveDemo on Cleanshot](https://share.cleanshot.com/oFn4el)

Had some issue here as I am getting success in translation but no output.
NOTE:❗️Troubleshooting BartyCrouch `error: no file found Library not loaded:libSwiftSyntax.dylib.` I posted on [Github BartyCrouch OSS](https://github.com/FlineDev/BartyCrouch/issues/252)

BC is free and open source it was fun to try out and play with it, but the learning curve was steep and Azure setup cumbersome.


2.2   Crowdin \
I heard a lot of folks in iOS community using this service which is cloud-based localization platform with continuous localization integrations.
Crowdin have the option to work with freelance translators and volunteers but also a software localization company.
Up to **60,000 hosted words** is free of charge.

2.3   Applanga \
Same as Crowdin but somewhat better CI* and automation delivery for native platforms with tests.
Basic subscription starts from **49$month**.

### Solution 3:
In Xcode 15 and later, `string catalogs` are the recommended way to localize strings. In earlier versions of Xcode, use `strings` and `stringsdict` files.
-exporting Localization Catalog .xcloc file containing good old XLIFF* file and sending it to a external translator source.

In code:\
As well from iOS15+ there is no need to use key-based translations with:
`String(localised: “Text”, defaultValue: “Text”, comment: “This is Text”)`

Prior static localization, means no need to use key-based translations with:
`NSLocalizedString(“Text”, value: “Hello World”, comment: “Label Hello World”)` → 


### Workflow (fallback strategy)

Usually I will start with English as the base language as default, then slowly adding more language support on top of it. Before using any tools we need to prepare our app for DEFAULT language.
By default, a base language will be provided by Xcode. This base language will act as a fallback language if any localizable content is not found. 
One of the advantages of "new" String Catalog is that when you build the project, strings are automatically listed. In demo test project since I am not using localized xibs, DefaultLocalizable.string file is the default file for English language that must contain all the text of the app for fallback.
Few tips from session @Apple Localization Lab:\
* Create String Catalogs in New File menu -> **Localizable.xcstrings** is created legacy to Localizable.string file creation manually
* Always wrap user-facing strings with legacy code NSLocalizedString or
* Created swift script that takes all .strings and creates enum from it 
(NSLocalizedString does not support being hidden behind macros). This does work for String(localized:) and LocalizedStringResource.

From iOS 15+ String(localized:) & LocalizedStringKey in SwiftUI \
will detect the App language:
`NSLocalizedString()` → short for `Bundle.main.localizedString()`\
Exporting for localization in SwiftUI
🤙🏽 Xcode project build settings **Use Compiler to Extract Swift Strings**
Once active, before exporting strings for localization, Xcode will build all project targets and use the compiler type information to extract LocalizedStringKeys from your SwiftUI code.
In Xcode .xcloc a.k.a. `Xcode Localization Catalogs` can be opened directly in Xcode with the new Localization Catalog Editor 🤙🏽
Needs to be set to **YES** if project uses SwiftUI for Exporting all targets in Catalog\
This is the file it will expose into: **en.xclocc**


You can use comments for easier translation all and more here
Spanish & English language got a new custom Markdown.
The main purpose of Automatic Grammar Agreement however, to make the translation of plural and gendered texts
but in my experience was so far better to use `.stringdict` format.



### SwiftUI
This part is specific for SwiftUI approach, where usually the translation process happens based on a user action.

Translation/TranslationSession API is making this possible now with multiple translations for iOS18.
To translate a batch of requests in different languages, do not try to do so in a single batch of requests. 
This API makes multiple language translations natively.

For Previews make sure you output is in localization to avoid unnecessary work for translators when exported:
`Text(verbatim: “This is content”)`
- returns text as it is - hence the verbatim argument name


🚫 NEVER give SwiftUI elements FIXED HEIGHT this way the localized Text will be cut off 🚫 (another post on this sizes).
In iOS16 this is solved with
Labels/Text need to be flexible in height and width if we use GRID layout or .ViewThatFits — than it is easier.
```tsx
.Grid(alignment: .leading) {
  .GridRow {
        .Text("This is content")
    }
}
```

NOTE: on WatchOS this is specially important so use - .ViewThatFits
```tsx
.ViewThatFits
```
Inside that view place for:
* expected view layout
* is for complex looking translated languages

On **WatchOS** and **Extensions** we need to specify a BUNDLE from where we are getting the translation from .framework if it is from Cocoapods or SPM
if it is inside host app than .main or .module for SPM

 `String(localised: “Text”, bundle: .main, comment: “”)`

AttributedStrings — from iOS15+ the are also localized

`AttributtedStrings(localised: “Text”, comment:””)`

or use Automatic Grammar agreement with Marksown strings (less control tho, exmpl. below)

<figure class="illustration">
  <img
    src="/blog/images/2024-06-19-all-things-localization/markdownSwiftui.png"
    alt="Image showing Markdown in SwiftUI"
  />
  <figcaption>SwiftUI with Markdown  (image by Learn And Code With Enid)</figcaption>
</figure>

**Extra edge cases:**
Localization of dynamic text

In case the strings(translations) are coming from the server:
`Bundle.main.preferredLocatizations.first`

Check the current running application language, if it is Spanish than show the Spanish text, else show the English one.

Plural and Gender Support
using .stringdict
String.localizedStringWithFormat(formatString, count)

TIP: If you try to translate English phrases word-for-word into Spanish or German, they will make no sense. For this reason, you may need to create more than one version of each string and write instructions about which variant should be used from .string file.

Gender and personalization with:
Using Date, Currencies and Number **formatters** API.

Dates
Unicode.org for [TEMPLATES](http://www.unicode.org/reports/tr35/tr35-31/tr35.html)
→ you can use templates : make app text user-friendly with **preferredLanguages** as it detected language from a device.

`dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first ?? “en”)`

or use the current locale of the app gives the same result
```tsx
let allServerLanguages = [”en”, “es”, “de”, “it”]
let language = Bundle.preferredLocalizations(from: allServerLanguages).first

```

Dynamic Dates →  
`dateFormatter.locale = .current`



### UITests
Saved screenshots form UITests are now localizable for App Store.
To test all the `strings` that are localizable use Edit Scheme -> Pseudolanguage in SwiftUI

Let AI write automated UI tests to verify the correctness of translations. Use XCTest to ensure that UI elements display the correct localized strings.
```tsx
func testLocalization() {
    let app = XCUIApplication()
    app.launchArguments = ["-AppleLanguages", "(fr)"]
    app.launch()
    
    // Check a localized string
    XCTAssertEqual(app.staticTexts["welcomeMessage"].label, "Bienvenue")
}
```

Set up your CI pipeline to automatically fetch the latest translations from server before building the app.
Use scripts in your CI configuration (e.g., GitHub Actions, Jenkins) to integrate this step.

### Final Thoughts
In summary I have chosen **SOLUTION 1** for my translation strategy but there’s no right answer. It varies from project to project. 
As well a lot of changes have been made from iOS15 and Xcode15 that can cause confusion if not updated.

Basic recap (some are optional❓): \
*  Extracted LocalizeStringKeys / NSLocalizedString
*  Turn on Use Compiler to Extract Swift Strings project build setting
*  Internationalize my code with formatting
*  Style my localized strings with Markdown ❓
*  Used Text() to add comments for translation context
*  Integrated localization tests with CI pipeline

By combining these strategies, developers can mitigate the challenges associated with localization in the Apple ecosystem, without the constant need for app resubmissions.
I asked ChatGPT to write the conclusion to this post in style of futurist **`Ray Kurzweil`**. I got pretty fancy analogy.\
Localization stands as a pivotal element within ubiquitous computing ecosystem. Just as the neurons in our brain work effortlessly to interpret and respond to our surroundings, localization ensures that our devices, from mobile phones to cars and even smart refrigerators, communicate with us in our native languages/dialects. This process must be as precise and reliable same as the synaptic transmissions within our neural networks.

<figure class="illustration">
  <img
    src="/blog/images/2024-06-19-all-things-localization/supermeme_localization.png"
    alt="Image showing Markdown in SwiftUI"
  />
  <figcaption>Translating offline without Apple privacy manifest file 🛃</figcaption>
</figure>

*If you have been wondering about some of the tech acronyms here is a [useful list](https://roundsquared.notion.site/Appronym-Glossary-757d24a3000d463b8d5c7664d111a593) by a fellow dev.

I am happy to try new approaches in localization! <a href="mailto:huber.marinae@gmail.com">✉️</a>

---
layout: epic
title: "SwiftUI vs Auto Layout and frames"
date: 2023-02-10
categories: [UI, UX, Animation]
author: "Marina Huber"
---

A
good section of this post is about the research + a project “Diagram” and steps I wish somebody told me upfront. Before I dive into Auto Layout, should I remind you also of legacy in frames 😝, masks — you always had to tell buttons and other controls how big they should be, either by setting their frame or bounds properties or by resizing them in Interface Builder. But it turns out that most controls are perfectly capable of determining how much space they need, based on their — content. 🌈🦄🌈
🕵️‍♀️ 🕵️‍♀️ Note: There is a tool Scherlock — it lets you edit views and layout constraints in real time, simulate running on other devices, and jump straight to the source code, all from your iOS Simulator — zero configuration required only $$ after trial.

Things I want to accomplish:⏎
— Solve errors in layout IB Auto Layout
— Solve errors in code Auto Layout

<!-- more -->
Note: Types of errors in Auto Layout:Unsatisfiable Layouts. Your layout has no valid solution. For more information, see Unsatisfiable Layouts.Ambiguous Layouts. Your layout has two or more possible solutions. For more information, see Ambiguous Layouts.Logical Errors.
🕵️‍♀️ 🕵️‍♀️ Note: There is a tool WTFAutoLayout a place where you can decode the warrning messages.
— Demo the findings in project “Diagram” with IB + code constraints
Things I accomplished: ✅
— When and why to use AutoLayoutThis whole section could be “How to understand blue, yellow and red lines”, but I’ll go into each part separately.


IMAGE HERE

When and why to use IB Constraint?
* 		When we want dynamic content.
* 		Less code more constraints rules
Tip pic below: when to update and when to resolve constraints out of the box (Xcode)
`

When and why to use NSLayout ConstraintNSLayout Constraint API is used when views needs to be synced programmatically. It is robust but stable API. You have three choices when it comes to programmatically creating constraints: You can use layout anchors, you can use the NSLayoutConstraint class, or you can use the Visual Format Language. But what we are interested here mostly is the User interface constraint system and Auto Layout. You can use handy frameworks like Snapkit & TinyConstraint to help with setting programmatic constraints.

## Let’s dive into the important concepts in AL: ⇨ Intrinsic content size

UI Elements that have INTRINSIC CONTENT SIZE:⇨ UILabel, UIButton, Textfield, SwitchesHere is Apples Design Guide
Implementing both solutions works — the intrinsicContentSize method as well as specify the intrinsic Size in Interface Builder. Because function is only determined at runtime, the interface builder needs some placeholder values to visualize the UI. Without entering those placeholder values into the interface builder, you may get some warnings about missing constrains. However, whatever you enter will be used as a placeholder only, the CGSize returned from the method intrinsicContentSize is still the actual value.
Example: the correct way for a view to specify views height is through intrinsicContentSize.


Another concepts in AL: ⇨ Hugging / Compression Resistance
Hugging ⇨ content does not want to grow — maxCompression Resistance ⇨ content does not want to shrink — min
* 		How to remove the yellow lines and warnings:
Tip on concepts above: when yellow lines and warnings in debugger (Xcode) appear. Fixing it with setting last bottom constraint to lower priority is usually the trick.
🤷‍ 🤷‍♀️ 🤟🤟🤟🤟
But this will break the view if the elements need to be animated or moved since every solution animates the constant property and not the priority. Here a workaround is to put a wrapper view, set wrapper.clipsToBounds = true, and animate wrapper’s constraint.
Conclusion
What ever approach you take keep in mind that written in code will be executed in runtime and override the IB rules. Other option that will not create so much confustion is to set all views in code. Down side to that its more timeconsuming and requires third party dependency in most cases. So keep the IB rules of basic structure:
~~ start constraints from top to bottom
~~ every element minimal 3–4 constraints
~~ use wrapper views when animating and self contained views
~~ uiview Subclass should never add constraints to its superview
If you have any suggestions or other comments, let me know below.
Here are some good reference in detail explained.
Auto layout best practices for minimum pain
Auto layout is a great tool, it helps keep our sanity as developer, and it prevent us lazy people from using magic…

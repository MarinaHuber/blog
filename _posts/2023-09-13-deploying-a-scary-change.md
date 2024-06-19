---
layout: epic
title: "Short Swift design patterns — for Newbies"
subtitle: "What to expect when you're expecting to break things"
date: 2023-09-13
categories: [Swift, SOLID]

---

OBJECTS VS. PROTOCOLS or functions
OOP is code that is grouped into object or a class. It is the foundation of lower level Obj-C languages 
(which still holds more than 80% of Xcode features). Equipped with specific characteristics, 
objects have the ability to communicate with other objects and can achieve advanced levels of functionality. 
They can also borrow (e.g. inherit) functionality from other objects/classes 🔡 🔠.
Protocol-Orientated Programming offers an alternate way to organize code. As the name implies, 
the model is based on objects conforming to various rules. Rule-based protocols can also be found in other languages 
\including Java and Objective-C. However, advancements in Swift take Protocols a step further by 
puting interfaces and composition ahead of inheritance. ect (allowing them to store actions (e.g. methods) for conforming types.)

<!-- more -->

- [ ] GENERIC VS. SPECIFIC MODELS
This is central to Object-oriented programming, model abstract or generic things as opposed to concrete ones. 
Still this is pure engagement in uncertainty and fear….Multiple objects need abstraction and old friend complexity 😲😱 — 
DRY and KISS principles. Opposed to Procedural programming like PHP 💤 ideas… for some of these paradigms it is no surprise 
“Google is said to be considering Swift as a ‘first class’ language for Android”
Generic type work as reusable templates. With parameters that must be descriptive, upper camel case names. 
When a type name doesn’t have a meaningful relationship or role, use generic upercase letter such as T, U, or V 🧐.
`enum ResultType<V> { case success(V) case failure(Error) }`
- [ ] DELEGATION VS. NOTIFICATIONS in iOS
Delegation (Cocoa Touch) pattern assumes objects and models have shared-responsibility for actions.Delegates are meant for 1-on-1 relation, meaning that one object has a delegate and sends any messages to that one particular delegate(if the needs of the Delegate are simple consider callbacks). We need be sure we do not create a retain cycle between the delegate and the delegating objects, so we use a [weak self] reference to delegate in asynchronous code.
Notifications are based on a model of “registration and updates” so its basically meant for 1-to-many relation. Notifications create too much indirection and make your code hard to follow 🧐. When you post a notification you cannot be sure which objects will intercept it, which might lead to unexpected behavior in your app. It is generally used when you want to update values in your view controller from any other viewController using didSet property setter — observer (not always an elegant solution).
Conclution: Swift contains multiple paradigms in one language and Linux with server-side Swift is here as well. It is so young but fastly adopted language.

Here are few references: [link] (https://livebook.manning.com/book/classic-computer-science-problems-in-swift/introduction/)


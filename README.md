# ControllerContext

ControllerContext solves the problem of passing data back and forth between iOS view controllers.  The ControllerContext object manages the state between view controllers, reducing the boilerplate code necessary to wire screens together.

# The problem

The state of the art today for passing data between view controllers is to create properties or setters on the next view controller to display and to use the delegate pattern for passing data back to the originating view controller.  

## Apple’s Perspective

The following best practices come directly from Apple’s article “[Coordinating Efforts Between View Controllers].”

1. A destination view controller’s references to app data should come from the source view controller unless the destination view controller represents a self-contained (and therefore self-configuring) view controller. 

2. Perform as much configuration as possible using Interface Builder, rather than configuring your controller programmatically in your code. 

3. Always use a delegate to communicate information back to other controllers. Your content view controller should never need to know the class of the source view controller or any controllers it doesn’t create. 

4. Avoid unnecessary connections to objects external to your view controller. Each connection represents a dependency that makes it harder to change your app design.

## Problems with the approach

- code is required for each data element carried forward
- delegate code is required to pass data from destination view controller back to the source view controller
- it is difficult to pass data back to the originating source view controller with a multi-level workflow
- there is no standard way to pass app specific data to every view controller
- there is tight coupling between view controllers

# The Solution

What if you could have similar flexibility to how data is passed between Web pages with the ability to control the scope of the data passed around?  The ControllerContext object gives you this power and control for passing data back and forth between view controllers.

The magic behind the ControllerContext is the combination of storing key/object pairs of data with the ability to control the scope of the data.

Imagine you have a login view controller that needs to return the userId.  The INNControllerContext instance is created in the MainVC class and passed to the SignupVC instance by calling the method INN_setContext: on the SignupVC view controller.  At this point both the MainVC and SignupVC have a reference to the same INNControllerContext instance.

![Example1](images/MainVCExample1.png)

After the user enters a username and password combination, the userId could be returned from a remote service call, validating the username and password.  The SignupVC sets the userId value in the INNControllerContext instance.  Since the same INNControllerContext instance is shared between the MainVC and SignupVC view controllers, the MainVC has access to the userId when viewWillAppear: fires.  This provides MainVC complete control over when to make UI changes based on the current values stored in the INNControllerContext instance.

![Example2](images/MainVCExample2.png)

### Addressing Apple’s Best Practices with ControllerContext

1. “A destination view controller’s reference to app data should come from the source view controller.”  This is accomplished by passing forward a single reference to a ControllerContext.

2. “Perform as much configuration as possible using Interface Builder, rather than configuring your controller programmatically in your code. “  The ControllerContext approach focuses on simplifying configuration in code.

3. “Your content view controller should never need to know the class of the source view controller or any controllers it doesn’t create.”   By passing a ControllerContext object forward, the destination view controller doesn’t need to know the class of the source view controller. 

4. “Avoid unnecessary connections to objects external to your view controller.”   The only compile time dependency between view controllers is the existence of the ControllerContext.  References to external objects are located in the internal logic of the view controller.  This enables you to more easily change your app design.

# Implementation

## The ControllerContext Object

The ControllerContext class is similar to NSDictionary in that you can set, get, and remove keys and their associated objects.  Keys are NSString objects and values are of type id.

A ControllerContext can also be constructed with an innerContext (ControllerContext) instance.  This enables you to build and pass around context objects with layers like an onion.  

First, create an instance of INNControllerContext.

```objective-c
INNControllerContext *context1 = [[INNControllerContext alloc]init];
```

Next, set an object for a key in a similar way you would use a NSMutableDictionary instance.

```objective-c
[context1 setObject:@"12345" forKey:@"userId"];
```
![context1](images/context1.png)


You can retrieve the object associated with a key by calling the objectForKey: method.

```objective-c
userId = [context1 objectForKey:@"userId"];
```

Now create a second ControllerContext passing in context1 as the inner ControllerContext.

```objective-c
INNControllerContext *context2 = [[INNControllerContext alloc]initWithInnerContext:context1];
```

When setObject:forKey: is called, the key/object pair is stored in the outer most ControllerContext instance referenced.  In the example below the “color” and “size” objects are stored in the context2 instance.  

If the same key was set in a inner ControllerContext, the outer most object will be returned when calling objectForKey:.

```objective-c
[context2 setObject:@"Blue" forKey:@"color"];
[context2 setObject:@"Large" forKey:@"size"];
```
![context1+context2](images/context2.png)

When objectForKey: is called, the logic starts at the outer most ControllerContext instance and walks the inner ControllerContext chain until the first matching key is found.  It then returns the object associated with the key.  If the inner ControllerContext ends with a nil the value nil is returned.

In the example below, the “userId” object will be returned by the inner ControllerContext, which was defined above with the context1 instance.  Both “color” and “size” will return their objects from the context2 instance.

```objective-c
userId = [context2 objectForKey:@"userId"];
color = [context2 objectForKey:@"color"];
size = [context2 objectForKey:@"size"];
```

The ControllerContext instance method dumpToConsole logs to the console the entire ControllerContext hierarchy.  The console output contains the optional ControllerContext name, the hierarchy level, and the key/object pair. 

```objective-c
---------------
1:--- (null) ---
1:color = Blue
1:Size = Large
0:--- (null) ---
0:userId = 12345
---------------
```

## Naming the ControllerContext

When creating a new ControllerContext instance you can provide a name.  The name can be used when setting, getting, or removing key/object pairs to target a specific ControllerContext.  You might use this method to guarantee you are accessing keys that were created with a specific name such as “app” or “base.” 

```objective-c
context1 = [[INNControllerContext alloc]initWithName:@"app"];

[context1 setObject:@"12345" forKey:@"userId"];
  
...
  
context2 = [[INNControllerContext alloc]initWithInnerContext:context1];  // context2 → context1

[context2 setObject:@"ABCDEF" forKey:@"userId"];

userId = [context2 objectForKey:@"userId"] // object returned is “ABCDEF” from context2

userId = [context2 objectForKey:@"userId" withContextName:@"app"];  // object returned is “12345” from context1
```
![context1+context2](images/context3.png)

## Using ControllerContext with View Controllers

The category UIViewController (INNControllerContext) is provided to manage the INNControllerContext instance associated with a view controller instance.   You can use the methods INN_setContext: and INN_context to set and retrieve the INNControllerContext instance.

```objective-c
@interface UIViewController (INNControllerContext)

-(id) INN_initWithContext:(INNControllerContext *)context;
-(void) INN_setContext:(INNControllerContext *)context;
-(INNControllerContext *)INN_context;

@end
```

Below is an example of creating the first INNControllerContext instance and passing it forward to the next view controller.

```objective-c
ColorsVC *vc = [[ColorsVC alloc]init];
  
colorContext = [[INNControllerContext alloc]init];
[vc INN_setContext:colorContext];
  
[self.navigationController pushViewController:vc animated:YES];
```

Below is an example of chaining INNControllerContext instances by retrieving the current INNControllerContext instance from self.INN_context.

```objective-c
SizeVC *vc = [[ColorsVC alloc]init];
  
sizeContext = [[INNControllerContext alloc] initWithInnerContext:self.INN_context];
[vc INN_setContext:sizeContext];
  
[self.navigationController pushViewController:vc animated:YES];
```

The suggested location to retrieve values from the INNControllerContext is in the viewWillAppear: method.  This enables the evaluation of the INNControllerContext data before the view controller is displayed.

```objective-c
-(void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];

  if(sizeContext!=nil){
    NSString *newSize = [sizeContext objectForKey:@"size"];
    if(newSize!=nil){
      //
      // assign data from context to an instance field
      //
      size = newSize;
      
      //
      // update UI here
      //
    }
    
    //
    // you can nil out sizeContext so this section of code is only evaluated when sizeContext has been set
    //
    sizeContext = nil;
  }
}
```

## ControllerContext  Rules

It’s important to know the rules behind how the ControllerContext manages its internal data.

- a ControllerContext can only reference one inner ControllerContext
- by default the key/object pair will be stored or removed from the ControllerContext referenced
- the retrieval of an object by key will traverse the ControllerContext chain walking through inner ControllerContext references until the first key is found or a nil inner 
ControllerContext is reached
- if referenced by name, the set, get, or remove actions will only by executed on the ControllerContext with the matching name
- if multiple ControllerContext instances have the same name, the top most ControllerContext will be used
- an object can be nil for a given key
- a key cannot be nil

## Usage

### Example App

Have a look at the /Example folder.

- Single Screen Example (1) – passes a data back to source view controller
- Single Screen Example (2) – passes a data back to source view controller from a workflow
- Shared Data Example – shares data between tabs and returns tab selected back to source view controller

![Example1](images/ControllerContextScreenGrab.gif)


## Requirements

Designed for iOS 6.0 and above, but I see no reason this shouldn't work with OSX 10.8 and above.

## Current Version

Release 0.1.0

## Installation

CocoaPods coming soon...

For now drop the files in the Classes folder into your project.

## Author

Michael Raber, michael@innoruptor.com, [@michaelraber], [@innoruptor]

## License

ControllerContext is available under the BSD license. See the LICENSE file for more info.

[@michaelraber]:http://twitter.com/michaelraber
[@innoruptor]:http://twitter.com/innoruptor
[Coordinating Efforts Between View Controllers]:https://developer.apple.com/library/IOS/featuredarticles/ViewControllerPGforiPhoneOS/ManagingDataFlowBetweenViewControllers/ManagingDataFlowBetweenViewControllers.html

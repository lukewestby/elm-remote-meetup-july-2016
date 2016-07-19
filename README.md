### Slides

https://slides.com/lukewestby/elm-stuff

### Required modifications to Elm platform code

In elm-stuff/packages/elm-lang/core/VERSION/src/Native/Platform.js, comment out
the function `mainToProgram` and replace it with the following implementation:

```js
function mainToProgram(moduleName, wrappedMain)
{
	return wrappedMain.main;
}
```

This will allow our custom `Program flags` types to slip past the final defenses
against unsafe code and run as-is.


### How does this work?

Detailed written explanation forthcoming! For now, checkout
src/Launchpad/Native/Launchpad.js and src/Launchpad/Launchpad.elm

Also see the video available at https://www.youtube.com/watch?v=qmQo9jtXMSo

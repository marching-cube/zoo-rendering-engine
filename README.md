# Zoo rendering engine (OpenGL ES / iOS)

This is an old project of mine, a mostly pure OpenGL ES implementation of a 3D graphics engine (for iOS).

Some of the fun features:
* multiple fragment shaders (to allow for different kind of light algorithms),
* shadow mapping support,
* very basic animation support,
* wavefront .obj file input.

There really is little practical benefit of going back to this project, other than nostalgia/fun.
New 3D application should probably be implemented in Unity or Apple's SceneKit, for maximal productivity and feature set.

# Work schedule

While I do not plan to put much work into this project anymore, I would like to see it functional and modern again. The minimalistic TODO list is as follows:

* (DONE) make it build and run with the current Xcode,
* (DONE) create a storyboard, 
* upgrade to OpenGL ES 3.0,
* extract rendering code from VC,
* fix the Ferris wheel animation,
* drop some more extravagant features (like Fresnel effect),
* optimise .obj reading code (very slow for not-trivial models),
* add Mac support,
* port to Swift (maybe?).

# Copyrights and other legalities

Most 3D models, other than the really, really basic cube/sphere examples, were provided curtesy of Piotr Smorawski, and are distributed here under the Creative Commons Licence.

# Screenshots

TODO
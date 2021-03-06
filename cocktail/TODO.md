TODO
==============
High level TODO list for the project, there are also TODO in the code for smaller tasks.
This is not an exhaustive list, only used as a remainder

CSS 2.1
==============

missing styles
---------------

### Important

- list styles (list-style, list-style-image...)
- tables styles, table layout

### Less important

- content (with :after and :before pseudo-styles)
- direction, unicode-bidi (useful for right to left languages)
- clip
- counter
- paged media styles

### incomplete styles

- display, misses list and tables related values
- border/outline, only support for solid lines
- outline, no support for "invert" value (inverted color)
- overflow, no implementation of the "scroll" value
- for color style, hsl and hsla not implemented
- for selectors, lang pseudoClass not implemented
- background-attachment implemented as CSS style but not implemented at rendering

### buggy/incomplete implementations

- "clear" style implementation should be improved
- vertical-align, other than baseline, not tested enough
- white-space, not tested enough
- in text, \n and \t are ignored
- text parser in PlainTextParser needs to be rewritten
- anonymous block box property inheritance is buggy

### refactoring/re-packaging

- anonymous text element should be wrapped in anonymous inline box
- graphics context tree should be more isolated when compositing disabled, add a ComposableLayerRenderer for when compositing enabled ?

CSS 3
=========

missing styles (not all CSS 3 styles here, only those that we plan to implement in the year)
--------------

- border-radius
- box-shadow / text-shadow
- gradient

### nice to have

- media queries
- font-face

### incomplete styles

- background shorthand is at level 2.1 and not 3 of CSS

### buggy implementations

- CSS transition, only style with 1 float value works now (like width, height...), no color or matrix transitions for instance.
- CSS transform (2d), mostly implemented but currently broken.

HTML 4
============

### features

- managing html entities
- implement text selection

### missing tags

- select
- button
- embed

### nice to have

- plugin system for object and embed tag
- true html parser (instead of haxe xml parser)
- iframe

HTML 5 
==============

### nice to have

- canvas 2d

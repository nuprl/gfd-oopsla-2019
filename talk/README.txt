talk
===

22 minutes (including questions)
Date: 2019-10-24
Time: 17:07 -- 17:30

TODO

- [ ] outline
  - [X] basic ideas (no slogan)
  - [X] design a plot*/pict example ... untyped handles drawing + interactions,
        typed API on top of the complex object, untyped client submits callback
        at init-time and displays later
        display can: give bad input to callback, get bad result from callback,
         and have callback misuse the input! All three deal with wrapped
         values (->, MouseEvent).
        * https://alex-hhh.github.io/2018/03/interactive-overlays-with-the-racket-plot-package-update.html
        ... may
        probably, avoid TS semantics
- [X] draft slideshow slides
- [ ] give presentation
  - [X] torture (2019-10-18)
  - [ ] oopsla (2019-10-24)
- [ ] blog post

- - -
# TAKEAWAYS

- cannot assume types are correct
- TS cannot distinguish ... neither can GG for that matter
- CM does distinguish,
- more generally, helpful to view through the lens of ownership semantics
- need monitors for BC (transient fails)

# Contributions
- CM spelled out
- important distinctions in GT systems
- ownership semantics, able to state properties about blame

# Technical Content
- language model
- ownership semantics
- HOW TO LIFT
- properties

# Lower-level items to communicate
- N T A
- types can be wrong
- idea of labeled semantics ... maybe the laws
- table 1
- type soundness not enough; A is the proof
- an ownership
- how to lift
- ->d interlude to illustrate types being wrong

# Visual plans
- illustrate program as bipartite graph
- remove names from boundaries
- 


## ps

tried looking at DefinitelyTyped for a motivating issue, searched for "callback"
 in open & closed issues, found 13 pages total ...

- wrong parameter type 2x
  https://github.com/DefinitelyTyped/DefinitelyTyped/issues/33561
  https://github.com/DefinitelyTyped/DefinitelyTyped/issues/35242
  https://github.com/DefinitelyTyped/DefinitelyTyped/issues/37695
  https://github.com/DefinitelyTyped/DefinitelyTyped/issues/16773
  https://github.com/DefinitelyTyped/DefinitelyTyped/issues/24817
  https://github.com/DefinitelyTyped/DefinitelyTyped/issues/25439

- https://alex-hhh.github.io/2019/09/map-snip.html
  map-widget package

- fonts
  https://www.fontspace.com/the-fontry/fha-condensed-french
  https://www.fontspace.com/cumberland-fontworks/kentucky-fireplace
  https://www.fontspace.com/sharkshock/enchanted-land
  https://www.fontspace.com/rick-mueller/primitive
  https://www.fontspace.com/gemfonts/treasure-map-deadhand
  https://fontsbytes.com/w/whipsmart/

## 2019-10-07 notes from MF

Maybe note that type soundness in erasure works for
 the closed world
Except for typescript

[X] (Later) ICFP already said that T and N were different
 in that T not checking everything, but didn't fully
 explain, we learn more via CM

[X] Don't do an increasing function plot, looks like
 performance

[X] Need to introduce Amnesic later, near the end
 before the table ... proof that "TS does not
 distinguish" is complicated, requires a counter
 semantics

[X] At the error, need to say "assuming the interface
 is correct" and point that out as the hint that
 types are wrong, and say clearly "types can be
 wrong" (its a fact not a slogan)

[X] Two takeaways
- GT MT challenges fundamental understanding of
  types and what they mean ... normal lang sits
  on an untyped runtime and we never thought of
  that
- Concrete takeaway, there is more to types than
  type soundness; there is CM; only some type sound
  systems satisfy CM

[X] New, second title slide: a careful analysis of the
 design space of gradual typing, contribute another
 design dimension

## 2019-10-09 notes from Christos

[X] BSBC note they use same ideas as CM

[X] focus on example in the beginning, but near
end come back to TS not enough as "... in general,
need sophisticated proof to show ... constructed
A semantics ..."

[N] acknowledge performance of CM, to motivate other
systems a little more; maybe do the same with TS

[ ] BSBC ... how can we semantically describe ...
precise description of what we didn't see


- - -
# SCRIPT

## Short

- seeking mixed-typed world, support large programs,
  need a GT system to support
- judge by TS, but doesn't distinguish one that supports modular reasoning
  from one that only supports 1-hop ... need to explain transitive edges
  vs lots of 1-hop edges
- demo with 2-hop graph,
  use higher-order API; off the stack
  (lack of modular reasoning)
- FIRST implications for detecting errors, big deal, explains why this is
  a useful property (idea should come early)
- second explanation for error
- ... our other contribution 

....

- TS says -> works
- CM for the rest
- that the main result, about detecting errors, of course you may also want to debug aka blame
- state of art in large chunk of GT community is the blame theorem
  ... summarized in slogan
- well broken beyond repair ... lets change the example in a small way
  so the type is incorrect ....
- gradual types CAN lie and when they do, need to know all components
  typed or untyped responsible for the value
- unless you have CM because well-monitored types cannot lie
  (is the cost reasonable)


## Long

This paper takes a close look at the design space of languages that mix typed
and untyped code. Lets start with the high-level context. The reason we're
interested in gradual types is to improve existing untyped code by adding type
information --- and ideally nothing else. The goal is to be able to start with
some untyped code on the left, add types to a few components and get something
like thi picture on the right, where we mix typed and untyped code. We don't
need a special dynamic type to reach this mixed-typed situation so far this
talk when you see a T think simple types --- all we really need are numbers,
pairs, and functions. The question is, once we have a mixed-typed program, what
happens when we run it? In particular, how do the types constrain the behavior?
There are many answers to this question, both in the form of medls in the
literature and implementations for untyped languages. The trouble with these
answers is theyre too diverse for a scientific comparison. Although they all
pursue the same mixed-typed vision, its not clear how they relate in a common
framework .... want to compare the TypeScript approach to the Hack approach
without comparing JavaScript to PHP. So this brings us to the broad context of
this paper --- to formally characterize the landscape, or the design space.

One part of this space is already well-understood so lets start there, at this
purple region for optional typing. Informally, optionally-typed languages are
characterized by the fact that typed code cannot trust the types. For example,
suppose we have a typed function that expects a pair of numbers and does
something with the first element. In a mixed-typed language, we can call this
function from untped code. Since the untyped code is untyped, it may pass any
argument to our typed funciton. So what happens if we pass the number 9? In an
optionally typed language the types are meaningless at runtime and so we
execute the body of the funciton with a bad input ... the best we can hope for
is an error like this, that says the number 9 doesn't have a first element.
Alternatively might not get an error. Clearly, ignoring types has consequences
to be aware of, so it would be useful to have a farmal characterization and
thankfully we have one --- optionally typed languages are characterized by a
lack of type soundness. Now we can see that everything outsibe the purple is
characterized by a non-trivial TS theorem.

The main focus of the paper is this green region. In the languages here,
informally, untyped code cannot trust the types. Time for another example.
Suppose we have an untyped library for making interactive plots; a client can
use this library to display a plot, accept a mouse click, and then draw an
image on the plot. More concretely, here are three modules. On the left is our
untyped library; it exports a Click Plot class whose constructor expects a
callback for handling mouse events. In the middle, the API module defines a
type for the class. Then on the right, we have an untyped class that defines a
callback function and builds a plot. Before we get to the details, I want to
point out this is an ideal use case of gradual typing. There's untyped code on
the left ... it works and we want to keep using it. The types in the middle are
a thin layer ... minimal work to document the existing behavior and get backt
to real work. The client best of all can rely on these types to speed up the
process of writing a script. Since it's a perfect example, its surprising how
quickly things fall apart. Unfortunately for the client.,th the types have a
bug. The type for the onClick callback tells the client to expect a pair of
numbers, representing a point on the plot. Below, the type for the mouseHandler
method says it receives a mouse event object. A mouse event is not a pair of
numbers, yet if we move to the library the method passes its event directly to
the callback. ANd so, the untyped library tries to send a mouse event value to
an untyped function that expects a pair of numbers. What happens next? Well, in
a TS language where untyped code cannot trust the types we're going to invoke
the function on the bad input ... the best outcome we can hope for is an error
that says the input is not a pair and stops the program before it silently
computes a nonsense result. Of course the real problem is this type in the
middle which misled he client but its up to the programmer to figure that out.
Clearly this is not good and we'd like to characterize languages where this can
happen. Abstractly we have three components in this program and two channels of
communication between them. A callback flows along the channels and thereby
opens a new channel between the untyped components. The key question is whether
types guard this new channel. As we've seen, one answer is no tpes don't guard
the callback channel ... and don't need to ... because it connects two untyped
components. Put another way, TS only requires protection on channels into typed
code.

Hang on. I've been talking about type soundness as though its an all-or-nothing
property. But if you saw me last year in St. Louis, you know theres a range of
TS theorems for mixed-typed languages, and these differences in TS have
implications for different behaviors. For everyone else here's a 1-slide
summary of what you need to know. Natural and Transient are names for two
mixed-typed semantics. Both claim to be type sound. For Natural TS means it
preserves full types. For Transient TS is a weaker property, it preserves type
constructors. In terms of our landscape, Natural is a semantics where untyped
code can trust the types and Transient is one where they cannot. So we want to
distinguish these, but TS does a fine job. To show thot TS is not strong enough
in general, in this paper we construct a counterexample semantics called
Amnesic that preserves full types but has the same behavior as Transient. That
means Amnesic falls in the green region where untyped code cannot trust the
types, and it also falls in a blue region for full type soundness. So type
soundness cannot distinguish languages where untyped code cannot trust the
types. This is the central argument of this paper. To show that a mixed -typed
language guards all boundarise between typed and untyped code; and this
property is called complete monitoring. Back to our plot example, if we run
this in a language that satisfies CM then we're guaranteed an error when the
library invokes the callback. Technically, the library has an obligation to
send a pair of numbers and a language that satisfies CM checks all obligations.
In a larger program, CM guarantees that types guard all channel across typed
code, and this way any mismatch in going to be caught. Back to the landscape,
CM is the distinction we are looking for. Lets put the results so far into a
table. In the paper we look closely at three semantics: Natural, Transient, and
Amnesic. Natural is the only one where untyped code can trust the types. Our
Amnesic counterexample shows that TS is not enough to capture the distinction.
In the paper, we use a syntactic technique to prove that only natural satisfies
CM.

So far all this is about the ability to detect errors across a channel of
communication. If an error occurs, though, we want to identify the relevant
channels. Lets go back to the plot example, we saw that CM guarantees an error
when th ecallback is invoked on bad input. What we really want, though, is an
error that points to the boundary between the library and API --- blaming the
library for the bad input, but acknowledging the type may be incorrect. With
this kind of error the programmer knows exactly where to start debugging. In
general, for languages that do not satisfy CM, its impossible to trace an error
back to ONE boundary since there could be many uncheckd obligations that a
value passed through. The challenge for a blame algorithm is to find the
responsible channel. We formulate this challenge as soundness and completeness
properties. A language satisfies blame soundness if tis guaranteed to report
only responsibel boundaries --- though it may miss some. And a language
satisfies blame completeness if tis guaranteed to report all responsibble
parties, though it may inclide false positives. The goal, of course, is to be
sound and complete. We tried to prove these properties for our three semantics
and the surprising outcome is that the Traniest blame algorithm is neither
sound nor complete --- it may report irrelevant channels and it may miss some
critical channels. With Amnesic we show that soundness and completeness can be
recovered by adding proxies. It's an opend quentios whether a semantics can be
BS and BC without proxies.

In conclusion let me remind you that almost every typed language depends on an
untyped runtime or an FFI. This untyped code falls outside the standard
metatheory. Gradual typing extends the theory to acknowledge untyped code, and
doing so challenges our understanding of types and what they mean. Abstractly
there is more to types than type soundness. Conceretely CM is the property you
want in order to reason about programs that compose typed and untyped code.

- - -
# TORTURE

TOP COMMENTS
- forgot what your first sentence was, but its unclear what's the thesis of
  the talk
- "migratory" has nothing to do with rest of talk
- before you even get to the code, needs to be clear what to expect
- first occurrence of the table sounded like a conclusion, and then the blame
  stuff sounded tacked on
- how does this CM relate to the idea for contracts?
- say what other people are missing about blame
- is Amnesic supposed to be useful? in the beginning thought this was
  analytic work, but then it sounds like you have something new so what's
  going on? is Amnesic making the world better?
- what does it mean to detect the same errors as Transient?

Julia:
- I was lost in general ... what's Natural? what's Transient? ... what's it
  mean that untyped code cannot trust types? ... got no meat from the
  statements
- table was a surprise, I thought Amnesic would be the thing that gives CM
- plot hard to follow, couldn't tell what types went with what parts,
  not sure about "constr"
- moving pointer impossible to follow
- plot: what is h doing, where does it go?
- is CM related to standard monitors?
- forgot what your first sentence was, but its unclear what's the thesis of
  the talk
- what does it mean to detect the same errors as Transient?

Cameron:
- need to see how Amnesic is different ... run the plot on all three?
- how does this CM relate to the idea for contracts?

Artem:
- what is the problem? can you say so in the beginning?
- is Amnesic a new approach? appeared very suddenly ... if you made the problem
  explicit, maybe the new semantics would be more expected
- is Amnesic supposed to be useful? in the beginning thought this was
  analytic work, but then it sounds like you have something new so what's
  going on?
- TS theorems ... thought you said A soundness is similar to Retic, but then
  the table says it matches Natural so what?
- explain _constr_ ... code went too fast, syntax is unfamiliar ... the
  diagram with channels was hard to get U -- T -- U

Michael:
- lost at "we only need Num Pair Fun" didn't make sense in context
- plot: can the client do some reasoning that depends on the wrong
  behavior? maybe the type promises a union of 3 things but a 4th comes
  in and untyped code goes down a surprising else branch
- maybe call immediately, don't need mouseHandler? (stack trace ... but then,
  show the stack trace idea)
- you spoke negative properties for Amnesic (fails CM) but described on slide
  with positive properties ... unclear how much to care about it
- landscape, why does CM bubble go outside the full-TS bubble? (bug!)
- distinguish CM from BC
- say what other people are missing about blame

Leif
- first occurrence of the table sounded like a conclusion, and then the blame
  stuff sounded tacked on
- talk advertises CM too much for something that's not new
- landscape jarring transition from "migration" ... I thought the mixed program
  was the landscape ... like we started with baby steps then took a big jump
- mouse highlighting was bad bad
- showed callback once & jumped to code ... would be better to build up
  what's needed ... try drawing arrows
- "migratory" has nothing to do with rest of talk

Stephen:
- before you even get to the code, needs to be clear what to expect
- the map never showed the connection between languages and these semantics
- I think the big points were:
  - prev paper about TS
  - turns out, languages blessed by TS have problems
  - need CM to catch some of these problems
- but then CM didn't appear until late so its not clear what the paper's about
- I'd reduce the landscape. People understand there's a bunch of languages.
- get into the problem ... this language is TS what the hell going on!
- glossed over ICFP ... better to go into some detial
- then come back to example [you did] show where we end up with new props
- landscape conveys very litte info at a glance, impossible to remember
- need a concrete code example, be clear whats about to go wrong, people
  should be agreeing as we show the code

- - -
# QUESTIONS

Q. what about the gradual guarantee? why do we need more?

GG doesn't distinguish, in fact search for Michael Vitousek's dissertation
will find a proof that Transient satisfies GG

GG is about the dynamic type, orthogonal


- - -

Q. hasn't CM been applied to gradual typing before?

that's right, other research teams have proved complete monitoring to validate
designs, esp for typed racket

we show WHY its a good tool to validate --- because it captures important
distinctions that we don't otherwise know how to articulate

we also show that CM useful even when it fails, to make weaker statements about
how the language can explain errors to programmers


IN A SENSE couldn't ask the question without the
common model ... gf didn't get to it but noted with
examples there is something more

- - -

Q. did you really prove the slogan, that "well-monitored types cannot lie"?

goood question ... (don't say the slogan in the talk!)
depends on what a lie is
to be precise, we proved that if you interpret types as a claim between a
sender and client, then the sender gets fully checked against the claim


- - -

Q. what is the second half to your slogan?

Of course. ".... // if the specification is correct."
We give ownership laws; they have intuitive flavor, some precedent, but maybe
 these are not the laws you want. Transient in particular, is sound with
 respect to a heap-based ownership model.
Some discussion in paper, details (sans explanation) in the tech report.

- - -

Q. what happens at a direct U-U boundary?

no obligations, so no check, can switch ownership
in the model these are all part of one "component"

(the slides are not perfectly faithful to the paper)


- - - 

Q. Blame theorem?

Technically, says errors manifest by less-precise value entering more-precise
code.

Justifies slogan, but that slogan assumes types are correct!

- - -

Q. CM can really trust the types?


- - -

Q. Why bother with transient?

Economics! Why bother with optional? Economics!
Scarce developer resources, scarce time to wait for compute

- - -

Q. How is this different from ESOP'12?

Same theorem as before. (Need to anticipate in the talk.)

- - -

Q. Why not GTT?

Axiomatic vs operational

Want to be able to define all kinds of semantics; don't want to limit defn's
to the valid ones.

- - -

Q. Is "complete" monitoring different from blame "complete"?

Q. When would we want blame complete without complete monitoring? Can we see
   a simple example?

- - -

Q. How unsound / incomplete is Transient in practice

the unsoundness comes from ...
the incompleteness comes from ...
with that in mind, I let you decide how it may go in practice

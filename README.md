oopsla-2019
===

Submission to OOPSLA 2019

Submission Deadline 2019-04-05

Submission Page Limit 23 pages 10pt font excluding references and appendices

Author Response Deadline 2019-06-11
https://oopsla19.hotcrp.com/paper/23

Second Round 2019-08-15
https://www.conference-publishing.com/Instructions.php?Event=OOPSLA19

Second Round Page Limit 27 pages excluding references

Final Decision 2019-09-01

Camera Ready 2019-09-06

Conference 2019-10-20 Athens, Greece



Build
---

To build the paper:

- run `make`
- open `paper.pdf`


Organization
---

- `paper.tex` : main file
- `package.tex` : LaTeX package imports
- `def.tex` : LaTeX macro definitions
- `bib.bib` : BibTeX bibliography
- `pf2.sty` : modified source for a LaTeX package for writing proofs
- `tr.tex` : technical appendix
- `talk/` : Racket slideshow slides


Typed/Untyped Examples
---


### https://github.com/racket/typed-racket/issues/189

TR bug report by me (Ben) complaining that the TR contract optimizer puts holes
in a type interface between untyped clients.


### https://github.com/racket/typed-racket/issues/636

TR bug report by me (Ben) noting that require/typed between typed modules does
not enforce all the necessary types

### https://groups.google.com/d/msg/racket-users/rfM6koVbOS8/cKc6YxVqBwAJ

> Seeing all the options, I believe that my favorite one is to type only at the
> border of my code, leaving the implementation in untyped Racket.  By dropping
> the contract cost, code still goes fast, and the borders are type-checked.
>
> For the meantime, I'll be doing this on new code
>
> #lang typed/racket[/unsafe maybe]
>
> (module 'hundred-lines-of-untyped racket
>    ...
>    (define (my-function A B C)
>        ...)))
>
> (require/typed/provide 'hundred-lines-of-untyped
>    [ my-function (-> NICE TYPED ARGS RESULT) ])
>
> If I understand this correctly, the unsafe version will perform the same
> static checks on callers of the functions published by (provide) but not
> incur contract cost.

### https://unitscale.com/mb/technique/dual-typed-untyped-library.html

> The unavoidable wrinkle in a mixed typed / untyped system is the interaction
> between typed and untyped code. Most Racket libraries are written with
> untyped code, and Typed Racket—now shortening this to TR—has to use these
> libraries. TR’s job is to insure that your functions and data are what they
> say they are. So you can’t just toss untyped code into the mix—“don’t worry
> TR, this will work.” TR likes you, but it doesn’t trust you.
>
> [... require/typed ...]
>
> This works well enough, but it has a cost: in this case, TR has to perform
> its typechecking when the program runs, and it does so by converting these
> types into Racket contracts. The added cost of a contract isn’t a big deal if
> you use the imported function occasionally.

### https://stackoverflow.com/questions/2503444/what-is-your-strategy-to-avoid-dynamic-typing-errors-in-python-nonetype-has-no

> A bug that doesn't crash my app is the most horrible situation imaginable.


### https://medium.com/@clayallsopp/incrementally-migrating-javascript-to-typescript-565020e49c88

> One of the benefits of moving your app over piecemeal like this is you can
> avoid adding such tooling complexity until you’re ready.


### https://stackoverflow.com/questions/26427722/calling-properly-typescript-code-from-javascript

Calling JS from TS ... Answer = no problem its JS


### https://plus.google.com/+DouglasCrockfordEsq/posts/MgzNUSTwjRt

Douglas Crockford:

> Microsoft's TypeScript may be the best of the many JavaScript front ends. It
> seems to generate the most attractive code. And I think it should take
> pressure off of the ECMAScript Standard for new features like type
> declarations and classes. Anders has shown that these can be provided nicely
> by a preprocessor, so there is no need to change the underlying language.
>
> I think that JavaScript's loose typing is one of its best features and that
> type checking is way overrated. TypeScript adds sweetness, but at a price. It
> is not a price I am willing to pay.

### https://walkercoderanger.com/blog/2014/02/typescript-isnt-the-answer/

> My prediction is that in time people will come to realize TypeScript doesn’t
> eliminate the JavaScript minefield and only makes it more confusing by
> providing the illusion of safety. 

### https://medium.jonasbandi.net/here-is-why-you-might-not-want-to-use-typescript-50ab0d225bdd

> TypeScript does [not] not not make "invalid states unrepresentable"

### http://blogs.perl.org/users/rafael_garcia-suarez/2011/10/why-dart-is-not-the-language-of-the-future.html

> Ah; OK. In other words the "static checker" is a lint-type development aid,
> not a language feature. Worse, that means you can write functioning programs
> with wrong (and misleading) type declarations, and still run them. Types have
> no effect whatsoever on your program's semantics.

### http://definitelytyped.org/

> The repository for high quality TypeScript type definitions

(but these are really for JS -> TS)

On 2019-03-02:

- 59224 commits
- 153 open pull requests, 28124 closed
- 2573 open issues, 2681 closed
- 6308 index.d.ts files

### https://github.com/racket/gui/issues/86

Anti-example ... issue says that enforcing previously-unenforced plot types
led to unacceptable slowdowns. Resolution: change to no-check lang.

### pict3d

#### 6 opengl bugs

- https://github.com/jeapostrophe/pict3d/issues/10
- https://github.com/jeapostrophe/pict3d/issues/8
- https://github.com/ntoronto/pict3d/issues/33
- https://github.com/ntoronto/pict3d/issues/34
- https://github.com/ntoronto/pict3d/issues/21
- https://github.com/ntoronto/pict3d/issues/5

Out of (+ 8 21 2 10) = 41 total bugs


### Examples of libraries with typed interfaces

search for '/typed' and/or 'typed/' in the docs:
    <https://docs.racket-lang.org/search/index.html?q=%2Ftyped>

Included in Typed Racket:

- typed/file/md5
- typed/json
- typed/net/dns
- typed/pict
- ....

Third-party, with a wrapper module:

- syntax-sloc
- mutt
- zordoz

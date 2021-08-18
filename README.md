
## Estimate traveling distances when typing

Why? https://www.youtube.com/watch?v=Mf2H9WZSIyw

## Install it

Install a recent ruby and download the `typeset.rb` script

## Use it

You can use it interactively by simply launching the script:

```bash
ruby typeset.rb
```

Each newline will trigger the estimations, and you can exit with `Ctrl-D`

Alternatively, you can use read from a flat file:

```bash
ruby typeset.rb -o per-line-distances.tsv -i some-file.txt
```

Use `-h` to see all the available options:

```bash
ruby typeset.rb -h
```

## Typing methods

In Matt's video, the distances are estimated according to the options:

```bash
ruby typeset.rb --onsite -1
```

That is: using only one finger and starting at the initial letter of the word.
The default of this script is: type using two fingers (`-2`) starting at the
positions F and J (`--no-onsite`).


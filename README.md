
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

Alternatively, you can use STDIN from a flat file:

```bash
ruby typeset.rb -o per-line-distances.tsv < some-file.txt
```

Use `-h` to see all the available options:

```bash
ruby typeset.rb -h
```


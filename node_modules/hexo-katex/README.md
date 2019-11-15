# hexo-katex

Use KaTeX to display math in Hexo sites.

## Installing

Install [hexo-renderer-pandoc](https://github.com/wzpan/hexo-renderer-pandoc) and config math engine.

```
pandoc:
  mathEngine: katex
```

Then install hexo-katex.

```
npm install hexo-katex --save
```

KaTeX css link will be automatically injected into post, if you want to add it manually, modify `_config.yml`.

```
katex:
  css: false
```

When KaTeX encounters an unsupported command, it will abort a rendering process. You can change the behavior by modifing `_config.yml`.

```
katex:
  throw_on_error: false
```

You can define macros like that:

```
katex:
  macros:
    \hash: \mathop\mathrm{hash}
```


## Writing

Inline math `$E = m * c^2$`

Display math

```
$$
E = m * c^2
$$
```

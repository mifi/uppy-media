# uppy-media

Images and videos for the [uppy.io](https://uppy.io) blog and docs. The website
itself lives in [transloadit/uppy](https://github.com/transloadit/uppy) under
`website/`.

Files are served through Transloadit's Smart CDN, which imports them from this
repository's `main` branch:

```
https://uppy-io-static.tlcdn.com/static/<path in this repo>
```

For example, `img/blog/2.0/uppy-performance-after.gif` is
`https://uppy-io-static.tlcdn.com/static/img/blog/2.0/uppy-performance-after.gif`.

## Adding media

1. Optimize first: re-encode videos and GIFs (e.g. to MP4 or WebM at web
   quality), compress images. The CDN serves files exactly as committed.
2. Add the file under `img/blog/<post>/` with a **new, unique filename**, by PR
   (GitHub's web upload works fine, no clone needed).
3. Once merged, open the CDN URL once to check it works, then merge the website
   PR that uses it.

Never overwrite, rename or delete a file that is in use: the CDN caches files
for a year, and existing pages link to them. Add a new file instead.

## History

The initial files were copied from the archived
[transloadit/uppy.io](https://github.com/transloadit/uppy.io) repository at
commit `67dd419` by `scripts/import-from-uppy-io.sh`, keeping only the media the
website still links to.

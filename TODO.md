# TODO

Traking issues and missing features.

## Features

- Documentation has to be expanded
- Migrate to [yq](https://github.com/mikefarah/yq) and yaml configuration files.
- Rather than stop if there is a problem in downloading or uploading, it's more efficient to log what wasn't downloaded (and consequentely uploaded) and continue with the list
  - Mark down each failed download/upload in a list that can be used later to target only failed resources

## Issues

- Pass paths to scripts, don't assume where and how they are being passed

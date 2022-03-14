# `coq-tinyram`

Current plan: advance the `vnTinyRAM` emulator in coq, figure out the rest of it later. 

`vnTinyRam` description: `papers/TinyRAM-spec-2.000.pdf`

The implementation relies **heavily** on Xia et. al. 2020. Some code is plagiarized [see here](https://github.com/DeepSpec/InteractionTrees/blob/master/tutorial/Asm.v).

## Build and launch emacs for interactive session 

We proceed by `nix` flakes and rely on `nix-direnv`. 

0. [Install `nix`](https://nixos.org/download.html)
1. [Install `nix-direnv`](https://github.com/nix-community/nix-direnv)

```sh
direnv allow
nix build
./result/bin/emacs
```

## Compile `.v` files

```sh
nix shell # ? 
dune build
```

## Mess around

Open up one of `theories/*.v` and type `C-c C-ENTER` to start the interactive session. Recall that `C-` is emacs-speak for holding the `CTRL` key.

## Customize

Explore `nix/doom.d/*` to get a feel for what tools you've been given and things you might want to change, disable, or add. 

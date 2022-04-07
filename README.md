### cleanPlutusProject
This is a clean cabal structure for plutus development. You can clone this to setup a new project fast.

### How to setup a new project
Git clone the repo and run the `setup.sh` bash script from a directory where you want to configure a new project.

### How to use
In the `cabal.project` file there is a reference made to the `/Input-output-hk/plutus-apps` github repository. With this reference there is also a version specified using a `tag`. Clone the plutus-app repository and `git checkout "INSERT referenced TAG HERE"`. Now you can open a `nix-shell` in that repository, this will preload all important dependancies that you will need in the development of your plutus project (the first time takes 10 minutes). If you now change directory to your just initialized clean plutus project folder you can compile the `app/Main.hs` file by running `cabal run`.

### Folder structure
├── app
│   └── Main.hs                         (The main program that is run when you `cabal run`
├── cabal.project                       (Contains references to dependancies)
├── cleanPlutusProject.cabal            (Contains all the basic information about your project)
├── LICENSE
├── plutus                              (A directory to store files created by the `app/Main.hs` program like compiled plutus core)
├── src                                 (The directory to store all your Haskell modules and Plutus validator scripts)
│   └── Utils.hs                        (some basic tool that help compile to plutus core and encode datums and redeemers)
└── testnet                             (A folder where you can test your scripts on testnet and store/construct transactions)
    └── keys

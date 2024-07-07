# Changelog

## [0.4.7](https://github.com/cameronraysmith/nixpod/compare/v0.4.6...v0.4.7) (2024-07-07)


### Bug Fixes

* **containers:** disable sudoImage runAsRoot ([45ce23b](https://github.com/cameronraysmith/nixpod/commit/45ce23b9ff7e2376608d4211938144e0a714d328))
* **flake:** disable pamImage runAsRoot ([ba4ceb4](https://github.com/cameronraysmith/nixpod/commit/ba4ceb407ebbbb985b03beab3597f9f3cac393ed))

## [0.4.6](https://github.com/cameronraysmith/nixpod/compare/v0.4.5...v0.4.6) (2024-07-07)


### Bug Fixes

* **flake:** remove unused intermediate nixImage ([ad81280](https://github.com/cameronraysmith/nixpod/commit/ad812801d63b9ff7259b226d690c88730243dc0b))

## [0.4.5](https://github.com/cameronraysmith/nixpod/compare/v0.4.4...v0.4.5) (2024-07-06)


### Bug Fixes

* **cid:** install system dependencies ([2b577b3](https://github.com/cameronraysmith/nixpod/commit/2b577b3070c240a9657c2d23e38dcfc07fcee0cf))
* **containers:** compress layers with zstd ([f8dc29c](https://github.com/cameronraysmith/nixpod/commit/f8dc29c79d0e55cb82b55522eb8d259c74c43f4b))
* **containers:** parameterize compressor ([4b7b354](https://github.com/cameronraysmith/nixpod/commit/4b7b3547d0beed9664f3895277de058a7194361b))
* **flake:** do not compress base images ([38a1bed](https://github.com/cameronraysmith/nixpod/commit/38a1bedcd13b12ddcc921fb233dd3a4ed6cbb3e9))
* **flake:** make nixpod with nix db ([071f601](https://github.com/cameronraysmith/nixpod/commit/071f60181acfb43d81b5e24cbc1696cd5019300b))
* **flake:** make zstd available to builder ([1eefb0f](https://github.com/cameronraysmith/nixpod/commit/1eefb0f2c718785def008380fbabb83e4330edca))
* **flake:** use zstd to compress all inherited images ([1ec7f2f](https://github.com/cameronraysmith/nixpod/commit/1ec7f2f7e57b65ca72a9940657b37e6d7d5335b8))

## [0.4.4](https://github.com/cameronraysmith/nixpod/compare/v0.4.3...v0.4.4) (2024-07-03)


### Bug Fixes

* **home:** increase command_timeout to 2s ([1205728](https://github.com/cameronraysmith/nixpod/commit/1205728ff581c6beba76e9fcc952b0d26907a006))

## [0.4.3](https://github.com/cameronraysmith/nixpod/compare/v0.4.2...v0.4.3) (2024-07-03)


### Bug Fixes

* **atuin:** enable daemon ([aaf95ac](https://github.com/cameronraysmith/nixpod/commit/aaf95ac492c676fe704d711d8de52601e650eab8))
* **code:** disable code-managed environment activation ([8bea974](https://github.com/cameronraysmith/nixpod/commit/8bea9749dff9307e74bf1962d7e9a1f480e09428))
* **flake:** enable atuin daemon service ([1e080de](https://github.com/cameronraysmith/nixpod/commit/1e080de51cd0dcb129f92d21db63b9427cbc1c25))

## [0.4.3-beta.1](https://github.com/cameronraysmith/nixpod/compare/v0.4.2...v0.4.3-beta.1) (2024-07-03)


### Bug Fixes

* **atuin:** enable daemon ([aaf95ac](https://github.com/cameronraysmith/nixpod/commit/aaf95ac492c676fe704d711d8de52601e650eab8))
* **code:** disable code-managed environment activation ([8bea974](https://github.com/cameronraysmith/nixpod/commit/8bea9749dff9307e74bf1962d7e9a1f480e09428))
* **flake:** enable atuin daemon service ([1e080de](https://github.com/cameronraysmith/nixpod/commit/1e080de51cd0dcb129f92d21db63b9427cbc1c25))

## [0.4.2](https://github.com/cameronraysmith/nixpod/compare/v0.4.1...v0.4.2) (2024-06-27)


### Bug Fixes

* **home:** disable atuin auto_sync ([5f577bf](https://github.com/cameronraysmith/nixpod/commit/5f577bfc06178c2875150c18c4d5d0beec127239))
* **home:** set direnv warn_timeout ([993c9b2](https://github.com/cameronraysmith/nixpod/commit/993c9b2c22879fb8faa3a3f3615a404cbc656a1d))

## [0.4.1](https://github.com/cameronraysmith/nixpod/compare/v0.4.0...v0.4.1) (2024-06-26)


### Bug Fixes

* **flake:** add init script to install code-server extensions ([6c4a15f](https://github.com/cameronraysmith/nixpod/commit/6c4a15fd7d1565a633ec01e52a7dcd5eaa2398ad))
* **flake:** initialize code-server user settings ([4a54e0a](https://github.com/cameronraysmith/nixpod/commit/4a54e0ab4f5b1346f34122bfbf72d77f9213f1ff))
* **flake:** update code-server extensions ([4a79dd7](https://github.com/cameronraysmith/nixpod/commit/4a79dd71071c97c3223e93a919315cc538121534))
* **flake:** whitespace ([ceabff2](https://github.com/cameronraysmith/nixpod/commit/ceabff253300e4780abea581f701f71f7d117570))

## [0.4.1-beta.1](https://github.com/cameronraysmith/nixpod/compare/v0.4.0...v0.4.1-beta.1) (2024-06-26)


### Bug Fixes

* **flake:** add init script to install code-server extensions ([6c4a15f](https://github.com/cameronraysmith/nixpod/commit/6c4a15fd7d1565a633ec01e52a7dcd5eaa2398ad))
* **flake:** initialize code-server user settings ([4a54e0a](https://github.com/cameronraysmith/nixpod/commit/4a54e0ab4f5b1346f34122bfbf72d77f9213f1ff))
* **flake:** update code-server extensions ([4a79dd7](https://github.com/cameronraysmith/nixpod/commit/4a79dd71071c97c3223e93a919315cc538121534))
* **flake:** whitespace ([ceabff2](https://github.com/cameronraysmith/nixpod/commit/ceabff253300e4780abea581f701f71f7d117570))

## [0.4.0](https://github.com/cameronraysmith/nixpod/compare/v0.3.1...v0.4.0) (2024-06-26)


### Features

* **flake:** add codenix image ([88788b1](https://github.com/cameronraysmith/nixpod/commit/88788b1d5ab17de6ecefc5d44cf9035b7a5767f2))


### Bug Fixes

* **build-nix-image:** disable existing git sha tag check to create new image ([8e20b9c](https://github.com/cameronraysmith/nixpod/commit/8e20b9cb4883df389bfb702eccb6fc5d04639681))
* **cid:** disable publish ([12b55f7](https://github.com/cameronraysmith/nixpod/commit/12b55f7b5d7d9940954c1d453c1728b6ac6fc290))
* **containers:** create `/var/log` ([befdd9b](https://github.com/cameronraysmith/nixpod/commit/befdd9b9e03ea6b7c5e4b671fb2fe04b4f5d64f1))
* **containers:** fetch s6-overlay ([2a1a722](https://github.com/cameronraysmith/nixpod/commit/2a1a722342194a78235354e0a417acdfb09a1d99))
* **containers:** fix usage of writeShellScript vs +Bin ([0e13390](https://github.com/cameronraysmith/nixpod/commit/0e133905a3ccf1f758759b698c39a826bb1e39b7))
* **containers:** remove manual s6 entrypoint script ([3c958c3](https://github.com/cameronraysmith/nixpod/commit/3c958c380ffe13893f7b2ee774b1340f1adb1869))
* **containers:** support joining extraConfig to the config set ([d56cbf8](https://github.com/cameronraysmith/nixpod/commit/d56cbf86323c6e62f99855ca3536fb092f415295))
* **containers:** untar s6-overlay in fakeRootCommands ([4c8b9d2](https://github.com/cameronraysmith/nixpod/commit/4c8b9d22ef9f940ce33922f9977c9e7f3b4247e4))
* **containers:** update `/run` permissions ([d0a2883](https://github.com/cameronraysmith/nixpod/commit/d0a2883d6903786d115a56897767429f8a146393))
* **containers:** use single s6 version reference ([0b6f140](https://github.com/cameronraysmith/nixpod/commit/0b6f1401a66e96065fbc5d1c9c4373eda7591773))
* **flake:** add nix-index-database ([efbb05d](https://github.com/cameronraysmith/nixpod/commit/efbb05d8b4251d28a77c8c3578b29800f61fc76b))
* **flake:** allow s6 to start jupyterlab in jupnix ([423705e](https://github.com/cameronraysmith/nixpod/commit/423705e02df84aeead46c2a16386c0e8ad1affa4))
* **flake:** assume s6 from s6-overlay ([1511eaa](https://github.com/cameronraysmith/nixpod/commit/1511eaadef9ff9d15ade2048209a55ce34cf7ee5))
* **flake:** create logging directory in cont-init.d ([5cc88ff](https://github.com/cameronraysmith/nixpod/commit/5cc88ff9a144e1d96452d479edfcd69d0f21317e))
* **flake:** defer s6 binaries to s6-overlay ([82e4667](https://github.com/cameronraysmith/nixpod/commit/82e46676d9b7ff0a59cb876cd44eb3659f30f54c))
* **flake:** disable home activation ([5047377](https://github.com/cameronraysmith/nixpod/commit/5047377743a1af997d4c9724fcf6cb330d871bdc))
* **flake:** disable logging ([398772b](https://github.com/cameronraysmith/nixpod/commit/398772b408467bf82a0348f98a5e79e2772228f0))
* **flake:** disable zsh ([5e4ca23](https://github.com/cameronraysmith/nixpod/commit/5e4ca237513dd5ac90fc6a698449987ced7e9873))
* **flake:** enable logging and activate hm on startup ([c2972ac](https://github.com/cameronraysmith/nixpod/commit/c2972acef2de32b0012e7cff6c20507ad7288a81))
* **flake:** fix usage of writeShellScript vs +Bin ([f77bd15](https://github.com/cameronraysmith/nixpod/commit/f77bd1559a466b1b9728c27946bc2b8e4b2b66d3))
* **flake:** include trailing slash in code-server base path ([6f413b1](https://github.com/cameronraysmith/nixpod/commit/6f413b1b31d4d4a7eec38d67d631b351905be7e8))
* **flake:** reenable zsh ([6ea5a0a](https://github.com/cameronraysmith/nixpod/commit/6ea5a0a235b6c4e84690411a59f7d8a147725e36))
* **flake:** refactor hm config to module ([14ce6f4](https://github.com/cameronraysmith/nixpod/commit/14ce6f46fc3c8c0ff2d40dd20e68510a934690b6))
* **flake:** reference single username and HOME in jupnix image ([7d2d4f8](https://github.com/cameronraysmith/nixpod/commit/7d2d4f885d350955d691ce57858d2c9af98ee1f5))
* **flake:** remove musl ([ec60083](https://github.com/cameronraysmith/nixpod/commit/ec60083c3b3f2cc4c2b8d41cd1b43f5e3161d5c1))
* **flake:** remove unused container cmd ([c292f5f](https://github.com/cameronraysmith/nixpod/commit/c292f5f80fc22e0591862f08006d7554d70bd767))
* **flake:** set server-base-path in code-server image ([2636b74](https://github.com/cameronraysmith/nixpod/commit/2636b74a9de0bd9339c76cfad1871aa215519c69))
* **flake:** set SHELL and reenable logging ([3d474b9](https://github.com/cameronraysmith/nixpod/commit/3d474b92d8a89c18cc397bcf0757c71348b9ed93))
* **flake:** sort and separate printenv ([f4579cb](https://github.com/cameronraysmith/nixpod/commit/f4579cb49f26928b21f12f39d6ec1d8f61687773))
* **flake:** update jupyter log ([89c08cb](https://github.com/cameronraysmith/nixpod/commit/89c08cbcffec22ac1d2ca1019a878a8a6d934f49))
* **flake:** use bash ([2730980](https://github.com/cameronraysmith/nixpod/commit/2730980bee00cdca87ea9a78d82996babc33ced8))
* **flake:** use code-server ([cbdefec](https://github.com/cameronraysmith/nixpod/commit/cbdefec4df732f004be9ce95208896784ee6af74))
* **flake:** use interactive/PATH bash to pickup env ([f7e6ffa](https://github.com/cameronraysmith/nixpod/commit/f7e6ffa47bb39655054f2f6dc562aa1e457589f9))
* **home:** add gawk ([d15b619](https://github.com/cameronraysmith/nixpod/commit/d15b61986721f94c85f89c7d8a870b619ac99755))
* **home:** disable compfix ([4abbdd5](https://github.com/cameronraysmith/nixpod/commit/4abbdd570ca952775886694d0c58dd670e14a666))
* **home:** enable git config, delta, lg ([2c52534](https://github.com/cameronraysmith/nixpod/commit/2c52534bc2299f52d5d0721f60eb49bac7ddb3e2))
* **home:** load nix-index-database module ([abc8e64](https://github.com/cameronraysmith/nixpod/commit/abc8e648427bc744de6a1177a4804bdec085f753))
* **home:** set editor ([812ab72](https://github.com/cameronraysmith/nixpod/commit/812ab729b1564aa432e750eba60abd5821e0477d))
* **home:** set glibcLocales ([bf92251](https://github.com/cameronraysmith/nixpod/commit/bf92251a8306aaf9f4a8bcf3f7db9051fc0451b4))

## [0.4.0-beta.2](https://github.com/cameronraysmith/nixpod/compare/v0.4.0-beta.1...v0.4.0-beta.2) (2024-06-26)


### Bug Fixes

* **cid:** disable publish ([12b55f7](https://github.com/cameronraysmith/nixpod/commit/12b55f7b5d7d9940954c1d453c1728b6ac6fc290))

## [0.4.0-beta.1](https://github.com/cameronraysmith/nixpod/compare/v0.3.1...v0.4.0-beta.1) (2024-06-26)


### Features

* **flake:** add codenix image ([88788b1](https://github.com/cameronraysmith/nixpod/commit/88788b1d5ab17de6ecefc5d44cf9035b7a5767f2))


### Bug Fixes

* **build-nix-image:** disable existing git sha tag check to create new image ([8e20b9c](https://github.com/cameronraysmith/nixpod/commit/8e20b9cb4883df389bfb702eccb6fc5d04639681))
* **containers:** create `/var/log` ([befdd9b](https://github.com/cameronraysmith/nixpod/commit/befdd9b9e03ea6b7c5e4b671fb2fe04b4f5d64f1))
* **containers:** fetch s6-overlay ([2a1a722](https://github.com/cameronraysmith/nixpod/commit/2a1a722342194a78235354e0a417acdfb09a1d99))
* **containers:** fix usage of writeShellScript vs +Bin ([0e13390](https://github.com/cameronraysmith/nixpod/commit/0e133905a3ccf1f758759b698c39a826bb1e39b7))
* **containers:** remove manual s6 entrypoint script ([3c958c3](https://github.com/cameronraysmith/nixpod/commit/3c958c380ffe13893f7b2ee774b1340f1adb1869))
* **containers:** support joining extraConfig to the config set ([d56cbf8](https://github.com/cameronraysmith/nixpod/commit/d56cbf86323c6e62f99855ca3536fb092f415295))
* **containers:** untar s6-overlay in fakeRootCommands ([4c8b9d2](https://github.com/cameronraysmith/nixpod/commit/4c8b9d22ef9f940ce33922f9977c9e7f3b4247e4))
* **containers:** update `/run` permissions ([d0a2883](https://github.com/cameronraysmith/nixpod/commit/d0a2883d6903786d115a56897767429f8a146393))
* **containers:** use single s6 version reference ([0b6f140](https://github.com/cameronraysmith/nixpod/commit/0b6f1401a66e96065fbc5d1c9c4373eda7591773))
* **flake:** add nix-index-database ([efbb05d](https://github.com/cameronraysmith/nixpod/commit/efbb05d8b4251d28a77c8c3578b29800f61fc76b))
* **flake:** allow s6 to start jupyterlab in jupnix ([423705e](https://github.com/cameronraysmith/nixpod/commit/423705e02df84aeead46c2a16386c0e8ad1affa4))
* **flake:** assume s6 from s6-overlay ([1511eaa](https://github.com/cameronraysmith/nixpod/commit/1511eaadef9ff9d15ade2048209a55ce34cf7ee5))
* **flake:** create logging directory in cont-init.d ([5cc88ff](https://github.com/cameronraysmith/nixpod/commit/5cc88ff9a144e1d96452d479edfcd69d0f21317e))
* **flake:** defer s6 binaries to s6-overlay ([82e4667](https://github.com/cameronraysmith/nixpod/commit/82e46676d9b7ff0a59cb876cd44eb3659f30f54c))
* **flake:** disable home activation ([5047377](https://github.com/cameronraysmith/nixpod/commit/5047377743a1af997d4c9724fcf6cb330d871bdc))
* **flake:** disable logging ([398772b](https://github.com/cameronraysmith/nixpod/commit/398772b408467bf82a0348f98a5e79e2772228f0))
* **flake:** disable zsh ([5e4ca23](https://github.com/cameronraysmith/nixpod/commit/5e4ca237513dd5ac90fc6a698449987ced7e9873))
* **flake:** enable logging and activate hm on startup ([c2972ac](https://github.com/cameronraysmith/nixpod/commit/c2972acef2de32b0012e7cff6c20507ad7288a81))
* **flake:** fix usage of writeShellScript vs +Bin ([f77bd15](https://github.com/cameronraysmith/nixpod/commit/f77bd1559a466b1b9728c27946bc2b8e4b2b66d3))
* **flake:** include trailing slash in code-server base path ([6f413b1](https://github.com/cameronraysmith/nixpod/commit/6f413b1b31d4d4a7eec38d67d631b351905be7e8))
* **flake:** reenable zsh ([6ea5a0a](https://github.com/cameronraysmith/nixpod/commit/6ea5a0a235b6c4e84690411a59f7d8a147725e36))
* **flake:** refactor hm config to module ([14ce6f4](https://github.com/cameronraysmith/nixpod/commit/14ce6f46fc3c8c0ff2d40dd20e68510a934690b6))
* **flake:** reference single username and HOME in jupnix image ([7d2d4f8](https://github.com/cameronraysmith/nixpod/commit/7d2d4f885d350955d691ce57858d2c9af98ee1f5))
* **flake:** remove musl ([ec60083](https://github.com/cameronraysmith/nixpod/commit/ec60083c3b3f2cc4c2b8d41cd1b43f5e3161d5c1))
* **flake:** remove unused container cmd ([c292f5f](https://github.com/cameronraysmith/nixpod/commit/c292f5f80fc22e0591862f08006d7554d70bd767))
* **flake:** set server-base-path in code-server image ([2636b74](https://github.com/cameronraysmith/nixpod/commit/2636b74a9de0bd9339c76cfad1871aa215519c69))
* **flake:** set SHELL and reenable logging ([3d474b9](https://github.com/cameronraysmith/nixpod/commit/3d474b92d8a89c18cc397bcf0757c71348b9ed93))
* **flake:** sort and separate printenv ([f4579cb](https://github.com/cameronraysmith/nixpod/commit/f4579cb49f26928b21f12f39d6ec1d8f61687773))
* **flake:** update jupyter log ([89c08cb](https://github.com/cameronraysmith/nixpod/commit/89c08cbcffec22ac1d2ca1019a878a8a6d934f49))
* **flake:** use bash ([2730980](https://github.com/cameronraysmith/nixpod/commit/2730980bee00cdca87ea9a78d82996babc33ced8))
* **flake:** use code-server ([cbdefec](https://github.com/cameronraysmith/nixpod/commit/cbdefec4df732f004be9ce95208896784ee6af74))
* **flake:** use interactive/PATH bash to pickup env ([f7e6ffa](https://github.com/cameronraysmith/nixpod/commit/f7e6ffa47bb39655054f2f6dc562aa1e457589f9))
* **home:** add gawk ([d15b619](https://github.com/cameronraysmith/nixpod/commit/d15b61986721f94c85f89c7d8a870b619ac99755))
* **home:** disable compfix ([4abbdd5](https://github.com/cameronraysmith/nixpod/commit/4abbdd570ca952775886694d0c58dd670e14a666))
* **home:** enable git config, delta, lg ([2c52534](https://github.com/cameronraysmith/nixpod/commit/2c52534bc2299f52d5d0721f60eb49bac7ddb3e2))
* **home:** load nix-index-database module ([abc8e64](https://github.com/cameronraysmith/nixpod/commit/abc8e648427bc744de6a1177a4804bdec085f753))
* **home:** set editor ([812ab72](https://github.com/cameronraysmith/nixpod/commit/812ab729b1564aa432e750eba60abd5821e0477d))
* **home:** set glibcLocales ([bf92251](https://github.com/cameronraysmith/nixpod/commit/bf92251a8306aaf9f4a8bcf3f7db9051fc0451b4))

## [0.3.1](https://github.com/cameronraysmith/nixpod/compare/v0.3.0...v0.3.1) (2024-06-20)


### Bug Fixes

* **actions:** append "v" to construct tag from version on release ([1e533a7](https://github.com/cameronraysmith/nixpod/commit/1e533a72bca4e6a8a155b7b4bd5618cd394beb9c))
* **actions:** set git sha from tag on release ([674fc4a](https://github.com/cameronraysmith/nixpod/commit/674fc4a00063373b3dc54f701b5ec383c913967d))
* **cid:** publish from git tag ([4d61f5f](https://github.com/cameronraysmith/nixpod/commit/4d61f5f44451c30f5954a2d2195a1d0836365cc7))
* **home:** add sed ([26867df](https://github.com/cameronraysmith/nixpod/commit/26867df68529559ec257fcf50cddc3dcf905c0aa))

## [0.3.1-beta.3](https://github.com/cameronraysmith/nixpod/compare/v0.3.1-beta.2...v0.3.1-beta.3) (2024-06-20)


### Bug Fixes

* **actions:** append "v" to construct tag from version on release ([1e533a7](https://github.com/cameronraysmith/nixpod/commit/1e533a72bca4e6a8a155b7b4bd5618cd394beb9c))

## [0.3.1-beta.2](https://github.com/cameronraysmith/nixpod/compare/v0.3.1-beta.1...v0.3.1-beta.2) (2024-06-20)


### Bug Fixes

* **actions:** set git sha from tag on release ([674fc4a](https://github.com/cameronraysmith/nixpod/commit/674fc4a00063373b3dc54f701b5ec383c913967d))

## [0.3.1-beta.1](https://github.com/cameronraysmith/nixpod/compare/v0.3.0...v0.3.1-beta.1) (2024-06-20)


### Bug Fixes

* **cid:** publish from git tag ([4d61f5f](https://github.com/cameronraysmith/nixpod/commit/4d61f5f44451c30f5954a2d2195a1d0836365cc7))
* **home:** add sed ([26867df](https://github.com/cameronraysmith/nixpod/commit/26867df68529559ec257fcf50cddc3dcf905c0aa))

## [0.3.0](https://github.com/cameronraysmith/nixpod/compare/v0.2.8...v0.3.0) (2024-06-19)


### Features

* **ci:** add jupnix ([6f3fe3a](https://github.com/cameronraysmith/nixpod/commit/6f3fe3a2115b5b3ab1551563c0d2433f846e0e84))
* **ci:** build nixpod-home image with nix ([57cf1f1](https://github.com/cameronraysmith/nixpod/commit/57cf1f12b1471863ffcee8bb23bfd19f9bc128d2))
* **containers:** add fromImage support to multiuser container ([53c8108](https://github.com/cameronraysmith/nixpod/commit/53c81080feb9e492104faf973af6c2d8e853e1e9))
* **containers:** add function to create home directories ([a6c1877](https://github.com/cameronraysmith/nixpod/commit/a6c187767fafed250c5fb0af2a188cb18be727e5))
* **containers:** add template for nix multiuser container ([364f3d7](https://github.com/cameronraysmith/nixpod/commit/364f3d768916074d04f9095f4b7b0f846eee3e59))
* **dotenv:** add dotenv template ([fa060b6](https://github.com/cameronraysmith/nixpod/commit/fa060b622e94ff6aebd8018457cf7533a4d45106))
* **flake:** add ghapod and manifest ([70e219c](https://github.com/cameronraysmith/nixpod/commit/70e219cf0e22dd60ff7979aa2fbd1d6793833f44))
* **flake:** add jupnix image ([d37e7a3](https://github.com/cameronraysmith/nixpod/commit/d37e7a36c8be8ce0f53e2c702aeeb7ffba03b98f))
* **github:** add build-nix-image action ([39fa663](https://github.com/cameronraysmith/nixpod/commit/39fa663a3cac51ef9852b291864df3c8f634ba4e))
* **home:** add atuin ([7eb20ad](https://github.com/cameronraysmith/nixpod/commit/7eb20ad40949b06f13036fb5442322df15ee0b5e))
* **just:** add secrets recipes ([c6234da](https://github.com/cameronraysmith/nixpod/commit/c6234da121345e2b62c30b6e618f4ed1d0ddf111))
* **teller:** add config ([a75d82e](https://github.com/cameronraysmith/nixpod/commit/a75d82e8b2a1898c3e89cadaa78463b8873764e7))


### Bug Fixes

* **actions:** add support for build-args ([11ae01d](https://github.com/cameronraysmith/nixpod/commit/11ae01dbfd60e2f9fdfa020378f39e5043b9db7e))
* **build-nix-image:** use releaseVersion ([1be3b3f](https://github.com/cameronraysmith/nixpod/commit/1be3b3f5c227baca446d7bd18361a53b2d5cdb07))
* **cd:** disable on push ([5bdc09e](https://github.com/cameronraysmith/nixpod/commit/5bdc09e900dc2c0f7ea4d7fab536de3e4ff40ca4))
* **ci:** add concurrency group to nixci job ([7a361e4](https://github.com/cameronraysmith/nixpod/commit/7a361e482bf6e489698b9674e2e6e4a2a641b632))
* **ci:** add ghapod job ([d6cc4d3](https://github.com/cameronraysmith/nixpod/commit/d6cc4d3011573bc56d29ca999f1dc09e845e2f24))
* **ci:** enable cache on nixci job ([6b42017](https://github.com/cameronraysmith/nixpod/commit/6b420179a7e2f12ea2e8a4205fb19eb4ffe519c0))
* **ci:** enable image push for PRs with build-images label ([d968d56](https://github.com/cameronraysmith/nixpod/commit/d968d56b8c1dadbe5a96f8b3ecf4c5d17bbf28f2))
* **ci:** reenable debnixpod ([b10595f](https://github.com/cameronraysmith/nixpod/commit/b10595fe6dafe17154e3be3b345bf7373644e1a1))
* **ci:** reenable dependent debnix jobs ([6c47b3b](https://github.com/cameronraysmith/nixpod/commit/6c47b3b0b71dd7d446d5daa8a117f4c316e3f41b))
* **ci:** release condition ([0a22d38](https://github.com/cameronraysmith/nixpod/commit/0a22d38f402a5b361b2a86ed5c6d648a9f2bfe21))
* **ci:** rename nixpod job ([90981ba](https://github.com/cameronraysmith/nixpod/commit/90981bac51eac6d8b0ced78cff45f58201f42948))
* **ci:** show logs and trace ([3284159](https://github.com/cameronraysmith/nixpod/commit/32841592e28b686f90d6c2751aff96befb4a94d9))
* **ci:** update concurrency groups and conditions for ci image build ([2043acf](https://github.com/cameronraysmith/nixpod/commit/2043acf97b7078f61ffe8db81ee604e7274e66c0))
* **ci:** update job dependencies ([29f3996](https://github.com/cameronraysmith/nixpod/commit/29f3996b0bdded61fcb1b4f46b16af6e7c239b23))
* **ci:** update job references ([e12fdd3](https://github.com/cameronraysmith/nixpod/commit/e12fdd3db81021d32e48eabd5b59abd6cdbe5172))
* **containers:** add nixProfileScript for nix-daemon ([db82cb1](https://github.com/cameronraysmith/nixpod/commit/db82cb16c69b41fd11a2ac894f3bc21a6b229716))
* **containers:** add nonRootUserDirectories and init scripts ([39a37af](https://github.com/cameronraysmith/nixpod/commit/39a37afdd92c6b9a207b9b906770e529a312f9ae))
* **containers:** convert guids to strings ([18bc78a](https://github.com/cameronraysmith/nixpod/commit/18bc78a351ca422fbdd86289fcf8d6791eb138b6))
* **containers:** improve debnixpod caching ([5699fc2](https://github.com/cameronraysmith/nixpod/commit/5699fc26b8b2582c2fdacfd19c08df5e4aa09708))
* **containers:** improve debnixpod caching ([e5ddaca](https://github.com/cameronraysmith/nixpod/commit/e5ddaca327fda90e849915d64229c2375a062d97))
* **containers:** improve debnixpod logging ([d2af22e](https://github.com/cameronraysmith/nixpod/commit/d2af22e22cc5437b82064089aa456880ea1acbba))
* **containers:** make user directories manually ([e5aca17](https://github.com/cameronraysmith/nixpod/commit/e5aca175090d5fa0a90d691331ddb782766dc520))
* **containers:** only create groups that don't already exist ([1128b57](https://github.com/cameronraysmith/nixpod/commit/1128b5755fc16e4066204824ce01283b43fc341f))
* **containers:** provide additional multiuser overrides ([db83cb1](https://github.com/cameronraysmith/nixpod/commit/db83cb1a53f60cdd4ffa2fd8ba0ac27fa7ae9932))
* **containers:** redirect nix-daemon output ([50a618e](https://github.com/cameronraysmith/nixpod/commit/50a618e0b3fb3d155b451645e9ab5ed99ed08afe))
* **containers:** rename multiuser-container -> multiuser ([5a38bcc](https://github.com/cameronraysmith/nixpod/commit/5a38bccfa7655ef1dae6b7e40f1eedee34f734b2))
* **containers:** separate nonRootUsers ([900e846](https://github.com/cameronraysmith/nixpod/commit/900e846dfc399a48a588253ef084625a8ce44df7))
* **containers:** set debnix trusted users ([bd50553](https://github.com/cameronraysmith/nixpod/commit/bd50553a6326bc915716bebd5ce26e9326e46951))
* **containers:** set entrypoint ([46d1c3f](https://github.com/cameronraysmith/nixpod/commit/46d1c3fd3aee0a4317de760bc214452365281a6a))
* **containers:** set store owner ([af964e8](https://github.com/cameronraysmith/nixpod/commit/af964e8a3370ad00a38b1d1d5900ea35347b9fd0))
* **containers:** update per-user profiles ([f8def87](https://github.com/cameronraysmith/nixpod/commit/f8def87e988d67c97b2548236e13cf4d575bb716))
* **containers:** update s6EntrypointScript ([f71258c](https://github.com/cameronraysmith/nixpod/commit/f71258c99d4d8e2f9347afea9ee32158679e79d9))
* **containers:** update user gids and groups ([7ba26c7](https://github.com/cameronraysmith/nixpod/commit/7ba26c7ef4e5163c2193eb24f9dc1af48d4af1ed))
* **direnv:** use dotenv ([32d5886](https://github.com/cameronraysmith/nixpod/commit/32d58869b2a77e5c4f99f77f7a9cc2e9e4bef9c8))
* **flake:** add `/etc/pam.d/system-auth` ([5341a03](https://github.com/cameronraysmith/nixpod/commit/5341a0341ae48e55f050b10075f8bcf9bbb4f013))
* **flake:** add buildImage version of ghapod ([4825e02](https://github.com/cameronraysmith/nixpod/commit/4825e0213ebea1b01b269edc2e289d73d106ed7a))
* **flake:** add homeConfigurations activationPackage to contents ([09a95e9](https://github.com/cameronraysmith/nixpod/commit/09a95e9e8e798b3015a668de6ab64fbc7c6d191d))
* **flake:** add missing `/etc/pam.d/sudo` ([8cb811a](https://github.com/cameronraysmith/nixpod/commit/8cb811a22507771bc7cb02fff0be433be1941019))
* **flake:** add su and sudo to root PATH ([18f4b79](https://github.com/cameronraysmith/nixpod/commit/18f4b790fdd16173824a0e417d706d7539b2194a))
* **flake:** append to nsswitch.conf ([416b2aa](https://github.com/cameronraysmith/nixpod/commit/416b2aa8f5709a156bc97fbbb4342ee1e45bee5f))
* **flake:** build ghanix from buildMultiUserNixImage ([58efe5c](https://github.com/cameronraysmith/nixpod/commit/58efe5c9835c70925267b424068c92a2cc54a3eb))
* **flake:** build image with nix ([21f4ae0](https://github.com/cameronraysmith/nixpod/commit/21f4ae0a62237cf4574336461581429ac9210f3d))
* **flake:** compose PAM su and sudo base images ([e2725c3](https://github.com/cameronraysmith/nixpod/commit/e2725c3ef2d3f3bf5a977607279898f85bb6a2ad))
* **flake:** container is named nixpod ([ea83028](https://github.com/cameronraysmith/nixpod/commit/ea8302875afaba26e9723728ed6072eee77eac70))
* **flake:** derived image needs maxLayers > fromImage.maxLayers ([1dc225d](https://github.com/cameronraysmith/nixpod/commit/1dc225d25565899ceb82e061fe5893c464a27d86))
* **flake:** disable config ([d9546ff](https://github.com/cameronraysmith/nixpod/commit/d9546ff98e9ccffaebf6a1d0b9bc65b541474ca8))
* **flake:** disable entrypoint ([656355b](https://github.com/cameronraysmith/nixpod/commit/656355b703bca57e77b03fe371ea1cae4c8f0218))
* **flake:** disable updating sudoers ([b5b746c](https://github.com/cameronraysmith/nixpod/commit/b5b746cc9cfb8e8b2d1305c268c522a1ac1f5c75))
* **flake:** duplicate shadowSetup ([cb402c5](https://github.com/cameronraysmith/nixpod/commit/cb402c52624abd00a2b866e9a12caadb153a9fa8))
* **flake:** enable entrypoint script ([a4229f0](https://github.com/cameronraysmith/nixpod/commit/a4229f058231255df86c80b65703d878cc47c477))
* **flake:** enable multi-user nix ([cc0c62a](https://github.com/cameronraysmith/nixpod/commit/cc0c62a46ca984ad1e6c5b331caf486f90378e20))
* **flake:** fix errors in sudoers config ([5511b38](https://github.com/cameronraysmith/nixpod/commit/5511b387a51d31ebbc068035ac381abed728c0d6))
* **flake:** layered images have contents attribute ([0d2d36f](https://github.com/cameronraysmith/nixpod/commit/0d2d36ff23e0e293108dc7b882ac2fcee1d0e076))
* **flake:** link all paths and update sudoers ([5c155f3](https://github.com/cameronraysmith/nixpod/commit/5c155f3eeeadd01847c8292895bdee18d99406ce))
* **flake:** link paths and define SSL vars ([b5cd949](https://github.com/cameronraysmith/nixpod/commit/b5cd949241f86f92e827afc76f58e7bbf152d3f6))
* **flake:** move all user config in base image ([1c780fc](https://github.com/cameronraysmith/nixpod/commit/1c780fc092f4e5dbe89329ffd4a0fb5e43a883a8))
* **flake:** reenable container entrypoint ([4c5dad5](https://github.com/cameronraysmith/nixpod/commit/4c5dad584dbd5f48702899d42088935e3d1cbd4b))
* **flake:** reenable wheel group ([537578c](https://github.com/cameronraysmith/nixpod/commit/537578c69c5804b841106d57f35caefc6f4d2459))
* **flake:** rename ghapod -> ghanix ([7e5846f](https://github.com/cameronraysmith/nixpod/commit/7e5846f4949275c4180ebc52159b148699f2b0a0))
* **flake:** separate sudo image ([31d7588](https://github.com/cameronraysmith/nixpod/commit/31d7588ef3663444d46fabae5417a4e3d1cfb9ae))
* **flake:** set ghanix store owner ([6780160](https://github.com/cameronraysmith/nixpod/commit/67801603caa07bb519d2c5ebc58e9b1f9929516d))
* **flake:** specify public cache ([338f93e](https://github.com/cameronraysmith/nixpod/commit/338f93e76b2ecc1bce9359b64b858f8e4f9e3bc6))
* **flake:** uid and gid are strings ([b04e4e0](https://github.com/cameronraysmith/nixpod/commit/b04e4e08bfdfb672a35a3aceea77b17f6cadbe35))
* **flake:** update sudoers ([0ce87b0](https://github.com/cameronraysmith/nixpod/commit/0ce87b04e27528f440bc196ada1c0ab5b88f2dde))
* **flake:** update user, gropu and nix configuration ([86f218b](https://github.com/cameronraysmith/nixpod/commit/86f218b95055cebbf23ae29c6afe7066450ea140))
* **flake:** use Cmd with bashInteractive ([d92cd30](https://github.com/cameronraysmith/nixpod/commit/d92cd30872f81702e608f6613e34877033f9730a))
* **flake:** use upstream nix container ([a5279ed](https://github.com/cameronraysmith/nixpod/commit/a5279ed3cec190b4b8b9196d250f42af70437db3))
* **github:** update labels ([d39380c](https://github.com/cameronraysmith/nixpod/commit/d39380c0c5290266a405223312aacd92fcdbbac6))
* **gitignore:** ignore `.env` ([a17ccf1](https://github.com/cameronraysmith/nixpod/commit/a17ccf16cdbd24649837a54e6c5a69bd792e9498))
* **home:** enable atuin and zsh ([2e7d758](https://github.com/cameronraysmith/nixpod/commit/2e7d7581130388d550168e6ca737e59bd6aa0fa7))
* **just:** add act recipe for ci nixci ([a480aab](https://github.com/cameronraysmith/nixpod/commit/a480aab4c54326ac095f368613cbf370dbe128af))

## [0.3.0-beta.1](https://github.com/cameronraysmith/nixpod/compare/v0.2.8...v0.3.0-beta.1) (2024-06-19)


### Features

* **ci:** add jupnix ([6f3fe3a](https://github.com/cameronraysmith/nixpod/commit/6f3fe3a2115b5b3ab1551563c0d2433f846e0e84))
* **ci:** build nixpod-home image with nix ([57cf1f1](https://github.com/cameronraysmith/nixpod/commit/57cf1f12b1471863ffcee8bb23bfd19f9bc128d2))
* **containers:** add fromImage support to multiuser container ([53c8108](https://github.com/cameronraysmith/nixpod/commit/53c81080feb9e492104faf973af6c2d8e853e1e9))
* **containers:** add function to create home directories ([a6c1877](https://github.com/cameronraysmith/nixpod/commit/a6c187767fafed250c5fb0af2a188cb18be727e5))
* **containers:** add template for nix multiuser container ([364f3d7](https://github.com/cameronraysmith/nixpod/commit/364f3d768916074d04f9095f4b7b0f846eee3e59))
* **dotenv:** add dotenv template ([fa060b6](https://github.com/cameronraysmith/nixpod/commit/fa060b622e94ff6aebd8018457cf7533a4d45106))
* **flake:** add ghapod and manifest ([70e219c](https://github.com/cameronraysmith/nixpod/commit/70e219cf0e22dd60ff7979aa2fbd1d6793833f44))
* **flake:** add jupnix image ([d37e7a3](https://github.com/cameronraysmith/nixpod/commit/d37e7a36c8be8ce0f53e2c702aeeb7ffba03b98f))
* **github:** add build-nix-image action ([39fa663](https://github.com/cameronraysmith/nixpod/commit/39fa663a3cac51ef9852b291864df3c8f634ba4e))
* **home:** add atuin ([7eb20ad](https://github.com/cameronraysmith/nixpod/commit/7eb20ad40949b06f13036fb5442322df15ee0b5e))
* **just:** add secrets recipes ([c6234da](https://github.com/cameronraysmith/nixpod/commit/c6234da121345e2b62c30b6e618f4ed1d0ddf111))
* **teller:** add config ([a75d82e](https://github.com/cameronraysmith/nixpod/commit/a75d82e8b2a1898c3e89cadaa78463b8873764e7))


### Bug Fixes

* **actions:** add support for build-args ([11ae01d](https://github.com/cameronraysmith/nixpod/commit/11ae01dbfd60e2f9fdfa020378f39e5043b9db7e))
* **build-nix-image:** use releaseVersion ([1be3b3f](https://github.com/cameronraysmith/nixpod/commit/1be3b3f5c227baca446d7bd18361a53b2d5cdb07))
* **cd:** disable on push ([5bdc09e](https://github.com/cameronraysmith/nixpod/commit/5bdc09e900dc2c0f7ea4d7fab536de3e4ff40ca4))
* **ci:** add concurrency group to nixci job ([7a361e4](https://github.com/cameronraysmith/nixpod/commit/7a361e482bf6e489698b9674e2e6e4a2a641b632))
* **ci:** add ghapod job ([d6cc4d3](https://github.com/cameronraysmith/nixpod/commit/d6cc4d3011573bc56d29ca999f1dc09e845e2f24))
* **ci:** enable cache on nixci job ([6b42017](https://github.com/cameronraysmith/nixpod/commit/6b420179a7e2f12ea2e8a4205fb19eb4ffe519c0))
* **ci:** enable image push for PRs with build-images label ([d968d56](https://github.com/cameronraysmith/nixpod/commit/d968d56b8c1dadbe5a96f8b3ecf4c5d17bbf28f2))
* **ci:** reenable debnixpod ([b10595f](https://github.com/cameronraysmith/nixpod/commit/b10595fe6dafe17154e3be3b345bf7373644e1a1))
* **ci:** reenable dependent debnix jobs ([6c47b3b](https://github.com/cameronraysmith/nixpod/commit/6c47b3b0b71dd7d446d5daa8a117f4c316e3f41b))
* **ci:** release condition ([0a22d38](https://github.com/cameronraysmith/nixpod/commit/0a22d38f402a5b361b2a86ed5c6d648a9f2bfe21))
* **ci:** rename nixpod job ([90981ba](https://github.com/cameronraysmith/nixpod/commit/90981bac51eac6d8b0ced78cff45f58201f42948))
* **ci:** show logs and trace ([3284159](https://github.com/cameronraysmith/nixpod/commit/32841592e28b686f90d6c2751aff96befb4a94d9))
* **ci:** update concurrency groups and conditions for ci image build ([2043acf](https://github.com/cameronraysmith/nixpod/commit/2043acf97b7078f61ffe8db81ee604e7274e66c0))
* **ci:** update job dependencies ([29f3996](https://github.com/cameronraysmith/nixpod/commit/29f3996b0bdded61fcb1b4f46b16af6e7c239b23))
* **ci:** update job references ([e12fdd3](https://github.com/cameronraysmith/nixpod/commit/e12fdd3db81021d32e48eabd5b59abd6cdbe5172))
* **containers:** add nixProfileScript for nix-daemon ([db82cb1](https://github.com/cameronraysmith/nixpod/commit/db82cb16c69b41fd11a2ac894f3bc21a6b229716))
* **containers:** add nonRootUserDirectories and init scripts ([39a37af](https://github.com/cameronraysmith/nixpod/commit/39a37afdd92c6b9a207b9b906770e529a312f9ae))
* **containers:** convert guids to strings ([18bc78a](https://github.com/cameronraysmith/nixpod/commit/18bc78a351ca422fbdd86289fcf8d6791eb138b6))
* **containers:** improve debnixpod caching ([5699fc2](https://github.com/cameronraysmith/nixpod/commit/5699fc26b8b2582c2fdacfd19c08df5e4aa09708))
* **containers:** improve debnixpod caching ([e5ddaca](https://github.com/cameronraysmith/nixpod/commit/e5ddaca327fda90e849915d64229c2375a062d97))
* **containers:** improve debnixpod logging ([d2af22e](https://github.com/cameronraysmith/nixpod/commit/d2af22e22cc5437b82064089aa456880ea1acbba))
* **containers:** make user directories manually ([e5aca17](https://github.com/cameronraysmith/nixpod/commit/e5aca175090d5fa0a90d691331ddb782766dc520))
* **containers:** only create groups that don't already exist ([1128b57](https://github.com/cameronraysmith/nixpod/commit/1128b5755fc16e4066204824ce01283b43fc341f))
* **containers:** provide additional multiuser overrides ([db83cb1](https://github.com/cameronraysmith/nixpod/commit/db83cb1a53f60cdd4ffa2fd8ba0ac27fa7ae9932))
* **containers:** redirect nix-daemon output ([50a618e](https://github.com/cameronraysmith/nixpod/commit/50a618e0b3fb3d155b451645e9ab5ed99ed08afe))
* **containers:** rename multiuser-container -> multiuser ([5a38bcc](https://github.com/cameronraysmith/nixpod/commit/5a38bccfa7655ef1dae6b7e40f1eedee34f734b2))
* **containers:** separate nonRootUsers ([900e846](https://github.com/cameronraysmith/nixpod/commit/900e846dfc399a48a588253ef084625a8ce44df7))
* **containers:** set debnix trusted users ([bd50553](https://github.com/cameronraysmith/nixpod/commit/bd50553a6326bc915716bebd5ce26e9326e46951))
* **containers:** set entrypoint ([46d1c3f](https://github.com/cameronraysmith/nixpod/commit/46d1c3fd3aee0a4317de760bc214452365281a6a))
* **containers:** set store owner ([af964e8](https://github.com/cameronraysmith/nixpod/commit/af964e8a3370ad00a38b1d1d5900ea35347b9fd0))
* **containers:** update per-user profiles ([f8def87](https://github.com/cameronraysmith/nixpod/commit/f8def87e988d67c97b2548236e13cf4d575bb716))
* **containers:** update s6EntrypointScript ([f71258c](https://github.com/cameronraysmith/nixpod/commit/f71258c99d4d8e2f9347afea9ee32158679e79d9))
* **containers:** update user gids and groups ([7ba26c7](https://github.com/cameronraysmith/nixpod/commit/7ba26c7ef4e5163c2193eb24f9dc1af48d4af1ed))
* **direnv:** use dotenv ([32d5886](https://github.com/cameronraysmith/nixpod/commit/32d58869b2a77e5c4f99f77f7a9cc2e9e4bef9c8))
* **flake:** add `/etc/pam.d/system-auth` ([5341a03](https://github.com/cameronraysmith/nixpod/commit/5341a0341ae48e55f050b10075f8bcf9bbb4f013))
* **flake:** add buildImage version of ghapod ([4825e02](https://github.com/cameronraysmith/nixpod/commit/4825e0213ebea1b01b269edc2e289d73d106ed7a))
* **flake:** add homeConfigurations activationPackage to contents ([09a95e9](https://github.com/cameronraysmith/nixpod/commit/09a95e9e8e798b3015a668de6ab64fbc7c6d191d))
* **flake:** add missing `/etc/pam.d/sudo` ([8cb811a](https://github.com/cameronraysmith/nixpod/commit/8cb811a22507771bc7cb02fff0be433be1941019))
* **flake:** add su and sudo to root PATH ([18f4b79](https://github.com/cameronraysmith/nixpod/commit/18f4b790fdd16173824a0e417d706d7539b2194a))
* **flake:** append to nsswitch.conf ([416b2aa](https://github.com/cameronraysmith/nixpod/commit/416b2aa8f5709a156bc97fbbb4342ee1e45bee5f))
* **flake:** build ghanix from buildMultiUserNixImage ([58efe5c](https://github.com/cameronraysmith/nixpod/commit/58efe5c9835c70925267b424068c92a2cc54a3eb))
* **flake:** build image with nix ([21f4ae0](https://github.com/cameronraysmith/nixpod/commit/21f4ae0a62237cf4574336461581429ac9210f3d))
* **flake:** compose PAM su and sudo base images ([e2725c3](https://github.com/cameronraysmith/nixpod/commit/e2725c3ef2d3f3bf5a977607279898f85bb6a2ad))
* **flake:** container is named nixpod ([ea83028](https://github.com/cameronraysmith/nixpod/commit/ea8302875afaba26e9723728ed6072eee77eac70))
* **flake:** derived image needs maxLayers > fromImage.maxLayers ([1dc225d](https://github.com/cameronraysmith/nixpod/commit/1dc225d25565899ceb82e061fe5893c464a27d86))
* **flake:** disable config ([d9546ff](https://github.com/cameronraysmith/nixpod/commit/d9546ff98e9ccffaebf6a1d0b9bc65b541474ca8))
* **flake:** disable entrypoint ([656355b](https://github.com/cameronraysmith/nixpod/commit/656355b703bca57e77b03fe371ea1cae4c8f0218))
* **flake:** disable updating sudoers ([b5b746c](https://github.com/cameronraysmith/nixpod/commit/b5b746cc9cfb8e8b2d1305c268c522a1ac1f5c75))
* **flake:** duplicate shadowSetup ([cb402c5](https://github.com/cameronraysmith/nixpod/commit/cb402c52624abd00a2b866e9a12caadb153a9fa8))
* **flake:** enable entrypoint script ([a4229f0](https://github.com/cameronraysmith/nixpod/commit/a4229f058231255df86c80b65703d878cc47c477))
* **flake:** enable multi-user nix ([cc0c62a](https://github.com/cameronraysmith/nixpod/commit/cc0c62a46ca984ad1e6c5b331caf486f90378e20))
* **flake:** fix errors in sudoers config ([5511b38](https://github.com/cameronraysmith/nixpod/commit/5511b387a51d31ebbc068035ac381abed728c0d6))
* **flake:** layered images have contents attribute ([0d2d36f](https://github.com/cameronraysmith/nixpod/commit/0d2d36ff23e0e293108dc7b882ac2fcee1d0e076))
* **flake:** link all paths and update sudoers ([5c155f3](https://github.com/cameronraysmith/nixpod/commit/5c155f3eeeadd01847c8292895bdee18d99406ce))
* **flake:** link paths and define SSL vars ([b5cd949](https://github.com/cameronraysmith/nixpod/commit/b5cd949241f86f92e827afc76f58e7bbf152d3f6))
* **flake:** move all user config in base image ([1c780fc](https://github.com/cameronraysmith/nixpod/commit/1c780fc092f4e5dbe89329ffd4a0fb5e43a883a8))
* **flake:** reenable container entrypoint ([4c5dad5](https://github.com/cameronraysmith/nixpod/commit/4c5dad584dbd5f48702899d42088935e3d1cbd4b))
* **flake:** reenable wheel group ([537578c](https://github.com/cameronraysmith/nixpod/commit/537578c69c5804b841106d57f35caefc6f4d2459))
* **flake:** rename ghapod -> ghanix ([7e5846f](https://github.com/cameronraysmith/nixpod/commit/7e5846f4949275c4180ebc52159b148699f2b0a0))
* **flake:** separate sudo image ([31d7588](https://github.com/cameronraysmith/nixpod/commit/31d7588ef3663444d46fabae5417a4e3d1cfb9ae))
* **flake:** set ghanix store owner ([6780160](https://github.com/cameronraysmith/nixpod/commit/67801603caa07bb519d2c5ebc58e9b1f9929516d))
* **flake:** specify public cache ([338f93e](https://github.com/cameronraysmith/nixpod/commit/338f93e76b2ecc1bce9359b64b858f8e4f9e3bc6))
* **flake:** uid and gid are strings ([b04e4e0](https://github.com/cameronraysmith/nixpod/commit/b04e4e08bfdfb672a35a3aceea77b17f6cadbe35))
* **flake:** update sudoers ([0ce87b0](https://github.com/cameronraysmith/nixpod/commit/0ce87b04e27528f440bc196ada1c0ab5b88f2dde))
* **flake:** update user, gropu and nix configuration ([86f218b](https://github.com/cameronraysmith/nixpod/commit/86f218b95055cebbf23ae29c6afe7066450ea140))
* **flake:** use Cmd with bashInteractive ([d92cd30](https://github.com/cameronraysmith/nixpod/commit/d92cd30872f81702e608f6613e34877033f9730a))
* **flake:** use upstream nix container ([a5279ed](https://github.com/cameronraysmith/nixpod/commit/a5279ed3cec190b4b8b9196d250f42af70437db3))
* **github:** update labels ([d39380c](https://github.com/cameronraysmith/nixpod/commit/d39380c0c5290266a405223312aacd92fcdbbac6))
* **gitignore:** ignore `.env` ([a17ccf1](https://github.com/cameronraysmith/nixpod/commit/a17ccf16cdbd24649837a54e6c5a69bd792e9498))
* **home:** enable atuin and zsh ([2e7d758](https://github.com/cameronraysmith/nixpod/commit/2e7d7581130388d550168e6ca737e59bd6aa0fa7))
* **just:** add act recipe for ci nixci ([a480aab](https://github.com/cameronraysmith/nixpod/commit/a480aab4c54326ac095f368613cbf370dbe128af))

## [0.2.8](https://github.com/cameronraysmith/nixpod/compare/v0.2.7...v0.2.8) (2024-05-23)


### Bug Fixes

* **envrc:** use nix-direnv ([6e443e6](https://github.com/cameronraysmith/nixpod/commit/6e443e63774c1d8bd76d1b14dc6eb442bd2078c9))
* **flake:** add act and ratchet to default devShell ([d0a1ac6](https://github.com/cameronraysmith/nixpod/commit/d0a1ac6e14ffa9a82865a2e0e0a6113a83ce3f81))

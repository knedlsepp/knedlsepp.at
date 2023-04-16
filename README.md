# knedlsepp.at (Archived)
This was at one point the configuration for my toy server on AWS.
I don't have a use right now apart from hosting a static site, so I ATM I'm just using github pages via https://github.com/knedlsepp/knedlsepp.at-landing-page.
Might be revived at some point.

# How-to deploy

```
nixos-rebuild switch --flake .\#knedlsepp-aws --target-host root@knedlsepp.at --build-host root@knedlsepp.at
```

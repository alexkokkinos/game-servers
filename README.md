# Game Servers in Hetzner Cloud

## What is this doing?

```shell
├─ modules/
  ├─ hetzner-game-server/
     game.tf #Creates a generic server with a storage volume and a firewall supplied by an input variable
     ...other files
production.tf #So far, it creates an instance of the hetzner-game-server module to create a blank server intended for Minecraft. Also creates firewalls for this purpose.

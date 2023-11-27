# Edgerouter DHCP Configuration

## CLI

1. SSH into your router
2. Enter configuration mode with `configure` and press return
3. Enter the commands: (NOTE: replace SERVERIP with the IP of your iVentoy instance)
    ```
    set service dns forwarding options dhcp-match=set:bios,60,PXEClient:Arch:00000
    set service dns forwarding options dhcp-boot=tag:bios,iventoy_loader_16000_bios,,SERVER_IP
    set service dns forwarding options "dhcp-match=set:efi32,60,PXEClient:Arch:00002"
    set service dns forwarding options "dhcp-boot=tag:efi32,iventoy_loader_16000_uefi,,SERVERIP"
    set service dns forwarding options "dhcp-match=set:efi32-1,60,PXEClient:Arch:00006"
    set service dns forwarding options "dhcp-boot=tag:efi32-1,iventoy_loader_16000_uefi,,SERVERIP"
    set service dns forwarding options "dhcp-match=set:efi64,60,PXEClient:Arch:00007"
    set service dns forwarding options "dhcp-boot=tag:efi64,iventoy_loader_16000_uefi,,SERVERIP"
    set service dns forwarding options "dhcp-match=set:efi64-1,60,PXEClient:Arch:00008"
    set service dns forwarding options "dhcp-boot=tag:efi64-1,iventoy_loader_16000_uefi,,SERVERIP"
    set service dns forwarding options "dhcp-match=set:efi64-2,60,PXEClient:Arch:00009"
    set service dns forwarding options "dhcp-boot=tag:efi64-2,iventoy_loader_16000_uefi,,SERVERIP"

    ```
4. Enter the command `commit; save` and press return


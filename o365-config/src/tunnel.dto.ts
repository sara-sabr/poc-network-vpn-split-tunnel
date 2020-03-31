import { ApiProperty } from "@nestjs/swagger";

export class Tunnel {
    @ApiProperty({ description: "URLs that need to bypass the VPN." })
    urls: string[] = [];

    @ApiProperty({ description: "CIDR for IPv4 address space to be configured." })
    ipv4: string[] = [];

    @ApiProperty({ description: "CIDR for IPv6 address space to be configured." })
    ipv6: string[] = [];
}
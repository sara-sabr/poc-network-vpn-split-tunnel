import { ApiProperty } from "@nestjs/swagger";

export class Tunnel {
    @ApiProperty({ description: "URLs that need to bypass the VPN." })
    urls: string[] = [];

    @ApiProperty({ description: "CIDR for IPv4 address space to be configured." })
    ipv4: string[] = [];

    @ApiProperty({ description: "CIDR for IPv6 address space to be configured." })
    ipv6: string[] = [];

    @ApiProperty({ description: "Number of entries required for IPv6." })
    ipv6TotalEntries: number;

    @ApiProperty({ description: "Number of entries required for IPv4." })
    ipv4TotalEntries: number;

    @ApiProperty({ description: "Number of entries required for URLs to bypass VPN." })
    urlsTotalEntries: number;

}
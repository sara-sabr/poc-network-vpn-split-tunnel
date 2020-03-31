import { ApiProperty } from '@nestjs/swagger';

/**
 * Microsoft O365 endpoint web method returns all records for IP address ranges and URLs that make up the Office 365 service.
 *
 * Values are defined by Microsoft found at https://docs.microsoft.com/en-us/office365/enterprise/office-365-ip-web-service.
 */
export class O365Dto {
  @ApiProperty({ description: 'The immutable id number of the endpoint set.' })
  id: number;

  @ApiProperty({
    description:
      'The service area that this is part of: Common, Exchange, SharePoint, or Skype',
    type: 'string',
    enum: ['Common', 'Exchange', 'Sharepoint', 'Skype'],
  })
  serviceArea: 'Common' | 'Exchange' | 'Sharepoint' | 'Skype';

  @ApiProperty({
    description:
      'URLs for the endpoint set. A JSON array of DNS records. Omitted if blank.',
  })
  urls: string[];

  @ApiProperty({
    description:
      'TCP ports for the endpoint set. All ports elements are formatted as a comma-separated list of ports or port ranges separated by a dash character (-). Ports apply to all IP addresses and all URLs in the endpoint set for a given category. Omitted if blank.',
  })
  tcpPorts: string;

  @ApiProperty({
    description:
      'UDP ports for the IP address ranges in this endpoint set. Omitted if blank.',
  })
  udpPorts: string;

  @ApiProperty({
    description:
      ' The IP address ranges associated with this endpoint set as associated with the listed TCP or UDP ports. A JSON array of IP address ranges. Omitted if blank.',
  })
  ips: string[];

  @ApiProperty({
    description:
      'The connectivity category for the endpoint set. Valid values are Optimize, Allow, and Default. If you search the endpoints web method output for the category of a specific IP address or URL, it is possible that your query will return multiple categories. In such a case, follow the recommendation for the highest priority category. For example, if the endpoint appears in both Optimize and Allow, you should follow the requirements for Optimize. Required.',
  })
  category: 'Optimize' | 'Allow' | 'Default';

  @ApiProperty({
    description:
      'True if this endpoint set is routed over ExpressRoute, False if not.',
  })
  expressRoute: boolean;

  @ApiProperty({
    description:
      'True if this endpoint set is required to have connectivity for Office 365 to be supported. False if this endpoint set is optional.',
  })
  required: boolean;

  @ApiProperty({
    description:
      'For optional endpoints, this text describes Office 365 functionality that would be unavailable if IP addresses or URLs in this endpoint set cannot be accessed at the network layer. Omitted if blank.',
  })
  notes: string;
}

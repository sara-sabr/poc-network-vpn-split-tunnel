import { Controller, Get, Query } from '@nestjs/common';
import { AppService } from './app.service';
import { Tunnel } from './tunnel.dto';
import { Version } from './version.dto';
import { ApiOkResponse, ApiBadRequestResponse, ApiQuery, ApiOperation } from '@nestjs/swagger';
import { ServiceAreas } from './o365.serviceAreas.enum';
import { Instance } from './o365.instance.enum';
import { uuid } from 'uuidv4';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get("/version")
  @ApiOkResponse({ description: 'The currernt version of the API.' })
  @ApiOperation({
    summary: 'Version',
    description: 'The version of the API'
  })
  getVersion(): Version {
    return new Version();
  }

  @Get("/")
  @ApiOkResponse({ description: 'Instructions.' })
  @ApiOperation({
    summary: 'Home page',
    description: 'Show something, so not error :) '
  })
  showInstruction(): string {
    return "Please access /api for details of endpoints";
  }

  @Get("/split-tunnel")
  @ApiOkResponse({ description: 'Configuration for the tunnel.', type: Tunnel })
  @ApiBadRequestResponse({ description: 'Error.' })
  @ApiQuery({ name: 'ServiceAreas', isArray: true, enum: ServiceAreas, description: 'A comma-separated list of service areas. Valid items are Common, Exchange, SharePoint, and Skype. Because Common service area items are a prerequisite for all other service areas, the web service always includes them. If you do not include this parameter, all service areas are returned', required: false })
  @ApiQuery({ name: 'Instance', enum: Instance, description: 'This required parameter specifies the instance from which to return the endpoints', required: false })
  @ApiQuery({ name: 'ClientRequestId', description: 'A required GUID that you generate for client association.', required: true })
  @ApiQuery({ name: 'NoIPv6', description: "Set the value to true to exclude IPv6 addresses from the output if you don't use IPv6 in your network.", required: false })
  @ApiOperation({
    summary: 'Split Tunnel Configuration',
    description: 'Returns the configuration in split tunnel format'
  })
  getSplitTunnelSettings(
    @Query('ClientRequestId') clientRequestId: string = uuid(),
    @Query('ServiceAreas') serviceAreas: ServiceAreas[] = [],
    @Query('NoIPv6') noIPv6: boolean = false,
    @Query('Instance') instance: Instance = Instance.Worldwide
  ): Promise<Tunnel> {
    return this.appService.getSplitTunnelConfig(clientRequestId, serviceAreas, noIPv6, instance);
  }

  @Get("/inverse-split-tunnel")
  @ApiOperation({
    summary: 'Inverse Split Tunnel Configuration',
    description: 'Returns the configuration in inverse split tunnel format'
  })
  @ApiOkResponse({ description: 'Configuration for the tunnel.', type: Tunnel })
  @ApiBadRequestResponse({ description: 'Error.' })
  @ApiQuery({ name: 'ServiceAreas', isArray: true, enum: ServiceAreas, description: 'A comma-separated list of service areas. Valid items are Common, Exchange, SharePoint, and Skype. Because Common service area items are a prerequisite for all other service areas, the web service always includes them. If you do not include this parameter, all service areas are returned', required: false })
  @ApiQuery({ name: 'Instance', enum: Instance, description: 'This required parameter specifies the instance from which to return the endpoints', required: true })
  @ApiQuery({ name: 'ClientRequestId', description: 'A required GUID that you generate for client association.', required: true })
  @ApiQuery({ name: 'NoIPv6', description: "Set the value to true to exclude IPv6 addresses from the output if you don't use IPv6 in your network.", required: false })
  getInverseSplitTunnelSettings(
    @Query('ClientRequestId') clientRequestId: string = uuid(),
    @Query('ServiceAreas') serviceAreas: ServiceAreas[] = [],
    @Query('NoIPv6') noIPv6: boolean = false,
    @Query('Instance') instance: Instance = Instance.Worldwide
  ): Promise<Tunnel> {
    return this.appService.getInverseSplitTunnelConfig(clientRequestId, serviceAreas, noIPv6, instance);
  }
}

import { Injectable, HttpService } from '@nestjs/common';
import { O365Dto } from './o365.dto';
import { AxiosResponse } from 'axios';
import { Observable } from 'rxjs';
import { Tunnel } from './tunnel.dto';
import cidrTools from 'cidr-tools';
import { ServiceAreas } from './o365.serviceAreas.enum';

@Injectable()
export class AppService {
  constructor(private httpService: HttpService) { }

  async getInverseSplitTunnelConfig(clientrequestid: string, serviceAreas: ServiceAreas[], noIPv6: boolean, instance: string): Promise<Tunnel> {
    return this.getCidrBlocks(clientrequestid, serviceAreas, noIPv6, instance);
  }

  async getSplitTunnelConfig(clientrequestid: string, serviceAreas: ServiceAreas[], noIPv6: boolean, instance: string): Promise<Tunnel> {
    let tunnelForInverse: Tunnel = await this.getCidrBlocks(clientrequestid, serviceAreas, noIPv6, instance);
    let tunnelForSplit: Tunnel = new Tunnel();

    tunnelForSplit.ipv4 = cidrTools.exclude("0.0.0.0/0", tunnelForInverse.ipv4);

    if (!noIPv6) {
      tunnelForSplit.ipv6 = cidrTools.exclude("::/0", tunnelForInverse.ipv6);
    }
    tunnelForSplit.urls = tunnelForInverse.urls;

    return tunnelForSplit;
  }

  async getCidrBlocks(clientrequestid: string, serviceAreas: ServiceAreas[], noIPv6: boolean, instance: string): Promise<Tunnel> {

    if (instance == null) {
      instance = "worldwide";
    }

    var serviceUrl = 'https://endpoints.office.com/endpoints/' + instance + '?ClientRequestId=' + clientrequestid;
    if (serviceAreas.length > 0) {
      let serviceAreaString = serviceAreas.toString();

      if (serviceAreas.indexOf(ServiceAreas.All) == -1) {
        serviceUrl += '&ServiceAreas=' + serviceAreaString;
      }
    }

    if (noIPv6) {
      serviceUrl += '&NoIPv6=' + noIPv6;
    }

    console.log(serviceUrl);

    var o365DataResultObservable: Observable<AxiosResponse<O365Dto[]>> = this.httpService.get(
      serviceUrl,
    );

    var o365AxiosResult = await o365DataResultObservable.toPromise();
    var o365Result = o365AxiosResult.data;

    let tunnel: Tunnel = new Tunnel();
    let ip;
    let url;
    let ipv4s: Map<string, number> = new Map<string, number>();
    let ipv6s: Map<string, number> = new Map<string, number>();
    let urls: Map<string, number> = new Map<string, number>();
    let o365Entry: O365Dto;

    for (var resultIdx = o365Result.length - 1; resultIdx >= 0; resultIdx--) {
      o365Entry = o365Result[resultIdx];

      if (o365Entry.ips != null) {
        for (var ipIdx = o365Entry.ips.length - 1; ipIdx >= 0; ipIdx--) {
          ip = o365Entry.ips[ipIdx];
          if (this.isIpV4(ip)) {
            ipv4s.set(ip, 1);
          } else {
            ipv6s.set(ip, 1);
          }
        }
      }

      if (o365Entry.urls != null) {
        for (var urlIdx = o365Entry.urls.length - 1; urlIdx >= 0; urlIdx--) {
          url = o365Entry.urls[urlIdx];
          urls.set(url, 1);
        }
      }
    }

    for (const [key] of urls) {
      tunnel.urls.push(key);
    }

    tunnel.urls = tunnel.urls.sort();

    for (var i of ipv4s.keys()) {
      tunnel.ipv4.push(i);
    }

    tunnel.ipv4 = tunnel.ipv4.sort(this.smallerIpV4);

    for (var i of ipv6s.keys()) {
      tunnel.ipv6.push(i);
    }

    return tunnel;
  }


  isIpV4(ip: string): boolean {
    // Not the best way of checking ...
    return ip.indexOf(':') == -1;
  }

  compareNumber(aStr: string, bStr: string): number {
    let a = Number(aStr);
    let b = Number(bStr);
    if (a < b) return -1;
    else if (a == b) return 0;
    else return 1;
  }

  smallerIpV4(a: string, b: string): number {
    let aOctets = a.substring(0, a.indexOf('/')).split('.');
    let bOctets = b.substring(0, b.indexOf('/')).split('.');

    let aNumOctet = Number(aOctets[0]);
    let bNumOctet = Number(bOctets[0]);

    if (aNumOctet < bNumOctet) {
      return -1;
    } else if (aNumOctet > bNumOctet) {
      return 1;
    }

    aNumOctet = Number(aOctets[1]);
    bNumOctet = Number(bOctets[1]);

    if (aNumOctet < bNumOctet) {
      return -1;
    } else if (aNumOctet > bNumOctet) {
      return 1;
    }

    aNumOctet = Number(aOctets[2]);
    bNumOctet = Number(bOctets[2]);

    if (aNumOctet < bNumOctet) {
      return -1;
    } else if (aNumOctet > bNumOctet) {
      return 1;
    }

    aNumOctet = Number(aOctets[3]);
    bNumOctet = Number(bOctets[3]);

    if (aNumOctet < bNumOctet) {
      return -1;
    } else if (aNumOctet > bNumOctet) {
      return 1;
    }

    return 0;
  }
}

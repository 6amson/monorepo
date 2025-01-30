import { Get, Injectable, Post } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }

  @Get('mono')
  getHealth(): string {
    return 'Hello mono!';
  }
}


  

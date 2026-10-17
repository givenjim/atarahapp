import { ApiProperty } from '@nestjs/swagger';

export class PublicConfigDto {
  @ApiProperty({ description: 'Show "Continue with Google" only when true.' })
  googleSignIn!: boolean;
}

export class LegalDocumentDto {
  @ApiProperty({ enum: ['TERMS', 'PRIVACY'] }) type!: string;
  @ApiProperty() version!: string;
  @ApiProperty() title!: string;
  @ApiProperty() body!: string;
  @ApiProperty({ description: 'True until the owner publishes reviewed text. Show it as a draft.' })
  isDraft!: boolean;
}

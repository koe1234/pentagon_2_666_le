/*--- This file was generated by rom2c Arithmetic Compressor/Converter v1.0 ---*/

const unsigned char logo[] = {
	0x80, 0xbf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xe5,
	0xdd, 0x14, 0xd8, 0xc6, 0xa3, 0x8e, 0xfd, 0x6a, 0xcc, 0x80,
	0x7e, 0x2d, 0x0e, 0x14, 0x4a, 0x66, 0xa0, 0xeb, 0xa0, 0xce,
	0x92, 0x62, 0xcf, 0x95, 0xfd, 0xef, 0xe9, 0x83, 0x09, 0x34,
	0x56, 0x49, 0xa0, 0x4a, 0x17, 0x93, 0x45, 0x9e, 0xe3, 0xee,
	0x5e, 0x57, 0x2b, 0xb4, 0x74, 0xc9, 0xff, 0x9f, 0x65, 0xc1,
	0xc3, 0x4c, 0xe1, 0x03, 0x52, 0x83, 0x96, 0x1a, 0xfa, 0x9a,
	0x59, 0x41, 0xf7, 0x89, 0x58, 0xa4, 0xd6, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0x8f, 0x68, 0xcb, 0xbc, 0x10, 0x1e, 0xb7, 0x89, 0xb0, 0x34,
	0x6d, 0xd2, 0xf7, 0x29, 0xa8, 0x21, 0xa8, 0x6a, 0xf9, 0x01,
	0x3e, 0xb7, 0x91, 0x62, 0x9d, 0x1f, 0xfe, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xeb, 0xd2, 0x45,
	0xed, 0x75, 0xc7, 0x73, 0x74, 0xb5, 0x5e, 0xc4, 0x53, 0x08,
	0x27, 0x59, 0x22, 0xb1, 0x3d, 0x23, 0x30, 0x9b, 0xb2, 0xeb,
	0xf2, 0x50, 0xbf, 0x5d, 0x56, 0xd0, 0x5b, 0x78, 0x63, 0xfe,
	0x75, 0x96, 0x1c, 0x41, 0x70, 0x6e, 0x28, 0x48, 0xfc, 0x3b,
	0x2f, 0x9d, 0x74, 0x56, 0xb1, 0x8d, 0x43, 0xf1, 0x4b, 0x42,
	0x69, 0x3b, 0xf9, 0x62, 0x9e, 0xc3, 0xed, 0x8e, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0x4b, 0x5f, 0x65, 0x9e, 0x74,
	0x42, 0xd7, 0x18, 0x11, 0x92, 0x48, 0x5b, 0x32, 0x8e, 0x72,
	0x30, 0xc0, 0x0b, 0x10, 0x86, 0x3b, 0x5b, 0x08, 0xc9, 0xd5,
	0x42, 0x00, 0xa1, 0xc2, 0xc1, 0x47, 0x53, 0xdd, 0x75, 0xe8,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x4b, 0x9b,
	0x74, 0x22, 0xe6, 0x7b, 0x90, 0x6a, 0x04, 0x6e, 0x8e, 0x4c,
	0xcd, 0x1a, 0xdf, 0x69, 0xcf, 0x6d, 0xc0, 0xaa, 0x82, 0x66,
	0x7a, 0xe3, 0xe1, 0x70, 0xad, 0x43, 0x9c, 0x9f, 0x6b, 0xde,
	0x1d, 0x48, 0x39, 0xdc, 0xe0, 0x88, 0xa6, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x56, 0x80, 0x7d,
	0x5b, 0x37, 0x17, 0xfb, 0x0d, 0x79, 0x77, 0x3a, 0x2f, 0x24,
	0x7f, 0x7c, 0x33, 0x21, 0x68, 0x3b, 0xe3, 0x46, 0x6d, 0x6b,
	0x78, 0xcc, 0x68, 0x1d, 0x20, 0xf4, 0xd0, 0x68, 0xf5, 0xaa,
	0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xab, 0xa9, 0xd1,
	0x5d, 0x11, 0x0b, 0x4a, 0xe4, 0xe8, 0x63, 0x81, 0x75, 0x86,
	0x09, 0xd8, 0x4e, 0x29, 0xec, 0x55, 0xe6, 0xb3, 0x34, 0xd8,
	0x6e, 0x1b, 0x94, 0x4d, 0xad, 0xd4, 0xc8, 0x18, 0xb2, 0xf1,
	0xe1, 0x14, 0x0b, 0x96, 0x47, 0xfd, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0x72, 0x26, 0x9d, 0x53, 0xc2, 0xa1,
	0x5e, 0x4f, 0xc8, 0x2c, 0xde, 0x71, 0x3a, 0x77, 0xfd, 0xe1,
	0x3e, 0xa5, 0xec, 0x96, 0x27, 0xf2, 0xfe, 0x30, 0x1c, 0x3c,
	0x3d, 0xa4, 0x2f, 0x45, 0x8d, 0xef, 0xbe, 0xff, 0xff, 0xff,
	0x91, 0x78, 0xc2, 0xff, 0xb7, 0x48, 0x87, 0xd6, 0x75, 0xfb,
	0x12, 0x5b, 0x87, 0x1e, 0x25, 0x34, 0x24, 0x3e, 0xf7, 0x46,
	0xde, 0x81, 0xc2, 0xa3, 0x41, 0x25, 0x23, 0x59, 0xdc, 0xa7,
	0xcb, 0x34, 0xb3, 0x20, 0xe8, 0x9b, 0x21, 0xfb, 0x98, 0xd5,
	0x98, 0xf7, 0x8b, 0x07, 0x4f, 0xd4, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xef, 0x73, 0xa3, 0x55, 0xd5, 0xa9, 0x0e,
	0x1f, 0x97, 0x7c, 0x62, 0x99, 0xbb, 0x7e, 0x9d, 0x98, 0x9f,
	0x08, 0x80, 0x78, 0xda, 0x61, 0x00, 0xfa, 0x77, 0xaa, 0x3e,
	0x05, 0x6c, 0x2d, 0x25, 0x8e, 0x7e, 0xfd, 0xff, 0xff, 0x52,
	0x46, 0x6f, 0x92, 0x55, 0x1e, 0xd0, 0x80, 0x12, 0x7f, 0xa5,
	0x6d, 0xc8, 0x10, 0xfd, 0xc1, 0xfc, 0xaf, 0xc9, 0x4a, 0xdf,
	0x05, 0x79, 0x94, 0x94, 0xca, 0x15, 0x80, 0xb9, 0x94, 0xc7,
	0xd7, 0x9e, 0x6e, 0xee, 0x5e, 0x8e, 0x7a, 0xb2, 0x1f, 0x9f,
	0x38, 0x39, 0x52, 0x34, 0x0a, 0x28, 0x2b, 0xb6, 0x06, 0x79,
	0x0b, 0x90, 0xda, 0x7c, 0x4f, 0xbd, 0x79, 0xee, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xf2, 0x7e, 0xe7, 0x9b, 0x3a,
	0x4f, 0x92, 0xdc, 0x25, 0x4b, 0xa0, 0x34, 0x6a, 0x45, 0x20,
	0xc9, 0x1f, 0xde, 0x32, 0xb8, 0xaa, 0x4e, 0x36, 0x6f, 0xe0,
	0x02, 0xad, 0x88, 0xf7, 0xff, 0xff, 0x4f, 0xb0, 0xe6, 0xd7,
	0xee, 0xb4, 0x23, 0x08, 0xac, 0xc1, 0xb6, 0xce, 0x8e, 0x4d,
	0xa8, 0x1a, 0x8a, 0x78, 0x62, 0x31, 0x0a, 0x74, 0x9f, 0x49,
	0xf8, 0xf1, 0x44, 0xf7, 0x68, 0x74, 0xe5, 0xbd, 0x16, 0xbc,
	0xa4, 0x4b, 0x0e, 0xb6, 0x57, 0x83, 0xdf, 0x47, 0x11, 0x61,
	0x34, 0xf5, 0xf2, 0xae, 0x63, 0x4a, 0xc2, 0x93, 0xb4, 0x01,
	0x3c, 0xf5, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xcf, 0x37,
	0xca, 0xc0, 0x6d, 0x4a, 0x39, 0xca, 0xd1, 0x8b, 0x98, 0xd7,
	0xd9, 0xba, 0x23, 0x7c, 0x1e, 0x4a, 0xb7, 0x6b, 0x0a, 0xa9,
	0x61, 0x89, 0x22, 0xad, 0x0d, 0xab, 0x1f, 0xf1, 0xff, 0x7f,
	0x4b, 0x89, 0x39, 0xca, 0x06, 0x0a, 0x2a, 0x05, 0xf2, 0xe0,
	0xec, 0x17, 0xfc, 0x34, 0x12, 0x08, 0x82, 0x3f, 0xcf, 0xd4,
	0xe7, 0x5d, 0x3b, 0x48, 0xde, 0x50, 0xe8, 0xb0, 0x47, 0xce,
	0xe3, 0xcd, 0xb2, 0x7c, 0xfb, 0x9a, 0x4f, 0x9b, 0x17, 0xf7,
	0x9f, 0x26, 0x76, 0x59, 0x16, 0x86, 0xd5, 0x6a, 0x80, 0xfe,
	0xad, 0x67, 0xc6, 0x62, 0xff, 0xff, 0xff, 0xff, 0xff, 0x9f,
	0x34, 0x28, 0x0d, 0x19, 0x6f, 0xb1, 0x85, 0x7c, 0x0a, 0x6c,
	0xfa, 0x2d, 0x2c, 0x63, 0x3d, 0xe6, 0x2f, 0x03, 0xaa, 0xd6,
	0x40, 0x3b, 0x43, 0xab, 0xde, 0xd5, 0xd3, 0xd6, 0x6a, 0x76,
	0xe2, 0xb6, 0x17, 0xfc, 0x73, 0x6f, 0x3b, 0xf8, 0xc1, 0xfe,
	0x5b, 0xf8, 0x85, 0xfa, 0x38, 0x5b, 0x67, 0x6f, 0x46, 0xe3,
	0x8e, 0xdf, 0x48, 0x44, 0xa1, 0x57, 0xfe, 0xb7, 0x9a, 0x35,
	0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0x93, 0xce, 0x10, 0xe2,
	0x70, 0x69, 0x69, 0x28, 0x14, 0xaf, 0xfc, 0xf9, 0xb1, 0x74,
	0xb0, 0xa0, 0xe6, 0xad, 0xef, 0x2e, 0x60, 0xf3, 0xa6, 0xc6,
	0x74, 0x35, 0x9a, 0x10, 0x65, 0x99, 0xdc, 0xd4, 0x1f, 0x45,
	0x74, 0xfa, 0x87, 0xd9, 0xb1, 0xcb, 0x7e, 0x53, 0x30, 0xc4,
	0x61, 0x31, 0x53, 0xe6, 0xe3, 0x03, 0x6f, 0x81, 0xfd, 0xe9,
	0x36, 0x34, 0x65, 0x91, 0x15, 0xc6, 0x26, 0x00, 0x6e, 0x39,
	0x2d, 0x5f, 0xcf, 0xc4, 0xee, 0xbc, 0x9b, 0xd2, 0x55, 0x6c,
	0xac, 0x86, 0x48, 0x32, 0x8b, 0x28, 0x6b, 0x59, 0xba, 0x31,
	0xce, 0xfe, 0x3d, 0x57, 0x16, 0x17, 0x59, 0xff, 0xdb, 0x72,
	0xa1, 0x10, 0xfe, 0xff, 0x5f, 0xf9, 0x15, 0x2a, 0xbb, 0x02,
	0x56, 0x20, 0x62, 0xe6, 0xa1, 0xca, 0x96, 0x0a, 0x1d, 0x73,
	0x84, 0xdb, 0x94, 0x01, 0x25, 0xed, 0x1c, 0xa4, 0x96, 0x09,
	0xae, 0xa4, 0x25, 0xe7, 0x9b, 0x50, 0x8b, 0x48, 0xb1, 0xc8,
	0xf8, 0xd5, 0x05, 0xae, 0x75, 0xeb, 0xf3, 0x0d, 0x37, 0x10,
	0xd8, 0xc8, 0xef, 0x69, 0xdf, 0xc9, 0x28, 0xfd, 0x69, 0x5a,
	0x40, 0x33, 0x16, 0x24, 0x0e, 0x4c, 0x06, 0x2b, 0xb6, 0xa5,
	0xd0, 0xfa, 0x51, 0xe1, 0x63, 0xe7, 0x59, 0x4c, 0x7c, 0x68,
	0xa1, 0x7b, 0xe4, 0xcc, 0x78, 0xec, 0x4b, 0xf5, 0xc3, 0xa1,
	0x78, 0x85, 0x99, 0xd6, 0x48, 0xca, 0xb0, 0xf2, 0x2f, 0xff,
	0x17, 0x3c, 0x84, 0x96, 0xf3, 0xff, 0xbf, 0x87, 0x7e, 0xb5,
	0x57, 0x1e, 0x4e, 0xee, 0x32, 0x7c, 0x26, 0x32, 0xcf, 0xb0,
	0x2d, 0x5f, 0x42, 0x64, 0x23, 0x6d, 0x27, 0x53, 0x0c, 0x8a,
	0x35, 0xc2, 0xfa, 0x0a, 0x4e, 0x74, 0xe7, 0xf3, 0x24, 0x0d,
	0x3c, 0x86, 0x15, 0x3d, 0xd3, 0xfd, 0xff, 0xff, 0x6f, 0x86,
	0x3d, 0xc5, 0xd5, 0xd6, 0x34, 0xeb, 0x03, 0xf4, 0x2d, 0xdf,
	0xf8, 0x5e, 0x3c, 0xf1, 0xd2, 0xeb, 0xab, 0xed, 0x0b, 0x41,
	0x40, 0xe9, 0x01, 0xae, 0xa3, 0x1f, 0x5a, 0xab, 0x4e, 0xc5,
	0x3b, 0xf5, 0x9d, 0xec, 0xcd, 0x8c, 0x5a, 0x5e, 0x6a, 0x42,
	0x0a, 0xf8, 0x27, 0xb4, 0xa3, 0x78, 0xbd, 0x04, 0xfd, 0xff,
	0xff, 0xff, 0xff, 0x1b, 0xaf, 0x2a, 0x29, 0xe3, 0x0c, 0x1d,
	0x2f, 0xe7, 0xb2, 0xa1, 0xed, 0x54, 0x50, 0xfd, 0x3f, 0x56,
	0xa4, 0xe7, 0x0e, 0x69, 0x21, 0x09, 0x15, 0x11, 0xc3, 0x0e,
	0xfe, 0x02, 0xee, 0xa3, 0xca, 0xed, 0xb5, 0xf1, 0xcf, 0x7a,
	0xa2, 0xba, 0xf9, 0x8c, 0xd5, 0xff, 0xff, 0xff, 0x97, 0xc8,
	0xbf, 0xa7, 0xcd, 0xd5, 0x38, 0x62, 0x9c, 0xee, 0x10, 0xa3,
	0x60, 0x5d, 0xf5, 0x83, 0x3f, 0x59, 0xfd, 0x97, 0x21, 0x7c,
	0xc1, 0xf5, 0xe5, 0xc1, 0xc1, 0x1d, 0x48, 0xbb, 0x4b, 0x2f,
	0xee, 0x98, 0xce, 0x3b, 0x7f, 0x27, 0xae, 0x10, 0x9f, 0xdf,
	0x07, 0x61, 0xf2, 0xc8, 0xe3, 0xff, 0xff, 0xff, 0xff, 0xb7,
	0x91, 0x3e, 0xd1, 0xf2, 0x46, 0x83, 0x2f, 0xa7, 0x9d, 0x30,
	0xe5, 0x04, 0x22, 0xd3, 0x3c, 0x00, 0xf8, 0x97, 0x21, 0xc6,
	0xb7, 0x33, 0xd3, 0xe5, 0x2e, 0x1d, 0x07, 0x83, 0xe0, 0x90,
	0x40, 0x9c, 0xec, 0xd7, 0x40, 0x49, 0x85, 0xcc, 0x0f, 0x22,
	0xa4, 0xe4, 0xff, 0xff, 0x1f, 0x55, 0xd1, 0x54, 0x5d, 0xd2,
	0x9a, 0xe1, 0xfe, 0xb6, 0xf4, 0x96, 0x6d, 0x38, 0x66, 0xe6,
	0xcd, 0x03, 0xf0, 0x2f, 0x42, 0x22, 0x59, 0xf8, 0xb6, 0x1e,
	0x9b, 0x31, 0x9d, 0x70, 0xa3, 0x98, 0x07, 0xe6, 0x2e, 0x54,
	0xd2, 0x0f, 0x34, 0xe5, 0x60, 0xf7, 0x8a, 0xae, 0xc4, 0xff,
	0xff, 0xff, 0xff, 0x3f, 0xf0, 0x66, 0x45, 0x07, 0x1c, 0x93,
	0xcf, 0x16, 0xec, 0xff, 0xa2, 0x4a, 0x35, 0x93, 0xfa, 0x6e,
	0xf5, 0x6d, 0x59, 0x9c, 0xd8, 0x09, 0x0e, 0x15, 0x90, 0x63,
	0xa5, 0xd8, 0x1f, 0xd3, 0xc7, 0x15, 0xb7, 0x8c, 0x96, 0xd3,
	0x9b, 0xc4, 0x42, 0xfe, 0xff, 0x3f, 0x49, 0x91, 0xa2, 0xf0,
	0xc4, 0x12, 0xee, 0x20, 0xe6, 0x9c, 0xda, 0x48, 0xfe, 0xb8,
	0x4d, 0x45, 0x14, 0xb4, 0xff, 0x6a, 0x4c, 0x07, 0xfa, 0xff,
	0x5f, 0x26, 0x49, 0xeb, 0xfe, 0xff, 0xff, 0xff, 0x7f, 0xc4,
	0xf8, 0x63, 0xdc, 0x81, 0x55, 0x46, 0x1c, 0xf7, 0xe0, 0x35,
	0x4a, 0x10, 0x58, 0xe3, 0x63, 0xda, 0x36, 0xc2, 0x75, 0xbf,
	0x34, 0xa8, 0x34, 0xc0, 0x46, 0x3d, 0xb9, 0x13, 0xed, 0x1b,
	0x69, 0x9c, 0x44, 0x68, 0xe2, 0xd7, 0xbf, 0x0b, 0xe8, 0x7a,
	0x7a, 0x0a, 0x6a, 0xbb, 0x0e, 0x02, 0x24, 0xba, 0x14, 0x95,
	0x11, 0x1e, 0x40, 0x98, 0x14, 0xb8, 0xf9, 0x3f, 0xd1, 0xfc,
	0xff, 0xa7, 0x08, 0x53, 0xd3, 0xff, 0xff, 0xff, 0xff, 0xe7,
	0x20, 0xc3, 0xe6, 0x55, 0xd9, 0x50, 0xc6, 0x1f, 0xc8, 0x87,
	0xe5, 0x33, 0x58, 0x18, 0x1f, 0x90, 0xad, 0x8e, 0x42, 0x0c,
	0x1c, 0xf7, 0x3a, 0xa3, 0xb9, 0x6f, 0x1b, 0x78, 0x79, 0x2a,
	0x9b, 0xb5, 0xe1, 0x9c, 0x5a, 0xe9, 0x4b, 0x3f, 0x9b, 0x02,
	0x59, 0x4f, 0x2e, 0x4d, 0x7d, 0x28, 0xb7, 0xd5, 0xbb, 0xdb,
	0xdd, 0x60, 0xba, 0xb6, 0x99, 0xde, 0x31, 0x76, 0xc1, 0x20,
	0x0c, 0xf7, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xfb, 0xb6, 0xb6,
	0xff, 0x9d, 0x3e, 0x65, 0x04, 0x3e, 0x01, 0x7d, 0x9d, 0x8f,
	0xc6, 0xd2, 0x9e, 0x8e, 0xa3, 0xff, 0xff, 0xff, 0xff, 0xff,
	0x2f, 0xc8, 0x16, 0x39, 0x46, 0x98, 0x8c, 0xcd, 0x51, 0x46,
	0x0f, 0xd0, 0x7e, 0x37, 0x9b, 0x64, 0x4b, 0xf2, 0x48, 0x0e,
	0xaf, 0xc2, 0xbe, 0x67, 0xd5, 0xe6, 0x36, 0x02, 0x0e, 0x8a,
	0x82, 0x51, 0x11, 0x52, 0x65, 0x25, 0x49, 0x08, 0x74, 0xea,
	0x51, 0x6c, 0x9f, 0xca, 0xe8, 0xff, 0xff, 0xff, 0xff, 0x7f,
	0xc1, 0xd0, 0xf4, 0xff, 0xfa, 0x4b, 0x92, 0x4f, 0xc1, 0x0e,
	0x26, 0x22, 0x58, 0x21, 0x24, 0xe8, 0x75, 0x24, 0xf2, 0xff,
	0xff, 0xff, 0xff, 0x7f, 0x5c, 0x70, 0x0f, 0x99, 0x13, 0xe0,
	0x7c, 0xf7, 0xfb, 0xb2, 0x54, 0x22, 0x47, 0x30, 0x6b, 0x2c,
	0xfe, 0x18, 0x89, 0x8c, 0x7d, 0xea, 0x97, 0xd1, 0x6d, 0xd5,
	0x81, 0xbd, 0x31, 0x4c, 0xd7, 0x01, 0x0b, 0x6a, 0x39, 0x99,
	0x6d, 0x3c, 0x12, 0x96, 0x47, 0xd6, 0x44, 0xf4, 0xff, 0xff,
	0xff, 0xff, 0xb9, 0x31, 0xd4, 0xfd, 0x82, 0xe4, 0xc7, 0xb8,
	0x96, 0xf7, 0x64, 0x4e, 0xce, 0xa7, 0x4c, 0xd3, 0x6f, 0x78,
	0x0a, 0x42, 0xb7, 0x49, 0x98, 0xa8, 0xb1, 0x7e, 0xd7, 0xff,
	0xff, 0xff, 0xff, 0x6b, 0x49, 0x05, 0xc0, 0xa2, 0x04, 0xfd,
	0x17, 0x80, 0x13, 0x36, 0xcc, 0x82, 0x12, 0x37, 0xcf, 0xb4,
	0xc8, 0x36, 0x04, 0xb6, 0x92, 0xb6, 0x87, 0x28, 0x79, 0xd5,
	0x8c, 0xc5, 0x5f, 0x7b, 0x9f, 0x1e, 0xfc, 0xf1, 0xdd, 0x81,
	0xfe, 0x14, 0x6e, 0xe2, 0x63, 0xe0, 0xff, 0xff, 0xff, 0xff,
	0xcd, 0x9e, 0x80, 0x42, 0xc1, 0x1f, 0xbd, 0x83, 0xd0, 0x88,
	0xc6, 0x69, 0x2b, 0x42, 0x0f, 0xfb, 0xe3, 0x24, 0x9e, 0xaa,
	0x5d, 0xf8, 0xff, 0xff, 0xff, 0xff, 0x5b, 0xf2, 0xcd, 0x84,
	0x72, 0x45, 0xcc, 0x44, 0x62, 0x85, 0xe4, 0x1a, 0x65, 0x5c,
	0xfc, 0xff, 0xff, 0xff, 0xff, 0xe3, 0x5f, 0x48, 0x07, 0x37,
	0x86, 0x29, 0x4e, 0x95, 0x0f, 0xf3, 0x0b, 0x7d, 0x25, 0x78,
	0x77, 0x9d, 0x82, 0xd8, 0x67, 0x05, 0xfa, 0xff, 0xff, 0xff,
	0xdf, 0x3d, 0x0a, 0x00, 0x06, 0x54, 0x68, 0xcd, 0x64, 0x52,
	0x51, 0x2c, 0x06, 0x95, 0x28, 0x52, 0xa8, 0xa3, 0xe7, 0x44,
	0xa2, 0x80, 0xf7, 0xed, 0x35, 0xf4, 0xec, 0x28, 0x02, 0x0b,
	0x03, 0x48, 0x05, 0x2b, 0x50, 0x01, 0xd3, 0xa2, 0xd2, 0xff,
	0xff, 0xff, 0xff, 0x7f, 0xda, 0xb0, 0xb8, 0x42, 0x44, 0x97,
	0x66, 0xb1, 0x48, 0xd4, 0x72, 0xce, 0x9f, 0x34, 0xae, 0xcb,
	0x5e, 0x05, 0xe6, 0x15, 0xc3, 0xff, 0xff, 0xff, 0x3f, 0xcd,
	0xe2, 0x61, 0x97, 0x78, 0x86, 0x3c, 0xcb, 0x94, 0xfe, 0x06,
	0x72, 0x79, 0xb2, 0x4c, 0xa5, 0x23, 0x61, 0x6b, 0xf2, 0xd2,
	0x20, 0xb4, 0x23, 0xf4, 0xc9, 0x73, 0x1b, 0x04, 0xae, 0xe9,
	0x88, 0x7a, 0x39, 0xf4, 0xb6, 0xf0, 0x9c, 0xfd, 0xff, 0x3f,
	0x59, 0xaa, 0x29, 0xfe, 0xe5, 0xee, 0xda, 0x95, 0x4f, 0x5c,
	0x73, 0x85, 0xb2, 0xc7, 0x97, 0xd1, 0xc7, 0x9f, 0xf3, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xbf, 0x43, 0x30, 0x4b, 0x26, 0xa6,
	0xeb, 0x93, 0xa4, 0xda, 0xc1, 0xf9, 0x28, 0x66, 0x3c, 0xd3,
	0xa9, 0xc6, 0xb8, 0x2b, 0x29, 0x4d, 0xe9, 0x73, 0x48, 0x9f,
	0xb4, 0x92, 0x82, 0x04, 0x00, 0x06, 0x96, 0x23, 0x8f, 0xe6,
	0xff, 0xff, 0xff, 0xaf, 0x57, 0x23, 0xff, 0x8b, 0xe0, 0xf0,
	0xc9, 0x60, 0x5e, 0xd5, 0x53, 0xa7, 0xf0, 0x47, 0xb8, 0x5a,
	0x46, 0xfc, 0xff, 0xff, 0xff, 0xff, 0xff, 0x17, 0xc3, 0xcf,
	0x5e, 0x78, 0x43, 0xfb, 0x75, 0x1b, 0x0f, 0x74, 0x88, 0x45,
	0x0e, 0x7a, 0xd5, 0xac, 0xa3, 0x27, 0x8f, 0xb2, 0x14, 0xf2,
	0xa2, 0xc0, 0xd8, 0x21, 0xad, 0x3d, 0x7c, 0xee, 0x44, 0xb1,
	0x7a, 0x7b, 0xfa, 0xff, 0xff, 0x3f, 0x4d, 0x0f, 0x10, 0x42,
	0x76, 0x69, 0xf6, 0x62, 0x3c, 0xbf, 0x6b, 0x61, 0x40, 0xb5,
	0x0c, 0xfa, 0xbe, 0x24, 0xb9, 0xe8, 0x54, 0x05, 0x8d, 0xf0,
	0x78, 0x31, 0x72, 0x8a, 0xa3, 0x8a, 0xd5, 0x94, 0x7f, 0x5a,
	0xe4, 0x9a, 0x76, 0xb2, 0x4e, 0x7b, 0xbc, 0xe7, 0x0b, 0xe8,
	0x1f, 0x81, 0x10, 0x5d, 0xbc, 0xef, 0x34, 0x85, 0x77, 0x3b,
	0x48, 0x70, 0x9b, 0xf4, 0x93, 0xb0, 0xf8, 0xe5, 0x8a, 0x1c,
	0x0b, 0x74, 0xf3, 0xbf, 0x70, 0x3c, 0x49, 0x69, 0xea, 0x74,
	0xb1, 0x46, 0x5e, 0xf8, 0x34, 0x68, 0x57, 0xff, 0x66, 0x61,
	0x07, 0xf5, 0x70, 0x3f, 0x3c, 0xae, 0xc7, 0x58, 0x49, 0xb8,
	0x84, 0x4b, 0x8f, 0x40, 0xbe, 0xe4, 0xf5, 0x67, 0x95, 0x75,
	0xc7, 0xbb, 0x46, 0x9f, 0x86, 0xe5, 0x51, 0x46, 0xd6, 0x5e,
	0xa3, 0xed, 0xb8, 0x8a, 0xd1, 0x31, 0xf4, 0x54, 0xf4, 0xd8,
	0xa7, 0xc4, 0x88, 0xb8, 0xb1, 0x1b, 0x15, 0xcc, 0x50, 0x23,
	0xbf, 0x18, 0x59, 0x04, 0x51, 0x2e, 0xfb, 0x33, 0xc0, 0xa5,
	0xfd, 0x0c, 0xde, 0xe0, 0xf0, 0x50, 0x77, 0x3e, 0x35, 0x1c,
	0x9e, 0xf0, 0x68, 0x2b, 0xd4, 0x3a, 0xbe, 0xe6, 0x3d, 0x37,
	0x5b, 0xe3, 0x12, 0x37, 0xd9, 0x1c, 0x26, 0xe0, 0x37, 0x81,
	0x4d, 0x60, 0x5f, 0x66, 0x88, 0x8f, 0xdf, 0x3f, 0x7b, 0x0b,
	0x4a, 0x02, 0x15, 0x82, 0x0e, 0xbd, 0x49, 0xba, 0x0f, 0x3b,
	0x13, 0x44, 0x11, 0xd8, 0x72, 0x93, 0x86, 0xd7, 0x11, 0x4e,
	0x80, 0x3c, 0xe4, 0x11, 0x7a, 0xfc, 0x47, 0x44, 0x7e, 0x8f,
	0x58, 0x0c, 0xc5, 0xb5, 0xea, 0x64, 0x7c, 0xd7, 0x98, 0x2d,
	0x16, 0x3f, 0x0c, 0x19, 0x5c, 0x59, 0x10, 0x39, 0xad, 0xb7,
	0xa7, 0x17, 0x74, 0x0f, 0x44, 0x46, 0xf3, 0x77, 0xc5, 0x23,
	0xbe, 0xf0, 0xc1, 0x82, 0x39, 0x96, 0x08, 0x70, 0x3b, 0x8f,
	0xf7, 0x9e, 0xb1, 0xc9, 0xd3, 0xc9, 0x8f, 0x9c, 0xda, 0x43,
	0x7d, 0x08, 0x67, 0x43, 0xe9, 0x68, 0x16, 0xad, 0x21, 0x4a,
	0x64, 0x05, 0x71, 0xe2, 0x9c, 0x63, 0x53, 0xb8, 0x3a, 0x9e,
	0xbb, 0x48, 0x6b, 0x87, 0xa6, 0xb6, 0xb5, 0x42, 0xe6, 0x41,
	0x73, 0x7c, 0x8a, 0x9d, 0xd0, 0x31, 0xe9, 0xaf, 0xe2, 0xa2,
	0x33, 0xd0, 0xc6, 0x31, 0x5d, 0xd0, 0x0e, 0x44, 0x9b, 0x9b,
	0xad, 0x03, 0xf2, 0x35, 0xf9, 0x2d, 0x71, 0x39, 0xce, 0x34,
	0xc6, 0x2f, 0xa6, 0x24, 0xdb, 0x3a, 0x10, 0x81, 0x45, 0x66,
	0x0a, 0xe8, 0x01, 0x70, 0x9c, 0x98, 0x8e, 0x5f, 0x29, 0xe5,
	0x14, 0x1b, 0xa4, 0x2d, 0xf9, 0xd3, 0x54, 0x55, 0xd7, 0xde,
	0x51, 0x05, 0x82, 0x9f, 0x06, 0xb5, 0x07, 0x8b, 0xf1, 0xcc,
	0xf9, 0x74, 0x4a, 0x4c, 0x04, 0xbc, 0xb6, 0xd0, 0xb5, 0x99,
	0x90, 0xe5, 0xb2, 0xd6, 0x3c, 0x17, 0xdc, 0x7e, 0xcf, 0x37,
	0x66, 0xa0, 0x2c, 0xb5, 0xcc, 0xca, 0x2a, 0xac, 0x31, 0x92,
	0x72, 0x00, 0x77, 0xf9, 0xd4, 0x11, 0x48, 0x39, 0xf2, 0x12,
	0x79, 0x86, 0x00 
	};

/*----------------------------------------------------------------------------*/

const unsigned long logo_size = 2473L;	/* chunk size, bytes */

/*----------------------------------------------------------------------------*/

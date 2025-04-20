/*----------------------------------------------------------------------------
 *      U S B  -  K e r n e l
 *----------------------------------------------------------------------------
 *      Name:    USBDESC.C
 *      Purpose: USB Descriptors
 *      Version: V1.10
 *----------------------------------------------------------------------------
 *      This software is supplied "AS IS" without any warranties, express,
 *      implied or statutory, including but not limited to the implied
 *      warranties of fitness for purpose, satisfactory quality and
 *      noninfringement. Keil extends you a royalty-free right to reproduce
 *      and distribute executable files created using this software for use
 *      on Philips LPC microcontroller devices only. Nothing else gives you
 *      the right to use this software.
 *
 *      Copyright (c) 2005-2006 Keil Software.
 *---------------------------------------------------------------------------*/

#include "type.h"

#include "usb.h"
#include "hid.h"
#include "usbcfg.h"
#include "usbdesc.h"


/* HID Report Descriptor */
const BYTE HID_ReportDescriptor[] = {
  HID_UsagePageVendor(0x00),
  HID_Usage(0x01),
  HID_Collection(HID_Application),
    HID_UsagePage(HID_USAGE_PAGE_GENERIC),
    HID_UsageMin(0),
    HID_UsageMax(255),
    HID_LogicalMin(0),
    HID_LogicalMaxS(255),
    HID_ReportCount(USB_HID_REPORT_IN),
    HID_ReportSize(8),
    HID_Input(HID_Data | HID_Variable | HID_Absolute),
    HID_Usage(HID_USAGE_GENERIC_UNDEFINED),
    HID_LogicalMin(0),
    HID_LogicalMaxS(255),
  //  HID_ReportCount(8),
  //  HID_ReportSize(USB_HID_REPORT_OUT),
     HID_ReportCount(USB_HID_REPORT_OUT),
     HID_ReportSize(8),
    HID_Output(HID_Data | HID_Variable | HID_Absolute),
  HID_EndCollection,
};

const WORD HID_ReportDescSize = sizeof(HID_ReportDescriptor);


/* USB Standard Device Descriptor */
const BYTE USB_DeviceDescriptor[] = {
  USB_DEVICE_DESC_SIZE,              /* bLength */
  USB_DEVICE_DESCRIPTOR_TYPE,        /* bDescriptorType */
  WBVAL(0x0110), /* 1.10 */          /* bcdUSB */
  0x00,                              /* bDeviceClass */
  0x00,                              /* bDeviceSubClass */
  0x00,                              /* bDeviceProtocol */
  USB_MAX_PACKET0,                   /* bMaxPacketSize0 */
  WBVAL(USB_HID_VID),                /* idVendor */
  WBVAL(USB_HID_PID),                /* idProduct */
  WBVAL(0x0100), /* 1.00 */          /* bcdDevice */
  0x04,                              /* iManufacturer */
  0x2A,                              /* iProduct */
  0x4C,                              /* iSerialNumber */
  0x01                               /* bNumConfigurations */
};

/* USB Configuration Descriptor */
/*   All Descriptors (Configuration, Interface, Endpoint, Class, Vendor */
const BYTE USB_ConfigDescriptor[] = {
/* Configuration 1 */
  USB_CONFIGUARTION_DESC_SIZE,       /* bLength */
  USB_CONFIGURATION_DESCRIPTOR_TYPE, /* bDescriptorType */
  WBVAL(                             /* wTotalLength */
    USB_CONFIGUARTION_DESC_SIZE +
    USB_INTERFACE_DESC_SIZE     +
    HID_DESC_SIZE               +
    USB_ENDPOINT_DESC_SIZE      +
	USB_ENDPOINT_DESC_SIZE
  ),
  0x01,                              /* bNumInterfaces */
  0x01,                              /* bConfigurationValue */
  0x00,                              /* iConfiguration */
  USB_CONFIG_BUS_POWERED /*|*/       /* bmAttributes */
/*USB_CONFIG_REMOTE_WAKEUP*/,
  USB_CONFIG_POWER_MA(100),          /* bMaxPower */
/* Interface 0, Alternate Setting 0, HID Class */
  USB_INTERFACE_DESC_SIZE,           /* bLength */
  USB_INTERFACE_DESCRIPTOR_TYPE,     /* bDescriptorType */
  0x00,                              /* bInterfaceNumber */
  0x00,                              /* bAlternateSetting */
  0x01,                              /* bNumEndpoints */
  USB_DEVICE_CLASS_HUMAN_INTERFACE,  /* bInterfaceClass */
  HID_SUBCLASS_NONE,                 /* bInterfaceSubClass */
  HID_PROTOCOL_NONE,                 /* bInterfaceProtocol */
  0x56,                              /* iInterface */
/* HID Class Descriptor */
/* HID_DESC_OFFSET = 0x0012 */
  HID_DESC_SIZE,                     /* bLength */
  HID_HID_DESCRIPTOR_TYPE,           /* bDescriptorType */
  WBVAL(0x0100), /* 1.00 */          /* bcdHID */
  0x00,                              /* bCountryCode */
  0x01,                              /* bNumDescriptors */
  HID_REPORT_DESCRIPTOR_TYPE,        /* bDescriptorType */
  WBVAL(HID_REPORT_DESC_SIZE),       /* wDescriptorLength */
/* Endpoint, HID Interrupt In */
  USB_ENDPOINT_DESC_SIZE,            /* bLength */
  USB_ENDPOINT_DESCRIPTOR_TYPE,      /* bDescriptorType */
  USB_ENDPOINT_IN(1),				 /* bEndpointAddress */
  USB_ENDPOINT_TYPE_INTERRUPT,       /* bmAttributes */
  WBVAL(USB_HID_REPORT_IN),          /* wMaxPacketSize */
  USB_HID_IN_INTERVAL,        		 /* bInterval - polling interval*/
/* Endpoint, HID Interrupt Out */
  USB_ENDPOINT_DESC_SIZE,			/* bLength 	*/
  USB_ENDPOINT_DESCRIPTOR_TYPE,		/* bDescriptorType */
  USB_ENDPOINT_OUT(1),				/* bEndpointAddress	*/
  USB_ENDPOINT_TYPE_INTERRUPT,		/* bmAttributes	*/
  WBVAL(USB_HID_REPORT_OUT),		/* wMaxPacketSize	*/
  USB_HID_OUT_INTERVAL,     		/* bInterval - polling interval*/
/* Terminator */
  0                                  /* bLength */
};

/* USB String Descriptor (optional) */
const BYTE USB_StringDescriptor[] = {
/* Index 0x00: LANGID Codes */
  0x04,                              /* bLength */
  USB_STRING_DESCRIPTOR_TYPE,        /* bDescriptorType */
  WBVAL(0x0409), /* US English */    /* wLANGID */
/* Index 0x04: Manufacturer */
  0x26,                              /* bLength */
  USB_STRING_DESCRIPTOR_TYPE,        /* bDescriptorType */
  'k',0,
  'o',0,
  'e',0,
  ' ',0,
  '2',0,
  '0',0,
  '1',0,
  '0',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
/* Index 0x2A: Product */
  0x22,                              /* bLength */
  USB_STRING_DESCRIPTOR_TYPE,        /* bDescriptorType */
  'h',0,
  'r',0,
  'e',0,
  'n',0,
  'o',0,
  'm',0,
  'e',0,
  'r',0,
  '!',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
  ' ',0,
/* Index 0x4C: Serial Number */
  0x0A,                              /* bLength */
  USB_STRING_DESCRIPTOR_TYPE,        /* bDescriptorType */
  't',0,
  'i',0,
  'm',0,
  'e',0,
/* Index 0x56: Interface 0, Alternate Setting 0 */
  0x08,                              /* bLength */
  USB_STRING_DESCRIPTOR_TYPE,        /* bDescriptorType */
  'H',0,
  'I',0,
  'D',0,
};

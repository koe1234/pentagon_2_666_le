/*----------------------------------------------------------------------------
 *      U S B  -  K e r n e l
 *----------------------------------------------------------------------------
 *      Name:    HIDUSER.C
 *      Purpose: HID Custom User Module
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
 *---------------------------------------------------------------------------
 *		 Change history (05/30/08)
 *		 Replaced GetInReport() with (*inptr)()
 *		 Replaced SetOutReport() with (*outptr)()
 *----------------------------------------------------------------------------*/

#include "type.h"

#include "usb.h"
#include "hid.h"
#include "usbcfg.h"
#include "usbcore.h"
#include "hiduser.h"




BYTE HID_Protocol;
BYTE HID_IdleTime[HID_REPORT_NUM];

BYTE InReport[USB_HID_REPORT_IN];
BYTE OutReport[USB_HID_REPORT_OUT];


/*
 *  HID Get Report Request Callback
 *   Called automatically on HID Get Report Request
 *    Parameters:      None (global SetupPacket and EP0Buf)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL HID_GetReport (void) {

  /* ReportID = SetupPacket.wValue.WB.L; */
  switch (SetupPacket.wValue.WB.H) {
    case HID_REPORT_INPUT:
 //     (*inptr)();
GetInReport();
      EP0Buf[0] = InReport[0];
      break;
    case HID_REPORT_OUTPUT:
      return (FALSE);          /* Not Supported */
    case HID_REPORT_FEATURE:
      /* EP0Buf[] = ...; */
      /* break; */
      return (FALSE);          /* Not Supported */
  }
  return (TRUE);
}


/*
 *  HID Set Report Request Callback
 *   Called automatically on HID Set Report Request
 *    Parameters:      None (global SetupPacket and EP0Buf)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL HID_SetReport (void) {
unsigned int k;

  /* ReportID = SetupPacket.wValue.WB.L; */
  switch (SetupPacket.wValue.WB.H) {
    case HID_REPORT_INPUT:
      return (FALSE);          /* Not Supported */
    case HID_REPORT_OUTPUT:
      OutReport[0] = EP0Buf[0];
	  for(k=1; k<=USB_HID_REPORT_OUT; k++) OutReport[k] = EP0Buf[k];

//      (*outptr)();
  SetOutReport();
      break;
    case HID_REPORT_FEATURE:
      return (FALSE);          /* Not Supported */
  }
  return (TRUE);
}


/*
 *  HID Get Idle Request Callback
 *   Called automatically on HID Get Idle Request
 *    Parameters:      None (global SetupPacket and EP0Buf)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL HID_GetIdle (void) {

  EP0Buf[0] = HID_IdleTime[SetupPacket.wValue.WB.L];
  return (TRUE);
}


/*
 *  HID Set Idle Request Callback
 *   Called automatically on HID Set Idle Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL HID_SetIdle (void) {

  HID_IdleTime[SetupPacket.wValue.WB.L] = SetupPacket.wValue.WB.H;

  /* Idle Handling if needed */
  /* ... */

  return (TRUE);
}


/*
 *  HID Get Protocol Request Callback
 *   Called automatically on HID Get Protocol Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL HID_GetProtocol (void) {

  EP0Buf[0] = HID_Protocol;
  return (TRUE);
}


/*
 *  HID Set Protocol Request Callback
 *   Called automatically on HID Set Protocol Request
 *    Parameters:      None (global SetupPacket)
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL HID_SetProtocol (void) {

  HID_Protocol = SetupPacket.wValue.WB.L;

  /* Protocol Handling if needed */
  /* ... */

  return (TRUE);
}

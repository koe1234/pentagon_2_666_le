/*----------------------------------------------------------------------------
 *      U S B  -  K e r n e l
 *----------------------------------------------------------------------------
 *      Name:    HIDUSER.H
 *      Purpose: HID Custom User Definitions
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
 *		Change history (05/30/08)
 *		Replaced GetInReport() and SetOutReport() with PFV inptr and outptr
 *
 *****************************************************************************/

#ifndef __HIDUSER_H__
#define __HIDUSER_H__


/* HID Number of Reports */
#define HID_REPORT_NUM      1

/* HID Data buffers */
extern BYTE InReport[USB_HID_REPORT_IN];
extern BYTE OutReport[USB_HID_REPORT_OUT];

/* HID Demo Functions */
extern void GetInReport  (void);
extern void SetOutReport (void);
//extern PFV inptr;
//extern PFV outptr;


/* HID Global Variables */
extern BYTE HID_Protocol;
extern BYTE HID_IdleTime[HID_REPORT_NUM];

/* HID Requests Callback Functions */
extern BOOL HID_GetReport   (void);
extern BOOL HID_SetReport   (void);
extern BOOL HID_GetIdle     (void);
extern BOOL HID_SetIdle     (void);
extern BOOL HID_GetProtocol (void);
extern BOOL HID_SetProtocol (void);


#endif  /* __HIDUSER_H__ */

/*----------------------------------------------------------------------------
 *      U S B  -  K e r n e l
 *----------------------------------------------------------------------------
 *      Name:    USBHW.C
 *      Purpose: USB Hardware Layer Module for Philips LPC214x/LPC318x/23xx/24xx
 *      Version: V1.10
 *----------------------------------------------------------------------------
 *      This file is part of the uVision/ARM development tools.
 *      This software may only be used under the terms of a valid, current,
 *      end user licence from KEIL for a compatible version of KEIL software
 *      development tools. Nothing else gives you the right to use it.
 *
 *      Copyright (c) 2005-2006 Keil Software.
 *---------------------------------------------------------------------------*/

#include <LPC23xx.H>                        /* LPC23xx definitions */

#include "type.h"

#include "usb.h"
#include "usbcfg.h"
#include "usbreg.h"
#include "usbhw.h"
#include "usbcore.h"
#include "usbuser.h"


#pragma diag_suppress 1441


#define EP_MSK_CTRL 0x0001      /* Control Endpoint Logical Address Mask */
#define EP_MSK_BULK 0xC924      /* Bulk Endpoint Logical Address Mask */
#define EP_MSK_INT  0x4492      /* Interrupt Endpoint Logical Address Mask */
#define EP_MSK_ISO  0x1248      /* Isochronous Endpoint Logical Address Mask */


#if USB_DMA

#pragma arm section zidata = "USB_RAM"
DWORD UDCA[USB_EP_NUM];                     /* UDCA in USB RAM */
DWORD DD_NISO_Mem[4*DD_NISO_CNT];           /* Non-Iso DMA Descriptor Memory */
DWORD DD_ISO_Mem [5*DD_ISO_CNT];            /* Iso DMA Descriptor Memory */
#pragma arm section zidata
DWORD udca[USB_EP_NUM];                     /* UDCA saved values */

DWORD DDMemMap[2];                          /* DMA Descriptor Memory Usage */

#endif


/*
 *  Get Endpoint Physical Address
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    Endpoint Physical Address
 */

DWORD EPAdr (DWORD EPNum) {
  DWORD val;

  val = (EPNum & 0x0F) << 1;
  if (EPNum & 0x80) {
    val += 1;
  }
  return (val);
}


/*
 *  Write Command
 *    Parameters:      cmd:   Command
 *    Return Value:    None
 */

void WrCmd (DWORD cmd) {

  DEV_INT_CLR = CCEMTY_INT;
  CMD_CODE = cmd;
  while ((DEV_INT_STAT & CCEMTY_INT) == 0);
}


/*
 *  Write Command Data
 *    Parameters:      cmd:   Command
 *                     val:   Data
 *    Return Value:    None
 */

void WrCmdDat (DWORD cmd, DWORD val) {

  DEV_INT_CLR = CCEMTY_INT;
  CMD_CODE = cmd;
  while ((DEV_INT_STAT & CCEMTY_INT) == 0);
  DEV_INT_CLR = CCEMTY_INT;
  CMD_CODE = val;
  while ((DEV_INT_STAT & CCEMTY_INT) == 0);
}


/*
 *  Read Command Data
 *    Parameters:      cmd:   Command
 *    Return Value:    Data Value
 */

DWORD RdCmdDat (DWORD cmd) {

  DEV_INT_CLR = CCEMTY_INT | CDFULL_INT;
  CMD_CODE = cmd;
  while ((DEV_INT_STAT & CDFULL_INT) == 0);
  return (CMD_DATA);
}


/*
 *  USB Initialize Function
 *   Called by the User to initialize USB
 *    Return Value:    None
 */

void USB_Init (void) {

  PINSEL1 &= ~0x3C000000;                 /* P0.29 USB1_D+, P0.30 USB1_D- */ 
  PINSEL1 |=  0x14000000;                 /* PINSEL1 26.27, 28.29         */

  PINSEL3 &= ~0x30000030;                 /* P1.18 GoodLink, P1.30 VBus   */
  PINSEL3 |=  0x20000010;                 /* PINSEL3 4.5, 28.29           */

  /* The SoftConnect pin for LPC2300 on USB_U1 doesn't work for now, 
     make it GPIO and make it low to turn on pull-up on D+. 
	 Once it's fixed, make #if 1 and set it as SoftConn Pin. */
#if 0
  PINSEL4 &= ~0x000C0000;                 /* P2.9 USB1 SoftConnect        */
  PINSEL4 |= 0x000040000;                 /* PINSEl4 18.19                */
#else
  PINSEL4 &= ~0x000C0000;
  FIO2DIR |= (1 << 9);
  FIO2CLR  = (1 << 9);
#endif
	
  PCONP |= 0x80000000;                    /* USB PCLK -> enable USB Per.  */

USBClkCtrl = 0x12;	                  /* Dev clock, AHB clock enable  */
  while ((USBClkSt & 0x12) != 0x12);
  
  VICVectAddr22 = (unsigned long)USB_ISR; /* USB Interrupt -> Vector 22   */
  VICVectCntl22 = 0x02;                   /* USB Interrupt -> Priority  2   */
  VICIntEnable = 1 << 22;                 /* Enable USB Interrupt         */

//  DEV_INT_EN = DEV_STAT_INT;              /* Enable Device Status Interrupt */

#if 1 /* Partial Manual Reset since Automatic Bus Reset is not working */
  USB_Reset();
  USB_SetAddress(0);
#endif
}


/*
 *  USB Connect Function
 *   Called by the User to Connect/Disconnect USB
 *    Parameters:      con:   Connect/Disconnect
 *    Return Value:    None
 */

void USB_Connect (BOOL con) {
  WrCmdDat(CMD_SET_DEV_STAT, DAT_WR_BYTE(con ? DEV_CON : 0));
}


/*
 *  USB Reset Function
 *   Called automatically on USB Reset
 *    Return Value:    None
 */

void USB_Reset (void) {
#if USB_DMA
  DWORD n;
#endif

  EP_INDEX = 0;
  MAXPACKET_SIZE = USB_MAX_PACKET0;
  EP_INDEX = 1;
  MAXPACKET_SIZE = USB_MAX_PACKET0;
  while ((DEV_INT_STAT & EP_RLZED_INT) == 0);

  EP_INT_CLR  = 0xFFFFFFFF;
  EP_INT_EN   = 0xFFFFFFFF ^ USB_DMA_EP;
  DEV_INT_CLR = 0xFFFFFFFF;
  DEV_INT_EN  = DEV_STAT_INT    | EP_SLOW_INT    |
               (USB_SOF_EVENT   ? FRAME_INT : 0) |
               (USB_ERROR_EVENT ? ERR_INT   : 0);

#if USB_DMA
  UDCA_HEAD   = USB_RAM_ADR;
  DMA_REQ_CLR = 0xFFFFFFFF;
  EP_DMA_DIS  = 0xFFFFFFFF;
  EP_DMA_EN   = USB_DMA_EP;
  EOT_INT_CLR = 0xFFFFFFFF;
  NDD_REQ_INT_CLR = 0xFFFFFFFF;
  SYS_ERR_INT_CLR = 0xFFFFFFFF;
  DMA_INT_EN  = 0x00000007;
  DDMemMap[0] = 0x00000000;
  DDMemMap[1] = 0x00000000;
  for (n = 0; n < USB_EP_NUM; n++) {
    udca[n] = 0;
    UDCA[n] = 0;
  }
#endif
}


/*
 *  USB Suspend Function
 *   Called automatically on USB Suspend
 *    Return Value:    None
 */

void USB_Suspend (void) {
  /* Performed by Hardware */
}


/*
 *  USB Resume Function
 *   Called automatically on USB Resume
 *    Return Value:    None
 */

void USB_Resume (void) {
  /* Performed by Hardware */
}


/*
 *  USB Remote Wakeup Function
 *   Called automatically on USB Remote Wakeup
 *    Return Value:    None
 */

void USB_WakeUp (void) {

  if (USB_DeviceStatus & USB_GETSTATUS_REMOTE_WAKEUP) {
    WrCmdDat(CMD_SET_DEV_STAT, DAT_WR_BYTE(DEV_CON));
  }
}


/*
 *  USB Remote Wakeup Configuration Function
 *    Parameters:      cfg:   Enable/Disable
 *    Return Value:    None
 */

void USB_WakeUpCfg (BOOL cfg) {
  /* Not needed */
}


/*
 *  USB Set Address Function
 *    Parameters:      adr:   USB Address
 *    Return Value:    None
 */

void USB_SetAddress (DWORD adr) {
  WrCmdDat(CMD_SET_ADDR, DAT_WR_BYTE(DEV_EN | adr)); /* Don't wait for next */
  WrCmdDat(CMD_SET_ADDR, DAT_WR_BYTE(DEV_EN | adr)); /*  Setup Status Phase */
}


/*
 *  USB Configure Function
 *    Parameters:      cfg:   Configure/Deconfigure
 *    Return Value:    None
 */

void USB_Configure (BOOL cfg) {

  WrCmdDat(CMD_CFG_DEV, DAT_WR_BYTE(cfg ? CONF_DVICE : 0));

  REALIZE_EP = 0x00000003;
  while ((DEV_INT_STAT & EP_RLZED_INT) == 0);
  DEV_INT_CLR = EP_RLZED_INT;
}


/*
 *  Configure USB Endpoint according to Descriptor
 *    Parameters:      pEPD:  Pointer to Endpoint Descriptor
 *    Return Value:    None
 */

void USB_ConfigEP (USB_ENDPOINT_DESCRIPTOR *pEPD) {
  DWORD num;

  num = EPAdr(pEPD->bEndpointAddress);
  REALIZE_EP |= (1 << num);
  EP_INDEX = num;
  MAXPACKET_SIZE = pEPD->wMaxPacketSize;
  while ((DEV_INT_STAT & EP_RLZED_INT) == 0);
  DEV_INT_CLR = EP_RLZED_INT;
}


/*
 *  Set Direction for USB Control Endpoint
 *    Parameters:      dir:   Out (dir == 0), In (dir <> 0)
 *    Return Value:    None
 */

void USB_DirCtrlEP (DWORD dir) {
  /* Not needed */
}


/*
 *  Enable USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_EnableEP (DWORD EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(0));
}


/*
 *  Disable USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_DisableEP (DWORD EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(EP_STAT_DA));
}


/*
 *  Reset USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_ResetEP (DWORD EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(0));
}


/*
 *  Set Stall for USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_SetStallEP (DWORD EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(EP_STAT_ST));
}


/*
 *  Clear Stall for USB Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_ClrStallEP (DWORD EPNum) {
  WrCmdDat(CMD_SET_EP_STAT(EPAdr(EPNum)), DAT_WR_BYTE(0));
}


/*
 *  Read USB Endpoint Data
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *                     pData: Pointer to Data Buffer
 *    Return Value:    Number of bytes read
 */

DWORD USB_ReadEP (DWORD EPNum, BYTE *pData, DWORD cnt) {
  DWORD n;

  USB_CTRL = ((EPNum & 0x0F) << 2) | CTRL_RD_EN;

 // do {
//    cnt = RX_PLENGTH;
 // } while ((cnt & PKT_RDY) == 0);
 
  cnt &= PKT_LNGTH_MASK;

  for (n = 0; n < (cnt + 3) / 4; n++) {
    *((__packed DWORD *)pData) = RX_DATA;
    pData += 4;
  }

  USB_CTRL = 0;

  if (((EP_MSK_ISO >> EPNum) & 1) == 0) {   /* Non-Isochronous Endpoint */
    WrCmd(CMD_SEL_EP(EPAdr(EPNum)));
    WrCmd(CMD_CLR_BUF);
  }

  return (cnt);
}


/*
 *  Write USB Endpoint Data
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *                     pData: Pointer to Data Buffer
 *                     cnt:   Number of bytes to write
 *    Return Value:    Number of bytes written
 */

DWORD USB_WriteEP (DWORD EPNum, BYTE *pData, DWORD cnt) {
  DWORD n;

  USB_CTRL = ((EPNum & 0x0F) << 2) | CTRL_WR_EN;

  TX_PLENGTH = cnt;

  for (n = 0; n < (cnt + 3) / 4; n++) {
    TX_DATA = *((__packed DWORD *)pData);
    pData += 4;
  }

  USB_CTRL = 0;

  WrCmd(CMD_SEL_EP(EPAdr(EPNum)));
  WrCmd(CMD_VALID_BUF);

  return (cnt);
}


#if USB_DMA


/* DMA Descriptor Memory Layout */
const DWORD DDAdr[2] = { DD_NISO_ADR, DD_ISO_ADR };
const DWORD DDSz [2] = { 16,          20         };


/*
 *  Setup USB DMA Transfer for selected Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                     pDD: Pointer to DMA Descriptor
 *    Return Value:    TRUE - Success, FALSE - Error
 */

BOOL USB_DMA_Setup(DWORD EPNum, USB_DMA_DESCRIPTOR *pDD) {
  DWORD num, ptr, nxt, iso, n;

  iso = pDD->Cfg.Type.IsoEP;                /* Iso or Non-Iso Descriptor */
  num = EPAdr(EPNum);                       /* Endpoint's Physical Address */

  ptr = 0;                                  /* Current Descriptor */
  nxt = udca[num];                          /* Initial Descriptor */
  while (nxt) {                             /* Go through Descriptor List */
    ptr = nxt;                              /* Current Descriptor */
    if (!pDD->Cfg.Type.Link) {              /* Check for Linked Descriptors */
      n = (ptr - DDAdr[iso]) / DDSz[iso];   /* Descriptor Index */
      DDMemMap[iso] &= ~(1 << n);           /* Unmark Memory Usage */
    }
    nxt = *((DWORD *)ptr);                  /* Next Descriptor */
  }

  for (n = 0; n < 32; n++) {                /* Search for available Memory */
    if ((DDMemMap[iso] & (1 << n)) == 0) {
      break;                                /* Memory found */
    }
  }
  if (n == 32) return (FALSE);              /* Memory not available */

  DDMemMap[iso] |= 1 << n;                  /* Mark Memory Usage */
  nxt = DDAdr[iso] + n * DDSz[iso];         /* Next Descriptor */

  if (ptr && pDD->Cfg.Type.Link) {
    *((DWORD *)(ptr + 0))  = nxt;           /* Link in new Descriptor */
    *((DWORD *)(ptr + 4)) |= 0x00000004;    /* Next DD is Valid */
  } else {
    udca[num] = nxt;                        /* Save new Descriptor */
    UDCA[num] = nxt;                        /* Update UDCA in USB */
  }

  /* Fill in DMA Descriptor */
  *(((DWORD *)nxt)++) =  0;                 /* Next DD Pointer */
  *(((DWORD *)nxt)++) =  pDD->Cfg.Type.ATLE |
                       (pDD->Cfg.Type.IsoEP << 4) |
                       (pDD->MaxSize <<  5) |
                       (pDD->BufLen  << 16);
  *(((DWORD *)nxt)++) =  pDD->BufAdr;
  *(((DWORD *)nxt)++) =  pDD->Cfg.Type.LenPos << 8;
  if (iso) {
    *((DWORD *)nxt) =  pDD->InfoAdr;
  }

  return (TRUE); /* Success */
}


/*
 *  Enable USB DMA Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_DMA_Enable (DWORD EPNum) {
  EP_DMA_EN = 1 << EPAdr(EPNum);
}


/*
 *  Disable USB DMA Endpoint
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    None
 */

void USB_DMA_Disable (DWORD EPNum) {
  EP_DMA_DIS = 1 << EPAdr(EPNum);
}


/*
 *  Get USB DMA Endpoint Status
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    DMA Status
 */

DWORD USB_DMA_Status (DWORD EPNum) {
  DWORD ptr, val;

  ptr = UDCA[EPAdr(EPNum)];                 /* Current Descriptor */
  if (ptr == 0) return (USB_DMA_INVALID);

  val = *((DWORD *)(ptr + 3*4));            /* Status Information */
  switch ((val >> 1) & 0x0F) {
    case 0x00:                              /* Not serviced */
      return (USB_DMA_IDLE);
    case 0x01:                              /* Being serviced */
      return (USB_DMA_BUSY);
    case 0x02:                              /* Normal Completition */
      return (USB_DMA_DONE);
    case 0x03:                              /* Data Under Run */
      return (USB_DMA_UNDER_RUN);
    case 0x08:                              /* Data Over Run */
      return (USB_DMA_OVER_RUN);
    case 0x09:                              /* System Error */
      return (USB_DMA_ERROR);
  }

  return (USB_DMA_UNKNOWN);
}


/*
 *  Get USB DMA Endpoint Current Buffer Address
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    DMA Address (or -1 when DMA is Invalid)
 */

DWORD USB_DMA_BufAdr (DWORD EPNum) {
  DWORD ptr, val;

  ptr = UDCA[EPAdr(EPNum)];                 /* Current Descriptor */
  if (ptr == 0) return ((DWORD)(-1));                /* DMA Invalid */

  val = *((DWORD *)(ptr + 2*4));            /* Buffer Address */

  return (val);                             /* Current Address */
}


/*
 *  Get USB DMA Endpoint Current Buffer Count
 *   Number of transfered Bytes or Iso Packets
 *    Parameters:      EPNum: Endpoint Number
 *                       EPNum.0..3: Address
 *                       EPNum.7:    Dir
 *    Return Value:    DMA Count (or -1 when DMA is Invalid)
 */

DWORD USB_DMA_BufCnt (DWORD EPNum) {
  DWORD ptr, val;

  ptr = UDCA[EPAdr(EPNum)];                 /* Current Descriptor */
  if (ptr == 0) return ((DWORD)(-1));       /* DMA Invalid */

  val = *((DWORD *)(ptr + 3*4));            /* Status Information */

  return (val >> 16);                       /* Current Count */
}


#endif /* USB_DMA */


/*
 *  Get USB Last Frame Number
 *    Parameters:      None
 *    Return Value:    Frame Number
 */

DWORD USB_GetFrame (void) {
  DWORD val;

  WrCmd(CMD_RD_FRAME);
  val = RdCmdDat(DAT_RD_FRAME);
  val = val | (RdCmdDat(DAT_RD_FRAME) << 8);

  return (val);
}


/*
 *  USB Interrupt Service Routine
 */

void USB_ISR (void) __irq {
  DWORD disr, val, n, m;

  disr = DEV_INT_STAT;                      /* Device Interrupt Status */
  DEV_INT_CLR = disr;                       /* A known issue on LPC214x */

  /* Device Status Interrupt (Reset, Connect change, Suspend/Resume) */
  if (disr & DEV_STAT_INT) {
    WrCmd(CMD_GET_DEV_STAT);
    val = RdCmdDat(DAT_GET_DEV_STAT);       /* Device Status */
    if (val & DEV_RST) {                    /* Reset */
      USB_Reset();
#if   USB_RESET_EVENT
      USB_Reset_Event();
#endif
      goto isr_end;
    }
    if (val & DEV_CON_CH) {                 /* Connect change */
#if   USB_POWER_EVENT
      USB_Power_Event(val & DEV_CON);
#endif
      goto isr_end;
    }
    if (val & DEV_SUS_CH) {                 /* Suspend/Resume */
      if (val & DEV_SUS) {                  /* Suspend */
        USB_Suspend();
#if     USB_SUSPEND_EVENT
        USB_Suspend_Event();
#endif
      } else {                              /* Resume */
        USB_Resume();
#if     USB_RESUME_EVENT
        USB_Resume_Event();
#endif
      }
      goto isr_end;
    }
  }

#if USB_SOF_EVENT
  /* Start of Frame Interrupt */
  if (disr & FRAME_INT) {
    USB_SOF_Event();
  }
#endif

#if USB_ERROR_EVENT
  /* Error Interrupt */
  if (disr & ERR_INT) {
    WrCmd(CMD_RD_ERR_STAT);
    val = RdCmdDat(DAT_RD_ERR_STAT);
    USB_Error_Event(val);
  }
#endif

  /* Endpoint's Slow Interrupt */
  if (disr & EP_SLOW_INT) {

    while (EP_INT_STAT) {                   /* Endpoint Interrupt Status */

      for (n = 0; n < USB_EP_NUM; n++) {    /* Check All Endpoints */
        if (EP_INT_STAT & (1 << n)) {
          m = n >> 1;

          EP_INT_CLR = 1 << n;
          while ((DEV_INT_STAT & CDFULL_INT) == 0);
          val = CMD_DATA;

          if ((n & 1) == 0) {               /* OUT Endpoint */
            if (n == 0) {                   /* Control OUT Endpoint */
              if (val & EP_SEL_STP) {       /* Setup Packet */
                if (USB_P_EP[0]) {
                  USB_P_EP[0](USB_EVT_SETUP);
                  continue;
                }
              }
            }
            if (USB_P_EP[m]) {
              USB_P_EP[m](USB_EVT_OUT);
            }
          } else {                          /* IN Endpoint */
            if (USB_P_EP[m]) {
              USB_P_EP[m](USB_EVT_IN);
            }
          }
        }
      }
    }
  }

#if USB_DMA

  if (DMA_INT_STAT & 0x00000001) {          /* End of Transfer Interrupt */
    val = EOT_INT_STAT;
    for (n = 2; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (val & (1 << n)) {
        m = n >> 1;
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_OUT_DMA_EOT);
          }
        } else {                            /* IN Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_IN_DMA_EOT);
          }
        }
      }
    }
    EOT_INT_CLR = val;
  }

  if (DMA_INT_STAT & 0x00000002) {          /* New DD Request Interrupt */
    val = NDD_REQ_INT_STAT;
    for (n = 2; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (val & (1 << n)) {
        m = n >> 1;
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_OUT_DMA_NDR);
          }
        } else {                            /* IN Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_IN_DMA_NDR);
          }
        }
      }
    }
    NDD_REQ_INT_CLR = val;
  }

  if (DMA_INT_STAT & 0x00000004) {          /* System Error Interrupt */
    val = SYS_ERR_INT_STAT;
    for (n = 2; n < USB_EP_NUM; n++) {      /* Check All Endpoints */
      if (val & (1 << n)) {
        m = n >> 1;
        if ((n & 1) == 0) {                 /* OUT Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_OUT_DMA_ERR);
          }
        } else {                            /* IN Endpoint */
          if (USB_P_EP[m]) {
            USB_P_EP[m](USB_EVT_IN_DMA_ERR);
          }
        }
      }
    }
    SYS_ERR_INT_CLR = val;
  }

#endif /* USB_DMA */

isr_end:
//  DEV_INT_CLR = disr;
  VICVectAddr = 0;                          /* Acknowledge Interrupt */
}

/**************************************************************************//**
 * @file     lpc23xx_spi.h
 * @brief    Header file for lpc23xx_spi.c.
 * @version  1.0koe
 *
 * General SPI/SSP drivers: NXP
 * SSP FIFO: Martin Thomas 
 *
 ******************************************************************************/

#ifndef __LPC23xx_SPI_H
#define __LPC23xx_SPI_H

#include <stdint.h>
#include "LPC23xx.H"                 /* LPC23xx Definitions */

/* undefine the macro to make Tx/Rx on polling mode */
#define USE_FIFO

/* SPI clock rate setting. 
SSP0_CLK = SystemCoreClock / divider,
The divider must be a even value between 2 and 254!
In SPI mode, max clock speed is 20MHz for MMC and 25MHz for SD */
#define SPI_CLOCKRATE_LOW   (uint32_t) (180)   /* 72MHz / 180 = 400kHz */
#define SPI_CLOCKRATE_HIGH  (uint32_t) (4)     /* 72MHz / 4 = 18MHz */

/* Public functions */
void    SPI_Init (void);
void    SPI_ConfigClockRate (uint32_t SPI_CLOCKRATE);
void    SPI_CS_Low (void);
void    SPI_CS_High (void);
uint8_t SPI_SendByte (uint8_t data);
uint8_t SPI_RecvByte (void);
#ifdef USE_FIFO
void    SPI_SendBlock_FIFO (const uint8_t *buf, uint32_t len);
void    SPI_RecvBlock_FIFO (uint8_t *buf, uint32_t len);
#endif
#endif  // __LPC23xx_SPI_H

/* --------------------------------- End Of File ------------------------------ */


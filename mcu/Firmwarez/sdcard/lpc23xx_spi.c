/**************************************************************************//**
 * @file     lpc23xx_spi.c
 * @brief    Drivers for SSP peripheral in lpc23xx.
 * @version  1.0koe
 *
 * General SPI/SSP drivers: NXP
 * SSP FIFO: Martin Thomas 
 *
 ******************************************************************************/

#include "lpc23xx_spi.h"

/* Macro defines for SSP SR register */
#define SSP_SR_TFE      ((uint32_t)(1<<0)) /** SSP status TX FIFO Empty bit */
#define SSP_SR_TNF      ((uint32_t)(1<<1)) /** SSP status TX FIFO not full bit */
#define SSP_SR_RNE      ((uint32_t)(1<<2)) /** SSP status RX FIFO not empty bit */
#define SSP_SR_RFF      ((uint32_t)(1<<3)) /** SSP status RX FIFO full bit */
#define SSP_SR_BSY      ((uint32_t)(1<<4)) /** SSP status SSP Busy bit */
#define SSP_SR_BITMASK	((uint32_t)(0x1F)) /** SSP SR bit mask */


/**
  * @brief  Initializes the SSP0.
  *
  * @param  None
  * @retval None 
  */
void SPI_Init (void) 
{
    PCONP |= (1 << 21);
    
    PINSEL0 &= ~(1 << 11);
		PINSEL0 &= ~(1 << 10); // GPIO P0.5 for SPI_CS
		PINSEL0 |= (1 << 13);
		PINSEL0 &= ~(1 << 12); // P0.6 -> SSEL1
	
		FIO0DIR |= (1<<5);
		FIO0MASK &= ~(1<<5);
	
    PINSEL0 |= (1 << 15);
		PINSEL0 &= ~(1 << 14); // P0.7 -> SCK1
		PINSEL0 |= (1 << 17);
		PINSEL0 &= ~(1 << 16); // P0.8 -> MISO1
		PINSEL0 |= (1 << 19);
		PINSEL0 &= ~(1 << 18); // P0.9 -> MOSI1
		
    PCLKSEL0 &= ~(3 << 20);
    PCLKSEL0 |=  (1 << 20);  /* SSP1_PCLK=CCLK */
		
		SSP1CR0 = (0x07 << 0) |     /* data width: 8bit*/
                    (0x00 << 4) |     /* frame format: SPI */
                    (0x00 << 6) |     /* CPOL: low level */
                    (0x00 << 7) |     /* CPHA: first edge */
                    (0x00 << 8);      /* SCR = 0 */

					SSP1CR1 = (0x00 << 0) |   /* Normal mode */
                    (0x01 << 1) |   /* Enable SSP0 */
                    (0x00 << 2) |   /* Master */
										(0x00 << 3);    /* slave output disabled */

		/* Configure SSP1 clock rate to 400kHz (72MHz/180) */
		SPI_ConfigClockRate (SPI_CLOCKRATE_LOW);

    /* Set SSEL to high */
    SPI_CS_High ();
}

/**
  * @brief  Configure SSP0 clock rate.
  * @brief  Configure SSP1 clock rate.
  * @param  SPI_CLOCKRATE: Specifies the SPI clock rate.
  *         The value should be SPI_CLOCKRATE_LOW or SPI_CLOCKRATE_HIGH.
  * @retval None 
  *
  * SSP0_CLK = CCLK / SPI_CLOCKRATE
	* SSP1_CLK = CCLK / SPI_CLOCKRATE
  */
void SPI_ConfigClockRate (uint32_t SPI_CLOCKRATE)
{
    /* CPSR must be an even value between 2 and 254 */
  	SSP1CPSR = (SPI_CLOCKRATE & 0x1FE);	
}

/**
  * @brief  Set SSEL to low: select spi slave.
  *
  * @param  None.
  * @retval None 
  */
void SPI_CS_Low (void)
{
    /* SSEL is GPIO, set to low.  */  
		FIO0CLR |= (1 << 5);    
}

/**
  * @brief  Set SSEL to high: de-select spi slave.
  *
  * @param  None.
  * @retval None 
  */
void SPI_CS_High (void)
{
    /* SSEL is GPIO, set to high.  */
		FIO0SET |= (1 << 5); 	
}

/**
  * @brief  Send one byte via MOSI and simutaniously receive one byte via MISO.
  *
  * @param  data: Specifies the byte to be sent out.
  * @retval Returned byte.
  *
  * Note: Each time send out one byte at MOSI, Rx FIFO will receive one byte. 
  */
uint8_t SPI_SendByte (uint8_t data)
{
    /* Put the data on the FIFO */
		SSP1DR = data;
    /* Wait for sending to complete */
		while (SSP1SR & SSP_SR_BSY);	
    /* Return the received value */              
		return (SSP1DR);
}

/**
  * @brief  Receive one byte via MISO.
  *
  * @param  None.
  * @retval Returned received byte.
  */
uint8_t SPI_RecvByte (void)
{
    /* Send 0xFF to provide clock for MISO to receive one byte */
    return SPI_SendByte (0xFF);
}

/* SPI FIFO functions are from Martin Thomas */
#ifdef USE_FIFO

/* 8 frame FIFOs for both transmit and receive */
#define SSP_FIFO_DEPTH       8 

/**
  * @brief  Send data block using FIFO.
  *
  * @param  buf: Pointer to the byte array to be sent
  * @param  len: length (in byte) of the byte array.
  *              Should be multiple of 4.   
  * @retval None.
  */
void SPI_SendBlock_FIFO (const uint8_t *buf, uint32_t len)
{
	uint32_t cnt;
	uint16_t data;

	SSP1CR0 |= 0x0f;  /* DSS to 16 bit */

	/* fill the FIFO unless it is full */
	for ( cnt = 0; cnt < ( len / 2 ); cnt++ ) 
	{
		/* wait for TX FIFO not full (TNF) */
		while ( !( SSP1SR & SSP_SR_TNF) );
		data  = (*buf++) << 8;
		data |= *buf++;
		SSP1DR = data;
	}

	/* wait for BSY gone */
	while ( SSP1SR & SSP_SR_BSY);

	/* drain receive FIFO */
	while ( SSP1SR & SSP_SR_RNE ) {
		data = SSP1DR; 
	}
		SSP1CR0 &= ~0x08;  /* DSS to 8 bit */	
}


/**
  * @brief  Receive data block using FIFO.
  *
  * @param  buf: Pointer to the byte array to store received data
  * @param  len: Specifies the length (in byte) to receive.
  *              Should be multiple of 4.   
  * @retval None.
  */
void SPI_RecvBlock_FIFO (uint8_t *buf, uint32_t len)
{
	uint32_t hwtr, startcnt, i, rec;

	hwtr = len/2;
	if ( len < SSP_FIFO_DEPTH ) {
		startcnt = hwtr;
	} else {
		startcnt = SSP_FIFO_DEPTH;
	}

	SSP1CR0 |= 0x0f;  /* DSS to 16 bit */

	for ( i = startcnt; i; i-- ) {
		SSP1DR = 0xffff;  // fill TX FIFO
	}

	do {
		while ( !(SSP1SR & SSP_SR_RNE ) ) {
		}
		rec = SSP1DR;
		if ( i < ( hwtr - startcnt ) ) {
			SSP1DR = 0xffff;
		}
		*buf++ = (uint8_t)(rec >> 8);
		*buf++ = (uint8_t)(rec);
		i++;
	} while ( i < hwtr );
		SSP1CR0 &= ~0x08;  /* DSS to 8 bit */
}

#endif

/* --------------------------------- End Of File ------------------------------ */

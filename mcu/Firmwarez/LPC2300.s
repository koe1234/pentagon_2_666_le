;/*****************************************************************************/
;/* LPC2300.S: Startup file for Philips LPC2300 device series                 */
;/*****************************************************************************/
;/* <<< Use Configuration Wizard in Context Menu >>>                          */
;/*****************************************************************************/
;/* This file is part of the uVision/ARM development tools.                   */
;/* Copyright (c) 2007 Keil - An ARM Company. All rights reserved.            */
;/* This software may only be used under the terms of a valid, current,       */
;/* end user licence from KEIL for a compatible version of KEIL software      */
;/* development tools. Nothing else gives you the right to use this software. */
;/*****************************************************************************/


;/*
; *  The LPC2300.S code is executed after CPU Reset. This file may be 
; *  translated with the following SET symbols. In uVision these SET 
; *  symbols are entered under Options - ASM - Define.
; *
; *  NO_CLOCK_SETUP: when set the startup code will not initialize Clock 
; *  (used mostly when clock is already initialized from script .ini 
; *  file).
; *
; *  NO_EMC_SETUP: when set the startup code will not initializes External 
; *  Memory Controller (used mostly when external memory is already initialized 
; *  and loaded from script .ini file).
; *
; *  RAM_INTVEC: when set the startup code copies exception vectors 
; *  from on-chip Flash to on-chip RAM.
; *
; *  REMAP: when set the startup code initializes the register MEMMAP 
; *  which overwrites the settings of the CPU configuration pins. The 
; *  startup and interrupt vectors are remapped from:
; *     0x00000000  default setting (not remapped)
; *     0x40000000  when RAM_MODE is used
; *     0x80000000  when EXTMEM_MODE is used
; *
; *  EXTMEM_MODE: when set the device is configured for code execution
; *  from external memory starting at address 0x80000000.
; *
; *  RAM_MODE: when set the device is configured for code execution
; *  from on-chip RAM starting at address 0x40000000. 
; */


; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled


;----------------------- Memory Definitions ------------------------------------

; Internal Memory Base Addresses
FLASH_BASE      EQU     0x00000000   
RAM_BASE        EQU     0x40000000
EXTMEM_BASE     EQU     0x80000000

; External Memory Base Addresses
STA_MEM0_BASE   EQU     0x80000000
STA_MEM1_BASE   EQU     0x81000000


;----------------------- Stack and Heap Definitions ----------------------------

;// <h> Stack Configuration (Stack Sizes in Bytes)
;//   <o0> Undefined Mode      <0x0-0xFFFFFFFF:8>
;//   <o1> Supervisor Mode     <0x0-0xFFFFFFFF:8>
;//   <o2> Abort Mode          <0x0-0xFFFFFFFF:8>
;//   <o3> Fast Interrupt Mode <0x0-0xFFFFFFFF:8>
;//   <o4> Interrupt Mode      <0x0-0xFFFFFFFF:8>
;//   <o5> User/System Mode    <0x0-0xFFFFFFFF:8>
;// </h>

UND_Stack_Size  EQU     0x00000000
SVC_Stack_Size  EQU     0x00000008
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000100
USR_Stack_Size  EQU     0x00000400

ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)

                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size

Stack_Top


;// <h> Heap Configuration
;//   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF>
;// </h>

Heap_Size       EQU     0x00000000

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


;----------------------- System Control Block (SCB) Module Definitions ---------

SCB_BASE        EQU     0xE01FC000      ; SCB Base Address
PLLCON_OFS      EQU     0x80            ; PLL Control Offset
PLLCFG_OFS      EQU     0x84            ; PLL Configuration Offset
PLLSTAT_OFS     EQU     0x88            ; PLL Status Offset
PLLFEED_OFS     EQU     0x8C            ; PLL Feed Offset
CCLKCFG_OFS     EQU     0x104           ; CPU Clock Divider Reg Offset
USBCLKCFG_OFS   EQU     0x108           ; USB Clock Divider Reg Offset
CLKSRCSEL_OFS   EQU     0x10C           ; Clock Source Select Reg Offset
SCS_OFS         EQU     0x1A0           ; System Control and Status Reg Offset
PCLKSEL0_OFS    EQU     0x1A8           ; Peripheral Clock Select Reg 0 Offset
PCLKSEL1_OFS    EQU     0x1AC           ; Peripheral Clock Select Reg 1 Offset

PCON_OFS        EQU     0x0C0           ; Power Mode Control Reg Offset
PCONP_OFS       EQU     0x0C4           ; Power Control for Periphs Reg Offset

; Constants
OSCRANGE        EQU     (1<<4)          ; Oscillator Range Select
OSCEN           EQU     (1<<5)          ; Main oscillator Enable
OSCSTAT         EQU     (1<<6)          ; Main Oscillator Status
PLLCON_PLLE     EQU     (1<<0)          ; PLL Enable
PLLCON_PLLC     EQU     (1<<1)          ; PLL Connect
PLLSTAT_M       EQU     (0x7FFF<<0)     ; PLL M Value
PLLSTAT_N       EQU     (0xFF<<16)      ; PLL N Value
PLLSTAT_PLOCK   EQU     (1<<26)         ; PLL Lock Status

;// <e> Clock Setup
;//   <h> System Controls and Status Register (SCS)
;//     <o1.4>    OSCRANGE: Main Oscillator Range Select
;//                     <0=>  1 MHz to 20 MHz
;//                     <1=> 15 MHz to 24 MHz
;//     <e1.5>       OSCEN: Main Oscillator Enable
;//     </e>
;//   </h>
;//
;//   <h> Clock Source Select Register (CLKSRCSEL)
;//     <o2.0..1>   CLKSRC: PLL Clock Source Selection
;//                     <0=> Internal RC oscillator
;//                     <1=> Main oscillator
;//                     <2=> RTC oscillator
;//   </h>
;//
;//   <h> PLL Configuration Register (PLLCFG)
;//                     <i> PLL_clk = (2* M * PLL_clk_src) / N
;//     <o3.0..14>    MSEL: PLL Multiplier Selection
;//                     <1-32768><#-1>
;//                     <i> M Value
;//     <o3.16..23>   NSEL: PLL Divider Selection
;//                     <1-256><#-1>
;//                     <i> N Value
;//   </h>
;//
;//   <h> CPU Clock Configuration Register (CCLKCFG)
;//     <o4.0..7>  CCLKSEL: Divide Value for CPU Clock from PLL
;//                     <2-256:2><#-1>
;//   </h>
;//
;//   <h> USB Clock Configuration Register (USBCLKCFG)
;//     <o5.0..3>   USBSEL: Divide Value for USB Clock from PLL
;//                     <1-16><#-1>
;//   </h>
;//
;//   <h> Peripheral Clock Selection Register 0 (PCLKSEL0)
;//     <o6.0..1>      PCLK_WDT: Peripheral Clock Selection for WDT
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.2..3>   PCLK_TIMER0: Peripheral Clock Selection for TIMER0
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.4..5>   PCLK_TIMER1: Peripheral Clock Selection for TIMER1
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.6..7>    PCLK_UART0: Peripheral Clock Selection for UART0
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.8..9>    PCLK_UART1: Peripheral Clock Selection for UART1
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.10..11>   PCLK_PWM0: Peripheral Clock Selection for PWM0
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.12..13>   PCLK_PWM1: Peripheral Clock Selection for PWM1
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.14..15>   PCLK_I2C0: Peripheral Clock Selection for I2C0
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.16..17>    PCLK_SPI: Peripheral Clock Selection for SPI
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.18..19>    PCLK_RTC: Peripheral Clock Selection for RTC
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.20..21>   PCLK_SSP1: Peripheral Clock Selection for SSP1
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.22..23>    PCLK_DAC: Peripheral Clock Selection for DAC
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.24..25>    PCLK_ADC: Peripheral Clock Selection for ADC
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o6.26..27>   PCLK_CAN1: Peripheral Clock Selection for CAN1
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 6
;//     <o6.28..29>   PCLK_CAN2: Peripheral Clock Selection for CAN2
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 6
;//     <o6.30..31>    PCLK_ACF: Peripheral Clock Selection for ACF
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 6
;//   </h>
;//
;//   <h> Peripheral Clock Selection Register 1 (PCLKSEL1)
;//     <o7.0..1>  PCLK_BAT_RAM: Peripheral Clock Selection for the Battery Supported RAM
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.2..3>     PCLK_GPIO: Peripheral Clock Selection for GPIOs
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.4..5>      PCLK_PCB: Peripheral Clock Selection for Pin Connect Block
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.6..7>     PCLK_I2C1: Peripheral Clock Selection for I2C1
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.10..11>   PCLK_SSP0: Peripheral Clock Selection for SSP0
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.12..13> PCLK_TIMER2: Peripheral Clock Selection for TIMER2
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.14..15> PCLK_TIMER3: Peripheral Clock Selection for TIMER3
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.16..17>  PCLK_UART2: Peripheral Clock Selection for UART2
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.18..19>  PCLK_UART3: Peripheral Clock Selection for UART3
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.20..21>   PCLK_I2C2: Peripheral Clock Selection for I2C2
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.22..23>    PCLK_I2S: Peripheral Clock Selection for I2S
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.24..25>    PCLK_MCI: Peripheral Clock Selection for MCI
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//     <o7.28..29> PCLK_SYSCON: Peripheral Clock Selection for System Control Block
;//                     <0=> Pclk = Cclk / 4
;//                     <1=> Pclk = Cclk
;//                     <2=> Pclk = Cclk / 2
;//                     <3=> Pclk = Hclk / 8
;//   </h>
;//   <h> Power Control for Peripherals Register (PCONP)
;//     <o8.31>     PCUSB: USB interface power/clock enable
;//     <o8.30>     PCENET: Ethernet block power/clock enable
;//     <o8.29>     PCGPDMA: GP DMA function power/clock enable
;//     <o8.28>     PCSDC: SD card interface power/clock enable
;//     <o8.27>     PCI2S: I2S interface power/clock enable
;//     <o8.26>     PCI2C2: I2C interface 2 power/clock enable
;//     <o8.25>     PCUART3: UART 3 power/clock enable
;//     <o8.24>     PCUART2: UART 2 power/clock enable
;//     <o8.23>     PCTIM3: Timer 3 power/clock enable
;//     <o8.22>     PCTIM2: Timer 2 power/clock enable
;//     <o8.21>     PCSSP0: SSP interface 0 power/clock enable
;//     <o8.19>     PCI2C1: I2C interface 1 power/clock enable
;//     <o8.14>     PCAN2: CAN controller 2 power/clock enable
;//     <o8.13>     PCAN1: CAN controller 1 power/clock enable
;//     <o8.12>     PCAD: A/D converter power/clock enable
;//     <o8.11>     PCEMC: External memory controller power/clock enable
;//     <o8.10>     PCSSP1: SSP interface 1 power/clock enable
;//     <o8.9>      PCRTC: RTC power/clock enable
;//     <o8.8>      PCSPI: SPI interface power/clock enable
;//     <o8.7>      PCI2C0: I2C interface 0 power/clock enable
;//     <o8.6>      PCPWM1: PWM 1 power/clock enable
;//     <o8.4>      PCUART1: UART 1 power/clock enable
;//     <o8.3>      PCUART0: UART 0 power/clock enable
;//     <o8.2>      PCTIM1: Timer/Counter 1 power/clock enable
;//     <o8.1>      PCTIM0: Timer/Counter 0 power/clock enable
;//   </h>
;// </e>
CLOCK_SETUP     EQU     1
SCS_Val         EQU     0x00000020
CLKSRCSEL_Val   EQU     0x00000001
PLLCFG_Val      EQU     0x0000000B
CCLKCFG_Val     EQU     0x00000005
USBCLKCFG_Val   EQU     0x00000005
PCLKSEL0_Val    EQU     0x00000000
PCLKSEL1_Val    EQU     0x00000000
PCONP_Val       EQU     0x04280FDE

;----------------------- Memory Accelerator Module (MAM) Definitions -----------

MAM_BASE        EQU     0xE01FC000      ; MAM Base Address
MAMCR_OFS       EQU     0x00            ; MAM Control Offset
MAMTIM_OFS      EQU     0x04            ; MAM Timing Offset

;// <e> MAM Setup
;//   <o1.0..1>   MAM Control
;//               <0=> Disabled
;//               <1=> Partially Enabled
;//               <2=> Fully Enabled
;//               <i> Mode
;//   <o2.0..2>   MAM Timing
;//               <0=> Reserved  <1=> 1   <2=> 2   <3=> 3
;//               <4=> 4         <5=> 5   <6=> 6   <7=> 7
;//               <i> Fetch Cycles
;// </e>
MAM_SETUP       EQU     1
MAMCR_Val       EQU     0x00000002
MAMTIM_Val      EQU     0x00000004


;----------------------- Pin Connect Block Definitions -------------------------

PCB_BASE            EQU 0xE002C000      ; PCB Base Address
PINSEL0_OFS         EQU 0x00            ; PINSEL0  Address Offset
PINSEL1_OFS         EQU 0x04            ; PINSEL1  Address Offset
PINSEL2_OFS         EQU 0x08            ; PINSEL2  Address Offset
PINSEL3_OFS         EQU 0x0C            ; PINSEL3  Address Offset
PINSEL4_OFS         EQU 0x10            ; PINSEL4  Address Offset
PINSEL5_OFS         EQU 0x14            ; PINSEL5  Address Offset
PINSEL6_OFS         EQU 0x18            ; PINSEL6  Address Offset
PINSEL7_OFS         EQU 0x1C            ; PINSEL7  Address Offset
PINSEL8_OFS         EQU 0x20            ; PINSEL8  Address Offset
PINSEL9_OFS         EQU 0x24            ; PINSEL9  Address Offset
PINSEL10_OFS        EQU 0x28            ; PINSEL10 Address Offset


;----------------------- External Memory Controller (EMC) Definitons -----------

EMC_BASE            EQU 0xFFE08000      ; EMC Base Address

EMC_CTRL_OFS        EQU 0x000           ; EMCControl
EMC_STAT_OFS        EQU 0x004           ; EMCStatus
EMC_CONFIG_OFS      EQU 0x008           ; EMCConfig
EMC_STA_CFG0_OFS    EQU 0x200           ; EMCStaticConfig0
EMC_STA_WWEN0_OFS   EQU 0x204           ; EMCStaticWaitWen0
EMC_STA_WOEN0_OFS   EQU 0x208           ; EMCStaticWaitOen0
EMC_STA_WRD0_OFS    EQU 0x20C           ; EMCStaticWaitRd0
EMC_STA_WPAGE0_OFS  EQU 0x210           ; EMCStaticWaitPage0
EMC_STA_WWR0_OFS    EQU 0x214           ; EMCStaticWaitWr0
EMC_STA_WTURN0_OFS  EQU 0x218           ; EMCStaticWaitTurn0
EMC_STA_CFG1_OFS    EQU 0x220           ; EMCStaticConfig1
EMC_STA_WWEN1_OFS   EQU 0x224           ; EMCStaticWaitWen1
EMC_STA_WOEN1_OFS   EQU 0x228           ; EMCStaticWaitOen1
EMC_STA_WRD1_OFS    EQU 0x22C           ; EMCStaticWaitRd1
EMC_STA_WPAGE1_OFS  EQU 0x230           ; EMCStaticWaitPage1
EMC_STA_WWR1_OFS    EQU 0x234           ; EMCStaticWaitWr1
EMC_STA_WTURN1_OFS  EQU 0x238           ; EMCStaticWaitTurn1
EMC_STA_EXT_W_OFS   EQU 0x080           ; EMCStaticExtendedWait

BUFEN_Const         EQU (1 << 19)       ; Buffer enable bit
EMC_PCONP_Const     EQU (1 << 11)       ; PCONP val to enable power for EMC

; External Memory Pins definitions
; pin functions for external memory interfacing
EMC_PINSEL6_Val     EQU 0x00005555      ; D0 .. D7
EMC_PINSEL8_Val     EQU 0x55555555      ; A0 .. A15
EMC_PINSEL9_Val     EQU 0x50090000;     ; !OE, !WE (BLS0 because of errata), !CS0, !CS1

;//     External Memory Controller Setup (EMC) ---------------------------------
;// <e> External Memory Controller Setup (EMC)
EMC_SETUP           EQU 1

;//   <h> EMC Control Register (EMCControl)
;//     <i> Controls operation of the memory controller
;//     <o0.2> L: Low-power mode enable
;//     <o0.1> M: Address mirror enable
;//     <o0.0> E: EMC enable
;//   </h>
EMC_CTRL_Val        EQU 0x00000001

;//   <h> EMC Configuration Register (EMCConfig)
;//     <o0.0> Endian mode
;//       <0=> Little-endian
;//       <1=> Big-endian
;//   </h>
EMC_CONFIG_Val      EQU 0x00000000

;//       Configure External Bus Behaviour for Static CS0 Area -----------------
;//   <e> Configure External Bus Behaviour for Static CS0 Area
EMC_STACS0_SETUP    EQU 1

;//     <h> Static Memory Configuration Register (EMCStaticConfig0)
;//       <i> Defines the configuration information for the static memory CS0
;//       <o0.20> WP: Write protect
;//       <o0.19> B: Write buffer enable
;//       <o0.8> EW: Extended wait enable
;//       <o0.6> PC: Chip select polarity
;//         <0=> Active LOW chip select
;//         <1=> Active HIGH chip select
;//       <o0.3> PM: Async page mode enable
;//       <o0.0..1> MW: Memory width
;//         <0=> 8 bit
;//         <1=> 16 bit
;//         <2=> 32 bit
;//     </h>
EMC_STA_CFG0_Val    EQU 0x00000000

;//     <h> Static Memory Write Enable Delay Register (EMCStaticWaitWen0)
;//       <i> Selects the delay from CS0 to write enable
;//       <o.0..3> WAITWEN: Wait write enable <1-16> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WWEN0_Val   EQU 0x00000002

;//     <h> Static Memory Output Enable Delay register (EMCStaticWaitOen0)
;//       <i> Selects the delay from CS0 or address change, whichever is later, to output enable
;//       <o.0..3> WAITOEN: Wait output enable <0-15>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WOEN0_Val   EQU 0x00000002
                                      
;//     <h> Static Memory Read Delay Register (EMCStaticWaitRd0)
;//       <i> Selects the delay from CS0 to a read access
;//       <o.0..4> WAITRD: Non-page mode read wait states or asynchronous page mode read first access wait states <1-32> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WRD0_Val    EQU 0x0000001F

;//     <h> Static Memory Page Mode Read Delay Register (EMCStaticWaitPage0)
;//       <i> Selects the delay for asynchronous page mode sequential accesses for CS0
;//       <o.0..4> WAITPAGE: Asynchronous page mode read after the first read wait states <1-32> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WPAGE0_Val  EQU 0x0000001F

;//     <h> Static Memory Write Delay Register (EMCStaticWaitWr0)
;//       <i> Selects the delay from CS0 to a write access
;//       <o.0..4> WAITWR: Write wait states <2-33> <#-2>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WWR0_Val    EQU 0x0000001F

;//     <h> Static Memory Turn Round Delay Register (EMCStaticWaitTurn0)
;//       <i> Selects the number of bus turnaround cycles for CS0
;//       <o.0..4> WAITTURN: Bus turnaround cycles <1-16> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WTURN0_Val  EQU 0x0000000F

;//   </e> End of Static Setup for Static CS0 Area

;//       Configure External Bus Behaviour for Static CS1 Area -----------------
;//   <e> Configure External Bus Behaviour for Static CS1 Area
EMC_STACS1_SETUP    EQU 0

;//     <h> Static Memory Configuration Register (EMCStaticConfig1)
;//       <i> Defines the configuration information for the static memory CS1
;//       <o0.20> WP: Write protect
;//       <o0.19> B: Write buffer enable
;//       <o0.8> EW: Extended wait enable
;//       <o0.6> PC: Chip select polarity
;//         <0=> Active LOW chip select
;//         <1=> Active HIGH chip select
;//       <o0.3> PM: Async page mode enable
;//       <o0.0..1> MW: Memory width
;//         <0=> 8 bit
;//         <1=> 16 bit
;//         <2=> 32 bit
;//     </h>
EMC_STA_CFG1_Val    EQU 0x00000000

;//     <h> Static Memory Write Enable Delay Register (EMCStaticWaitWen1)
;//       <i> Selects the delay from CS1 to write enable
;//       <o.0..3> WAITWEN: Wait write enable <1-16> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WWEN1_Val   EQU 0x00000000

;//     <h> Static Memory Output Enable Delay register (EMCStaticWaitOen1)
;//       <i> Selects the delay from CS1 or address change, whichever is later, to output enable
;//       <o.0..3> WAITOEN: Wait output enable <0-15>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WOEN1_Val   EQU 0x00000000
                                      
;//     <h> Static Memory Read Delay Register (EMCStaticWaitRd1)
;//       <i> Selects the delay from CS1 to a read access
;//       <o.0..4> WAITRD: Non-page mode read wait states or asynchronous page mode read first access wait states <1-32> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WRD1_Val    EQU 0x0000001F

;//     <h> Static Memory Page Mode Read Delay Register (EMCStaticWaitPage0)
;//       <i> Selects the delay for asynchronous page mode sequential accesses for CS1
;//       <o.0..4> WAITPAGE: Asynchronous page mode read after the first read wait states <1-32> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WPAGE1_Val  EQU 0x0000001F

;//     <h> Static Memory Write Delay Register (EMCStaticWaitWr1)
;//       <i> Selects the delay from CS1 to a write access
;//       <o.0..4> WAITWR: Write wait states <2-33> <#-2>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WWR1_Val    EQU  0x0000001F

;//     <h> Static Memory Turn Round Delay Register (EMCStaticWaitTurn1)
;//       <i> Selects the number of bus turnaround cycles for CS1
;//       <o.0..4> WAITTURN: Bus turnaround cycles <1-16> <#-1>
;//         <i> The delay is in CCLK cycles
;//     </h>
EMC_STA_WTURN1_Val  EQU 0x0000000F

;//   </e> End of Static Setup for Static CS1 Area

;//   <h> Static Memory Extended Wait Register (EMCStaticExtendedWait)
;//     <i> Time long static memory read and write transfers
;//     <o.0..9> EXTENDEDWAIT: Extended wait time out <1-64><#-1>
;//       <i> The delay is in (16 * CCLK) cycles
;//   </h>
EMC_STA_EXT_W_Val   EQU 0x00000000

;// </e> End of EMC Setup mnbmnb


                PRESERVE8

; Area Definition and Entry Point
;  Startup Code must be linked first at Address at which it expects to run.

                AREA    RESET, CODE, READONLY
                ARM


; Exception Vectors
;  Mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC, Reset_Addr         
                LDR     PC, Undef_Addr
                LDR     PC, SWI_Addr
                LDR     PC, PAbt_Addr
                LDR     PC, DAbt_Addr
                NOP                            ; Reserved Vector 
;               LDR     PC, IRQ_Addr
                LDR     PC, [PC, #-0x0120]     ; Vector from VicVectAddr
                LDR     PC, FIQ_Addr

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address 
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
SWI_Handler     B       SWI_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler


; Reset Handler

                EXPORT  Reset_Handler
Reset_Handler   



; Clock Setup ------------------------------------------------------------------

                IF      (:LNOT:(:DEF:NO_CLOCK_SETUP)):LAND:(CLOCK_SETUP != 0)
                LDR     R0, =SCB_BASE
                MOV     R1, #0xAA
                MOV     R2, #0x55

;  Configure and Enable PLL
                LDR     R3, =SCS_Val          ; Enable main oscillator
                STR     R3, [R0, #SCS_OFS] 

                IF      (SCS_Val:AND:OSCEN) != 0  
OSC_Loop        LDR     R3, [R0, #SCS_OFS]    ; Wait for main osc stabilize
                ANDS    R3, R3, #OSCSTAT
                BEQ     OSC_Loop
                ENDIF

                LDR     R3, =CLKSRCSEL_Val    ; Select PLL source clock
                STR     R3, [R0, #CLKSRCSEL_OFS] 
                LDR     R3, =PLLCFG_Val
                STR     R3, [R0, #PLLCFG_OFS] 
                STR     R1, [R0, #PLLFEED_OFS]
                STR     R2, [R0, #PLLFEED_OFS]
                MOV     R3, #PLLCON_PLLE
                STR     R3, [R0, #PLLCON_OFS]
                STR     R1, [R0, #PLLFEED_OFS]
                STR     R2, [R0, #PLLFEED_OFS]

                IF      (CLKSRCSEL_Val:AND:3) != 2
;  Wait until PLL Locked (if source is not RTC oscillator)
PLL_Loop        LDR     R3, [R0, #PLLSTAT_OFS]
                ANDS    R3, R3, #PLLSTAT_PLOCK
                BEQ     PLL_Loop
                ELSE
;  Wait at least 200 cycles (if source is RTC oscillator)
                MOV     R3, #(200/4)
PLL_Loop        SUBS    R3, R3, #1
                BNE     PLL_Loop
                ENDIF

M_N_Lock        LDR     R3, [R0, #PLLSTAT_OFS]
                LDR     R4, =(PLLSTAT_M:OR:PLLSTAT_N)
                AND     R3, R3, R4
                LDR     R4, =PLLCFG_Val
                EORS    R3, R3, R4
                BNE     M_N_Lock

;  Setup CPU clock divider
                MOV     R3, #CCLKCFG_Val
                STR     R3, [R0, #CCLKCFG_OFS]

;  Setup USB clock divider
                LDR     R3, =USBCLKCFG_Val
                STR     R3, [R0, #USBCLKCFG_OFS]

;  Setup Peripheral Clock
                LDR     R3, =PCLKSEL0_Val
                STR     R3, [R0, #PCLKSEL0_OFS]
                LDR     R3, =PCLKSEL1_Val
                STR     R3, [R0, #PCLKSEL1_OFS]

;  Switch to PLL Clock
                MOV     R3, #(PLLCON_PLLE:OR:PLLCON_PLLC)
                STR     R3, [R0, #PLLCON_OFS]
                STR     R1, [R0, #PLLFEED_OFS]
                STR     R2, [R0, #PLLFEED_OFS]

                LDR     R4, =PCONP_Val        ; Enable Peripheral Clocks
                STR     R4, [R0, #PCONP_OFS]
                ENDIF   ; CLOCK_SETUP


; Setup Memory Accelerator Module ----------------------------------------------

                IF      MAM_SETUP != 0
                LDR     R0, =MAM_BASE
                MOV     R1, #MAMTIM_Val
                STR     R1, [R0, #MAMTIM_OFS] 
                MOV     R1, #MAMCR_Val
                STR     R1, [R0, #MAMCR_OFS] 
                ENDIF   ; MAM_SETUP


; Setup External Memory Controller ---------------------------------------------

                IF      (:DEF:NO_EMC_SETUP):LOR:(EMC_SETUP != 0)
                LDR     R0, =EMC_BASE
                LDR     R1, =SCB_BASE
                LDR     R2, =PCB_BASE

                LDR     R4, [R1, #PCONP_OFS]
                ORR     R4, R4, #EMC_PCONP_Const  ; Enable EMC clock
                STR     R4, [R1, #PCONP_OFS]

                LDR     R4, =EMC_CTRL_Val
                STR     R4, [R0, #EMC_CTRL_OFS]
                LDR     R4, =EMC_CONFIG_Val
                STR     R4, [R0, #EMC_CONFIG_OFS]

;  Setup pin functions for External Bus functionality
                LDR     R4, =EMC_PINSEL6_Val
                STR     R4, [R2, #PINSEL6_OFS]
                LDR     R4, =EMC_PINSEL8_Val
                STR     R4, [R2, #PINSEL8_OFS]
                LDR     R4, =EMC_PINSEL9_Val
                STR     R4, [R2, #PINSEL9_OFS]

                LDR     R6, =1200000              ; Number of cycles to delay
Wait_0          SUBS    R6, R6, #1                ; Delay ~100 ms @ proc clk 48 MHz
                BNE     Wait_0

                IF      (EMC_STACS0_SETUP != 0)
                LDR     R4, =EMC_STA_CFG0_Val
                STR     R4, [R0, #EMC_STA_CFG0_OFS]
                LDR     R4, =EMC_STA_WWEN0_Val
                STR     R4, [R0, #EMC_STA_WWEN0_OFS]
                LDR     R4, =EMC_STA_WOEN0_Val
                STR     R4, [R0, #EMC_STA_WOEN0_OFS]
                LDR     R4, =EMC_STA_WRD0_Val
                STR     R4, [R0, #EMC_STA_WRD0_OFS]
                LDR     R4, =EMC_STA_WPAGE0_Val
                STR     R4, [R0, #EMC_STA_WPAGE0_OFS]
                LDR     R4, =EMC_STA_WWR0_Val
                STR     R4, [R0, #EMC_STA_WWR0_OFS]
                LDR     R4, =EMC_STA_WTURN0_Val
                STR     R4, [R0, #EMC_STA_WTURN0_OFS]
                ENDIF

                IF      (EMC_STACS1_SETUP != 0)
                LDR     R4, =EMC_STA_CFG1_Val
                STR     R4, [R0, #EMC_STA_CFG1_OFS]
                LDR     R4, =EMC_STA_WWEN1_Val
                STR     R4, [R0, #EMC_STA_WWEN1_OFS]
                LDR     R4, =EMC_STA_WOEN1_Val
                STR     R4, [R0, #EMC_STA_WOEN1_OFS]
                LDR     R4, =EMC_STA_WRD1_Val
                STR     R4, [R0, #EMC_STA_WRD1_OFS]
                LDR     R4, =EMC_STA_WPAGE1_Val
                STR     R4, [R0, #EMC_STA_WPAGE1_OFS]
                LDR     R4, =EMC_STA_WWR1_Val
                STR     R4, [R0, #EMC_STA_WWR1_OFS]
                LDR     R4, =EMC_STA_WTURN1_Val
                STR     R4, [R0, #EMC_STA_WTURN1_OFS]
                ENDIF

                LDR     R6, =120000               ; Number of cycles to delay
Wait_1          SUBS    R6, R6, #1                ; Delay ~10 ms @ proc clk 48 MHz
                BNE     Wait_1

                LDR     R4, =EMC_STA_EXT_W_Val
                LDR     R5, =EMC_STA_EXT_W_OFS
                ADD     R5, R5, R0
                STR     R4, [R5, #0]

                ENDIF   ; EMC_SETUP


; Copy Exception Vectors to Internal RAM ---------------------------------------

                IF      :DEF:RAM_INTVEC
                ADR     R8, Vectors         ; Source
                LDR     R9, =RAM_BASE       ; Destination
                LDMIA   R8!, {R0-R7}        ; Load Vectors 
                STMIA   R9!, {R0-R7}        ; Store Vectors 
                LDMIA   R8!, {R0-R7}        ; Load Handler Addresses 
                STMIA   R9!, {R0-R7}        ; Store Handler Addresses
                ENDIF


; Memory Mapping (when Interrupt Vectors are in RAM) ---------------------------

MEMMAP          EQU     0xE01FC040          ; Memory Mapping Control
                IF      :DEF:REMAP
                LDR     R0, =MEMMAP
                IF      :DEF:EXTMEM_MODE
                MOV     R1, #3
                ELIF    :DEF:RAM_MODE
                MOV     R1, #2
                ELSE
                MOV     R1, #1
                ENDIF
                STR     R1, [R0]
                ENDIF


; Setup Stack for each mode ----------------------------------------------------

                LDR     R0, =Stack_Top

;  Enter Undefined Instruction Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                IF      :DEF:__MICROLIB

                EXPORT __initial_sp

                ELSE

                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size

                ENDIF


; Enter the C code -------------------------------------------------------------

                IMPORT  __main
                LDR     R0, =__main
                BX      R0


                IF      :DEF:__MICROLIB

                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE
; User Initial Stack & Heap
                AREA    |.text|, CODE, READONLY

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap
__user_initial_stackheap

                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + USR_Stack_Size)
                LDR     R2, = (Heap_Mem +      Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDIF


                END

//
// Name: Berkay Arslan
// School ID: 171024030
//
// P.S: There was an annoyance in my SSD's first digit. So, I worked with SSD's last
// three digits.

.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb


/* make linker see this */
.global Reset_Handler

/* get these from linker script */
.word _sdata
.word _edata
.word _sbss
.word _ebss


/* define peripheral addresses from RM0444 page 57, Tables 3-4 */
.equ RCC_BASE,         (0x40021000)          // RCC base address
.equ RCC_IOPENR,       (RCC_BASE   + (0x34)) // RCC IOPENR register offset

.equ GPIOA_BASE,       (0x50000000)          // GPIOA base address
.equ GPIOA_MODER,      (GPIOA_BASE + (0x00)) // GPIOA MODER register offset
.equ GPIOA_ODR,        (GPIOA_BASE + (0x14)) // GPIOA ODR register offset
.equ GPIOA_PUPDR,	   (GPIOA_BASE + (0x0C))

.equ GPIOB_BASE,       (0x50000400)          // GPIOA base address
.equ GPIOB_MODER,      (GPIOB_BASE + (0x00)) // GPIOA MODER register offset
.equ GPIOB_ODR,        (GPIOB_BASE + (0x14)) // GPIOA ODR register offset
.equ GPIOB_IDR,        (GPIOB_BASE + (0x10)) // GPIOB IDR register offset

.equ GPIOF_BASE,	   (0x50001400)
.equ GPIOF_MODER,	   (GPIOF_BASE + (0x00))
.equ GPIOF_IDR,	       (GPIOF_BASE + (0x10))

/* vector table, +1 thumb mode */
.section .vectors
vector_table:
	.word _estack             /*     Stack pointer */
	.word Reset_Handler +1    /*     Reset handler */
	.word Default_Handler +1  /*       NMI handler */
	.word Default_Handler +1  /* HardFault handler */
	/* add rest of them here if needed */


/* reset handler */
.section .text
Reset_Handler:
	/* set stack pointer */
	ldr r0, =_estack
	mov sp, r0

	/* initialize data and bss
	 * not necessary for rom only code
	 * */
	bl init_data
	/* call main */
	bl main
	/* trap if returned */
	b .


/* initialize data and bss sections */
.section .text
init_data:

	/* copy rom to ram */
	ldr r0, =_sdata
	ldr r1, =_edata
	ldr r2, =_sidata
	movs r3, #0
	b LoopCopyDataInit

	CopyDataInit:
		ldr r4, [r2, r3]
		str r4, [r0, r3]
		adds r3, r3, #4

	LoopCopyDataInit:
		adds r4, r0, r3
		cmp r4, r1
		bcc CopyDataInit

	/* zero bss */
	ldr r2, =_sbss
	ldr r4, =_ebss
	movs r3, #0
	b LoopFillZerobss

	FillZerobss:
		str  r3, [r2]
		adds r2, r2, #4

	LoopFillZerobss:
		cmp r2, r4
		bcc FillZerobss

	bx lr


/* default handler */
.section .text
Default_Handler:
	b Default_Handler


/* main function */
.section .text
main:
// STM32 port assignments

	ldr r6, =RCC_IOPENR
	ldr r5, [r6]
	movs r4, 0x3
	orrs r5, r5, r4
	str r5, [r6]


	ldr r6, = GPIOB_MODER
	ldr r5, [r6]
	ldr r4, = 0xFFF4F5DF
	ands r5, r5, r4
	str r5, [r6]

	ldr r6, =GPIOB_ODR
	ldr r5, [r6]
	ldr r4, =0x330
	orrs r5, r5, r4
	str r5, [r6]

	ldr r6, =GPIOA_MODER
	ldr r5, [r6]
	ldr r4, =0x280AA0A
	bics r5, r5, r4
	str r5, [r6]

	ldr r6, = GPIOA_PUPDR
	ldr r5 , [r6]
	ldr r4,= 0x1405505
	orrs r5, r5, r4
	str r5, [r6]



loop:

	b myID
	b loop

//idle state
myID:
    adds r7, r7, #1
    ldr r0,=#0
    bl Display2
    ldr r6,=#200
    bl delay
    bl reset
    ldr r1,=#3
    bl Display3
    ldr r6,=#200
    bl delay
    ldr r2,=#0
    bl reset
    bl Display4
    ldr r6,=#200
    bl delay
	bl reset

//buttona basınca generate setup ı
	ldr r6, =GPIOB_IDR
	ldr r5, [r6]
	ldr r4,= 0x110
	cmp r5, r4
	beq Generate_Setup

    b myID

Generate_Setup:
//basamaklarin tutuldugu registerlar
    ldr r0, =#0
    ldr r1, =#0
    ldr r2, =#0

    bl Generate // Random sayi uret. Basamaklarina ayir.
    bl Divide_D2
    bl Divide_D3
    bl Divide_D4
    bl Count_Back
//Random Generate Fonksiyonu
Generate:
	ldr r6, =#999
	subs r7,r7,r6
	cmp r7, r6
	blt link
	b Generate
//basit bir link fonksiyonu
link:
    bx lr
//First digiti ayırma
Divide_D2:
	ldr r6, =#100
	subs r7, r7, r6
    adds r0, r0, #1
	cmp r7, r6
	blt link
	b Divide_D2
//second digiti ayırma
Divide_D3:
    ldr r6, =#10
    subs r7, r7, r6
    adds r1, r1, #1
    cmp r7, r6
    blt link
    b Divide_D3
//Third digiti ayırma
Divide_D4:
	ldr r6, =#1
	subs r7, r7, r6
	adds r2, r2, #1
	cmp r7, r6
	blt link
	b Divide_D4


//Button a basinca gidilen loop
Button_Loop:
	subs r7, r7, #1
	bl Button_Number
	cmp r0, r7
	beq Count_Back
	ldr r6, =GPIOB_IDR
	ldr r5, [r6]
	ldr r4,= 0x110
	cmp r5, r4
	beq Stop_Counting
	b Button_Loop

//Button a basilinca olusturulan random number
Button_Number:
	push {lr}
	bl reset
    bl Display2
    ldr r6,=#200
    bl delay
    bl reset
    bl decimal
    ldr r6,=#200
    bl delay
    bl reset
    bl Display3
    ldr r6,=#200
    bl delay
    bl reset
    bl Display4
    ldr r6,=#200
    bl delay
	pop {pc}
//external led
external_led:
	ldr r6, =GPIOB_ODR
	ldr r5, [r6]
	ldr r4, =0x334
	orrs r5, r5, r4
	str r5, [r6]
	bx lr
//Zero state'in loop u. 1sn beklet, ledi yak, sonra idle state' e gec.
Zero_state_Loop:
	bl external_led
	subs r7, r7, #1
	cmp r7, r0
	bne Zero_State
	bl external_led
	b myID

//Zero state, count back islemi bittikten sonra buraya gececek.
Zero_State:
    ldr r0,=#0
    bl Display2
    ldr r6,=#200
    bl delay
    ldr r1,=#0
    bl reset
    bl Display3
    ldr r6,=#200
    bl delay
    ldr r2,=#0
    bl reset
    bl Display4
    ldr r6,=#200
    bl delay
	bl reset
	b Zero_state_Loop

//Count back islemleri. Count_Back_r2 ne zaman calisirsa display i güncelletiyor bu fonksiyon.
Count_Back:

    bl Count_Back_r2
    ldr r6,=#50
    bl delay
    ldr r7,= #50
    b Button_Loop

//button'a basinca display fonksiyonunu infinite loop'a al. Bidaha basinca da infinite loop'tan cikart.
Stop_Counting:
	bl Button_Number
	ldr r6, =GPIOB_IDR
	ldr r5, [r6]
	ldr r4,= 0x110
	cmp r5, r4
	beq Keep_Counting
	b Stop_Counting

Keep_Counting:
	b Button_Loop

Count_Back_r2:
    subs r2, r2, #1
    ldr r7,= #-1
    cmp r2, r7
    bne link
    ldr r7,= #0
    cmp r1, r7
    bne Count_Back_r1
    cmp r0, r7
    ldr r7,= #9000
    beq Zero_State
	b Count_Back_r0

Count_Back_r1:
	ldr r7,= #-1
	ldr r2, =#9
    subs r1, r1, #1
    cmp r1, r7
    bne Count_Back_r2
    ldr r1, =#9
    b Count_Back_r0

Count_Back_r0:
    subs r0, r0, #1
    ldr r1, =#9
    ldr r2, =#9
    b Count_Back_r2

// delay function
delay:
	subs r6, r6, #1
	bne delay
	bx lr

//Display fonksiyonlari.
Display2:
    ldr r6, = GPIOB_ODR
    ldr r5, [r6]
    ldr r3,= 0xFFFF
    orrs r5, r5, r3
    ldr r4,= 0x200
    ands r5, r5, r4
    str r5, [r6]
    b AssignNum_D2

Display3:
    ldr r6, = GPIOB_ODR
    ldr r5, [r6]
    ldr r3,= 0xFFFF
    orrs r5, r5, r3
    ldr r4,= 0x20
    ands r5, r5, r4
    str r5, [r6]
    b AssignNum_D3

Display4:
    ldr r6, = GPIOB_ODR
    ldr r5, [r6]
    ldr r3,= 0xFFFF
    orrs r5, r5, r3
    ldr r4,= 0x10
    ands r5, r5, r4
    str r5, [r6]
    b AssignNum_D4

//Her display fonksiyonuna ozel olarak register atandigi icin karismasin diye bu fonksiyonlar olusturuldu.
AssignNum_D2:
    cmp r0, #0
	beq zero
	cmp r0, #1
	beq one
	cmp r0, #2
	beq two
	cmp r0, #3
	beq three
	cmp r0, #4
	beq four
	cmp r0, #5
	beq five
	cmp r0, #6
	beq six
	cmp r0, #7
	beq seven
	cmp r0, #8
	beq eight
	cmp r0, #9
	beq nine

AssignNum_D3:
    cmp r1, #0
	beq zero
	cmp r1, #1
	beq one
	cmp r1, #2
	beq two
	cmp r1, #3
	beq three
	cmp r1, #4
	beq four
	cmp r1, #5
	beq five
	cmp r1, #6
	beq six
	cmp r1, #7
	beq seven
	cmp r1, #8
	beq eight
	cmp r1, #9
	beq nine

AssignNum_D4:
    cmp r2, #0
	beq zero
	cmp r2, #1
	beq one
	cmp r2, #2
	beq two
	cmp r2, #3
	beq three
	cmp r2, #4
	beq four
	cmp r2, #5
	beq five
	cmp r2, #6
	beq six
	cmp r2, #7
	beq seven
	cmp r2, #8
	beq eight
	cmp r2, #9
	beq nine

//Ekranda gösterilecek sayilarin fonksiyonlari.
zero:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x1833
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

one:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x12
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

two:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x1063
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

three:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x73
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

four:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x852
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

five:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x871
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

six:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x1871
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

seven:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x13
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

eight:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x1873
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

nine:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x873
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

//Her display'den sonra resetlenmesi gerekiyor ODR'in. Bunun icin de reset fonksiyonu olusturuldu.
reset:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0xFFFF // 1100 1111 0011
	mvns r4, r4
	ands r5, r5, r4
	str r5, [r6]
    bx lr
//Counting de gozukmesi icin bi decimal fonksiyonu olusturuldu.
decimal:
	ldr r6, =GPIOA_ODR
	ldr r5, [r6]
	ldr r4,= 0x80
	mvns r4, r4
	orrs r5, r5, r4
	str r5, [r6]
    bx lr

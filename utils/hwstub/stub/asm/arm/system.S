/***************************************************************************
 *             __________               __   ___.
 *   Open      \______   \ ____   ____ |  | _\_ |__   _______  ___
 *   Source     |       _//  _ \_/ ___\|  |/ /| __ \ /  _ \  \/  /
 *   Jukebox    |    |   (  <_> )  \___|    < | \_\ (  <_> > <  <
 *   Firmware   |____|_  /\____/ \___  >__|_ \|___  /\____/__/\_ \
 *                     \/            \/     \/    \/            \/
 * $Id$
 *
 * Copyright (C) 2014 by Amaury Pouly
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 ****************************************************************************/

/* Handling of data abort:
 * the code can register a "longjmp" buffer to restore the context in case of
 * fault */
.data
data_abort_jmp_ctx_ptr:
/* buffer contains in order: cpsr,r4-r11,sp,lr,pc */
.skip   48 /* = 4 * (cpsr +  11 registers) */

.text
/* Prototype: int set_data_abort_jmp()
 * Return: 1 in case of data abort, 0 otherwise */
.global set_data_abort_jmp
set_data_abort_jmp:
    mrs     r2, cpsr
    ldr     r1, =data_abort_jmp_ctx_ptr
    mov     r0, #0
    stmia   r1, {r2,r4-r11,sp,lr,pc} /* see PC note below */
    bx      lr
    mov     r0, #1 /* <-- PC points here in stmia */
    bx      lr

.global data_abort_handler
data_abort_handler:
    /* restore everything from context */
    ldr     r1, =data_abort_jmp_ctx_ptr
    /* NOTE: we need to restore sp_sys and lr_sys, for this we need the
     * LDM  Rn, {}^
     * variant, but we cannot restore PC from it because ^ has a different
     * meaning and won't restore user/sys registers. On top of that, the
     * non-PC ^ variant cannot do the register writeback, so on the PC restore,
     * we reload all registers once again to avoid manually offseting the base
     * register, it will trash sp_abt and lr_abr but those are unused anyway
     * because we do not save the abort address and we don't use an abort stack */
    ldmia   r1, {r0,r4-r11,sp,lr}^  /* this variant cannot have writeback (r1!) */
    msr     spsr, r0
    ldmia   r1, {r0,r4-r11,sp,lr,pc}^ /* reload some registers but we don't care */

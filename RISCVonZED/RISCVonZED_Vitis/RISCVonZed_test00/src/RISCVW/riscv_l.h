/*
 * riscv.h
 *
 *  Created on: 1. 5. 2023
 *      Author: kornerltd.cz
 */

#ifndef RISCVW_RISCV_L_H_
#define RISCVW_RISCV_L_H_

#include "xil_types.h"
#include "xstatus.h"
#include "xil_io.h"

#define RVW_OFFSET_REG_CONTROL				0
#define RVW_OFFSET_REG_STATUS				4
#define RVW_OFFSET_REG_CLOCK_CONTROL		8

#define RVW_BIT_REG_CONTROL_RESET			0x00000001
#define RVW_BIT_REG_CONTROL_COMPUTER_RESET	0x00000002

#define RVW_BIT_REG_CLOCK_CONTROL_CE		0x00000001
#define RVW_BIT_REG_CLOCK_CONTROL_PULSE		0x00000002

#define RVW_OFFSET_COMPUTER_MEM				0x00010000


/*
 * Register IO
 */
#define RVW_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

#define RVW_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/*
 * Memory IO
 */
#define RVW_mWriteMem(BaseAddress, MemOffset, Data) \
	Xil_Out32((BaseAddress) + (MemOffset) + (RVW_OFFSET_COMPUTER_MEM), (u32)(Data))

#define RVW_mReadMem(BaseAddress, MemOffset) \
    Xil_In32((BaseAddress) + (MemOffset) + (RVW_OFFSET_COMPUTER_MEM))

/*
 * Register writes
 */
#define RVW_mWriteRegControl(BaseAddress, Data) \
	RVW_mWriteReg((BaseAddress), (RVW_OFFSET_REG_CONTROL), (Data))

#define RVW_mWriteRegClockControl(BaseAddress, Data) \
	RVW_mWriteReg((BaseAddress), (RVW_OFFSET_REG_CLOCK_CONTROL), (Data))

/*
 * Register reads
 */
#define RVW_mReadRegControl(BaseAddress) \
	RVW_mReadReg((BaseAddress), (RVW_OFFSET_REG_CONTROL))

#define RVW_mReadRegStatus(BaseAddress) \
	RVW_mReadReg((BaseAddress), (RVW_OFFSET_REG_STATUS))

#define RVW_mReadRegClockControl(BaseAddress) \
	RVW_mReadReg((BaseAddress), (RVW_OFFSET_REG_CLOCK_CONTROL))

#endif /* RISCVW_RISCV_L_H_ */

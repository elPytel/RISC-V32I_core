/*
 * riscv.c
 *
 *  Created on: 1. 5. 2023
 *      Author: kornerltd.cz
 */

#include "riscv.h"

/*
 * RVW_Initialize
 * 	initializes driver structure
 *
 * drv - instance driver pointer
 * base_address - device base address
 * mbize - computer ram byte size
 *
 * returns XST_* codes
 */
int RVW_Initialize(RVW_t* drv, u32 base_address, int mbsize) {
	Xil_AssertNonvoid(drv != NULL);
	Xil_AssertNonvoid((u32*)base_address != NULL);

	drv->BaseAddress = base_address;
	drv->ComputerMemByteSize = mbsize;
	RVW_CoreGetReset(drv, NULL);
	RVW_CoreGetClockEnable(drv, NULL);
	return XST_SUCCESS;
}

/*
 * RVW_Reset
 * 	Resets IP & core and updates driver structure
 *
 * drv - instance driver pointer
 *
 * returns XST_* codes
 */
int RVW_Reset(RVW_t *drv) {
	Xil_AssertNonvoid(drv != NULL);

	RVW_mWriteRegControl(drv->BaseAddress, RVW_BIT_REG_CONTROL_RESET);
	RVW_CoreGetReset(drv, NULL);
	RVW_CoreGetClockEnable(drv, NULL);
	return XST_SUCCESS;
}

/*
 * RVW_CoreSetReset
 * 	Sets core reset value
 *
 * drv - instance driver pointer
 * value - nonzero based reset value
 *
 * returns XST_* codes
 */
int RVW_CoreSetReset(RVW_t *drv, int value) {
	Xil_AssertNonvoid(drv != NULL);

	u32 reg_control = RVW_mReadRegControl(drv->BaseAddress);
	if (value) {
		RVW_mWriteRegControl(drv->BaseAddress, reg_control | RVW_BIT_REG_CONTROL_COMPUTER_RESET);
	}
	else {
		RVW_mWriteRegControl(drv->BaseAddress, reg_control & ~RVW_BIT_REG_CONTROL_COMPUTER_RESET);
	}
	drv->ComputerReset = value;
	return XST_SUCCESS;
}

/*
 * RVW_CoreGetReset
 * 	Sets core reset value
 *
 * drv - instance driver pointer
 * value - nonzero based reset return value
 *
 * returns XST_* codes
 */
int RVW_CoreGetReset(RVW_t *drv, int *value) {
	Xil_AssertNonvoid(drv != NULL);

	u32 reg_control = RVW_mReadRegControl(drv->BaseAddress);
	drv->ComputerReset = reg_control & RVW_BIT_REG_CONTROL_COMPUTER_RESET;
	if (value != NULL) {
		*value = drv->ComputerReset;
	}
	return XST_SUCCESS;
}

/*
 * RVW_CoreSetClockEnable
 * 	Sets core clock enable value
 *
 * drv - instance driver pointer
 * value - nonzero based clock enable value
 *
 * returns XST_* codes
 */
int RVW_CoreSetClockEnable(RVW_t *drv, int value) {
	Xil_AssertNonvoid(drv != NULL);

	u32 reg_clock = RVW_mReadRegClockControl(drv->BaseAddress);
	if (value) {
		RVW_mWriteRegClockControl(drv->BaseAddress, reg_clock | RVW_BIT_REG_CLOCK_CONTROL_CE);
	}
	else {
		RVW_mWriteRegClockControl(drv->BaseAddress, reg_clock & ~RVW_BIT_REG_CLOCK_CONTROL_CE);
	}
	drv->ComputerClockEnable = value;
	return XST_SUCCESS;
}

/*
 * RVW_CoreSetClockEnable
 * 	Sets core clock enable value
 *
 * drv - instance driver pointer
 * value - nonzero based clock enable value
 *
 * returns XST_* codes
 */
int RVW_CoreGetClockEnable(RVW_t *drv, int *value) {
	Xil_AssertNonvoid(drv != NULL);

	u32 reg_clock = RVW_mReadRegClockControl(drv->BaseAddress);
	drv->ComputerClockEnable = reg_clock & RVW_BIT_REG_CLOCK_CONTROL_CE;
	if (value != NULL) {
		*value = drv->ComputerClockEnable;
	}
	return XST_SUCCESS;
}

/*
 * RVW_CoreClockPulse
 * 	Generates single clock pulse
 *
 * drv - instance driver pointer
 *
 * returns XST_* codes
 */
int RVW_CoreClockPulse(RVW_t *drv) {
	Xil_AssertNonvoid(drv != NULL);
	u32 reg_clock = RVW_mReadRegClockControl(drv->BaseAddress);
	RVW_mWriteRegClockControl(drv->BaseAddress, reg_clock | RVW_BIT_REG_CLOCK_CONTROL_PULSE);
	return XST_SUCCESS;
}

/*
 * RVW_CoreGetStatus
 * 	Reads core status register
 *
 * drv - instance driver pointer
 * status - returns core status value via pointer
 *
 * returns XST_* codes
 */
int RVW_CoreGetStatus(RVW_t *drv, int* status) {
	Xil_AssertNonvoid(drv != NULL);
	*status = RVW_mReadRegStatus(drv->BaseAddress);
	return XST_SUCCESS;
}

/*
 * RVW_CoreWriteMem
 * 	Copies buffer content to core program memory
 *
 * drv - instance driver pointer
 * membuf - source buffer
 * woffset - word offset
 * wsize - word size
 *
 * returns XST_* codes
 */
int RVW_CoreWriteMem(RVW_t *drv, u32 *membuf, int woffset, int wsize) {
	Xil_AssertNonvoid(drv != NULL);
	Xil_AssertNonvoid(membuf != NULL);

	if ((wsize < 0) || (wsize > drv->ComputerMemByteSize / 4)) {
		return XST_FAILURE;
	}

	for (int i = 0; i < wsize; i++) {
		RVW_mWriteMem(drv->BaseAddress, 4 * woffset + i * 4, membuf[i]);
	}

	return XST_SUCCESS;

}

/*
 * RVW_CoreRadMem
 * 	Copies program memory to local buffer
 *
 * drv - instance driver pointer
 * membuf - destination buffer
 * woffset - word offset
 * wsize - word size
 *
 * returns XST_* codes
 */
int RVW_CoreRadMem(RVW_t *drv, u32 *membuf, int woffset, int wsize) {
	Xil_AssertNonvoid(drv != NULL);
	Xil_AssertNonvoid(membuf != NULL);

	if ((wsize < 0) || (wsize > drv->ComputerMemByteSize)) {
		return XST_FAILURE;
	}

	for (int i = 0; i < wsize; i++) {
		membuf[i] = RVW_mReadMem(drv->BaseAddress, 4 * woffset + i*4);
	}

	return XST_SUCCESS;
}

char RVW_cpu_state_name_table[RVW_CPU_STATE_UNKNOWN][16] = {
	"FETCH",
	"DECODE",
	"EXECUTE",
	"MEMORY",
	"WRITEBACK",
	"IDLE",
	"HALT",
	"EXCEPTION",
	"START",
	"RESETING"
};

/*
 * riscv.h
 *
 *  Created on: 1. 5. 2023
 *      Author: kornerltd.cz
 */

#ifndef RISCVW_RISCV_H_
#define RISCVW_RISCV_H_

#include "riscv_l.h"

typedef enum {
	RVW_CPU_STATE_FETCH,
	RVW_CPU_STATE_DECODE,
	RVW_CPU_STATE_EXECUTE,
	RVW_CPU_STATE_MEMORY,
	RVW_CPU_STATE_WRITEBACK,
	RVW_CPU_STATE_IDLE,
	RVW_CPU_STATE_HALT,
	RVW_CPU_STATE_EXCEPTION,
	RVW_CPU_STATE_START,
	RVW_CPU_STATE_RESETING,
	RVW_CPU_STATE_UNKNOWN
} RVW_cpu_state_t;

typedef struct {
	u32 BaseAddress;
	int ComputerReset;
	int ComputerClockEnable;
	int ComputerMemByteSize;
} RVW_t;

int RVW_Initialize(RVW_t* InstPtr, u32 BaseAddress, int MemByteSize);
int RVW_Reset(RVW_t *InstPtr);
int RVW_CoreSetReset(RVW_t *InstPtr, int value);
int RVW_CoreGetReset(RVW_t *InstPtr, int *value);
int RVW_CoreSetClockEnable(RVW_t *InstPtr, int value);
int RVW_CoreGetClockEnable(RVW_t *InstPtr, int *value);
int RVW_CoreClockPulse(RVW_t *InstPtr);
int RVW_CoreGetStatus(RVW_t *InstPtr, int *status);
int RVW_CoreWriteMem(RVW_t *InstPtr, u32 *membuf, int offset, int bsize);
int RVW_CoreRadMem(RVW_t *InstPtr, u32 *membuf, int offset, int bsize);

extern char RVW_cpu_state_name_table[RVW_CPU_STATE_UNKNOWN][16];

#endif /* SRC_RISCVW_RISCV_H_ */

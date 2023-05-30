#include <ff.h>
#include <stdio.h>
#include <stdlib.h>
#include <xil_printf.h>
#include <xil_types.h>
#include <xparameters.h>
#include <xstatus.h>

#include "platform.h"
#include "RISCVW/riscv.h"

RVW_t rv;

u32 membuf[4096/4];

static FATFS fatfs;

int mount_fs(TCHAR *path);
int program_read(TCHAR *file, u32 *progbuf, int *size);

int main()
{
	int status;
	int core_status;

    init_platform();

    printf("RISC-V on ZED test platform\r\n");

    status = mount_fs("0:/");
    if (status !=  XST_SUCCESS) {
    	printf("Failed to mount file system with status %d\r\n", status);
    	return status;
    }

    int progsize;
    status = program_read("ledtest.raw", membuf, &progsize);
    if (status != XST_SUCCESS) {
    	printf("Failed to read program.raw file with status %d\r\n", status);
    	return status;
    }

    status = RVW_Initialize(&rv, XPAR_KORNER_RISC_V_0_BASEADDR, 4096);
    if (status != XST_SUCCESS) {
    	printf("Failed to initialize RWV driver\r\n");
    }

    status = RVW_CoreGetStatus(&rv, &core_status);
    printf("RVW initialized. Core status %s\r\n", RVW_cpu_state_name_table[core_status]);

    status = RVW_CoreWriteMem(&rv, membuf, 0, progsize);
    status = RVW_CoreRadMem(&rv, membuf, 0, progsize);

    int cycle = 0;
    RVW_CoreSetReset(&rv, 1);
    status = RVW_CoreClockPulse(&rv);
    RVW_CoreSetReset(&rv, 0);
    RVW_CoreGetStatus(&rv, &core_status);
    printf("Core status %s\r\n", RVW_cpu_state_name_table[core_status]);
    while(1) {
    	status = RVW_CoreClockPulse(&rv);
    	status = RVW_CoreGetStatus(&rv, &core_status);
    	xil_printf("%d:%s\r\n", cycle, RVW_cpu_state_name_table[core_status]);
    	cycle++;
    }

    cleanup_platform();
    return 0;
}

int mount_fs(TCHAR *path) {

	/* Mount SD */

    return f_mount(&fatfs, path, 0);
}

int program_read(TCHAR *file, u32 *progbuf, int *size) {

	FRESULT status = FR_OK;
    FIL fil;
    status = f_open(&fil, file, FA_READ);
    if (status != FR_OK) {
    	return status;
    }

    TCHAR linebuf[16];
    unsigned int br;

    int progsize = 0;
    while(1) {
    	status = f_read(&fil, linebuf, 8, &br);
    	if (status != FR_OK) {
    		break;
    	}
    	if (br > 0) {
    		linebuf[br] = 0;
    		unsigned long instr = strtoul(linebuf, NULL, 16);
    		progbuf[progsize] = (u32)instr;
    		progsize++;
    	} else
    	{
    		break;
    	}
    }
    *size = progsize;
    return status;
}

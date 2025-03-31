[BITS 32]
[extern kernelBridge]
page_directory_base_address equ 0x200000     ; 页目录的起始物理地址
kernel_page_table_base_address equ 0x201000  ; 核心态页表的起始物理地址

global greatstart
greatstart:
    ; 页目录清 0
    mov edi, page_directory_base_address + 0xc0000000  ; 逻辑地址 3G+2M = 物理 2M
    mov ecx, 1024
    xor eax, eax
    rep stosd

    ; 填写页目录：0# 和 768# 指向同一个内核页表
    mov eax, kernel_page_table_base_address
    or eax, 0x03  ; Present + Read/Write
    mov [page_directory_base_address + 0*4 + 0xc0000000], eax    ; 0#
    mov [page_directory_base_address + 768*4 + 0xc0000000], eax  ; 768#

    ; 初始化内核页表（映射 0xC0000000~0xC0400000 → 0x00000000~0x00400000）
    mov edi, kernel_page_table_base_address ; 逻辑地址 3G+2M+4K = 物理 2M+4K
    mov eax, 0x00000003  ; 物理页 0x0 + Present + Read/Write
    mov ecx, 1024        ; 1024 项 × 4KB = 4MB

.fill_kernel_page_table:
    mov [edi], eax
    add eax, 0x1000  ; 下一物理页（+4KB）
    add edi, 4       ; 下一页表项
    loop .fill_kernel_page_table

    ; 清中断描述符表（加载空的 IDT）
    lidt [empty_idt]

    ; 设置 CR3 寄存器（指向页目录）
    mov edx, page_directory_base_address
    mov cr3, edx

    ; 启动分页和保护机制（CR0.PG = 1, CR0.PE = 1）
    mov ebx, cr0
    or ebx, 0x80000001
    mov cr0, ebx

    ; 设置段寄存器（使用内核数据段选择子）
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0xc0400000  ; 设置内核栈顶（4MB处）
    mov ebp, 0xc0400000

    ; 跳转到内核入口（kernelBridge）
    jmp code_selector:kernelBridge

    ; 如果跳转失败，执行未定义指令（ud2）
    ud2

align 4  ; 4 字节对齐
empty_idt:
    .length dw 0
    .base dd 0

; 选择子（GDT 索引 * 8）
code_selector equ (1 << 3)  ; 内核代码段选择子（GDT 第 1 项）
data_selector equ (2 << 3)  ; 内核数据段选择子（GDT 第 2 项）

align 4
gdt_pointer:
    dw (gdt_end - gdt_base) - 1  ; GDT 限长
    dd gdt_base                  ; GDT 基地址
    dd 0                         ; 保留

align 4
gdt_base:
    dq 0                        ; 第 0 项：空描述符
gdt_kernel_code:
    dq 0xcf9a000000ffff         ; 内核代码段：DPL=0, 32位, 4GB, 可执行/可读
gdt_kernel_data:
    dq 0xcf92000000ffff         ; 内核数据段：DPL=0, 32位, 4GB, 可读/可写
gdt_end:
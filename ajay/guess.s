.code16         # Use 16-bit assembly
.altmacro
.globl start    # Tells linker that start is "main"

.macro PUTC c=$0x20
    push %ax
    mov \c, %al
    mov $0x0E, %ah
    int $0x10
    pop %ax
.endm

.macro HEX_NIBBLE reg
        LOCAL letter, end
        cmp $10, \reg
        jae letter
        add $'0, \reg
        jmp end
    letter:
        add $0x37, \reg
    end:
.endm

.macro HEX c
    mov \c, %al
    mov \c, %ah
    shr $4, %al
    HEX_NIBBLE <%al>
    and $0x0F, %ah
    HEX_NIBBLE <%ah>
.endm


.macro PRINT_HEX reg = <%al>
    push %ax
    HEX <\reg>
    PUTC <%al>
    PUTC <%ah>
    pop %ax
.endm

#simple startup prompt--use this a lot, especially with a starting prompt
start:
    movw $prompt, %si  # load the offset of our message into %si
    movb $0x00,%ah      # 0x00 - set video mode
    movb $0x03,%al      # 0x03 - 80x25 text mode
    int $0x10           # call into the BIOS
    .equ RTCaddress, 0x70
    .equ RTCdata, 0x71
    jmp rtc_seconds_example


rtc_seconds_example:
    movb $0x0A, %al         #get AL ready for access with code 0x0A
    out %al, $RTCaddress    #do in/out stuff--covered
    in $RTCdata, %al
    testb $0x80, %al        #test if the RTC is ready--if its not, itll output garbage, so we wait until it gives the correct code
    jne rtc_seconds_example
    
    mov $0x00, %al          #0x00 is the seconds code in the RTC--set output to seconds
    out %al, $RTCaddress    #again, in out stuff
    in $RTCdata, %al           
        
    cmp %al, %cl            #only print if the seconds change (only really helpful when showcasing usablility with inf loop)
    je rtc_seconds_example
    mov %al, %cl
    
     
    HEX <%al>               #Hexify value for actual number                   
    mov %ah, %cl            #Now CL holds the value of the random number
    
    jmp set_prompt

set_prompt:
    movw $prompt, %si       #set our prompt (also a good entry point for an inf loop)

print_prompt:
    lodsb
    testb %al, %al
    jz load_char_example
    movb $0x0e, %ah
    int $0x10
    jmp print_prompt

load_char_example:
    int $0x16               #interrupt to read a single char when AH is set to 0--which it is. Saves it to AL
    movb $0x0e, %ah         #print the char out, to prove it was loaded
    int $0x10
    
    cmp %al, %cl            #check if the char was the right answer              
    je correct              #incorrect vs. correct. We need to do this to not lose our random val with the print
    jmp incorrect



carriage_return:
    movb 0x0d, %al          #send cursor back to first column
    movb $0x0e, %ah
    int $0x10
    movb 0x0a, %al
    movb $0x0e, %ah
    int $0x10


incorrect:
    movb 0x0d, %al          #send cursor back to first column
    movb $0x0e, %ah
    int $0x10
    movb 0x0a, %al
    movb $0x0e, %ah
    int $0x10

    movw $bad_msg, %si
    jmp finish_up_bad

correct:
    movb 0x0d, %al          #send cursor back to first column
    movb $0x0e, %ah
    int $0x10
    movb 0x0a, %al
    movb $0x0e, %ah
    int $0x10

    movw $good_msg, %si
    jmp finish_up_good

#bad because the value does not change here, but in the good version, the value changes
finish_up_bad:
    lodsb
    testb %al, %al
    jz new_game_bad
    movb $0x0e, %ah
    int $0x10
    jmp finish_up_bad

new_game_bad:
     movb 0x0d, %al          #send cursor back to first column
     movb $0x0e, %ah
     int $0x10
     movb 0x0a, %al
     movb $0x0e, %ah
     int $0x10
     jmp set_prompt

#good because the random value changes here
finish_up_good:
    lodsb
    testb %al, %al
    jz new_game_good
    movb $0x0e, %ah
    int $0x10
    jmp finish_up_good

new_game_good:
     movb 0x0d, %al          #send cursor back to first column
     movb $0x0e, %ah
     int $0x10
     movb 0x0a, %al
     movb $0x0e, %ah
     int $0x10
     jmp rtc_seconds_example



print_char_example:
    lodsb                   #loads AL with one byte from SI, AL is the register that will be printed by print function, it also moves SI forward.
    movb $0x0e, %ah         #sets AH to print function
    int $0x10               #calls current function

//hardcoded string fills
good_msg:
    .string "Right! Congratulations."
bad_msg:
    .string "Wrong!\n"
prompt:
    .string "What number am I thinking of (0-9)?   "
//pad semantics

.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA

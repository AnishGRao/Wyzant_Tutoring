.code16         # Use 16-bit assembly
.altmacro
.globl start    # Tells linker that start is "main"
###
#   Fully Working!!
#
#
#   requirements:
#               sudo apt-get install qemu, qemu-utils;
#   run cmmand for wsl2:
#               make guess; qemu-system-i386 -nographic -hda guess
#               (runs qemu without need for graphics driver and vcxsvr.)
#               To quit, hold ctrl+a, let go, and type 'x' without quotes.
###

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

#simple startup prompt--use this a lot, especially with a starting prompt
start:
    movw $prompt, %si       # load the offset of our message into %si
    movb $0x00,%ah          # 0x00 - set video mode
    movb $0x03,%al          # 0x03 - 80x25 text mode
    int $0x10               # call into the BIOS
    .equ RTCaddress, 0x70   # set RTCaddress to 0x70, so magic numbers are not throughout the code    
    .equ RTCdata, 0x71      # set RTCdata to 0x70, so magic numbers are not throughout the code
    .equ HOME, 0x0d         # set the value of the HOME ASCII to 0x0d
    .equ ENTER, 0x0a        # set the value of the ENTER ASCII to 0x0a
    jmp rtc_seconds_example # jump down to the calculation of the random value

rtc_seconds_example:
    movb $0x0A, %al         #get AL ready for access with code 0x0A
    out %al, $RTCaddress    #do in/out stuff--covered
    in $RTCdata, %al        #set RTCdata as input stream
    testb $0x80, %al        #test if the RTC is ready--if its not, itll output garbage, so we wait until it gives the correct code
    jne rtc_seconds_example #if RTC not ready and outputs 0x80, restart the function until ready.
    
    mov $0x00, %al          #0x00 is the seconds code in the RTC--set output to seconds
    out %al, $RTCaddress    #again, in out stuff
    in $RTCdata, %al        #set input stream as RTC data
        
    cmp %al, %cl            #only print if the seconds change (only really helpful when showcasing usablility with inf loop)
    je rtc_seconds_example  #if there was no change (here unnecessary) restart until change.
    mov %al, %cl            #move the value of AL into CL (not necessary here) to check for change
    
     
    HEX <%al>               #Hexify value for actual number                   
    mov %ah, %cl            #Now CL holds the value of the random number, and is 0-9, because AL holds the upper value so 0-5
    
    jmp set_prompt          #go and set the prompt

set_prompt:
    movw $prompt, %si       #set our prompt (also a good entry point for an inf loop)

print_prompt:
    lodsb                   #load a bit from SI into AL, and increment the pointer at SI by one
    testb %al, %al          #check if it is 0--this will happen when SI is no longer pointing at valid info.
    jz load_char_example    #if SI is "invalid," then our stuff has fully printed, now obtain user input
    movb $0x0e, %ah         #move the print function into AH--it prints what is in AL
    int $0x10               #call an interrupt which triggers the function above--printing AL
    jmp print_prompt        #Recurse, while there is still content to print

load_char_example:
    mov $0x0,%ah            #shove 0 into AH, in order to have the correct conditions to trigger on the next interrupt
    int $0x16               #interrupt to read a single char when AH is set to 0--which it is. Saves it to AL
    movb $0x0e, %ah         #set the print function
    int $0x10               #print the char out

    cmp %al, %cl            #check if the char was the right answer (remember, we saved the random number to CL, as we need AL and AH open)

    movb $HOME, %al         #set up next line by storing a "move to start of line" ASCII to AL
    movb $0x0e, %ah         #set up print function (redundant)
    int $0x10               #"print" the cursor, setting it to the beginning
    movb $ENTER, %al        #setup by storign a "move to next row" ASCII to AL
    movb $0x0e, %ah         #set up print function (redundant)
    int $0x10               #"print" the cursor, with it now at the beginning of the next line

    je correct              #incorrect vs. correct. We need to do this to not lose our random val with the print
    jmp incorrect           #go to incorrect func

incorrect:
    movw $bad_msg, %si      #move the bad msg into SI, like we did the prompt
    jmp finish_up_bad       #go to next function

correct:
    movw $good_msg, %si     #move the good msg into SI, like we did the prompt
    jmp finish_up_good      #go to next function
    
##bad because the value does not change here, but in the good version, the value changes
finish_up_bad:
    lodsb                   #same as printing out the prompt, just with either right or wrong                 
    testb %al, %al          #same as printing out the prompt, just with either right or wrong         
    jz new_game_bad         #go to final portion before restart         
    movb $0x0e, %ah         #same as printing out the prompt, just with either right or wrong         
    int $0x10               #same as printing out the prompt, just with either right or wrong     
    jmp finish_up_bad       #same as printing out the prompt, just with either right or wrong

#good because the random value changes here
finish_up_good:
    lodsb                   #same as priting out the prompt, just with either right or wrong  
    testb %al, %al          #same as priting out the prompt, just with either right or wrong          
    jz new_game_good        #go to final portion before restart              
    movb $0x0e, %ah         #same as priting out the prompt, just with either right or wrong          
    int $0x10               #same as priting out the prompt, just with either right or wrong      
    jmp finish_up_good      #same as priting out the prompt, just with either right or wrong              

new_game_bad:
     movb $HOME, %al        #send cursor back to first column
     movb $0x0e, %ah        #repeat the same stuff for setting up the next line  
     int $0x10              #repeat the same stuff for setting up the next line   
     movb $ENTER, %al       #repeat the same stuff for setting up the next line              
     movb $0x0e, %ah        #repeat the same stuff for setting up the next line              
     int $0x10              #repeat the same stuff for setting up the next line      
     jmp set_prompt         #jump up to setting the prompt--the random number has not changed.         

new_game_good:
     movb $HOME, %al          #send cursor back to first column
     movb $0x0e, %ah          #repeat the same stuff for setting up the next line            
     int $0x10                #repeat the same stuff for setting up the next line    
     movb $ENTER, %al         #repeat the same stuff for setting up the next line            
     movb $0x0e, %ah          #repeat the same stuff for setting up the next line            
     int $0x10                #repeat the same stuff for setting up the next line    
     jmp rtc_seconds_example  #jump to calculating the random value, here the random number changes or else it would just be the same one forever.                  

#hardcoded string fills
good_msg:
    .string "     Right! Congratulations."
bad_msg:
    .string "     Wrong!"
prompt:
    .string "     What number am I thinking of (0-9)? "
#pad semantics
.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA

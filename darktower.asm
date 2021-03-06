
; *** Chapter 0 page 0

S000    ldx   0         
	tma             
	a9aac           
	br    S03E      
S00F    tcmiy 8         
	tcy   0         
	br    S01B      
S03E    tcmiy 0         

;
; Rotate the drum to the position targeted in 4/0
; Current position is in 0/0
;
S03D    ldx   0         
	tcy   0         
	tma             
	ldx   4         
	mnea            
	br    S033      
	retn            

S033    ldp   1         
	call  L040      
	ldx   5         
	tcy   0         
	tma             
	ldx   1         
	alem            
	br    S018      
	br    S000      
S018    mnea            
	br    S01C      
	ldx   6         
	tma             
	ldx   2         
	alem            
	br    S01C      
	br    S000      
S01C    ldx   0         
	tma             
	a9aac           
	br    S00F      
	imac            
	tam             
S01B    ldx   6         
	tma             
	amaac           
	br    S011      
	ldx   2         
	tam             
	ldx   5         
	tma             
	br    S026      
S011    ldx   2         
	tam             
	ldx   5         
	imac            
	br    S00A      
S026    amaac           
	br    S00A      
	ldx   1         
	tam             
	br    S03D      
S00A    ldx   2         
	tcmiy 14        
	ldx   1         
	tcy   0         
	tcmiy 15        
	br    S03D      
	mnea            

; *** Chapter 0 page 1

L040    tcy   8         ; Select the Rotation Sensor
	setr            
	tcy   9         ; Select the Motor
	setr            
	ldx   6         
	tcy   0         
	tcmiy 0         
	ldx   5         
	tcy   0         
	tcmiy 0         
S077    tka             
	dan             
	br    S04E      
	br    S077      
S079    ldx   6         
	tcmiy 15        
	br    S071      
S04E    tcy   5         
	tya             
	tcy   8         
S075    dyn             
	br    S075      
	dan             
	br    S075      
	ldx   6         
	tcy   0         
	imac            
	br    S04B      
	br    S078      
S04B    tam             
	ldx   5         
	imac            
	br    S079      
S078    tam             
S071    tka             
	dan             
	br    S04E      
	tcy   8         
	rstr            
	tcy   9         
	rstr            
	retn            

;
; RANDOM routine continues
;
S074    tma             ; Pick up value at 3/0, 3/1, 3/2
	ldx   4         
	amaac           ; Add 4/0, 4/1, 4/2 to it
	call  S055      ; Increment 6/0, 6/1, 6/2 if carry
	ldx   5         
	amaac           ; Add 5/0, 5/1, 5/2 to it
	call  S055      ; Increment 6/0, 6/1, 6/2 if carry
	ldx   6         
	amaac           ; Add 6/0, 6/1, 6/2 to it
	call  S055      ; Increment 6/0, 6/1, 6/2 if carry
	ldx   3         
	tamiyc          ; Store it at 3/0, 3/1, 3/2 then increment Y
	ynec  3         ; We done doing 0-2?
	br    S074      ; Nope, do the next column
	tcy   2         
	retn            

S055    iyc             
	ldx   6         
	xma             
	iac             
	ldp   7         
	br    L1D4      ; xma, dyn, retn

; *** Chapter 0 page 2

;
; Using the R output in A, scan the K inputs to find a key pressed
;
; For some reason the R output we're looking at is stored in 6/13 with the high-order bit set.
;
S080    tcy   13        
	tam             ; Save the R output we're using at 6/13
	a8aac           ; Toggle high-order bit
	br    S09F      ; There should have been a carry due to the way it's stored
	a8aac           ; Nope, add 8 again to get it back (?)
S09F    tay             
	setr            ; Set R output addressed by Y
	tka             ; Pick up K inputs from keyboard
	rstr            ; Reset R output addressed by Y
	tcy   14        
	xma             ; Exchange 6/14 and results of TKA - Look at the last read?

	tbit1 0         ; Keyboard row 1 - Dark Tower/Frontier/Inventory - set? (3/7/11)
	br    S0AE      ; Add 3 to accumulator

	tbit1 3         ; Keyboard row 2 - Tomb-Ruin/Move/Sanctuary-Citadel - set? (2/6/10)
	br    S09C      ; Add 2 to accumulator

	tbit1 2         ; Keyboard row 3 - Haggle/Bazaar/Clear - set? (1/5/9)
	br    S0B8      ; Add 1 to accumulator

	tbit1 1         ; Keyboard row 4 - Yes-Buy/Repeat/No-End - set? (0/4/8)
	br    S0B1      ; Add nothing to accumulator

;
; No keys were detected, fall through
;
	a4aac           ; Nothing was read? - A = 4
	tam             ; Save results at 6/14
;
; Entry point for keyboard read routine.  Loop through the R output and scan the K inputs at S080
;
READKBD tcy   13        
	dman            ; Pick up the last R output we looked at and subtract one
	br    S0B0      ; We're not done scanning
	br    S085      
S0B0    tay             
	ynec  7         
	br    S080      ; Go back and scan the next R output

S085    tcy   14        
	tma             ; Load 6/14
	br    S0B1      

S0AE    iac             
S09C    iac             
S0B8    iac             
S0B1    tcy   15        
	xma             ; Swap 6/15 with results
	mnea            ; Compare this result to the last result
	br    S08A      ; Go back to prompt routine if they're different

	tay             
	ynec  12        
	br    S091      
	tcy   13        
	sbit  3         ; Set 6/13 bit 3
	tcy   12        
	tbit1 0         ; 6/12 bit 0 set?
	br    S08A      ; Go back to prompt routine
	br    S089      ; Success, return?

S091    tcy   12        
	tbit1 0         ; 6/12 bit 0 set?
	br    S099      

S089    cla             
	dan             
	ldp   10        
	br    L2A2      ; TDO, pick up value in 6/15 to Y and return

S099    tcy   13        
	tbit1 3         ; 6/13 bit 3 set?
	br    S0AA      
S08A    ldp   7         
	br    L1C6      ; Jump back into prompt routine and refresh the LEDs some more

S0AA    ldp   3         
	tpc             
	ldp   1         
	call  PLYTICK      
	br    S089      


; *** Chapter 0 page 3

;********************************************************************************
; RANDOM 
;
; Generate a random number based on the seed at 3/0-2 and 4/0-2
; 5/0-2 and 6/0-2 are overwritten.
;
; Return value in A (0-F); Y=2
;
; The formula is:
;
; 3/0 * 2 -> 4/0 * 2 -> 5/1
; 3/1 * 2 -> 4/1 * 2 -> 5/2
; 3/2 * 2 -> 4/2
; 3/0 + 4/0 + 5/0 + 6/0 -> 3/0 using 6/0 as carry
; 3/1 + 4/1 + 5/1 + 6/1 -> 3/1 using 6/1 as carry
; 3/2 + 4/2 + 5/2 + 6/2 -> 3/2 using 6/2 as carry
;
; Example: 3/0 = 0; 3/1 = 1; 3/2 = 2
;          4/0 = 0; 4/1 = 0
;
; Results:  0 1 2    Y=2; A=A
;           -----
;         3|0 3 A
;         4|0 2 4
;         5|0 0 4
;         6|0 0 0
;********************************************************************************
RANDOM  ldx   5         
	call  S0D5      ; Clear 5/0-2
	ldx   6         
	call  S0D5      ; Clear 6/0-2
	ldx   3         
	tcy   0         
	tma             ; Pick up value at 3/0 (Starting value)
	amaac           ; Double it
	br    S0C9      ; Branch if it overflowed
	ldx   4         
	tam             ; Save it at 4/0
S0EF    amaac           ; Double it
	br    S0E9      ; Branch if it overflowed
	ldx   5         
	tcy   1         
	tam             ; Save doubled value at 5/1
S0E7    ldx   3         
	tma             ; Pick up value at 3/1 (Starting value)
	amaac           ; Double it
	br    S0E3      ; Branch if it overflowed
	ldx   4         
	tam             ; Save doubled value at 4/1
S0D6    amaac           ; Double it
	ldx   5         
	tcy   2         
	tam             ; Save it at 5/2
	ldx   3         
	tma             ; Pick up value at 3/2 (Starting value)
	amaac           ; Double it
	ldx   4         
	tam             ; Save it at 4/2
	ldx   3         
	tcy   0         
	ldp   1         
	br    S074      ; Out of room here...

S0E3    ldx   4         ; 3/1 doubling caused an overflow...
	tamiyc          ; Save doubled value at 4/1
	ldx   6         
	imac            
	tamdyn          ; Add one to 6/2
	ldx   4         
	tma             ; Pick up 4/1
	br    S0D6      ; Go back and deal with the next digit
S0E9    ldx   5         
	tcy   1         
	tamiyc          
	ldx   6         
	imac            
	tamdyn          
	br    S0E7      
S0C9    ldx   4         ; 3/0 doubling caused an overflow
	tamiyc          ; Save doubled value at 4/0
	ldx   6         
	tcmiy 1         ; Store a 1 at 6/1
	tcmiy 2         ; Store a 2 at 6/2
	ldx   4         
	tcy   0         
	br    S0EF      ; Go back and deal with the next digit

S0D5    tcy   0         
	tcmiy 0         
	tcmiy 0         
	tcmiy 0         
	retn            

	mnea            

; *** Chapter 0 page 4

;********************************************************************************
; AD2B10
;
; Perform Base 10 arithmetic on values in scratchpad RAM 4/1-2 and 5/1-2
;
; Add the two-digit base 10 number encoded in 4/1 and 4/2 to the two-digit 
; base 10 number encoded in 5/1 and 5/2 giving a three-digit base-10 number
; encoded in 5/0-2.
;
; For example:   0 1 2     (x means doesn't matter--overwritten)
;              4 x 1 9
;              5 x 2 2
;
; Returns:       0 1 2
;              4 0 1 9
;              5 0 4 1
;********************************************************************************
AD2B10  ldx   5         
	tcy   0         
	tcmiy 0         ; 5/0 = 0
L107    ldx   4         
	tcy   0         
	tcmiy 0         ; 4/0 = 0
SUMB10  cla             ; SUMB10 - don't initialize 100s digit
	tcy   2         ; Start at 4/2 with A=0
;
; Perform (4/Y + 5/Y) mod 10
;
S13D    ldx   4         
	amaac           
	ldx   5         
	amaac           ; A = 4/Y + 5/Y (Y = 2-0)
	br    S11D      ; Overflow?
	a6aac           ; Add 6 to Accumulator - (do a MOD 10 operation; is the result >= 10?)
	br    S13A      ; Yes

	a10aac          ; Add 10 to Accumulator - (effectively back out the A6AAC operation)
	tamza           ; Save to 5/Y (Y = 2-0)
	br    S12B      
S11D    a6aac           
S13A    tamza           
	iac             
S12B    dyn             
	br    S13D      
	tcy   0         
	retn            

;
; Generate a random number between 17 and 32 - used to give a base Brigand count
;
L130    ldp   3         
	call  RANDOM    ; Get a random number in ACC
	ldx   4         
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	ldx   4         
	tamdyn          ; 4/2 = ACC
	ldx   5         
	tcmiy 0         ; 5/1 = 0
	tcmiy 0         ; 5/2 = 0
	ldp   4         
	call  AD2B10    ; Copy random number to 5/2 via addition (?!)
	ldx   4         
	tcy   1         
	tcmiy 1         ; 4/1 = 1
	tcmiy 7         ; 4/2 = 7
	ldp   4         
	br    AD2B10    ; Add 17 and return

;
; Generate a random number between 9 and 16.  Used by Santuary to calculate
; how much food or gold to provide the player.
;
L129    ldp   3         
	call  RANDOM    
	ldx   4         
	tamdyn          ; 4/2 = ACC
	tcmiy 0         ; 4/1 = 0
	rbit  3         ; Limit 4/2 to 0-7
	ldx   5         
	tcy   1         
	tcmiy 0         ; 5/1 = 0
	tcmiy 9         ; 5/2 = 9
	call  AD2B10    
	ldp   1         
	tpc             
	ldp   12        
	br    CPY5TO4   ; Be neat about it and copy the amount up to the top of the formula

;
; Add 16 to 5/1-2
;
ADD16   ldx   4         
	tcy   1         
	tcmiy 1         ; 4/1 = 16
	tcmiy 6         
	ldp   4         
	br    AD2B10    

; *** Chapter 0 page 5

;********************************************************************************
; DSPRSLT
;
; Display the results of an encounter or inventory
; Called after encounter as well as when Repeat button is hit
;
; Note about status flags.  The tests assume the bit being set means
; the inventory doesn't need to be shown.  Cleared means display the
; current status.
;********************************************************************************
DSPRSLT ldx   4         
	tcy   13        
	tbit1 0         ; Warrior count change during encounter
	br    S173      
;
; Display Warrior count
;
	tcy   1         ; Switch drum to Warrior/Food/Beast position
	ldp   8         
	call  ROTDRUM   
	ldp   1         
	tpc             
	ldp   6         
	call  CPY2TO5   ; Copy the warrior count for current player to 5/1 and 5/2
	ldp   8         
	call  BUF2DSP   ; Update display buffer with contents of 5/1 and 5/2
	ldp   9         
	call  L241      ; Light top window and update display from display buffer???

S173    ldx   4         
	tcy   13        
	tbit1 1         ; Food change during encounter
	br    S157      
;
; Display Food
;
	tcy   1         ; Switch drum to Warrior/Food/Beast position
	ldp   8         
	call  ROTDRUM   
	ldp   1         
	tpc             
	ldp   12        
	call  CPY1TO5   ; Copy the gold amount for current player to 5/1 and 5/2
	ldp   8         
	call  BUF2DSP   ; Update display buffer with contents of 5/1 and 5/2
	ldp   9         
	call  L25F      

S157    ldx   4         
	tcy   13        
	tbit1 3         ; Beast found during encounter
	br    S152      
;
; Display Beast
;
	ldx   1         
	tcy   3         
	tbit1 0         ; Check inventory for Beast
	br    S176      
	br    S152      
S176    tcy   1         ; Switch drum to Warrior/Food/Beast position
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTLWRCL   ; Light lower window

S152    ldx   4         
	tcy   14        
	tbit1 0         ; Scout found during encounter
	br    S155      
;
; Display Scout
;
	ldx   1         
	tcy   3         
	tbit1 3         ; Check inventory for Scout
	br    S14C      
	br    S155      
S14C    tcy   2         ; Switch drum to Scout/Healer/Gold position
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTTOPCL   ; Light Scout and clear display

S155    ldx   4         
	tcy   14        
	ldp   6         
	tbit1 1         ; Healer found during encounter?
	br    L1B7      
	br    S180


; *** Chapter 0 page 6

;
; Display Healer
;
S180    ldx   1         
	tcy   3         
	tbit1 1         ; Check inventory for Healer
	br    S19F      
	br    L1B7      
S19F    tcy   2         ; Switch drum to Scout/Healer/Gold position
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTMIDCL   ; Light Healer and clear display

L1B7    ldx   4         
	tcy   13        
	tbit1 2         ; Gold found during encounter?
	br    S1B0      
;
; Display Gold
;
	tcy   2         ; Switch drum to Scout/Healer/Gold position
	ldp   8         
	call  ROTDRUM   
	ldp   1         
	tpc             
	ldp   12        
	call  CPY0TO5   
	ldp   8         
	call  BUF2DSP   ; Update display buffer with contents of 5/1 and 5/2
	ldp   9         
	call  L27B      ; Light bottom window and update display from display buffer???

S1B0    ldx   4         
	tcy   15        
	tbit1 0         ; Gold Key found during encounter?
	br    S1B6      
;
; Display Gold Key
;
	ldx   2         
	tcy   3         
	tbit1 3         ; Check inventory for Gold Key
	br    S1B1      
	br    S1B6      
S1B1    tcy   3         ; Switch drum to Gold Key/Silver Key/Brass Key
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTTOPCL   ; Light Gold Key and clear display

S1B6    ldx   4         
	tcy   14        
	tbit1 3         ; Silver Key found during encounter?
	br    S18C      
;
; Display Silver Key
;
	ldx   2         
	tcy   3         
	tbit1 2         ; Check inventory for Silver Key
	br    S1A2      
	br    S18C      
S1A2    tcy   3         ; Switch drum to Gold Key/Silver Key/Brass Key
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTMIDCL   ; Light Silver Key and clear display

S18C    ldx   4         
	tcy   14        
	ldp   7         
	tbit1 2         ; Brass Key found during encounter?
	br    L1DF      
;
; Display Brass Key
;
	ldx   2         
	tcy   3         
	tbit1 1         ; Check inventory for Brass Key
	br    L1C0      
	br    L1DF      
	mnea            

; *** Chapter 0 page 7

L1C0    tcy   3         ; Switch drum to Gold Key/Silver Key/Brass Key
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTLWRCL   ; Light lower window

L1DF    ldx   4         
	tcy   15        
	tbit1 1         ; Sword resulting from encounter?
	br    S1FA      
;
; Display Sword if in inventory
;
	ldx   1         
	tcy   3         
	tbit1 2         ; Check inventory for Sword
	br    S1F9      
	br    S1FA      
S1F9    tcy   4         ; Switch drum to Dragon/Sword/Pegasus
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTMIDCL   ; Light Sword and clear display
;
; Display Pegasus?
;
; Note, Pegasus isn't an inventory item so there is no check for it
;
S1FA    ldx   4         
	tcy   15        
	tbit1 2         ; Pegasus resulting from encounter?
	br    S1C5      

	tcy   4         ; Switch drum to Dragon/Sword/Pegasus
	ldp   8         
	call  ROTDRUM   
	ldp   9         
	call  LTLWRCL   ; Light lower window
S1C5    retn            

;********************************************************************************
; PROMPT - Prompt user for input
;
; Update display with contents of 7/14 and 7/15, flash and wait for keypress
;
; Return key pressed in Y:
;  0 = Yes/Buy          6 = Move
;  1 = Haggle           7 = Frontier
;  2 = Tomb/Ruin        8 = No/End
;  3 = Dark Tower       9 = Clear
;  4 = Repeat          10 = Sanctuary/Citadel
;  5 = Bazaar          11 = Inventory
;********************************************************************************
PROMPT  ldx   6         
	tcy   12        
	sbit  0         
	rbit  2         ; Don't update LEDs immediately (?)
L1F8    ldx   6         
	tcy   13        
	rbit  3         

L1C6    ldp   10        
	call  REFRLED   
	ldp   10        
	call  REFRLED   
	ldp   10        
	call  REFRLED   
	ldx   3         
	tcy   2         
	tma             
	a7aac           
	call  S1CA      
	tam             
;
; Set things up before reading the keyboard
;
	ldx   6         
	tcy   13        
	rbit  2         
	sbit  1         
	sbit  0         
	tcy   14        
	tcmiy 0         
	ldp   2         
	br    READKBD   

S1CA    tamdyn          
	imac            
	retn            

L1D4    xma             
	dyn             
	retn            

	mnea            

; *** Chapter 0 page 8

;
; Rotate the player RAM buffer so the next player is in the first
; position
;
L200    ldx   0         ; Rotate 0/1-12 left three times
	call  S230      
	call  S230      
	call  S230      
	ldx   1         ; Rotate 1/1-12 left three times
	call  S230      
	call  S230      
	call  S230      
	ldx   2         ; Rotate 2/1-12 left three times
	call  S230      
	call  S230      
	call  S230      

	ldx   3         
	tcy   11        
	tma             ; Pick up the current player from 3/11
	a12aac          ; Add 12 to generate an overflow if we're on player 4
	br    S21D      ; Overflow, it's P0 right now
	a4aac           ; Add 4 to get us back to where we should be

S21D    iac             ; Next player...
	tam             ; Update current player at 3/11
	tcy   9         
	alem            ; Check that we're not exceeding the total number of players playing
	br    S218      ; We're done
	br    L200      ; Oops.  Do another rotation

S218    retn            

;
; Rotate the current register file words 1-12 left one word
;
S230    tcy   12        ; Start at 12
	tma             ; Get a copy of what's at the current position
	dyn             ; Move pointer left
S205    xma             ; Swap
	dyn             ; Move pointer left
	ynec  0         ; Are we pointing at zero?
	br    S205      ; Nope, do it again
	tcy   12        ; Final step, copy what was at 1
	tam             ; To 12
	retn            

;********************************************************************************
; RND0TO2 - Return a random value from 0 to 2 in A
;
;	11 - 15 - A = 2
;        6 - 10 - A = 1
;        0 -  5 - A = 0
;********************************************************************************
RND0TO2 ldp   3         
	call  RANDOM    
L20D    tcy   1         
S21B    a5aac           
	br    S234      
	dyn             
	br    S21B      
S234    tya             
	iac             
	retn            

;********************************************************************************
; BUF2DSP - Load 5/1 and 5/2 into the display buffer 7/14 and 7/15 respectively
;********************************************************************************
BUF2DSP ldx   5         
	tcy   1         
	tma             
	ldx   7         
	tcy   14        
	tam             
	ldx   5         
	tcy   2         
	tma             
	ldx   7         
	tcy   15        
	tam             
	retn            

;********************************************************************************
; ROTDRUM - Rotate the drum to the position specified in Y
;********************************************************************************
ROTDRUM tya             
	ldx   4         
	tcy   0         
	tam             
	ldp   0         
	br    S03D      

; *** Chapter 0 page 9

;********************************************************************************
; LTTOPCL - Clear display and light top lamp
;********************************************************************************
LTTOPCL call  S25A      ; Load blanks into 7/14-15
L241    call  S248      ; Set for immediate update of LEDS (6/12 bit 2 set)
	tcy   7         ; Select upper lamp
	br    S26F      

;********************************************************************************
; LTMIDCL - Clear display and light middle lamp
;********************************************************************************
LTMIDCL call  S25A      ; Load blanks into 7/14-15
L25F    call  S248      ; Set for immediate update of LEDS (6/12 bit 2 set)
	tcy   6         ; Select middle lamp
	br    S26F      

;********************************************************************************
; LTLWRCL - Clear display and light lower lamp
;********************************************************************************
LTLWRCL call  S25A      ; Load blanks into 7/14-15
L27B    call  S248      ; Set for immediate update of LEDS (6/12 bit 2 set)
	tcy   5         ; Select lower lamp

;
; Light the lamp referenced in Y, beep, update the LEDs and loop over REFRLED
;
S26F    setr            ; Light the selected lamp
	ldp   3         
	tpc             
	ldp   13        
	call  PLYBEEP   
L267    ldx   6         
	tcy   12        
	sbit  2         ; 6/12 bit 2 set - Immediate update of LEDs
;
; Call REFRLED $BF (191) times
;
	ldx   6         
	tcy   0         
	tcmiy 15        ; 6/0 = 15
	tcmiy 11        ; 6/1 = 11
S26C    tam             ; 6/2 = A
	ldp   10        
	call  REFRLED   
	ldx   6         
	tcy   0         
	dman            ; Acc = 6/0 - 1
	br    S26C      ; Update 6/0 and loop
	tamiyc          ; Acc has overflowed; update 6/0 and focus on 6/1
	dman            ; Decrement 6/1
	br    S26C      ; Update 6/1 and loop
;
; We've called REFRLED enough times; turn off the lamps
;
	tdo             
	tcy   7         ; Select Upper lamp
	rstr            ; Turn it off
	tcy   6         ; Select Middle lamp
	rstr            ; Turn it off
	tcy   5         ; Select Lower lamp
	rstr            ; Turn it off

	retn            
;
; Load blanks into display buffer (7/14-15)
;
S25A    ldx   7         
	tcy   14        
	tcmiy 15        ; 7/14 = 15 (" ")
	tcmiy 15        ; 7/15 = 15 (" ")
	retn            
;
; Set for immediate update of LEDs on call to REFRLED (6/12 bit 2 set)
;
S248    ldx   6         
	tcy   12        
	sbit  2         
	retn            

;********************************************************************************
; CPYBRIG - Copy the current brigand count (3/12-13) to 5/1-2 for base 10 math
;********************************************************************************
CPYBRIG ldx   3         
	tcy   12        
	tma             
	ldx   5         
	tcy   1         
	tam             
	ldx   3         
	tcy   13        
	tma             
	ldx   5         
	tcy   2         
	tam             
	retn            

	mnea            

; *** Chapter 0 page 10

;********************************************************************************
; REFRLED
;
; Refresh the contents of the LEDs either with new data or handle flashing
;
;********************************************************************************
REFRLED ldx   6         
	tcy   12        
	tbit1 2         ; 6/12 Bit 2 - Immediate update of LEDs.  Bypass flashing.
	br    S2A1      
;
; Decrement countdown timer in 7/12-13.  When it expires, it checks what's currently displayed
; in the LED segments (6/12 Bit 1).  If it's reset, it does a TDO and clears the display.  It then
; toggles the bit.
;
	ldx   7         
	tcy   13        
	dman            
	br    S2AB      
	tamdyn          ; 7/13 = 7/13 - 1
	dman            ; A = 7/12 - 1
	br    S2AB      
;
; Countdown has expired.  Acc has 15 (" ") in it due to underflow.  If 6/12 bit 1 is reset, the
; display has data in it.  Blank the display with a TDO.  In either case, toggle 6/12 bit 1.
;
	tcmiy 1         ; Reset 7/12 - $1F
	ldx   6         
	tcy   12        
	tbit1 1         ; 6/12 Bit 1 - Display currently blank
	br    S2BA      
	sbit  1         ; Set 6/12 Bit 1 - Display now blank
	tdo             ; Transfer Accumulator to O outputs - Clear display (Load 15 [" "] into LED)
	br    S29A      
S2BA    rbit  1         ; Clear 6/12 Bit 1 - Display now not blank
	br    S2A1      

S2AB    tam             
	ldx   6         
	tcy   12        
	tbit1 1         ; Is display currently blank (6/12 Bit 1 set)?
	br    S29A      ; Bit 1 is set.  Skip update and just delay
;
; Update the LED segments with the contents of 7/14-15
;
S2A1    tma             ; Load 6/12
	tay             ; Save it...
	a8aac           ; Toggle 6/12 bit 3
	br    S2AE      ; It's now clear; we want the Status Latch set to 1
	tay             ; It's now set; we want the Status Latch set to 0
S2AE    ynea            ; Update Status Latch to select correct LED segment based on prior steps
	tcy   12        
	tam             ; Update 6/12 with the new state of 6/12 Bit 3
	ldx   7         
	tcy   14        ; Select 7/14
	a8aac           ; Flip bit 3 of Accumulator BACK to test it (from the earlier work on 6/12)
	br    S2B6      ; There was a carry, we have the right segment (Bit 3 was set)
	tcy   15        ; Switch to 7/15 (Bit 3 was clear)
S2B6    tma             ; Pick up value in the referenced LED display buffer
	tdo             ; Transfer Accumulator to O outputs - Update the LED display

;
; Display has been updated; delay for 255 loops and return
;
S29A    tcy   15        
	tya             
S2A9    dyn             
	br    S2A9      
	dan             
	br    S2A9      
	retn            
;
; Used by read keyboard routine
;
L2A2    tdo             
	ldx   6         
	tcy   15        
	tmy             
	retn            
;
; Copy 5/2-0 to 7/2-0
;
L28C    tcy   2         
S299    ldx   5         
	tma             
	ldx   7         
	tamdyn          
	br    S299      
	retn            
;
; This code looks to be unused...  Odd.  There's also a chunk of code
; like this at SFD4
;
; Values are 65 25 80 94
;
S294    tcmiy 10        
	tamiyc          
	br    REFRLED   
	br    S294      

; *** Chapter 0 page 11

;
; Group of routines to rotate buffer of four two-word values at 5/8-1 by
; 6, 4 and 2 positions
;
L2C0    call  ROL5      
	call  ROL5      
L2C3    call  ROL5      
	call  ROL5      
L2CF    call  ROL5      

ROL5    ldx   5         
	tcy   8         
	tma             

S2FD    dyn             
	xma             
	ynec  1         
	br    S2FD      
	tcy   8         
	tam             
	retn            

L2F3    tcy   2         
S2E7    ldx   7         
	tma             
	ldx   5         
	tamdyn          
	br    S2E7      
	retn            
;
; Rotate the buffer of five 2-digit Base10 values left at 7/1-10.  Keep track of
; the position at 7/11.  Value at 7/11 is 1-5.
;
L2D6    ldx   7         
	tcy   11        
	tma             ; Save the current position
;
; Limit the range of 7/11 to 0-4 (concerned someone futzed with it?)
;
	a11aac          
	br    S2C5      
	a5aac           
S2C5    iac             ; Advance the position
	tamdyn          ; Save Acc at 7/11
	call  S2EE      ; Rotate all of the values in 7/10-1 left (twice)
S2EE    tma             
	dyn             
S2F8    xma             
	dyn             
	ynec  0         
	br    S2F8      

	tcy   10        ; Finish up by copying what was in 7/1 to 7/10
	tam             

	retn            

;
; Called during Bazaar visit
;
L2ED    ldp   3         
;
; Generate a random number from 0-9 and add it to 17
; Results in 5/1 and 5/2
;
	call  RANDOM    ; Generate a random number in A; return with Y=2
	ldx   4         
	tamdyn          ; 4/2 = ACC
	tcmiy 0         ; 4/1 = 0
	rbit  3         ; 4/2 = 4/2 & 0b0111
	ldx   5         
	tcy   1         
	tcmiy 1         ; 5/1 = 1
	tcmiy 7         ; 5/2 = 7
	ldp   4         
	call  AD2B10    

	ldp   1         
	tpc             
	ldp   12        
	br    CPY5TO4   
L2E5    ldx   3         
	tcy   1         
	ldp   14        
S2EA    tbit1 1         
	br    L2BINIT   
	br    BRGDONE      
	tka             
	tdo             

; *** Chapter 0 page 12

;********************************************************************************
; SU2B10 - Perform Base 10 subtraction on values in scratchpad RAM 4/1-2 and 5/1-2
;
;          Subtract the two-digit base 10 number encoded in 4/1 and 4/2 from
;          the two-digit base 10 number encoded in 5/1 and 5/2 giving
;          a two-digit base-10 number encoded in 5/1 and 5/2
;
;          For example:   1 2
;                       4 1 9
;                       5 2 2
;
;          Returns:       1 2
;                       4 1 9
;                       5 0 3
;********************************************************************************
SU2B10  ldx   5         
	tcy   0         
	tcmiy 0         ; 5/0 = 0
L307    ldx   4         
	tcy   0         
	tcmiy 0         ; 4/0 = 0
L33F    cla             
	tcy   2         
S33D    ldx   4         
	amaac           
	ldx   5         
	saman           ; A = 5/Y - 4/Y (Y = 2-0)
	br    S335      ; Branch if no borrow
	a10aac          
	tamza           ; 5/Y = A + 10
	iac             
S327    dyn             
	br    S33D      
	tcy   0         
	retn            

S335    tamza           
	br    S327      
;
; Display key awarded
;
L316    ldx   4         
	tcy   4         
	tam             ; 4/4 = A
	tcy   3         ; Gold Key/Silver Key/Brass Key
	ldp   8         
	call  ROTDRUM   
	ldx   4         
	tcy   4         
	tma             ; A = 4/4
	ldp   9         
	a14aac          ; A = A + 14
	br    LTTOPCL   ; On overflow, light Gold Key and clear the display
	iac             
	br    LTMIDCL   ; Light Silver Key and clear display
	br    LTLWRCL	; Light Brass Key and clear display
;
; Copy 5/1 and 5/2 to 3/12 and 3/13 - Brigand count for fight
; 
L30D    ldx   5         
	tcy   1         
	tma             ; A = 5/1
	ldx   3         
	tcy   12        
	tam             ; 3/12 = A
	ldx   5         
	tcy   2         
	tma             ; A = 5/2
	ldx   3         
	tcy   13        
	tam             ; 3/13 = A
	retn            

;
; Continue setting up for Level 4
;
S309    ldx   2         
	tam             ; 2/3 = 15 - Give player all keys and ??? about the frontier
	ldx   1         
	tamiyc          ; 1/3 = 15 - Give player all items (Sword, Scout, Healer, Beast)
	iyc             
	iyc             
	ynec  15        ; Have we done all players?
	br    S309      ; Nope, go back and do the next player
	ldx   5         
	tcy   14        
	tcmiy 2         ; 5/14 = 2 - First key  - 2 = Gold
	tcmiy 1         ; 5/15 = 1 - Second key - 1 = Silver
	ldp   13        
	br    L36C      ; Carry on with game setup


; *** Chapter 0 page 13

;
; Continue new game initialization
;
L340    ldx   3         
	tcy   14        
	tam             ; Update Dark Tower brigand 10s digit from math
	ldx   5         
	tcy   2         
	tma             
	ldx   3         
	tcy   15        
	tam             ; Update Dark Tower Brigand 1s digit from math
	ldp   8         
	call  RND0TO2   
	ldx   5         
	tcy   14        
	tam             ; Set Dark Tower first key value
S379    ldp   8         
	call  RND0TO2   
	ldx   5         
	tcy   14        
	mnea            ; Make sure we didn't get the same key twice
	br    S36B      
	br    S379      ; We did; try again
S36B    tcy   15        
	tam             
;
; Game setup - Select number of players
;
L36C    ldx   7         
	tcy   14        
	tcmiy 12        ; 7/14 = 12 ("P")
	tcmiy 1         ; 7/15 = 1 ("1")
S342    ldp   7         
	call  PROMPT      
	ldx   7         
	ynec  8         ; Did they hit anything other than "No/End"?
	br    S36D      ; Yes, check to see if they hit "Yes/Buy"
	tcy   15        
	tma             ; Get the current player count from the display (7/15)
	a12aac          ; Add 12 (overflow to 0 if it's 4)
	br    S34D      ; It overflowed...
	a4aac           ; It didn't overflow, add 4 to get it back to the original value
S34D    iac             ; Add one player
	tam             ; Update display
	br    S342      

S36D    ynec  0         ; Did they hit anything other than "Yes/Buy"?
	br    S342      ; Yes.  Prompt again
	tcy   15        ; They hit "Yes/Buy"
	tma             ; Pick up the player count from the display (7/15)
	ldx   3         
	tcy   9         
	tam             ; Save the player count in 3/9
	ldp   3         
	tpc             
	ldp   0         
	call  PLYTHEM   ; Play the Dark Tower theme song
	ldp   1         
	tpc             
	ldp   0         
	br    NEWTURN   
;
; Set the game up for Level 4 play
;
L4INIT  ldx   3         
	tcy   14        
	tcmiy 1         ; 3/14 = 1 (Dark tower brigand count 10s digit)
	tcmiy 6         ; 3/15 = 6 (Dark tower brigand count 1s digit)
	cla             
	dan             
	tcy   3         
	ldp   12        
	br    S309      

; *** Chapter 0 page 14

;********************************************************************************
; Initialize player inventory information for new game (continued)
;********************************************************************************
L380    ldp   15        
	ynec  13        ; On to next player; done with all 4 players?
	br    L3E5      ; No, fill in the next player

	ldx   3         
	tcy   0         
	tcmiy 1         ; 3/0 = 1
	tcmiy 2         ; 3/1 = 2
	tcmiy 4         ; 3/2 = 4
	tcmiy 0         ; 3/3 = 0 - Turn number 10s
	tcmiy 0         ; 3/4 = 0 - Turn number 1s
	tcmiy 0         ; 3/5 = 0 - Dragon treasure Warriors 10s
	tcmiy 2         ; 3/6 = 2 - Dragon treasure Warriors 1s
	tcmiy 0         ; 3/7 = 0 - Dragon treasure Gold 10s
	tcmiy 6         ; 3/8 = 6 - Dragon treasure Gold 1s
	tcy   11        
	tcmiy 0         ; 3/11 = 0 - Current player
;
; Handle level selection
;
	ldx   7         
	tcy   14        ; Reference display 10s digit (7/14)
	tcmiy 13        ; 7/14 = 13 ("L")
	tcmiy 1         ; 7/15 = 1 ("1")
S3B5    ldp   7         
	call  PROMPT    ; Display flashing "L1" and wait for keypress
	ldx   7         
	ynec  8         ; Did user hit "No"?
	br    S3B8      ; Nope, they hit something else.  This is the level they want to play
	tcy   15        
	tma             ; Pick up the currently selected level
	a12aac          ; Add 12 to see if there's an overflow
	br    S397      ; There was, ACC is now 0
	a4aac           ; Nope, add four more effectively doing a MOD 4
S397    iac             ; Increment ACC to select next level
	tam             ; Update 1s digit on display
	br    S3B5      
S3B8    ynec  0         ; Did the user hit "Yes"?
	br    S3B5      ; Nope, go prompt again at the same level
	tcy   15        ; Pick up the level selected
	tma             ; and store it in the Accumulator
	ldp   13        
	a12aac          ; Add 12 to accumulator (See if it's level 4)
	br    L4INIT    ; Handle Level 4 separately (special conditions--see manual page 39)
	ldp   4         
	call  L130      ; Load 17 + a random number into 5/1 and 5/2 - Base Brigand count for Levels 1 and 4
	ldx   7         
	tcy   15        
	tma             ; Pick up the level selected
	ldp   11        
	a13aac          ; n = Level + 13 - Is this level 3 or 4? (n = 16 or 17)
	br    L2E5      ; If there was a carry, branch and deal with it
	ldp   14        ; Level < 3
	iac             ; n = n + 1 - Generate a carry if it's level 2
	br    L2BINIT   ; On carry, branch and deal with level 2; otherwise, set status=1
	br    BRGDONE   ; There wasn't a carry.  We're done calculating Brigands
L2BINIT ldx   3         
	tcy   1         
	ldp   4         
	tbit1 0         
	call  ADD16     ; Add 16 to 5/1-5/2 if bit 0 of 3/1 is set
	ldp   4         
	call  ADD16     ; Add 16 more to 5/1-5/2
BRGDONE ldx   5         
	tcy   1         
	tma             
	ldp   13        
	br    L340      

; *** Chapter 0 page 15

;********************************************************************************
; INIT - Called on power-up
;********************************************************************************
INIT    tcy   0         
S3C1    ldx   0         
	tka             
	ynea            
	tdo             
	tay             
	setr            
	rstr            
	knez            
	br    S3C1      
	ldx   7         
	tcy   14        ; Reference display 10s digit
	tcmiy 14        ; 7/14 = 14 ("-")
	tcmiy 14        ; 7/15 = 14 ("-")
	ldp   7         
	call  PROMPT    ; Display flashing "--" and wait for keypress
	ldp   1         
	call  L040      

	ldx   0         
	tcy   0         
	tcmiy 8         ; 0/0 = 8 - Last display position 8=unknown?
	ldx   1         
	tcy   0         
	tcmiy 15        ; 1/0 = 15
	ldx   2         
	tcy   0         
	tcmiy 15        ; 2/0 = 15
	tcy   0         
	ldp   8         
	call  ROTDRUM   ; Cycle display to position 0 - on return, 0/0=0; 1/0=4; 2/0=12
	ldx   7         
	tcy   14        ; Reference display 10s digit
	tcmiy 8         ; 7/14 = 8 ("8")
	tcmiy 8         ; 7/15 = 8 ("8")
	ldp   9         
	call  L241      ; Display 88, light top display light and beep
	ldp   9         
	call  L25F      ; Light middle display light and beep
	ldp   9         
	call  L27B      ; Light lower display light and beep
;********************************************************************************
; Initialize player inventory information for new game
;
; 30 Gold, 25 Food and 10 Warriors
;********************************************************************************
L3ED    ldx   0         
	tcy   1         ; X = 0, Y = 1 - Player 1 Gold and ???
S3F4    tcmiy 3         ; Set Gold 10s to 3
	tcmiy 0         ; Set Gold 1s to 0
	tcmiy 2         ; Set ??? to 2
	ynec  13        ; On to next player; done with all 4 players?
	br    S3F4      ; No, fill in the next player

	ldx   1         ; X = 1, Y = 1 - Player 1 Food and inventory pt 1
	tcy   1         
S3C4    tcmiy 2         ; Set Food 10s to 2
	tcmiy 5         ; Set Food 1s to 5
	tcmiy 0         ; Set Inventory pt 1 to 0 (No Scout - 1000, Sword - 0100, Healer - 0010, Beast - 0001)
	ynec  13        ; On to next player; done with all 4 players?
	br    S3C4      ; No, fill in the next player

	ldx   2         ; X = 2, Y = 1 - Player 1 Warriors and inventory pt 2
	tcy   1         
L3E5    tcmiy 1         ; Set Warriors 10s to 1
	tcmiy 0         ; Set Warriors 1s to 0
	tcmiy 0         ; Set Inventory pt 2 to 0 (No Gold key - 1000, No Silver key - 0100, No Brass key - 0010, ??? - 0001)
	ldp   14        
	br    L380      ; Ran out of ROM in this page...
S3E8    tamiyc          
	tya             
	br    S3E8      

; *** Chapter 1 page 0

;
; Main gameplay loop?
;
L400    ldp   3         
	tpc             
	ldp   13        
	call  PLYBEEP   

;********************************************************************************
; ENDTURN - Prompt for player EOT
;********************************************************************************
ENDTURN ldx   3         
	tcy   11        
	tma             ; Pick up current player
	ldx   7         
	tcy   14        
	tcmiy 14        ; 7/14 = 14 ("-")
	tam             ; 7/15 = Current Player
	ldp   0         
	tpc             
	ldp   7         
	call  PROMPT    ; Update display from 7/14-15 and wait for keypress
	ynec  4         ; Did they hit Repeat (4)?
	br    S435      ; Nope...
;
; Player hit Repeat
;
	ldp   12        
	call  CALLDSP   ; Display results from last turn again
	br    ENDTURN   

S435    ynec  9         ; Did they hit Clear (9)?
	br    S418      ; Nope...
;
; Player hit Clear
;
	ldp   1         
	br    DOCLEAR   

S418    ynec  8         ; Did they hit No/END
	br    ENDTURN   ; Nope, go back and prompt again
	ldp   3         
	tpc             
	ldp   3         
	call  PLAYEOT      
;
; Begin next player's turn
;
NEWTURN ldx   4         
	tcy   12        
	rbit  0         ; 4/12 Bit 0 = 0
	ldp   0         
	tpc             
	ldp   8         
	call  L200      ; Advance the next player's data into the active slot
	a14aac          
	br    S426      
	ldp   14        
	call  CPYTRNC   ; Get the turn counter into 5/1-2
	ldx   4         
	tcy   1         
	tcmiy 0         
	tcmiy 1         
	ldp   12        
	call  ADDB10    ; Add 1 to what was in 3/3-4
	ldp   14        
	mnez            ; Is 5/0 non-zero (2-digit overflow?)
	call  LOAD99    ; 5/1 = 9; 5/2 = 9
	ldp   14        
	call  CPYTRNC   ; Save the results of the math back to the turn counter at 3/3-4
;
; Update display with current player
;
S426    ldx   3         
	tcy   11        
	tma             ; Pick up current player from 3/11
	ldx   7         
	tcy   14        
	tcmiy 15        ; 7/14 = 15 (" ")
	ldp   1         
	br    L440      

L414    ldx   4         
	tcy   12        
	sbit  0         ; 4/12 Bit 0 = 1.  Player was lost but had a Scout.
	br    S426      


; *** Chapter 1 page 1

L440    tam             
;
; Get player move
;
S441    ldp   0         
	tpc             
	ldp   7         
	call  PROMPT      
;
; Process input
;
; First, handle non-move buttons.  Either invalid keys or Clear
;
	ynec  0         ; Did they hit Yes/Buy?
	br    S47D      ; Nope
	br    S441      ; Yes - Error; prompt again

S47D    ynec  8         ; Did they hit No/End?
	br    S46F      ; Nope
	br    S441      ; Yes - Error; prompt again

S46F    ynec  4         ; Did they hit Repeat?
	br    S479      ; Nope
	br    S441      ; Yes - Error; prompt again

S479    ynec  1         ; Did they hit Haggle?
	br    S44E      ; Nope
	br    S441      ; Yes - Error; prompt again

S44E    ynec  9         ; Did they hit Clear?
	br    DOBUTTN   ; Nope.  Process the button pressed
;
; Player hit Clear.  Deal with it
;
	ldx   4         
	tcy   12        
	tbit1 0         ; Check to see if this is still the beginning of their turn
	br    DOCLEAR   ; Nope
	br    S441      ; Yeah, beginning of turn--Clear does nothing
;
; Handle player hitting Clear to clear up an illegal move
;
; Restore the saved copy of the player's inventory and status from 0/13-15, 1/13-15 and 2/13-15
; and start the next player's turn.
;
DOCLEAR ldx   0         
	call  S446      
	ldx   1         
	call  S446      
	ldx   2         
	call  S446      
	ldp   3         
	tpc             
	ldp   14        
	call  PLYCLR    
	ldp   0         
	br    NEWTURN   
;
; Restore saved player information to recover from illegal move
;
S446    tcy   13        
	tma             
	tcy   1         
	tam             
	tcy   14        
	tma             
	tcy   2         
	tam             
	tcy   15        
	tma             
	tcy   3         
	tam             
	retn            
;
; Player has hit a button to make a move of some sort
; First, initialize the encounter results 4/13-15 to "No changes"
; (all flags set)
;
DOBUTTN ldx   4         
	tcy   13        
	tcmiy 15        ; 4/13 = 0b1111 - Beast/Gold/Food/Warriors unchanged
	tcmiy 15        ; 4/14 = 0b1111 - Silver key/Brass key/Healer/Scout not found this round
	tcmiy 15        ; 4/15 = 0b1111 - ???/Pegasus/Sword/Gold key not found this round
	ldx   0         
	tcy   3         
	ldp   2         
	tbit1 1         ; Player status flag at 0/3 - bit 1 - Cursed when clear
	br    L4B7      
;
; Player was cursed (0/3 bit 1 is clear).  Provide status update to player.
;
	ldx   4         
	tcy   13        
	tcmiy 10        ; 4/13 = 0b1010 - Gold and Warriors have changed
	ldp   9         
	br    L66A      ; Player was cursed - rotate drum to Cursed/Lost/Plague then branch back to L480


; *** Chapter 1 page 2

;
; Display Cursed!
;
L480    tcy   7         ; Select upper lamp
	setr            ; Turn it on
	ldp   3         
	tpc             
	ldp   0         
	call  LC13      ; Play the "lose round of battle" sound
	tcy   7         ; Select upper lamp
	rstr            ; Turn it off
	ldp   12        
	call  CALLDSP   ; Display results
;
; Determine how much food the warriors consumed this turn
;
; 15 Warriors or less consume 1 food per turn
; 16-30 Warriors consume 2 per turn
; 31-45 Warriors consume 3 per turn, etc.
;
L4B7    ldp   6         
        call  CPY2TO5   ; Copy current player Warrior count to 5/1-2
	ldx   4         
	tcy   1         
	tcmiy 1         ; 4/1 = 1
	tcmiy 6         ; 4/2 = 6 - Start by subtracting 15
	tcmiy 2         ; 4/3 = 2 - contains the amount of food consumed
;
; Loop through, repeatedly subtracting until there's a borrow.  Basically, divide by 15 (kind of, as the first iteration was 16)
; to determine how much food was consumed.
;
S48E    ldp   12        
	call  SUBB10    ; Subtract value in row 4 from Warrior count - first time 16; afterward 15
	mnez            ; Was there a borrow in the subtraction routine?  (5/0 will be 9)
	br    S48B      ; Yes.  We're done
;
; No borrow, add one food to counter and set up to subtract 15 more warriors
;
	ldx   4         
	tcy   3         
	imac            
	tam             ; Increment 4/3 - We had no borrow so add another food consumed this round
	ldx   4         
	tcy   2         
	tcmiy 5         ; 4/2 = 5 - Subtract 15 on the second and subsequent iterations
	br    S48E      ; Subtract again
;
; There was a borrow; we're done with the subtract loop (aka division).  4/3 has how much food was consumed + 1
;
S48B    ldx   1         
	tcy   3         
	tbit1 0         ; Beast in player inventory?
	ldx   4         
	dman            ; Pick up 4/3 and subtract 1
	tam             ; Save corrected food consumed
;
; Set up to subtract food consumed from player's food inventory
;
	ldx   4         
	tma             ; Pick up food consumed (again?)
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	tam             ; Store food consumed in 4/2
	ldp   12        
	call  CPY1TO5   ; Copy current player Food count to 5/1-2
	ldp   12        
	call  SUBB10    ; Subtract food consumed from food count
	mnez            ; Was there a borrow during subtraction?
	call  S494      ; Yep.  We're at negative food, set it back to 00
	ldp   10        
	call  CPY5TO1   ; Update player food inventory from math results in 5/1-2
;
; Now, deal with soldiers dying from starvation if applicable
;
	ldx   5         
	tcy   0         
	ldp   3         
	mnez            ; Check 5/0 for borrow
	br    L4C0      ; Yep.  Warriors died; play the death march and update counts
;
; Nobody died...
;
	ldx   4         
	tcy   3         
	tma             ; Pick up how much food was consumed from 4/3
	tcy   1         ; Prep for doing the math
	tcmiy 0         ; 4/1 = 0
	tamdyn          ; 4/2 = consumed food
	br    L4EF      ; Check to see if the low food warning should be played

S494    tcy   1         
	tcmiy 0         
	tcmiy 0         
	retn            


; *** Chapter 1 page 3

;
; Handle warrior starvation
;
L4C0    ldx   4         
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	tcmiy 1         ; 4/2 = 1
	ldp   5         
	call  SUBWARR   
	ldp   3         
	tpc             
	ldp   11        
	call  PLYDETH   
	br    S4F8      
;
; Determine if the Low Food warning should be played by multiplying the consumed food by 4
; and subtracting it from the player's current inventory
;
L4EF    ldx   5         
	tcmiy 0         ; 5/1 = 0
	tam             ; 5/2 = consumed food
	ldp   12        
	call  ADDB10    ; Double consumed food
	ldp   12        
	call  CPY5TO4   ; Copy total to 4/1-2
	ldp   12        
	call  ADDB10    ; Double it again
	ldp   12        
	call  CPY5TO4   ; Copy it
	ldp   12        
	call  CPY1TO5   ; Pick up player food
	ldp   12        
	call  SUBB10    ; Subtract food from total player food
	mnez            ; Check for borrow
	br    S4CB      ; Yep, play the low food warning
	br    S4F8      ; Nope carry on
;
; Play the low food warning
;
S4CB    ldp   3         
	tpc             
	ldp   14        
	call  PLWFOOD   
;
; Save current player information into save buffer
;
S4F8    ldx   0         
	call  S4D3      
	ldx   1         
	call  S4D3      
	ldx   2         
	call  S4D3      
;
; Check to see if player was cursed.  If so, clear the curse and end their turn.
;
	ldx   0         
	tcy   3         
	tbit1 1         ; Was player cursed (0/3 bit 1 clear)?
	br    S4C8      ; Nope - bit 1 was set
	sbit  1         ; Clear the curse and end their turn
	ldp   0         
	br    ENDTURN   

S4C8    ldx   6         
	tcy   15        
	tmy             ; See what key was pressed
	ldp   4         
	br    L500      
;
; Copy current player information into save buffer
;
S4D3    tcy   1         ; Copy X/1 to X/13
	tma             
	tcy   13        
	tam             
	tcy   2         ; Copy X/2 to X/14
	tma             
	tcy   14        
	tam             
	tcy   3         ; Copy X/3 to X/15
	tma             
	tcy   15        
	tam             
	retn            


; *** Chapter 1 page 4

;
; Handle Move being pressed
;
L500    ynec  6         
	br    S50F      
	ldp   7         
	br    DOMOVE    
;
; Handle Sanctuary/Citadel being pressed
;
S50F    ynec  10        
	br    S53D      
	ldp   12        
	br    DOSANCT   
;
; Handle Frontier being pressed
;
S53D    ynec  7         ; Did they hit the Frontier button?
	br    S523      
	ldp   3         
	tpc             
	ldp   8         
	call  PLYFRNT   
;
; Handle determining whether they've found the key in this region or not
;
; There's no real magic to the Frontier thing.  The entirety of it is the "KeyNotFound" flag at 2/3 bit 0.  If
; it's set to 1, the key hasn't been found yet and you can still be awarded a key.  If it's set to 0, the key
; has been found and you won't be awarded a key as loot.  The Frontier button simply checks this flag; if it's
; set, you get a Key Missing.  If it's cleared, it gets set.
;
	ldx   2         
	tcy   3         
	tbit1 0         ; If bit 0 is set the key hasn't been found yet
	br    S52B      ; It was set - Key missing
	sbit  0         ; Reset Key not found (move us to a new region)
S53A    ldp   0         
	br    ENDTURN   ; End the turn
S52B    imac            ; Increment key flags and load into accumulator
	br    S53A      ; Overflow - They have all of the keys already; they can go to any territory
;
; Handle showing Key Missing
;
KEYMISS tcy   5         ; Wizard/Bazaar Closed/Key Missing
	ldp   10        
	call  ROTDRM2   
	tcy   5         ; Select lower map
	setr            ; Turn it on
L505    ldp   3         
	tpc             
	ldp   11        
	call  PLYFAIL   
	tcy   5         ; Select lower lamp
	rstr            ; Turn it off
	br    S53A      ; End their turn
;
; Handle Inventory being pressed
;
S523    ynec  11        ; Did they hit Inventory?
	br    S529      ; Nope
	ldx   4         
	tcy   13        
	tcmiy 0         ; No changes for this round (4/13-14 = 0)
	tcmiy 0
	ldp   12        
	br    L70D      ; Put a 12 in 4/15 then run through the inventory
;
; Player is doing an activity that resets the "Citadel visited" flag; reset it
;
S529    tya             
	ldx   0         
	tcy   3         
	rbit  0         ; Reset 0/3 Bit 0 "Citadel visited" flag
	tay             
;
; Handle Tomb/Ruin being pressed
;
	ynec  2         ; Did they hit Tomb/Ruin?
	br    S519      ; Nope
	ldp   2         
	tpc             
	ldp   3         
	br    L8D9      
;
; Handle Bazaar being pressed
;
S519    ynec  5         ; Did they hit Bazaar?
	br    S514      ; Nope
	ldp   2         
	tpc             
	ldp   10        
	br    LA98      
;
; All that's left is Dark Tower, handle it
;
S514    ldp   2         
	tpc             
	ldp   10        
	br    LAA7      

; *** Chapter 1 page 5

;********************************************************************************
; SUBWARR - Warriors have died.  Subtract count in 4/1-2 from player forces
;********************************************************************************
SUBWARR ldp   6         
;
; Copy current player's Warrior count into 5/1-2; subtract the deaths and update their count
;
	call  CPY2TO5   
	ldp   12        
	call  SUBB10    
	ldp   12        
	call  CPY5TO2   
;
; Subtract one more warrior and see if the count goes negative, if so, the current player
; is out of warriors.  Deal with the situation appropriately.
;
	ldx   4         
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	tcmiy 1         ; 4/2 = 1
	ldp   0         
	tpc             
	ldp   12        
	call  L307      ; Do a subtraction without clearing 5/0 (borrow)
	mnez            ; Check borrow (negative warriors?)
	br    S56C      ; Yep.  Everyone died.

S567    ldp   6         
	br    L5BB      ; Go figure out how much Gold the remaining Warriors can carry
;
; Multiplayer game and player has lost all of their warriors.  Give them one.
;
S55D    ldx   2         
	tcy   1         
	tcmiy 0         ; 2/1 = 0
	tcmiy 1         ; 2/1 = 1
	br    S567      ; Carry on...
;
; Warrior count is negative; deal with it appropriately
;
S56C    ldx   3         
	tcy   9         ; 3/9 = player count
	tma             ; Pick up number of players
	a14aac          ; Add 14 (2+ players)
	br    S55D      ; This isn't a single-player game
;
; Single player game - they lost all of their warriors so they lose with a score of 00
;
	tcy   6         ; Victory/Warrior/Brigand
	ldp   10        
	call  ROTDRM2   
	tcy   6         ; Select middle lamp
	setr            ; Light it
	ldp   3         
	tpc             
	ldp   11        
	call  PLYDETH   
	tcy   6         ; Select middle lamp
	rstr            ; Turn it off
	ldx   5         
	tcy   1         
	tcmiy 0         ; 5/1 = 0
	tcmiy 0         ; 5/2 = 0
L569    ldp   0         
	tpc             
	ldp   8         
	call  BUF2DSP   ; Update display buffer with contents of 5/1 and 5/2 (Display "00")
	ldp   14        
	br    L7B2      ; Prompt the player and end the game

;********************************************************************************
; SUBGOLD - Subtract the number of bags of gold in 4/1-2 from the player's hoard
;********************************************************************************
SUBGOLD ldp   12        
	call  CPY0TO5   
	ldp   12        
	call  SUBB10    
	mnez            
	call  S54A      
	ldp   12        
	br    CPY5TO0   
S54A    tcy   1         
	tcmiy 0         
	tcmiy 0         
	retn            

	tma             
	tdo             
	iyc             

; *** Chapter 1 page 6

;********************************************************************************
; ADDGOLD - Add the number of bags of gold in 4/1-2 to the player's hoard
;********************************************************************************
ADDGOLD ldp   12        
	call  CPY0TO5   
	ldp   12        
	call  ADDB10    
	ldp   14        
	mnez            
	call  LOAD99    
	ldp   12        
	call  CPY5TO0   
;
; Multiply Warrior count by 6 to determine how much gold they can carry
;
L5BB    ldp   6         
	call  CPY2TO5   ; 5/1-2 = Warrior count
	ldp   12        
	call  CPY5TO4   ; 4/1-2 = Warrior count
	ldp   12        
	call  ADDB10    ; 5/1-2 = Warrior count + Warrior count = Warrior count x 2
	ldp   12        
	call  CPY5TO4   ; 4/1-2 = Warrior count x 2
	ldp   0         
	tpc             
	ldp   4         
	call  SUMB10    ; 5/1-2 = Warrior count x 2 + Warrior count x 2 = Warrior count x 4
	ldp   0         
	tpc             
	ldp   4         
	call  SUMB10    ; 5/1-2 = Warrior count x 2 + Warrior count x 4 = Warrior count x 6
;
; 5/0-2 now has the maximum gold that can be carried
;
	ldx   1         
	tcy   3         
	tbit1 0         ; Do they have a Beast?
	br    S588      ; Yep - add 50 to capacity

S58B    ldx   5         
	tcy   0         
	mnez            ; Was there a Base10 overflow (Warrior count x 6 + 50 for beast if any > 99)?
	br    S5A4      ; Yeah, the warriors can carry more than 99 bags of gold; we're done

	ldp   12        
	call  CPY5TO4   ; 4/1-2 = Max gold carried
	ldp   12        
	call  CPY0TO5   ; 5/1-2 = Current gold
	ldp   12        
	call  SUBB10    ; Subtract carrying capacity from current gold
	mnez            ; Was there a borrow?
	br    S5A4      ; Yes. They have enough capacity
;
; Player's warriors can't carry that much gold.  Update player gold with their carrying capacity
;
	ldp   10        
	call  SWP4ND5   ; 4/1-2 has maximum gold they can carry.
	ldp   12        
	call  CPY5TO0   ; Update player gold

S5A4    retn            
;
; Handle the player having a Beast
;
S588    ldx   4         
	tcy   1         
	tcmiy 5         ; 4/1 = 5
	tcmiy 0         ; 4/2 = 0
	ldp   0         
	tpc             
	ldp   4         
	call  L107      ; Add 50 to the warrior's capacity
	br    S58B      

;********************************************************************************
; CPY2TO5 - Copy 2/2-0 to 5/2-0
;
;           Copy player Warrior count to 5/2-0 to do math on it
;********************************************************************************
CPY2TO5 tcy   2         
S5A5    ldx   2         
	tma             
	ldx   5         
	tamdyn          
	br    S5A5      
	retn            

	mnea            
	mnea            

; *** Chapter 1 page 7

;********************************************************************************
; DOMOVE - Handle random encounters from player hitting the Move button
;********************************************************************************
DOMOVE  ldp   0         
	tpc             
	ldp   3         
	call  RANDOM    
	a13aac          ; Add 13 to result - 0-2 = Lost
	br    S5C6      
;
; Player is Lost 18.75% of the time (on a roll of 0-2 out of 16)
;
	tcy   7         ; Cursed/Lost/Plague
	ldp   10        
	call  ROTDRM2   
	ldx   1         
	tcy   3         
	tbit1 3         ; Do they have a Scout?
	br    S5EC      ; Yes...

	tcy   6         ; Select middle lamp (Lost)
	setr            ; Turn it on
	ldp   3         
	tpc             
	ldp   11        
	call  PLYFAIL   ; LOST!
	tcy   6         ; Select middle lamp
	rstr            ; Turn it off
	ldp   0         
	br    ENDTURN   
;
; Lost but has a Scout
;
S5EC    ldp   0         
	tpc             
	ldp   9         
	call  LTMIDCL   ; Light Lost and clear display
	tcy   2         ; Scout/Healer/Gold
	ldp   10        
	call  ROTDRM2   
	ldp   0         
	tpc             
	ldp   9         
	call  LTTOPCL   ; Light Scout and clear the display
	ldp   0         
	br    L414      
;
; Player wasn't lost; random number was 3-15.  Check for Dragon.
;
S5C6    ldp   9         
	a14aac          ; Add 14 - 0-1 = Dragon 
	br    L65D      
;
; Player encounters a Dragon 10% of the time (on a roll of 3-4 out of 16)
;
	tcy   4         ; Dragon/Sword/Pegasus
	ldp   10        
	call  ROTDRM2   
	tcy   7         
	setr            
	ldp   3         
	tpc             
	ldp   9         
	call  PLYDRGN   ; DRAGON!!!
	tcy   7         
	rstr            
	ldx   1         
	tcy   3         
	ldp   8         
	tbit1 2         ; Do they have a Sword?
	br    L617      ; Yes!  Give them the Dragon's treasure
;
; Player doesn't have a Sword (Dragon defense)
;
	ldp   12        
	call  CPY0TO5   ; Pick up current player Gold
	ldp   10        
	call  SWP4ND5   ; Move current player Gold up in the formula
	ldp   11        
	call  L6C0      ; See how much Gold the dragon takes
	ldp   8         
	br    L600      
	mnea            

; *** Chapter 1 page 8

L600    ldp   11        
	call  SWPDGLD   ; Swap the Dragon's Gold with 5/1-2
	ldp   12        
	call  ADDB10    
	ldp   14        
	mnez            
	call  LOAD99    
	ldp   11        
	call  SWPDGLD   
	ldp   5         
	call  SUBGOLD   
	ldp   6         
	call  CPY2TO5   ; Pick up current player Warriors
	ldp   10        
	call  SWP4ND5   ; Move current player Warriors up in the formula
	ldp   11        
	call  L6C0      ; See how many Warriors the dragon takes
	ldp   10        
	call  SWPDWAR   ; Swap the Dragon's Warriors with 5/1-2
	ldp   12        
	call  ADDB10    
	ldp   14        
	mnez            
	call  LOAD99    
	ldp   10        
	call  SWPDWAR   
	ldp   5         
	call  SUBWARR   
	ldp   9         
	br    L66F      
;
; Player has a sword; reward the Dragon's TREASURE!
;
L617    rbit  2         
	tcy   6         ; Select middle lamp
	setr            ; Turn it on
	ldp   3         
	tpc             
	ldp   9         
	call  PLYDSWD   ; Play the Sword defense sound
	tcy   6         ; Select the middle lamp
	rstr            ; Turn it off
;
; Pick up the Dragon's Warriors from 3/5-6 and add them to the player's forces
;
	ldx   3         
	tcy   5         
	tma             ; Pick up 3/5
	ldx   4         
	tcy   1         
	tam             ; Store it in 4/1
	ldx   3         
	tcy   6         
	tma             ; Pick up 3/6
	ldx   4         
	tcy   2         
	tam             ; Store it in 4/2
	ldp   10        
	call  ADDWARR   ; Add those Warriors to the players forces
;
; Pick up the Dragon's bags of Gold from 3/7-8 and add them to the player's hoard
;
	ldx   3         
	tcy   7         
	tma             ; Pick up 3/7
	ldx   4         
	tcy   1         
	tam             ; Store it in 4/1
	ldx   3         
	tcy   8         
	tma             ; Pick up 3/8
	ldp   9         
	br    L640      

; *** Chapter 1 page 9

L640    ldx   4         
	tcy   2         
	tam             ; Store it in 4/2
	ldp   6         
	call  ADDGOLD   ; Add that gold to the player's hoard
;
; Reset the Dragon's treasure to defaults (2 Warriors, 6 bags of Gold)
;
	ldx   3         
	tcy   5         
	tcmiy 0         ; 3/5 = 0
	tcmiy 2         ; 3/6 = 2 - 2 Warriors
	tcmiy 0         ; 3/7 = 0
	tcmiy 6         ; 3/8 = 6 - 6 bags of Gold
L66F    ldx   4         
	tcy   13        
	tcmiy 10        ; 4/13 = 0b1010 - Gold and Warrior count has changed
L679    ldp   12        
	call  CALLDSP   ; Display player's updated inventory
	ldp   0         

	br    ENDTURN   
;
; Player wasn't Lost or ran into a Dragon; random number was 5-15, check for Plague
;
L65D    ldp   11        
	a13aac          ; Add 13 to result - 0-2 = Plague
	br    L6E5      ; No Plague...
;
; Player gets Plague 18.75% of the time (on a roll of 5-7 out of 16)
;
	tcy   7         ; Cursed/Lost/Plague
	ldp   10        
	call  ROTDRM2   
	ldx   1         
	tcy   3         
	tbit1 1         ; Healer?
	br    S652      ; Yep!

	tcy   5         ; Select lower lamp
	setr            ; Turn it on
	ldp   3         
	tpc             
	ldp   11        
	call  PLYDETH   ; Play the death march
	tcy   5         ; Select lower lamp
	rstr            ; Turn it off
	ldx   4         
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	tcmiy 2         ; 4/2 = 2
	ldp   5         
	call  SUBWARR   ; Kill some warriors
	ldp   10        
	br    L6B2      
;
; Player has a Healer
;
S652    ldp   0         
	tpc             
	ldp   9         
	call  LTLWRCL   ; Light Plague and clear display
	tcy   2         ; Scout/Healer/Gold
	ldp   10        
	call  ROTDRM2   
	ldp   0         
	tpc             
	ldp   9         
	call  LTMIDCL   ; Light Healer and clear display
	ldx   4         
	tcy   1         
	ldp   15        
	br    L7E5      

L66A    tcy   7         ; Cursed/Lost/Plague
	ldp   10        
	call  ROTDRM2   
	ldp   2         
	br    L480      

; *** Chapter 1 page 10

;********************************************************************************
; SWPDWAR - Swap 3/5 <-> 5/1 and 3/6 <-> 5/2 (Dragon's Warrior treasure)
;********************************************************************************
SWPDWAR ldx   3         
	tcy   5         
	tma             
	ldx   5         
	tcy   1         
	xma             
	ldx   3         
	tcy   5         
	tamiyc          
	tma             
	ldx   5         
	tcy   2         
	xma             
	ldx   3         
	tcy   6         
	tam             
	retn            

;********************************************************************************
; ADDFOOD - Add the amount of food in 4/1-2 to the current player's inventory
;********************************************************************************
ADDFOOD ldp   12        
	call  CPY1TO5   
	ldp   12        
	call  ADDB10    
	ldp   14        
	mnez            
	call  LOAD99    
	ldp   10        
	call  CPY5TO1   
	retn            

;********************************************************************************
; SWP4ND5 - Swap 4/2-0 with 5/2-0.
;
; Utility routine used in conjunction with the CPYxTOy for math
;********************************************************************************
SWP4ND5 ldx   4         
	tcy   2         
S68B    tma             
	ldx   5         
	xma             
	ldx   4         
	tamdyn          
	br    S68B      
	retn            

;********************************************************************************
; ADDWARR - Add value in 4/1-2 to current player's Warrior count
;********************************************************************************
ADDWARR ldp   6         
	call  CPY2TO5   ; Pick up player Warrior count
	ldp   12        
	call  ADDB10    ; Add 4/1-2 to the count
	ldp   14        
	mnez            ; Check for overflow (can't exceed 99 warriors)
	call  LOAD99    
	ldp   12        
	br    CPY5TO2   ; Update player Warrior count

;********************************************************************************
; CPY5TO1 - Update player Food after Base10 math
;********************************************************************************
CPY5TO1 tcy   2         
S688    ldx   5         
	tma             
	ldx   1         
	tamdyn          
	ynec  0         
	br    S688      
	retn            
;
; Add Warriors in 4/1-2, mark Warrior count as changed and display results
;
; This is called from Plague when player has a Healer
;
L68C    ldp   10        
	call  ADDWARR   
L6B2    ldx   4         
	tcy   13        
	rbit  0         
	ldp   9         
	br    L679      

;********************************************************************************
; ROTDRM2 - Local copy of ROTDRUM in Chapter 1
;********************************************************************************
ROTDRM2 ldp   0         
	tpc             
	ldp   8         
	br    ROTDRUM   

; *** Chapter 1 page 11

;
; Called with either player Warrior or Gold inventory in 4/1-2
;
; When player has been attacked by the Dragon and doesn't
; have a sword for defense.  Figure out how much the Dragon will take.
;
; Formula is based on how many Warriors or how much Gold player has.  More
; in their inventory means the Dragon takes more.
;
; According to the manual, the dragon takes 1/4 of the player's warriors and gold.
;
L6C0    ldx   4         
	tcy   2         
	tma             ; Take a look at the 1s digit of 4/2
	sbit  0         
	sbit  1         ; Start with 3
	tbit1 2         ; Do they have 4 or more of this
	br    S6FD      ; Yes, leave bit 0 set
	rbit  0         
S6FD    tbit1 3         ; Do they have 8 or more of this
	br    S6EF      ; Yep, leave bit 1 set
	rbit  1         
S6EF    rbit  2         
	rbit  3         

	tcy   1         ; Take a look at the 10s digit at 4/1
	tbit1 0         ; At least 10
	br    S6F1      ; Add 2 more
S6E7    tbit1 1         ; At least 20
	br    S6CB      ; Add 5 more
S6DD    sbit  0         
	sbit  1         
	tbit1 2         
	br    S6EC      
	rbit  0         
S6EC    tbit1 3         
	br    S6E1      
	rbit  1         
S6E1    rbit  2         
	rbit  3         

	retn            

S6CB    tcy   2         
	tma             
	a5aac           
	tamdyn          
	br    S6DD      

S6F1    tcy   2         
	tma             
	a2aac           
	tamdyn          
	br    S6E7      
;********************************************************************************
; SWPDGLD - Swap 3/7 <-> 5/1 and 3/8 <-> 5/2 (Dragon's bags of Gold treasure)
;********************************************************************************
SWPDGLD ldx   3         
	tcy   7         
	tma             
	ldx   5         
	tcy   1         
	xma             
	ldx   3         
	tcy   7         
	tamiyc          
	tma             
	ldx   5         
	tcy   2         
	xma             
	ldx   3         
	tcy   8         
	tam             
	retn            
;
; Player wasn't Lost, ran into a Dragon or got the Plague; random number was 8-15, check for Brigands???
;
L6E5    ldp   0         
	a13aac          ; Add 13 to result - 0-2 = Brigands
	br    L400      ; No encounter the rest of the time (31.25%)
;
; Player gets Brigands 18.75% of the time (on a roll of 8-10 out of 16)
;
	ldp   2         
	tpc             
	ldp   4         
	br    L937      
	mnea            

; *** Chapter 1 page 12

;********************************************************************************
; CPY5TO2 - Copy 5/2-0 to 2/2-0
;********************************************************************************
CPY5TO2 tcy   2         
S701    ldx   5         
	tma             
	ldx   2         
S70F    tamdyn          
	ynec  0         
	br    S701      
	retn            

;********************************************************************************
; CPY5TO0 - Copy 5/2-0 to 0/2-0
;********************************************************************************
CPY5TO0 tcy   2         
S73B    ldx   5         
	tma             
	ldx   0         
	tamdyn          
	ynec  0         
	br    S73B      
	retn            

;********************************************************************************
; CPY5TO4 - Copy 5/2-0 to 4/2-0
;********************************************************************************
CPY5TO4 tcy   2         
S70E    ldx   5         
	tma             
	ldx   4         
	tamdyn          
	br    S70E      
	retn            

;********************************************************************************
; CPY1TO5 - Copy 1/2-0 to 5/2-0
;********************************************************************************
CPY1TO5 tcy   2         
S718    ldx   1         
	tma             
	ldx   5         
	tamdyn          
	br    S718      
	retn            

;********************************************************************************
; CPY0TO5 - Copy 0/2-0 to 5/2-0
;********************************************************************************
CPY0TO5 tcy   2         
S72E    ldx   0         
	tma             
	ldx   5         
	tamdyn          
	br    S72E      
	retn            

;********************************************************************************
; 
;********************************************************************************
L70D    tcmiy 12        
	ldp   12        
	call  CALLDSP   ; Display results
	ldp   0         
	br    ENDTURN   

;********************************************************************************
; ADDB10 - Call the actual Add Base 10 routine (AD2B10)
;********************************************************************************
ADDB10  ldp   0         
	tpc             
	ldp   4         
	br    AD2B10    

;********************************************************************************
; SUBB10 - Call the actual Subtract Base 10 routine (SU2B10)
;********************************************************************************
SUBB10  ldp   0         
	tpc             
	ldp   12        
	br    SU2B10    

;********************************************************************************
; CALLDSP - Local copy of DSPRSLT in Chapter 1
;********************************************************************************
CALLDSP ldp   0         
	tpc             
	ldp   5         
	br    DSPRSLT   

;********************************************************************************
; DOSANCT - Player has hit Sanctuary/Citadel - handle the encounter
;********************************************************************************
DOSANCT ldp   3         
	tpc             
	ldp   5         
	call  PLYSANC      
	ldx   2         
	tcy   3         
	ldp   13        
	imac            ; Load up the Key inventory and add 1.  If it's 0b1111, they're in the final territory
	br    L740      ; There was a carry.  This is a Citadel visit.
	br    L74F      ; Sanctuary visit

; *** Chapter 1 page 13

;
; This is a Citadel visit.  Test 0/3 Bit 0 to see if this is just a repeat visit.
;
L740    ldx   0         
	tbit1 0         ; Are they cheating and trying to revisit the Citadel without a Tomb run?
	br    S759      ; Yep.  Act like this is a Sanctuary visit, bypassing any Warrior bonuses.
	sbit  0         ; Nope.  Flag that the Citadel has been visited and give them bonuses.

;
; Check to see if player is eligible for additional Warriors.
;
; If they have 4 Warriors or less, give them 5-8 more on a Sanctuary run
;
L74F    ldp   6         
	call  CPY2TO5   ; Copy current Warriors
	ldx   4         
	tcy   1         
	tcmiy 9         ; 4/1 = 9
	tcmiy 5         ; 4/2 = 5
	ldp   12        
	call  ADDB10    
	mnez            ; Check for overflow, eligble for more Warriors?
	br    S757      ; Nope, sorry
;
; They had 4 Warriors or less
;
	ldp   0         
	tpc             
	ldp   3         
	call  RANDOM    
	ldx   4         
	tamdyn          ; 4/2 = Random
	tcmiy 0         ; 4/1 = 0
	rbit  3         ; Reduce random value to 0-7
	rbit  2         ; Reduce random value to 0-3
	ldx   5         
	tcy   1         
	tcmiy 0         ; 5/1 = 0
	tcmiy 5         ; 5/2 = 5
	ldp   12        
	call  ADDB10    ; Give a random value of 5-8
	br    S751      
;
; They had 5 or more Warriors, check to see if they have less than 25.
; If so, double their forces (this is a Citadel run).
;
S757    ldp   6         
	call  CPY2TO5   ; Copy current Warriors
	ldx   4         
	tcy   1         
	tcmiy 7         ; 4/1 = 7
	tcmiy 5         ; 4/2 = 5
	ldp   12        
	call  ADDB10    ; Add 75 to player Warrior count
	mnez            ; Overflow?
	br    S759      ; They had more than 24 warriors; sorry.
;
; Check to see if this is a Sanctuary run or a Citadel run based on Key inventory
;
	ldx   2         
	tcy   3         
	imac            ; Check if we're in the final territory (this is a Citadel run)
	br    S764      ; Yep.  Double their warriors
	br    S759      ; Nope, sorry - this is effectively a Sanctuary run
;
; This is a Citadel run and they had 5-24 Warriors; double their forces
;
S764    ldp   6         
	call  CPY2TO5   ; Pick up the Warrior count
;
; Add Warriors (either double for Citadel run or 5-8 more for a Sanctuary run)
;
S751    ldp   12        
	call  CPY5TO4   ; Copy additional Warriors to top of formula
	ldp   10        
	call  ADDWARR   ; Double their forces and update their inventory
	ldx   4         
	tcy   13        
	rbit  0         ; Flag that Warrior count has changed

;
; Check to see if player is eligible for more Gold.
;
; If they have 7 bags or less, give them 9-16 more bags of Gold
;
S759    ldp   12        
	call  CPY0TO5   ; Copy current player's Gold
	ldx   4         
	tcy   1         
	tcmiy 9         ; 4/1 = 9
	tcmiy 2         ; 4/2 = 2
	ldp   14        
	br    L780      
	mnea            
	mnea            

; *** Chapter 1 page 14

L780    ldp   12        
	call  ADDB10    ; Add 92 to player's gold
	mnez            ; Overflow?
	br    S7B7      ; Nope, sorry
;
; Player had 7 bags of gold or less.  Give them 9-16 more.
;
	call  S797      ; Random value of 9-16 in 4/1-2
	ldp   6         
	call  ADDGOLD   ; Add additional bags to player Gold
	ldx   4         
	tcy   13        
	rbit  2         ; Flag that Gold inventory changed

;
; Check to see if the player is eligible for more Food
;
; If they have 5 rations of Food or less, give them
;
S7B7    ldp   12        
	call  CPY1TO5   
	ldx   4         
	tcy   1         
	tcmiy 9         ; 4/1 = 9
	tcmiy 4         ; 4/2 = 4
	ldp   12        
	call  ADDB10    
	mnez            ; Was there an overflow?
	br    S7A1      ; Nope, sorry
;
; Player has 5 or less rations of Food.  Give them 9-16 more.
;
	call  S797      ; Get a random number from 9-16 into 4/1-2
	ldp   10        
	call  ADDFOOD   ; Add the Food to the player inventory
	ldx   4         
	tcy   13        
	rbit  1         ; Flag that Food inventory has changed
;
; Done with Sanctuary/Citadel - show the results
;
S7A1    ldp   12        
	call  CALLDSP   ; Display results
	ldp   0         
	br    ENDTURN   

S797    ldp   0         
	tpc             
	ldp   4         
	br    L129      

LOAD99  tcy   1         
	tcmiy 9         
	tcmiy 9         
	retn            
;********************************************************************************
; CPYTRNC - Copy the turn counter for math 
; 
; Swap 3/3 <-> 5/1 and 3/4 <-> 5/2
;********************************************************************************
CPYTRNC ldx   3         
	tcy   3         
	tma             
	ldx   5         
	tcy   1         
	xma             
	ldx   3         
	tcy   3         
	tamiyc
	tma             
	ldx   5         
	tcy   2         
	xma             
	ldx   3         
	tcy   4         
	tam
	retn            

L7B2    ldp   0         
	tpc             
	ldp   7         
	call  PROMPT      
	ldp   15        
	br    L7D4      
	setr            
	rstr            
	iyc             

; *** Chapter 1 page 15

;********************************************************************************
; PLYOPEN - Play the tomb open sound
;********************************************************************************
PLYOPEN ldx   6         
	tcy   0         
	tcmiy 0         ; 6/0 = 0
	tcmiy 2         ; 6/1 = 2
S7CF    call  S7CB      
	a3aac           
	br    S7FD      
	br    S7EF      
S7FD    tamiyc          
	imac            
	br    S7F2      ; Return
S7EF    tam             
	br    S7CF      

;********************************************************************************
; PLYCLOS - Play the tomb close sound (tomb is empty) and end the turn
;********************************************************************************
PLYCLOS ldx   6         
	tcy   0         
	tcmiy 15        ; 6/0 = 15
	tcmiy 15        ; 6/1 = 15
S7CE    call  S7CB      
	a13aac          
	br    S7C2      
	tamiyc          
	dman            
	tam             
	a13aac          
	br    S7CE      
	ldp   0         
	br    ENDTURN   
S7C2    tam             
	br    S7CE      
;
; Probably play a tick and delay based on contents of 6/0-1
; Used by Tomb open/close routines
;
S7CB    tcy   10        ; Select speaker out
	setr            ; Set the speaker
	ynea            
	ynea            
	ynea            
	ynea            
	ldx   6         
	rstr            ; Reset the speaker
	tcy   0         
	tma             ; A = 6/0
	iyc             
	tmy             ; Y = 6/1
	ldx   7         
S7F4    tam             
	cla             
	a9aac           
S7E4    dan             
	br    S7E4      
	tma             
	dan             
	br    S7F4      
	dyn             
	br    S7F4      
	ldx   6         
	tcy   0         
	tma             
S7F2    retn            
;
; Plague with Healer - add some warriors
;
L7E5    tcmiy 0         ; 4/1 = 0
	tcmiy 2         ; 4/2 = 2
	ldp   10        
	br    L68C      ; Add two Warriors to player's forces and display results

L7D4    ldp   0         
	tpc             
	ldp   15        
	br    L3ED      

; *** Chapter 2 page 0

;
; BRIGANDS!!!  Handle the encounter
;
L800    ldp   15        
	call  LRANDOM   
	ldp   15        
	call  LBE5      
	ldx   4         
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	tam             ; 4/2 = 
	ldp   15        
	call  LBD4      
	ldx   3         
	tcy   1         
	tbit1 3         
	br    S816      
	ldp   4         
	call  LADDB10   
	ldp   1         
	tpc             
	ldp   14        
	mnez            
	call  LOAD99    
	br    S80D      
S816    ldp   0         
	tpc             
	ldp   12        
	call  SU2B10    
	mnez            
	br    S831      
	tcy   1         
	mnez            
	br    S80D      
	tcy   2         
	mnez            
	br    S80D      
S831    tcy   1         
	tcmiy 0         
	tcmiy 1         
S80D    ldp   4         
	call  L913      ; Update the Brigand count from 5/1-2
L836    ldp   3         
	tpc             
	ldp   7         
	call  PLYBUGL   
	ldp   2         
	call  LCPBRIG   ; Copy Brigand count to 5/1-2 for calculations
	ldp   3         
	call  5TODSPB   ; Copy Brigand count to Display Buffer
	tcy   6         ; Victory/Warriors/Brigands
	ldp   9         
	call  ROTDRM3   
	ldp   0         
	tpc             
	ldp   9         
	call  L27B      ; Light the lower window and beep
	ldx   7         
	tcy   14        
	tcmiy 15        ; 7/14 = 15 (" ")
	tcmiy 15        ; 7/15 = 15 (" ")
	ldp   0         
	tpc             
	ldp   9         
	call  L267      
	ldp   1         
	br    L840      

; *** Chapter 2 page 1

;
; Add the count of 
;
L840    ldx   3         
	tcy   12        
	tma             ; Brigand fight count 10s digit
	tcy   13        
	amaac           ; Add the Brigand fight count 1s digit
	br    S87B      
	dan             
	br    S87B      
	retn            

S87B    ldx   6         
	tcy   12        
	rbit  0         
	ldx   7         
	tcy   14        
	tcmiy 15        ; 7/14 = 15 (" ")
	tcmiy 15        ; 7/15 = 15 (" ")
	ldx   3         
	tcy   9         
	tma             ; Pick up player count
	a14aac          ; More than one player?
	br    S85B      ; Yes
S86B    ldp   0         
	tpc             
	ldp   7         
	call  L1F8      
	ynec  8         
	br    S851      
S842    call  S855      
	tcy   6         
	setr            
	ldp   3         
	tpc             
	ldp   11        
	call  PLYDETH   
	tcy   6         
	rstr            
	cla             
	retn            

S85B    ldx   2         
	tcy   1         
	mnez            
	br    S86B      
	tcy   2         
	tma             
	a13aac          
	br    S86B      
	br    S842      
S851    ldp   15        
	call  LRANDOM   
	ldx   5         
	tcy   3         
	tam             
	rbit  3         
	rbit  2         
	ldp   15        
	call  LRANDOM   
	ldp   2         
	br    L880      
S855    ldx   4         
	tcy   1         
	tcmiy 0         
	tcmiy 1         
	ldp   7         
	br    L9D3      ; Call SUBWARR

; *** Chapter 2 page 2

L880    ldx   5         
	tcy   11        
	tam             
	rbit  3         
	rbit  2         
	ldp   15        
	call  LBD4      
	tcy   0         
	tcmiy 0         
	call  LCP5TO4   
	br    S8B9      
S8AF    tam             
	ldp   2         
	call  LSUMB10  
S8B9    ldx   5         
	tcy   3         
	dman            
	br    S8AF      
	call  LCP5TO4   
	call  LCPBRIG   ; Copy Brigand count to 5/1-2 for calculations
	tcy   0         
	tcmiy 0         
	call  LSWP4N5   
	tcy   4         
S898    tam             
	ldp   0         
	tpc             
	ldp   12        
	call  L33F      
	ldp   3         
	dan             
	br    L8FE      
	tcy   11        
	ldp   2         
	dman            
	br    S898      
	tam             
	call  LSWP4N5   
	call  LCP5TO4   
	call  LSUMB10  
	call  LSWP4N5   
	call  LSUMB10  
	call  LSUMB10  
	tma             
	ldp   3         
	br    L8C0      

LSWP4N5 ldp   1         
	tpc             
	ldp   10        
	br    SWP4ND5   

LSUMB10 ldp   0         
	tpc             
	ldp   4         
	br    SUMB10    

LCP5TO4 ldp   1         
	tpc             
	ldp   12        
	br    CPY5TO4   

LCPBRIG ldp   0         
	tpc             
	ldp   9         
	br    CPYBRIG   ; Copy Brigand count to 5/1-2 for calculations

	mnea            
	mnea            

; *** Chapter 2 page 3

L8C0    tcy   1         
	xma             
	tcy   2         
	tam             
	ldp   4         
	call  L913      ; Update the Brigand count from 5/1-2
	br    S8FB      
L8FE    ldp   1         
	call  S855      
S8FB    tcy   6         ; Light middle lamp
	setr            
	call  S8C9      
	ldp   15        
	call  LBD4      
	call  5TODSPB   
	call  S8C8      
	tcy   6         ; Turn off middle lamp
	rstr            
	tcy   5         ; Light lower lamp
	setr            
	call  S8C9      
	ldp   2         
	call  LCPBRIG   ; Copy Brigand count to 5/1-2
	call  5TODSPB   ; Copy Brigand count to display buffer at 7/14-15
	call  S8C8      
	tcy   5         ; Turn off lower lamp
	rstr            
	ldx   5         
	tcy   11        
	imac            
	br    S8C6      
	ldp   3         
	tpc             
	ldp   8         
	call  PLYLOSR   ; Play the "lose round" sound
	br    S8ED      
S8C6    ldp   3         
	tpc             
	ldp   7         
	call  PLYWINR   ; Play the "win round" sound
S8ED    ldp   1         
	br    L840      
5TODSPB ldp   0         
	tpc             
	ldp   8         
	br    BUF2DSP   ; Update display buffer with contents of 5/1 and 5/2
S8C8    ldp   0         
	tpc             
	ldp   9         
	br    L267      

S8C9    ldp   3         
	tpc             
	ldp   14        
	br    LF80      
L8D9    ldp   1         
	tpc             
	ldp   15        
	call  PLYOPEN   
	ldp   4         
	br    L900      

L8D4    ldp   0         
	tpc             
	ldp   12        
	br    L316      ; Display awarded key

; *** Chapter 2 page 4

L900    ldp   15        
	call  LRANDOM   
	a14aac          ; Add 14; is the result 0-1 (12.5%)?
	br    S93D      ; Nope
	ldp   1         
	tpc             
	ldp   15        
	br    PLYCLOS   ; Nothing interesting in Tomb/Ruin--play the close sound

S93D    a6aac           ; Add another 6; was the original value 2-9 (50%)?
	br    S91D      ; Nope
L937    ldp   0         
	call  L800      ; BRIGANDS!
	iac             
	br    S91D      

S939    ldp   1         
	tpc             
	ldp   0         
	br    ENDTURN   
;
; Always give player Gold if Tomb/Ruin has something in it (Brigands or otherwise)
;
S91D    ldp   14        
	call  LB86      ; Randomly award 13-20 Gold
	ldp   7         
	call  L9EA      ; Call ADDGOLD
	ldx   4         
	tcy   13        
	rbit  2         ; Flag that player Gold has changed
	ldp   0         
	tpc             
	ldp   5         
	call  DSPRSLT   ; Display results

	ldp   15        
	call  LRANDOM   
	ldp   5         
	a6aac           ; Add 6; is the value 0-9 (62.5%)?
	br    L97A      ; Nope, maybe give them a Pegasus
;
; Award a key 62.5% of the time
;
	ldx   2         
	tcy   3         ; 2/3 = Current player key inventory and status
	ldp   4         
	tbit1 0         ; Key found in this region yet?
	br    S91A      ; Nope.  Let's give them one

S936    ldp   4         
	br    S939      ; Sorry, sucker.  End the turn

S91A    tma             ; Pick up the current key inventory
	amaac           ; Check to see if they already have the Gold key (8 + 8 = overflow)
	br    S936      ; Yep - end the turn
	tam             ; We doubled the previous value, effectively granting the next key; save it to their inventory
	cla             
	a2aac           ; Accumulator = 2
	ldp   5         
	tbit1 3         ; Do they have the Gold key now?
	br    L96F      ; Yep, they must have just gotten it - show it as an award
	br    L940      

L913    ldp   0         
	tpc             
	ldp   12        
	br    L30D      ; Copy 5/1-2 to 3/12-13 - Results of Brigand math to Brigand count

L932    ldp   1         
	tpc             
	ldp   5         
	br    L569      ; Update the display with the current Brigand count

;********************************************************************************
; LADDB10 - Call the AD2B10 routine - Local to chapter 2
;********************************************************************************
LADDB10 ldp   0         
	tpc             
	ldp   4         
	br    AD2B10    
	mnea            

; *** Chapter 2 page 5

L940    dan             
	tbit1 2         ; Do they have the Silver key now?
	br    S973      ; Yep, they must have just gotten it, as they didn't have the Gold key - show it as an award
;
; Award a Brass key since it wasn't the Gold or Silver keys
;
	cla             
	ldx   4         
	tcy   14        
	rbit  2         ; Brass key flag
;
; Treasure included a key - handle it
;
S97E    ldp   3         
	call  L8D4      ; Display the key awarded
S97B    ldp   4         
	br    S939      ; ...and end the turn
;
; Award a Gold key
;
L96F    ldx   4         
	tcy   15        
	rbit  0         ; Gold key flag
	br    S97E      
;
; Award a Silver key
;
S973    ldx   4         
	tcy   14        
	rbit  3         ; Silver key flag
	br    S97E      
;
; Award a Pegasus?
;
L97A    a14aac          
	br    S946      
;
; Yep
;
	tcy   4         ; Dragon/Sword/Pegasus
	ldp   9         
	call  ROTDRM3   
	tcy   5         ; Select lower lamp
	setr            ; Light it
	ldp   3         
	tpc             
	ldp   12        
	call  PLYPEGA   
	tcy   5         ; Select lower lamp
	rstr            ; Turn it off
	ldx   4         
	tcy   15        
	rbit  2         ; Flag that Pegasus was found
	br    S97B      ; and end the turn
;
; Award a Dragonsword?
;
S946    a14aac          
	br    S959      
;
; Yep
;
	ldx   1         
	tcy   3         
	tbit1 2         ; Check 1/3 bit 2.  Do they have one already?
	br    S97B      ; Sorry.  End turn.
	sbit  2         
	tcy   4         ; Dragon/Sword/Pegasus
	ldp   9         
	call  ROTDRM3   
	ldp   0         
	tpc             
	ldp   9         
	call  LTMIDCL   ; Light up Sword
	ldx   4         
	tcy   15        
	rbit  1         ; Flag Sword found in encounter
	br    S97B      ; End turn
;
; Award a Wizard?
;
S959    ldx   3         
	tcy   9         
	tma             ; Pick up number of players in the game
	a14aac          ; Is this a single-player game?
	br    S954      ; There was a carry--yes
	br    S97B      ; Nope.  End turn
;
; Player is awarded a Wizard; handle selecting who will be cursed
;
S954    ldx   3         
	tcy   11        
	ldp   6         
	br    L980      

; *** Chapter 2 page 6

;
; Curse continued
;
L980    tma             ; Get current player
	ldx   4         
	tam             ; Save current player in 4/11
	tcy   5         ; Wizard/Bazaar Closed/Key Missing
	ldp   9         
	call  ROTDRM3   
	ldp   0         
	tpc             
	ldp   9         
	call  LTTOPCL   ; Light up Wizard and clear the display
S9B7    ldp   10        
	call  ROTPLYR   ; Rotate player info
	ldx   4         
	tcy   11        
	mnea            ; Make sure the player rotated in isn't the current player
	br    S98E      ; Got it
	br    S9B7      ; Nope, it is; don't want to curse ourselves.  Rotate again

S98E    ldx   3         
	tcy   11        
	tma             ; Pick up target player
	ldx   7         
	tcy   14        
	tcmiy 11        ; 7/14 = 11 ("C")
	tam             ; 7/15 = Target player to curse
S998    ldp   0         
	tpc             
	ldp   7         
	call  PROMPT      
	ynec  8         ; Did they hit No/End
	br    S9AE      ; Nope
	br    S9B7      

S9AE    ynec  9         ; Did they hit Clear?
	br    S9A9      ; Nope
S9B8    ldp   10        
	call  ROTPLYR   
	ldx   4         
	tcy   11        
	mnea            ; Check that the player rotated in is the current player
	br    S9B8      ; Nope, rotate again
	ldp   1         
	tpc             
	ldp   1         
	br    DOCLEAR   
S9A9    ynec  0         ; Did they hit Yes/Buy
	br    S998      ; Nope, try again
;
; We've got the right player rotated in; handle the curse
;
	ldx   0         
	tcy   3         
	rbit  1         ; 0/3 bit 1 - cleared - flag that player has been cursed
	ldp   7         
	call  L9F6      ; Call CPY0TO5
	ldp   2         
	call  LCP5TO4   
	ldp   7         
	call  L9E9      
	tcy   2         
S9B2    ldx   4         
	tma             
	ldx   6         
	tamdyn          
	br    S9B2      
	ldp   7         
	call  L9D1      ; Call SUBGOLD
	ldp   7         
	br    L9C0      

; *** Chapter 2 page 7

L9C0    ldp   15        
	call  LBD4      
	ldp   2         
	call  LCP5TO4   
	call  L9E9      
	ldp   2         
	call  LSWP4N5   
	ldp   10        
	call  CPY5TO7   
	ldp   2         
	call  LSWP4N5   
	call  L9D3      ; Call SUBWARR
	ldp   10        
	call  CPY7TO5   
	ldp   2         
	call  LSWP4N5   
S9E7    ldp   10        
	call  ROTPLYR   
	ldx   4         
	tcy   11        
	mnea            
	br    S9E7      
	call  S9F2      ; Call ADDWARR
	tcy   2         
S9D8    ldx   6         
	tma             
	ldx   4         
	tamdyn          
	br    S9D8      
	call  L9EA      ; Call ADDGOLD
	ldx   4         
	tcy   13        
	rbit  0         
	ldp   0         
	tpc             
	ldp   5         
	call  DSPRSLT   ; Display results
	ldp   4         
	br    S939      
L9F6    ldp   1         
	tpc             
	ldp   12        
	br    CPY0TO5   
L9E9    ldp   1         
	tpc             
	ldp   11        
	br    L6C0      
L9D1    ldp   1         
	tpc             
	ldp   5         
	br    SUBGOLD   
L9D3    ldp   1         
	tpc             
	ldp   5         
	br    SUBWARR   
S9F2    ldp   1         
	tpc             
	ldp   10        
	br    ADDWARR   
L9EA    ldp   1         
	tpc             
	ldp   6         
	br    ADDGOLD   
	mnea            

; *** Chapter 2 page 8

;
; Attack the Dark Tower!  First, do The Riddle of the Keys.
;
LA00    imac            ; Are we in the final territory with all the keys?
	br    SA3D      ; Yep
;
; They're missing some element.  Check to see if they have all of the keys yet or if they're just
; not back in their own territory (2/3 Bit 0 is still clear).
;
	ldp   1         
	tpc             
	ldp   4         
	iac             
	br    L505      ; They're not back in their own territory; play the failure sound and end turn
	br    KEYMISS	; They're still missing a key
;
; Begin The Riddle of the Keys
;
SA3D    ldx   5         
	tcy   12        
	tcmiy 14        ; 5/12 = 14
	tcmiy 15        ; 5/13 = 15
LA1E    ldp   0         
	tpc             
	ldp   8         
	call  RND0TO2   ; Start with a random key
	br    SA09      ; Propose it...
;
; Propose the key in A (0-2) to the player
;
SA0E    tcy   11        
	tam             ; Save the proposed key in 5/11
SA3A    ldp   3         
	call  L8D4      ; Show the proposed next key
	ldx   5         
	tcy   12        
        tma             ; 5/12 has 14 for the first key, 15 for the second key (5/14 or 5/15)
	a3aac           ; Add 3 to bump it up to 1-2
	ldx   7         
	tcy   14        
	tamiyc          ; 7/14 = which key sequence we're on
	tcmiy 15        ; 7/15 = 15 (" ")
;
; Prompt user to use the key in the accumulator or not
;
SA0B    ldp   0         
	tpc             
	ldp   7         
	call  PROMPT      

	ynec  4         ; Did they hit Repeat?
	br    SA36      ; Nope
	ldx   5         
	tcy   11        
	tma             ; Pick up the last proposed key
	br    SA3A      

SA36    ynec  9         ; Did they hit Clear?
	br    SA24      ; Nope
	ldp   1         
	tpc             
	ldp   1         
	br    DOCLEAR   

SA24    ynec  8         ; Did they hit No/End?
	br    SA15      ; Nope
	ldx   5         
	tcy   11        
	tma             ; Pick up the last proposed key
;
; Pick the next key to use...
;
SA09    dan             ; Accumulator had the last key used
	br    SA0C      
	a3aac           
SA0C    ldx   5         
	tcy   13        
	mnea            ; Is this the last key we tried?
	br    SA0E      ; Nope, propose this key
	br    SA09      ; Try the next key

SA15    ynec  0         ; Did they hit Yes/Buy?
	br    SA0B      ; Nope, go back and prompt again
	ldx   5         
	tcy   11        
	ldp   9         
	br    LA40      

; *** Chapter 2 page 9

;
; They said "Yes, use this key here"
; Check the key sequence against The Riddle of the Keys
;
LA40    tma             ; Pick up the last proposed key from 5/11
	tcy   12        ; 5/12 is the key we're trying (14 or 15 for 5/14 and 5/15)
	tmy             ; Pick up that address for an indirect comparsion
	mnea            ; Is this the right key?
	br    SA5E      ; Nope.  Wrong key.
;
; They did get the right key
;
	iyc             ; Advance Y to the next key position
	br    SA5D      ; Y overflowed, they solved The Riddle of the Keys.  Storm the tower.
;
; First key is solved.  Update 5/12 to point to the second key storage location (5/15)
;
	tcy   12        
	tcmiy 15        ; 5/12 = 15 (for 5/15)
	tam             ; Save the key we just used in 5/13
	ldp   8         
	br    LA1E      ; Go back and prompt for the next key, choosing a random one
;
; Chose the wrong key
;
SA5E    ldp   3         
	tpc             
	ldp   11        
	call  PLYFAIL   
	ldp   4         
	br    S939      ; Call ENDTURN
;
; They solved The Riddle of the Keys; fight the Final Battle
;
SA5D    call  SA4C      
	ldp   0         
	call  L836      
	iac             
	br    SA70      
	ldp   4         
	br    S939      ; Call ENDTURN
;
; Handle Victory
;
SA70    tcy   6         ; Victory/Warriors/Brigands
	call  ROTDRM3   
	tcy   7         ; Light upper lamp
	setr            
	ldp   3         
	tpc             
	ldp   0         
	call  PLYTHEM      
	tcy   7         
	rstr            ; Turn off upper lamp
;
; Calculate the player's score and end the game
;
	ldx   2         
	ldp   1         
	tpc             
	ldp   1         
	call  S446      ; Copy saved player Warriors back to current player
	call  SA4C      ; Copy Dark Tower Brigand count to Brigand battle count
	ldp   0         
	tpc             
	ldp   9         
	call  CPYBRIG  ; Copy Brigand count to 5/1-2 for calculations
	ldp   3         
	tpc             
	ldp   15        
	br    LFFF      ; Finish calculating the score and end the game

ROTDRM3 ldp   0         
	tpc             
	ldp   8         
	br    ROTDRUM

SA4C    ldx   3         
	tcy   15        
SA72    tma             
	dyn             
	dyn             
	tamiyc          
	ynec  13        
	br    SA72      
	retn            

	mnea            
	mnea            

; *** Chapter 2 page 10

;********************************************************************************
; ROT7LFT - Call the routine to rotate the buffer of 2-digit Base10 values
;           left at 7/1-10, keeping track of the position at 7/11.
;********************************************************************************
ROT7LFT ldp   0         
	tpc             
	ldp   11        
	br    L2D6      

;********************************************************************************
; ROTPLYR - Call the routine to rotate the next player's info into 
;           0/1-3, 1/1-3, 2/2-3
;********************************************************************************
ROTPLYR ldp   0         
	tpc             
	ldp   8         
	br    L200      

;********************************************************************************
; CPY5TO7 - Call the routine to copy 5/2-0 to 7/2-0
;********************************************************************************
CPY5TO7 ldp   0         
	tpc             
	ldp   10        
	br    L28C      

;********************************************************************************
; CPY7TO5 - Call the routine to copy 7/2-0 to 5/2-0
;********************************************************************************
CPY7TO5 ldp   0         
	tpc             
	ldp   11        
	br    L2F3      
;
; Player is attacking the Dark Tower.  Play the attack sound and handle it
;
LAA7    ldp   3         
	tpc             
	ldp   6         
	call  PLYATTK      
	ldx   2         
	tcy   3         
	ldp   8         
	br    LA00      
;
; Visit the Bazaar
;
; Start by filling in the "price buffer" at 7/1-10 with the prices of the various goods.
; Prices are recorded as two-digit Base10 values to facilitate display on the LED display.
;
; The order of buffer is: Warriors, Food, Beast, Scout, Healer
;
; Price values are set to:
;   - Warriors: 3-8 bags of gold
;   - Food: 1 bag of gold
;   - Beast, Scout, Healer: 17-26 bags of gold each
;
LA98    ldp   3         
	tpc             
	ldp   4         
	call  PLYBAZR   ; Play the Bazaar music to set the location for the player
	ldx   7         
	tcy   11        
	tcmiy 1         ; 7/11 = 1 - Start at position 1
	ldp   15        
;
; Fill in position 1 with a random value from 3-8 (Warrior price)
;
	call  LRANDOM   
	ldx   4         
	tamdyn          ; 4/2 = Random
	tcmiy 0         ; 4/1 = 0
	rbit  3         ; Reduce random value to 0-7
	rbit  2         ; Reduce random value further to 0-3
;
; Add 5 to the random value
;
	ldx   5         
	tcy   1         
	tcmiy 0         ; 5/1 = 0
	tcmiy 5         ; 5/2 = 5
	ldp   4         
	call  LADDB10   ; Call ADDB10 - Add 5 to the random value
	call  CPY5TO7   ; Copy 5/2-0 to 7/2-0 - Save it in the 7 buffer
	call  ROT7LFT   ; Move on to the next price
;
; Fill in the next position with a 1 (Food price)
;
	tcy   1         
	tcmiy 0         ; 7/1 = 0
	tcmiy 1         ; 7/2 = 1
	call  ROT7LFT   ; Move on to the next price
;
; Fill in the remaining three positions with random values from 17-26 (Beast, Scout, Healer)
;
SA89    ldp   0         
	tpc             
	ldp   11        
	call  L2ED      ; Generate value from 17-26 and store in 5/1-2
	call  CPY5TO7   ; Copy 5/2-0 to 7/2-0
	call  ROT7LFT   ; Move on to the next price
	tcy   11        
	tmy             
	ynec  1         ; Have we filled in all five prices yet?
	br    SA89      ; Nope

;
; Copy the price for the current item to 5/2-0 and show it
;
LA94    call  CPY7TO5   
	ldp   11        
	br    LAC0      
	mnea            

; *** Chapter 2 page 11

;
; Handle Bazaar shopping
;
LAC0    ldp   15        
	call  ROL5BY6   
	ldx   4         
	tcy   12        
	sbit  1         ; 4/12 Bit 1 set - haven't yet haggled, give a better chance of succeeding
;
; Display what's for sale and its price then wait for a response
;
SADF    ldp   15        
	call  DSPWARE   ; Show the player what's for sale...
LAFE    ldx   7         
	tcy   14        
	tcmiy 14        ; 7/14 = 14 ("-")
	tcmiy 14        ; 7/15 = 14 ("-")
	ldp   0         
	tpc             
;
; Prompt the user for a response and process the key pressed
;
SAFC    ldp   7         
	call  PROMPT      

	ynec  4         ; Did they hit Repeat?
	br    SADD      ; Nope
;
; Handle player hitting Repeat
;
	br    SADF      ; Go back and display current item

SADD    ynec  9         ; Did they hit Clear?
	br    SAD8      ; Nope
;
; Handle player hitting Clear
;
	ldp   1         
	tpc             
	ldp   1         
	br    DOCLEAR   

SAD8    ynec  8         ; Did they hit No/End?
	br    SAC4      ; Nope
;
; Handle player hitting No/End; display next item
;
SAE1    ldp   10        
	call  ROT7LFT   
	tcy   11        
	tma             ; Check to see what item we're on
	a13aac          ; Have we hit Beast/Scout/Healer?
	br    SAF1      ; Yes.  Check to see if player already has item in inventory
SADC    ldp   10        
	br    LA94      ; Copy the price from 7/2-0 to 5/2-0 and show the wares
;
; We're looking at the Beast, Scout and Healer.  Don't show something they already have.
;
; As we added 13 to the current item in view, Acc is as follows:
;
; Acc = 0 - Beast
;       1 - Scout
;       2 - Healer
;
SAF1    ldx   1         
	tcy   3         

	dan             
	br    SADA      ; We're not on Beast
	tbit1 0         ; Do they have a Beast?
	br    SAE1      ; Yes, advance to next item
	br    SADC      ; Nope, go back and let them buy it

SADA    dan             
	br    SAC8      ; We're not on Scout
	tbit1 3         ; Do they have a Scout?
	br    SAE1      ; Yes, advance to next item
	br    SADC      ; Nope, go back and let them buy it

SAC8    tbit1 1         ; Do they have a Healer?
	br    SAE1      ; Yes, advance to next item
	br    SADC      ; Nope, go back and let them buy it

SAC4    ldp   12        
	ynec  1         ; Did they hit Haggle?
	br    LB06      ; Nope
;
; Haggle precheck
;
; Check to see that the price isn't already 1 bag of gold
;
	ldx   5         
	tcy   3         
	ldp   12        
	mnez            ; Is 10s digit non-zero?
	br    LB3C      ; Yep.  We can haggle
	tcy   4         ; Nope, check 1s digit...
	tmy             
	ynec  1         ; Is the current price more than 1 bag of gold?
	br    LB3C      ; Yeah.  We can haggle.
	br    SB00      ; Price is already 1 bag of gold.  Fuck you.  Close Bazaar
	mnea            
	mnea            

; *** Chapter 2 page 12

;
; Fuck you.  I'm closing the Bazaar.
;
SB00    tcy   5         ; Wizard/Bazaar Closed/Key Missing
	ldp   9         
	call  ROTDRM3   
	tcy   6         
	setr            ; Turn on middle lamp - Bazaar Closed
	ldp   3         
	tpc             
	ldp   11        
	call  PLYFAIL   
	tcy   6         
	rstr            ; Turn off middle lamp
	ldp   4         
	br    S939      ; Call ENDTURN
;
; Haggle...
;
; Call RANDOM to get a random value in the Accumulator.  On 0-7, haggling succeeds (50% of the time)
; except when bit 1 of 4/12 is set.  Then it always fails.
;
LB3C    ldp   15        
	call  LRANDOM   
	ldx   4         
	tcy   12        
	tbit1 1         ; Check bit 1 of 4/12 - is this the first round of haggling?
	br    SB16      ; It's set
	a8aac           ; 50% chance of haggling succeeding (roll of 0-7)
	br    SB00      ; Bazaar Closed on overflow
	br    SB30      
;
; First round of haggling has a better chance of succeeding.  4/12 bit 1 tracks.
;
SB16    rbit  1         ; Clear 4/12 bit 1; this was your first chance, make it work for you...
	a4aac           ; 68.75% chance of succeeding on first round (roll of 0-11)
	br    SB00      ; Sorry, sucker
;
; Haggle succeeded.  Reduce the price by one bag of gold and update it in the buffer
;
SB30    ldx   4         
	tcy   1         
	tcmiy 0         ; 4/1 = 0
	tcmiy 1         ; 4/2 = 1
	ldp   15        
	call  ROL5BY2  
	call  SB2A      ; Subtract one from the price
	ldp   15        
	call  ROL5BY6
	ldp   11        
	br    SADF      ; Go back and prompt with the updated price
;
; Bazaar keypress processing continues
;
LB06    ldp   11        
	ynec  0         ; Did they hit Yes/Buy
	br    LAFE      ; Nope
;
; Handle Yes/Buy purchase
;
	ldx   5         
	tcy   5         
	ldp   12        
SB34    tcmiy 0         
	ynec  9         
	br    SB34      
LB24    ldp   15        
	call  ROL5BY2   
	ldp   2         
	call  LCP5TO4   
	ldp   15        
	call  ROL5BY2   
	ldp   4         
	call  LADDB10   
	ldp   2         
	call  LCP5TO4   
	ldp   15        
	call  ROL5BY4   
	ldp   13        
	br    LB40      
SB2A    ldp   0         
	tpc             
	ldp   12        
	br    SU2B10    
	mnea            

; *** Chapter 2 page 13

LB40    ldp   7         
	call  L9F6      
	ldp   12        
	call  SB2A      
	ldp   12        
	mnez            
	br    SB00      
	ldx   7         
	tcy   11        
	tma             ; 7/11 - Current Bazaar item
	ldp   13        
	a13aac          
	br    SB53      
	ldp   15        
	call  ROL5BY6   
	ldx   4         
	tcy   1         
	tcmiy 0         
	tcmiy 1         
	ldp   4         
	call  LADDB10   
	ldp   2         
	call  LCP5TO4   
	ldp   15        
	call  ROL5BY2   
SB70    ldp   2         
	call  LSWP4N5   
	ldp   2         
	call  LCP5TO4   
	ldp   3         
	call  5TODSPB   
	ldp   0         
	tpc             
	ldp   7         
	call  PROMPT      
	ynec  9         ; Did the user hit Clear?
	br    SB5A      ; Nope
;
; Handle the user hitting Clear
;
	ldp   1         
	tpc             
	ldp   1         
	br    DOCLEAR   

SB5A    ynec  0         ; Did the user hit Yes/Buy?
	br    SB64      ; Nope
;
; Handle Yes/Buy
;
	ldp   12        
	br    LB24      
;
; Handle Repeat
;
SB64    ldp   14        
	ynec  4         ; Did the user hit Repeat?
	br    LB80      ; Nope
	ldp   15        
	call  DSPWARE   ; Display the Bazaar's wares
	br    SB70      

SB53    ldx   1         
	tcy   3         ; Player Scout/Sword/Healer/Beast inventory
	a14aac          ; Add 14 (0b1110)
	br    SB68      ; They have a Scout, Sword or Healer
	iac             ; Add one more
	br    SB6A      
	sbit  0         
	br    SB50      
SB6A    sbit  3         
	br    SB50      
SB68    sbit  1         ; Bit 1 - Healer
SB50    ldp   14        
	br    LBAB      

; *** Chapter 2 page 14

LB80    ldp   13        
	ynec  8         
	br    SB70      
	ldp   15        
	call  ROL5BY6   
	ldp   2         
	call  LCP5TO4   
	ldp   15        
	call  ROL5BY2   
	ldx   7         
	tcy   11        
	tma             ; 7/11 - Current Bazaar item
	a14aac          
	br    SB8E      
	ldp   7         
	call  S9F2      
	br    LBAB      
SB8E    ldp   1         
	tpc             
	ldp   10        
	call  ADDFOOD   

LBAB    ldp   15        
	call  ROL5BY4   
	ldp   2         
	call  LCP5TO4   
	ldp   7         
	call  L9D1      ; Call SUBGOLD
	ldx   4         
	tcy   13        
	rbit  2         ; Flag that Gold changed during encounter
	ldp   0         
	tpc             
	ldp   5         
	call  DSPRSLT   ; Display results
	ldp   4         
	br    S939      

LB86    ldp   15        
	call  LRANDOM   ; Call RANDOM.  Random value in A; Y=2
	ldx   4         
	tamdyn          ; 4/2 = random value
	tcmiy 0         ; 4/1 = 0
	rbit  3         ; Ensure random number is 0-7
	ldx   5         
	tcy   1         
	tcmiy 1         ; 5/1 = 1
	tcmiy 3         ; 5/2 = 3
	ldp   4         
	call  LADDB10   ; Add 4/1-2 to 5/1-2 - Give value of 13-20
	ldp   2         
	br    LCP5TO4   ; Copy result to 4

LB89    dan             
	call  SB94      ; Zero out 5/0-2
	mnez            ; Check for overflow
	call  SBA5      ; Yep.  Cap it at 99
	ldp   4         
	br    L932      ; Display the current Brigand count

SBA5    tcy   1         
	tcmiy 9         
	tcmiy 9         
	retn            

SB94    tcmiy 0         
	tcmiy 0         
	tcmiy 0         
	retn            


; *** Chapter 2 page 15

;********************************************************************************
; ROL5BY2 - Call the routine to rotate the buffer at 5/8-1 left 2 times
;********************************************************************************
ROL5BY2 ldp   0         
	tpc             
	ldp   11        
	br    L2CF      
;********************************************************************************
; ROL5BY4 - Call the routine to rotate the buffer at 5/8-1 left 4 times
;********************************************************************************
ROL5BY4 ldp   0         
	tpc             
	ldp   11        
	br    L2C3      
;********************************************************************************
; ROL5BY6 - Call the routine to rotate the buffer at 5/8-1 left 6 times
;********************************************************************************
ROL5BY6 ldp   0         
	tpc             
	ldp   11        
	br    L2C0      

;********************************************************************************
; DISPWARE - Display the Bazaar merchant's wares
;********************************************************************************
DSPWARE call  ROL5BY2   
	ldp   3         
	call  5TODSPB   
	call  ROL5BY6   
	ldx   7         
	tcy   11        
	tma             ; Pick up the current Bazaar item being looked at

	a12aac          
	br    SBF6      
	tcy   1         ; Warrior/Food/Beast
	ldp   9         
	call  ROTDRM3   
	ldx   7         
	tcy   11        
	tma             

	a13aac          
	br    SBE2      
	iac             
	br    SBE3      
SBEE    ldp   0         
	tpc             
	ldp   9         
	br    L241      
SBE3    ldp   0         
	tpc             
	ldp   9         
	br    L25F      

SBF6    tcy   2         ; Scout/Healer/Gold
	ldp   9         
	call  ROTDRM3   
	ldx   7         
	tcy   11        
	tma             

	a11aac          
	br    SBE3      
	br    SBEE      
SBE2    ldp   0         
	tpc             
	ldp   9         
	br    L27B      

LRANDOM ldp   0         
	tpc             
	ldp   3         
	br    RANDOM    

LBE5    ldp   0         
	tpc             
	ldp   8         
	br    L20D      
LBD4    ldp   1         
	tpc             
	ldp   6         
	br    CPY2TO5   

; *** Chapter 3 page 0


;********************************************************************************
; PLAYBUF - Play the sound buffer loaded in the Scratchpad RAM region
;
; 4/Y and 5/Y have array of durations
; 6/Y and 7/Y have array of pitches
; Notes are loaded in reverse order from Y=(0-10) down to 0
;
; Called with Y register pointing to first note plus 1
;********************************************************************************
PLAYBUF tya             ; Transfer the Y register to the Accumulator
	dan             ; Subtract one from Accumulator to point to beginning of sound buffer at 4/Y
	ldx   3         
	tcy   10        
SC0F    tam             ; Save updated pointer into sound buffer into 3/10
	tmy             
	ldx   4         ; Check 4/Y
	mnez            
	br    SC3A      ; There's a non-zero value here, play it

	ldx   5         ; Check 5/Y
	mnez            
	br    SC3A      ; There's a non-zero value here, play it
	ldp   1         
	br    LC5F      ; There's a zero here... play silence (a rest)

SC39    mnea            
	mnea            
	mnea            
	mnea            
SC1D    tam             

SC3A    tcy   10        ; Select the speaker R output
	setr            ; Toggle the speaker on
	mnea            
	mnea            
	mnea            
	mnea            
	ldx   3         
	rstr            ; Toggle the speaker off
	tmy             ; Restore the note we were playing
;
; Load delay from 6/Y and 7/Y into A and Y respectively and delay for that many loops
;
; This adjusts the time between toggles of the speaker
;
	ldx   6         
	tma             
	ldx   7         
	tmy             
SC1C    dyn             
	br    SC1C      
	dan             
	br    SC1C      
;
; Restore the note we're on into the Y register
;
	ldx   3         
	tcy   10        
	tmy             
;
; Loop based on 5/Y and 4/Y, playing the note repeatedly.  This gives duration.
;
	ldx   5         
	dman            
	br    SC39      
	tam             
	ldx   4         
	dman            
	br    SC1D      
;
; Note has been played for requested duration, decrement 3/10 and loop
;
LC08    ldx   3         
	tcy   10        
	dman            
	br    SC0F      
	retn            

LC13    ldp   8         
	br    PLYLOSR   ; Play the "lose round" sound

;********************************************************************************
; PLYTHEM - Play the theme song (start of game and victory over Dark Tower)
;********************************************************************************
PLYTHEM ldx   6         
	tcy   0         ; 6/0 - 7 1 8 0 11 0 8 1 11 1 8
	tcmiy 7         
	tcmiy 1         
	tcmiy 8         
	tcmiy 0         
	tcmiy 11        
	tcmiy 0         
	tcmiy 8         
	ldp   1         
	br    LC4D      


; *** Chapter 3 page 1

;
; More of the PLAYBUF routine.  Code responsible for playing silence (a rest)
;
SC40    mnea            
	mnea            
	mnea            
	mnea            
SC4F    tam             

;
; Play a "zero" note - silence
;
LC5F    cla             
	dan             
SC7E    mnea            
	mnea            
	mnea            
	mnea            
	mnea            
	dan             
	br    SC7E      
	ldx   7         
	dman            
	br    SC40      
	tam             
	ldx   6         
	dman            
	br    SC4F      
	ldp   0         
	br    LC08      ; Go back and play the next note

;********************************************************************************
; PLYTICK - Play tick sound on keypress
;********************************************************************************
PLYTICK ldx   7         
	tcy   0         ; 7/0 - 0
	tcmiy 0         
	ldx   6         
	tcy   0         ; 6/0 - 4
	tcmiy 4         
	ldx   5         
	tcy   0         ; 5/0 - 1
	tcmiy 1         
	ldx   4         
	tcy   0         ; 4/0 - 0
	tcmiy 0         
	ldp   0         
	br    PLAYBUF   ; Play the tick sound and return to caller

;********************************************************************************
; Continue loading play buffer for part 1 of intro tune
;********************************************************************************
LC4D    tcmiy 1         
	tcmiy 11        
	tcmiy 1         
	tcmiy 8         
	ldx   7         
	tcy   0         ; 7/0 - 5 0 11 1 13 1 11 0 13 0 11
	tcmiy 5         
	tcmiy 0         
	tcmiy 11        
	tcmiy 1         
	tcmiy 13        
	tcmiy 1         
	tcmiy 11        
	tcmiy 0         
	tcmiy 13        
	tcmiy 0         
	tcmiy 11        
	ldx   4         
	tcy   0         ; 4/0 - 6 0 2 0 1 0 2 1 0 4 0 6
	tcmiy 6         
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 1         
	tcmiy 0         
	ldp   2         
	br    LC80      

; *** Chapter 3 page 2

LC80    tcmiy 1         
	tcmiy 0         
	tcmiy 4         
	tcmiy 0         
	tcmiy 6         
	ldx   5         
	tcy   0         ; 5/0 - 0 0 2 0 10 0 10 0 4 0 0
	tcmiy 0         
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	tcmiy 4         
	tcmiy 0         
	tcmiy 0         
	ldp   0         
	call  PLAYBUF   ; Play part 1 of intro tune

;********************************************************************************
; Load play buffer for part 2 of intro tune
;********************************************************************************
	ldx   6         
	tcy   0         ; 6/0 - 1 5 1 7 0 8 0 7 1 8 1
	tcmiy 1         
	tcmiy 5         
	tcmiy 1         
	tcmiy 7         
	tcmiy 0         
	tcmiy 8         
	tcmiy 0         
	tcmiy 7         
	tcmiy 1         
	tcmiy 8         
	tcmiy 1         
	ldx   7         
	tcy   0         ; 7/0 - 0 10 0 3 1 11 1 5 0 11 0
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	tcmiy 3         
	tcmiy 1         
	tcmiy 11        
	tcmiy 1         
	tcmiy 5         
	tcmiy 0         
	tcmiy 11        
	tcmiy 0         
	ldx   4         
	tcy   0         ; 4/0 - 0 8 0 2 0 1 0 1 0 4 0
	tcmiy 0         
	tcmiy 8         
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 1         
	tcmiy 0         
	tcmiy 1         
	tcmiy 0         
	tcmiy 4         
	tcmiy 0         
	ldx   5         
	tcy   0         ; 5/0 - 3 0 0 2 0 10 0 10 0 5 0
	tcmiy 0         
	ldp   3         
	br    LCC0      

; *** Chapter 3 page 3

LCC0    tcmiy 0         
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	tcmiy 5         
	tcmiy 0         
	ldp   0         
	call  PLAYBUF   ; Play part 2 of the intro tune

;********************************************************************************
; Load play buffer for part 3 of intro tune
;********************************************************************************
	ldx   6         
	tcy   0         ; 6/0 - 6 1 8 0 11 0 8 1 11
	tcmiy 6         
	tcmiy 1         
	tcmiy 8         
	tcmiy 0         
	tcmiy 11        
	tcmiy 0         
	tcmiy 8         
	tcmiy 1         
	tcmiy 11        
	ldx   7         
	tcy   0         ; 7/0 - 13 0 11 1 13 1 11 0 13
	tcmiy 13        
	tcmiy 0         
	tcmiy 11        
	tcmiy 1         
	tcmiy 13        
	tcmiy 1         
	tcmiy 11        
	tcmiy 0         
	tcmiy 13        
	ldx   4         
	tcy   0         ; 4/0 - 15 0 2 0 1 0 2 0 3
	tcmiy 15        
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 1         
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 3         
	ldx   5         
	tcy   0         ; 5/0 - 15 0 2 0 10 0 2 0 4
	tcmiy 15        
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	tcmiy 2         
	tcmiy 0         
	tcmiy 4         
	ldp   0         
	br    PLAYBUF   ; Play part 3 of the intro tune and return to the caller

;********************************************************************************
; PLAYEOT - Play the end of turn sound (three tones)
;********************************************************************************
PLAYEOT ldx   6         
	tcy   0         ; 6/0 - 1 3 6
	tcmiy 1         
	tcmiy 3         
	ldp   4         
	br    LD00      

; *** Chapter 3 page 4

LD00    tcmiy 6         
	ldx   7         
	tcy   0         ; 7/0 - 3 0 11
	tcmiy 3         
	tcmiy 0         
	tcmiy 11        
	ldx   4         
	tcy   0         ; 4/0 - 8 4 2
	tcmiy 8         
	tcmiy 4         
	tcmiy 2         
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0
	tcmiy 0         
	tcmiy 0         
	tcmiy 0         
	ldp   0         
	br    PLAYBUF   ; Play the EOT sound and return to caller

;********************************************************************************
; PLYBAZR - Play Bazaar snake charmer tune
;********************************************************************************
PLYBAZR ldx   6         
	tcy   0         ; 6/0 - 6 5 6 7 6 5 6 7 9
	tcmiy 6         
	tcmiy 5         
	tcmiy 6         
	tcmiy 7         
	tcmiy 6         
	tcmiy 5         
	tcmiy 6         
	tcmiy 7         
	tcmiy 9         
	ldx   7         
	tcy   0         ; 7/0 - 3 15 3 10 3 15 3 10 7
	tcmiy 3         
	tcmiy 15        
	tcmiy 3         
	tcmiy 10        
	tcmiy 3         
	tcmiy 15        
	tcmiy 3         
	tcmiy 10        
	tcmiy 7         
	ldx   4         
	tcy   0         ; 4/0 - 10 5 5 5 5 5 5 5 5 5
	tcmiy 10        
SD29    tcmiy 5         
	ynec  9         
	br    SD29      
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0 0 0 0 0 0 0 0
SD22    tcmiy 0         
	ynec  9         
	br    SD22      
	ldp   0         
	call  PLAYBUF   ; Play part 1 of tune

LD0C    ldx   6         
	tcy   0         ; 6/0 - 15
	tcmiy 15        
	ldx   7         
	tcy   0         ; 7/0 - 15
	tcmiy 15        
	ldx   4         
	tcy   0         ; 4/0 - 0
	tcmiy 0         
	ldp   5         
	br    LD40      

; *** Chapter 3 page 5

LD40    ldx   5         
	tcy   0         ; 5/0 - 0
	tcmiy 0         
	ldp   0         
	br    PLAYBUF   ; Play part 2 of tune and return to caller

;********************************************************************************
; PLYSANC - Play the Sanctuary / Citadel sound
;********************************************************************************
PLYSANC call  SD4E      
	call  SD4E      
	call  SD4E      
	call  SD4E      
	call  SD4E      
	call  SD69      
	call  SD69      
	call  SD69      
	call  SD69      
	call  SD69      
	ldp   4         
	br    LD0C      

;
; First half of Sanctuary / Citadel sound 
;
SD4E    ldx   6         
	tcy   0         ; 6/0 - 0 0 1 0 0 1 0 0 1 
SD7A    tcmiy 0         
	tcmiy 0         
	tcmiy 1         
	ynec  9         
	br    SD7A      
	ldx   7         
	tcy   0         ; 7/0 - 10 14 4 10 14 4 10 14 4 
SD61    tcmiy 10        
	tcmiy 14        
	tcmiy 4         
	ynec  9         
	br    SD61      
	ldx   4         
	tcy   0         ; 4/0 - 1 1 1 1 1 1 1 1 1
SD78    tcmiy 1         
	ynec  9         
	br    SD78      
	ldx   5         
	tcy   0         ; 5/0 - 10 10 10 10 10 10 10 10 10
SD5B    tcmiy 10        
	ynec  9         
	br    SD5B      
	ldp   0         
	br    PLAYBUF      

;
; Second half of Sanctuary / Citadel sound
;
SD69    ldx   6         
	tcy   0         ; 6/0 - 0 0 1 0 0 1 0 0 1 
SD64    tcmiy 0         
	tcmiy 0         
	tcmiy 1         
	ynec  9         
	br    SD64      
	ldx   7         ; 7/0 - 9 15 4 9 15 4 9 15 4 
	tcy   0         
SD66    tcmiy 9         
	tcmiy 15        
	tcmiy 4         
	ynec  9         
	br    SD66      
	ldx   4         
	tcy   0         ; 4/0 - 1 1 1 1 1 1 1 1 1 
SD6A    tcmiy 1         
	ynec  9         
	br    SD6A      
	ldp   6         
	br    LD80      

; *** Chapter 3 page 6

LD80    ldx   5         
	tcy   0         ; 5/0 - 10 10 10 10 10 10 10 10 10 
SD83    tcmiy 10        
	ynec  9         
	br    SD83      
	ldp   0         
	br    PLAYBUF      

;********************************************************************************
; PLYATTK - Play the Dark Tower attack song
;********************************************************************************
PLYATTK ldx   6         
	tcy   0         ; 6/0 - 2 8 2 7 2 6 2 7 2 8
	tcmiy 2         
	tcmiy 8         
	tcmiy 2         
	tcmiy 7         
	tcmiy 2         
	tcmiy 6         
	tcmiy 2         
	tcmiy 7         
	tcmiy 2         
	tcmiy 8         
	ldx   7         
	tcy   0         ; 7/0 - 1 8 1 10 1 11 1 10 1 8
	tcmiy 1         
	tcmiy 8         
	tcmiy 1         
	tcmiy 10        
	tcmiy 1         
	tcmiy 11        
	tcmiy 1         
	tcmiy 10        
	tcmiy 1         
	tcmiy 8         
	ldx   4         ; 4/0 - 0 2 0 2 0 2 0 2 0 2
	tcy   0         
SDB8    tcmiy 0         
	tcmiy 2         
	ynec  10        
	br    SDB8      
	ldx   5         ; 5/0 - 0 0 0 0 0 0 0 0 0 0
	tcy   0         
SDB6    tcmiy 0         
	ynec  10        
	br    SDB6      
	ldp   0         
	call  PLAYBUF      

	ldx   6         
	tcy   0         ; 6/0 - 8 2 8 9 6 2 7
	tcmiy 8         
	tcmiy 2         
	tcmiy 8         
	tcmiy 9         
	tcmiy 6         
	tcmiy 2         
	tcmiy 7         
	ldx   7         ; 7/0 - 0 8 1 8 2 11 1 10
	tcy   0         
	tcmiy 8         
	tcmiy 1         
	tcmiy 8         
	tcmiy 2         
	tcmiy 11        
	tcmiy 1         
	tcmiy 10        
	ldp   7         
	br    LDC0      

; *** Chapter 3 page 7

LDC0    ldx   4         ; 4/0 - 11 0 5 0 1 0 2
	tcy   0         
	tcmiy 11        
	tcmiy 0         
	tcmiy 5         
	tcmiy 0         
	tcmiy 1         
	tcmiy 0         
	tcmiy 2         
	ldx   5         ; 5/0 - 0 0 0 0 8 0 0
	tcy   0         
SDEF    tcmiy 0         
	ynec  4         
	br    SDEF      
	tcmiy 8         
	tcmiy 0         
	tcmiy 0         
	ldp   0         
	call  PLAYBUF      

	ldp   4         
	br    LD0C      

;********************************************************************************
; PLYBUGL - Play bugle call for brigand attack
;********************************************************************************
PLYBUGL ldx   6         
	tcy   0         ; 6/0 - 1 3 2 1 3
	tcmiy 1         
	tcmiy 3         
	tcmiy 2         
	tcmiy 1         
	tcmiy 3         
	ldx   7         
	tcy   0         ; 7/0 - 14 3 0 14 3
	tcmiy 14        
	tcmiy 3         
	tcmiy 0         
	tcmiy 14        
	tcmiy 3         
	ldx   4         
	tcy   0         ; 4/0 - 15 5 0 15 5
	tcmiy 15        
	tcmiy 5         
	tcmiy 0         
	tcmiy 15        
	tcmiy 5         
	ldx   5         
	tcy   0         ; 5/0 - 10 0 0 10 0 
	tcmiy 10        
	tcmiy 0         
	tcmiy 0         
	tcmiy 10        
	tcmiy 0         
	ldp   0         
	call  PLAYBUF      
	ldp   4         
	br    LD0C      

;********************************************************************************
; PLYWINR - Play low/high tones when player wins a round against Brigands
;********************************************************************************
PLYWINR ldx   6         
	tcy   0         ; 6/0 - 4 6
	tcmiy 4         
	tcmiy 6         
	ldx   7         
	tcy   0         ; 7/0 - 5 12
	tcmiy 5         
	tcmiy 12        
	ldx   4         
	ldp   8         
	br    LE00      

; *** Chapter 3 page 8

LE00    tcy   0         ; 4/0 - 11 5
	tcmiy 11        
	tcmiy 5         
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0
	tcmiy 0         
	tcmiy 0         
	ldp   0         
	call  PLAYBUF      
	ldp   4         
	br    LD0C      

;********************************************************************************
; PLYLOSR - Play high/low tones when player loses a round against Brigands
;********************************************************************************
PLYLOSR ldx   6         
	tcy   0         ; 6/0 - 9 6
	tcmiy 9         
	tcmiy 6         
	ldx   7         
	tcy   0         ; 7/0 - 7 11
	tcmiy 7         
	tcmiy 11        
	ldx   4         
	tcy   0         ; 4/0 - 8 10
	tcmiy 8         
	tcmiy 10        
	ldx   5         
	tcy   0         ; 5/0 - 0 0
	tcmiy 0         
	tcmiy 0         
	ldp   0         
	call  PLAYBUF      
	ldp   4         
	br    LD0C      

;********************************************************************************
; PLYFRNT - Play the Frontier sound
;********************************************************************************
PLYFRNT call  SE23      
	call  SE23      
	ldp   4         
	br    LD0C      

SE23    ldx   6         
	tcy   0         ; 6/0 - 1 2 3 1 2 3
SE0D    tcmiy 1         
	tcmiy 2         
	tcmiy 3         
	ynec  6         
	br    SE0D      
	ldx   7         
	tcy   0         ; 7/0 - 13 10 0 13 10 0 
SE12    tcmiy 13        
	tcmiy 10        
	tcmiy 0         
	ynec  6         
	br    SE12      
	ldx   4         
	tcy   0         ; 4/0 - 3 3 3 3 3 3
SE13    tcmiy 3         
	ynec  6         
	br    SE13      
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0 0 0 0
SE25    tcmiy 0         
	ynec  6         
	br    SE25      
	ldp   0         
	br    PLAYBUF      

	tka             
	tam             
	iyc             

; *** Chapter 3 page 9


;********************************************************************************
; PLYDRGN - Play the dragon siren
;********************************************************************************
PLYDRGN call  SE7E      
	call  SE7E      
	call  SE7E      
	call  SE7E      
	call  SE7E      
	call  SE7E      
	call  SE7E      

SE7E    ldx   6         
	tcy   0         ; 6/0 - 1 0 1 0 1 0 1 0 1 0
SE7B    tcmiy 1         
	tcmiy 0         
	ynec  10        
	br    SE7B      
	ldx   7         ; 7/0 - 3 5 3 5 3 5 3 5 3 5
	tcy   0         
SE73    tcmiy 3         
	tcmiy 5         
	ynec  10        
	br    SE73      
	ldx   4         ; 4/0 - 1 0 1 0 1 0 1 0 1 0
	tcy   0         
SE6B    tcmiy 1         
	tcmiy 0         
	ynec  10        
	br    SE6B      
	ldx   5         ; 5/0 - 6 8 6 8 6 8 6 8 6 8
	tcy   0         
SE42    tcmiy 6         
	tcmiy 8         
	ynec  10        
	br    SE42      
	ldp   0         
	br    PLAYBUF      

;********************************************************************************
; PLYDSWD - Sword defense against Dragon sound
;********************************************************************************
PLYDSWD ldp   10        
	call  LE80      
	ldp   10        
	call  LE9B      
;
; Sword defense part three
;
	ldx   6         
	tcy   0         ; 6/0 - 13 12 12 11 11
	tcmiy 13        
	tcmiy 12        
	tcmiy 12        
	tcmiy 11        
	tcmiy 11        
	ldx   7         
	tcy   0         ; 7/0 - 1 7 2 9 4
	tcmiy 1         
	tcmiy 7         
	tcmiy 2         
	tcmiy 9         
	tcmiy 4         
	ldx   4         
	tcy   0         ; 4/0 - 9 1 1 1 1
	tcmiy 9         
SE59    tcmiy 1         
	ynec  5         
	br    SE59      
	ldx   5         
	tcy   0         ; 5/0 - 8 8 8 8 8
SE6A    tcmiy 8         
	ynec  5         
	br    SE6A      
	ldp   0         
	br    PLAYBUF      

; *** Chapter 3 page 10

;
; Sword defense part one
;
LE80    ldx   6         
	tcy   0         ; 6/0 - 6 5 5 4 4 3 3 3 2 2
	tcmiy 6         
	tcmiy 5         
	tcmiy 5         
	tcmiy 4         
	tcmiy 4         
	tcmiy 3         
	tcmiy 3         
	tcmiy 3         
	tcmiy 2         
	tcmiy 2         
	ldx   7         
	tcy   0         ; 7/0 - 1 13 2 14 4 15 5 0 7 2
	tcmiy 1         
	tcmiy 13        
	tcmiy 2         
	tcmiy 14        
	tcmiy 4         
	tcmiy 15        
	tcmiy 5         
	tcmiy 0         
	tcmiy 7         
	tcmiy 2         
SE98    ldx   4         
	tcy   0         ; 4/0 - 0 1 0 1 0 1 0 1 0 1
SEA1    tcmiy 0         
	tcmiy 1         
	ynec  10        
	br    SEA1      
	ldx   5         
	tcy   0         ; 5/0 - 8 6 8 6 8 6 8 6 8 6
SE9C    tcmiy 8         
	tcmiy 6         
	ynec  10        
	br    SE9C      
	ldp   0         
	br    PLAYBUF      
;
; Sword defense part two
;
LE9B    ldx   6         
	tcy   0         ; 6/0 - 10 10 9 9 8 8 7 7 6 6
	tcmiy 10        
	tcmiy 10        
	tcmiy 9         
	tcmiy 9         
	tcmiy 8         
	tcmiy 8         
	tcmiy 7         
	tcmiy 7         
	tcmiy 6         
	tcmiy 6         
	ldx   7         
	tcy   0         ; 7/0 - 10 5 12 7 13 8 15 10 15 11
	tcmiy 10        
	tcmiy 5         
	tcmiy 12        
	tcmiy 7         
	tcmiy 13        
	tcmiy 8         
	tcmiy 15        
	tcmiy 10        
	tcmiy 15        
	tcmiy 11        
	br    SE98      
	mnea            

; *** Chapter 3 page 11


;********************************************************************************
; PLYFAIL - Play failure riff.  Bazaar Closed and Lost events
;********************************************************************************
PLYFAIL ldx   6         
	tcy   0         ; 6/0 - 10 9 8 7 6 5 4 3 2
	tcmiy 10        
	tcmiy 9         
	tcmiy 8         
	tcmiy 7         
	tcmiy 6         
	tcmiy 5         
	tcmiy 4         
	tcmiy 3         
	tcmiy 2         
	ldx   7         
	tcmiy 0         ; 7/0 - 0 0 0 0 0 0 0 0 0
SEFC    tcmiy 0         
	ynec  9         
	br    SEFC      
	ldx   4         
	tcy   0         ; 4/0 - 4 4 4 4 4 4 4 4 4
SEDD    tcmiy 4         
	ynec  9         
	br    SEDD      
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0 0 0 0 0 0 0
SEEC    tcmiy 0         
	ynec  9         
	br    SEEC      
	ldp   0         
	br    PLAYBUF      

;********************************************************************************
; PLYDETH - Play the death march (Plague, starvation, etc.)
;********************************************************************************
PLYDETH ldx   6         
	tcy   0         ; 6/0 - 0 9 0 9 0 9 0 9
SED7    tcmiy 0         
	tcmiy 9         
	ynec  8         
	br    SED7      
	ldx   7         
	tcy   0         ; 7/0 - 12 9 12 9 12 9 12 9 
SEC6    tcmiy 12        
	tcmiy 9         
	ynec  8         
	br    SEC6      
	ldx   4         
	tcy   0         ; 4/0 - 0 6 0 1 0 3 0 3
	tcmiy 0         
	tcmiy 6         
	tcmiy 0         
	tcmiy 1         
	tcmiy 0         
	tcmiy 3         
	tcmiy 0         
	tcmiy 3         
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0 0 0 0 0 0
SEE6    tcmiy 0         
	ynec  8         
	br    SEE6      
	ldp   0         
	call  PLAYBUF      

	ldx   6         
	tcy   0         ; 6/0 - 9 9 9 0 9 8 0 8 7
	tcmiy 9         
	tcmiy 9         
	tcmiy 9         
	ldp   12        
	br    LF00      

; *** Chapter 3 page 12

LF00    tcmiy 0         
	tcmiy 9         
	tcmiy 8         
	tcmiy 0         
	tcmiy 8         
	tcmiy 7         
	ldx   7         
	tcy   0         ; 7/0 - 9 14 9 12 9 2 12 2 12
	tcmiy 9         
	tcmiy 14        
	tcmiy 9         
	tcmiy 12        
	tcmiy 9         
	tcmiy 2         
	tcmiy 12        
	tcmiy 2         
	tcmiy 12        
	ldx   4         
	tcy   0         ; 4/0 - 3 3 3 0 3 3 0 3 3
	tcmiy 3         
	tcmiy 3         
	tcmiy 3         
	tcmiy 0         
	tcmiy 3         
	tcmiy 3         
	tcmiy 0         
	tcmiy 3         
	tcmiy 3         
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0 0 0 0 0 0 0
SF17    tcmiy 0         
	ynec  9         
	br    SF17      
	ldp   0         
	call  PLAYBUF      

	ldp   4         
	br    LD0C      

;********************************************************************************
; PLYPEGA - Play the Pegasus found sound
;********************************************************************************
PLYPEGA ldx   6         
	tcy   0         ; 6/0 - 1 2 2 3 3 4 5 5 6 7
	tcmiy 1         
	tcmiy 2         
	tcmiy 2         
	tcmiy 3         
	tcmiy 3         
	tcmiy 4         
	tcmiy 5         
	tcmiy 5         
	tcmiy 6         
	tcmiy 7         
	ldx   7         
	tcy   0         ; 7/0 - 3 1 8 6 13 11 1 15 6 4
	tcmiy 3         
	tcmiy 1         
	tcmiy 8         
	tcmiy 6         
	tcmiy 13        
	tcmiy 11        
	tcmiy 1         
	tcmiy 15        
	tcmiy 6         
	tcmiy 4         
	ldx   4         
	ldp   13        
	br    LF40      

; *** Chapter 3 page 13

LF40    tcy   0         ; 4/0 - 3 3 2 2 2 1 1 0 0 0
	tcmiy 3         
	tcmiy 3         
	tcmiy 2         
	tcmiy 2         
	tcmiy 2         
	tcmiy 1         
	tcmiy 1         
	tcmiy 0         
	tcmiy 0         
	tcmiy 0         
	ldx   5         
	tcy   0         ; 5/0 - 8 0 13 5 2 10 6 15 11 4
	tcmiy 8         
	tcmiy 0         
	tcmiy 13        
	tcmiy 5         
	tcmiy 2         
	tcmiy 10        
	tcmiy 6         
	tcmiy 15        
	tcmiy 11        
	tcmiy 4         
	ldp   0         
	call  PLAYBUF      

	ldx   6         
	tcy   0         ; 6/0 - 0 0 0 0
SF42    tcmiy 0         
	ynec  4         
	br    SF42      
	ldx   7         
	tcy   0         ; 7/0 - 0 2 3 13
	tcmiy 0         
	tcmiy 2         
	tcmiy 3         
	tcmiy 13        
	ldx   4         
	tcy   0         ; 4/0 - 4 4 4 3
	tcmiy 4         
	tcmiy 4         
	tcmiy 4         
	tcmiy 3         
	ldx   5         
	tcy   0         ; 5/0 - 14 7 3 12
	tcmiy 14        
	tcmiy 7         
	tcmiy 3         
	tcmiy 12        
	ldp   0         
	br    PLAYBUF      

;********************************************************************************
; PLYBEEP - Play beep when prompting user and during startup
;********************************************************************************
PLYBEEP ldx   7         ; 7/0 - 0
	tcy   0         
	tcmiy 0         
	ldx   6         ; 6/0 - 2
	tcy   0         
	tcmiy 2         
	ldx   5         ; 5/0 - 0
	tcy   0         
	tcmiy 0         
	ldx   4         ; 4/0 - 2
	tcy   0         
	tcmiy 2         
	ldp   0         
	br    PLAYBUF      


; *** Chapter 3 page 14

LF80    ldp   13        
	br    PLYBEEP   

;********************************************************************************
; PLWFOOD - Play the Low Food notification at the beginning of a turn
;********************************************************************************
PLWFOOD call  SFBE      
	call  SFBE      
	call  SFBE      
	ldp   4         
	br    LD0C      
;
; One of the three riffs for the low food warning (called three times)
;
SFBE    ldx   6         
	tcy   0         ; 6/0 - 0 1 2 3 4 4 5 6 7 8
	tcmiy 0         
	tcmiy 1         
	tcmiy 2         
	tcmiy 3         
	tcmiy 4         
	tcmiy 4         
	tcmiy 5         
	tcmiy 6         
	tcmiy 7         
	tcmiy 8         
	ldx   7         
	tcy   0         ; 7/0 - 7 5 4 2 1 15 15 13 12 10
	tcmiy 7         
	tcmiy 5         
	tcmiy 4         
	tcmiy 2         
	tcmiy 1         
	tcmiy 15        
	tcmiy 15        
	tcmiy 13        
	tcmiy 12        
	tcmiy 10        
	ldx   4         
	tcy   0         ; 4/0 - 1 1 1 1 1 1 1 1 1 1
SFB8    tcmiy 1         
	ynec  10        
	br    SFB8      
	ldx   5         
	tcy   0         ; 5/0 - 0 0 0 0 0 0 0 0 0 0
SF9B    tcmiy 0         
	ynec  10        
	br    SF9B      
	ldp   0         
	br    PLAYBUF      

;********************************************************************************
; PLYCLR - Play the hi/lo siren when player presses Clear
;********************************************************************************
PLYCLR  ldx   6         
	tcy   0         ; 6/0 - 1 3 1 3 1 3 1 3
SFA4    tcmiy 1         
	tcmiy 3         
	ynec  8         
	br    SFA4      
	ldx   7         
	tcy   0         ; 7/0 - 9 15 9 15 9 15 9 15
SF93    tcmiy 9         
	tcmiy 15        
	ynec  8         
	br    SF93      
	ldx   4         
	tcy   0         ; 4/0 - 10 5 10 5 10 5 10 5
SF8A    tcmiy 10        
	tcmiy 5         
	ynec  8         
	br    SF8A      
	ldx   5         
	ldp   15        
	br    LFC0      

; *** Chapter 3 page 15

LFC0    tcy   0         ; 5/0 - 0 0 0 0 0 0 0 0
SFC1    tcmiy 0         
	ynec  8         
	br    SFC1      
	ldp   0         
	br    PLAYBUF      

LFFF    call  SFE5      ; Copy 5 to 4 (Brigand count)
	ldp   1         
	tpc             
	ldp   11        
	call  L6C0      ; Weighted scoring (same as Dragon losses)
	call  SFE6      ; ADDB10
	ldx   4         
	tcmiy 1         
	tcmiy 7         
	tcmiy 6         
	call  SFE2      ; SUMB10
	ldp   0         
	tpc             
	ldp   10        
	call  L28C      ; Copy 5/2-0 to 7/2-0
	ldp   1         
	tpc             
	ldp   14        
	call  CPYTRNC   ; Pick up the turn count
	call  SFE5      ; Copy 5 to 4 (Turn count)
	ldp   1         
	tpc             
	ldp   6         
	call  CPY2TO5   ; Save current player Warrior count
	call  SFE6      ; Add 4 to 5
	call  SFE5      ; Copy 5 to 4
	call  SFE2      ; Add 4 again
	call  SFE5      ; Copy 5 to 4
	call  SFE2      ; Add 4 again
	call  SFE5      ; Copy 5 to 4
	ldp   0         
	tpc             
	ldp   11        
	call  L2F3      ; Copy 7/2-0 to 5/2-0
	ldp   0         
	tpc             
	ldp   12        
	call  L33F      ; Subtract 4 from 5
	ldp   2         
	tpc             
	ldp   14        
	br    LB89      ; Update display with score and end game

SFE2    ldp   0         
	tpc             
	ldp   4         
	br    SUMB10    
SFE6    ldp   0         
	tpc             
	ldp   4         
	br    AD2B10    
SFE5    ldp   1         
	tpc             
	ldp   12        
	br    CPY5TO4   
;
; This code looks to be unused...  Odd.  There's also a chunk of code
; like this at S294.
;
; Values are 6A 25 80 94
;
SFD4    tcmiy 5         
	tamiyc          
	br    LFC0      
	br    SFD4      

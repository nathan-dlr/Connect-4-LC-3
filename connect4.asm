.ORIG x3000 
;create game board
;implement doubly linked list
;doubly linked list will allow us to easily traverse, and compare different collums of the board
;it will also allow us to compare data and display data using the same data structure 
            AND R6, R6, #0     ;this will be used to show who's turn it is
            LDI R1, BOARD_HEAD ;RO points to the adress of node repsenting column 1
RESET       AND R2, R1, #-1
            ADD R2, R2, #7     ;address of where "-" will be placed
            LD  R3, -KEY       ;"-" signifes an empty space on the board
            ADD R4, R1, #1     ;use this register to check if all "-" have been placed
            NOT R4, R4
            ADD R4, R4, #1
LOOP1       STR R3, R2, #0
            ADD R2, R2, #-1
            ADD R5, R2, R4
            BRnp LOOP1 
            LDR R1, R1, #0
            BRnp RESET
         
;display screen
            JSR DISPLAY ;only R6 needs to be saved in this subroutine
;prompt user's move
AGAIN       JSR PROMPT_USER 
            GETC              ;R0 will contain the value of the column to drop piece in 
            OUT
            ST  R0, SAVER0
            GETC
            OUT
            LD  R0, SAVER0
            JSR CHECK_VALID
            ADD R3, R3, #0
            BRnp NOTVALID
            AND R0, R0, x0F
;check if move is valid and update game board
;first check if move is valid
            LD  R1, BOARD_HEAD
NXT_NODE    LDR R1, R1, #0      
            ADD R0, R0, #-1
            BRnp NXT_NODE
            ADD R2, R1, #2
            LDR R2, R2, #0  
            LD  R4, -NEG
            ADD R5, R2, R4
            BRz VALID
NOTVALID 
            LEA R0, INVALID
            PUTS
            LD  R0, NEW_LINE
            OUT
            BRnzp AGAIN
VALID    
            ADD R2, R1, #7  ;r2 will point at the bottom of the list and go up to test where we can place the piece
LOOP2       LDR R3, R2, #0  
            ADD R5, R3, R4  ;subtracting the -neg by the data inside the current word
            BRz PLACE       ;if its a "-" then we can place a X/O
            ADD R2, R2, #-1
            BRnzp LOOP2
PLACE       ADD R6, R6, #0  ;check whos turn it is
            BRp PLACEX
            LD  R5, O_KEY
            ADD R6, R6, #1
            BRnzp STORE
PLACEX      LD  R5, X_KEY   
            ADD R6, R6, #-1
STORE       STR R5, R2, #0   
            JSR DISPLAY      ;display screen again

;check winner
;r1, r2, r5, r6 saved from before DISPLAY subroutine are registers that we can use to help check for a winner
;r1 = node address, r2 = adress of piece last placed, r5 and r6 = whose turn it is (O/0=player 1, X/1=player2)
;r2-r1 would give us the row that the last piece was placed on
            NOT R5, R5
            ADD R5, R5, #1 ;R5 is the piece we just placed, making the negative allows us to compare with the pieces around us
            JSR CHECK_VERT
            ADD R4, R4, #0 
            BRp WIN
            JSR CHECK_SIDES
            ADD R4, R4, #0 
            BRp WIN
            JSR CHECK_TIE
            ADD R5, R5, #0 
            BRz GAME_TIE
            BRnzp AGAIN
         
GAME_TIE    LEA R0, TIE_STRING
            PUTS
            HALT
WIN         ADD R6, R6, #-1
            BRn WIN2
            LEA R0, WIN1_STRNG 
            PUTS
            HALT
WIN2        LEA R0, WIN2_STRNG
            PUTS
            HALT
;if game is over display final board
;then display who won or if it was a tie


-KEY        .FILL x002D
SPACE       .FILL x0020
O_KEY       .FILL x004F
X_KEY       .FILL x0058
NEW_LINE    .FILL x000A
NEG_ONE     .FILL xFFCF ;negatvie of ASCII code for 1
PROMPT1     .STRINGZ "Player 1, choose a column: "
PROMPT2     .STRINGZ "Player 2, choose a column: "
INVALID     .STRINGZ "Invalid move. Try again."
WIN1_STRNG  .STRINGZ "Player 1 Wins."
WIN2_STRNG  .STRINGZ "Player 2 Wins."
TIE_STRING  .STRINGZ "Tie Game."
SAVER0      .BLKW 1
SAVER1      .BLKW 1
SAVER2      .BLKW 1
SAVER3      .BLKW 1
SAVER5      .BLKW 1
SAVER6      .BLKW 1
SAVER7      .BLKW 1
BOARD_HEAD  .FILL x4000
-NEG        .FILL xFFD3 ;negative of the "-" key


;DISPLAY SUBROUTINE
DISPLAY 
            ST  R1, SAVER1
            ST  R2, SAVER2
            ST  R5, SAVER5
            ST  R6, SAVER6
            LDI R1, BOARD_HEAD ;keep r1 on the pointer so we can LDR to the next node
            LD  R5, SPACE
            LD  R6, NEW_LINE
            AND R2, R2, #0
            ADD R2, R2, #2  ;this indicated what row of the list we're on it will be incremented once we traverse all nodes
NXT_ROW     LDI R1, BOARD_HEAD ;keep r1 on the pointer so we can LDR to the next node
NXT_PIECE   ADD R3, R1, R2  ;this reg will be used in as BSreg for LDR, its base node adress plus which row we're on
            LDR R0, R3, #0  ;this register contains the data we're displaying
            OUT             ;display piece 
            LDR R1, R1, #0
            BRnp OUT_SPACE
            ADD R0, R6, #0
            OUT             ;display newline
            ADD R2, R2, #1
            ADD R3, R2, #-8
            BRz DONE_DSPLY
            BRnzp NXT_ROW
OUT_SPACE   ADD R0, R5, #0
            OUT            ;display space ascii
            BRnzp NXT_PIECE
DONE_DSPLY  LD R1, SAVER1
            LD R2, SAVER2
            LD R5, SAVER5
            LD R6, SAVER6
            RET

           
           
;PROMPT USER SUBROUTINE           
PROMPT_USER
            ADD R6, R6, #0   ;check whose turn it is
            BRp PLAYER2      
            LEA R0, PROMPT1
            BRnzp READ
PLAYER2     LEA R0, PROMPT2
READ        PUTS
DONE_STRING RET


;CHECK VALID SUBROUTINE
CHECK_VALID         
            LD  R1, NEG_ONE
            AND R2, R2, #0
            ADD R2, R2, #6
            AND R3, R3, #0
LOOP3       ADD R4, R0, R1
            BRz SUCCESS 
            ADD R2, R2, #-1
            BRz FAILED
            ADD R1, R1, #-1
            BRnzp LOOP3
FAILED      ADD R3, R3, #1
SUCCESS     RET


;CHECK VERT SUBROUTINE
;r1, r2, r5, r6 saved from before DISPLAY subroutine are registers that we can use to help check for a winner
;r1 = node address, r2 = adress of piece last placed, r5 and r6 = whose turn it is (O/0=player 1, X/1=player2)
;r2-r1 would give us the row that the last piece was placed on
CHECK_VERT  AND R4, R4, #0  ;R4 will count if we have a connect four; it will return 4 if it detects a connect four and a 0 if it doesn't
            ADD R4, R4, #1  ;it already has one from the piece we just placed 
            ST  R2, SAVER2
COMPAREDOWN ADD R3, R2, #-7
            NOT R3, R2
            ADD R3, R3, #1  ;subtract R2 by seven (store in R3) and make R3 negative 
            ADD R3, R1, R3  ;comparing R3 with R1 will tell us if we're at the bottom of the column
            BRz NO_WIN_v
            ADD R2, R2, #1  
            LDR R3, R2, #0
            ADD R3, R5, R3
            BRnp NO_WIN_V
            ADD R4, R4, #1
            ADD R3, R4, #-4
            BRz WIN 
            BRnzp COMPAREDOWN
NO_WIN_V    AND R4, R4, #0
WIN_V       LD  R2, SAVER2
            RET

CHECK_SIDES

            ST  R1, SAVER1
            ST  R2, SAVER2
            ST  R6, SAVER6
            ST  R7, SAVER7
            AND R7, R7, #0  ;R7 will indicate where we're checking. -1=down diagonal, 0=horizontal, 1=up diagonal
            ADD R7, R7 #-1  ;R7 will also offset the row number in R3
            NOT R1, R1
            ADD R1, R1, #1 
            ADD R3, R1, R2 ;find row, store in R3
            ST  R3, SAVER3
            LD  R1, SAVER1
CHECKLFT    AND R4, R4, #0  ;R4 will count if we have a connect four; it will return 4 if it detects a connect four and a 0 if it doesn't
            ADD R4, R4, #1  ;it already has one from the piece we just placed 
CHCKLFT2    LDR R1, R1, #1
            BRz CHECKRHT
            ADD R3, R7, R3 ;add offset 
            ADD R2, R3, R1
            LDR R6, R2, #0 
            ADD R6, R5, R6
            BRnp CHECKRHT
            ADD R4, R4, #1
            ADD R6, R4, #-4
            BRz DONE
            BRnzp CHCKLFT2
CHECKRHT    LD  R1, SAVER1
            LD  R3, SAVER3
            NOT R7, R7
            ADD R7, R7, #1 ;need the offset to be negative as we check the other direction
CHCKRHT2    LDR R1, R1, #0 
            BRz NO_WIN
            ADD R3, R7, R3 
            ADD R2, R1, R3
            LDR R6, R2, #0
            ADD R6, R5, R6
            BRnp NO_WIN
            ADD R4, R4, #1
            ADD R6, R4, #-4
            BRz DONE
            BRnzp CHCKRHT2
NO_WIN      AND R4, R4, #0
            NOT R7, R7
            ADD R7, R7, #1
            BRp DONE  ;(CHANGE)
            ADD R7, R7, #1
            LD  R1, SAVER1
            LD  R2, SAVER2
            LD  R6, SAVER6
            BRnzp CHECKLFT
DONE        LD  R1, SAVER1
            LD  R2, SAVER2
            LD  R6, SAVER6
            LD  R7, SAVER7 
            RET
        
  

CHECK_TIE
            LD  R1, BOARD_HEAD
            LD  R3, -NEG
            AND R5, R5, #0
LOOP4       LDR R1, R1, #0
            BRz TIE 
            LDR R2, R1, #2
            ADD R4, R3, R2
            BRnp LOOP4
NO_TIE      ADD R5, R5, #1
TIE         RET

.END

.ORIG x4000
.FILL x4100
.END

.ORIG x4100
.FILL x4200
.FILL x0000
.END

.ORIG x4200
.FILL x4300
.FILL x4100
.END

.ORIG x4300
.FILL x4400
.FILL x4200
.END

.ORIG x4400
.FILL x4500
.FILL x4300
.END

.ORIG x4500
.FILL x4600
.FILL x4400
.END

.ORIG x4600
.FILL x0000
.FILL x4500
.END



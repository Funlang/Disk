;----------------------------------------------------------------------------

;---------------------- Program Starting ... --------------------------------

;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Defination     Starting...
;----------------------------------------------------------------------------
                A_BUF           =       0400H

                UP              =       0

                escape          =       011bh
                enter           =       1c0dh
                c_pgup          =       8400h
                c_pgdw          =       7600h
                home            =       4700h
                ende            =       4f00h
                pageup          =       4900h
                pagedw          =       5100h
                cleft           =       4b00h
                cup             =       4800h
                cright          =       4d00h
                cdown           =       5000h

                digit0          =       48
                digit9          =       57
                hex_au          =       65
                hex_fu          =       70
                hex_ad          =       97
                hex_fd          =       102

                lfrg            =       0c4h
                updw            =       0b3h
                uplf            =       0dah
                uprg            =       0bfh
                dwlf            =       0c0h
                dwrg            =       0d9h

                d_wild          =       74
                d_row           =       03
                d_col           =       02
                d_hex           =       d_col+10
                d_text          =       d_col+59

                d_para          =       d_col+04

                d_drive         =       d_para+02
                d_cyls          =       d_para+09
                d_head          =       d_para+18
                d_sect          =       d_para+28
                d_ldrive        =       d_para+39
                d_lclust        =       d_para+46
                d_lsect         =       d_para+56
                d_up            =       d_para+64

                w_msub          =       10
                c_mbar          =       7

                tbar_c          =       07h
                pbar_c          =       70h
                tmnu_c          =       70h
                pmnu_c          =       07h

                thed_c          =       26h
                phed_c          =       2eh
                bord_c          =       2ah
                text_c          =       3eh

                stat1_c         =       3ch
                stat2_c         =       39h
                stat3_c         =       3ah
                stat4_c         =       3bh

                ldisk_w         =       18

;Defination     End...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Macro          Starting...
;----------------------------------------------------------------------------
Add_Row         macro                           ;Use SI=>Get Row
                mov     ax,si
                mov     [row],al
                add     [row],d_row+1
                call    SCursor
                endm

Add_Col         macro                           ;Use DI=>Get Col
                mov     ax,di
                mov     dl,3
                mul     dl
                add     al,d_hex                ;Disp2hex=>Col
                mov     [col],al
                call    SCursor
                endm

;Macro          End...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;CODE           Segment         Starting...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Code            segment para    public

                org     100h
                assume  cs:Code,ds:Data,es:Data,ss:Code
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Main            Proc    Far
;----------------------------------------------------------------------------
START:
                mov     ax,Data                 ;MOV    AX,OFFSET CLAST
                                                ;INC    AX
                                                ;MOV    BX,AX
                                                ;MOV    CL,4
                                                ;SHR    AX,CL
                                                ;MOV    DX,AX
                                                ;SHL    DX,CL
                                                ;CMP    DX,BX
                                                ;JZ     NEXT
                                                ;INC    AX
                                                ;NEXT:
                                                ;MOV    BX,CS
                                                ;ADD    AX,BX
                mov     ds,ax
                mov     es,ax

                call    Disk

                call    Display

                call    Cls

;----------------------------------------------------------------------------
Main            Endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Exit            proc    near
;----------------------------------------------------------------------------
                mov     ah,4ch
                int     21h

Exit            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Error           proc    near
;----------------------------------------------------------------------------
                call    NewLine
                mov     dx,offset version
                call    DispText
                call    NewLine
                call    NewLine

                mov     dx,offset error_m
                call    DispText

                call    NewLine

                call    Exit

Error           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Invalid         proc    near
;----------------------------------------------------------------------------
                mov     al,[y]
                push    ax

                mov     [x1],8
                mov     [y1],20
                mov     [x],5
                mov     [y],41
                call    MSave
                call    MBox

                mov     [row],9
                mov     [col],35
                call    SCursor
                mov     dx,offset err_m1
                call    DispText

                mov     [row],11
                mov     [col],22
                call    SCursor
                mov     dx,offset err_m2
                call    DispText

                mov     [col],28
                call    SCursor
                mov     bl,[ldrive]
                add     bl,hex_au
                call    DispChar

                mov     [row],13
                mov     [col],28
                call    SCursor
                mov     dx,offset err_m3
                call    DispText

                call    GetKey
                call    Mstore

                pop     ax
                mov     [y],al

                ret

Invalid         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
WBox            proc    near
;----------------------------------------------------------------------------
                mov     bh,stat1_c
                mov     cx,1800h
                mov     dx,1802h
                call    Box

                mov     bh,stat2_c
                mov     cx,1803h
                mov     dx,1810h
                call    Box

                mov     bh,stat3_c
                mov     cx,1810h
                mov     dx,1840h
                call    Box

                mov     bh,stat4_c
                mov     cx,1840h
                mov     dx,184fh
                call    Box

                mov     [row],18h
                call    SCursor
                mov     dx,offset status
                call    DispText                ;Display Version

                mov     bh,tbar_c
                call    Dsp_Bar

                mov     bh,11h
                mov     cx,0100h
                mov     dx,174fh
                call    Box                     ;Clear Text Screen

                mov     ah,[color]
                mov     al,[y]
                push    ax
                mov     [x1],d_row
                mov     [y1],d_col-1
                mov     [x],16
                mov     [y],d_wild+1
                mov     [color],bord_c
                call    MBox                    ;Text Box Border
                pop     ax
                mov     [color],ah
                mov     [y],al

                mov     bh,text_c
                mov     ch,d_row+1
                mov     cl,d_col
                mov     dh,d_row+16
                mov     dl,d_col+d_wild
                call    Box                     ;Text Box

                mov     bh,thed_c
                mov     ch,d_row
                mov     cl,d_para+1
                mov     dh,ch
                mov     dl,d_up+1
                call    Box                     ;Parameter Box

                mov     [row],d_row
                mov     [col],d_para
                call    SCursor
                mov     dx,offset titles
                call    DispText                ;Display Disk Parameter

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_cyls
                mov     dh,ch
                mov     dl,d_cyls+3
                call    Box                     ;Cylinder

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_head
                mov     dh,ch
                mov     dl,d_head+1
                call    Box                     ;Head

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_sect
                mov     dh,ch
                mov     dl,d_sect+1
                call    Box                     ;Sector

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_ldrive
                mov     dh,ch
                mov     dl,d_ldrive
                call    Box                     ;Logical Drive

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_lclust
                mov     dh,ch
                mov     dl,d_lclust+3
                call    Box                     ;Logical Clust

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_lsect
                mov     dh,ch
                mov     dl,d_lsect+1
                call    Box                     ;Logical Sector

                mov     bh,phed_c
                mov     ch,d_row
                mov     cl,d_up
                mov     dh,ch
                mov     dl,d_up
                call    Box                     ;page UP/DOWN

                ret

WBox            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Dsp_Bar         proc    near
;----------------------------------------------------------------------------
                mov     cx,0000h
                mov     dx,004fh
                call    Box                     ;Menu Bar Box

                mov     [row],0
                mov     [col],0
                call    SCursor
                mov     dx,offset menubar
                call    DispText                ;Display Menubar

                ret

Dsp_Bar         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Disk            proc    near
;----------------------------------------------------------------------------
                mov     [drive],80h
                call    XDisk
                or      ax,ax
                jz      disk1
                call    Error
disk1:
                call    Cls
                call    ECursor

                call    WBox
                call    DispPage

                mov     [ldrive],2
                mov     [dlast],0
                mov     bp,sp
                sub     bp,6
disk2:
                mov     di,[buffer]
disk3:
                push    di
                push    [cyls]
                mov     ah,[head]
                mov     al,[sect]
                push    ax
                call    Read
                jc      disk5

                mov     al,[di+01c2h]
                cmp     al,06h                  ;No Branch
                jnz     disk4

                mov     ch,[di+01c1h]

                mov     dh,[di+01bfh]
                mov     cl,[di+01c0h]
                call    PPPP
                mov     [ncyls],ax
                mov     [nhead],dh
                mov     [nsect],cl

                call    LDisk
                cmp     ax,0
                jnz     disk5

                call    PushDisk
                inc     [ldrive]
                inc     [dlast]

                pop     ax
                mov     [head],ah
                mov     [sect],al
                pop     [cyls]

                pop     di
                add     di,10h
                jmp     disk3
disk4:
                cmp     al,05h                  ;Have Branch
                jnz     disk5                   ;AL==0:End

                mov     ch,[di+01c1h]
                mov     dh,[di+01bfh]
                mov     cl,[di+01c0h]
                call    PPPP
                mov     [cyls],ax
                mov     [head],dh
                mov     [sect],cl
                jmp     disk2
disk5:
                mov     di,sp
                mov     di,ss:[di+4]
                sub     di,[buffer]
                cmp     di,40h
                jb      disk6

                cmp     bp,sp
                jz      diskx
                add     sp,6
disk6:
                pop     ax
                mov     [head],ah
                mov     [sect],al
                pop     [cyls]

                pop     di
                add     di,10h
                jmp     disk3
diskx:
                add     sp,6

                mov     [ldrive],2
                call    PopDisk

                ret

Disk            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
XDisk           proc    near                    ;AX ?= 0
;----------------------------------------------------------------------------
                mov     ah,8
                mov     dl,[drive]
                int     13h

                jnc     xdisk1
xdiskx:
                mov     ax,0ffffh

                ret
xdisk1:
                mov     ax,Data                 ;MOV    AX,DS
                mov     es,ax

                add     ch,[Extra_Cylinder]
                call    PPPP
                mov     [xcyls],ax
                mov     [xhead],dh
                mov     [xsect],cl

                mov     [cyls],0
                mov     [head],0
                mov     [sect],1
                call    Read
                jc      xdiskx

                xor     ax,ax

                ret

XDisk           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
PPPP            proc    near                    ;CH,CL=>AX,CL
;----------------------------------------------------------------------------
                mov     al,cl
                shl     cl,1
                shl     cl,1
                shr     cl,1
                shr     cl,1
                push    cx
                mov     cl,6
                shr     al,cl
                mov     ah,al
                mov     al,ch
                pop     cx

                ret

PPPP            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
LDisk           proc    near                    ;AX ?= 0
;----------------------------------------------------------------------------
                mov     [ls_h],0
                mov     [ls_l],0
                call    LRead
                jc      ldiskx
                mov     si,[buffer]
                jmp     ldisk0
ldiskx:
                call    Invalid
                mov     ax,0ffffh
                ret
ldisk0:
                mov     ax,[si+1feh]
                cmp     ax,0aa55h
                jnz     ldiskx
                mov     ax,[si+0bh]             ;0BH:Bytes/Sector
                cmp     ax,0
                jz      ldiskx
                mov     cl,[si+0dh]             ;0DH:sectors/clust
                cmp     cl,0
                jz      ldiskx
                dec     cl
                mov     [xlsect],cl
                inc     cl
                mov     al,[drive]
                cmp     al,80h
                jnz     ldisk1
                mov     dx,[si+22h]             ;20H:Max LSector
                mov     ax,[si+20h]             ;IF DL==80
                jmp     ldisk2
ldisk1:
                xor     dx,dx                   ;13H:Max Sector
                mov     ax,[si+13h]             ;IF DL==00/01
ldisk2:
                mov     [xls_h],dx              
                mov     [xls_l],ax
                call    Divide
                cmp     ax,0
                jz      ldiskx
                mov     [xlclust],ax

                mov     cl,[si+10h]             ;10H:fats
                cmp     cl,0
                jz      ldiskx
                xor     ch,ch
                dec     cx
                mov     ax,[si+16h]             ;16H:sectors/fat
                cmp     ax,0
                jz      ldiskx
                mov     bx,ax
                inc     ax
                mov     [fat],ax
ldisk3:
                add     ax,bx
                loop    ldisk3
                mov     [root],ax
                mov     bx,[si+11h]             ;11H:root items
                cmp     bx,0
                jz      ldiskx
                mov     cl,4
                shr     bx,cl
                add     ax,bx
                mov     [d1st],ax

                xor     ax,ax

                ret

LDisk           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DiskP           proc    near
;----------------------------------------------------------------------------
                mov     al,[sectors]            ;AL=Sectors.
                mov     bx,[buffer]             ;BX=Buffer,                            
                                                ;ES=Segment.
                mov     dx,[cyls]
                mov     cl,6
                shl     dh,cl
                mov     cl,[sect]               ;CL=Sector,
                add     cl,dh
                mov     dh,[head]               ;DH=Head,       
                mov     ch,dl                   ;CH=Cylinder,
                mov     dl,[drive]              ;DL=Drive.
                
                int     13h

                ret

DiskP           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Read            proc    near
;----------------------------------------------------------------------------
                mov     ah,02                   ;AH=Function.   

                call    DiskP
                jc      readx

                call    ResetUp
readx:
                ret

Read            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Write           proc    near
;----------------------------------------------------------------------------
                mov     ah,03                   ;AH=Function.   

                call    DiskP                       

                ret

Write           endp
;----------------------------------------------------------------------------
  
;----------------------------------------------------------------------------
LRead           proc    near
;----------------------------------------------------------------------------
                call    LtoP
                call    Read

                ret

LRead           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
PushDisk        proc    near
;----------------------------------------------------------------------------
                mov     si,offset dlast

                push    [xcyls]
                pop     [si+1]
                mov     al,[xhead]
                mov     [si+3],al
                mov     al,[xsect]
                mov     [si+4],al

                add     si,4
                mov     al,[ldrive]
                dec     al
                dec     al
                mov     cl,ldisk_w
                mul     cl
                add     si,ax

                mov     al,[ldrive]
                mov     [si+1],al

                push    [ncyls]
                pop     [si+2]
                mov     al,[nhead]
                mov     [si+4],al
                mov     al,[nsect]
                mov     [si+5],al

                push    [xls_h]
                pop     [si+6]
                push    [xls_l]
                pop     [si+8]

                push    [xlclust]
                pop     [si+10]
                mov     al,[xlsect]
                mov     [si+12],al

                push    [fat]
                pop     [si+13]
                push    [root]
                pop     [si+15]
                push    [d1st]
                pop     [si+17]

                ret

PushDisk        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
PopDisk         proc    near
;----------------------------------------------------------------------------
                mov     si,offset dlast

                push    [si+1]
                pop     [xcyls]
                mov     al,[si+3]
                mov     [xhead],al
                mov     al,[si+4]
                mov     [xsect],al

                add     si,4
                mov     al,[ldrive]
                dec     al
                dec     al
                mov     cl,ldisk_w
                mul     cl
                add     si,ax

                mov     al,[si+1]
                mov     [ldrive],al

                push    [si+2]
                pop     [ncyls]
                mov     al,[si+4]
                mov     [nhead],al
                mov     al,[si+5]
                mov     [nsect],al

                push    [si+6]
                pop     [xls_h]
                push    [si+8]
                pop     [xls_l]

                push    [si+10]
                pop     [xlclust]
                mov     al,[si+12]
                mov     [xlsect],al

                push    [si+13]
                pop     [fat]
                push    [si+15]
                pop     [root]
                push    [si+17]
                pop     [d1st]

                mov     [ls_h],0                                                        
                mov     [ls_l],0
                call    StoC
                call    LRead

                ret

PopDisk         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
PtoL            proc    near
;----------------------------------------------------------------------------
                mov     ax,[cyls]
                sub     ax,[ncyls]
                jc      ptolx
                mov     cl,[xhead]
                inc     cl
                xor     dx,dx
                call    Multiply
                mov     cl,[head]
                add     ax,cx
                jnc     ptol1
                inc     dx
ptol1:
                mov     cl,[nhead]
                sub     ax,cx
                jnc     ptol2
                sub     dx,1
                jc      ptolx
ptol2:
                mov     cl,[xsect]
                call    Multiply

                mov     cl,[sect]
                add     ax,cx
                jnc     ptol3
                inc     dx
ptol3:
                mov     cl,[nsect]
                sub     ax,cx
                jnc     ptol4
                sub     dx,1
                jc      ptolx
ptol4:
                cmp     dx,[xls_h]
                ja      ptolx
                jnz     ptol5
                cmp     ax,[xls_l]
                ja      ptolx
ptol5:
                mov     [ls_h],dx
                mov     [ls_l],ax

                call    StoC
ptolx:
                ret

PtoL            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
LtoP            proc    near
;----------------------------------------------------------------------------
                mov     dx,[ls_h]
                mov     ax,[ls_l]

                xor     ch,ch

                mov     cl,[nsect]
                dec     cl
                add     ax,cx
                jnc     ltop1
                inc     dx
ltop1:
                mov     cl,[xsect]
                call    Divide
                inc     cl
                mov     [sect],cl

                mov     cl,[nhead]
                add     ax,cx
                jnc     ltop2
                inc     dx
ltop2:
                mov     cl,[xhead]
                inc     cl
                call    Divide
                mov     [head],cl

                mov     cx,[ncyls]
                add     ax,cx
                mov     [cyls],ax

                ret

LtoP            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Divide          proc    near                    ;DX_AX/CL(<>0)=>DX_AX,CL
;----------------------------------------------------------------------------
                push    ax

                xor     ah,ah

                mov     al,dh
                div     cl
                mov     dh,al                   ;=>DH
                mov     al,dl
                div     cl
                mov     dl,al                   ;=>DL

                pop     bx

                mov     al,bh
                div     cl
                mov     bh,al                   ;=>AH
                mov     al,bl
                div     cl
                mov     bl,al                   ;=>AL

                mov     cl,ah                   ;=>CL
                mov     ax,bx                   ;=>AX

                ret

Divide          endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Multiply        proc    near                    ;DX_AX*CL=>DX_AX
;----------------------------------------------------------------------------
                push    ax

                xor     ch,ch

                mov     ax,dx
                mul     cx
                mov     bx,ax

                pop     ax

                mul     cx
                add     dx,bx

                ret

Multiply        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
iCyls           proc    near
;----------------------------------------------------------------------------
                mov     cx,[xcyls]
                cmp     [cyls],cx
                jz      icylsx
                inc     [cyls]

                call    PtoL
icylsx:
                ret

iCyls           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
dCyls           proc    near
;----------------------------------------------------------------------------
                cmp     [cyls],0
                jz      dcylsx
                dec     [cyls]

                call    PtoL
dcylsx:
                ret

dCyls           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
iHead           proc    near
;----------------------------------------------------------------------------
                mov     cl,[xhead]
                cmp     [head],cl
                jz      ihead1
                inc     [head]
                call     PtoL
                jmp     iheadx
ihead1:
                mov     [head],0
                call    iCyls
iheadx:
                ret

iHead           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
dHead           proc    near
;----------------------------------------------------------------------------
                cmp     [head],0
                jz      dhead1
                dec     [head]
                call    PtoL
                jmp     dheadx
dhead1:
                mov     al,[xhead]
                mov     [head],al
                call    dCyls
dheadx:
                ret

dHead           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
iSect           proc    near
;----------------------------------------------------------------------------
                mov     cl,[xsect]
                cmp     [sect],cl
                jz      isect1
                inc     [sect]
                call    PtoL
                jmp     isectx
isect1:
                mov     [sect],1
                call    iHead
isectx:
                ret

iSect           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
dSect           proc    near
;----------------------------------------------------------------------------
                cmp     [sect],1
                jz      dsect1
                dec     [sect]
                call    PtoL
                jmp     dsectx
dsect1:
                mov     al,[xsect]
                mov     [sect],al
                call    dHead
dsectx:
                ret

dSect           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
CtoS            proc    near
;----------------------------------------------------------------------------
                xor     dx,dx
                mov     ax,[lclust]
                mov     cl,[xlsect]
                inc     cl
                call    Multiply
                mov     cl,[lsect]
                add     ax,cx
                jnc     ctos1
                inc     dx
ctos1:
                mov     [ls_h],dx
                mov     [ls_l],ax

                ret

CtoS            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
StoC            proc    near
;----------------------------------------------------------------------------
                mov     cl,[xlsect]
                inc     cl
                mov     dx,[ls_h]
                mov     ax,[ls_l]

                call    Divide

                mov     [lclust],ax
                mov     [lsect],cl

                ret

StoC            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
iLClust         proc    near
;----------------------------------------------------------------------------
                mov     ax,[xlclust]
                cmp     [lclust],ax
                jz      ilclustx
                inc     [lclust]

                call    CtoS
ilclustx:                
                ret

iLClust         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
dLClust         proc    near
;----------------------------------------------------------------------------
                cmp     [lclust],0
                jz      dlclustx
                dec     [lclust]

                call    CtoS
dlclustx:
                ret

dLClust         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
iLSect          proc    near
;----------------------------------------------------------------------------
                mov     al,[xlsect]
                cmp     [lsect],al
                jz      ilsect1
                inc     [lsect]
                call    CtoS
                jmp     ilsectx
ilsect1:
                mov     [lsect],0
                call    iLClust
ilsectx:                
                ret

iLSect          endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
dLSect          proc    near
;----------------------------------------------------------------------------
                cmp     [lsect],0
                jz      dlsect1
                dec     [lsect]
                call    CtoS
                jmp     dlsectx
dlsect1:
                mov     al,[xlsect]
                mov     [lsect],al
                call    dLClust
dlsectx:
                ret

dLSect          endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
ResetUp         proc    near
;----------------------------------------------------------------------------
                mov     si,offset cbuf
                mov     cx,[buffer]
                mov     [si],cx
                
                mov     [pages],UP

                ret

ResetUp         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
ResetDw         proc    near
;----------------------------------------------------------------------------
                call    ResetUp

                add     [cbuf],0100h
                not     [pages]

                ret

ResetDw         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
ReadPage        proc    near
;----------------------------------------------------------------------------
                cmp     [pages],up
                jnz     readpage1
                call    ResetUp
                jmp     readpage2
readpage1:
                call    ResetDw
readpage2:
                ret

ReadPage        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Cls             proc    near
;----------------------------------------------------------------------------
                mov     ax,0003h
                int     10h

                ret

Cls             endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Box             proc    near
;----------------------------------------------------------------------------
                mov     ax,0600h                
                xor     bl,bl
                int     10h

                ret

Box             endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DCursor         proc    near
;----------------------------------------------------------------------------
                mov     ch,7
                mov     cl,0
                mov     ah,1
                int     10h

                ret

DCursor         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
ECursor         proc    near
;----------------------------------------------------------------------------
                mov     ch,4
                mov     cl,7
                mov     ah,1
                int     10h

                ret

ECursor         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
BCursor         proc    near
;----------------------------------------------------------------------------
                mov     ch,0
                mov     cl,7
                mov     ah,1
                int     10h

                ret

BCursor         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
SCursor         proc    near                    ;DH,DL=>Row,Col.         
;----------------------------------------------------------------------------
                mov     dh,[row]
                mov     dl,[col]
                mov     ah,02h
                mov     bh,00h
                int     10h

                ret

SCursor         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GCursor         proc    near                    ;DH,DL=>Row,Col.         
;----------------------------------------------------------------------------
                mov     ah,03h
                mov     bh,00h
                int     10h

                mov     [row],dh
                mov     [col],dl

                ret

GCursor         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
NewLine         proc    near
;----------------------------------------------------------------------------
                mov     ax,0e0dh
                int     10h
                mov     ax,0e0ah
                int     10h

                ret

NewLine         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
MSave           proc    near
;----------------------------------------------------------------------------
                mov     dh,[x1]
                mov     dl,[y1]
                mov     [row],dh
                mov     [col],dl

                mov     di,[mbuf]

                mov     cl,[x]
                xor     ch,ch
                add     cx,3
msave1:
                push    cx
                push    dx

                mov     cl,[y]
                add     cx,3
msave2:
                push    cx

                call    SCursor
                mov     ah,8
                int     10h
                stosw

                inc     [col]

                pop     cx
                loop    msave2

                inc     [row]
                pop     dx
                mov     [col],dl

                pop     cx
                loop    msave1

                ret

MSave           endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
MStore          proc    near
;----------------------------------------------------------------------------
                mov     dh,[x1]
                mov     dl,[y1]
                mov     [row],dh
                mov     [col],dl

                mov     si,[mbuf]

                mov     cl,[x]
                xor     ch,ch
                add     cx,3
mstore1:
                push    cx
                push    dx

                mov     cl,[y]
                add     cx,3
mstore2:
                push    cx

                call    SCursor
                lodsw
                mov     bl,ah
                mov     ah,09h
                mov     cx,1
                int     10h

                inc     [col]

                pop     cx
                loop    mstore2

                inc     [row]
                pop     dx
                mov     [col],dl

                pop     cx
                loop    mstore1
                
                ret

MStore          endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
PBox            proc    near                    ;AL=SUB,BH=CLR
;----------------------------------------------------------------------------
                push    ax

                mov     ch,[x1]
                add     ch,al
                mov     dh,ch

                mov     cl,[y1]
                inc     cl
                mov     dl,cl
                mov     al,[y]
                add     dl,al
                dec     dl

                mov     [row],ch
                mov     [col],cl

                call    Box

                call    SCursor

                mov     dx,[text]
                pop     ax
                dec     al
                mov     cl,w_msub+1
                mul     cl
                add     dx,ax
                call    DispText

                ret

PBox            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
TBox            proc    near
;----------------------------------------------------------------------------
                mov     ch,[x1]
                mov     cl,[y1]
                inc     ch
                inc     cl

                mov     [row],ch
                mov     [col],cl

                mov     si,[text]

                mov     cl,[x]
                xor     ch,ch
tbox1:
                push    cx

                call    SCursor
                mov     dx,si

                push    si
                call    DispText
                pop     si

                inc     [row]
                add     si,w_msub+1

                pop     cx
                loop    tbox1

                ret

TBox            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
MBox            proc    near
;----------------------------------------------------------------------------
                mov     ch,[x1]
                mov     cl,[y1]
                mov     dh,ch
                add     dh,[x]
                inc     dh
                mov     dl,cl
                add     dl,[y]
                inc     dl

                push    cx
                push    dx

                inc     ch
                inc     cl
                inc     dh
                inc     dl
                mov     bh,00h
                call    Box

                pop     dx
                pop     cx
                mov     bh,[color]
                call    Box

                push    cx
                push    dx

                mov     [row],ch
                mov     [col],cl
                call    SCursor
                mov     bl,uplf
                call    DispChar

                mov     cl,[y]
                xor     ch,ch
mbox1:
                mov     bl,lfrg
                call    DispChar
                loop    mbox1

                call    GCursor

                mov     bl,uprg
                call    DispChar

                mov     cl,[x]
                xor     ch,ch
                push    cx
mbox2:
                inc     [row]
                call    SCursor
                mov     bl,updw
                call    DispChar
                loop    mbox2

                pop     ax
                pop     dx
                pop     cx
                push    ax                
                mov     [row],ch
                mov     [col],cl
                pop     cx
mbox3:
                inc     [row]
                call    SCursor
                mov     bl,updw
                call    DispChar
                loop    mbox3

                call    GCursor
                inc     [row]
                dec     [col]
                call    SCursor
                mov     bl,dwlf
                call    DispChar

                mov     cl,[y]
                xor     ch,ch
mbox4:
                mov     bl,lfrg
                call    DispChar
                loop    mbox4

                mov     bl,dwrg
                call    DispChar

                ret

MBox            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
ReadMenu        proc    near
;----------------------------------------------------------------------------
                mov     [x1],1
                mov     al,[mbar]
                push    ax
                dec     al
                mov     cl,w_msub
                mul     cl
                mov     [y1],al

                mov     si,offset subs
                pop     ax
                xor     ah,ah
                mov     cx,ax
                xor     bl,bl
readmenu1:
                lodsb
                sub     al,digit0
                add     bl,al
                loop    readmenu1

                mov     [x],al

                sub     bl,al
                mov     al,bl
                mov     cl,w_msub+1
                mul     cl

                mov     si,offset menusub
                add     si,ax
                mov     [text],si

                ret

ReadMenu        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Menu            proc    near
;----------------------------------------------------------------------------
                call    DCursor
                mov     bh,pbar_c
                call    Dsp_Bar

                mov     [mbar],1

                call    ReadPage
menu1:
                call    ReadMenu

                mov     [msub],1
                mov     [osub],1

                call    MSave
                call    MBox
                call    TBox
menu2:
                mov     al,[osub]
                mov     bh,tmnu_c
                call    PBox

                mov     al,[msub]
                mov     bh,pmnu_c
                call    PBox
menu3:
                call    GetKey

                mov     al,[msub]
                mov     [osub],al

                cmp     [key],cup
                jnz     menu5
                cmp     [msub],1
                jbe     menu4
                dec     [msub]
                jmp     menu2
menu4:
                mov     al,[x]
                mov     [msub],al
                jmp     menu2
menu5:
                cmp     [key],cdown
                jnz     menu7
                mov     al,[x]
                cmp     [msub],al
                jae     menu6
                inc     [msub]
                jmp     menu2
menu6:
                mov     [msub],1
                jmp     menu2
menu1_1:
                call    MStore
                jmp     menu1
menu3_1:
                jmp     menu3
menu7:
                cmp     [key],cleft
                jnz     menu9
                cmp     [mbar],1
                jbe     menu8
                dec     [mbar]
                jmp     menu1_1
menu8:
                mov     [mbar],c_mbar
                jmp     menu1_1
menu9:
                cmp     [key],cright
                jnz     menu11
                cmp     [mbar],c_mbar
                jae     menu10
                inc     [mbar]
                jmp     menu1_1
menu10:
                mov     [mbar],1
                jmp     menu1_1
menu11:
                cmp     [key],escape
                jnz     menu12
                mov     [item],0
                jmp     menux
menu12:
                cmp     [key],enter
                jnz     menu3_1
                mov     al,[mbar]
                mov     cl,10
                mul     cl
                add     al,[msub]
                mov     [item],al
                cmp     al,15                   ;EXIT ITEM
                jnz     menux
                mov     [item],0ffh
menux:
                call    MStore

                mov     bh,tbar_c
                call    Dsp_Bar
                call    ECursor

                ret

Menu            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
BtoH            proc    near                    ;BL=>BX.
;----------------------------------------------------------------------------
                mov     ch,bl

                mov     cl,4
                shr     ch,cl

                cmp     ch,0ah
                jb      btoh1
                add     ch,hex_au-0ah
                jmp     btoh2
btoh1:
                add     ch,digit0
btoh2:
                mov     bh,ch

                mov     ch,bl

                mov     cl,4
                shl     ch,cl
                shr     ch,cl

                cmp     ch,0ah
                jb      btoh3
                add     ch,hex_au-0ah
                jmp     btoh4
btoh3:
                add     ch,digit0
btoh4:
                mov     bl,ch

                ret

BtoH            endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Disp2Hex        proc    near                    ;BL=>BH,BL.
;----------------------------------------------------------------------------
                call    BtoH

                mov     ah,0eh
                mov     al,bh
                int     10h

                mov     ah,0eh
                mov     al,bl
                int     10h

                ret

Disp2Hex        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Disp4Hex        proc    near                    ;BX.
;----------------------------------------------------------------------------
                push    bx

                mov     bl,bh
                call    Disp2Hex

                pop     bx   
                call    Disp2Hex
                
                ret

Disp4Hex        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DispChar        proc    near                    ;BL.
;----------------------------------------------------------------------------
                cmp     bl,20h
                jae     dispchar1
                mov     bl,2eh
dispchar1:
                mov     ah,0eh
                mov     al,bl
                int     10h

                ret

DispChar        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DispText        proc    near                    ;Equal Int 21H
;----------------------------------------------------------------------------
                mov     si,dx
disptext1:
                lodsb
                cmp     al,24h
                jz      disptextx
                mov     ah,0eh
                int     10h
                jmp     disptext1
disptextx:
                ret

DispText        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DispAddress     proc    near                    ;DH.
;----------------------------------------------------------------------------
                mov     bx,es
                call    Disp4Hex

                mov     ax,0e3ah
                int     10h                     ; Display ':'

                mov     bx,[cbuf]
                call    Disp4Hex

                mov     [col],d_hex+23
                call    SCursor
                mov     ax,0e2dh
                int     10h                     ; Display '-'

                ret

DispAddress     endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DispLine        proc    near
;----------------------------------------------------------------------------
                mov     [col],d_col
                call    SCursor

                call    DispAddress

                mov     cx,16
                xor     di,di
displine1:
                push    cx

                mov     si,offset cbuf
                mov     bx,[si]
                mov     bl,[bx]
                mov     dx,[si]
                inc     dx
                mov     [si],dx

                push    bx

                Add_Col                         ;MACRO

                pop     bx
                push    bx

                call    Disp2Hex

                mov     ax,di
                mov     dl,al
                add     dl,d_text               ;DispText=>Col
                mov     [col],dl
                call    SCursor

                pop     bx

                call    DispChar

                pop     cx
                inc     di

                loop    displine1

                inc     [row]

                ret

DispLine        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DiskPara        proc    near
;----------------------------------------------------------------------------
                mov     [row],d_row

                mov     [col],d_head+3
                call    SCursor
                mov     bl,[xhead]
                call    Disp2Hex                ;XHead

                mov     [col],d_sect+3
                call    SCursor
                mov     bl,[xsect]
                call    Disp2Hex                ;XSector

                mov     [col],d_drive
                call    SCursor
                mov     bl,[drive]
                call    Disp2Hex                ;Drive

                mov     [col],d_cyls
                call    SCursor
                mov     bx,[cyls]
                call    Disp4Hex                ;Cylinder

                mov     [col],d_head
                call    SCursor
                mov     bl,[head]
                call    Disp2Hex                ;Head            

                mov     [col],d_sect
                call    SCursor
                mov     bl,[sect]
                call    Disp2Hex                ;Sector

                mov     [col],d_lsect+3
                call    SCursor
                mov     bl,[xlsect]
                call    Disp2Hex                ;Logical XSector

                mov     [col],d_ldrive
                call    SCursor
                mov     bl,[ldrive]
                add     bl,hex_au
                call    DispChar                ;Logical Drive

                mov     [col],d_lclust
                call    SCursor
                mov     bx,[lclust]
                call    Disp4Hex                ;Logical Clust

                mov     [col],d_lsect
                call    SCursor
                mov     bl,[lsect]
                call    Disp2Hex                ;Logical Sector

                cmp     [pages],UP
                jz      diskpara1
                mov     [col],d_up
                call    SCursor
                mov     ax,0e19h
                int     10h
                jmp     diskparax
diskpara1:
                mov     [col],d_up
                call    SCursor
                mov     ax,0e18h
                int     10h
diskparax:
                mov     [col],d_up
                call    SCursor

                ret

DiskPara        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
DispPage        proc    near
;----------------------------------------------------------------------------
                call    DCursor

                mov     [row],d_row+1
                mov     [col],d_col
                call    SCursor

                mov     cx,16
disppage1:
                push    cx
                call    DispLine
                pop     cx
                loop    disppage1

                call    DiskPara

                call    ECursor

                ret

DispPage        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GetKey          proc    near                     
;----------------------------------------------------------------------------
                xor     ah,ah
                int     16h

                mov     [key],ax

                ret

GetKey          endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GetHex          proc    near                     
;----------------------------------------------------------------------------
gethex1:
                call    GetKey

                mov     bx,[key]

                cmp     bl,digit0
                jb      gethex1
                cmp     bl,digit9
                ja      gethex2
                call    DispChar
                sub     bl,digit0
                mov     [hex],bl
                jmp     gethexx
gethex2:
                cmp     bl,hex_au
                jb      gethex1
                cmp     bl,hex_fu
                ja      gethex3
                call    DispChar
                sub     bl,hex_au-0ah
                mov     [hex],bl
                jmp     gethexx
gethex3:
                cmp     bl,hex_ad
                jb      gethex1
                cmp     bl,hex_fd
                ja      gethex1
                call    DispChar
                sub     bl,hex_ad-0ah
                mov     [hex],bl
gethexx:
                ret

GetHex          endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Get2Hex         proc    near                     
;----------------------------------------------------------------------------
                call    BCursor
                call    SCursor

                call    GetHex
                mov     bh,[hex]
                push    bx
                call    GetHex
                pop     bx
                mov     bl,[hex]
                mov     cl,4
                shl     bh,cl
                add     bl,bh
                mov     [hex],bl

                call    SCursor
                call    Disp2Hex
                call    ECursor

                ret

Get2Hex         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Get4Hex         proc    near                    ;=>AX 
;----------------------------------------------------------------------------
                call    Get2Hex
                mov     ah,[hex]
                push    ax
                add     [col],2
                call    Get2Hex
                pop     ax
                mov     al,[hex]

                ret

Get4Hex         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GetDisk         proc    near
;----------------------------------------------------------------------------
                call    BCursor
getdisk1:
                mov     [row],d_row
                mov     [col],d_ldrive
                call    SCursor

                call    GetKey

                mov     bx,[key]

                cmp     bl,hex_au+2
                jb      getdisk1
                mov     bh,[dlast]
                add     bh,hex_au+2
                cmp     bl,bh
                jae     getdisk2
                call    DispChar
                sub     bl,hex_au
                mov     [ldrive],bl
                jmp     getdiskx
getdisk2:
                cmp     bl,hex_ad+2
                jb      getdisk1
                mov     bh,[dlast]
                add     bh,hex_ad+2
                cmp     bl,bh
                jae     getdisk1
                call    DispChar
                sub     bl,hex_ad
                mov     [ldrive],bl
getdiskx:
                call    ECursor

                ret

GetDisk         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GetSect         proc    near
;----------------------------------------------------------------------------
getsect1:
                mov     [row],d_row
                mov     [col],d_cyls
                call    Get4Hex                 ;Input Cylinder
                cmp     ax,[xcyls]
                ja      getsect1
                mov     [cyls],ax
getsect2:
                mov     [row],d_row
                mov     [col],d_head
                call    Get2Hex                 ;Input Head
                mov     al,[hex]
                cmp     al,[xhead]
                ja      getsect2
                mov     [head],al
getsect3:
                mov     [row],d_row
                mov     [col],d_sect
                call    Get2Hex                 ;Input Sector
                mov     al,[hex]
                cmp     al,1
                jb      getsect3
                cmp     al,[xsect]
                ja      getsect3
                mov     [sect],al

                call    PtoL
                call    Read

                ret

GetSect         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GetLSect        proc    near
;----------------------------------------------------------------------------
getlsect1:
                mov     [row],d_row
                mov     [col],d_lclust
                call    Get4Hex
                cmp     ax,[xlclust]
                ja      getlsect1
                mov     [lclust],ax
getlsect2:
                mov     [row],d_row
                mov     [col],d_lsect
                call    Get2Hex
                mov     al,[hex]
                cmp     al,[xlsect]
                ja      getlsect2
                mov     [lsect],al

                call    CtoS
                call    LRead

                ret

GetLSect        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
GetData         proc    near
;----------------------------------------------------------------------------
                call    ReadPage

                xor     si,si
                mov     di,si
getdata1:
                Add_Row
                Add_Col                         ;MACRO
                                                ;MACRO
                call    GetKey

                cmp     [key],cleft
                jnz     getdata2
                cmp     di,0
                jz      getdata1
                dec     di
                jmp     getdata1
getdata2:
                cmp     [key],cright
                jnz     getdata3
                cmp     di,0fh
                jz      getdata1
                inc     di
                jmp     getdata1
getdata3:
                cmp     [key],cup
                jnz     getdata4
                cmp     si,0
                jz      getdata1
                dec     si
                jmp     getdata1
getdata4:
                cmp     [key],cdown
                jnz     getdata5
                cmp     si,0fh
                jz      getdata1
                inc     si
getdata1_1:
                jmp     getdata1
getdata5:
                cmp     [key],enter
                jnz     getdata6
                call    Get2Hex
                mov     ax,si
                mov     cl,4
                shl     ax,cl
                add     ax,di
                push    si
                mov     si,[cbuf]
                add     si,ax
                mov     al,[hex]
                mov     [si],al
                pop     si
getdata6:
                cmp     [key],escape
                jnz     getdata1_1
getdatax:
                ret

GetData         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Display         proc    near
;----------------------------------------------------------------------------
display1:
                call    DispPage
display1_1:
                call    GetKey
                mov     ax,[key]

                cmp     ax,escape               ;ESC
                jnz     display2
                call    Menu
                mov     al,[item]
                cmp     al,0
                jz      display1
                cmp     al,0ffh
                jz      displayx_1
                call    Run
                jmp     display1
display2:
                cmp     ax,pageup               ;PageUP
                jnz     display4                ;NotPageUP
                cmp     [pages],UP
                jz      display3                ;AT UP
display2_1:
                call    ResetUp
                jmp     display1
display3:
                call    dSect
                call    Read
display3_1:
                call    ResetDw
                jmp     display1
display4:
                cmp     ax,pagedw               ;PageDOWN
                jnz     display6                ;NotPageDOWN
                cmp     [pages],UP
                jnz     display5                ;AT DOWN
display4_1:
                not     [pages]
                jmp     display1                            
display5:
                call    iSect
display5_1:
                call    Read
                jmp     display1
display6:
                cmp     ax,c_pgup               ;Ctrl-PgUp
                jnz     display7
                call    dCyls
                jmp     display5_1
display7:
                cmp     ax,c_pgdw               ;Ctrl-PgDw
                jnz     display8
                call    iCyls
                jmp     display5_1
display8:
                cmp     ax,home                 ;Home
                jnz     display9
                call    dHead
                jmp     display5_1
display9:
                cmp     ax,ende                 ;End
                jnz     display10
                call    iHead
                jmp     display5_1
displayx_1:
                jmp     displayx
display1_2:
                jmp     display1_1
display10:
                cmp     ax,cup                  ;UP
                jnz     display12
                cmp     [pages],UP
                jz      display11
                jmp     display2_1
display11:
                call    dLSect
                call    LRead
                jmp     display3_1
display12:
                cmp     ax,cdown                ;DOWN
                jnz     display14
                cmp     [pages],UP
                jnz     display13
                jmp     display4_1
display13:
                call    iLSect
display13_1:
                call    LRead
                jmp     display1
display14:
                cmp     ax,cleft                ;LEFT
                jnz     display15
                call    dLClust
                jmp     display13_1
display15:
                cmp     ax,cright               ;RIGHT
                jnz     display1_2
                call    iLClust
                jmp     display13_1
displayx:
                ret

Display         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Waiting         proc    near
;----------------------------------------------------------------------------
                mov     [x1],8
                mov     [y1],20
                mov     [x],3
                mov     [y],30
                call    MSave
                call    MBox

                mov     [row],10
                mov     [col],25
                call    SCursor
                mov     dx,offset err_m4
                call    DispText

                ret

Waiting         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Waiterr         proc    near
;----------------------------------------------------------------------------
                mov     [row],10
                mov     [col],25
                call    SCursor
                mov     dx,offset err_m5
                call    DispText

                call    GetKey
                call    Waitend

                ret

Waiterr         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Waitend         proc    near
;----------------------------------------------------------------------------
                call    Mstore

                mov     [y],w_msub

                ret

Waitend         endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
SaveDisk        proc    near
;----------------------------------------------------------------------------
                call    Waiting

                mov     di,[buffer]
                push    di
                push    di
                mov     cx,200h
                xor     al,al
                rep     stosb

                xor     ah,ah
                mov     al,[xsect]
                mov     cl,6
                shl     ax,cl
                mov     cx,ax
                push    [xcyls]
                pop     [cyls]
                mov     [head],0
                mov     [sect],1
savedisk0:
                push    cx
                call    Write
                call    iSect
                pop     cx
                loop    savedisk0
        
                pop     di

                mov     si,offset status
                mov     cx,79
                rep     movsb
                mov     al,20h
                stosb

                pop     di
                add     di,100h

                mov     si,offset dlast
                mov     al,[si]
                mov     cl,ldisk_w
                mul     cl
                add     ax,5
                push    ax
                pop     cx
                rep     movsb

                push    [xcyls]
                pop     [cyls]
                push    [cyls]
                mov     [head],0
                mov     [sect],1
                call    Write

                mov     [cyls],0
                call    Read
                pop     [cyls]
                mov     [sect],2
                call    Write

                mov     [ldrive],2
                xor     ch,ch
                mov     cl,[dlast]
                xor     dh,dh
                mov     dl,[xsect]
                shl     dx,1
                shl     dx,1
                shl     dx,1
savedisk1:
                push    cx
                push    dx
                push    dx
                call    PopDisk
                pop     cx
                mov     bh,[ldrive]
                dec     bh
                dec     bh
                shl     bh,1
                shl     bh,1
                shl     bh,1
                inc     bh
                mov     bl,1
                push    bx
                mov     ah,[nhead]
                mov     al,[nsect]
                push    ax
savedisk2:
                pop     ax
                pop     bx
                push    cx
                push    bx

                mov     [head],ah
                mov     [sect],al
                push    [ncyls]
                pop     [cyls]
                call    Read
                call    iSect
                mov     ah,[head]
                mov     al,[sect]

                pop     bx
                push    ax

                mov     [head],bh
                mov     [sect],bl
                push    [xcyls]
                pop     [cyls]
                call    Write
                call    iSect
                mov     bh,[head]
                mov     bl,[sect]

                pop     ax
                pop     cx
                push    bx
                push    ax
                loop    savedisk2

                inc     [ldrive]

                pop     cx
                pop     cx
                pop     dx
                pop     cx
                loop    savedisk1

                mov     [ldrive],2
                call    PopDisk

                call    Waitend

                ret

SaveDisk        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
LoadDisk        proc    near
;----------------------------------------------------------------------------
                call    Waiting

                mov     si,[buffer]
                push    si
                push    si

                push    [xcyls]
                pop     [cyls]
                mov     [head],0
                mov     [sect],1
                call    Read
        
                pop     si

                mov     di,offset status
                mov     cx,79
                rep     cmpsb
                jz      loaddisk0

                call    Waiterr

                pop     si
                ret
loaddisk0:
                pop     si
                add     si,100h

                mov     di,offset dlast
                movsb
                mov     al,[di-1]
                mov     cl,ldisk_w
                mul     cl
                add     ax,4
                push    ax
                pop     cx
                rep     movsb

                push    [xcyls]
                pop     [cyls]
                mov     [sect],2
                call    Read
                mov     [cyls],0
                mov     [sect],1
                call    Write

                mov     [ldrive],2
                xor     ch,ch
                mov     cl,[dlast]
                xor     dh,dh
                mov     dl,[xsect]
                shl     dx,1
                shl     dx,1
                shl     dx,1
loaddisk1:
                push    cx
                push    dx
                push    dx
                call    PopDisk
                pop     cx
                mov     ah,[nhead]
                mov     al,[nsect]
                push    ax
                mov     bh,[ldrive]
                dec     bh
                dec     bh
                shl     bh,1
                shl     bh,1
                shl     bh,1
                inc     bh
                mov     bl,1
                push    bx
loaddisk2:
                pop     bx
                pop     ax
                push    cx
                push    ax

                mov     [head],bh
                mov     [sect],bl
                push    [xcyls]
                pop     [cyls]
                call    Read
                call    iSect
                mov     bh,[head]
                mov     bl,[sect]

                pop     ax
                push    bx

                mov     [head],ah
                mov     [sect],al
                push    [ncyls]
                pop     [cyls]
                call    Write
                call    iSect
                mov     ah,[head]
                mov     al,[sect]

                pop     bx
                pop     cx
                push    ax
                push    bx
                loop    loaddisk2

                inc     [ldrive]

                pop     cx
                pop     cx
                pop     dx
                pop     cx
                loop    loaddisk1

                mov     [ldrive],2
                call    PopDisk

                call    Waitend
                
                ret

LoadDisk        endp
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Run             proc    near                     
;----------------------------------------------------------------------------
                mov     al,[item]
run11:
                cmp     al,11
                jnz     run12
                call    SaveDisk
                jmp     runx
run12:
                cmp     al,12
                jnz     run21
                call    LoadDisk
                jmp     runx
run21:
                cmp     al,21
                jnz     run22
                mov     [cyls],0
run21_1:
                mov     [head],0
                mov     [sect],1
                call    Read
                jmp     runx
run22:
                cmp     al,22
                jnz     run23
                push    [xcyls]
                pop     [cyls]
                jmp     run21_1
run23:
                cmp     al,23
                jnz     run24
                mov     [ls_l],0
run23_1:
                mov     [ls_h],0
                call    StoC
                call    LRead
                jmp     runx
run24:
                cmp     al,24
                jnz     run25
                mov     [ls_l],1
                jmp     run23_1
run25:
                cmp     al,25
                jnz     run26
                push    [fat]
                pop     [ls_l]
                jmp     run23_1
run26:
                cmp     al,26
                jnz     run27
                push    [root]
                pop     [ls_l]
                jmp     run23_1
run27:
                cmp     al,27
                jnz     run28
                push    [d1st]
                pop     [ls_l]
                jmp     run23_1
run28:
                cmp     al,28
                jnz     run29
                call    GetSect
                jmp     runx
run29:
                cmp     al,29
                jnz     run31
                call    GetLSect
                jmp     runx
run31:
                cmp     al,31
                jnz     run32
                call    GetData
                jmp     runx
run32:
                cmp     al,32
                jnz     run51
                call    Write
                jmp     runx
run51:
                cmp     al,51
                jnz     run52
                mov     [ldrive],0
                mov     [drive],0
run51_1:
                mov     [ncyls],0
                mov     [nhead],0
                mov     [nsect],1
                mov     [ls_l],0
                call    XDisk
                cmp     ax,0
                jnz     run51_2
                call    LDisk
                jmp     run23_1
run51_2:
                call    Invalid
                jmp     run53_2
run52:
                cmp     al,52
                jnz     run53
                mov     [ldrive],1
                mov     [drive],1
                jmp     run51_1
run53:
                cmp     al,53
                jnz     run54
run53_2:
                mov     [ldrive],2
run53_1:
                mov     [drive],80h
                call    PopDisk
                jmp     runx
run54:
                cmp     al,54
                jnz     run61
                call    GetDisk
                jmp     run53_1
run61:
                cmp     al,61
                jnz     run62
                mov     [Extra_Cylinder],1
run61_1:
                call    Disk
                jmp     runx
run62:
                cmp     al,62
                jnz     runx
                mov     [Extra_Cylinder],2
                jmp     run61_1
runx:
                ret

Run             endp
;----------------------------------------------------------------------------
;               CLAST   DB      0
;----------------------------------------------------------------------------
Code            ends
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;CODE           Segment         End...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;DATA           Segment         Starting...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Data            segment para    public
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Parameter      Starting...
;----------------------------------------------------------------------------
                buffer  dw      A_BUF

                cbuf    dw      A_BUF

                Extra_Cylinder  db      1

                sectors db      1

                drive   db      80h
                cyls    dw      0
                head    db      0
                sect    db      1

                xcyls   dw      0
                xhead   db      0
                xsect   db      1

                ncyls   dw      0
                nhead   db      0
                nsect   db      1

                ldrive  db      2
                lclust  dw      0
                lsect   db      0

                xlclust dw      0
                xlsect  db      1

                ls_h    dw      0
                ls_l    dw      0
                xls_h   dw      0
                xls_l   dw      1
                              
                fat     dw      0
                root    dw      0
                d1st    dw      0

                row     db      0
                col     db      0

                x1      db      0
                y1      db      0
                x       db      0
                y       db      w_msub
                mbar    db      1
                msub    db      1
                osub    db      1
                text    dw      0

                color   db      tmnu_c

                item    db      0

                mbuf    dw      A_BUF+0200h

                key     dw      0
                hex     db      0

                pages   db      0

;Parameter      End...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Text           Starting...
;----------------------------------------------------------------------------
                status  db      ' ?DISK v1.0        Copyright (c) Zhang '
                        db      'Weidong, 1999-2000         NO:1999-0701$'

                titles  db      '碵  ] C:[    ] H:[  -  ] S:[  -  ]'
                        db      ' LD:[ ] LC:[    ] LS:[  -  ] [ ]?'

                version db      'DISK v1.0',9,'Copyright(c) Zhang Weidong, '
                        db      '1999-2000, All rights reserved.$'
                error_m db      'Error:',9,9,'HARD DISK NOT Found.$'

                err_m1  db      'WARNING!$'
                err_m2  db      'Drive C Not Found or Boot Record Error.$'
                err_m3  db      'Press any key to continue...$'

                err_m4  db      'Please Waiting......$'
                err_m5  db      "Disk wasn't Saved...$"

                menubar db      'File      View      Edit      Search    '
                        db      'Drive     Option    Help$'
                subs    db      '5924421'
                menusub db      'Save Disk $'
                        db      'Load Disk $'
                        db      'Save CMOS $'
                        db      'Load CMOS $'
                        db      'Exit      $'
                        db      'MBR       $'
                        db      'Reserve   $'
                        db      'Boot      $'
                        db      'Fat 1st   $'
                        db      'Fat Copy  $'
                        db      'Root      $'
                        db      'Data Start$'
                        db      'Sector    $'
                        db      'LSector   $'
                        db      'Edit      $'
                        db      'Save      $'
                        db      'DIR       $'
                        db      'FileName  $'
                        db      'String    $'
                        db      'Next      $'
                        db      'A:        $'
                        db      'B:        $'
                        db      'C:        $'
                        db      'Other Wise$'
                        db      'Extra: 1C $'
                        db      'Extra: 2C $'
                        db      'How About $'

                dlast   db      0

;Text           End...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Data            ends
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;DATA           Segment         End...
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
                END     START
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------

;------------------------- Program is End ... -------------------------------

;----------------------------------------------------------------------------


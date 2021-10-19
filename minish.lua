--[[
 __  __ _____ _   _ _____  _____ _    _
|  \/  |_   _| \ | |_   _|/ ____| |  | |
| \  / | | | |  \| | | | | (___ | |__| |
| |\/| | | | | . ` | | |  \___ \|  __  |
| |  | |_| |_| |\  |_| |_ ____) | |  | |
|_|  |_|_____|_| \_|_____|_____/|_|  |_|
________________________________________
<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>
<<<<<<<< smol chip8 interpreter >>>>>>>>
<<<<<<<<<<< LUA 5.3 REQUIRED >>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>
]]--
-- VARIABLES
-- Q - const 0xF
-- E - const 0xFF
-- W - const 0x80
-- J - const 144
-- j - const 240
-- V - const 32
-- w - const 16
-- U - const 224
-- K - keyboard
-- F - FLAG
-- R - V0-15
-- P - PC
-- I - I REGISTER
-- M - MEMORY
-- S - STACK
-- D - DISPLAY
-- C - DELAY TIMER
-- o - Current instr
-- r - OP & 0x0FFF
-- l - OP & 0xF000
-- X - OP & 0x0F00
-- Y - OP & 0x00F0
-- H - OP & 0x00FF
-- h - OP & 0x000F
-- x - Vx
-- y - Vy
-- m - math lib
-- N - nil/false
-- b - converts bool to num
-- s - main loop
-- d - draw flag
-- q,u,t,_,z,Z,i,g - temporary
W,J,V,j,w,Q,E,U=128,144,32,240,16,15,255,224
m,C,P,I,F,R,S,K,M=math,0,512,0,0,{},{},{},{j,J,J,J,j,V,96,V,V,112,j,w,j,W,j,j,w,j,w,j,J,J,j,w,w,j,W,j,w,j,j,W,j,J,j,j,w,V,64,64,j,J,j,J,j,j,J,j,w,j,j,J,j,J,J,U,J,U,J,U,j,W,W,W,j,U,J,J,J,U,j,W,j,W,j,j,W,j,W,W}
m.randomseed(7) --comment out if not needed
for i=0,Q do R[i]=0 end --init registers
--memory is left uninited except font starting at 0

--DISPLAY
D={}for i=0,31 do D[i]={}end

--converts bool to num
function b(v)return(v and 1 or 0)end

--MAIN LOOP
function s()
	C=m.max(C-1,0)
	u=M[P]or 0
	o=(M[P+1]or 0)|(u<<8) --fetch
	--print(string.format("OP: %04X",o),string.format("PC: %03X",P)) --uncomment for basic debug
	X=(u&Q)    	  --0x0F00 >>
	l=(u&j)>>4    --0xF000 >>
	Y=(o&j)>>4       --0x00F0 >>
	h=o&Q 			  --0x000F
	r=o&4095 	     --0x0FFF
	H=o&E 			  --0x00FF
	P=P+2 			  --next instr
	x=R[X]
	y=R[Y]
	if(l<1)then -- if 0xN000 is 0
		if(o==224)then --0x00E0 (CLS)
			for i=0,31 do D[i]={}end
			d=1
		elseif(o==238)then --0xEE (RET)
			P=S[#S]
			S[#S]=N
		end
	elseif(l<3)then  -- 0xN000 is 1 or 2
		S[#S+1]=(l>1)and(P)or(N) --If 2nnn (CALL)
		P=o --opcode & 0xFFF
		--will be &0xFFF'd later
	elseif(l<5) then --IF 0xN000 is 3 or 4
		--3xkk (SE Vx,byte)
		--4xkk (SNE Vx,byte)
		P=P+(l>3 and b(x~=H) or b(x==H))*2
	elseif(l<6 or l==9)then -- 5xxk (SE Vx,Vy) 9xxk (SNE Vx,Vy)
		P=P+(l>8 and b(x~=y) or b(x==y))*2
	elseif(l<7)then --if 0xN000 is 6 (LD Vx,byte)
		R[X]=H
	elseif(l<8)then --if 0xN000 is 7 (ADD Vx,byte)
		R[X]=(x+H)&E
	elseif(l<9)then --if 0xN000 is 8
		if(h<4)then --LD Vx,Vy; OR Vx,Vy; AND Vx,Vy; XOR Vx,Vy;
			x=(h<1 and y or (h<2 and(x|y)or(h<3 and(x&y)or(x~y))))
		elseif(h<6 or h==7)then --ADD Vx,Vy; SUB Vx,Vy; SUBN Vx,Vy
			x=h>4 and (h>6 and y-x or x-y) or x+y
			F=h>4 and b(x>=0) or b(x>E)
		elseif(h<7)then --SHR Vx
			F=x&1>0 x=x>>1
		elseif(h==14)then --0xE SHL Vx
			F=x&W>0 x=x*2
		end
		R[X]=x&E
	elseif(l<11)then --if 0xN000 is A
		I=r
	elseif(l<12)then --if 0xN000 is B
		P=r+R[0]
	elseif(l<13)then --if 0XN000 is C
		R[X]=m.random(0,H)
	elseif(l<14)then --if 0xN000 is D (DRW Vx,Vy,nibble)
		d,F=1,0
		for i=0,h-1 do
			q=M[I+i]or 0
			for g=0,7 do
				if(q&(W>>g)>0)then
					z,Z=x+g,y+i
					_=D[Z][z]
					F=F|b(_)
					D[Z][z]=not(_)
				end
			end
		end
	elseif(l<Q)then --if 0xN000 is E
		--Handle SKP and SKNP
		P=P+(b(K[x])~b(H>160))*2*b(H==158 or H==161)
	else --if 0xN000 is F
		if(H==7)then --07
			R[X]=C
		elseif(H==21)then --$0A
			C=x
		elseif(H==30)then --$1E
			--ADD I,Vx and
			I=I+x
		elseif(H==41)then --$29
			--LD F,Vx
			I=x*5
		end
	end
	P=P&4095
end


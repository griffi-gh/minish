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
-- K - keyboard
-- U - FONT
-- F - FLAG
-- R - V0-15
-- P - PC
-- I - I REGISTER
-- M - MEMORY
-- S - STACK
-- D - DISPLAY
-- o - Current instr
-- r - OP & 0x0FFF
-- l - OP & 0xF000
-- X - OP & 0x0F00
-- Y - OP & 0x00F0
-- H - OP & 0x00FF
-- h - OP & 0x000F
-- m - math lib
-- N - nil/false
-- b - converts bool to num
-- s - main loop
-- d - draw flag
-- q,t,_,z,Z,x,y,i,g - temporary
W,J,V,j,w=128,144,32,240,16
m,P,I,F,R,M,S,K,U=math,512,0,0,{},{},{},{},{j,J,J,J,j,V,96,V,V,112,j,w,j,W,j,j,w,j,w,j,J,J,j,w,w,j,W,j,w,j,j,W,j,J,j,j,w,V,64,64,j,J,j,J,j,j,J,j,w,j,j,J,j,J,J,224,J,224,J,224,j,W,W,W,j,224,J,J,J,224,j,W,j,W,j,j,W,j,W,W}
m.randomseed(7) --comment out if not needed
Q,E=15,255
for i=0,Q do R[i]=0 end --init registers
--memory is left uninited

--DISPLAY
D={}for i=0,31 do D[i]={}end

--converts bool to num
function b(v)return(v and 1 or 0)end

--MAIN LOOP
function s()
	o=(M[P+1]or 0)|(M[P]or 0)<<8 --fetch
	--print(string.format("OP: %04X",o),string.format("PC: %03X",P)) --uncomment for basic debug
	P=P+2 --next instr
	l=(o&0xF000)>>12 --0xF000 >>
	X=(o&3840)>>8    --0x0F00 >>
	Y=(o&j)>>4       --0x00F0 >>
	h=o&Q 			  --0x000F
	H=o&E 			  --0x00FF
	r=H|(o&3840)	  --0x0FFF
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
		P=P+(l>3 and b(R[X]~=H) or b(R[X]==H))*2
	elseif(l<6 or l==9)then -- 5xxk (SE Vx,Vy) 9xxk (SNE Vx,Vy)
		q,t=R[X],R[Y]
		P=P+(l>8 and b(q~=t) or b(q==t))*2
	elseif(l<7)then --if 0xN000 is 6 (LD Vx,byte)
		R[X]=H
	elseif(l<8)then --if 0xN000 is 7 (ADD Vx,byte)
		R[X]=(R[X]+H)&E
	elseif(l<9)then --if 0xN000 is 8
		q=R[X]t=R[Y]
		if(h<4)then --LD Vx,Vy; OR Vx,Vy; AND Vx,Vy; XOR Vx,Vy;
			q=(h<1 and t or (h<2 and(q|t)or(h<3 and(q&t)or(q~t))))
		elseif(h<6 or h==7)then --ADD Vx,Vy; SUB Vx,Vy; SUBN Vx,Vy
			q=h>4 and (h>6 and t-q or q-t) or q+t
			F=(h>4 and b(q>=0) or b(q>E))
		elseif(h<7)then --SHR Vx
			F,q=q&1>0,q>>1
		elseif(h==14)then --0xE SHL Vx
			F,q=q&W>0,q<<1
		end
		R[X]=q&E
	elseif(l<11)then --if 0xN000 is A
		I=r
	elseif(l<12)then --if 0xN000 is B
		P=r+R[0]
	elseif(l<13)then --if 0XN000 is C
		R[X]=m.random(0,H)
	elseif(l<14)then --if 0xN000 is D (DRW Vx,Vy,nibble)
		x=R[X]y=R[Y]d,F=1,0
		for i=0,h-1 do
			q = M[I+i]or 0
			for g=0,7 do
				if(q&(W>>g)>0)then
					z,Z=x+g,y+i
					_=D[Z][z]
					F=F|b(_)
					D[Z][z]=not(_)
				end
			end
		end
	elseif(l<Q) then --if 0xN000 is E
		if(H==158 or H==161)then --0x9e or 0xa1
			P=P+(b(K[R[X]])~b(H>160))*2
		end
	end
	P=P&4095
end


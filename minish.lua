-- __  __ _____ _   _ _____  _____ _    _
--|  \/  |_   _| \ | |_   _|/ ____| |  | |
--| \  / | | | |  \| | | | | (___ | |__| |
--| |\/| | | | | . ` | | |  \___ \|  __  |
--| |  | |_| |_| |\  |_| |_ ____) | |  | |
--|_|  |_|_____|_| \_|_____|_____/|_|  |_|
--________________________________________
--<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>
--<<<<<<<< smol chip8 interpreter >>>>>>>>
--<<<<<<<<<<< LUA 5.3 REQUIRED >>>>>>>>>>>
--<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>
--
-- VARIABLES
-- Q - const 0xF
-- E - const 0xFF
-- W - const 0x80
-- J - const 144
-- j - const 240
-- V - const 32
-- w - const 16
-- U - const 224
-- k - const 64
-- f - const 4095
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
-- p - selects a or b
-- s - main loop
-- d - draw flag
-- q,u,t,_,z,Z,i,g - temporary
-- v,B,n,(o,u used temporarily) - reserved
W,J,V,j,w,Q,E,U,k,f=128,144,32,240,16,15,255,224,64,4095
m,C,P,I,F,R,S,K,M=math,0,512,0,0,{},{},{},{j,J,J,J,j,V,96,V,V,112,j,w,j,W,j,j,w,j,w,j,J,J,j,w,w,j,W,j,w,j,j,W,j,J,j,j,w,V,k,k,j,J,j,J,j,j,J,j,w,j,j,J,j,J,J,U,J,U,J,U,j,W,W,W,j,U,J,J,J,U,j,W,j,W,j,j,W,j,W,W}
for i=0,Q do R[i]=0 end --init registers
--memory is left uninited except font starting at 0

--DISPLAY
D={}for i=0,31 do D[i]={}end

function p(v,a,b)return(v and a or b)end
--converts bool to num
function b(v)return p(v,1,0)end

--MAIN LOOP
function s()
	C=m.max(C-1,0)
	u=M[P]or 0
	o=u<<8|(M[P+1]or 0) --fetch
	--print(string.format("OP: %04X",o),string.format("PC: %03X",P)) --uncomment for basic debug
	X=u&Q    	  --0x0F00
	l=(u&j)>>4    --0xF000
	Y=(o&j)>>4    --0x00F0
	h=o&Q 		  --0x000F
	r=o&f     	  --0x0FFF
	H=o&E 		  --0x00FF
	P=P+2     	  --next instr
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
		S[#S+1]=p(l>1,P,N) --If 2nnn (CALL)
		P=o --opcode & 0xFFF
		--will be &0xFFF'd later
	elseif(l<6 or l==9)then --IF 0xN000 is 3 or 4, 5 or 9
		--3xkk (SE Vx,byte)
		--4xkk (SNE Vx,byte)
		--5xyk (SE Vx,Vy)
		--9xyk (SNE Vx,Vy)
		q=p(l>4,y,H)
		P=P+2*p(l%2==0 or l>5,b(x~=q),b(x==q))
	elseif(l<8)then --if 0xN000 is 6 (LD Vx,byte) or 7 (ADD Vx,byte)
		R[X]=E&(b(l>6)*x+H)
	elseif(l<9)then --if 0xN000 is 8
		if(h<4)then --LD Vx,Vy; OR Vx,Vy; AND Vx,Vy; XOR Vx,Vy;
			x=p(h<1,y,p(h<2,x|y,p(h<3,x&y,x~y)))
		elseif(h<6 or h==7)then --ADD Vx,Vy; SUB Vx,Vy; SUBN Vx,Vy
			x=p(h>4,p(h>6,y-x,x-y),x+y)
			F=p(h>4,b(x>=0),b(x>E))
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
		elseif(H==30 or H==41)then --$1E and $29
			--ADD I,Vx and
			--LD F,Vx
			I=p(H>V,5*x,I+x)
		elseif(H==85)then --$55
			for i=0,x do M[I+i]=R[i]end
		elseif(H==101)then --$65
			for i=0,x do R[i]=M[I+i]end
		elseif(H==51) then --$33
			q=m.floor
			M[I]=q(x/100)
			M[I+1]=q(x/10)%10
			M[I+2]=x%10
		end
	end
	P=P&f
end

--Data to be used by packer to optimize ROMs
--CONSTANTS;0xF:Q,0xFF:E,0x80:W,144:J,240:j,32:V,16:w,224:U,64:k,4095:f
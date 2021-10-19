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
-- l - 0xF000
-- X - 0x0F00
-- Y - 0x00F0
-- H - 0x00FF
-- h - 0x000F
-- m - math lib
-- N - nil/false
-- b - converts bool to num
-- s - main loop
-- d - draw flag
-- q,t,_,z,Z,x,y - temporary

m=math
m.randomseed(7) --comment out if not needed

P,I,F,R,M,S,K,U=512,0,0,{},{},{},{},{240,144,144,144,240,32,96,32,32,112,240,16,240,128,240,240,16,240,16,240,144,144,240,16,16,240,128,240,16,240,240,128,240,144,240,240,16,32,64,64,240,144,240,144,240,240,144,240,16,240,240,144,240,144,144,224,144,224,144,224,240,128,128,128,240,224,144,144,144,224,240,128,240,128,240,240,128,240,128,128}
for i=0,15 do R[i]=0 end --init registers
--memory is left uninited

--DISPLAY
D={}for i=0,31 do D[i]={}end

--converts bool to num
function b(v)return(v and 1 or 0)end

--MAIN LOOP
function s()
	o=M[P]or 0|(M[P+1]or 0 << 8) --fetch
	--print(o,P) --uncomment for debug
	P=P+2 --next instr
	l=(o&0xF000)>>12 --0xF000
	X=(o&3840)>>8    --0x0F00
	Y=(o&240)>>4     --0x00F0
	h=o&15 			  --0x000F
	H=h|Y 			  --0x00FF
	if(l<1)then -- if 0xN000 is 0
		if(o==224)then --0x00E0 (CLS)
			for i=0,31 do D[i]={}end
			d=1
		elseif(o==238)then --0xEE (RET)
			P=S[#S] S[#S]=N
		end
	elseif(l<3)then  -- 0xN000 is 1 or 2
		if(l>1)then S[#S+1]=P end --If 2nnn (CALL)
		S[#S+1]=(l>1)and(P)or(N)
		P=o --opcode & 0xFFF
		--will be &0xFFF'd later
	elseif(l<5) then --IF 0xN000 is 3 or 4
		--3xkk (SE Vx,byte)
		--4xkk (SNE Vx,byte)
		P=P+b(l>3 and R[X]~=H or R[X]==H)*2
	elseif(l<6 or l==9)then -- 5xxk (SE Vx,Vy) 9xxk (SNE Vx,Vy)
		q,t=R[X],R[Y]
		P=P+b(l>8 and q~=t or q==t)*2
	elseif(l<7)then --if 0xN000 is 6 (LD Vx,byte)
		R[X]=H
	elseif(l<8)then --if 0xN000 is 7 (ADD Vx,byte)
		R[X]=(R[X]+H)&255
	elseif(l<9)then --if 0xN000 is 8
		q=R[X]t=R[Y]
		if(h<4)then --LD Vx,Vy; OR Vx,Vy; AND Vx,Vy; XOR Vx,Vy;
			q=(h<1 and t or (h<2 and(q|t)or(h<3 and(q&t)or(q~t))))
		elseif(h<6 or h==7)then --ADD Vx,Vy; SUB Vx,Vy; SUBN Vx,Vy
			q=h>4 and (h>6 and t-q or q-t) or q+t
			F=(h>4 and b(q>=0) or b(q>255))
		elseif(h<7)then --SHR Vx
			F,q=q&1>0,q>>1
		elseif(h==14)then --0xE SHL Vx
			F,q=q&128>0,q<<1
		end
		R[X]=q&255
	elseif(l<11)then --if 0xN000 is A
		I=H|X
	elseif(l<12)then --if 0xN000 is B
		P=H|X+R[0]
	elseif(l<13)then --if 0XN000 is C
		R[X]=m.random(0,H)
	elseif(l<14)then --if 0xN000 is D (DRW Vx,Vy,nibble)
		x=R[X]y=R[Y]d,F=1,0
		for i=0,h-1 do
			q = M[I+i]
			for j=0,7 do
				if(q&(128>>j)>0)then
					z,Z=x+j,y+i
					_=D[Z][z]
					F=F|b(_)
					D[Z][z]=not(_)
				end
			end
		end
	elseif(l<15) then --if 0xN000 is E
		if(H==158 or H==161)then --0x9e or 0xa1
			P=P+(b(K[R[X]])~b(H==161))*2
		end
	end
	P=P&4095
end


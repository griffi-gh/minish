-- N - NIL
-- U - FONT
-- F - FLAG
-- R - V0-15
-- P - PC
-- I - I REGISTER
-- M - MEMORY
-- S - STACK
U={240,144,144,144,240,32,96,32,32,112,240,16,240,128,240,240,16,240,16,240,144,144,240,16,16,240,128,240,16,240,240,128,240,144,240,240,16,32,64,64,240,144,240,144,240,240,144,240,16,240,240,144,240,144,144,224,144,224,144,224,240,128,128,128,240,224,144,144,144,224,240,128,240,128,240,240,128,240,128,128}
P,I,F,R,M=512,0,0,{},{}for i=0,15 do R[i]=0 end
for i=0,4095 do M[i]=0 end
--DISPLAY
D={}for i=0,31 do D[i]={}end
--MAIN LOOP
function s()
	o=M[P] --fetch
	P=P+2 --next instr
	l=(o&0xF000)>>12 --0xF000
	X=(o&3840)>>8    --0x0F00
	Y=(o&240)>>4     --0x00F0
	H=o&255
	if(l<1)then -- if 0xN000 is 0
		if(o==224)then --0x00E0; CLS
			for i=0,31 do D[i]={}end
		elseif(o==238)then --0xEE; RET
			P=S[#S]
			S[#S]=N
		end
	elseif(l<3)then --if 0xN000 is 1 or 2
		if(l>1)then S[#S+1]=P end --If 2nnn (CALL)
		P=o&4095 --opcode & 0xFFF
	elseif(l<5) then --IF 0xN000 is 3 or 4
		P=P+(R[X]==H and 2 or (l>3 and 2 or 0))
		--[[if(R[X]==H)then --if 3xkk (SE Vx,byte)
			P=P+2
		elseif(l>3)then --if 4xkk (SNE)
			P=P+2
		end]]
	elseif(l<6)then --if 5xkk (SE Vx,Vy)
		if(R[X]==R[Y])then P=P+2 end
	elseif(l<7)then --if 0xN000 is 6 (LD Vx,byte)
		R[X]=H
	elseif(l<8)then --if 0xN000 is 7 (ADD Vx,byte)
		R[x]=(R[x]+H)&255
	elseif(l<9)then --if 0xN000 is 8
end


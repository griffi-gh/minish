--[[MINISH]]
do
	local rom = {--[[ROM]]}
	local sc = screen
	function onDraw()
		if(d)then
			for i=1,32 do
				for g=1,64 do
					local c = b(D[i-1][g-1])*255
					sc.setColor(c,c,c)
					sc.drawRectF(g,i,1,1)
				end
			end
			d=N
		end
	end
	onTick = s
	for i=1,#rom do
		M[i+512]=rom[i]
	end
end

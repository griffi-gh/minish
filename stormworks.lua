--[[MINISH]]
do
	local rom = {--[[ROM]]}
	local sc = screen
	function onDraw()
		if(d)then
			sc.setColor(0,0,0)
			sc.drawClear()
			for i=1,32 do
				for g=1,64 do
					local c = D[i-1][g-1] and 255 or 0
					sc.setColor(c,c,c)
					sc.drawRectF(g,i,1,1)
				end
			end
			d=N
		end
	end
	onTick = function()
		for i=1,#rom do
			M[i+511]=rom[i]
		end
		onTick = s
	end
end

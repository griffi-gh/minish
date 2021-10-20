--[[MINISH]]
m.randomseed(7)
B=screen
onDraw=function()
	B.setColor(E,E,E)
	for i=0,31 do
		for g=0,63 do
			if D[i][g] then
				B.drawRectF(g,i,1,1)
			end
		end
	end
end
onTick=function()--init array
	v={--[[ROM]]}o=1
	onTick=function()--copy it
		for i=1,k do
			M[o+511]=v[o]
			o=o+1
			if(o>#v)then
				onTick=s --and run
				return
			end
		end
	end
end

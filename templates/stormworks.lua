--[[MINISH]]
v={--[[ROM]]}
B=screen
onDraw=function()
	if(d)then
		for i=1,32 do
			for g=1,64 do
				n=b(D[i-1][g-1])*255
				B.setColor(n,n,n)
				B.drawRectF(g,i,1,1)
			end
		end
		d=N
	end
end
onTick=function()
	for i=1,#v do
		M[i+511]=v[i]
		onTick=s
	end
end

function relink(sol_start::solution, sol_end::solution, distancier::Array{Float64,2},f = nothing)::solution

	zbest = min(sol_start.z,sol_end.z)
	n = length(sol_start.x)
	r = rand(1:n/2)
	xStart = circshift(sol_start.x, r)
	xEnd = circshift(sol_end.x, r)
	if xStart[1] != xEnd[1]
		xStart = circshift(xStart, - findfirst(xStart, xEnd[1]) + 1 )
	end
	if xStart[2] == xEnd[end]
		reverse(xStart, 2)
	end
	
	zStart = sol_start.z
	
	
	for i=1:n-2

		if xStart[i] != xEnd[i]
			
			index = findfirst(xStart, xEnd[i])
			index == 1 ? index_m_1 = n : index_m_1 = index - 1
			
			zStart += distancier[xStart[index_m_1], xStart[index%n + 1]]
			zStart -= distancier[xStart[index_m_1], xStart[index]] + distancier[xStart[index], xStart[index%n + 1]]			
			splice!(xStart, findfirst(xStart, xEnd[i]))

			value_removed = xStart[i]
			i == 1 ? i_m_1 = n-1 : i_m_1 = i - 1
			zStart -= distancier[xStart[i_m_1], xStart[i]] + distancier[xStart[i], xStart[i + 1]]
			
			xStart[i] = xEnd[i]
			zStart += distancier[xStart[i_m_1], xStart[i]] + distancier[xStart[i], xStart[i + 1]]
			
		
			#Recherche du meilleur placement de value_removed entre les indices i+1 : end
			valuebestmin = distancier[xStart[i],value_removed] + distancier[value_removed,xStart[(i%(n-1))+1]] - distancier[xStart[i],xStart[(i%(n-1))+1]]
			indexbestmin = i+1 #index auquel ajouter la ville dans la solution

			for j = i+2:n-1
				dist = distancier[xStart[j],value_removed] + distancier[value_removed,xStart[(j%(n-1))+1]] - distancier[xStart[j],xStart[(j%(n-1))+1]]
				if dist < valuebestmin
					valuebestmin = dist
					indexbestmin = j+1
				end
			end
			
			#Insertion
			if indexbestmin==n
				zStart -= distancier[xStart[n-1],xStart[1]]
				push!(xStart, value_removed)
				zStart += distancier[xStart[n-1],xStart[n]] + distancier[xStart[n],xStart[1]]
			else
				zStart -= distancier[xStart[indexbestmin-1],xStart[indexbestmin]]
				insert!(xStart, indexbestmin, value_removed)
				zStart += distancier[xStart[indexbestmin-1],xStart[indexbestmin]] + distancier[xStart[indexbestmin],xStart[indexbestmin+1]]
			end
			
			f!=nothing && writedlm(f, transpose(xStart), " ")
					
			if zStart < zbest - 1e-6
				f!=nothing && writedlm(f, transpose([1,1]), " ")
				f!=nothing && writedlm(f, transpose([1,1]), " ")
				return solution(xStart,zStart)
			end
		end
	end
	
	f!=nothing && writedlm(f, transpose([1,1]), " ")
	f!=nothing && writedlm(f, transpose([1,1]), " ")

	solution(xStart,zStart)
	
end
		


function simple_relink(sol_start::solution, sol_end::solution, distancier::Array{Float64,2},f = nothing)::solution

	zBest = min(sol_start.z,sol_end.z)
	n = length(sol_start.x)
	r = rand(1:n/2)
	xStart = circshift(sol_start.x, r)
	xEnd = circshift(sol_end.x, r)
	
	if xStart[1] != xEnd[1]
		xStart = circshift(xStart, - findfirst(xStart, xEnd[1]) + 1 )
	end
	if xStart[2] == xEnd[end]
		reverse(xStart, 2)
	end
	
	zStart = sol_start.z
	
	for i=1:n-2

		if xStart[i] != xEnd[i]
			
			index = findfirst(xStart, xEnd[i])
			index == 1 && error("index = 1")
			
			city = xStart[index]
			
			zStart += distancier[xStart[index - 1], xStart[index%n + 1]]
			zStart -= distancier[xStart[index - 1], xStart[index]] + distancier[xStart[index], xStart[index%n + 1]]			
			splice!(xStart, index)

			index -= 1
			
			while index > i
				cout = distancier[xStart[index - 1], city] + distancier[city, xStart[index]] - distancier[xStart[index - 1], xStart[index]]
				if zStart + cout < zBest - 1e-6
					insert!(xStart, index, city)
					return solution(xStart, zStart + cout)
				end
				index -= 1
			end
	
			cout = distancier[xStart[index - 1], city] + distancier[city, xStart[index]] - distancier[xStart[index - 1], xStart[index]]
			insert!(xStart, index, city)
			zStart += cout
		end
	end
		
	solution(xStart,zStart)
	
end
		



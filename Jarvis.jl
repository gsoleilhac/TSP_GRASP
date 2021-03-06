function orientation(p::Point, q::Point, r::Point)::Int
	val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)

	if (val == 0) return 0
	else return (val > 0) ? 1 : 2
	end
end


function convexHull(points::Array{Point,1})::Array{Int,1}

	n = length(points)
	if (n < 3) return end

	#Find the leftmost point
	l = 1
	for i = 2:n
		if (points[i].x < points[l].x)
			l = i
		end
	end


	p = l
	hull = Array{Int}(0)

	while true
	
		#Add current point to result
		push!(hull, p)
		
	# Search for a point 'q' such that orientation(p, x,
        # q) is counterclockwise for all points 'x'. The idea
        # is to keep track of last visited most counterclock-
        # wise point in q. If any point 'i' is more counterclock-
        # wise than q, then update q.
        q = (p%n) + 1
        for i = 1:n
           # If i is more counterclockwise than current q, then
           # update q
           if (orientation(points[p], points[i], points[q]) == 2)
               q = i
           end
        end

        # Now q is the most counterclockwise with respect to p
        # Set p as q for next iteration, so that q is added to
        # result 'hull'
        p = q
        
        p == l && break
	end
	
	return hull
end



function distance(p::Point, q::Point)::Float64
	return sqrt( (p.x - q.x)^ 2 + (p.y - q.y) ^ 2)
end

function parse(filename)::Tuple{Array{Point,1},Array{String,1},Array{Float64,2}}

	f = open(filename)
	xyData = Array{Point}(0)
	names = Array{String}(0)
	if splitext(filename)[2] == ".tsp"
		coord_section = false
		for ln in eachline(f)			
			if !coord_section
				if ln == "NODE_COORD_SECTION\n"
					coord_section = true
				end
			else
				d = split(chomp(ln), " ")
				d = setdiff(d,[""])
				if length(d) >= 3
					push!(xyData, Point(Base.parse(Float64,d[2]) , Base.parse(Float64,d[3])) )
					push!(names, d[1])
				end
			end
		end
	else
		for ln in eachline(f)
			d = split(ln, " ")
			if length(d) >= 3
				push!(xyData, Point(Base.parse(Float64,d[1]) , Base.parse(Float64,d[2])) )
				push!(names, replace(join(d[3:end]," "), "\n", ""))
			end
		end
	end
	close(f)

	n = length(xyData)
	distancier = Matrix(n,n)
	for i = 1:n
		for j = 1:n
			distancier[i,j] = distance(xyData[i], xyData[j])
		end
	end
	return xyData, names, distancier
end

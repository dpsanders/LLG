# using DataStructures

function initialise(L)

	#mirrors::Array{Int8, 2} = 2 .* randbool(L, L) .- 1;
	#mirror_types::Array{Int8, 2} = zeros(mirrors);
	#paths::Array{Int32, 2} = zeros(mirrors);

	# paths stores the number of the path that previously touched a mirror

	# global delta_index
	# const delta_index = [L 1 -L -1]

	#r = randbool(L, L)
	# mirrors = Array(Int8, (L, L))
    
 #    for i in 1:length(mirrors)
 #        if rand() < 0.5
 #            mirrors[i] = -1
 #        else
 #            mirrors[i] = 1
 #        end
 #    end

    r = rand(L, L)
    mirrors = Array(Int8, (L, L))
    for i in 1:length(mirrors)
        if r[i] < 0.5
            mirrors[i] = -1
        else
            mirrors[i] = 1
        end
    end
    


	delta_index = [L 1 -L -1]

	#return (mirrors, mirror_types, paths)
	return mirrors, delta_index

end



const up, right, down, left = 1, 2, 3, 4

const reflection = [
	4 3 2 1
	1 2 3 4
	2 1 4 3
]



function startingPoint(L, starting_side, x_start)
	y_start = -1

    if starting_side == 1  # bottom
    	x, y, direction = x_start, 0, up

	elseif starting_side == 2  # right
        	x, y, direction = L+1, x_start, left

	elseif starting_side == 3  # top
        	x, y, direction = L+1 - x_start, L+1, down

	else # left
        	x, y, direction = 0, L+1 - x_start, right

    end

	return (x, y, direction)
end



function print_mirrors(mirrors)

	mirrors_reversed = mirrors'[end:-1:1, :]
	# this strange expression is due to the difference between thinking of (x,y)
	# as an index for a matrix (x down, y across) or in a Cartesian graph (x across, y up)

	s = "$(mirrors_reversed)"
	s = replace(s, "-1", "\\")
	s = replace(s, "1", "/")
	s = replace(s, "\t", " ")

	println(s)

end        


function chooseDirectionCheckExited!(direction, x, y, L)
	# returns true if leave box
	
	exited = false

	if direction == up
		y += 1
		if y > L 
			exited = true
		end

	elseif direction == right
		x += 1
		if x > L
			exited = true
		end

	elseif direction == down
		y -= 1
		if y < 1
			exited = true
		end

	elseif direction == left
		x -= 1
		if x < 1
			exited = true
		end

	end

	return (x, y, exited)
end

function chooseDirection!(direction, x, y, L)
	
	if direction == up
		y += 1
		
	elseif direction == right
		x += 1
		
	elseif direction == down
		y -= 1
		
	elseif direction == left
		x -= 1
		
	end

	return (x, y)
end


function chooseDirectionNew(direction, mirror_index, L, delta_index)
	# version using single index for
	
	# if direction == up
	# 	# y += 1
	# 	mirror_index += L

	# elseif direction == right
	# 	# x += 1
	# 	mirror_index += 1
		
	# elseif direction == down
	# 	# y -= 1
	# 	mirror_index -= L
		
	# elseif direction == left
	# 	# x -= 1
	# 	mirror_index -= 1
	
	# end

	#return mirror_index
	return mirror_index + delta_index[direction]

end

convert_to_index(L, x, y) = (y-1)*L + x 
# (presumably) more efficient than generic sub2ind

convert_from_index(L, mirror_index) = 
	( ((mirror_index-1) % L) + 1, int(ceil(mirror_index / L)) )  


function findOpenPaths!(L, mirrors) #, mirror_types, paths)

	println("\n# Finding open paths")
	
	output_traj = false

	path_number = 1

	visited = Set{(Int, Int)}()
	# mirror_list = Set{Int64}()
	mirror_list = IntSet()

	OO_lengths = Int[]
	total_open_length = 0
	# num_OO_same = 0
	# num_OO_distinct = 0

	num_OO = 0

	#current_traj = IntSet()


	# idea of the algorithm:
	# when hit a mirror for the first time, add it to the list
	# if don't hit again, it is an OC
	# if hit again, it is an OO; register the fact, and remove it from the list
	# Thus by the end of the process, only the OCs remain in the list

	for starting_side in 1:4
		for x_start in 1:L

			(x, y, direction) = startingPoint(L, starting_side, x_start)

			if output_traj
				println("# Starting at ($x, $y) in direction $direction")
			end

			if in((x,y), visited)
				continue
			end

			length = 0

			while true

				(x, y, finished) = chooseDirectionCheckExited!(direction, x, y, L)

				if finished
					break
				end

	            mirror_type = mirrors[x, y] 
	           
	            # reflect: 

	            previous_direction = direction
	            direction = reflection[sign(mirror_type)+2, direction]

	            length += 1

	            mirror_index = convert_to_index(L,x,y)

	            if mirror_type != 0
	            	if abs(mirror_type) == 1  # not hit yet
	            		# if direction == up || previous_direction == down
	            		# 	paths[x, y] = path_number  # positive for loop above
	            		# else
	            		# 	paths[x, y] = -path_number  # positive for loop below
	            		# end

	            		# paths[mirror_index] = 
	            		# 	(direction == up || previous_direction == down) ? path_number : (-path_number)


#	            		mirrors[mirror_index] *= ((direction == up || previous_direction == down) ? 2 : 4)

	            		mirrors[mirror_index] <<= ((direction == up || previous_direction == down) ? 1 : 2)


	            		push!(mirror_list, mirror_index)
	            		# hit once, so it could be an OC

	            	else  # already hit
	            		# if abs(paths[mirror_index]) == path_number  # hit by same path
	            		# 	mirror_types[mirror_index] = 1  
	            		# 	num_OO_same += 1
	            		# else
	            		# 	mirror_types[mirror_index] = 2  
	            		# 	num_OO_distinct += 1
	            		# end

	            		num_OO += 1

	            		delete!(mirror_list, mirror_index)
	            		# hit twice, so it is not an OC
	            	end


	            end
	            
	            if output_traj
	            	println("($x, $y); direction $direction; mirror_type: $mirror_type")
	            end

        	end

	        if output_traj
	            	println("($x, $y); direction $direction")
	        end
	        
	        push!(visited, (x,y))


			push!(OO_lengths, length)
			total_open_length += length


			path_number += 1

			if output_traj
				println()
			end

		end

	end

	num_open_paths = path_number - 1

	println("# num open paths: ", num_open_paths)
	#println("# lengths: ", OO_lengths')
	println("# total open length: ", total_open_length)
	println("# open length fraction: ", total_open_length / (2*L*L))
	# println("# num_OO_same: ", num_OO_same)
	# println("# num_OO_distinct: ", num_OO_distinct)
	println("# num_OO: ", num_OO)
	#println("# num_OO_distinct: ", num_OO_distinct)


	# for pos in mirror_list
	# 	mirror_types[pos] = 3  # OC
	# end


	println("# num_OC = ", length(mirror_list))



	return mirror_list, path_number, total_open_length, num_open_paths, num_OO

end


# function findClosedPaths!(L, mirrors, mirror_types, paths, OC_mirror_list, path_number)
function findClosedPathsTouchingOpen!(L, mirrors, OC_mirror_list, path_number, delta_index)


	println("\n# Finding closed touching open paths")
	
	output_traj = false
	initial_path_number = path_number

	CC_mirror_list = IntSet() #Set{Int}()
	done = IntSet() # Set{Int}()

	CC_lengths = Int[]
	total_closed_length = 0
	# num_CC_same = 0
	# num_CC_distinct = 0
	num_CC  = 0

	
	
	# iterate over all OCs and launch a trajectory
	# if we hit an OC in the process, then remove that OC from the list, since 
	# already "done" (this is taken account of in the new list "done")

	for mirror_index in OC_mirror_list
		if mirror_index in done 
			continue
		end

		#(x,y) = convert_from_index(L, mirror_index)

		#println("index: $mirror_index; x,y=($x,$y)")

		#touching_path = paths[mirror_index]  # there should only be one

		# if touching_path > 0  # previous visit was from above
		# 	direction = down
		# else
		# 	direction = up
		# end

		direction = (abs(mirrors[mirror_index]) == 2) ? down : up
		# touching_path is positive if previous visit was from above
		# in this case, start downwards to do the other part (which must be a closed path)


		if output_traj
			println("# Starting at ($x, $y) in direction $direction")
		end

			# println("# Starting at ($x, $y) in direction $direction")
			# 		println("touching_path: $touching_path")




		length = 0

		#(x_initial, y_initial) = (x, y)
		initial_index = mirror_index

		while true

			#(x, y) = chooseDirection!(direction, x, y, L)

			mirror_index = chooseDirectionNew(direction, mirror_index, L, delta_index)


			#if (x,y) == (x_initial, y_initial)  # loop
			if mirror_index == initial_index
				break
			end

			mirror_type = mirrors[mirror_index] 
			#println("$x, $y, mirror_type: $mirror_type, direction=$direction")
            
           
            # reflect: 

            previous_direction = direction
            direction = reflection[sign(mirror_type)+2, direction]

            length += 1

            if mirror_type != 0
            	#mirror_index = convert_to_index(L, x, y)

            	if in(mirror_index, OC_mirror_list)
            		push!(done, mirror_index)  # already accounted for
            	
            	elseif in(mirror_index, CC_mirror_list)
        			# if abs(paths[mirror_index] == path_number) 
        			# 	mirror_types[mirror_index] = 4  
        			# 	num_CC_same += 1
        			# else
        			# 	mirror_types[mirror_index] = 5
        			# 	num_CC_distinct += 1
        			# end

        			num_CC += 1

        			delete!(CC_mirror_list, mirror_index)


            	else  # not visited yet
            		if direction == up || previous_direction == down
            			#mirrors[mirror_index] *= 2
            			mirrors[mirror_index] <<= 1
            			# paths[mirror_index] = path_number  # positive for loop above
            		else
            			# paths[mirror_index] = -path_number  # positive for loop below
            			#mirrors[mirror_index] *= 4
            			mirrors[mirror_index] <<= 2
            		end

            		push!(CC_mirror_list, mirror_index)

            	end


            end
            
            if output_traj
            	println("($x, $y); direction: $direction; mirror_type: $mirror_type")
            end

    	end

    	if output_traj
            println("($x, $y); direction: $direction; mirror_type: $mirror_type")
        end
        
        length += 1

		push!(CC_lengths, length)
		total_closed_length += length


		path_number += 1

		if output_traj
			println()
		end

	end

	num_closed_paths_touching_open = path_number - initial_path_number
	total_closed_length_touching_open = total_closed_length

	println("# num closed paths touching open ones: ", num_closed_paths_touching_open)
	# println("# closed lengths: ", CC_lengths')
	println("# total closed length touching open: ", total_closed_length_touching_open)
	
	# println("# num_CC_same: ", num_CC_same)
	# println("# num_CC_distinct: ", num_CC_distinct)

	println("# num CC: ", num_CC)

	return CC_mirror_list, path_number, total_closed_length_touching_open, 
				num_closed_paths_touching_open, num_CC

end


#function findClosedClosedPaths!(L, mirrors, mirror_types, paths, CC_mirror_list, path_number)
function findEmbeddedClosedPaths!(L, mirrors, CC_mirror_list, path_number, delta_index)


	println("\n# Finding closed closed paths")
	output_traj = false
	initial_path_number = path_number

	done = IntSet() #Set{Int}()
	newly_found = IntSet() #Set{Int}()

	CC_lengths = Int[]
	total_closed_length = 0
	# num_CC_same = 0
	# num_CC_distinct = 0
 
	num_CC = 0

	
	# CC_mirror_list should contain those CC mirrors which have been touched
	# exactly once, so from which must launch a trajectory

	while true  # collections of CC_mirror_list


		# println(CC_mirror_list)
		
		for mirror_index in CC_mirror_list
			if mirror_index in done 
				continue
			end


			#println("index: $mirror_index; x,y=($x,$y)")

			#touching_path = paths[mirror_index]  # there should only be one

			# if touching_path > 0  # previous visit was from above
			# 	direction = down
			# else
			# 	direction = up
			# end

			direction = (abs(mirrors[mirror_index]) == 2) ? down : up
			# touching_path is positive if previous visit was from above
			# in this case, start downwards to do the other part (which must be a closed path)


			if output_traj
				println("# Starting at ($x, $y) in direction $direction")
			end

				# println("# Starting at ($x, $y) in direction $direction")
				# 		println("touching_path: $touching_path")

			length = 0

			#(x,y) = convert_from_index(L, mirror_index)
			#(x_initial, y_initial) = (x, y)
			initial_index = mirror_index

			while true

				#(x, y) = chooseDirection!(direction, x, y, L)
				mirror_index = chooseDirectionNew(direction, mirror_index, L, delta_index)

				#if (x,y) == (x_initial, y_initial)  # loop
				if mirror_index == initial_index
					break
				end

					# println("$x, $y") #, mirror_type: $mirror_type, direction=$direction")
				

				mirror_type = mirrors[mirror_index] 
	            
	           
	            # reflect: 

	            previous_direction = direction
	            direction = reflection[sign(mirror_type)+2, direction]

	            length += 1

	            if mirror_type != 0
	            	#mirror_index = convert_to_index(L, x, y)

	            	if in(mirror_index, CC_mirror_list) || in(mirror_index, newly_found)
	            		push!(done, mirror_index)  # already accounted for

	           #  		if abs(paths[mirror_index] == path_number) 
        				# 	mirror_types[mirror_index] = 4  
        				# 	num_CC_same += 1
        				# else
        				# 	mirror_types[mirror_index] = 5
        				# 	num_CC_distinct += 1
        				# end

        				num_CC += 1

	            	else  # not visited yet
	            		if direction == up || previous_direction == down
	            			#paths[mirror_index] = path_number  # positive for loop above
	            			#mirrors[mirror_index] *= 2
	            			mirrors[mirror_index] <<= 1

	            		else
	            			# paths[mirror_index] = -path_number  # positive for loop below
	            			# mirrors[mirror_index] *= 4
	            			mirrors[mirror_index] <<= 2


	            		end

	            		push!(newly_found, mirror_index)  # aguas!

	            	end


	            end
	            
	            if output_traj
	            	println(x, ", ", y, "\t", direction, "\t", mirror_type)
	            end

	    	end

	        if output_traj
	        	println(x, ", ", y)
	        end
	     
	     	length += 1

			push!(CC_lengths, length)
			total_closed_length += length


			path_number += 1

			if output_traj
				println()
			end

		end

		if length(newly_found) == 0
			break  # no more found
		end

		union!(done, CC_mirror_list)
		CC_mirror_list = newly_found
		newly_found = IntSet() #Set{Int}()

	end

	num_embedded_closed_paths = path_number - initial_path_number

	println("# num closed closed paths: ", num_embedded_closed_paths)
	# println("# closed lengths: ", CC_lengths')
	println("# total closed closed length: ", total_closed_length)
	# println("# num_CC_same: ", num_CC_same)
	# println("# num_CC_distinct: ", num_CC_distinct)
	println("# num_CC_2: ", num_CC)
	return num_embedded_closed_paths, total_closed_length, num_CC

end



function run_LLG(L)

	# println("Initialising with small system")
	# L_small = 10
	# (mirrors, mirror_types, paths) = initialise(L_small)
	# mirror_list = findOpenPaths!(L_small, mirrors, mirror_types, paths)

	println()
	println("# L = ", L)

	@time begin
	#	(mirrors, mirror_types, paths) = initialise(L)
		mirrors, delta_index = initialise(L)
		# println(mirrors)
	
	end

	@time begin
		#OC_mirror_list, path_number, total_open_length = findOpenPaths!(L, mirrors, mirror_types, paths)
		OC_mirror_list, path_number, total_open_length, 
		num_open_paths, num_OO  = findOpenPaths!(L, mirrors)
		
		#print(mirror_list)
	end

	# println(mirrors'[end:-1:1, :])
	# print_mirrors(mirrors)

	# println(mirror_types'[end:-1:1, :])

	# println(paths'[end:-1:1, :])

	# println(OC_mirror_list)
	# println([convert_from_index(L, x) for x in OC_mirror_list])

	@time begin
		# print_mirrors(mirrors)
		# println(mirrors'[end:-1:1, :])
		CC_mirror_list, path_number, total_closed_length_touching_open, 
			num_closed_paths_touching_open, num_CC_1 = 
			findClosedPathsTouchingOpen!(L, mirrors, OC_mirror_list, 
											path_number, delta_index)

	end

	# println("CC_mirror_list: ", CC_mirror_list)


	@time begin
		#total_closed_closed_length = findClosedClosedPaths!(L, mirrors, mirror_types, paths, CC_mirror_list, path_number)
		num_embedded_closed_paths, total_closed_closed_length, num_CC_2 = 
		findEmbeddedClosedPaths!(L, mirrors, CC_mirror_list, path_number, delta_index)

	end


	total_length = total_open_length +
		 total_closed_length_touching_open + total_closed_closed_length
	println("\n# Total length: ", total_length)
	println("# Expected: ", 2*L*L)
	println("# Difference: ", 2*L*L - total_length)

	#return (L, mirrors, mirror_types, paths)
end


if length(ARGS) > 0
	L = int(ARGS[1])
	run_LLG(10)
	
	@time run_LLG(L)
end


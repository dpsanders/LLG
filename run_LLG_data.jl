using finite_LLG

if length(ARGS) > 0
    min_L, step_L, max_L, num_repetitions = map(int, ARGS)

else
    min_L = 10
    step_L = 10
    max_L = 50000
    num_repetitions = 100
end


outfile = open("all_finite_LLG_data.dat", "a")

for L in min_L:step_L:max_L

    for i in 1:num_repetitions

        @time total_open_length, num_open_paths, num_OO, num_OC, 
        total_closed_length_touching_open, num_closed_paths_touching_open, num_CC_1,
        num_embedded_closed_paths, total_closed_closed_length, num_CC_2 =
             run_LLG(L)

        print("$L\t$i\t")
        writedlm(outfile, [i for i in (L, total_open_length, num_open_paths, num_OO, num_OC, 
        total_closed_length_touching_open, num_closed_paths_touching_open, num_CC_1,
        num_embedded_closed_paths, total_closed_closed_length, num_CC_2) ]' )

        flush(outfile)


    end
end